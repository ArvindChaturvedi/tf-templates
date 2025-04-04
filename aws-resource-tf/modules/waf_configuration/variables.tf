variable "name" {
  description = "Name prefix for the resources"
  type        = string
}

variable "scope" {
  description = "Scope of the WAF Web ACL. Valid values: REGIONAL or CLOUDFRONT"
  type        = string
  default     = "REGIONAL"
}

variable "enable_aws_managed_rules" {
  description = "Whether to enable AWS managed rules (Common Rule Set)"
  type        = bool
  default     = true
}

variable "enable_sql_injection_protection" {
  description = "Whether to enable AWS managed rules for SQL injection protection"
  type        = bool
  default     = true
}

variable "enable_rate_limiting" {
  description = "Whether to enable rate limiting protection"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Request limit for rate-based rules"
  type        = number
  default     = 2000
}

variable "blocked_ip_addresses" {
  description = "List of IP addresses to block (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "enable_whitelist_rule" {
  description = "Whether to enable IP whitelisting rule"
  type        = bool
  default     = false
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses to allow (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "custom_rules" {
  description = "List of custom WAF rules"
  type = list(object({
    name                   = string
    action                 = string
    positional_constraint  = string
    search_string          = string
  }))
  default = []
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with the WAF"
  type        = string
  default     = ""
}

variable "enable_logging" {
  description = "Whether to enable WAF logging"
  type        = bool
  default     = false
}

variable "log_destination_arn" {
  description = "ARN of the destination for WAF logs (S3 bucket, CloudWatch Logs, or Kinesis Firehose)"
  type        = string
  default     = ""
}

variable "redacted_fields" {
  description = "List of fields to redact from logs"
  type = list(object({
    type = string
    name = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}