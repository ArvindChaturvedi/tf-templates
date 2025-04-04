terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  # For local development only - would use actual credentials in production
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock-access-key"
  secret_key                  = "mock-secret-key"
}

locals {
  name           = "${var.project_name}-${var.environment}"
  owner          = var.owner
  environment    = var.environment
  
  tags = {
    Owner       = local.owner
    Environment = local.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

# This is a simple example that would create a KMS key for encryption
resource "aws_kms_key" "example" {
  description             = "KMS key for ${local.name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = local.tags
}

resource "aws_kms_alias" "example" {
  name          = "alias/${local.name}"
  target_key_id = aws_kms_key.example.key_id
}

# This example requires an existing VPC
# Users must provide their own VPC ID
data "aws_vpc" "example" {
  id = var.existing_vpc_id
}

# Use the provided subnet IDs directly
# This replaces the old approach of looking up subnets by tags
locals {
  subnet_ids = var.existing_subnet_ids
}

# Create a security group in the existing VPC
resource "aws_security_group" "example" {
  name        = "${local.name}-sg"
  description = "Example security group for ${local.name}"
  
  # Using the existing VPC ID
  vpc_id      = data.aws_vpc.example.id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.example.cidr_block]
    description = "PostgreSQL access from within VPC"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = local.tags
}
