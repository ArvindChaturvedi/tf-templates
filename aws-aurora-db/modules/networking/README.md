# AWS Networking Module for Aurora PostgreSQL

This module creates the necessary network infrastructure for deploying AWS Aurora PostgreSQL clusters, including VPC, subnets, internet gateways, NAT gateways, route tables, and security groups.

## Features

- VPC with public and private subnets
- Internet Gateway for public internet access
- NAT Gateway for private subnet internet access
- Route tables for traffic management
- Security groups for controlling access to the Aurora database
- Flexible configuration options

## Usage

```hcl
module "networking" {
  source = "../modules/networking"

  name = "example-postgres-network"
  
  # VPC Configuration
  vpc_cidr = "10.0.0.0/16"
  
  # Subnet Configuration
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  # Security Group Configuration
  db_port             = 5432
  allowed_cidr_blocks = ["10.0.0.0/8"]
  
  tags = {
    Owner       = "Team1"
    Project     = "Example"
    Environment = "dev"
  }
}
