# Team-Specific Configurations

This directory contains team-specific configuration files for AWS resources. Each team has its own directory with a `terraform.tfvars.json` file that contains team-specific settings.

## Directory Structure

```
teams/
├── team-a/
│   └── terraform.tfvars.json
├── team-b/
│   └── terraform.tfvars.json
└── README.md
```

## How to Use

### For Teams

1. Create a directory for your team if it doesn't exist:
   ```bash
   mkdir -p teams/your-team-name
   ```

2. Create a `terraform.tfvars.json` file in your team directory with your team-specific settings:
   ```json
   {
     "application_name": "your-team-app",
     "database_name": "your-team-db",
     "master_username": "your-team-admin",
     "instance_count": 2,
     "instance_class": "db.r5.large",
     "allowed_cidrs": ["10.0.0.0/16"],
     "backup_retention_period": 7,
     "performance_insights_enabled": true,
     "performance_insights_retention_period": 7,
     "monitoring_interval": 60,
     "db_cluster_parameters": {
       "log_statement": "all",
       "log_min_duration_statement": "1000"
     },
     "db_instance_parameters": {
       "work_mem": "16MB",
       "maintenance_work_mem": "1GB"
     },
     "create_cloudwatch_alarms": true,
     "create_sns_topic": true,
     "create_db_credentials_secret": true,
     "generate_master_password": true,
     "create_db_event_subscription": true,
     "create_db_access_role": true,
     "create_eks_integration": false,
     "create_pgbouncer": false
   }
   ```

3. Use the `apply-team-config.sh` script to apply your team's configuration:
   ```bash
   ./apply-team-config.sh your-team-name dev true
   ```

### For DevOps/Infrastructure Teams

1. The root `terraform.tfvars.json` file contains global settings that apply to all teams.

2. Each team's `terraform.tfvars.json` file contains team-specific settings that override the global settings.

3. The `apply-team-config.sh` script combines the global settings with the team-specific settings and applies them.

4. To add a new team, create a new directory and `terraform.tfvars.json` file in the `teams` directory.

## Available Settings

The following settings can be configured in the team-specific `terraform.tfvars.json` file:

### Required Settings

- `application_name`: Name of the application
- `database_name`: Name of the database
- `master_username`: Username for the master DB user
- `instance_count`: Number of DB instances to create in the cluster
- `instance_class`: Instance type to use for the DB instances
- `allowed_cidrs`: CIDR blocks allowed to access the database

### Optional Settings

- `backup_retention_period`: Number of days to retain backups (default: 7)
- `performance_insights_enabled`: Whether to enable performance insights (default: true)
- `performance_insights_retention_period`: Retention period for performance insights in days (default: 7)
- `monitoring_interval`: Interval in seconds for enhanced monitoring (default: 60)
- `db_cluster_parameters`: Map of cluster parameters to apply
- `db_instance_parameters`: Map of instance parameters to apply
- `create_cloudwatch_alarms`: Whether to create CloudWatch alarms (default: true)
- `create_sns_topic`: Whether to create SNS topics for notifications (default: true)
- `create_db_credentials_secret`: Whether to create a Secrets Manager secret for database credentials (default: true)
- `generate_master_password`: Whether to generate a random master password (default: true)
- `create_db_event_subscription`: Whether to create RDS event subscriptions (default: true)
- `create_db_access_role`: Whether to create IAM roles for database access (default: true)
- `create_eks_integration`: Whether to create EKS integration components (default: false)
- `create_eks_secrets_access`: Whether to create Kubernetes Secret access for Secrets Manager (default: false)
- `create_eks_irsa_access`: Whether to create IAM Roles for Service Accounts (default: false)
- `create_eks_k8s_resources`: Whether to create Kubernetes resources (default: false)
- `create_eks_service_account`: Whether to create Kubernetes Service Account (default: false)
- `eks_cluster_name`: Name of the EKS cluster (default: "")
- `eks_namespace`: Kubernetes namespace to create resources in (default: "default")
- `eks_service_account_name`: Name of the Kubernetes service account (default: "db-access")
- `create_pgbouncer`: Whether to create PGBouncer connection pooling (default: false)
- `pgbouncer_instance_type`: Instance type for PGBouncer (default: "t3.micro")
- `pgbouncer_min_capacity`: Minimum capacity for PGBouncer ASG (default: 1)
- `pgbouncer_max_capacity`: Maximum capacity for PGBouncer ASG (default: 3)
- `pgbouncer_desired_capacity`: Desired capacity for PGBouncer ASG (default: 2)
- `pgbouncer_port`: Port for PGBouncer (default: 6432)
- `pgbouncer_max_client_conn`: Maximum client connections for PGBouncer (default: 1000)
- `pgbouncer_default_pool_size`: Default pool size for PGBouncer (default: 20)
- `pgbouncer_create_lb`: Whether to create a load balancer for PGBouncer (default: true)
- `create_lambda_functions`: Whether to create Lambda functions (default: false)
- `lambda_functions`: Map of Lambda functions to create

## Best Practices

1. Keep team-specific settings in the team's `terraform.tfvars.json` file.
2. Use consistent naming conventions across teams (e.g., `{team-name}-{resource-type}-{environment}`).
3. Implement resource tagging for better cost allocation and management.
4. Set up team-specific IAM roles and permissions.
5. Use separate VPCs or subnets for each team.
6. Implement proper security groups and network ACLs per team. 