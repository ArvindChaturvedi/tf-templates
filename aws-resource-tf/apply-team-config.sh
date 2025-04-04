#!/bin/bash
# Script to apply team-specific configurations

set -e

# Display usage information
function show_usage {
  echo "Usage: $0 <team-name> [environment] [apply]"
  echo "  team-name: Name of the team (e.g., team-a, team-b)"
  echo "  environment: Environment to deploy to (default: dev)"
  echo "  apply: Whether to apply changes (default: false)"
  echo ""
  echo "Example: $0 team-a dev true"
  exit 1
}

# Check if team name is provided
if [ $# -lt 1 ]; then
  show_usage
fi

TEAM_NAME=$1
ENVIRONMENT=${2:-dev}
APPLY=${3:-false}

# Create team directory if it doesn't exist
if [ ! -d "teams/$TEAM_NAME" ]; then
  echo "Creating team directory 'teams/$TEAM_NAME'..."
  mkdir -p "teams/$TEAM_NAME"
fi

# Create environment directory if it doesn't exist
if [ ! -d "teams/$TEAM_NAME/$ENVIRONMENT" ]; then
  echo "Creating environment directory 'teams/$TEAM_NAME/$ENVIRONMENT'..."
  mkdir -p "teams/$TEAM_NAME/$ENVIRONMENT"
fi

# Check if team tfvars file exists, if not create a default one
if [ ! -f "teams/$TEAM_NAME/$ENVIRONMENT/terraform.tfvars.json" ]; then
  echo "Creating default tfvars.json file for $TEAM_NAME in $ENVIRONMENT environment..."
  cat > "teams/$TEAM_NAME/$ENVIRONMENT/terraform.tfvars.json" << EOF
{
  "aws_region": "us-east-1",
  "environment": "$ENVIRONMENT",
  "project_name": "$TEAM_NAME",
  "owner": "devops-team",
  "existing_vpc_id": "vpc-0123456789abcdef0",
  "existing_private_subnet_ids": [
    "subnet-0123456789abcdef1",
    "subnet-0123456789abcdef2",
    "subnet-0123456789abcdef3"
  ],
  "existing_public_subnet_ids": [
    "subnet-0123456789abcdef4",
    "subnet-0123456789abcdef5",
    "subnet-0123456789abcdef6"
  ],
  "existing_db_security_group_ids": [
    "sg-0123456789abcdef7"
  ],
  "availability_zones": [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ],
  "allowed_cidr_blocks": [
    "10.0.0.0/16"
  ],
  "create_aurora_db": true,
  "create_kms_key": true,
  "create_enhanced_monitoring_role": true,
  "create_db_credentials_secret": true,
  "generate_master_password": true,
  "create_sns_topic": true,
  "create_db_event_subscription": true,
  "create_db_access_role": true,
  "db_port": 5432,
  "db_engine_version": "14.6",
  "db_parameter_group_family": "aurora-postgresql14",
  "backup_retention_period": 7,
  "preferred_backup_window": "02:00-03:00",
  "preferred_maintenance_window": "sun:05:00-sun:06:00",
  "auto_minor_version_upgrade": true,
  "storage_encrypted": true,
  "monitoring_interval": 60,
  "performance_insights_enabled": true,
  "performance_insights_retention_period": 7,
  "deletion_protection": true,
  "apply_immediately": false,
  "skip_final_snapshot": false,
  "final_snapshot_identifier_prefix": "final",
  "create_eks_integration": false,
  "create_eks_secrets_access": false,
  "create_eks_irsa_access": false,
  "eks_node_role_id": "",
  "create_eks_k8s_resources": false,
  "eks_cluster_name": "",
  "eks_namespace": "default",
  "create_eks_service_account": false,
  "eks_service_account_name": "db-access",
  "create_acm_certificates": false,
  "create_public_certificate": false,
  "create_private_certificate": false,
  "domain_name": "",
  "subject_alternative_names": [],
  "auto_validate_certificate": true,
  "route53_zone_name": "",
  "create_waf_configuration": false,
  "waf_scope": "REGIONAL",
  "enable_waf_managed_rules": true,
  "enable_sql_injection_protection": true,
  "enable_rate_limiting": true,
  "waf_rate_limit": 2000,
  "create_pgbouncer": false,
  "pgbouncer_instance_type": "t3.micro",
  "pgbouncer_min_capacity": 1,
  "pgbouncer_max_capacity": 3,
  "pgbouncer_desired_capacity": 2,
  "pgbouncer_port": 6432,
  "pgbouncer_max_client_conn": 1000,
  "pgbouncer_default_pool_size": 20,
  "pgbouncer_create_lb": true,
  "create_lambda_functions": false,
  "lambda_functions": {
    "db-backup": {
      "description": "Lambda function for database backup",
      "handler": "index.handler",
      "runtime": "nodejs16.x",
      "memory_size": 512,
      "timeout": 300,
      "s3_bucket": "lambda-packages",
      "s3_key": "db-backup/db-backup.zip",
      "environment_variables": {
        "DB_NAME": "appdb",
        "BACKUP_BUCKET": "db-backups"
      },
      "db_access_enabled": true,
      "vpc_config_enabled": true,
      "schedule_expression": "cron(0 2 * * ? *)"
    }
  }
}
EOF
  echo "Default tfvars.json file created for $TEAM_NAME in $ENVIRONMENT environment."
fi

# Also create a .tfvars file in the same directory
if [ ! -f "teams/$TEAM_NAME/$ENVIRONMENT/terraform.tfvars" ]; then
  echo "Creating default tfvars file for $TEAM_NAME in $ENVIRONMENT environment..."
  cat > "teams/$TEAM_NAME/$ENVIRONMENT/terraform.tfvars" << EOF
aws_region = "us-east-1"
environment = "$ENVIRONMENT"
project_name = "$TEAM_NAME"
owner = "devops-team"
existing_vpc_id = "vpc-0123456789abcdef0"
existing_private_subnet_ids = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
existing_public_subnet_ids = ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"]
existing_db_security_group_ids = ["sg-0123456789abcdef7"]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
allowed_cidr_blocks = ["10.0.0.0/16"]
create_aurora_db = true
create_kms_key = true
create_enhanced_monitoring_role = true
create_db_credentials_secret = true
generate_master_password = true
create_sns_topic = true
create_db_event_subscription = true
create_db_access_role = true
db_port = 5432
db_engine_version = "14.6"
db_parameter_group_family = "aurora-postgresql14"
backup_retention_period = 7
preferred_backup_window = "02:00-03:00"
preferred_maintenance_window = "sun:05:00-sun:06:00"
auto_minor_version_upgrade = true
storage_encrypted = true
monitoring_interval = 60
performance_insights_enabled = true
performance_insights_retention_period = 7
deletion_protection = true
apply_immediately = false
skip_final_snapshot = false
final_snapshot_identifier_prefix = "final"
create_eks_integration = false
create_eks_secrets_access = false
create_eks_irsa_access = false
eks_node_role_id = ""
create_eks_k8s_resources = false
eks_cluster_name = ""
eks_namespace = "default"
create_eks_service_account = false
eks_service_account_name = "db-access"
create_acm_certificates = false
create_public_certificate = false
create_private_certificate = false
domain_name = ""
subject_alternative_names = []
auto_validate_certificate = true
route53_zone_name = ""
create_waf_configuration = false
waf_scope = "REGIONAL"
enable_waf_managed_rules = true
enable_sql_injection_protection = true
enable_rate_limiting = true
waf_rate_limit = 2000
create_pgbouncer = false
pgbouncer_instance_type = "t3.micro"
pgbouncer_min_capacity = 1
pgbouncer_max_capacity = 3
pgbouncer_desired_capacity = 2
pgbouncer_port = 6432
pgbouncer_max_client_conn = 1000
pgbouncer_default_pool_size = 20
pgbouncer_create_lb = true
create_lambda_functions = false
EOF
  echo "Default tfvars file created for $TEAM_NAME in $ENVIRONMENT environment."
fi

# Create a temporary tfvars file that includes both global and team-specific settings
echo "Creating combined tfvars file for $TEAM_NAME in $ENVIRONMENT environment..."
jq -s '.[0] * .[1]' terraform.tfvars.json "teams/$TEAM_NAME/$ENVIRONMENT/terraform.tfvars.json" > "terraform.$TEAM_NAME.$ENVIRONMENT.tfvars.json"

# Set the workspace
echo "Setting workspace to $ENVIRONMENT..."
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan Terraform
echo "Planning Terraform for $TEAM_NAME in $ENVIRONMENT environment..."
terraform plan -var-file="terraform.$TEAM_NAME.$ENVIRONMENT.tfvars.json" -out=tfplan

# Apply Terraform if requested
if [ "$APPLY" = "true" ]; then
  echo "Applying Terraform for $TEAM_NAME in $ENVIRONMENT environment..."
  terraform apply tfplan
else
  echo "Skipping apply. Run with 'true' as the third argument to apply changes."
fi

# Clean up
echo "Cleaning up..."
rm -f "terraform.$TEAM_NAME.$ENVIRONMENT.tfvars.json"

echo "Done!" 