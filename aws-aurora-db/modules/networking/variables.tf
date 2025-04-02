variable "name" {
  description = "Name prefix for the networking resources"
  type        = string
}

variable "create_vpc" {
  description = "Whether to create a VPC"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of an existing VPC to use (if not creating a new one)"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "create_igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to create a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "create_security_group" {
  description = "Whether to create security groups for the Aurora DB"
  type        = bool
  default     = true
}

variable "create_app_security_group" {
  description = "Whether to create security group for applications that will access the Aurora DB"
  type        = bool
  default     = true
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 5432
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the Aurora DB"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups" {
  description = "List of existing security group IDs allowed to access the Aurora DB"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
