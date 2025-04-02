# Local Values for Aurora PostgreSQL Infrastructure
# This file defines local variables that can be reused throughout the Terraform configuration

locals {
  # Common tags to be applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }

  # Team-specific configurations, merge team-specific tags with common tags
  team_tags = {
    for team in var.application_teams :
    team.name => merge(
      local.common_tags,
      {
        Team        = team.name
        Application = team.application
        Cost_Center = team.cost_center
      }
    )
  }

  # Network configurations
  network_config = {
    # Use existing VPC and subnets if specified
    use_existing_vpc     = var.existing_vpc_id != ""
    vpc_id               = var.existing_vpc_id != "" ? var.existing_vpc_id : module.networking.vpc_id
    private_subnet_ids   = length(var.existing_private_subnet_ids) > 0 ? var.existing_private_subnet_ids : module.networking.private_subnets
    # Calculate the number of AZs based on subnets
    availability_zones   = var.availability_zones
    # Enhanced monitoring role ARN
    monitoring_role_arn  = var.create_enhanced_monitoring_role ? module.security.monitoring_role_arn : var.existing_monitoring_role_arn
  }

  # Database configuration, with parameter defaults based on environment
  db_config = {
    parameter_family = "aurora-postgresql14"
    parameters = merge(
      # Default parameters for all environments
      {
        "shared_buffers"      = var.environment == "production" ? "{DBInstanceClassMemory/32768}" : "{DBInstanceClassMemory/65536}"
        "max_connections"     = var.environment == "production" ? "LEAST({DBInstanceClassMemory/9531392},5000)" : "LEAST({DBInstanceClassMemory/9531392},3000)"
        "effective_cache_size" = "{DBInstanceClassMemory/2}"
      },
      # Environment-specific parameter overrides
      var.db_parameters
    )
  }
}