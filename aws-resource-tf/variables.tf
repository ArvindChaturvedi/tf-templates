###########################################################################
# AWS Aurora PostgreSQL Terraform Module - Input Variables
###########################################################################

# Basic Configuration
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name, used for prefixing resources"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project, used for tagging and resource name prefixes"
  type        = string
}

variable "owner" {
  description = "Owner of the resources, used for tagging"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

###########################################################################
# Component Creation Flags - Control which modules get created
###########################################################################

variable "create_networking" {
  description = "DEPRECATED: VPC creation is no longer supported. Please provide existing VPC and subnet IDs."
  type        = bool
  default     = false
}

variable "create_aurora_db" {
  description = "Whether to create the Aurora PostgreSQL database cluster"
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Whether to create a new KMS key for encryption"
  type        = bool
  default     = true
}

variable "create_enhanced_monitoring_role" {
  description = "Whether to create an IAM role for enhanced monitoring"
  type        = bool
  default     = true
}

variable "create_db_credentials_secret" {
  description = "Whether to create a Secrets Manager secret for database credentials"
  type        = bool
  default     = true
}

variable "generate_master_password" {
  description = "Whether to generate a random master password"
  type        = bool
  default     = true
}

variable "create_sns_topic" {
  description = "Whether to create SNS topics for notifications"
  type        = bool
  default     = true
}

variable "create_db_event_subscription" {
  description = "Whether to create RDS event subscriptions"
  type        = bool
  default     = true
}

variable "create_db_access_role" {
  description = "Whether to create IAM roles for database access"
  type        = bool
  default     = true
}

variable "create_eks_integration" {
  description = "Whether to create EKS integration components"
  type        = bool
  default     = false
}

variable "create_eks_secrets_access" {
  description = "Whether to create Kubernetes Secret access for Secrets Manager"
  type        = bool
  default     = false
}

variable "create_eks_irsa_access" {
  description = "Whether to create IAM Roles for Service Accounts"
  type        = bool
  default     = false
}

variable "create_eks_k8s_resources" {
  description = "Whether to create Kubernetes resources (requires kubectl provider)"
  type        = bool
  default     = false
}

variable "create_eks_service_account" {
  description = "Whether to create Kubernetes Service Account"
  type        = bool
  default     = false
}

variable "create_acm_certificates" {
  description = "Whether to create ACM certificates"
  type        = bool
  default     = false
}

variable "create_public_certificate" {
  description = "Whether to create a public ACM certificate"
  type        = bool
  default     = false
}

variable "create_private_certificate" {
  description = "Whether to create a private ACM certificate"
  type        = bool
  default     = false
}

variable "create_waf_configuration" {
  description = "Whether to create WAF configuration"
  type        = bool
  default     = false
}

variable "create_pgbouncer" {
  description = "Whether to create PGBouncer connection pooling"
  type        = bool
  default     = false
}

variable "create_lambda_functions" {
  description = "Whether to create Lambda functions"
  type        = bool
  default     = false
}
###########################################################################
# Network Configuration - Required existing resources
###########################################################################

variable "existing_vpc_id" {
  description = "ID of the existing VPC to use (required, VPC creation is not supported)"
  type        = string
}

variable "existing_private_subnet_ids" {
  description = "IDs of existing private subnets to use (required, subnet creation is not supported)"
  type        = list(string)
}

variable "existing_public_subnet_ids" {
  description = "IDs of existing public subnets to use (required, subnet creation is not supported)"
  type        = list(string)
}

variable "existing_db_security_group_ids" {
  description = "IDs of existing security groups to use for the database (optional)"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
###########################################################################
# Security Configuration
###########################################################################

variable "existing_kms_key_arn" {
  description = "ARN of an existing KMS key to use (if not creating a new key)"
  type        = string
  default     = ""
}

variable "existing_monitoring_role_arn" {
  description = "ARN of an existing IAM role for enhanced monitoring (if not creating a new role)"
  type        = string
  default     = ""
}

variable "existing_db_credentials_secret_arn" {
  description = "ARN of an existing Secrets Manager secret for database credentials (if not creating a new secret)"
  type        = string
  default     = ""
}

variable "existing_db_credentials_secret_name" {
  description = "Name of an existing Secrets Manager secret for database credentials (if not creating a new secret)"
  type        = string
  default     = ""
}

variable "existing_sns_topic_arns" {
  description = "ARNs of existing SNS topics for notifications (if not creating new topics)"
  type        = list(string)
  default     = []
}

###########################################################################
# Aurora DB Configuration
###########################################################################

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "dbadmin"
}

variable "master_password" {
  description = "Password for the master DB user (if not generating a random one)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_db_endpoint" {
  description = "Endpoint of an existing database (if not creating Aurora)"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "Port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "db_instance_count" {
  description = "Number of DB instances to create in the cluster"
  type        = number
  default     = 2
}

variable "db_instance_class" {
  description = "Instance type to use for the DB instances"
  type        = string
  default     = "db.r5.large"
}

variable "db_engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "14.6"
}

variable "db_parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = "aurora-postgresql14"
}

variable "db_cluster_parameters" {
  description = "List of DB cluster parameters to apply"
  type        = list(map(string))
  default     = []
}

variable "db_instance_parameters" {
  description = "List of DB instance parameters to apply"
  type        = list(map(string))
  default     = []
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range during which backups are created"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which maintenance can occur"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "auto_minor_version_upgrade" {
  description = "Whether to automatically upgrade minor engine versions"
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Whether to encrypt the database storage"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "The retention period for Performance Insights, in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately or during the next maintenance window"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when the cluster is deleted"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier_prefix" {
  description = "Prefix for the name of the final snapshot"
  type        = string
  default     = "final"
}

###########################################################################
# EKS Integration Configuration
###########################################################################

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to integrate with"
  type        = string
  default     = ""
}

variable "eks_namespace" {
  description = "Kubernetes namespace to create resources in"
  type        = string
  default     = "default"
}

variable "eks_node_role_id" {
  description = "Role ID of the EKS node IAM role"
  type        = string
  default     = ""
}

variable "eks_service_account_name" {
  description = "Name of the Kubernetes service account to create"
  type        = string
  default     = "db-access"
}

###########################################################################
# ACM Certificate Configuration
###########################################################################

variable "domain_name" {
  description = "Domain name for the ACM certificate"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the ACM certificate"
  type        = list(string)
  default     = []
}

variable "auto_validate_certificate" {
  description = "Whether to automatically validate the certificate with Route 53"
  type        = bool
  default     = true
}

variable "route53_zone_name" {
  description = "Route 53 zone name to use for certificate validation"
  type        = string
  default     = ""
}

###########################################################################
# WAF Configuration
###########################################################################

variable "waf_scope" {
  description = "Scope of WAF (REGIONAL or CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"
}

variable "enable_waf_managed_rules" {
  description = "Whether to enable AWS managed rule sets"
  type        = bool
  default     = true
}

variable "enable_sql_injection_protection" {
  description = "Whether to enable SQL injection protection"
  type        = bool
  default     = true
}

variable "enable_rate_limiting" {
  description = "Whether to enable rate limiting"
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "Maximum number of requests allowed in a 5-minute period"
  type        = number
  default     = 2000
}

###########################################################################
# PGBouncer Configuration
###########################################################################

variable "pgbouncer_instance_type" {
  description = "EC2 instance type for PGBouncer"
  type        = string
  default     = "t3.micro"
}

variable "pgbouncer_ami_id" {
  description = "AMI ID for PGBouncer instances (defaults to latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "pgbouncer_min_capacity" {
  description = "Minimum capacity for PGBouncer Auto Scaling Group"
  type        = number
  default     = 1
}

variable "pgbouncer_max_capacity" {
  description = "Maximum capacity for PGBouncer Auto Scaling Group"
  type        = number
  default     = 3
}

variable "pgbouncer_desired_capacity" {
  description = "Desired capacity for PGBouncer Auto Scaling Group"
  type        = number
  default     = 2
}

variable "pgbouncer_port" {
  description = "Port on which PGBouncer listens for connections"
  type        = number
  default     = 6432
}

variable "pgbouncer_max_client_conn" {
  description = "Maximum number of client connections allowed by PGBouncer"
  type        = number
  default     = 1000
}

variable "pgbouncer_default_pool_size" {
  description = "Default pool size used by PGBouncer"
  type        = number
  default     = 20
}

variable "pgbouncer_create_lb" {
  description = "Whether to create a load balancer for PGBouncer"
  type        = bool
  default     = true
}

###########################################################################
# Lambda Functions Configuration
###########################################################################

variable "lambda_functions" {
  description = "Map of Lambda functions to create"
  type        = map(object({
    description          = string
    handler              = string
    runtime              = string
    memory_size          = number
    timeout              = number
    s3_bucket            = optional(string)
    s3_key               = optional(string)
    source_code_path     = optional(string)
    environment_variables = optional(map(string), {})
    db_access_enabled     = optional(bool, false)
    vpc_config_enabled    = optional(bool, false)
    schedule_expression   = optional(string, "")
  }))
  default     = {}
}
