###########################################################################
# AWS Aurora PostgreSQL Terraform Module - Outputs
###########################################################################

# Networking Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.create_networking ? module.networking[0].vpc_id : var.existing_vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = var.create_networking ? module.networking[0].private_subnets : var.existing_private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = var.create_networking ? module.networking[0].public_subnets : var.existing_public_subnet_ids
}

output "db_security_group_id" {
  description = "Security group ID for the database"
  value       = var.create_networking ? module.networking[0].db_security_group_id : (
    length(var.existing_db_security_group_ids) > 0 ? var.existing_db_security_group_ids[0] : null
  )
}

# Security Outputs
output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = var.create_kms_key ? module.security.kms_key_id : null
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = var.create_kms_key ? module.security.kms_key_arn : var.existing_kms_key_arn
}

output "monitoring_role_arn" {
  description = "The ARN of the enhanced monitoring IAM role"
  value       = var.create_enhanced_monitoring_role ? module.security.monitoring_role_arn : var.existing_monitoring_role_arn
}

output "db_credentials_secret_arn" {
  description = "The ARN of the database credentials secret"
  value       = var.create_db_credentials_secret ? module.security.db_credentials_secret_arn : var.existing_db_credentials_secret_arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = var.create_sns_topic ? module.security.sns_topic_arn : (
    length(var.existing_sns_topic_arns) > 0 ? var.existing_sns_topic_arns[0] : null
  )
}

output "db_access_role_arn" {
  description = "The ARN of the IAM role for database access"
  value       = var.create_db_access_role && var.create_aurora_db && var.iam_database_authentication_enabled ? module.security.db_access_role_arn : var.eks_db_access_role_arn
}

# Aurora DB Outputs
output "db_cluster_id" {
  description = "The ID of the Aurora DB cluster"
  value       = var.create_aurora_db ? module.aurora[0].cluster_id : null
}

output "db_cluster_arn" {
  description = "The ARN of the Aurora DB cluster"
  value       = var.create_aurora_db ? module.aurora[0].cluster_arn : null
}

output "db_cluster_endpoint" {
  description = "The endpoint of the Aurora DB cluster"
  value       = var.create_aurora_db ? module.aurora[0].cluster_endpoint : var.existing_db_endpoint
}

output "db_cluster_reader_endpoint" {
  description = "The reader endpoint of the Aurora DB cluster"
  value       = var.create_aurora_db ? module.aurora[0].cluster_reader_endpoint : null
}

output "db_cluster_port" {
  description = "The port of the Aurora DB cluster"
  value       = var.create_aurora_db ? module.aurora[0].cluster_port : var.db_port
}

output "db_instance_ids" {
  description = "List of Aurora DB instance IDs"
  value       = var.create_aurora_db ? module.aurora[0].cluster_instances : null
}

# EKS Integration Outputs
output "eks_role_arn" {
  description = "The ARN of the IAM role for EKS pods to access the database"
  value       = var.create_eks_integration && (var.create_aurora_db || var.existing_db_endpoint != "") ? module.eks_integration[0].eks_role_arn : null
}

output "eks_service_account_name" {
  description = "The name of the Kubernetes service account for database access"
  value       = var.create_eks_integration && var.create_eks_service_account && (var.create_aurora_db || var.existing_db_endpoint != "") ? module.eks_integration[0].service_account_name : null
}

# ACM Certificate Outputs
output "acm_certificate_arn" {
  description = "The ARN of the public ACM certificate"
  value       = var.create_acm_certificates && var.create_public_certificate ? module.acm_certificates[0].public_certificate_arn : null
}

output "acm_private_certificate_arn" {
  description = "The ARN of the private ACM certificate"
  value       = var.create_acm_certificates && var.create_private_certificate ? module.acm_certificates[0].private_certificate_arn : null
}

# WAF Outputs
output "waf_web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = var.create_waf_configuration ? module.waf[0].web_acl_id : null
}

output "waf_web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = var.create_waf_configuration ? module.waf[0].web_acl_arn : null
}

# PGBouncer Outputs
output "pgbouncer_load_balancer_dns" {
  description = "The DNS name of the PGBouncer load balancer"
  value       = var.create_pgbouncer && var.pgbouncer_create_lb && (var.create_aurora_db || var.existing_db_endpoint != "") ? module.pgbouncer[0].load_balancer_dns_name : null
}

output "pgbouncer_security_group_id" {
  description = "The ID of the PGBouncer security group"
  value       = var.create_pgbouncer && (var.create_aurora_db || var.existing_db_endpoint != "") ? module.pgbouncer[0].security_group_id : null
}

output "pgbouncer_asg_name" {
  description = "The name of the PGBouncer Auto Scaling Group"
  value       = var.create_pgbouncer && (var.create_aurora_db || var.existing_db_endpoint != "") ? module.pgbouncer[0].auto_scaling_group_id : null
}

# Lambda Functions Outputs
output "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  value       = var.create_lambda_functions && length(keys(var.lambda_functions)) > 0 ? module.lambda_functions[0].function_arns : null
}

output "lambda_function_names" {
  description = "Map of Lambda function names"
  value       = var.create_lambda_functions && length(keys(var.lambda_functions)) > 0 ? module.lambda_functions[0].function_names : null
}