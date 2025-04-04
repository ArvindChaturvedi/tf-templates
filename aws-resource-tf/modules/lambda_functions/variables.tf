variable "name" {
  description = "Name prefix for the Lambda function and related resources"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = "Lambda function created by Terraform"
}

variable "handler" {
  description = "Lambda function handler (e.g., index.handler)"
  type        = string
}

variable "runtime" {
  description = "Lambda function runtime (e.g., nodejs14.x, python3.9)"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "publish_versions" {
  description = "Whether to publish a new Lambda version on code changes"
  type        = bool
  default     = false
}

variable "filename" {
  description = "Path to the function's deployment package (ZIP file)"
  type        = string
  default     = ""
}

variable "s3_bucket" {
  description = "S3 bucket containing the function's deployment package"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 key of the function's deployment package"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "create_custom_policy" {
  description = "Whether to create a custom IAM policy for the Lambda function"
  type        = bool
  default     = false
}

variable "custom_policy_json" {
  description = "JSON policy document for the custom IAM policy"
  type        = string
  default     = ""
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs the Lambda function needs access to"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for Lambda function (required if vpc_subnet_ids is provided)"
  type        = string
  default     = ""
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs for Lambda function VPC configuration"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of additional security group IDs for Lambda function VPC configuration"
  type        = list(string)
  default     = []
}

variable "additional_policy_arns" {
  description = "List of additional IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing Aurora DB credentials"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "dead_letter_target_arn" {
  description = "ARN of an SQS queue or SNS topic for the Lambda function's dead letter queue"
  type        = string
  default     = ""
}

variable "tracing_mode" {
  description = "X-Ray tracing mode for the Lambda function (PassThrough or Active)"
  type        = string
  default     = ""
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the Lambda function"
  type        = number
  default     = -1
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda function logs"
  type        = number
  default     = 7
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for triggering the Lambda function"
  type        = string
  default     = ""
}

variable "s3_event_trigger_buckets" {
  description = "List of S3 bucket names to trigger the Lambda function on events"
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to trigger the Lambda function"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}