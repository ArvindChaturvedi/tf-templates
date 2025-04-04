# AWS Security Module for Aurora PostgreSQL

This module creates security-related resources for AWS Aurora PostgreSQL clusters, including KMS keys for encryption, IAM roles for monitoring, Secrets Manager secrets for database credentials, and SNS topics for notifications.

## Features

- KMS Key for Aurora PostgreSQL encryption with customizable policy
- IAM Role for Enhanced Monitoring
- Secrets Manager Secret for master database credentials
- IAM Role and Policy for database access via IAM authentication
- SNS Topic for Aurora PostgreSQL notifications
- RDS Event Subscription for important database events

## Usage

```hcl
module "security" {
  source = "../modules/security"

  name = "example-postgres-security"
  
  # KMS Key Configuration
  create_kms_key        = true
  kms_key_deletion_window = 30
  kms_key_enable_rotation = true
  
  # Set specific permissions for the KMS key
  kms_key_admin_arns = ["arn:aws:iam::123456789012:role/admin-role"]
  kms_key_user_arns  = ["arn:aws:iam::123456789012:role/app-role"]
  
  # Enhanced Monitoring Role
  create_monitoring_role = true
  
  # Secret Manager Configuration
  create_db_credentials_secret = true
  generate_master_password     = true
  master_username              = "dbadmin"
  database_name                = "exampledb"
  db_cluster_endpoint          = module.aurora.cluster_endpoint
  db_port                      = 5432
  
  # IAM Authentication Configuration
  create_db_access_role     = true
  db_cluster_resource_id    = module.aurora.resource_id
  
  # SNS Topic for Notifications
  create_sns_topic            = true
  create_db_event_subscription = true
  db_cluster_id               = module.aurora.cluster_id
  
  tags = {
    Owner       = "Team1"
    Project     = "Example"
    Environment = "dev"
  }
}
