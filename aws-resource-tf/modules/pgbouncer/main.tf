# PGBouncer Module
# This module deploys PGBouncer on EC2 instances for Aurora connection pooling

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for PGBouncer instances
resource "aws_security_group" "pgbouncer" {
  name        = "${var.name}-pgbouncer-sg"
  description = "Security group for PGBouncer instances"
  vpc_id      = var.vpc_id

  # Ingress rule for PGBouncer port (from EKS)
  ingress {
    from_port       = var.pgbouncer_port
    to_port         = var.pgbouncer_port
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "Allow access to PGBouncer from EKS"
  }

  # Ingress rule for SSH (optional)
  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = var.ssh_security_group_ids
      description     = "Allow SSH access to PGBouncer instances"
    }
  }

  # Egress rule for Aurora DB access
  egress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow access to Aurora DB"
  }

  # General egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pgbouncer-sg"
    }
  )
}

# IAM role for PGBouncer instances
resource "aws_iam_role" "pgbouncer" {
  name = "${var.name}-pgbouncer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pgbouncer-role"
    }
  )
}

# IAM instance profile for PGBouncer instances
resource "aws_iam_instance_profile" "pgbouncer" {
  name = "${var.name}-pgbouncer-profile"
  role = aws_iam_role.pgbouncer.name
}

# IAM policy for accessing Secrets Manager (for Aurora credentials)
resource "aws_iam_policy" "secrets_access" {
  count       = var.db_credentials_secret_arn != "" ? 1 : 0
  name        = "${var.name}-pgbouncer-secrets-access"
  description = "Policy for PGBouncer instances to access Aurora DB credentials in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = var.db_credentials_secret_arn
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "secrets_access" {
  count      = var.db_credentials_secret_arn != "" ? 1 : 0
  role       = aws_iam_role.pgbouncer.name
  policy_arn = aws_iam_policy.secrets_access[0].arn
}

# Attach SSM policy for instance management
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.pgbouncer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Launch Template for PGBouncer instances
resource "aws_launch_template" "pgbouncer" {
  name          = "${var.name}-pgbouncer-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.pgbouncer.name
  }

  network_interfaces {
    associate_public_ip_address = var.assign_public_ip
    security_groups             = [aws_security_group.pgbouncer.id]
  }

  # PGBouncer installation and configuration
  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", {
    region                     = var.region
    db_host                    = var.db_endpoint
    db_port                    = var.db_port
    db_name                    = var.database_name
    pgbouncer_port             = var.pgbouncer_port
    max_client_conn            = var.pgbouncer_max_client_conn
    default_pool_size          = var.pgbouncer_default_pool_size
    min_pool_size              = var.pgbouncer_min_pool_size
    max_db_connections         = var.pgbouncer_max_db_connections
    db_credentials_secret_arn  = var.db_credentials_secret_arn
    use_secrets_manager        = var.db_credentials_secret_arn != ""
    db_username                = var.db_username
    db_password                = var.db_password
    custom_pg_params           = var.custom_pg_params
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.name}-pgbouncer"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pgbouncer-lt"
    }
  )
}

# Auto Scaling Group for PGBouncer instances
resource "aws_autoscaling_group" "pgbouncer" {
  name                = "${var.name}-pgbouncer-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.pgbouncer.id
    version = "$Latest"
  }

  health_check_type = "EC2"
  default_cooldown  = 300

  dynamic "tag" {
    for_each = merge(
      var.tags,
      {
        Name = "${var.name}-pgbouncer"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Load Balancer for PGBouncer instances (NLB)
resource "aws_lb" "pgbouncer" {
  count              = var.create_lb ? 1 : 0
  name               = "${var.name}-pgbouncer-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pgbouncer-nlb"
    }
  )
}

# Target Group for PGBouncer instances
resource "aws_lb_target_group" "pgbouncer" {
  count       = var.create_lb ? 1 : 0
  name        = "${var.name}-pgbouncer-tg"
  port        = var.pgbouncer_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = var.pgbouncer_port
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-pgbouncer-tg"
    }
  )
}

# Listener for PGBouncer NLB
resource "aws_lb_listener" "pgbouncer" {
  count             = var.create_lb ? 1 : 0
  load_balancer_arn = aws_lb.pgbouncer[0].arn
  port              = var.pgbouncer_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pgbouncer[0].arn
  }
}

# Attachment for ASG to target group
resource "aws_autoscaling_attachment" "pgbouncer" {
  count                  = var.create_lb ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.pgbouncer.name
  lb_target_group_arn    = aws_lb_target_group.pgbouncer[0].arn
}