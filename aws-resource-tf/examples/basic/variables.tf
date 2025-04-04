variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "The environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "The owner of the resources"
  type        = string
  default     = "terraform-user"
}

variable "existing_vpc_id" {
  description = "ID of the existing VPC to use (required)"
  type        = string
  
  validation {
    condition     = can(regex("^vpc-", var.existing_vpc_id))
    error_message = "The VPC ID must start with 'vpc-'."
  }
}

variable "existing_subnet_ids" {
  description = "List of existing subnet IDs to use (minimum 2 required)"
  type        = list(string)
  
  validation {
    condition     = length(var.existing_subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for Aurora deployment."
  }
}
