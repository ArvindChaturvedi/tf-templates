# AWS Networking Module for Aurora PostgreSQL
# This module works with existing VPC and subnets resources

locals {
  # Check if a VPC ID is provided
  vpc_id = var.vpc_id

  # Database security groups to use
  db_security_group_ids = length(var.existing_security_group_ids) > 0 ? var.existing_security_group_ids : [aws_security_group.database[0].id]

  # Process provided subnet IDs
  private_subnet_ids = var.private_subnet_ids
  
  # Check if we're using dummy values (for planning only)
  is_dummy_vpc = can(regex("^vpc-[0-9a-f]{8}$", var.vpc_id))
  is_dummy_subnet = length(var.private_subnet_ids) > 0 ? can(regex("^subnet-[0-9a-f]{8}$", var.private_subnet_ids[0])) : false
}

# Data source to fetch the existing VPC details
data "aws_vpc" "selected" {
  count = local.is_dummy_vpc ? 0 : 1
  id    = local.vpc_id
}

# Data source to fetch subnet information
data "aws_subnet" "private" {
  count = local.is_dummy_subnet ? 0 : length(local.private_subnet_ids)
  id    = local.private_subnet_ids[count.index]
}

# Security Group for Database access
resource "aws_security_group" "database" {
  count = length(var.existing_security_group_ids) == 0 ? 1 : 0

  name        = "${var.name}-database-sg"
  description = "Security group for ${var.name} database"
  vpc_id      = local.vpc_id

  # DB port ingress from allowed CIDRs
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-database-sg"
    }
  )
}
