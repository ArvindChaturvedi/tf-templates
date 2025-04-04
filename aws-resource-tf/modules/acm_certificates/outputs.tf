output "public_certificate_arn" {
  description = "ARN of the public ACM certificate (for external ALB)"
  value       = var.create_public_certificate ? aws_acm_certificate.public[0].arn : ""
}

output "private_certificate_arn" {
  description = "ARN of the private ACM certificate (for internal ALB)"
  value       = var.create_private_certificate ? aws_acm_certificate.private[0].arn : ""
}

output "validation_domains" {
  description = "List of domain validation options for the certificate"
  value       = var.create_public_certificate ? aws_acm_certificate.public[0].domain_validation_options : []
}

output "alb_dns_record_name" {
  description = "The DNS record name created for the ALB"
  value       = var.create_public_certificate && var.create_alb_dns_record && var.route53_zone_name != "" ? aws_route53_record.alb_record[0].name : ""
}

output "alb_dns_record_fqdn" {
  description = "The FQDN of the DNS record created for the ALB"
  value       = var.create_public_certificate && var.create_alb_dns_record && var.route53_zone_name != "" ? aws_route53_record.alb_record[0].fqdn : ""
}