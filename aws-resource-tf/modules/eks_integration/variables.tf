variable "name" {
  description = "Name prefix for the resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS and Aurora are deployed"
  type        = string
}

variable "db_security_group_id" {
  description = "Security group ID of the Aurora DB cluster"
  type        = string
}

variable "db_port" {
  description = "The port on which the Aurora DB accepts connections"
  type        = number
  default     = 5432
}

variable "create_secrets_access_policy" {
  description = "Whether to create a policy for EKS nodes to access the DB credentials in Secrets Manager"
  type        = bool
  default     = true
}

variable "create_irsa_secrets_access_policy" {
  description = "Whether to create a policy for IRSA (IAM Roles for Service Accounts) to access DB credentials"
  type        = bool
  default     = true
}

variable "node_role_id" {
  description = "IAM role ID for the EKS node group (required if create_secrets_access_policy is true)"
  type        = string
  default     = ""
}

variable "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing Aurora DB credentials"
  type        = string
  default     = ""
}

variable "create_k8s_resources" {
  description = "Whether to create Kubernetes resources like ConfigMaps and ServiceAccounts"
  type        = bool
  default     = false
}

variable "k8s_namespace" {
  description = "Kubernetes namespace where to create resources"
  type        = string
  default     = "default"
}

variable "create_service_account" {
  description = "Whether to create a Kubernetes ServiceAccount with IRSA for DB access"
  type        = bool
  default     = false
}

variable "db_access_role_arn" {
  description = "ARN of the IAM role for IRSA to access the DB (required if create_service_account is true)"
  type        = string
  default     = ""
}

variable "db_endpoint" {
  description = "The endpoint of the Aurora DB cluster"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "Name of the database in the Aurora cluster"
  type        = string
  default     = ""
}

variable "db_credentials_secret_name" {
  description = "Name of the Secrets Manager secret containing Aurora DB credentials"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}