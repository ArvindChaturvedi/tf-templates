output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  description = "Invocation ARN of the Lambda function (for API Gateway)"
  value       = aws_lambda_function.function.invoke_arn
}

output "function_qualified_arn" {
  description = "ARN identifying your Lambda function version"
  value       = aws_lambda_function.function.qualified_arn
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.function.version
}

output "function_last_modified" {
  description = "Date the Lambda function was last modified"
  value       = aws_lambda_function.function.last_modified
}

output "role_name" {
  description = "Name of the IAM role for the Lambda function"
  value       = aws_iam_role.lambda.name
}

output "role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  value       = aws_iam_role.lambda.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "security_group_id" {
  description = "ID of the security group for the Lambda function (if in VPC)"
  value       = var.vpc_subnet_ids != null && length(var.vpc_subnet_ids) > 0 ? aws_security_group.lambda[0].id : ""
}

output "schedule_rule_arn" {
  description = "ARN of the CloudWatch Events rule for the Lambda function (if scheduled)"
  value       = var.schedule_expression != "" ? aws_cloudwatch_event_rule.schedule[0].arn : ""
}