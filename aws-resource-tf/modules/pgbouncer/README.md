# PGBouncer Connection Pooling Module

This module deploys PGBouncer connection pooling for Aurora PostgreSQL using an Auto Scaling Group of EC2 instances, providing reliable and scalable database connection management.

## Overview

PGBouncer is a lightweight connection pooler for PostgreSQL that significantly reduces the impact of frequent connection creation on the database server. This module:

1. Creates an Auto Scaling Group of EC2 instances running PGBouncer
2. Configures each instance with a user data script that installs and sets up PGBouncer
3. Optionally creates a load balancer to distribute connections 
4. Sets up monitoring, logging, and health checks

## Architecture

```
┌───────────────┐      ┌─────────────────┐      ┌───────────────┐
│               │      │ Auto Scaling    │      │               │
│ Applications  │─────▶│ Group with      │─────▶│ Aurora        │
│ or EKS Pods   │      │ PGBouncer       │      │ PostgreSQL    │
│               │      │ Instances       │      │               │
└───────────────┘      └─────────────────┘      └───────────────┘
                               │
                               │
                        ┌──────▼───────┐
                        │ CloudWatch   │
                        │ Monitoring & │
                        │ Logging      │
                        └──────────────┘
```

## Features

- **High Availability**: Deployed across multiple Availability Zones
- **Auto Scaling**: Automatically adjusts capacity based on load
- **Secure Connectivity**: Security groups to control access
- **Custom Configuration**: Easily tune PGBouncer parameters
- **Health Monitoring**: Health checks ensure only healthy instances are used
- **Load Balancing**: Optional Network Load Balancer for connection distribution
- **Unified Entry Point**: Single DNS name for client connections
- **Customizable User Data**: Bootstrap script can be customized as needed

## Usage

```hcl
module "pgbouncer" {
  source = "../../modules/pgbouncer"

  name                      = "app-pgbouncer"
  
  # VPC and networking
  vpc_id                    = "vpc-0123456789abcdef0"
  subnet_ids                = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
  
  # Aurora DB connection details
  db_host                   = module.aurora.cluster_endpoint
  db_port                   = 5432
  db_name                   = "appdb"
  db_user                   = "dbadmin"
  db_password_secret_arn    = module.aurora.master_user_secret_arn
  
  # PGBouncer configuration
  pgbouncer_port            = 6432
  max_client_conn           = 1000
  default_pool_size         = 20
  max_db_connections        = 100
  
  # EC2 instance configuration
  instance_type             = "t3.micro"
  key_name                  = "ssh-key-name"
  assign_public_ip          = false
  
  # Auto scaling
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 4
  
  # Security
  allowed_security_group_ids = ["sg-0123456789abcdef3"]
  
  # Load Balancer
  create_lb                 = true
  
  # Custom parameters
  custom_pgbouncer_params   = "server_idle_timeout = 300"
  
  tags = {
    Environment = "production"
    Application = "customer-portal"
  }
}
```

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for the PGBouncer resources | `string` | n/a | yes |
| vpc_id | ID of the VPC where resources will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the Auto Scaling group | `list(string)` | n/a | yes |
| db_host | Aurora PostgreSQL host endpoint | `string` | n/a | yes |
| db_port | Aurora PostgreSQL port | `number` | n/a | yes |
| db_name | Aurora PostgreSQL database name | `string` | n/a | yes |
| db_user | Aurora PostgreSQL master username | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db_password | Aurora PostgreSQL password. Either this or db_password_secret_arn must be provided | `string` | `""` | no |
| db_password_secret_arn | Secret ARN for the Aurora PostgreSQL password | `string` | `""` | no |
| pgbouncer_port | Port that PGBouncer will listen on | `number` | `6432` | no |
| max_client_conn | Maximum number of client connections allowed | `number` | `1000` | no |
| default_pool_size | How many server connections to allow per user/database pair | `number` | `20` | no |
| min_pool_size | Minimum number of server connections to keep per user/database pair | `number` | `0` | no |
| max_db_connections | Maximum number of connections per database | `number` | `0` | no |
| instance_type | EC2 instance type for PGBouncer instances | `string` | `"t3.micro"` | no |
| ami_id | AMI ID for PGBouncer instances (defaults to latest Amazon Linux 2) | `string` | `""` | no |
| key_name | SSH key name to use for the instances | `string` | `""` | no |
| assign_public_ip | Whether to assign public IPs to the instances | `bool` | `false` | no |
| desired_capacity | Desired number of PGBouncer instances | `number` | `2` | no |
| min_size | Minimum number of PGBouncer instances | `number` | `2` | no |
| max_size | Maximum number of PGBouncer instances | `number` | `4` | no |
| allowed_security_group_ids | List of security group IDs allowed to connect to PGBouncer | `list(string)` | `[]` | no |
| enable_ssh | Whether to allow SSH access to the instances | `bool` | `false` | no |
| ssh_security_group_ids | List of security group IDs allowed to SSH to instances | `list(string)` | `[]` | no |
| create_lb | Whether to create a load balancer for PGBouncer | `bool` | `true` | no |
| health_check_path | Health check path for the load balancer target group | `string` | `"/"` | no |
| custom_pgbouncer_params | Custom parameters for PGBouncer configuration | `string` | `""` | no |
| user_data_replace_on_change | Whether to replace instances when user_data changes | `bool` | `true` | no |
| additional_iam_policies | List of additional IAM policy ARNs to attach to instance profile | `list(string)` | `[]` | no |
| tags | Map of tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| security_group_id | The ID of the security group for PGBouncer instances |
| auto_scaling_group_id | The ID of the Auto Scaling group |
| auto_scaling_group_arn | The ARN of the Auto Scaling group |
| load_balancer_dns_name | The DNS name of the load balancer (if created) |
| load_balancer_arn | The ARN of the load balancer (if created) |
| iam_role_arn | The ARN of the IAM role for PGBouncer instances |
| iam_instance_profile_arn | The ARN of the IAM instance profile |
| launch_template_id | The ID of the launch template |
| connection_string | PostgreSQL connection string to use for connecting to PGBouncer |

## Monitoring and Scaling

The module sets up the following monitoring and scaling capabilities:

1. **CloudWatch Agent**: Installed to collect system and PGBouncer metrics
2. **Health Checks**: Configured to verify PGBouncer is responding
3. **Auto Scaling Policies**: Default policies for CPU utilization-based scaling
4. **Logs**: PGBouncer logs are sent to CloudWatch Logs

## PGBouncer Configuration

The module supports various PGBouncer configuration options, including:

- **Pool Mode**: Session, transaction, or statement pooling
- **Authentication**: User/password authentication with optional HBA rules
- **Connection Settings**: Controls for timeouts, backlog, and TLS
- **Pooling Parameters**: Pool sizes, reserve pools, and connection limits

## Security Considerations

The module implements these security practices:

1. **Network Isolation**: Instances are placed in private subnets by default
2. **Security Groups**: Restrictive security groups for controlled access
3. **Credentials Management**: Uses AWS Secrets Manager for database credentials
4. **Minimal Permissions**: IAM roles follow least privilege principle
5. **SSH Access Control**: SSH access disabled by default, can be enabled with restrictions

## Advanced Example

```hcl
module "pgbouncer_advanced" {
  source = "../../modules/pgbouncer"

  name                   = "advanced-pgbouncer"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets
  
  # Aurora DB connection
  db_host                = module.aurora.cluster_endpoint
  db_port                = 5432
  db_name                = "appdb"
  db_user                = "dbadmin"
  db_password_secret_arn = module.aurora.master_user_secret_arn
  
  # PGBouncer tuning
  pgbouncer_port         = 6432
  max_client_conn        = 2000
  default_pool_size      = 25
  min_pool_size          = 5
  max_db_connections     = 150
  
  # Custom parameters
  custom_pgbouncer_params = <<-EOT
    pool_mode = transaction
    server_reset_query = DISCARD ALL
    server_idle_timeout = 300
    server_lifetime = 3600
    server_connect_timeout = 15
    client_login_timeout = 60
    autodb_idle_timeout = 3600
    log_connections = 1
    log_disconnections = 1
    log_pooler_errors = 1
    stats_period = 60
    ignore_startup_parameters = extra_float_digits
  EOT
  
  # Instance configuration
  instance_type          = "t3.small"
  key_name               = aws_key_pair.admin.key_name
  assign_public_ip       = false
  
  # Auto scaling
  desired_capacity       = 3
  min_size               = 2
  max_size               = 6
  
  # Security
  allowed_security_group_ids = [
    module.app_servers.security_group_id,
    module.eks.node_security_group_id
  ]
  
  # SSH access for administrators
  enable_ssh             = true
  ssh_security_group_ids = [module.bastion.security_group_id]
  
  # Load balancer
  create_lb              = true
  
  # Additional IAM permissions
  additional_iam_policies = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    module.custom_metrics_policy.arn
  ]
  
  tags = {
    Environment  = "production"
    Application  = "financial-services"
    Terraform    = "true"
    CostCenter   = "finance-123"
  }
}
```