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
# Aurora DB Configuration - Default values for all teams
###########################################################################

variable "db_port" {
  description = "Port for the database"
  type        = number
  default     = 5432
}

variable "db_engine_version" {
  description = "Version of the PostgreSQL engine"
  type        = string
  default     = "14.6"
}

variable "db_parameter_group_family" {
  description = "Family of the DB parameter group"
  type        = string
  default     = "aurora-postgresql14"
}

variable "db_cluster_parameters" {
  description = "Map of cluster parameters to apply"
  type        = map(string)
  default     = {}
}

variable "db_instance_parameters" {
  description = "Map of instance parameters to apply"
  type        = map(string)
  default     = {}
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred window for automated backups"
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred window for maintenance"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "auto_minor_version_upgrade" {
  description = "Whether to enable auto minor version upgrades"
  type        = bool
  default     = true
}

variable "storage_encrypted" {
  description = "Whether to encrypt storage"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Interval in seconds for enhanced monitoring"
  type        = number
  default     = 60
}

variable "performance_insights_enabled" {
  description = "Whether to enable performance insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Retention period for performance insights in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting the cluster"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier_prefix" {
  description = "Prefix for the final snapshot identifier"
  type        = string
  default     = "final"
}

###########################################################################
# EKS Integration Configuration
###########################################################################

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "eks_namespace" {
  description = "Kubernetes namespace to create resources in"
  type        = string
  default     = "default"
}

variable "eks_node_role_id" {
  description = "ID of the EKS node role"
  type        = string
  default     = ""
}

variable "eks_service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = "db-access"
}

###########################################################################
# ACM Certificate Configuration
###########################################################################

variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the certificate"
  type        = list(string)
  default     = []
}

variable "auto_validate_certificate" {
  description = "Whether to automatically validate the certificate"
  type        = bool
  default     = true
}

variable "route53_zone_name" {
  description = "Name of the Route53 zone for DNS validation"
  type        = string
  default     = ""
}

###########################################################################
# WAF Configuration
###########################################################################

variable "waf_scope" {
  description = "Scope of the WAF configuration"
  type        = string
  default     = "REGIONAL"
}

variable "enable_waf_managed_rules" {
  description = "Whether to enable WAF managed rules"
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
  description = "Rate limit for WAF"
  type        = number
  default     = 2000
}

###########################################################################
# PGBouncer Configuration
###########################################################################

variable "pgbouncer_instance_type" {
  description = "Instance type for PGBouncer"
  type        = string
  default     = "t3.micro"
}

variable "pgbouncer_ami_id" {
  description = "AMI ID for PGBouncer"
  type        = string
  default     = ""
}

variable "pgbouncer_min_capacity" {
  description = "Minimum capacity for PGBouncer ASG"
  type        = number
  default     = 1
}

variable "pgbouncer_max_capacity" {
  description = "Maximum capacity for PGBouncer ASG"
  type        = number
  default     = 3
}

variable "pgbouncer_desired_capacity" {
  description = "Desired capacity for PGBouncer ASG"
  type        = number
  default     = 2
}

variable "pgbouncer_port" {
  description = "Port for PGBouncer"
  type        = number
  default     = 6432
}

variable "pgbouncer_max_client_conn" {
  description = "Maximum client connections for PGBouncer"
  type        = number
  default     = 1000
}

variable "pgbouncer_default_pool_size" {
  description = "Default pool size for PGBouncer"
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
  type = map(object({
    description            = string
    handler                = string
    runtime                = string
    memory_size            = number
    timeout                = number
    s3_bucket              = string
    s3_key                 = string
    environment_variables   = map(string)
    db_access_enabled      = bool
    vpc_config_enabled     = bool
    schedule_expression    = string
  }))
  default = {}
}

###########################################################################
# Team-Specific Configuration
###########################################################################

variable "teams" {
  description = "Map of team configurations"
  type = map(object({
    application_name    = string
    database_name      = string
    master_username    = string
    instance_count     = number
    instance_class     = string
    allowed_cidrs      = list(string)
    backup_retention_period = optional(number, 7)
    performance_insights_enabled = optional(bool, true)
    performance_insights_retention_period = optional(number, 7)
    monitoring_interval = optional(number, 60)
    db_cluster_parameters = optional(map(string), {})
    db_instance_parameters = optional(map(string), {})
    create_cloudwatch_alarms = optional(bool, true)
    create_sns_topic = optional(bool, true)
    create_db_credentials_secret = optional(bool, true)
    generate_master_password = optional(bool, true)
    create_db_event_subscription = optional(bool, true)
    create_db_access_role = optional(bool, true)
    create_eks_integration = optional(bool, false)
    create_eks_secrets_access = optional(bool, false)
    create_eks_irsa_access = optional(bool, false)
    create_eks_k8s_resources = optional(bool, false)
    create_eks_service_account = optional(bool, false)
    eks_cluster_name = optional(string, "")
    eks_namespace = optional(string, "default")
    eks_service_account_name = optional(string, "db-access")
    create_pgbouncer = optional(bool, false)
    pgbouncer_instance_type = optional(string, "t3.micro")
    pgbouncer_min_capacity = optional(number, 1)
    pgbouncer_max_capacity = optional(number, 3)
    pgbouncer_desired_capacity = optional(number, 2)
    pgbouncer_port = optional(number, 6432)
    pgbouncer_max_client_conn = optional(number, 1000)
    pgbouncer_default_pool_size = optional(number, 20)
    pgbouncer_create_lb = optional(bool, true)
    create_lambda_functions = optional(bool, false)
    lambda_functions = optional(map(object({
      description            = string
      handler                = string
      runtime                = string
      memory_size            = number
      timeout                = number
      s3_bucket              = string
      s3_key                 = string
      environment_variables   = map(string)
      db_access_enabled      = bool
      vpc_config_enabled     = bool
      schedule_expression    = string
    })), {})
  }))
  default = {}
}
