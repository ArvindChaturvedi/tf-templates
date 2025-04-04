# AWS Provider Configuration
# This file defines the provider configuration for the Aurora PostgreSQL infrastructure

provider "aws" {
  region = var.aws_region

  # Use these lines to authenticate with AWS credentials if not using IAM roles
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key

  # Default tags to be applied to all resources
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Optional AWS provider for different region (if needed)
# provider "aws" {
#   alias      = "secondary_region"
#   region     = var.secondary_aws_region
#   
#   # Use these lines to authenticate with AWS credentials if not using IAM roles
#   # access_key = var.aws_access_key
#   # secret_key = var.aws_secret_key
#
#   # Default tags to be applied to all resources
#   default_tags {
#     tags = {
#       Environment = var.environment
#       Project     = var.project_name
#       ManagedBy   = "Terraform"
#     }
#   }
# }

# Required Terraform version and providers
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}