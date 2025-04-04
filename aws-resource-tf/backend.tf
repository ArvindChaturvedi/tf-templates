# Backend Configuration for Terraform State Management
# This configuration supports both local state (for development) and remote S3 state (for production)

terraform {
  # The backend configuration is defined in the GitHub Actions workflow
  # This allows for dynamic state paths based on team and environment
  # The following parameters will be provided during terraform init:
  # - bucket: S3 bucket for state storage
  # - key: Path within the bucket (e.g., team-a/dev/terraform.tfstate)
  # - region: AWS region where the bucket is located
  # - dynamodb_table: DynamoDB table for state locking
  
  backend "s3" {
    # AWS S3 bucket for remote state (specified during terraform init)
    # bucket = "terraform-state-bucket"
    
    # State file path within bucket (will be team_name/environment/terraform.tfstate)
    # key = "team-a/dev/terraform.tfstate"
    
    # AWS region for the S3 bucket
    # region = "us-east-1"
    
    # DynamoDB table for state locking
    # dynamodb_table = "terraform-lock-table"
    
    # Encrypt the state file
    encrypt = true
  }
}

# Note on State Management:
# 
# This architecture uses Terraform workspaces combined with S3 backend paths
# to isolate state for each application team and environment.
#
# The state structure follows this pattern:
# S3 Bucket
# ├── team-a/
# │   ├── dev/terraform.tfstate
# │   ├── staging/terraform.tfstate
# │   └── prod/terraform.tfstate
# ├── team-b/
# │   ├── dev/terraform.tfstate
# │   ├── staging/terraform.tfstate
# │   └── prod/terraform.tfstate
#
# Additionally, Terraform workspaces provide another layer of isolation:
# Each team/environment combination gets its own workspace (e.g., team-a-dev)
# This allows for complete separation of state between teams and environments.