output "environment" {
  description = "The environment in which resources are deployed"
  value       = var.environment
}

output "project_name" {
  description = "The name of the project"
  value       = var.project_name
}

output "resource_prefix" {
  description = "The prefix used for resource naming"
  value       = "${var.project_name}-${var.environment}"
}

output "owner" {
  description = "The owner of the resources"
  value       = var.owner
}

output "vpc_id" {
  description = "The ID of the VPC used"
  value       = data.aws_vpc.example.id
}

output "kms_key_id" {
  description = "The ID of the KMS key"
  value       = aws_kms_key.example.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.example.arn
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.example.id
}
