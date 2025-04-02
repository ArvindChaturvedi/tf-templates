# Outputs for Aurora PostgreSQL Infrastructure

# Network Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnets
}

output "db_security_group_id" {
  description = "The ID of the security group for the Aurora DB"
  value       = module.networking.db_security_group_id
}

output "app_security_group_id" {
  description = "The ID of the security group for applications"
  value       = module.networking.app_security_group_id
}

# Aurora Shared Cluster Outputs (if created)
output "shared_cluster_endpoint" {
  description = "The cluster endpoint for the shared Aurora PostgreSQL"
  value       = var.create_shared_aurora ? module.aurora_shared[0].cluster_endpoint : null
}

output "shared_cluster_reader_endpoint" {
  description = "The reader endpoint for the shared Aurora PostgreSQL"
  value       = var.create_shared_aurora ? module.aurora_shared[0].cluster_reader_endpoint : null
}

output "shared_cluster_id" {
  description = "The ID of the shared Aurora PostgreSQL cluster"
  value       = var.create_shared_aurora ? module.aurora_shared[0].cluster_id : null
}

# Application-specific Aurora Clusters
output "app_cluster_endpoints" {
  description = "Map of application team name to cluster endpoint"
  value = {
    for team, aurora in module.aurora_app : team => aurora.cluster_endpoint
  }
}

output "app_cluster_reader_endpoints" {
  description = "Map of application team name to reader endpoint"
  value = {
    for team, aurora in module.aurora_app : team => aurora.cluster_reader_endpoint
  }
}

output "app_cluster_ids" {
  description = "Map of application team name to cluster ID"
  value = {
    for team, aurora in module.aurora_app : team => aurora.cluster_id
  }
}

# Security Outputs
output "monitoring_role_arn" {
  description = "The ARN of the enhanced monitoring IAM role"
  value       = var.create_enhanced_monitoring_role ? module.security.monitoring_role_arn : var.existing_monitoring_role_arn
}