region      = "us-east-1"
environment = "dev"
project_name = "multi-team-aurora"

vpc_cidr = "10.0.0.0/16"
az_count = 3
db_port  = 5432

monitoring_interval = 60
performance_insights_enabled = true
create_cloudwatch_alarms    = true

# Team 1 Configuration
team1_application_name = "team1-app"
team1_allowed_cidrs    = ["192.168.1.0/24"]
team1_database_name    = "team1db"
team1_master_username  = "team1admin"
team1_instance_count   = 2
team1_instance_class   = "db.t3.medium"
team1_backup_retention_period = 7

# Team 2 Configuration
team2_application_name = "team2-app"
team2_allowed_cidrs    = ["192.168.2.0/24"]
team2_database_name    = "team2db"
team2_master_username  = "team2admin"
team2_instance_count   = 2
team2_instance_class   = "db.t3.medium"
team2_backup_retention_period = 7
