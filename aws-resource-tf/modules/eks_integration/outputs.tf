output "security_group_id" {
  description = "ID of the security group for EKS to Aurora connectivity"
  value       = aws_security_group.eks_to_aurora.id
}

output "irsa_policy_arn" {
  description = "ARN of the IAM policy for IRSA to access Aurora DB credentials"
  value       = var.create_irsa_secrets_access_policy ? aws_iam_policy.irsa_secrets_manager_access[0].arn : ""
}

output "config_map_name" {
  description = "Name of the Kubernetes ConfigMap with Aurora DB configuration"
  value       = var.create_k8s_resources ? kubernetes_config_map.aurora_config[0].metadata[0].name : ""
}

output "service_account_name" {
  description = "Name of the Kubernetes ServiceAccount with IRSA for DB access"
  value       = var.create_k8s_resources && var.create_service_account ? kubernetes_service_account.db_access[0].metadata[0].name : ""
}