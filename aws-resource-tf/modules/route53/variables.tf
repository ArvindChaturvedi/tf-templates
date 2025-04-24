variable "create_route53_records" {
  description = "Whether to create Route53 records"
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone where records will be created"
  type        = string
  default     = ""
}

variable "hosted_zone_name" {
  description = "The name of the hosted zone (used if hosted_zone_id is not provided)"
  type        = string
  default     = ""
}

variable "records" {
  description = "Map of Route53 records to create"
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = list(string)
    alias = optional(object({
      name                   = string
      zone_id               = string
      evaluate_target_health = optional(bool, true)
    }), null)
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 