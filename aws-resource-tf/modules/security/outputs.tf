output "kms_key_id" {
  description = "The ID of the KMS key used for Aurora PostgreSQL encryption"
  value       = var.create_kms_key ? aws_kms_key.aurora[0].id : null
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for Aurora PostgreSQL encryption"
  value       = var.create_kms_key ? aws_kms_key.aurora[0].arn : null
}

output "kms_key_alias_arn" {
  description = "The ARN of the KMS key alias"
  value       = var.create_kms_key ? aws_kms_alias.aurora[0].arn : null
}

output "kms_key_alias_name" {
  description = "The name of the KMS key alias"
  value       = var.create_kms_key ? aws_kms_alias.aurora[0].name : null
}

output "monitoring_role_arn" {
  description = "The ARN of the IAM role used for enhanced monitoring"
  value       = var.create_monitoring_role ? aws_iam_role.enhanced_monitoring[0].arn : null
}

output "monitoring_role_name" {
  description = "The name of the IAM role used for enhanced monitoring"
  value       = var.create_monitoring_role ? aws_iam_role.enhanced_monitoring[0].name : null
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret for DB credentials"
  value       = var.create_db_credentials_secret ? aws_secretsmanager_secret.aurora_master[0].arn : null
}

output "secret_name" {
  description = "The name of the Secrets Manager secret for DB credentials"
  value       = var.create_db_credentials_secret ? aws_secretsmanager_secret.aurora_master[0].name : null
}

output "master_password" {
  description = "The master password for the database (if generated)"
  value       = var.create_db_credentials_secret && var.generate_master_password ? random_password.master_password[0].result : var.master_password
  sensitive   = true
}

output "secret_access_policy_arn" {
  description = "The ARN of the IAM policy for accessing the DB credentials secret"
  value       = var.create_db_credentials_secret && var.create_secret_access_policy ? aws_iam_policy.secret_access[0].arn : null
}

output "db_access_role_arn" {
  description = "The ARN of the IAM role for DB access via IAM authentication"
  value       = var.create_db_access_role ? aws_iam_role.db_access[0].arn : null
}

output "db_access_role_name" {
  description = "The name of the IAM role for DB access via IAM authentication"
  value       = var.create_db_access_role ? aws_iam_role.db_access[0].name : null
}

output "db_access_policy_arn" {
  description = "The ARN of the IAM policy for DB access via IAM authentication"
  value       = var.create_db_access_role ? aws_iam_policy.db_access[0].arn : null
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for Aurora notifications"
  value       = var.create_sns_topic ? aws_sns_topic.aurora_notifications[0].arn : null
}

output "sns_topic_name" {
  description = "The name of the SNS topic for Aurora notifications"
  value       = var.create_sns_topic ? aws_sns_topic.aurora_notifications[0].name : null
}

output "event_subscription_arn" {
  description = "The ARN of the RDS event subscription"
  value       = var.create_sns_topic && var.create_db_event_subscription ? aws_db_event_subscription.aurora[0].arn : null
}

output "event_subscription_id" {
  description = "The ID of the RDS event subscription"
  value       = var.create_sns_topic && var.create_db_event_subscription ? aws_db_event_subscription.aurora[0].id : null
}
