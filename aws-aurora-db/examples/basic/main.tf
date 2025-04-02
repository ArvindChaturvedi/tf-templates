provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC and subnets for the Aurora PostgreSQL cluster
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

# Create security resources for the Aurora PostgreSQL cluster
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
  
  tags = var.tags
  
  # These parameters will be updated after Aurora cluster creation
  # db_cluster_endpoint = module.aurora.cluster_endpoint
  # db_cluster_id       = module.aurora.cluster_id
  # db_cluster_resource_id = module.aurora.resource_id
}

# Create the Aurora PostgreSQL cluster
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
  
  storage_encrypted = true
  kms_key_id        = module.security.kms_key_arn
  
  backup_retention_period = var.backup_retention_period
  
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = module.security.monitoring_role_arn
  
  performance_insights_enabled = var.performance_insights_enabled
  
  create_cloudwatch_alarms    = var.create_cloudwatch_alarms
  
  tags = var.tags
}

# Update security module with Aurora cluster details
resource "null_resource" "update_security_module" {
  depends_on = [module.aurora]

  provisioner "local-exec" {
    command = "echo 'Aurora cluster created with ID: ${module.aurora.cluster_id}'"
  }
}

# Below is a workaround since we can't use depends_on in module configuration
# In a real scenario, you might need to use a separate configuration or create custom modules

module "sns_notifications" {
  source = "../../modules/security"

  name = "${var.environment}-${var.name}-notifications"
  
  # Only create SNS resources
  create_kms_key              = false
  create_monitoring_role      = false
  create_db_credentials_secret = false
  
  # SNS Topic for Notifications
  create_sns_topic            = true
  create_db_event_subscription = true
  db_cluster_id               = module.aurora.cluster_id
  
  tags = var.tags
}

# IAM Authentication setup (if enabled)
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
