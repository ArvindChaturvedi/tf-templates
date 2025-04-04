variable "name" {
  description = "Name prefix for Aurora PostgreSQL resources"
  type        = string
}

variable "application_name" {
  description = "Name of the application that will use this database"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones for the Aurora cluster"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "A list of subnet IDs to use for the Aurora cluster"
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the Aurora cluster"
  type        = list(string)
}

variable "database_name" {
  description = "Name of the default database to create"
  type        = string
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Password for the master DB user. If not provided, a random password will be generated"
  type        = string
  default     = ""
  sensitive   = true
}

variable "port" {
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
  default     = []
}

variable "instance_parameters" {
  description = "A list of instance parameters to apply"
  type        = list(map(string))
  default     = []
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

variable "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If not specified, the default encryption key is used"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Bool to control if instances are publicly accessible"
  type        = bool
  default     = false
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether or not the mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql"]
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  type        = number
  default     = 0 # 0 means monitoring is disabled
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed"
  type        = bool
  default     = false
}

variable "create_custom_endpoints" {
  description = "Create custom endpoints for the Aurora cluster"
  type        = bool
  default     = false
}

variable "backtrack_window" {
  description = "The target backtrack window, in seconds. Valid values are between 0 and 259200 (72 hours)"
  type        = number
  default     = 0 # 0 means backtrack is disabled
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for the Aurora cluster"
  type        = bool
  default     = false
}

variable "cloudwatch_alarm_actions" {
  description = "List of ARNs of actions to take when the CloudWatch alarms enter the ALARM state"
  type        = list(string)
  default     = []
}

variable "cloudwatch_ok_actions" {
  description = "List of ARNs of actions to take when the CloudWatch alarms enter the OK state"
  type        = list(string)
  default     = []
}

variable "cpu_utilization_threshold" {
  description = "The value against which the CPU utilization metric is compared"
  type        = number
  default     = 80
}

variable "freeable_memory_threshold" {
  description = "The value against which the freeable memory metric is compared (in bytes)"
  type        = number
  default     = 64000000 # 64MB
}

variable "disk_queue_depth_threshold" {
  description = "The value against which the disk queue depth metric is compared"
  type        = number
  default     = 20
}

variable "serverless_min_capacity" {
  description = "The minimum capacity for an Aurora PostgreSQL Serverless v2 DB cluster in Aurora capacity units (ACU)"
  type        = number
  default     = 0.5
}

variable "serverless_max_capacity" {
  description = "The maximum capacity for an Aurora PostgreSQL Serverless v2 DB cluster in Aurora capacity units (ACU)"
  type        = number
  default     = 1.0
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
