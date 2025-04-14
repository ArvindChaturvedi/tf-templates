output "function_names" {
  description = "Names of the Lambda functions"
  value       = { for k, v in aws_lambda_function.this : k => v.function_name }
}

output "function_arns" {
  description = "ARNs of the Lambda functions"
  value       = { for k, v in aws_lambda_function.this : k => v.arn }
}

output "function_invoke_arns" {
  description = "Invoke ARNs of the Lambda functions"
  value       = { for k, v in aws_lambda_function.this : k => v.invoke_arn }
}

output "function_versions" {
  description = "Latest published version of the Lambda functions"
  value       = var.enable_versioning ? { for k, v in aws_lambda_function.this : k => "1" } : {}
}

output "function_aliases" {
  description = "ARNs of the Lambda function aliases"
  value       = var.create_alias ? { for k, v in aws_lambda_alias.this : k => v.arn } : {}
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.name
}

output "cloudwatch_log_groups" {
  description = "Names of the CloudWatch log groups"
  value       = { for k, v in aws_cloudwatch_log_group.lambda : k => v.name }
} 