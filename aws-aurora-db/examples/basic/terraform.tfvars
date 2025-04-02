# Basic configuration for testing

name = "aurora-pg-basic"
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
db_instance_class = "db.t3.medium"
db_engine_version = "13.7"
cluster_parameters = {
  "log_statement" = "all"
  "log_min_duration_statement" = "1000"
}
db_deletion_protection = false