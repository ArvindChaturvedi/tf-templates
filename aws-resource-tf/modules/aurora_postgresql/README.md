# AWS Aurora PostgreSQL Module

This module provides a standardized way to create an Aurora PostgreSQL database cluster with the most commonly required features and security best practices enabled by default.

## Features

- Aurora PostgreSQL cluster and instance(s) creation
- Security group and subnet group configuration
- Backup and maintenance window settings
- Performance Insights and Enhanced Monitoring
- Encryption at rest with KMS
- CloudWatch alarms and event notifications
- IAM database authentication
- Custom parameter groups and cluster settings

## Usage

```hcl
module "aurora_postgresql" {
  source = "../../modules/aurora_postgresql"

  name                    = "app-postgresql"
  environment             = "production"
  application_name        = "customer-portal"
  
  # Network settings
  subnet_ids              = ["subnet-12345678", "subnet-87654321"]
  security_group_ids      = ["sg-12345678"]
  
  # Database settings
  database_name           = "appdb"
  master_username         = "dbadmin"
  master_password         = var.db_password
  port                    = 5432
  
  # Instance settings
  instance_count          = 2
  instance_class          = "db.r5.large"
  engine_version          = "14.6"
  
  # Backup settings
  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
  
  # Maintenance settings
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  
  # Monitoring
  monitoring_interval             = 30
  monitoring_role_arn             = aws_iam_role.rds_enhanced_monitoring.arn
  performance_insights_enabled    = true
  create_cloudwatch_alarms        = true
  
  # Security
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.rds.arn
  iam_database_authentication_enabled = true
  
  # Parameters and settings
  cluster_parameters = {
    "rds.force_ssl"                   = "1"
    "log_min_duration_statement"      = "1000"
    "shared_preload_libraries"        = "pg_stat_statements"
  }
  
  instance_parameters = {
    "log_statement"                  = "ddl"
    "log_min_error_statement"        = "error"
    "log_rotation_age"               = "1440"
    "pg_stat_statements.track"       = "all"
  }
  
  tags = {
    Environment = "production"
    Application = "customer-portal"
    Terraform   = "true"
  }
}
```

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name of the Aurora cluster resources | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the Aurora subnet group | `list(string)` | n/a | yes |
| database_name | The name of the initial database | `string` | n/a | yes |
| master_username | The master username for the database | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_name | Application name for tagging and naming resources | `string` | `""` | no |
| environment | Environment name for tagging and naming resources | `string` | `""` | no |
| security_group_ids | List of security group IDs to associate with the cluster | `list(string)` | `[]` | no |
| master_password | Master password. If not specified, a random one will be generated | `string` | `""` | no |
| port | The port on which the DB accepts connections | `number` | `5432` | no |
| instance_count | Number of DB instances to create in the cluster | `number` | `2` | no |
| instance_class | Instance type for the Aurora cluster instances | `string` | `"db.r5.large"` | no |
| engine_version | The PostgreSQL engine version to use | `string` | `"14.6"` | no |
| storage_encrypted | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| kms_key_id | The ARN for the KMS encryption key. If not specified, the default RDS KMS key will be used | `string` | `""` | no |
| backup_retention_period | The days to retain backups for | `number` | `7` | no |
| preferred_backup_window | The daily time range during which automated backups are created | `string` | `"02:00-03:00"` | no |
| preferred_maintenance_window | The weekly time range during which system maintenance can occur | `string` | `"sun:04:00-sun:05:00"` | no |
| skip_final_snapshot | Determines whether a final DB snapshot is created before the DB cluster is deleted | `bool` | `false` | no |
| final_snapshot_identifier | The name of your final DB snapshot when this DB cluster is deleted | `string` | `""` | no |
| deletion_protection | If the DB instance should have deletion protection enabled | `bool` | `true` | no |
| apply_immediately | Specifies whether any cluster modifications are applied immediately | `bool` | `false` | no |
| monitoring_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected | `number` | `60` | no |
| monitoring_role_arn | The ARN for the IAM role that permits RDS to send Enhanced Monitoring metrics to CloudWatch | `string` | `""` | no |
| performance_insights_enabled | Specifies whether Performance Insights are enabled | `bool` | `true` | no |
| performance_insights_retention_period | The amount of time in days to retain Performance Insights data | `number` | `7` | no |
| create_cloudwatch_alarms | Whether to create CloudWatch alarms for the DB cluster | `bool` | `true` | no |
| cpu_utilization_threshold | The maximum percentage of CPU utilization to trigger an alarm | `number` | `80` | no |
| freeable_memory_threshold | The minimum amount of available memory in bytes to trigger an alarm | `number` | `256000000` | no |
| disk_queue_depth_threshold | The maximum disk queue depth to trigger an alarm | `number` | `64` | no |
| db_connections_threshold | The maximum number of database connections to trigger an alarm | `number` | `500` | no |
| iam_database_authentication_enabled | Specifies whether IAM Database authentication is enabled | `bool` | `false` | no |
| enabled_cloudwatch_logs_exports | List of log types to export to CloudWatch | `list(string)` | `["postgresql", "upgrade"]` | no |
| cluster_parameters | A map of cluster parameter group parameters | `map(string)` | `{}` | no |
| instance_parameters | A map of DB instance parameter group parameters | `map(string)` | `{}` | no |
| auto_minor_version_upgrade | Indicates that minor engine upgrades will be applied automatically | `bool` | `true` | no |
| allow_major_version_upgrade | Indicates that major version upgrades are allowed | `bool` | `false` | no |
| create_custom_endpoints | Whether to create custom endpoints for readers | `bool` | `false` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the Aurora cluster |
| cluster_arn | The ARN of the Aurora cluster |
| cluster_endpoint | The writer endpoint for the Aurora cluster |
| cluster_reader_endpoint | The reader endpoint for the Aurora cluster |
| cluster_port | The port of the Aurora cluster |
| security_group_id | The security group ID associated with the Aurora cluster |
| cluster_resource_id | The resource ID of the Aurora cluster |
| cluster_instances | List of cluster instance IDs |
| cluster_parameter_group_id | The ID of the DB cluster parameter group |
| instance_parameter_group_id | The ID of the DB instance parameter group |
| subnet_group_id | The ID of the DB subnet group |
| master_username | The master username for the database |
| database_name | The database name |
| cloudwatch_alarm_arns | List of ARNs of the CloudWatch alarms |

## Security Considerations

This module implements several security best practices:

1. **Encryption at Rest**: By default, all data is encrypted using AWS KMS.
2. **SSL Enforcement**: The module can configure the cluster to force SSL connections.
3. **IAM Authentication**: Optionally enable AWS IAM database authentication.
4. **Deletion Protection**: Enabled by default to prevent accidental deletion.
5. **Enhanced Monitoring**: Detailed OS-level metrics for better visibility.
6. **Audit Logging**: Optional logging of all database activity to CloudWatch.
7. **Network Isolation**: Deployment within private subnets in your VPC.

## Monitoring and Maintenance

The module provides:

1. **Performance Insights**: Deep database performance analysis.
2. **CloudWatch Alarms**: Preconfigured alarms for critical metrics.
3. **Enhanced Monitoring**: OS-level metrics at user-specified intervals.
4. **Automated Maintenance**: Configured maintenance windows for updates.
5. **Automated Backups**: Daily backups with configurable retention.

## Customization

The module allows extensive customization through variables:

1. **Parameter Groups**: Custom database parameters for both cluster and instances.
2. **Instance Types**: Choose the appropriate instance class for your workload.
3. **Scaling**: Set the desired number of read replicas.
4. **Backup Configuration**: Customize backup retention and timing.
5. **Monitoring Settings**: Adjust monitoring frequency and alarm thresholds.

## Example: High Availability Production Deployment

```hcl
module "aurora_postgresql_prod" {
  source = "../../modules/aurora_postgresql"

  name                    = "prod-postgresql"
  environment             = "production"
  application_name        = "financial-services"
  
  subnet_ids              = module.vpc.private_subnets
  security_group_ids      = [module.security.db_security_group_id]
  
  database_name           = "financial"
  master_username         = "admin"
  master_password         = var.db_master_password
  
  instance_count          = 3  # One writer, two readers
  instance_class          = "db.r5.2xlarge"
  
  backup_retention_period = 30
  preferred_backup_window = "01:00-03:00"
  preferred_maintenance_window = "sun:03:30-sun:05:30"
  
  monitoring_interval     = 1  # 1-second monitoring intervals
  performance_insights_retention_period = 731  # ~2 years
  
  storage_encrypted       = true
  kms_key_id              = module.kms.rds_key_arn
  iam_database_authentication_enabled = true
  
  deletion_protection     = true
  skip_final_snapshot     = false
  
  cluster_parameters = {
    "rds.force_ssl"                = "1"
    "shared_preload_libraries"     = "pg_stat_statements,auto_explain"
    "log_statement"                = "ddl"
    "log_min_duration_statement"   = "1000"
    "auto_explain.log_min_duration" = "1000"
  }
  
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade", "audit"]
  
  create_cloudwatch_alarms = true
  cpu_utilization_threshold = 70
  freeable_memory_threshold = 512000000  # 512MB
  
  tags = {
    Environment = "production"
    Application = "financial-services"
    Backup      = "daily"
    Terraform   = "true"
    CostCenter  = "finance-123"
  }
}
```