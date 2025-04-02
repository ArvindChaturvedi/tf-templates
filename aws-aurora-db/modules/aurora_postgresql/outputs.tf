output "cluster_id" {
  description = "The ID of the Aurora cluster"
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the Aurora cluster"
  value       = aws_rds_cluster.this.arn
}

output "cluster_endpoint" {
  description = "The writer endpoint of the Aurora cluster"
  value       = aws_rds_cluster.this.endpoint
}

output "cluster_reader_endpoint" {
  description = "The reader endpoint of the Aurora cluster"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "custom_reader_endpoint" {
  description = "The custom reader endpoint of the Aurora cluster"
  value       = var.create_custom_endpoints ? aws_rds_cluster_endpoint.reader[0].endpoint : null
}

output "cluster_port" {
  description = "The port of the Aurora cluster"
  value       = aws_rds_cluster.this.port
}

output "cluster_instances" {
  description = "A map of cluster instances and their attributes"
  value       = aws_rds_cluster_instance.this
}

output "cluster_instance_ids" {
  description = "A list of all cluster instance IDs"
  value       = aws_rds_cluster_instance.this.*.id
}

output "cluster_master_username" {
  description = "The master username for the database"
  value       = aws_rds_cluster.this.master_username
  sensitive   = true
}

output "cluster_master_password" {
  description = "The master password for the database"
  value       = var.master_password == "" ? random_password.master_password[0].result : var.master_password
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "The DB subnet group ID"
  value       = aws_db_subnet_group.this.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group"
  value       = aws_db_subnet_group.this.arn
}

output "cluster_parameter_group_id" {
  description = "The cluster parameter group ID"
  value       = aws_rds_cluster_parameter_group.this.id
}

output "cluster_parameter_group_arn" {
  description = "The ARN of the cluster parameter group"
  value       = aws_rds_cluster_parameter_group.this.arn
}

output "instance_parameter_group_id" {
  description = "The instance parameter group ID"
  value       = aws_db_parameter_group.this.id
}

output "instance_parameter_group_arn" {
  description = "The ARN of the instance parameter group"
  value       = aws_db_parameter_group.this.arn
}

output "security_group_ids" {
  description = "List of security group IDs used by the cluster"
  value       = var.security_group_ids
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The ARN of the monitoring role"
  value       = var.monitoring_role_arn
}

output "database_name" {
  description = "The database name"
  value       = var.database_name
}

output "cloudwatch_alarm_arns" {
  description = "The ARNs of the CloudWatch alarms"
  value       = concat(
    var.create_cloudwatch_alarms ? [aws_cloudwatch_metric_alarm.cpu_utilization_high[0].arn] : [],
    var.create_cloudwatch_alarms ? [aws_cloudwatch_metric_alarm.free_memory_low[0].arn] : [],
    var.create_cloudwatch_alarms ? [aws_cloudwatch_metric_alarm.disk_queue_depth_high[0].arn] : []
  )
}

output "jdbc_connection_string" {
  description = "JDBC connection string for the Aurora cluster"
  value       = "jdbc:postgresql://${aws_rds_cluster.this.endpoint}:${aws_rds_cluster.this.port}/${var.database_name}"
  sensitive   = false
}

output "connection_map" {
  description = "Map of connection details for the Aurora cluster"
  value = {
    endpoint  = aws_rds_cluster.this.endpoint
    port      = aws_rds_cluster.this.port
    database  = var.database_name
    username  = aws_rds_cluster.this.master_username
    password  = var.master_password == "" ? random_password.master_password[0].result : var.master_password
  }
  sensitive = true
}
