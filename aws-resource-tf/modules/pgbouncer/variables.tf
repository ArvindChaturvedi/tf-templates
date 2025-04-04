variable "name" {
  description = "Name prefix for the resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where PGBouncer will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where PGBouncer instances will be deployed"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for PGBouncer instances"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access (if enable_ssh is true)"
  type        = string
  default     = ""
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to PGBouncer instances"
  type        = bool
  default     = false
}

variable "region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of PGBouncer instances"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of PGBouncer instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of PGBouncer instances"
  type        = number
  default     = 4
}

variable "db_endpoint" {
  description = "Endpoint of the Aurora DB cluster"
  type        = string
}

variable "db_port" {
  description = "Port of the Aurora DB cluster"
  type        = number
  default     = 5432
}

variable "database_name" {
  description = "Name of the database in the Aurora cluster"
  type        = string
}

variable "pgbouncer_port" {
  description = "Port where PGBouncer will listen"
  type        = number
  default     = 6432
}

variable "pgbouncer_max_client_conn" {
  description = "Maximum number of client connections"
  type        = number
  default     = 1000
}

variable "pgbouncer_default_pool_size" {
  description = "Default pool size for each database user"
  type        = number
  default     = 20
}

variable "pgbouncer_min_pool_size" {
  description = "Minimum pool size for each database user"
  type        = number
  default     = 0
}

variable "pgbouncer_max_db_connections" {
  description = "Maximum number of connections to the database"
  type        = number
  default     = 100
}

variable "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing Aurora DB credentials"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "Username for Aurora DB (used if db_credentials_secret_arn is not provided)"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Password for Aurora DB (used if db_credentials_secret_arn is not provided)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "custom_pg_params" {
  description = "Custom PGBouncer parameters to add to the configuration"
  type        = string
  default     = ""
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to connect to PGBouncer"
  type        = list(string)
}

variable "enable_ssh" {
  description = "Whether to enable SSH access to PGBouncer instances"
  type        = bool
  default     = false
}

variable "ssh_security_group_ids" {
  description = "List of security group IDs allowed to SSH into PGBouncer instances"
  type        = list(string)
  default     = []
}

variable "create_lb" {
  description = "Whether to create a load balancer for PGBouncer instances"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}