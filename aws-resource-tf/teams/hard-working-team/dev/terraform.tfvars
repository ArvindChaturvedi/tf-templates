aws_region = "us-east-1"
environment = "dev"
project_name = "hard-working-team"
owner = "devops-team"

existing_vpc_id = "vpc-0123456789abcdef0"
existing_private_subnet_ids = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
existing_public_subnet_ids = ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"]
existing_db_security_group_ids = ["sg-0123456789abcdef7"]

create_aurora_db = true
database_name = "hard-working-team-db"
master_username = "hard-working-team-admin"
instance_count = 2
instance_class = "db.r5.large"

create_kms_key = true
create_enhanced_monitoring_role = true
create_db_credentials_secret = true
generate_master_password = true
create_sns_topic = true
create_db_event_subscription = true
create_db_access_role = true

create_pgbouncer = false
create_eks_integration = false

db_cluster_parameters = {
  "rds.force_ssl"              = "1"
  "pg_stat_statements.track"   = "all"
}

db_instance_parameters = {
  "log_min_duration_statement" = "1000"
  "log_connections"            = "1"
  "log_disconnections"         = "1"
}
