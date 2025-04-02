# AWS Aurora PostgreSQL Terraform Modules

This repository provides Terraform modules for creating and managing AWS Aurora PostgreSQL clusters with a scalable directory structure suitable for multiple application teams.

## Directory Structure

```
├── examples/                  # Example implementations
│   ├── basic/                 # Basic cluster configuration
│   ├── custom_parameters/     # Example with custom DB parameters
│   └── multi_team_setup/      # Multi-team infrastructure setup
├── modules/                   # Reusable Terraform modules
│   ├── aurora_postgresql/     # Core Aurora PostgreSQL module
│   ├── networking/            # Network infrastructure module
│   └── security/              # Security resources module
```

## Modules

### Aurora PostgreSQL Module

The `aurora_postgresql` module creates an Aurora PostgreSQL cluster with customizable parameters, backup settings, monitoring, and performance configurations.

Key features:
- Configurable instance count and instance class
- Support for custom parameter groups
- Encryption at rest
- Monitoring and CloudWatch alarms
- Customizable backup settings
- IAM database authentication
- Performance Insights
- Serverless v2 scaling configuration

### Networking Module

The `networking` module creates the necessary network infrastructure for deploying PostgreSQL Aurora clusters, including VPC, subnets, and security groups.

Key features:
- VPC with public and private subnets
- Internet Gateway and NAT Gateway
- Route tables for traffic management
- Security groups for database access control

### Security Module

The `security` module creates security-related resources for AWS Aurora PostgreSQL clusters.

Key features:
- KMS Key for encryption
- IAM Roles for monitoring and database access
- Secrets Manager for database credentials
- SNS Topics for notifications
- RDS Event Subscriptions

## Examples

The repository includes several example configurations:

1. **Basic Setup** - A simple Aurora PostgreSQL cluster with standard configuration
2. **Custom Parameters** - Example with custom database parameters and settings
3. **Multi-Team Setup** - Advanced configuration demonstrating how to set up infrastructure for multiple teams

## Usage

To use these modules, you'll need:
- Terraform installed (version >= 1.0.0)
- AWS credentials configured
- Basic understanding of AWS VPC and RDS Aurora

See the README files in each module directory for detailed usage instructions and the examples directory for implementation patterns.

## Getting Started

1. Clone this repository
2. Navigate to one of the examples directories
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and modify as needed
4. Run `terraform init`, `terraform plan`, and `terraform apply`

```bash
cd examples/basic
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred settings
terraform init
terraform plan
terraform apply
```

## Contributing

Contributions to improve these modules are welcome. Please follow the standard fork and pull request workflow.

## License

This project is licensed under the MIT License.
