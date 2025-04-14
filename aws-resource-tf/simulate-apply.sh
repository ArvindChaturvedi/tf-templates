#!/bin/bash
# Script to simulate Terraform apply workflow without creating actual resources

set -e

# Display usage information
function show_usage {
  echo "Usage: $0 <team_name> <environment> [plan_only]"
  echo "  team_name: Name of the team (e.g., team-a, team-b)"
  echo "  environment: Environment to deploy to (default: dev)"
  echo "  plan_only: Whether to plan only (default: true)"
  echo ""
  echo "Example: $0 team-a staging true"
  exit 1
}

# Function to clean up and restore original state
cleanup() {
    echo "Cleaning up and restoring original state..."
    
    # Restore original provider.tf
    if [ -f "provider.tf.backup" ]; then
        echo "Restoring original provider.tf..."
        mv provider.tf.backup provider.tf
    fi
    
    # Remove temporary files
    echo "Removing temporary files..."
    rm -f mock-provider.tf override.tf tfplan
    
    # Remove generated team configuration
    if [ -n "$TEAM_NAME" ] && [ -n "$ENVIRONMENT" ]; then
        echo "Removing generated team configuration..."
        rm -rf "teams/${TEAM_NAME}/${ENVIRONMENT}"
        
        # Remove empty team directory if it exists
        if [ -d "teams/${TEAM_NAME}" ] && [ -z "$(ls -A "teams/${TEAM_NAME}")" ]; then
            rmdir "teams/${TEAM_NAME}"
        fi
    fi
    
    # Remove temporary workspace
    if [ -n "$WORKSPACE" ]; then
        echo "Removing temporary workspace..."
        # Switch to default workspace first
        terraform workspace select default || true
        terraform workspace delete "${WORKSPACE}" || true
    fi
    
    # Remove terraform init files if they were created during simulation
    if [ -d ".terraform" ] && [ -f ".terraform.lock.hcl" ]; then
        read -p "Do you want to remove Terraform initialization files? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing Terraform initialization files..."
            rm -rf .terraform .terraform.lock.hcl
        fi
    fi
    
    echo "Cleanup completed!"
}

# Set up trap to ensure cleanup happens even if script fails
trap cleanup EXIT

# Check if team name and environment are provided
if [ "$#" -lt 2 ]; then
    show_usage
fi

TEAM_NAME=$1
ENVIRONMENT=$2
PLAN_ONLY=${3:-true}
WORKSPACE="${TEAM_NAME}-${ENVIRONMENT}"

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
  
  "create_serverless_lambda": true,
  "lambda_git_repository_url": "https://github.com/your-org/${TEAM_NAME}-lambda-functions.git",
  "lambda_git_repository_branch": "main",
  "lambda_git_repository_token": "",
  "lambda_functions": {
    "call-group": {
      "description": "Function to handle call group operations",
      "runtime": "python3.9",
      "handler": "call-group.handler",
      "source_dir": "functions/call-group",
      "environment_variables": {
        "SCRIPT_PATH": "/function-job-scripts/call-group.sh"
      },
      "timeout": 300,
      "memory_size": 256,
      "build_command": "pip install -r requirements.txt -t ."
    },
    "vacuum-analyse": {
      "description": "Function to handle vacuum and analyse operations",
      "runtime": "python3.9",
      "handler": "vacuum-analyse.handler",
      "source_dir": "functions/vacuum-analyse",
      "environment_variables": {
        "SCRIPT_PATH": "/function-job-scripts/vacuum-analyse.sh"
      },
      "timeout": 600,
      "memory_size": 512,
      "build_command": "pip install -r requirements.txt -t ."
    }
  },
  "enable_lambda_xray": true,
  "enable_lambda_alarms": true,
  
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

create_serverless_lambda = true
lambda_git_repository_url = "https://github.com/your-org/${TEAM_NAME}-lambda-functions.git"
lambda_git_repository_branch = "main"
lambda_git_repository_token = ""

lambda_functions = {
  call-group = {
    description = "Function to handle call group operations"
    runtime     = "python3.9"
    handler     = "call-group.handler"
    source_dir  = "functions/call-group"
    
    environment_variables = {
      SCRIPT_PATH = "/function-job-scripts/call-group.sh"
    }
    
    timeout     = 300
    memory_size = 256
    build_command = "pip install -r requirements.txt -t ."
  }
  
  vacuum-analyse = {
    description = "Function to handle vacuum and analyse operations"
    runtime     = "python3.9"
    handler     = "vacuum-analyse.handler"
    source_dir  = "functions/vacuum-analyse"
    
    environment_variables = {
      SCRIPT_PATH = "/function-job-scripts/vacuum-analyse.sh"
    }
    
    timeout     = 600
    memory_size = 512
    build_command = "pip install -r requirements.txt -t ."
  }
}

enable_lambda_xray = true
enable_lambda_alarms = true

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

# Backup the original provider.tf if it exists
if [ -f "provider.tf" ]; then
    echo "Backing up original provider.tf..."
    cp provider.tf provider.tf.backup
fi

# Create a mock provider configuration
cat > "provider.tf" << EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  # Use mock credentials
  access_key = "mock_access_key"
  secret_key = "mock_secret_key"
  
  # Skip all AWS API calls
  skip_metadata_api_check     = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
  
  # Disable actual API calls
  s3_use_path_style = true
  
  # Use dummy endpoints that will fail gracefully
  endpoints {
    apigateway     = "http://dummy"
    cloudwatch     = "http://dummy"
    dynamodb       = "http://dummy"
    ec2            = "http://dummy"
    es             = "http://dummy"
    elasticache    = "http://dummy"
    firehose       = "http://dummy"
    iam            = "http://dummy"
    kinesis        = "http://dummy"
    lambda         = "http://dummy"
    rds            = "http://dummy"
    redshift       = "http://dummy"
    route53        = "http://dummy"
    s3             = "http://dummy"
    secretsmanager = "http://dummy"
    ses            = "http://dummy"
    sns            = "http://dummy"
    sqs            = "http://dummy"
    ssm            = "http://dummy"
    stepfunctions  = "http://dummy"
    sts            = "http://dummy"
  }
}

# Override data sources to return mock data
data "aws_vpc" "selected" {
  id = "vpc-0123456789abcdef0"
}

data "aws_subnet" "private" {
  count = 3
  id    = "subnet-0123456789abcdef${count.index + 1}"
}

data "aws_subnet" "public" {
  count = 3
  id    = "subnet-0123456789abcdef${count.index + 4}"
}

data "aws_security_group" "db" {
  id = "sg-0123456789abcdef7"
}

data "aws_caller_identity" "current" {
  account_id = "123456789012"
  arn        = "arn:aws:iam::123456789012:user/mock-user"
  user_id    = "AIDAXXXXXXXXXXXXXXXXX"
}
EOF

# Create temporary override file for networking module
cat > "override.tf" << EOF
# Override networking module data sources
module "networking" {
  source = "./modules/networking"
  
  providers = {
    aws = aws
  }
  
  vpc_id = "vpc-0123456789abcdef0"
  private_subnet_ids = [
    "subnet-0123456789abcdef1",
    "subnet-0123456789abcdef2",
    "subnet-0123456789abcdef3"
  ]
  public_subnet_ids = [
    "subnet-0123456789abcdef4",
    "subnet-0123456789abcdef5",
    "subnet-0123456789abcdef6"
  ]
}
EOF

# Run terraform init with the mock provider
echo "Initializing Terraform with mock provider..."
terraform init -upgrade -backend=false

# Create a workspace for this team and environment
echo "Creating/selecting workspace: ${WORKSPACE}"
terraform workspace select ${WORKSPACE} || terraform workspace new ${WORKSPACE}

# Run terraform plan
echo "Running Terraform plan..."
terraform plan -var-file="teams/${TEAM_NAME}/${ENVIRONMENT}/terraform.tfvars.json" -out=tfplan

# If plan_only is false, show what would happen in a real apply
if [ "$PLAN_ONLY" = "false" ]; then
  echo "This is a simulation. In a real apply, the following would happen:"
  echo "1. AWS resources would be created according to the plan"
  echo "2. The serverless Lambda functions would be cloned from the Git repository"
  echo "3. The functions would be packaged and deployed to AWS Lambda"
  echo "4. CloudWatch alarms would be set up for monitoring"
  echo ""
  echo "To actually apply these changes, run:"
  echo "terraform apply -var-file=\"teams/${TEAM_NAME}/${ENVIRONMENT}/terraform.tfvars.json\""
else
  echo "Plan completed successfully. No resources were created."
  echo "To apply these changes, run:"
  echo "./apply-team-config.sh ${TEAM_NAME} ${ENVIRONMENT} false"
fi

# Ask user if they want to clean up now
read -p "Do you want to clean up and restore the original state now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cleanup
    trap - EXIT  # Remove the trap since we manually called cleanup
else
    echo "Skipping cleanup. You can manually clean up later by running the script again."
fi

echo "Done!" 