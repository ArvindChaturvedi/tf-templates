provider "aws" {
  region = var.region
}

locals {
  # Common tags for all resources
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
    Project     = var.project_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create a shared VPC and subnets for multiple application teams
module "shared_networking" {
  source = "../../modules/networking"

  name               = "${var.environment}-shared-network"
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  
  public_subnet_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + var.az_count)]
  
  # Do not create DB security groups here, they will be created per team
  create_security_group = false
  
  tags = merge(local.common_tags, {
    Name = "${var.environment}-shared-network"
  })
}

# Create shared security resources (KMS, monitoring role)
module "shared_security" {
  source = "../../modules/security"

  name = "${var.environment}-shared-security"
  
  # KMS Key Configuration
  create_kms_key = true
  
  # Enhanced Monitoring Role
  create_monitoring_role = true
  
  # Don't create secrets or other resources here, they will be created per team
  create_db_credentials_secret = false
  
  tags = merge(local.common_tags, {
    Name = "${var.environment}-shared-security"
  })
}

# Create Security Group for Team 1's database
module "team1_db_security" {
  source = "../../modules/networking"

  name   = "${var.environment}-team1-db-security"
  
  # Use the shared VPC
  create_vpc = false
  vpc_id     = module.shared_networking.vpc_id
  
  # Only create security groups
  create_security_group = true
  db_port               = var.db_port
  allowed_cidr_blocks   = concat([var.vpc_cidr], var.team1_allowed_cidrs)
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team1-db-security"
    Team  = "team1"
  })
}

# Create Security Group for Team 2's database
module "team2_db_security" {
  source = "../../modules/networking"

  name   = "${var.environment}-team2-db-security"
  
  # Use the shared VPC
  create_vpc = false
  vpc_id     = module.shared_networking.vpc_id
  
  # Only create security groups
  create_security_group = true
  db_port               = var.db_port
  allowed_cidr_blocks   = concat([var.vpc_cidr], var.team2_allowed_cidrs)
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team2-db-security"
    Team  = "team2"
  })
}

# Create security resources specific to Team 1
module "team1_security" {
  source = "../../modules/security"

  name = "${var.environment}-team1-security"
  
  # Don't create KMS key or monitoring role, use shared ones
  create_kms_key         = false
  create_monitoring_role = false
  
  # Create secrets for Team 1's database credentials
  create_db_credentials_secret = true
  generate_master_password     = true
  master_username              = var.team1_master_username
  database_name                = var.team1_database_name
  
  # Create SNS topic for Team 1's database notifications
  create_sns_topic = true
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team1-security"
    Team  = "team1"
  })
}

# Create security resources specific to Team 2
module "team2_security" {
  source = "../../modules/security"

  name = "${var.environment}-team2-security"
  
  # Don't create KMS key or monitoring role, use shared ones
  create_kms_key         = false
  create_monitoring_role = false
  
  # Create secrets for Team 2's database credentials
  create_db_credentials_secret = true
  generate_master_password     = true
  master_username              = var.team2_master_username
  database_name                = var.team2_database_name
  
  # Create SNS topic for Team 2's database notifications
  create_sns_topic = true
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team2-security"
    Team  = "team2"
  })
}

# Create Team 1's Aurora PostgreSQL cluster
module "team1_aurora" {
  source = "../../modules/aurora_postgresql"

  name             = "${var.environment}-team1-postgres"
  application_name = var.team1_application_name
  environment      = var.environment
  
  subnet_ids         = module.shared_networking.private_subnets
  security_group_ids = [module.team1_db_security.db_security_group_id]
  
  database_name        = var.team1_database_name
  master_username      = var.team1_master_username
  master_password      = module.team1_security.master_password
  port                 = var.db_port
  
  instance_count = var.team1_instance_count
  instance_class = var.team1_instance_class
  
  storage_encrypted = true
  kms_key_id        = module.shared_security.kms_key_arn
  
  backup_retention_period = var.team1_backup_retention_period
  
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = module.shared_security.monitoring_role_arn
  
  performance_insights_enabled = var.performance_insights_enabled
  
  create_cloudwatch_alarms = var.create_cloudwatch_alarms
  cloudwatch_alarm_actions = [module.team1_security.sns_topic_arn]
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team1-postgres"
    Team  = "team1"
  })
}

# Create Team 2's Aurora PostgreSQL cluster
module "team2_aurora" {
  source = "../../modules/aurora_postgresql"

  name             = "${var.environment}-team2-postgres"
  application_name = var.team2_application_name
  environment      = var.environment
  
  subnet_ids         = module.shared_networking.private_subnets
  security_group_ids = [module.team2_db_security.db_security_group_id]
  
  database_name        = var.team2_database_name
  master_username      = var.team2_master_username
  master_password      = module.team2_security.master_password
  port                 = var.db_port
  
  instance_count = var.team2_instance_count
  instance_class = var.team2_instance_class
  
  storage_encrypted = true
  kms_key_id        = module.shared_security.kms_key_arn
  
  backup_retention_period = var.team2_backup_retention_period
  
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = module.shared_security.monitoring_role_arn
  
  performance_insights_enabled = var.performance_insights_enabled
  
  create_cloudwatch_alarms = var.create_cloudwatch_alarms
  cloudwatch_alarm_actions = [module.team2_security.sns_topic_arn]
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team2-postgres"
    Team  = "team2"
  })
}

# Update security modules with Aurora cluster details for event subscriptions
module "team1_event_subscription" {
  source = "../../modules/security"

  name = "${var.environment}-team1-events"
  
  # Only create DB event subscription
  create_kms_key              = false
  create_monitoring_role      = false
  create_db_credentials_secret = false
  create_sns_topic            = false
  
  create_db_event_subscription = true
  db_cluster_id                = module.team1_aurora.cluster_id
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team1-events"
    Team  = "team1"
  })
}

module "team2_event_subscription" {
  source = "../../modules/security"

  name = "${var.environment}-team2-events"
  
  # Only create DB event subscription
  create_kms_key              = false
  create_monitoring_role      = false
  create_db_credentials_secret = false
  create_sns_topic            = false
  
  create_db_event_subscription = true
  db_cluster_id                = module.team2_aurora.cluster_id
  
  tags = merge(local.common_tags, {
    Name  = "${var.environment}-team2-events"
    Team  = "team2"
  })
}
