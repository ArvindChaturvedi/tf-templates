# AWS Security Module for Aurora PostgreSQL
# This module creates security-related resources for Aurora DB clusters

# KMS Key for Aurora PostgreSQL Encryption
resource "aws_kms_key" "aurora" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for Aurora PostgreSQL cluster encryption - ${var.name}"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_enable_rotation
  policy                  = var.kms_key_policy == "" ? data.aws_iam_policy_document.kms_key_policy[0].json : var.kms_key_policy

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-kms-key"
    },
  )
}

# KMS Key Alias
resource "aws_kms_alias" "aurora" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.name}-aurora-key"
  target_key_id = aws_kms_key.aurora[0].key_id
}

# KMS Key Policy
data "aws_iam_policy_document" "kms_key_policy" {
  count = var.create_kms_key ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow RDS to use the key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_admin_arns
    content {
      sid    = "Allow key administration for ${statement.value}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }

      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.kms_key_user_arns
    content {
      sid    = "Allow key usage for ${statement.value}"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }
}

# Get current caller identity for KMS policy
data "aws_caller_identity" "current" {}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  name = "${var.name}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-monitoring-role"
    },
  )
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Secret for Aurora PostgreSQL master credentials
resource "aws_secretsmanager_secret" "aurora_master" {
  count = var.create_db_credentials_secret ? 1 : 0

  name        = "${var.name}-aurora-master-credentials"
  description = "Secret for Aurora PostgreSQL master credentials for ${var.name}"
  
  recovery_window_in_days = var.secret_recovery_window_in_days
  
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-aurora-master-credentials"
    },
  )
}

# Random password for master user
resource "random_password" "master_password" {
  count = var.create_db_credentials_secret && var.generate_master_password ? 1 : 0
  
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Secret version for Aurora PostgreSQL master credentials
resource "aws_secretsmanager_secret_version" "aurora_master" {
  count = var.create_db_credentials_secret ? 1 : 0
  
  secret_id = aws_secretsmanager_secret.aurora_master[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = var.generate_master_password ? random_password.master_password[0].result : var.master_password
    engine   = "postgresql"
    host     = var.db_cluster_endpoint
    port     = var.db_port
    dbname   = var.database_name
  })
}

# IAM Policy for accessing the Aurora PostgreSQL credentials
resource "aws_iam_policy" "secret_access" {
  count = var.create_db_credentials_secret && var.create_secret_access_policy ? 1 : 0

  name        = "${var.name}-secret-access-policy"
  description = "IAM policy for accessing Aurora PostgreSQL credentials for ${var.name}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.aurora_master[0].arn
      },
    ]
  })
}

# IAM Role for DB access via IAM authentication
resource "aws_iam_role" "db_access" {
  count = var.create_db_access_role ? 1 : 0

  name        = "${var.name}-db-access-role"
  description = "IAM role for accessing Aurora PostgreSQL DB via IAM authentication for ${var.name}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-db-access-role"
    },
  )
}

# IAM Policy for DB access via IAM authentication
resource "aws_iam_policy" "db_access" {
  count = var.create_db_access_role ? 1 : 0

  name        = "${var.name}-db-access-policy"
  description = "IAM policy for connecting to Aurora PostgreSQL DB via IAM authentication for ${var.name}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds-db:connect"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.db_cluster_resource_id}/${var.master_username}"
      },
    ]
  })
}

# Attachment of the DB access policy to the DB access role
resource "aws_iam_role_policy_attachment" "db_access" {
  count = var.create_db_access_role ? 1 : 0

  role       = aws_iam_role.db_access[0].name
  policy_arn = aws_iam_policy.db_access[0].arn
}

# Get current region for IAM policy
data "aws_region" "current" {}

# SNS Topic for Aurora PostgreSQL notifications
resource "aws_sns_topic" "aurora_notifications" {
  count = var.create_sns_topic ? 1 : 0

  name = "${var.name}-aurora-notifications"
  
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-aurora-notifications"
    },
  )
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "aurora_notifications" {
  count = var.create_sns_topic ? 1 : 0

  arn    = aws_sns_topic.aurora_notifications[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

# SNS Topic Policy Document
data "aws_iam_policy_document" "sns_topic_policy" {
  count = var.create_sns_topic ? 1 : 0

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.aurora_notifications[0].arn,
    ]
  }
}

# RDS Event Subscription for Aurora PostgreSQL
resource "aws_db_event_subscription" "aurora" {
  count = var.create_sns_topic && var.create_db_event_subscription ? 1 : 0

  name      = "${var.name}-event-subscription"
  sns_topic = aws_sns_topic.aurora_notifications[0].arn
  
  source_type = "db-cluster"
  source_ids  = [var.db_cluster_id]
  
  event_categories = [
    "availability",
    "backup",
    "configuration change",
    "creation",
    "deletion",
    "failover",
    "failure",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration"
  ]

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-event-subscription"
    },
  )
}
