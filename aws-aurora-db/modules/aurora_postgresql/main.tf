# AWS Aurora PostgreSQL Terraform Module
# This module creates an Aurora PostgreSQL cluster with customizable parameters

locals {
  name        = var.name
  port        = var.port
  final_tags  = merge(var.tags, {
    "Terraform"   = "true"
    "Environment" = var.environment
    "Application" = var.application_name
  })
}

# Create a random password if not provided
resource "random_password" "master_password" {
  count   = var.master_password == "" ? 1 : 0
  length  = 16
  special = false
}

# Aurora PostgreSQL DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name        = "${local.name}-subnet-group"
  description = "Subnet group for ${local.name} Aurora PostgreSQL cluster"
  subnet_ids  = var.subnet_ids

  tags = merge(
    local.final_tags,
    {
      "Name" = "${local.name}-subnet-group"
    },
  )
}

# Aurora PostgreSQL DB Parameter Group
resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${local.name}-cluster-parameter-group"
  family      = var.db_parameter_group_family
  description = "Cluster parameter group for ${local.name} Aurora PostgreSQL cluster"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = local.final_tags
}

# Aurora PostgreSQL DB Instance Parameter Group
resource "aws_db_parameter_group" "this" {
  name        = "${local.name}-instance-parameter-group"
  family      = var.db_parameter_group_family
  description = "Instance parameter group for ${local.name} Aurora PostgreSQL cluster"

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = local.final_tags
}

# Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "this" {
  cluster_identifier              = "${local.name}-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  availability_zones              = var.availability_zones
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = var.master_password == "" ? random_password.master_password[0].result : var.master_password
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  port                            = local.port
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = var.security_group_ids
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.kms_key_id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${local.name}-final-snapshot-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  apply_immediately               = var.apply_immediately
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  # Enable IAM database authentication if specified
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  
  # Enable auto minor version upgrade if specified
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  
  # Enable backtrack if specified
  backtrack_window                = var.backtrack_window

  # Enable Serverless v2 if specified
  serverlessv2_scaling_configuration {
    min_capacity = var.serverless_min_capacity
    max_capacity = var.serverless_max_capacity
  }

  tags = local.final_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Aurora PostgreSQL Cluster Instances
resource "aws_rds_cluster_instance" "this" {
  count                        = var.instance_count
  identifier                   = "${local.name}-instance-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.this.id
  engine                       = "aurora-postgresql"
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = aws_db_subnet_group.this.name
  db_parameter_group_name      = aws_db_parameter_group.this.name
  apply_immediately            = var.apply_immediately
  monitoring_role_arn          = var.monitoring_role_arn
  monitoring_interval          = var.monitoring_interval
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  performance_insights_enabled = var.performance_insights_enabled
  
  # Add performance insights retention period if enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  
  # Add performance insights KMS key if specified
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

  tags = merge(
    local.final_tags,
    {
      "Name" = "${local.name}-instance-${count.index + 1}"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Aurora PostgreSQL Cluster Endpoint
resource "aws_rds_cluster_endpoint" "reader" {
  count                       = var.create_custom_endpoints ? 1 : 0
  cluster_identifier          = aws_rds_cluster.this.id
  cluster_endpoint_identifier = "${local.name}-reader"
  custom_endpoint_type        = "READER"

  tags = local.final_tags
}

# Create CloudWatch Alarms for the Aurora Cluster
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  count               = var.create_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "Average database CPU utilization is too high"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.this.id
  }

  tags = local.final_tags
}

resource "aws_cloudwatch_metric_alarm" "free_memory_low" {
  count               = var.create_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name}-free-memory-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.freeable_memory_threshold
  alarm_description   = "Average database freeable memory is too low"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.this.id
  }

  tags = local.final_tags
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_high" {
  count               = var.create_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name}-disk-queue-depth-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.disk_queue_depth_threshold
  alarm_description   = "Average database disk queue depth is too high"
  alarm_actions       = var.cloudwatch_alarm_actions
  ok_actions          = var.cloudwatch_ok_actions

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.this.id
  }

  tags = local.final_tags
}
