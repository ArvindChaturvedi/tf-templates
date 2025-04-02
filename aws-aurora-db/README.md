# AWS Aurora PostgreSQL Terraform Modules

This project provides a set of reusable Terraform modules for deploying and managing AWS Aurora PostgreSQL clusters, designed to serve multiple application teams with flexible infrastructure configurations.

## Project Structure

```
├── examples/                   # Example implementations
│   ├── basic/                  # Simple Aurora PostgreSQL deployment
│   ├── custom_parameters/      # Deployment with custom DB parameters
│   └── multi_team_setup/       # Setup for multiple application teams
├── modules/                    # Core modules
│   ├── aurora_postgresql/      # Aurora PostgreSQL cluster module
│   ├── networking/             # Networking infrastructure module
│   └── security/               # Security resources module
├── .github/
│   └── workflows/              # GitHub Actions workflows
│       └── terraform.yml       # CI/CD pipeline for Terraform
├── backend.tf                  # Terraform backend configuration
├── locals.tf                   # Local variables
├── main.tf                     # Root module configuration
├── outputs.tf                  # Root module outputs
├── provider.tf                 # AWS provider configuration
├── terraform.tfvars.example    # Example variable values
└── variables.tf                # Input variables
```

## Core Modules

### 1. Aurora PostgreSQL Module

Creates an Aurora PostgreSQL cluster with associated resources like parameter groups, subnet groups, and instances.

**Features:**
- Creates provisioned or Serverless V2 Aurora PostgreSQL clusters
- Configurable instance types and counts
- Parameter group customization
- Enhanced monitoring and performance insights
- CloudWatch alarms for key metrics
- Backup configuration
- Encryption using AWS KMS

### 2. Networking Module

Creates or uses existing VPC infrastructure for the Aurora PostgreSQL clusters, including subnets, route tables, and security groups.

**Features:**
- VPC and subnet creation
- Internet Gateway and NAT Gateway setup
- Public and private subnets
- Security groups for DB access
- Support for using existing VPC and subnet infrastructure

### 3. Security Module

Creates security-related resources for Aurora PostgreSQL, such as KMS keys, IAM roles, and secrets.

**Features:**
- KMS key for encryption
- IAM role for enhanced monitoring
- AWS Secrets Manager for database credentials
- IAM authentication for database access
- SNS topics for notifications
- RDS event subscriptions

## Example Implementations

### Basic Example

A simple implementation with standard parameters - use this as a starting point for new deployments.

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

### Custom Parameters Example

An implementation with customized database parameters for specific workloads.

```bash
cd examples/custom_parameters
terraform init
terraform plan
terraform apply
```

### Multi-Team Setup Example

An advanced setup for supporting multiple application teams with shared infrastructure.

```bash
cd examples/multi_team_setup
terraform init
terraform plan
terraform apply
```

## GitHub Actions CI/CD

This project includes a GitHub Actions workflow that automates:

1. Terraform validation and formatting checks
2. Infrastructure plan generation
3. PR comments with plan details
4. Infrastructure deployment to multiple environments
5. Slack notifications for deployment status

The workflow supports:
- Multiple environments (dev, staging, prod)
- Manual or automated deployments
- Workspace-based state management
- S3 backend for state storage

## Prerequisites

- Terraform >= 1.0.0
- AWS account with appropriate permissions
- S3 bucket for Terraform state (configured in backend.tf)
- DynamoDB table for state locking (configured in backend.tf)
- GitHub repository secrets for AWS credentials or role ARN

## Getting Started

1. Clone this repository
2. Choose an example implementation 
3. Customize `terraform.tfvars` based on `terraform.tfvars.example`
4. Initialize and apply Terraform:

```bash
terraform init \
  -backend-config="bucket=your-state-bucket" \
  -backend-config="key=your-state-path/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=your-lock-table"

terraform plan
terraform apply
```

## Best Practices

- Use workspace-based state management for different environments
- Apply appropriate tagging for cost allocation
- Use KMS encryption for all sensitive data
- Set up enhanced monitoring for production environments
- Configure CloudWatch alarms with appropriate thresholds
- Use deletion protection in production environments
- Implement proper IAM policies with least privilege

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with a clear description of changes

## License

This project is licensed under the MIT License - see the LICENSE file for details.