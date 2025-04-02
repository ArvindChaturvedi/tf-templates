output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = var.create_vpc ? aws_vpc.this[0].cidr_block : null
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = var.create_subnets ? aws_subnet.public[*].id : var.existing_public_subnet_ids
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = var.create_subnets ? aws_subnet.public[*].cidr_block : null
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = var.create_subnets ? aws_subnet.private[*].id : var.existing_private_subnet_ids
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = var.create_subnets ? aws_subnet.private[*].cidr_block : null
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = var.create_vpc ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "db_security_group_id" {
  description = "The ID of the security group for the Aurora DB"
  value       = var.create_security_group ? aws_security_group.db[0].id : null
}

output "db_security_group_arn" {
  description = "The ARN of the security group for the Aurora DB"
  value       = var.create_security_group ? aws_security_group.db[0].arn : null
}

output "app_security_group_id" {
  description = "The ID of the security group for applications to access the Aurora DB"
  value       = var.create_security_group && var.create_app_security_group ? aws_security_group.app[0].id : null
}

output "app_security_group_arn" {
  description = "The ARN of the security group for applications to access the Aurora DB"
  value       = var.create_security_group && var.create_app_security_group ? aws_security_group.app[0].arn : null
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}
