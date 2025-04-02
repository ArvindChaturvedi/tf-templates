variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name of the Aurora PostgreSQL cluster"
  type        = string
  default     = "postgres-custom"
}

variable "application_name" {
  description = "Name of the application using the database"
  type        = string
  default     = "custom-app"
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
  default     = "db.r5.large"
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "13.7"
}

variable "db_parameter_group_family" {
  description = "Family of the DB parameter group"
  type        = string
  default     = "aurora-postgresql13"
}

variable "cluster_parameters" {
  description = "A list of cluster parameters to apply"
  type        = list(map(string))
  default = [
    {
      name  = "rds.force_ssl"
      value = "1"
    },
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements,auto_explain"
    },
    {
      name  = "log_statement"
      value = "ddl"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]
}

variable "instance_parameters" {
  description = "A list of instance parameters to apply"
  type        = list(map(string))
  default = [
    {
      name  = "log_statement"
      value = "ddl"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    },
    {
      name  = "auto_explain.log_min_duration"
      value = "5000"
    },
    {
      name  = "auto_explain.log_analyze"
      value = "1"
    }
  ]
}

variable "backup_retention_period" {
  description = "The number of days to retain backups for"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which system maintenance can occur"
  type        = string
  default     = "sun:04:00-sun:05:00"
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

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7
}

variable "cpu_utilization_threshold" {
  description = "The value against which the CPU utilization metric is compared"
  type        = number
  default     = 70
}

variable "freeable_memory_threshold" {
  description = "The value against which the freeable memory metric is compared (in bytes)"
  type        = number
  default     = 128000000 # 128MB
}

variable "disk_queue_depth_threshold" {
  description = "The value against which the disk queue depth metric is compared"
  type        = number
  default     = 10
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM database authentication is enabled"
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql", "upgrade"]
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = true
}

variable "create_custom_endpoints" {
  description = "Create custom endpoints for the Aurora cluster"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately"
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
