output "vpc_id" {
  description = "The ID of the VPC"
  value       = local.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = local.is_dummy_vpc ? "10.0.0.0/16" : data.aws_vpc.selected[0].cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = local.private_subnet_ids
}

output "db_security_group_ids" {
  description = "List of IDs of database security groups"
  value       = local.db_security_group_ids
}
