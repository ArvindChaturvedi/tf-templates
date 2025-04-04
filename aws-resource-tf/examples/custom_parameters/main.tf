provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create networking resources
module "networking" {
  source = "../../modules/networking"

  name               = "${var.environment}-${var.name}"
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  
  public_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + var.az_count)]
  
  db_port             = var.db_port
  allowed_cidr_blocks = var.allowed_cidr_blocks
  
  tags = var.tags
}

# Create security resources
module "security" {
  source = "../../modules/security"

  name = "${var.environment}-${var.name}"
  
  # KMS Key Configuration
  create_kms_key = true
  
  # Enhanced Monitoring Role
  create_monitoring_role = true
  
  # Secret Manager Configuration
  create_db_credentials_secret = true
  generate_master_password     = true
  master_username              = var.master_username
  database_name                = var.database_name
  
  # SNS Topic for Notifications
  create_sns_topic = true
  
  tags = var.tags
}

# Create the Aurora PostgreSQL cluster with custom parameters
module "aurora" {
  source = "../../modules/aurora_postgresql"

  name             = "${var.environment}-${var.name}"
  application_name = var.application_name
  environment      = var.environment
  
  subnet_ids         = module.networking.private_subnets
  security_group_ids = [module.networking.db_security_group_id]
  
  database_name        = var.database_name
  master_username      = var.master_username
  master_password      = module.security.master_password
  port                 = var.db_port
  
  instance_count = var.instance_count
  instance_class = var.instance_class
  
  # Engine specific configuration
  engine_version           = var.engine_version
  db_parameter_group_family = var.db_parameter_group_family
  
  # Custom cluster parameters
  cluster_parameters = var.cluster_parameters
  
  # Custom instance parameters
  instance_parameters = var.instance_parameters
  
  # Storage configuration
  storage_encrypted = true
  kms_key_id        = module.security.kms_key_arn
  
  # Backup configuration
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  
  # Monitoring configuration
  monitoring_interval      = var.monitoring_interval
  monitoring_role_arn      = module.security.monitoring_role_arn
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  
  # CloudWatch alarms
  create_cloudwatch_alarms    = true
  cloudwatch_alarm_actions    = [module.security.sns_topic_arn]
  cpu_utilization_threshold   = var.cpu_utilization_threshold
  freeable_memory_threshold   = var.freeable_memory_threshold
  disk_queue_depth_threshold  = var.disk_queue_depth_threshold
  
  # Additional features
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports    = var.enabled_cloudwatch_logs_exports
  auto_minor_version_upgrade         = var.auto_minor_version_upgrade
  allow_major_version_upgrade        = var.allow_major_version_upgrade
  deletion_protection                = var.deletion_protection
  
  # Advanced settings
  create_custom_endpoints = var.create_custom_endpoints
  apply_immediately       = var.apply_immediately
  
  tags = var.tags
}

# Update security module with Aurora cluster details for event subscription
module "db_event_subscription" {
  source = "../../modules/security"

  name = "${var.environment}-${var.name}-events"
  
  # Only create DB event subscription
  create_kms_key              = false
  create_monitoring_role      = false
  create_db_credentials_secret = false
  create_sns_topic            = false
  
  create_db_event_subscription = true
  db_cluster_id                = module.aurora.cluster_id
  
  tags = var.tags
}

# Create IAM role for DB access via IAM authentication if enabled
module "iam_auth" {
  source = "../../modules/security"
  count  = var.iam_database_authentication_enabled ? 1 : 0

  name = "${var.environment}-${var.name}-iam-auth"
  
  # Only create IAM auth resources
  create_kms_key              = false
  create_monitoring_role      = false
  create_db_credentials_secret = false
  create_sns_topic            = false
  
  # IAM Authentication Configuration
  create_db_access_role    = true
  master_username          = var.master_username
  db_cluster_resource_id   = module.aurora.cluster_id
  
  tags = var.tags
}
