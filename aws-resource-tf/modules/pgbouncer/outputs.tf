output "security_group_id" {
  description = "ID of the security group for PGBouncer instances"
  value       = aws_security_group.pgbouncer.id
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group for PGBouncer instances"
  value       = aws_autoscaling_group.pgbouncer.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group for PGBouncer instances"
  value       = aws_autoscaling_group.pgbouncer.name
}

output "launch_template_id" {
  description = "ID of the Launch Template for PGBouncer instances"
  value       = aws_launch_template.pgbouncer.id
}

output "iam_role_name" {
  description = "Name of the IAM role for PGBouncer instances"
  value       = aws_iam_role.pgbouncer.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role for PGBouncer instances"
  value       = aws_iam_role.pgbouncer.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer for PGBouncer instances"
  value       = var.create_lb ? aws_lb.pgbouncer[0].dns_name : ""
}

output "load_balancer_arn" {
  description = "ARN of the load balancer for PGBouncer instances"
  value       = var.create_lb ? aws_lb.pgbouncer[0].arn : ""
}

output "target_group_arn" {
  description = "ARN of the target group for PGBouncer instances"
  value       = var.create_lb ? aws_lb_target_group.pgbouncer[0].arn : ""
}

output "pgbouncer_port" {
  description = "Port where PGBouncer is listening"
  value       = var.pgbouncer_port
}

output "connection_string" {
  description = "Connection string to connect to PGBouncer"
  value       = var.create_lb ? "postgresql://${var.db_username}:${var.db_password}@${aws_lb.pgbouncer[0].dns_name}:${var.pgbouncer_port}/${var.database_name}" : ""
  sensitive   = true
}