variable "name" {
  description = "Name prefix for the networking resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC to use (required)"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of existing public subnets to use (required)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of existing private subnets to use (required)"
  type        = list(string)
}

variable "existing_security_group_ids" {
  description = "IDs of existing security groups to use for the database (if any)"
  type        = list(string)
  default     = []
}

variable "db_port" {
  description = "Port for the database connections"
  type        = number
  default     = 5432
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
