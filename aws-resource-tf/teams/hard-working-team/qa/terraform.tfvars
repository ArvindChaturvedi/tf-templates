aws_region = "us-east-1"
environment = "qa"
project_name = "hard-working-team"
owner = "devops-team"
existing_vpc_id = "vpc-0123456789abcdef0"
existing_private_subnet_ids = ["subnet-0123456789abcdef1", "subnet-0123456789abcdef2", "subnet-0123456789abcdef3"]
existing_public_subnet_ids = ["subnet-0123456789abcdef4", "subnet-0123456789abcdef5", "subnet-0123456789abcdef6"]
existing_db_security_group_ids = ["sg-0123456789abcdef7"]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
allowed_cidr_blocks = ["10.0.0.0/16"]
create_aurora_db = true
create_kms_key = true
create_enhanced_monitoring_role = true
create_db_credentials_secret = true
generate_master_password = true
create_sns_topic = true
create_db_event_subscription = true
create_db_access_role = true
db_port = 5432
db_engine_version = "14.6"
db_parameter_group_family = "aurora-postgresql14"
backup_retention_period = 7
preferred_backup_window = "02:00-03:00"
preferred_maintenance_window = "sun:05:00-sun:06:00"
auto_minor_version_upgrade = true
storage_encrypted = true
monitoring_interval = 60
performance_insights_enabled = true
performance_insights_retention_period = 7
deletion_protection = true
apply_immediately = false
skip_final_snapshot = false
final_snapshot_identifier_prefix = "final"
create_eks_integration = false
create_eks_secrets_access = false
create_eks_irsa_access = false
eks_node_role_id = ""
create_eks_k8s_resources = false
eks_cluster_name = ""
eks_namespace = "default"
create_eks_service_account = false
eks_service_account_name = "db-access"
create_acm_certificates = false
create_public_certificate = false
create_private_certificate = false
domain_name = ""
subject_alternative_names = []
auto_validate_certificate = true
route53_zone_name = ""
create_waf_configuration = false
waf_scope = "REGIONAL"
enable_waf_managed_rules = true
enable_sql_injection_protection = true
enable_rate_limiting = true
waf_rate_limit = 2000
create_pgbouncer = false
pgbouncer_instance_type = "t3.micro"
pgbouncer_min_capacity = 1
pgbouncer_max_capacity = 3
pgbouncer_desired_capacity = 2
pgbouncer_port = 6432
pgbouncer_max_client_conn = 1000
pgbouncer_default_pool_size = 20
pgbouncer_create_lb = true
create_lambda_functions = false
