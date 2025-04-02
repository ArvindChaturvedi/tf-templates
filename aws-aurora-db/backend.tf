# Backend Configuration for Terraform State
# This file defines where and how Terraform stores state

terraform {
  # S3 backend configuration for storing terraform state
  backend "s3" {
    bucket         = "terraform-aurora-postgres-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"  # Change to your preferred region
    encrypt        = true
    dynamodb_table = "terraform-state-lock"  # For state locking (prevents concurrent modifications)
  }

  # Uncomment this section if you prefer to use other backends
  # For example: Terraform Cloud backend
  # 
  # backend "remote" {
  #   organization = "your-organization"
  #
  #   workspaces {
  #     name = "aurora-postgresql"
  #   }
  # }
  
  # Local backend (not recommended for production)
  # backend "local" {
  #   path = "terraform.tfstate"
  # }
}