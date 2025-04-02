# AWS Aurora PostgreSQL Module

This Terraform module creates an AWS Aurora PostgreSQL cluster with associated resources.

## Features

- Creates a complete Aurora PostgreSQL cluster with instances
- Supports both provisioned and serverless v2 deployments
- Configurable parameter groups for fine-tuning database settings
- Enhanced monitoring and performance insights support
- CloudWatch alarms for key metrics
- IAM authentication support
- Encryption using AWS KMS
- Custom endpoints for reader and writer separation
- Automated backups with configurable retention

## Usage

```hcl
module "aurora_postgresql" {
  source = "../../modules/aurora_postgresql"

  name             = "myapp-db"
  application_name = "myapp"
  environment      = "production"
  
  subnet_ids         = ["subnet-12345678", "subnet-23456789", "subnet-34567890"]
  security_group_ids = ["sg-12345678"]
  
  database_name   = "myappdb"
  master_username = "dbadmin"
  
  instance_count = 2
  instance_class = "db.r6g.large"
  
  storage_encrypted = true
  kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456"
  
  backup_retention_period = 7
  
  monitoring_interval = 60
  
  performance_insights_enabled = true
  
  create_cloudwatch_alarms = true
  
  tags = {
    Department = "Engineering"
    Project    = "Database Infrastructure"
  }
}
```

## Module Configuration for Serverless V2

To use Aurora Serverless v2, specify an instance class with "serverless" in its name and configure the min/max capacity:

```hcl
module "aurora_serverless" {
  source = "../../modules/aurora_postgresql"

  name             = "myapp-serverless"
  application_name = "myapp"
  environment      = "staging"
  
  # Other config...
  
  # Serverless v2 configuration
  instance_class = "db.serverless"
  serverless_min_capacity = 0.5
  serverless_max_capacity = 4.0
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for Aurora PostgreSQL resources | `string` | n/a | yes |
| application_name | Name of the application that will use this database | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| availability_zones | A list of availability zones for the Aurora cluster | `list(string)` | `[]` | no |
| subnet_ids | A list of subnet IDs to use for the Aurora cluster | `list(string)` | n/a | yes |
| security_group_ids | A list of security group IDs to associate with the Aurora cluster | `list(string)` | n/a | yes |
| database_name | Name of the default database to create | `string` | n/a | yes |
| master_username | Username for the master DB user | `string` | `"postgres"` | no |
| master_password | Password for the master DB user. If not provided, a random password will be generated | `string` | `""` | no |
| port | The port on which the DB accepts connections | `number` | `5432` | no |
| instance_count | Number of DB instances to create in the cluster | `number` | `2` | no |
| instance_class | Instance class to use for the DB instances | `string` | `"db.t3.medium"` | no |
| engine_version | Aurora PostgreSQL engine version | `string` | `"13.7"` | no |
| db_parameter_group_family | Family of the DB parameter group | `string` | `"aurora-postgresql13"` | no |
| cluster_parameters | A list of cluster parameters to apply | `list(map(string))` | `[]` | no |
| instance_parameters | A list of instance parameters to apply | `list(map(string))` | `[]` | no |
| backup_retention_period | The number of days to retain backups for | `number` | `7` | no |
| preferred_backup_window | The daily time range during which automated backups are created | `string` | `"02:00-03:00"` | no |
| preferred_maintenance_window | The weekly time range during which system maintenance can occur | `string` | `"sun:04:00-sun:05:00"` | no |
| storage_encrypted | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| kms_key_id | The ARN for the KMS encryption key. If not specified, the default encryption key is used | `string` | `null` | no |
| deletion_protection | If the DB instance should have deletion protection enabled | `bool` | `true` | no |
| skip_final_snapshot | Determines whether a final DB snapshot is created before the DB instance is deleted | `bool` | `false` | no |
| apply_immediately | Specifies whether any cluster modifications are applied immediately | `bool` | `false` | no |
| publicly_accessible | Bool to control if instances are publicly accessible | `bool` | `false` | no |
| iam_database_authentication_enabled | Specifies whether or not the mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `false` | no |
| enabled_cloudwatch_logs_exports | List of log types to export to CloudWatch | `list(string)` | `["postgresql"]` | no |
| monitoring_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance | `number` | `0` | no |
| monitoring_role_arn | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs | `string` | `null` | no |
| performance_insights_enabled | Specifies whether Performance Insights are enabled | `bool` | `false` | no |
| performance_insights_retention_period | The amount of time in days to retain Performance Insights data | `number` | `7` | no |
| performance_insights_kms_key_id | The ARN for the KMS key to encrypt Performance Insights data | `string` | `null` | no |
| auto_minor_version_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `true` | no |
| allow_major_version_upgrade | Indicates that major version upgrades are allowed | `bool` | `false` | no |
| create_custom_endpoints | Create custom endpoints for the Aurora cluster | `bool` | `false` | no |
| backtrack_window | The target backtrack window, in seconds. Valid values are between 0 and 259200 (72 hours) | `number` | `0` | no |
| create_cloudwatch_alarms | Create CloudWatch alarms for the Aurora cluster | `bool` | `false` | no |
| cloudwatch_alarm_actions | List of ARNs of actions to take when the CloudWatch alarms enter the ALARM state | `list(string)` | `[]` | no |
| cloudwatch_ok_actions | List of ARNs of actions to take when the CloudWatch alarms enter the OK state | `list(string)` | `[]` | no |
| cpu_utilization_threshold | The value against which the CPU utilization metric is compared | `number` | `80` | no |
| freeable_memory_threshold | The value against which the freeable memory metric is compared (in bytes) | `number` | `64000000` | no |
| disk_queue_depth_threshold | The value against which the disk queue depth metric is compared | `number` | `20` | no |
| serverless_min_capacity | The minimum capacity for an Aurora PostgreSQL Serverless v2 DB cluster in Aurora capacity units (ACU) | `number` | `0.5` | no |
| serverless_max_capacity | The maximum capacity for an Aurora PostgreSQL Serverless v2 DB cluster in Aurora capacity units (ACU) | `number` | `1.0` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the Aurora cluster |
| cluster_resource_id | The Resource ID of the Aurora cluster |
| cluster_arn | Amazon Resource Name (ARN) of the Aurora cluster |
| cluster_endpoint | Writer endpoint for the Aurora cluster |
| cluster_reader_endpoint | Reader endpoint for the Aurora cluster |
| custom_reader_endpoint | Custom reader endpoint for the Aurora cluster |
| cluster_port | The database port for the Aurora cluster |
| database_name | The database name |
| master_username | The master username for the database |
| instance_identifiers | List of instance identifiers in the Aurora cluster |
| instance_endpoints | List of instance endpoints in the Aurora cluster |
| db_subnet_group_name | The name of the DB subnet group |
| db_subnet_group_id | The ID of the DB subnet group |
| cluster_parameter_group_name | The name of the cluster parameter group |
| instance_parameter_group_name | The name of the instance parameter group |
| security_group_ids | List of security group IDs used by the cluster |
| cloudwatch_alarms | Map of CloudWatch alarms and their properties |
| is_serverless_v2 | Indicates if the cluster is using ServerlessV2 |
| enhanced_monitoring_enabled | Indicates if enhanced monitoring is enabled |
| performance_insights_enabled | Indicates if Performance Insights is enabled |
| deletion_protection_enabled | Indicates if deletion protection is enabled |
| iam_auth_enabled | Indicates if IAM database authentication is enabled |

## License

This module is licensed under the MIT License - see the LICENSE file for details.