# Getting Started with AWS Aurora PostgreSQL Terraform

This guide will help you get started with deploying AWS Aurora PostgreSQL and related infrastructure using this Terraform module collection.

## Prerequisites

Before you begin, make sure you have:

1. [Terraform](https://www.terraform.io/downloads.html) installed (v1.0.0 or newer)
2. AWS credentials configured with appropriate permissions
3. Git installed (to clone this repository)
4. Basic knowledge of Terraform and AWS services
5. **Existing VPC and subnet infrastructure** (required)

## Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/aws-aurora-postgresql-terraform.git
cd aws-aurora-postgresql-terraform
```

### Step 2: Choose Your Deployment Approach

This module collection supports three main deployment approaches:

1. **Full deployment**: All modules including Aurora PostgreSQL, PGBouncer, EKS integration, etc.
2. **Database-only deployment**: Just the Aurora cluster with essential components
3. **Custom deployment**: Pick and choose only the modules you need

### Step 3: Configure Your Infrastructure

1. Create a new configuration file for your team and environment:

```bash
mkdir -p config/your-team/dev
cp terraform.tfvars.json.example config/your-team/dev/terraform.tfvars.json
```

2. Edit the configuration file to match your requirements:

```bash
nano config/your-team/dev/terraform.tfvars.json
```

3. Set the module creation flags according to your needs:

```json
{
  "existing_vpc_id": "vpc-0123456789abcdef0",
  "existing_private_subnet_ids": ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"],
  "existing_public_subnet_ids": ["subnet-0123456789abcdef3", "subnet-0123456789abcdef4", "subnet-0123456789abcdef5"],
  
  "create_aurora_db": true,
  "create_kms_key": true,
  "create_enhanced_monitoring_role": true,
  "create_db_credentials_secret": true,
  "create_sns_topic": true,
  "create_db_event_subscription": true,
  "create_eks_integration": false,
  "create_acm_certificates": false,
  "create_waf_configuration": false,
  "create_pgbouncer": true,
  "create_lambda_functions": false
}
```

### Step 4: Initialize Terraform

```bash
terraform init
```

### Step 5: Create a Workspace for Your Team

```bash
terraform workspace new your-team-dev
```

### Step 6: Plan Your Deployment

```bash
terraform plan -var-file=config/your-team/dev/terraform.tfvars.json
```

### Step 7: Apply Your Configuration

```bash
terraform apply -var-file=config/your-team/dev/terraform.tfvars.json
```

## Module Configuration Guide

### Network Configuration

You must provide existing VPC and subnet IDs:

```json
{
  "existing_vpc_id": "vpc-0123456789abcdef0",
  "existing_private_subnet_ids": ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"],
  "existing_public_subnet_ids": ["subnet-0123456789abcdef3", "subnet-0123456789abcdef4"],
  "existing_db_security_group_ids": ["sg-0123456789abcdef5"]
}
```

### Aurora DB Module

Basic Aurora PostgreSQL configuration:

```json
{
  "create_aurora_db": true,
  "database_name": "appdb",
  "master_username": "dbadmin",
  "generate_master_password": true,
  "db_port": 5432,
  "db_instance_count": 2,
  "db_instance_class": "db.r5.large",
  "db_engine_version": "14.6",
  "backup_retention_period": 7,
  "preferred_backup_window": "02:00-03:00",
  "performance_insights_enabled": true
}
```

### PGBouncer Module

To deploy PGBouncer for connection pooling:

```json
{
  "create_pgbouncer": true,
  "pgbouncer_instance_type": "t3.micro",
  "pgbouncer_desired_capacity": 2,
  "pgbouncer_port": 6432,
  "pgbouncer_max_client_conn": 1000,
  "pgbouncer_default_pool_size": 20,
  "pgbouncer_create_lb": true
}
```

### EKS Integration Module

To integrate with an existing EKS cluster:

```json
{
  "create_eks_integration": true,
  "create_eks_secrets_access": true,
  "create_eks_irsa_access": true,
  "eks_node_role_id": "your-eks-node-role-id",
  "create_eks_k8s_resources": true,
  "eks_namespace": "default",
  "create_eks_service_account": true
}
```

### ACM Certificates Module

To create certificates for your load balancers:

```json
{
  "create_acm_certificates": true,
  "create_public_certificate": true,
  "domain_name": "app.example.com",
  "subject_alternative_names": ["api.app.example.com"],
  "auto_validate_certificate": true,
  "route53_zone_name": "example.com"
}
```

### WAF Configuration Module

To configure a Web Application Firewall:

```json
{
  "create_waf_configuration": true,
  "waf_scope": "REGIONAL",
  "enable_waf_managed_rules": true,
  "enable_sql_injection_protection": true,
  "enable_rate_limiting": true,
  "waf_rate_limit": 2000
}
```

### Lambda Functions Module

To deploy Lambda functions:

```json
{
  "create_lambda_functions": true,
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
```

## GitHub Actions Workflow

To use the included GitHub Actions workflow:

1. Store your AWS credentials in GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

2. Configure the workflow file for your teams and environments:

```yaml
# .github/workflows/terraform.yml
name: 'Terraform'

on:
  push:
    branches: [ main ]
    paths:
      - 'config/**'
      - '**.tf'
      - '.github/workflows/terraform.yml'
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      team:
        description: 'Team name (e.g., team-a)'
        required: true
      environment:
        description: 'Environment (e.g., dev, staging, prod)'
        required: true
```

3. Trigger the workflow manually with your team and environment parameters.

## Common Deployment Examples

### Example 1: Database-Only Deployment

For a simple Aurora PostgreSQL cluster without additional components:

```json
{
  "aws_region": "us-east-1",
  "environment": "dev",
  "project_name": "db-only",
  "owner": "team-a",
  
  "existing_vpc_id": "vpc-0123456789abcdef0",
  "existing_private_subnet_ids": ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"],
  "existing_public_subnet_ids": ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"],
  
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

### Example 2: Lambda-Only Deployment

For deploying only Lambda functions without a database:

```json
{
  "aws_region": "us-east-1",
  "environment": "dev",
  "project_name": "lambda-only",
  "owner": "team-b",
  
  "existing_vpc_id": "vpc-0123456789abcdef0",
  "existing_private_subnet_ids": ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2"],
  "existing_public_subnet_ids": ["subnet-0123456789abcdef3", "subnet-0123456789abcdef4"],
  
  "create_aurora_db": false,
  "create_kms_key": true,
  "create_enhanced_monitoring_role": false,
  "create_db_credentials_secret": false,
  "create_sns_topic": true,
  "create_db_event_subscription": false,
  "create_eks_integration": false,
  "create_acm_certificates": false,
  "create_waf_configuration": false,
  "create_pgbouncer": false,
  "create_lambda_functions": true
}
```

### Example 3: Complete Application Stack

For a complete application stack with all components:

```json
{
  "aws_region": "us-east-1",
  "environment": "prod",
  "project_name": "complete-app",
  "owner": "team-c",
  
  "existing_vpc_id": "vpc-0123456789abcdef0",
  "existing_private_subnet_ids": ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"],
  "existing_public_subnet_ids": ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"],
  
  "create_aurora_db": true,
  "create_kms_key": true,
  "create_enhanced_monitoring_role": true,
  "create_db_credentials_secret": true,
  "create_sns_topic": true,
  "create_db_event_subscription": true,
  "create_eks_integration": true,
  "create_acm_certificates": true,
  "create_waf_configuration": true,
  "create_pgbouncer": true,
  "create_lambda_functions": true
}
```

## Terraform State Management

This module uses Terraform workspaces to manage state for different teams and environments:

- Create a new workspace: `terraform workspace new team-a-dev`
- List workspaces: `terraform workspace list`
- Select a workspace: `terraform workspace select team-a-dev`

## Troubleshooting

### Common Issues

1. **Network Configuration Errors**:
   - Ensure that the provided VPC and subnet IDs exist and are correct
   - Verify that your subnets have routing configured properly
   - Check that security groups allow necessary traffic

2. **IAM Permission Issues**:
   - Check that your AWS credentials have the necessary permissions
   - Look for IAM error messages in the Terraform output

3. **Dependency Errors**:
   - Follow the correct order of resource creation
   - Use the `depends_on` attribute when necessary

### Getting Help

If you need assistance:

1. Check the module documentation
2. Review the AWS service documentation
3. Open an issue in the GitHub repository with details about your problem
4. Contact the module maintainers

## Next Steps

After deploying your infrastructure:

1. Configure database connections in your applications
2. Set up monitoring and alerting
3. Implement backup and disaster recovery procedures
4. Plan for scaling and performance optimization

## Resources

- [AWS Aurora Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [PGBouncer Documentation](https://www.pgbouncer.org/usage.html)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
