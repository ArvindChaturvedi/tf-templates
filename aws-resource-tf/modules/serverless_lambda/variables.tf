variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "git_repository_url" {
  description = "URL of the Git repository containing Lambda functions"
  type        = string
}

variable "git_repository_branch" {
  description = "Branch of the Git repository to use"
  type        = string
  default     = "main"
}

variable "git_repository_token" {
  description = "Personal access token for private Git repositories"
  type        = string
  default     = ""
  sensitive   = true
}

variable "functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    description = string
    runtime     = string
    handler     = string
    source_dir  = string
    
    environment_variables = optional(map(string), {})
    timeout              = optional(number, 30)
    memory_size         = optional(number, 128)
    
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }), null)
    
    event_source = optional(object({
      type       = string # sqs, dynamodb, etc.
      source_arn = string
      batch_size = optional(number, 1)
      enabled    = optional(bool, true)
    }), null)

    layers = optional(list(string), [])
    
    build_command = optional(string, "")
    runtime_dependencies = optional(list(string), [])
    
    log_retention_days = optional(number, 14)
    reserved_concurrent_executions = optional(number, -1)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_xray" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for Lambda functions"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger"
  type        = list(string)
  default     = []
}

variable "common_environment_variables" {
  description = "Environment variables to add to all functions"
  type        = map(string)
  default     = {}
}

variable "lambda_role_permissions_boundary" {
  description = "ARN of IAM policy to use as permissions boundary for Lambda roles"
  type        = string
  default     = null
}

variable "enable_versioning" {
  description = "Enable function versioning"
  type        = bool
  default     = true
}

variable "create_alias" {
  description = "Create an alias for the Lambda function"
  type        = bool
  default     = true
}

variable "alias_name" {
  description = "Name of the alias to create"
  type        = string
  default     = "current"
} 