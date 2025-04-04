# Example Terraform Variables File
# Copy to terraform.tfvars and customize as needed

# AWS Configuration
aws_region  = "us-west-2"
environment = "test"
project_name = "myproject-aurora"
owner       = "infrastructure"

# Network Configuration - Using Existing VPC
existing_vpc_id = "vpc-0123456789abcdef0"
existing_private_subnet_ids = [
  "subnet-0123456789abcdef1", 
  "subnet-0123456789abcdef2",
  "subnet-0123456789abcdef3"
]
# Make sure these subnets match the availability zones
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Database Configuration
db_instance_class = "db.r5.large"
db_engine_version = "14.6"
db_deletion_protection = true

# Custom Database Parameters
db_parameters = {
  "log_statement" = "all"
  "log_min_duration_statement" = "1000"  # Log queries taking more than 1 second
  "shared_preload_libraries" = "pg_stat_statements"
  "pg_stat_statements.track" = "all"
}

# Application Teams
application_teams = [
  {
    name = "team1"
    application = "analytics"
    cost_center = "data-engineering"
    db_name = "analytics_db"
    instance_count = 2
    instance_class = "db.r5.xlarge"
    parameters = {
      "work_mem" = "16MB"
      "maintenance_work_mem" = "1GB"
    }
  },
  {
    name = "team2"
    application = "reporting"
    cost_center = "business-intelligence"
    db_name = "reporting_db"
    instance_count = 2
  }
]