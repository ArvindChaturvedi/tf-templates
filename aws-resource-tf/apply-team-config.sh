#!/bin/bash
# Script to apply team-specific configurations

set -e

# Display usage information
function show_usage {
  echo "Usage: $0 <team_name> <environment> [plan_only]"
  echo "  team_name: Name of the team (e.g., team-a, team-b)"
  echo "  environment: Environment to deploy to (default: dev)"
  echo "  plan_only: Whether to plan only (default: false)"
  echo ""
  echo "Example: $0 team-a staging true"
  exit 1
}

# Check if team name and environment are provided
if [ "$#" -lt 2 ]; then
    show_usage
fi

TEAM_NAME=$1
ENVIRONMENT=$2
PLAN_ONLY=${3:-false}

# Create team directory if it doesn't exist
mkdir -p "teams/${TEAM_NAME}/${ENVIRONMENT}"

# Generate tfvars.json file
cat > "teams/${TEAM_NAME}/${ENVIRONMENT}/terraform.tfvars.json" << EOF
{
  "aws_region": "us-east-1",
  "environment": "${ENVIRONMENT}",
  "project_name": "${TEAM_NAME}",
  "owner": "devops-team",
  
  "existing_vpc_id": "vpc-0123456789abcdef0",
  "existing_private_subnet_ids": ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"],
  "existing_public_subnet_ids": ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"],
  "existing_db_security_group_ids": ["sg-0123456789abcdef7"],
  
  "create_aurora_db": true,
  "database_name": "${TEAM_NAME}-db",
  "master_username": "${TEAM_NAME}-admin",
  "instance_count": 2,
  "instance_class": "db.r5.large",
  
  "create_kms_key": true,
  "create_enhanced_monitoring_role": true,
  "create_db_credentials_secret": true,
  "generate_master_password": true,
  "create_sns_topic": true,
  "create_db_event_subscription": true,
  "create_db_access_role": true,
  
  "create_pgbouncer": false,
  "create_eks_integration": false,
  
  "db_cluster_parameters": {
    "rds.force_ssl": "1",
    "pg_stat_statements.track": "all"
  },
  "db_instance_parameters": {
    "log_min_duration_statement": "1000",
    "log_connections": "1",
    "log_disconnections": "1"
  }
}
EOF

# Generate tfvars file
cat > "teams/${TEAM_NAME}/${ENVIRONMENT}/terraform.tfvars" << EOF
aws_region = "us-east-1"
environment = "${ENVIRONMENT}"
project_name = "${TEAM_NAME}"
owner = "devops-team"

existing_vpc_id = "vpc-0123456789abcdef0"
existing_private_subnet_ids = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
existing_public_subnet_ids = ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"]
existing_db_security_group_ids = ["sg-0123456789abcdef7"]

create_aurora_db = true
database_name = "${TEAM_NAME}-db"
master_username = "${TEAM_NAME}-admin"
instance_count = 2
instance_class = "db.r5.large"

create_kms_key = true
create_enhanced_monitoring_role = true
create_db_credentials_secret = true
generate_master_password = true
create_sns_topic = true
create_db_event_subscription = true
create_db_access_role = true

create_pgbouncer = false
create_eks_integration = false

db_cluster_parameters = {
  "rds.force_ssl"              = "1"
  "pg_stat_statements.track"   = "all"
}

db_instance_parameters = {
  "log_min_duration_statement" = "1000"
  "log_connections"            = "1"
  "log_disconnections"         = "1"
}
EOF

# Run terraform plan
terraform init
if [ "$PLAN_ONLY" = "true" ]; then
    terraform plan -var-file="teams/${TEAM_NAME}/${ENVIRONMENT}/terraform.tfvars.json"
else
    terraform apply -auto-approve -var-file="teams/${TEAM_NAME}/${ENVIRONMENT}/terraform.tfvars.json"
fi

echo "Done!" 