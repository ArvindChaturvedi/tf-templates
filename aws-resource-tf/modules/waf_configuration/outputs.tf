output "web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.name
}

output "blocked_ip_set_id" {
  description = "ID of the IP set for blocked IPs"
  value       = length(var.blocked_ip_addresses) > 0 ? aws_wafv2_ip_set.blocked_ips[0].id : ""
}

output "allowed_ip_set_id" {
  description = "ID of the IP set for allowed IPs"
  value       = var.enable_whitelist_rule && length(var.allowed_ip_addresses) > 0 ? aws_wafv2_ip_set.allowed_ips[0].id : ""
}

output "association_id" {
  description = "ID of the WAF-ALB association"
  value       = var.alb_arn != "" ? aws_wafv2_web_acl_association.alb_association[0].id : ""
}