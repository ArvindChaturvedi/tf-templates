aws_region = "us-east-1"
environment = "dev"
project_name = "team-alpha"
owner = "devops-team"

existing_vpc_id = "vpc-0123456789abcdef0"
existing_private_subnet_ids = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
existing_public_subnet_ids = ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"]
existing_db_security_group_ids = ["sg-0123456789abcdef7"]

create_aurora_db = true
database_name = "team-alpha-db"
master_username = "team-alpha-admin"
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

create_serverless_lambda = true
lambda_git_repository_url = "https://github.com/your-org/team-alpha-lambda-functions.git"
lambda_git_repository_branch = "main"
lambda_git_repository_token = ""

lambda_functions = {
  call-group = {
    description = "Function to handle call group operations"
    runtime     = "python3.9"
    handler     = "call-group.handler"
    source_dir  = "functions/call-group"
    
    environment_variables = {
      SCRIPT_PATH = "/function-job-scripts/call-group.sh"
    }
    
    timeout     = 300
    memory_size = 256
    build_command = "pip install -r requirements.txt -t ."
  }
  
  vacuum-analyse = {
    description = "Function to handle vacuum and analyse operations"
    runtime     = "python3.9"
    handler     = "vacuum-analyse.handler"
    source_dir  = "functions/vacuum-analyse"
    
    environment_variables = {
      SCRIPT_PATH = "/function-job-scripts/vacuum-analyse.sh"
    }
    
    timeout     = 600
    memory_size = 512
    build_command = "pip install -r requirements.txt -t ."
  }
}

enable_lambda_xray = true
enable_lambda_alarms = true

db_cluster_parameters = {
  "rds.force_ssl"              = "1"
  "pg_stat_statements.track"   = "all"
}

db_instance_parameters = {
  "log_min_duration_statement" = "1000"
  "log_connections"            = "1"
  "log_disconnections"         = "1"
}
