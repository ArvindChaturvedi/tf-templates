# Variables for Aurora PostgreSQL Infrastructure
# This file defines input variables for the Terraform configuration

# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, test, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aurora-postgres"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "infrastructure-team"
}

# Network Configuration
variable "existing_vpc_id" {
  description = "ID of an existing VPC to use (leave empty to create a new VPC)"
  type        = string
  default     = ""
}

variable "existing_private_subnet_ids" {
  description = "List of existing private subnet IDs to use (leave empty to create new subnets)"
  type        = list(string)
  default     = []
}

variable "existing_public_subnet_ids" {
  description = "List of existing public subnet IDs to use (leave empty to create new subnets)"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (only used if creating a new VPC)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones in the region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Database Configuration
variable "db_instance_class" {
  description = "Instance class for the Aurora DB instances"
  type        = string
  default     = "db.r5.large"
}

variable "db_engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "14.6"
}

variable "db_parameters" {
  description = "Map of additional database parameters to apply"
  type        = map(string)
  default     = {}
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for the database"
  type        = bool
  default     = true
}

variable "create_enhanced_monitoring_role" {
  description = "Whether to create an IAM role for enhanced monitoring"
  type        = bool
  default     = true
}

variable "existing_monitoring_role_arn" {
  description = "ARN of an existing enhanced monitoring role (if not creating one)"
  type        = string
  default     = ""
}

# Application Teams Configuration
variable "application_teams" {
  description = "List of application teams that will use the database"
  type = list(object({
    name        = string
    application = string
    cost_center = string
    db_name     = string
    # Additional team-specific settings
    instance_count = optional(number, 2)
    instance_class = optional(string, "")
    parameters     = optional(map(string), {})
  }))
  default = []
}