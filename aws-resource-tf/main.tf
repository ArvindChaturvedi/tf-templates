###########################################################################
# AWS Aurora PostgreSQL Terraform Module - Main Configuration
###########################################################################

provider "aws" {
  region = var.aws_region
}

# Local variables for naming and tagging consistency
locals {
  # Standard naming prefix based on environment and project
  name_prefix = "${var.environment}-${var.project_name}"
  
  # Common tags to be applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
  
  # Merge common tags with any additional custom tags
  tags = merge(local.common_tags, var.additional_tags)
}

###########################################################################
# Networking Setup - Using Only Existing Resources
###########################################################################

module "networking" {
  source = "./modules/networking"

  name               = "${local.name_prefix}-network"
  vpc_id             = var.existing_vpc_id
  public_subnet_ids  = var.existing_public_subnet_ids
  private_subnet_ids = var.existing_private_subnet_ids
  
  db_port             = var.db_port
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  tags = local.tags
}

###########################################################################
# Security Module - Always created with conditional components
###########################################################################

module "security" {
  source = "./modules/security"

  name = "${local.name_prefix}-security"
  
  # KMS Key Configuration
  create_kms_key = var.create_kms_key
  existing_kms_key_arn = var.existing_kms_key_arn
  
  # Enhanced Monitoring Role
  create_monitoring_role = var.create_enhanced_monitoring_role
  existing_monitoring_role_arn = var.existing_monitoring_role_arn
  
  # Secret Manager Configuration
  create_db_credentials_secret = var.create_db_credentials_secret
  generate_master_password = var.generate_master_password
  existing_db_credentials_secret_arn = var.existing_db_credentials_secret_arn
  existing_db_credentials_secret_name = var.existing_db_credentials_secret_name
  
  master_username = var.master_username
  master_password = var.master_password
  database_name = var.database_name
  
  # SNS Topics for Alerting
  create_sns_topic = var.create_sns_topic
  existing_sns_topic_arns = var.existing_sns_topic_arns
  
  # IAM Role for Database Access
  create_db_access_role = var.create_db_access_role
  
  tags = local.tags
}

###########################################################################
# Aurora PostgreSQL Database Module - Created if explicitly enabled
###########################################################################

module "aurora_db" {
  count  = var.create_aurora_db ? 1 : 0
  source = "./modules/aurora_postgresql"
  
  name           = "${local.name_prefix}-aurora"
  environment    = var.environment
  application_name = var.project_name
  
  # Network Configuration
  subnet_ids = module.networking.private_subnet_ids
  vpc_id     = module.networking.vpc_id
  vpc_security_group_ids = module.networking.db_security_group_ids
  
  # Database Configuration
  database_name     = var.database_name
  master_username   = var.master_username
  master_password   = var.master_password
  port              = var.db_port
  instance_count    = var.db_instance_count
  instance_class    = var.db_instance_class
  engine_version    = var.db_engine_version
  availability_zones = var.availability_zones
  
  db_parameter_group_family = var.db_parameter_group_family
  cluster_parameters = var.db_cluster_parameters
  instance_parameters = var.db_instance_parameters
  
  # Performance & Backup Settings
  backup_retention_period       = var.backup_retention_period
  preferred_backup_window       = var.preferred_backup_window
  preferred_maintenance_window  = var.preferred_maintenance_window
  auto_minor_version_upgrade    = var.auto_minor_version_upgrade
  
  storage_encrypted             = var.storage_encrypted
  kms_key_id                    = var.create_kms_key ? module.security.kms_key_arn : var.existing_kms_key_arn
  
  monitoring_interval           = var.monitoring_interval
  monitoring_role_arn           = var.create_enhanced_monitoring_role ? module.security.monitoring_role_arn : var.existing_monitoring_role_arn
  
  performance_insights_enabled  = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  
  deletion_protection   = var.deletion_protection
  apply_immediately     = var.apply_immediately
  skip_final_snapshot   = var.skip_final_snapshot
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix
  
  # Event Subscription
  create_db_event_subscription = var.create_db_event_subscription
  sns_topic_arn = var.create_sns_topic ? module.security.sns_topic_arn : (length(var.existing_sns_topic_arns) > 0 ? var.existing_sns_topic_arns[0] : "")
  
  db_credentials_secret_arn = var.create_db_credentials_secret ? module.security.db_credentials_secret_arn : var.existing_db_credentials_secret_arn
  
  tags = local.tags
}

###########################################################################
# EKS Integration Module - Only created if explicitly enabled
###########################################################################

module "eks_integration" {
  count  = var.create_eks_integration ? 1 : 0
  source = "./modules/eks_integration"
  
  name = "${local.name_prefix}-eks"
  
  # Aurora DB Information
  db_endpoint     = var.create_aurora_db ? module.aurora_db[0].cluster_endpoint : var.existing_db_endpoint
  db_port         = var.db_port
  database_name   = var.database_name
  master_username = var.master_username
  
  # Secret Access Configuration
  create_secrets_access = var.create_eks_secrets_access
  db_credentials_secret_arn = var.create_db_credentials_secret ? module.security.db_credentials_secret_arn : var.existing_db_credentials_secret_arn
  
  # IRSA Configuration  
  create_irsa_access = var.create_eks_irsa_access
  eks_node_role_id  = var.eks_node_role_id
  
  # K8s Resource Configuration
  create_k8s_resources = var.create_eks_k8s_resources
  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.eks_namespace
  
  # Service Account
  create_service_account = var.create_eks_service_account
  service_account_name   = var.eks_service_account_name
  
  tags = local.tags
}

###########################################################################
# ACM Certificates Module - Only created if explicitly enabled
###########################################################################

module "acm_certificates" {
  count  = var.create_acm_certificates ? 1 : 0
  source = "./modules/acm_certificates"
  
  name = "${local.name_prefix}-acm"
  
  create_public_certificate  = var.create_public_certificate
  create_private_certificate = var.create_private_certificate
  
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  auto_validate_certificate = var.auto_validate_certificate
  route53_zone_name         = var.route53_zone_name
  
  tags = local.tags
}

###########################################################################
# WAF Configuration Module - Only created if explicitly enabled
###########################################################################

module "waf_configuration" {
  count  = var.create_waf_configuration ? 1 : 0
  source = "./modules/waf_configuration"
  
  name = "${local.name_prefix}-waf"
  
  scope                        = var.waf_scope
  enable_managed_rules         = var.enable_waf_managed_rules
  enable_sql_injection_protection = var.enable_sql_injection_protection
  enable_rate_limiting         = var.enable_rate_limiting
  rate_limit                   = var.waf_rate_limit
  
  # Associate with load balancers if created
  associate_with_pgbouncer_lb = var.create_pgbouncer && var.pgbouncer_create_lb
  pgbouncer_lb_arn = var.create_pgbouncer && var.pgbouncer_create_lb ? module.pgbouncer[0].load_balancer_arn : ""
  
  tags = local.tags
}

###########################################################################
# PGBouncer Module - Only created if explicitly enabled
###########################################################################

module "pgbouncer" {
  count  = var.create_pgbouncer ? 1 : 0
  source = "./modules/pgbouncer"
  
  name = "${local.name_prefix}-pgbouncer"
  
  # Network Configuration
  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.public_subnet_ids
  availability_zones  = var.availability_zones
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  # DB Connection Information
  db_host       = var.create_aurora_db ? module.aurora_db[0].cluster_endpoint : var.existing_db_endpoint
  db_port       = var.db_port
  db_name       = var.database_name
  db_user       = var.master_username
  db_password   = var.create_db_credentials_secret ? module.security.master_password : var.master_password
  
  # EC2 Instance Configuration
  instance_type      = var.pgbouncer_instance_type
  ami_id             = var.pgbouncer_ami_id
  min_capacity       = var.pgbouncer_min_capacity
  max_capacity       = var.pgbouncer_max_capacity
  desired_capacity   = var.pgbouncer_desired_capacity
  
  # PGBouncer Configuration
  pgbouncer_port            = var.pgbouncer_port
  pgbouncer_max_client_conn = var.pgbouncer_max_client_conn
  pgbouncer_default_pool_size = var.pgbouncer_default_pool_size
  
  # Load Balancer Configuration
  create_lb = var.pgbouncer_create_lb
  
  # Security Configuration 
  use_https = var.create_acm_certificates && var.create_public_certificate
  certificate_arn = var.create_acm_certificates && var.create_public_certificate ? module.acm_certificates[0].public_certificate_arn : ""
  
  tags = local.tags
}

###########################################################################
# Lambda Functions Module - Only created if explicitly enabled
###########################################################################

module "lambda_functions" {
  count  = var.create_lambda_functions ? 1 : 0
  source = "./modules/lambda_functions"
  
  name = "${local.name_prefix}-lambda"
  
  # VPC Configuration for Lambda functions that need VPC access
  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.private_subnet_ids
  security_group_ids  = module.networking.db_security_group_ids
  
  # DB Configuration for Lambda functions that need DB access
  db_host       = var.create_aurora_db ? module.aurora_db[0].cluster_endpoint : var.existing_db_endpoint
  db_port       = var.db_port
  db_name       = var.database_name
  db_secret_arn = var.create_db_credentials_secret ? module.security.db_credentials_secret_arn : var.existing_db_credentials_secret_arn
  
  # Lambda Functions Configuration
  lambda_functions = var.lambda_functions
  
  tags = local.tags
}
