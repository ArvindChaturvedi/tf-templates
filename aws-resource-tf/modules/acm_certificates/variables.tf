variable "name" {
  description = "Name prefix for the resources"
  type        = string
}

variable "create_public_certificate" {
  description = "Whether to create a public ACM certificate (for external ALB)"
  type        = bool
  default     = true
}

variable "create_private_certificate" {
  description = "Whether to create a private ACM certificate (for internal ALB)"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for the public certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the public certificate"
  type        = list(string)
  default     = []
}

variable "internal_domain_name" {
  description = "Domain name for the private certificate"
  type        = string
  default     = ""
}

variable "internal_subject_alternative_names" {
  description = "Subject alternative names for the private certificate"
  type        = list(string)
  default     = []
}

variable "auto_validate_certificate" {
  description = "Whether to automatically validate the public certificate using Route53"
  type        = bool
  default     = true
}

variable "route53_zone_name" {
  description = "Name of the Route53 zone for certificate validation and ALB DNS records"
  type        = string
  default     = ""
}

variable "create_alb_dns_record" {
  description = "Whether to create a Route53 record for the ALB"
  type        = bool
  default     = false
}

variable "alb_dns_name" {
  description = "DNS name of the ALB (required if create_alb_dns_record is true)"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB (required if create_alb_dns_record is true)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}