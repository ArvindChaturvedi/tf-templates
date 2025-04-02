# Aurora PostgreSQL Terraform Module

This module creates an Aurora PostgreSQL cluster on AWS with customizable parameters, security settings, and monitoring.

## Features

- Creates a PostgreSQL-compatible Aurora cluster
- Configurable instance count and instance class
- Support for custom parameter groups
- Security features including encryption at rest
- Monitoring and CloudWatch alarms
- Customizable backup settings
- Support for IAM database authentication
- Performance Insights configuration
- Support for custom endpoints
- Serverless v2 scaling configuration

## Usage

```hcl
module "aurora_postgresql" {
  source = "../modules/aurora_postgresql"

  name            = "example-postgres"
  application_name = "my-application"
  environment     = "dev"

  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
  
  database_name  = "exampledb"
  master_username = "dbadmin"
  
  instance_count = 2
  instance_class = "db.r5.large"
  
  # Enable encryption
  storage_encrypted = true
  
  # Set backup retention period (in days)
  backup_retention_period = 7
  
  # Enable monitoring
  create_cloudwatch_alarms = true
  cloudwatch_alarm_actions = ["arn:aws:sns:us-east-1:123456789012:example-topic"]
  
  # Add custom parameters
  cluster_parameters = [
    {
      name  = "rds.force_ssl"
      value = "1"
    }
  ]
  
  tags = {
    Owner       = "Team1"
    Project     = "Example"
    Environment = "dev"
  }
}
