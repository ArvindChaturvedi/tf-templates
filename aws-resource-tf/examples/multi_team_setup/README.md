# Multi-Team Infrastructure Management with Terraform

This example demonstrates how to structure Terraform code for managing infrastructure across multiple application teams within an organization.

## Overview

Large organizations typically have multiple teams that require their own dedicated infrastructure resources. This example implements a solution that allows:

1. Each team to have isolated infrastructure
2. Standardized deployment processes
3. Centralized management of common infrastructure patterns
4. Team-specific configuration and customization

## Prerequisites

- Terraform >= 1.0.0
- AWS credentials configured
- **Existing VPC and subnet infrastructure**
- S3 bucket for Terraform state
- DynamoDB table for state locking

## Architecture

```
Organization
├── Team A
│   ├── Development Environment
│   ├── Staging Environment
│   └── Production Environment
├── Team B
│   ├── Development Environment
│   ├── Staging Environment
│   └── Production Environment
└── Team C
    ├── Development Environment
    ├── Staging Environment
    └── Production Environment
```

Each team's infrastructure is deployed using the same core Terraform modules, but with team-specific configuration parameters and isolated state files.

## Implementation Details

### Directory Structure

```
/
├── config/
│   ├── team-a/
│   │   ├── dev.tfvars.json
│   │   ├── staging.tfvars.json
│   │   └── prod.tfvars.json
│   ├── team-b/
│   │   ├── dev.tfvars.json
│   │   ├── staging.tfvars.json
│   │   └── prod.tfvars.json
│   └── team-c/
│       ├── dev.tfvars.json
│       ├── staging.tfvars.json
│       └── prod.tfvars.json
├── modules/
│   ├── aurora_postgresql/
│   ├── networking/  # Only for networking resources in existing VPCs
│   ├── security/
│   └── ...
├── backend.tf
├── main.tf
└── .github/
    └── workflows/
        └── terraform.yml
```

### Configuration Files

Each team maintains its own set of configuration files for each environment:

```json
{
  "aws_region": "us-east-1",
  "environment": "dev",
  "project_name": "payment-service",
  "owner": "team-a",
  
  "/* Network Configuration */": null,
  "existing_vpc_id": "vpc-0abc123def456789a",
  "existing_private_subnet_ids": ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"],
  "existing_public_subnet_ids": ["subnet-abcdef0123456789a", "subnet-a9876543210fedcba"],
  
  "/* Aurora DB Configuration */": null,
  "create_aurora_db": true,
  "database_name": "payment",
  "master_username": "payment_admin",
  "db_instance_count": 2,
  "db_instance_class": "db.r5.large",
  
  "/* EKS Integration Configuration */": null,
  "create_eks_integration": true,
  "eks_namespace": "payment-system",
  
  "/* Application Team Configuration */": null,
  "application_teams": [
    {
      "name": "team-a",
      "application": "payment-service",
      "cost_center": "finance-123"
    }
  ]
}
```

### Important Note About Networking

This project no longer creates VPC or networking resources from scratch. Instead, it requires existing VPC and subnet IDs to be provided. The `networking` module is now used only for managing network-related resources within existing VPCs.

### Terraform State Management

State files are isolated for each team and environment using:

1. **S3 Backend with Dynamic Paths**: Each team gets a different state file path
   ```
   s3://${bucket}/${team_name}/${environment}/terraform.tfstate
   ```

2. **Workspaces**: Each team/environment combination uses a unique workspace
   ```
   terraform workspace select ${team_name}-${environment}
   ```

### GitHub Actions Workflow

The workflow automates infrastructure deployments:

1. **Matrix Strategy**: Generates a matrix of team/environment combinations
2. **Dynamic Backend Configuration**: Configures backends with team-specific paths
3. **Workspace Management**: Creates and selects appropriate workspaces
4. **Variable Files**: Loads the correct .tfvars.json file for each team/environment
5. **Approval Gates**: Uses environments for deployment approvals
6. **Notifications**: Sends success/failure notices to Slack

## Usage

### Deploying for a Specific Team

To deploy infrastructure for a specific team and environment:

```bash
# Initialize with the right backend path
terraform init \
  -backend-config="bucket=terraform-state-bucket" \
  -backend-config="key=team-a/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-lock-table"

# Select or create the workspace
terraform workspace select team-a-dev || terraform workspace new team-a-dev

# Plan with team-specific variables
terraform plan -var-file="config/team-a/dev.tfvars.json" -out=plan.out

# Apply the plan
terraform apply plan.out
```

### Using the GitHub Actions Workflow

For automated deployments, trigger the workflow:

1. **For all teams**: Push to the main branch
2. **For a specific team**: Use the workflow_dispatch trigger with team/environment parameters

## Benefits

This multi-team approach provides several advantages:

1. **Isolation**: Each team's infrastructure is separate
2. **Standardization**: Common modules ensure consistent implementation
3. **Self-Service**: Teams can request their own deployments
4. **Governance**: Centralized control over infrastructure patterns
5. **Cost Management**: Team-based tagging for cost allocation
6. **Security**: Environment-specific approval processes
7. **Scalability**: Easy to add new teams and environments

## Real-World Considerations

When implementing this approach, consider:

1. **Access Control**: IAM policies to restrict teams to their own resources
2. **Cost Allocation**: Implement tagging strategies for billing
3. **Module Versioning**: Use module versioning to control updates
4. **State Locking**: Ensure DynamoDB tables for state locking
5. **Secrets Management**: Securely handle credentials in CI/CD
6. **Drift Detection**: Schedule regular drift detection
7. **Documentation**: Maintain team-specific documentation
8. **Network Dependency**: Ensure that existing VPC and subnet IDs are available and accessible

## Example: Adding a New Team

To add a new team:

1. Create a directory for the team under `config/`:
   ```bash
   mkdir -p config/team-d/{dev,staging,prod}
   ```

2. Create configuration files for each environment:
   ```bash
   cp templates/tfvars.json.example config/team-d/dev.tfvars.json
   ```

3. Update the configuration with team-specific values including existing VPC and subnet IDs
4. Commit and push the changes
5. Trigger the workflow for the new team

## Conclusion

This multi-team setup provides a scalable and manageable way to handle infrastructure for multiple application teams in a large organization. By combining modular Terraform code, team-specific configuration, and automated workflows, it achieves a balance between centralized control and team flexibility while leveraging existing network infrastructure.
