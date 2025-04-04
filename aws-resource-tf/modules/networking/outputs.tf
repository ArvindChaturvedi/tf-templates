output "vpc_id" {
  description = "The ID of the VPC"
  value       = local.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = data.aws_vpc.selected.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = local.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = local.private_subnet_ids
}

output "db_security_group_ids" {
  description = "List of IDs of database security groups"
  value       = local.db_security_group_ids
}
