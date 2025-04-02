output "cluster_id" {
  description = "The ID of the Aurora cluster"
  value       = aws_rds_cluster.this.id
}

output "cluster_resource_id" {
  description = "The Resource ID of the Aurora cluster"
  value       = aws_rds_cluster.this.cluster_resource_id
}

output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of the Aurora cluster"
  value       = aws_rds_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster"
  value       = aws_rds_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "custom_reader_endpoint" {
  description = "Custom reader endpoint for the Aurora cluster"
  value       = var.create_custom_endpoints ? aws_rds_cluster_endpoint.reader[0].endpoint : null
}

output "cluster_port" {
  description = "The database port for the Aurora cluster"
  value       = aws_rds_cluster.this.port
}

output "database_name" {
  description = "The database name"
  value       = aws_rds_cluster.this.database_name
}

output "master_username" {
  description = "The master username for the database"
  value       = aws_rds_cluster.this.master_username
  sensitive   = true
}

output "instance_identifiers" {
  description = "List of instance identifiers in the Aurora cluster"
  value       = aws_rds_cluster_instance.this[*].identifier
}

output "instance_endpoints" {
  description = "List of instance endpoints in the Aurora cluster"
  value       = aws_rds_cluster_instance.this[*].endpoint
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.this.name
}

output "db_subnet_group_id" {
  description = "The ID of the DB subnet group"
  value       = aws_db_subnet_group.this.id
}

output "cluster_parameter_group_name" {
  description = "The name of the cluster parameter group"
  value       = aws_rds_cluster_parameter_group.this.name
}

output "instance_parameter_group_name" {
  description = "The name of the instance parameter group"
  value       = aws_db_parameter_group.this.name
}

output "security_group_ids" {
  description = "List of security group IDs used by the cluster"
  value       = var.security_group_ids
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms and their properties"
  value = {
    cpu_utilization  = var.create_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cpu_utilization[0].arn : null
    freeable_memory  = var.create_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.freeable_memory[0].arn : null
    disk_queue_depth = var.create_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.disk_queue_depth[0].arn : null
  }
}

output "is_serverless_v2" {
  description = "Indicates if the cluster is using ServerlessV2"
  value       = local.is_serverless_v2
}

output "enhanced_monitoring_enabled" {
  description = "Indicates if enhanced monitoring is enabled"
  value       = var.monitoring_interval > 0
}

output "performance_insights_enabled" {
  description = "Indicates if Performance Insights is enabled"
  value       = var.performance_insights_enabled
}

output "deletion_protection_enabled" {
  description = "Indicates if deletion protection is enabled"
  value       = var.deletion_protection
}

output "iam_auth_enabled" {
  description = "Indicates if IAM database authentication is enabled"
  value       = var.iam_database_authentication_enabled
}