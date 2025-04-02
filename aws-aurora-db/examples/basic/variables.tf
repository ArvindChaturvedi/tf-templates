variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name of the Aurora PostgreSQL cluster"
  type        = string
  default     = "postgres-basic"
}

variable "application_name" {
  description = "Name of the application using the database"
  type        = string
  default     = "example-app"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the Aurora DB"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "database_name" {
  description = "Name of the default database to create"
  type        = string
  default     = "postgres"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "postgres"
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "instance_count" {
  description = "Number of DB instances to create in the cluster"
  type        = number
  default     = 2
}

variable "instance_class" {
  description = "Instance class to use for the DB instances"
  type        = string
  default     = "db.t3.medium"
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
  default     = 7
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

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM database authentication is enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Owner       = "DevOps"
    Environment = "dev"
    Terraform   = "true"
  }
}
