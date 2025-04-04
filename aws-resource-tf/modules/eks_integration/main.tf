# EKS Integration Module
# This module creates and configures resources for EKS-Aurora connectivity

resource "aws_security_group" "eks_to_aurora" {
  name        = "${var.name}-eks-to-aurora-sg"
  description = "Security group for EKS to Aurora DB connectivity"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-eks-to-aurora-sg"
    }
  )
}

resource "aws_security_group_rule" "eks_to_aurora" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = var.db_security_group_id
  source_security_group_id = aws_security_group.eks_to_aurora.id
  description              = "Allow EKS nodegroups access to Aurora DB"
}

# Create an IAM role for EKS nodes to access Secrets Manager for DB credentials
resource "aws_iam_role_policy" "node_secrets_manager_access" {
  count = var.create_secrets_access_policy ? 1 : 0
  name  = "${var.name}-eks-secrets-access"
  role  = var.node_role_id

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

# Create an IAM policy for EKS IRSA to access Secrets Manager
resource "aws_iam_policy" "irsa_secrets_manager_access" {
  count       = var.create_irsa_secrets_access_policy ? 1 : 0
  name        = "${var.name}-irsa-secrets-access"
  description = "Policy allowing IRSA to access Aurora DB credentials in Secrets Manager"

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

# Create ConfigMap for service discovery
resource "kubernetes_config_map" "aurora_config" {
  count = var.create_k8s_resources ? 1 : 0
  
  metadata {
    name      = "aurora-db-config"
    namespace = var.k8s_namespace
  }

  data = {
    "db_host"     = var.db_endpoint
    "db_port"     = tostring(var.db_port)
    "db_name"     = var.database_name
    "secret_name" = var.db_credentials_secret_name
    "region"      = var.region
  }
}

# Create a ServiceAccount with IRSA for DB access (if specified)
resource "kubernetes_service_account" "db_access" {
  count = var.create_k8s_resources && var.create_service_account ? 1 : 0
  
  metadata {
    name      = "${var.name}-db-access"
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.db_access_role_arn
    }
  }
}