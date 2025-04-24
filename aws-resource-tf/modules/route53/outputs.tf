output "route53_record_ids" {
  description = "Map of Route53 record IDs"
  value       = { for k, v in aws_route53_record.this : k => v.id }
}

output "route53_record_fqdns" {
  description = "Map of Route53 record FQDNs"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}

output "hosted_zone_id" {
  description = "The ID of the hosted zone"
  value       = local.hosted_zone_id
}

output "hosted_zone_name" {
  description = "The name of the hosted zone"
  value       = var.hosted_zone_name
} 