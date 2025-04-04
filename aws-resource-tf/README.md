# AWS Aurora PostgreSQL Terraform Modules

A comprehensive, modular infrastructure as code solution for deploying AWS Aurora PostgreSQL clusters with supporting components tailored for enterprise application teams.

![Architecture Diagram](generated-icon.png)

## Overview

This repository provides a flexible framework for deploying AWS infrastructure using Terraform, with a focus on Aurora PostgreSQL database deployments and associated services. It is designed to support multiple application teams with varied requirements while maintaining consistent standards and security best practices.

## Features

- **Aurora PostgreSQL Clusters**: Fully-featured PostgreSQL-compatible database deployment
- **Database Connection Pooling**: PGBouncer instances in an Auto Scaling Group
- **Kubernetes Integration**: EKS service accounts and IAM integration for pod database access
- **Security**: WAF configurations, ACM certificates, encryption and audit logging
- **Automation**: Lambda functions for database operations and maintenance
- **Team Separation**: Isolated infrastructure for multiple application teams

## Architecture

The architecture follows a modular approach, with each component organized into its own module:

```
modules/
├── acm_certificates/       # AWS Certificate Manager for TLS certificates
├── aurora_postgresql/      # Aurora PostgreSQL cluster configuration
├── eks_integration/        # Amazon EKS integration components
├── lambda_functions/       # AWS Lambda functions for automation
├── networking/             # Security groups and network configuration with existing VPC/subnets
├── pgbouncer/              # Connection pooling with PGBouncer
├── security/               # IAM roles, KMS keys, secrets management
└── waf_configuration/      # Web Application Firewall settings
```

## Prerequisites

- AWS account with appropriate permissions
- Terraform v1.0.0 or newer
- Existing VPC and network architecture (required)
- For EKS integration: existing EKS cluster

## Deployment Models

This solution supports three deployment models:

1. **Full deployment**: Aurora PostgreSQL cluster with all supporting components
2. **Database-only deployment**: Just the Aurora cluster without additional components
3. **Component-specific deployment**: Use only the modules needed for your use case

## Usage

### Basic Aurora PostgreSQL Deployment

```hcl
module "aurora" {
  source = "github.com/your-org/aws-aurora-postgresql-terraform//modules/aurora_postgresql"

  name                    = "app-db"
  database_name           = "appdb"
  master_username         = "dbadmin"
  instance_count          = 2
  instance_class          = "db.r5.large"
  subnet_ids              = ["subnet-12345678", "subnet-87654321"]
  security_group_ids      = ["sg-12345678"]
  backup_retention_period = 7
  
  tags = {
    Environment = "production"
    Application = "example-app"
  }
}
```

### Team-Based Infrastructure Deployment

For multi-team infrastructure, define your configuration in team-specific JSON files:

1. Edit the configuration file for your team: `config/team-a/dev.tfvars.json`
2. Deploy using the GitHub Actions workflow with team and environment parameters

### Conditional Module Creation

Each module can be conditionally enabled or disabled based on the requirements of each application team. Set the appropriate flags in your tfvars file:

```json
{
  "aws_region": "us-east-1",
  "environment": "dev",
  "project_name": "app-platform",
  "owner": "app-team-a",
  
  "/* Required Network Configuration */": "Existing VPC and subnet IDs to use",
  "existing_vpc_id": "vpc-01234567890abcdef",
  "existing_private_subnet_ids": ["subnet-private1", "subnet-private2", "subnet-private3"],
  "existing_public_subnet_ids": ["subnet-public1", "subnet-public2", "subnet-public3"],
  
  "/* Module Creation Flags */": "Control which components are created",
  "create_aurora_db": true,
  "create_kms_key": true,
  "create_enhanced_monitoring_role": true,
  "create_db_credentials_secret": true,
  "create_sns_topic": true,
  "create_db_event_subscription": true,
  "create_eks_integration": false,
  "create_acm_certificates": false,
  "create_waf_configuration": false,
  "create_pgbouncer": false,
  "create_lambda_functions": false
}
```

#### Example: Create Only Lambda Functions

For a team that only needs Lambda functions:

```json
{
  "existing_vpc_id": "vpc-01234567890abcdef",
  "existing_private_subnet_ids": ["subnet-private1", "subnet-private2"],
  "existing_public_subnet_ids": ["subnet-public1", "subnet-public2"],
  
  "create_aurora_db": false,
  "create_kms_key": true,
  "create_lambda_functions": true,
  
  "lambda_functions": {
    "user-api": {
      "description": "Lambda function for user service API",
      "handler": "index.handler",
      "runtime": "nodejs16.x",
      "memory_size": 512,
      "vpc_config_enabled": true
    }
  }
}
```

#### Example: Create Only Aurora DB and PGBouncer

For a team that only needs a database with connection pooling:

```json
{
  "existing_vpc_id": "vpc-01234567890abcdef",
  "existing_private_subnet_ids": ["subnet-private1", "subnet-private2", "subnet-private3"],
  "existing_public_subnet_ids": ["subnet-public1", "subnet-public2", "subnet-public3"],
  
  "create_aurora_db": true,
  "create_kms_key": true,
  "create_pgbouncer": true,
  "create_eks_integration": false,
  "create_lambda_functions": false
}
```

## Module Details

### Aurora PostgreSQL

Creates an Aurora PostgreSQL cluster with:

- Cluster and instance parameters
- Security group and subnet group configuration
- Monitoring and logging settings
- Optional features like performance insights, IAM authentication, etc.

### PGBouncer

Deploys PGBouncer connection pooling with:

- Auto Scaling Group of EC2 instances
- User data script for PGBouncer configuration
- Optional load balancer for connection distribution
- Health checks and scaling policies

### EKS Integration

Configures database access from EKS pods:

- IAM roles for service accounts (IRSA)
- Secret injection for database credentials
- Node role policies for database connectivity
- Kubernetes namespace and service account resources

### Other Modules

Additional modules provide:

- **ACM Certificates**: Public and private TLS certificates
- **WAF Configuration**: Web Application Firewall rules and logging
- **Lambda Functions**: Scheduled database operations and event handling
- **Security**: IAM roles, KMS keys, secrets, and monitoring

## Team-Based Infrastructure

This solution provides team isolation through:

- Separate Terraform state files
- Team-specific parameter files
- Distinct resource naming
- IAM-based access control
- Workflow separation

## Deployment Pipeline

The included GitHub Actions workflow automates:

1. Terraform validation and formatting
2. Team-specific plan generation
3. Environment-specific deployment
4. State management and locking
5. Notifications and reporting

## Security Features

- All database credentials in AWS Secrets Manager
- Encryption at rest with AWS KMS keys
- Encryption in transit with enforced SSL
- IAM authentication for database users
- VPC security groups and network ACLs
- Web Application Firewall protection

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear change description

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- AWS Well-Architected Framework
- Terraform AWS Provider Documentation
- AWS Database Blog
