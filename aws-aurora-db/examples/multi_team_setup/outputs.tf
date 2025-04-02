output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.shared_networking.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.shared_networking.private_subnets
}

output "shared_kms_key_id" {
  description = "The ID of the shared KMS key"
  value       = module.shared_security.kms_key_id
}

output "shared_monitoring_role_arn" {
  description = "The ARN of the shared monitoring role"
  value       = module.shared_security.monitoring_role_arn
}

# Team 1 Outputs
output "team1_db_security_group_id" {
  description = "The ID of Team 1's DB security group"
  value       = module.team1_db_security.db_security_group_id
}

output "team1_secret_arn" {
  description = "The ARN of Team 1's DB credentials secret"
  value       = module.team1_security.secret_arn
}

output "team1_sns_topic_arn" {
  description = "The ARN of Team 1's SNS topic"
  value       = module.team1_security.sns_topic_arn
}

output "team1_cluster_id" {
  description = "The ID of Team 1's Aurora cluster"
  value       = module.team1_aurora.cluster_id
}

output "team1_cluster_endpoint" {
  description = "The writer endpoint of Team 1's Aurora cluster"
  value       = module.team1_aurora.cluster_endpoint
}

output "team1_cluster_reader_endpoint" {
  description = "The reader endpoint of Team 1's Aurora cluster"
  value       = module.team1_aurora.cluster_reader_endpoint
}

output "team1_jdbc_connection_string" {
  description = "JDBC connection string for Team 1's Aurora cluster"
  value       = module.team1_aurora.jdbc_connection_string
}

# Team 2 Outputs
output "team2_db_security_group_id" {
  description = "The ID of Team 2's DB security group"
  value       = module.team2_db_security.db_security_group_id
}

output "team2_secret_arn" {
  description = "The ARN of Team 2's DB credentials secret"
  value       = module.team2_security.secret_arn
}

output "team2_sns_topic_arn" {
  description = "The ARN of Team 2's SNS topic"
  value       = module.team2_security.sns_topic_arn
}

output "team2_cluster_id" {
  description = "The ID of Team 2's Aurora cluster"
  value       = module.team2_aurora.cluster_id
}

output "team2_cluster_endpoint" {
  description = "The writer endpoint of Team 2's Aurora cluster"
  value       = module.team2_aurora.cluster_endpoint
}

output "team2_cluster_reader_endpoint" {
  description = "The reader endpoint of Team 2's Aurora cluster"
  value       = module.team2_aurora.cluster_reader_endpoint
}

output "team2_jdbc_connection_string" {
  description = "JDBC connection string for Team 2's Aurora cluster"
  value       = module.team2_aurora.jdbc_connection_string
}
