variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-team-aurora"
}

# Existing VPC and Subnet Variables
variable "existing_vpc_id" {
  description = "ID of the existing VPC to use"
  type        = string
  
  validation {
    condition     = can(regex("^vpc-", var.existing_vpc_id))
    error_message = "The VPC ID must start with 'vpc-'."
  }
}

variable "existing_private_subnet_ids" {
  description = "List of existing private subnet IDs to use"
  type        = list(string)
  
  validation {
    condition     = length(var.existing_private_subnet_ids) >= 2
    error_message = "At least 2 private subnet IDs are required for Aurora deployment."
  }
}

variable "existing_public_subnet_ids" {
  description = "List of existing public subnet IDs to use"
  type        = list(string)
  
  validation {
    condition     = length(var.existing_public_subnet_ids) >= 2
    error_message = "At least 2 public subnet IDs are required."
  }
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = true
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for the Aurora cluster"
  type        = bool
  default     = true
}

# Team 1 Variables
variable "team1_application_name" {
  description = "Name of Team 1's application"
  type        = string
  default     = "team1-app"
}

variable "team1_allowed_cidrs" {
  description = "List of additional CIDR blocks allowed to access Team 1's database"
  type        = list(string)
  default     = []
}

variable "team1_database_name" {
  description = "Name of Team 1's database"
  type        = string
  default     = "team1db"
}

variable "team1_master_username" {
  description = "Username for Team 1's database master user"
  type        = string
  default     = "team1admin"
}

variable "team1_instance_count" {
  description = "Number of DB instances to create in Team 1's cluster"
  type        = number
  default     = 2
}

variable "team1_instance_class" {
  description = "Instance class to use for Team 1's DB instances"
  type        = string
  default     = "db.t3.medium"
}

variable "team1_backup_retention_period" {
  description = "The number of days to retain backups for Team 1's database"
  type        = number
  default     = 7
}

# Team 2 Variables
variable "team2_application_name" {
  description = "Name of Team 2's application"
  type        = string
  default     = "team2-app"
}

variable "team2_allowed_cidrs" {
  description = "List of additional CIDR blocks allowed to access Team 2's database"
  type        = list(string)
  default     = []
}

variable "team2_database_name" {
  description = "Name of Team 2's database"
  type        = string
  default     = "team2db"
}

variable "team2_master_username" {
  description = "Username for Team 2's database master user"
  type        = string
  default     = "team2admin"
}

variable "team2_instance_count" {
  description = "Number of DB instances to create in Team 2's cluster"
  type        = number
  default     = 2
}

variable "team2_instance_class" {
  description = "Instance class to use for Team 2's DB instances"
  type        = string
  default     = "db.t3.medium"
}

variable "team2_backup_retention_period" {
  description = "The number of days to retain backups for Team 2's database"
  type        = number
  default     = 7
}
