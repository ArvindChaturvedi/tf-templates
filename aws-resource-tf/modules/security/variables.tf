variable "name" {
  description = "Name prefix for security resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# KMS Key variables
variable "create_kms_key" {
  description = "Whether to create a KMS key for Aurora PostgreSQL encryption"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window" {
  description = "The waiting period, in days, before the KMS key is deleted"
  type        = number
  default     = 30
}

variable "kms_key_enable_rotation" {
  description = "Whether to enable automatic rotation of the KMS key"
  type        = bool
  default     = true
}

variable "kms_key_policy" {
  description = "A custom KMS key policy. If not provided, a default policy will be created"
  type        = string
  default     = ""
}

variable "kms_key_admin_arns" {
  description = "A list of IAM ARNs that can administer the KMS key"
  type        = list(string)
  default     = []
}

variable "kms_key_user_arns" {
  description = "A list of IAM ARNs that can use the KMS key"
  type        = list(string)
  default     = []
}

# Enhanced Monitoring variables
variable "create_monitoring_role" {
  description = "Whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

# Secret Manager variables
variable "create_db_credentials_secret" {
  description = "Whether to create a Secrets Manager secret for the DB credentials"
  type        = bool
  default     = true
}

variable "secret_recovery_window_in_days" {
  description = "Number of days that Secrets Manager waits before deleting a secret"
  type        = number
  default     = 30
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "postgres"
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
  default     = ""
  sensitive   = true
}

variable "generate_master_password" {
  description = "Whether to generate a random password for the master DB user"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "postgres"
}

variable "db_cluster_endpoint" {
  description = "The DNS address of the Aurora cluster"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "create_secret_access_policy" {
  description = "Whether to create an IAM policy for accessing the DB credentials secret"
  type        = bool
  default     = true
}

# IAM Authentication variables
variable "create_db_access_role" {
  description = "Whether to create an IAM role for DB access via IAM authentication"
  type        = bool
  default     = false
}

variable "db_cluster_resource_id" {
  description = "The resource ID of the Aurora DB cluster"
  type        = string
  default     = ""
}

# SNS Topic variables
variable "create_sns_topic" {
  description = "Whether to create an SNS topic for Aurora notifications"
  type        = bool
  default     = false
}

variable "create_db_event_subscription" {
  description = "Whether to create a DB event subscription"
  type        = bool
  default     = false
}

variable "db_cluster_id" {
  description = "The identifier of the Aurora DB cluster"
  type        = string
  default     = ""
}
