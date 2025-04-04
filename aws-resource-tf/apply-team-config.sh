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

# Check if team directory exists
if [ ! -d "teams/$TEAM_NAME" ]; then
  echo "Error: Team directory 'teams/$TEAM_NAME' does not exist."
  exit 1
fi

# Check if team tfvars file exists
if [ ! -f "teams/$TEAM_NAME/terraform.tfvars.json" ]; then
  echo "Error: Team tfvars file 'teams/$TEAM_NAME/terraform.tfvars.json' does not exist."
  exit 1
fi

# Create a temporary tfvars file that includes both global and team-specific settings
echo "Creating combined tfvars file for $TEAM_NAME..."
jq -s '.[0] * {teams: {}} | .teams[.teams | keys[0]] = .[1]' terraform.tfvars.json "teams/$TEAM_NAME/terraform.tfvars.json" > "terraform.$TEAM_NAME.tfvars.json"

# Set the workspace
echo "Setting workspace to $ENVIRONMENT..."
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan Terraform
echo "Planning Terraform for $TEAM_NAME in $ENVIRONMENT environment..."
terraform plan -var-file="terraform.$TEAM_NAME.tfvars.json" -out=tfplan

# Apply Terraform if requested
if [ "$APPLY" = "true" ]; then
  echo "Applying Terraform for $TEAM_NAME in $ENVIRONMENT environment..."
  terraform apply tfplan
else
  echo "Skipping apply. Run with 'true' as the third argument to apply changes."
fi

# Clean up
echo "Cleaning up..."
rm -f "terraform.$TEAM_NAME.tfvars.json"

echo "Done!" 