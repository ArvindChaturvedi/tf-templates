output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.networking.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.networking.public_subnets
}

output "db_security_group_id" {
  description = "The ID of the security group for the Aurora DB"
  value       = module.networking.db_security_group_id
}

output "kms_key_id" {
  description = "The ID of the KMS key used for Aurora PostgreSQL encryption"
  value       = module.security.kms_key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for Aurora PostgreSQL encryption"
  value       = module.security.kms_key_arn
}

output "monitoring_role_arn" {
  description = "The ARN of the IAM role used for enhanced monitoring"
  value       = module.security.monitoring_role_arn
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret for DB credentials"
  value       = module.security.secret_arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for Aurora notifications"
  value       = module.security.sns_topic_arn
}

output "cluster_id" {
  description = "The ID of the Aurora cluster"
  value       = module.aurora.cluster_id
}

output "cluster_arn" {
  description = "The ARN of the Aurora cluster"
  value       = module.aurora.cluster_arn
}

output "cluster_endpoint" {
  description = "The writer endpoint of the Aurora cluster"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "The reader endpoint of the Aurora cluster"
  value       = module.aurora.cluster_reader_endpoint
}

output "custom_reader_endpoint" {
  description = "The custom reader endpoint of the Aurora cluster"
  value       = module.aurora.custom_reader_endpoint
}

output "cluster_port" {
  description = "The port of the Aurora cluster"
  value       = module.aurora.cluster_port
}

output "cluster_master_username" {
  description = "The master username for the database"
  value       = module.aurora.cluster_master_username
  sensitive   = true
}

output "cluster_parameter_group_id" {
  description = "The cluster parameter group ID"
  value       = module.aurora.cluster_parameter_group_id
}

output "instance_parameter_group_id" {
  description = "The instance parameter group ID"
  value       = module.aurora.instance_parameter_group_id
}

output "jdbc_connection_string" {
  description = "JDBC connection string for the Aurora cluster"
  value       = module.aurora.jdbc_connection_string
}

output "iam_database_authentication_enabled" {
  description = "Whether IAM database authentication is enabled"
  value       = var.iam_database_authentication_enabled
}

output "db_access_role_arn" {
  description = "The ARN of the IAM role for DB access via IAM authentication"
  value       = var.iam_database_authentication_enabled ? module.iam_auth[0].db_access_role_arn : null
}
