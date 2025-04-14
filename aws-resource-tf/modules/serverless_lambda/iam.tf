# IAM role for Lambda functions
resource "aws_iam_role" "lambda" {
  for_each = var.functions

  name = "${var.name_prefix}-${each.key}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  permissions_boundary = var.lambda_role_permissions_boundary

  tags = local.common_tags
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  for_each = var.functions

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access policy for Lambda functions with VPC config
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  for_each = {
    for k, v in var.functions : k => v
    if v.vpc_config != null
  }

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# X-Ray policy if tracing is enabled
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  for_each = var.enable_xray ? var.functions : {}

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Event source policy for functions with event sources
resource "aws_iam_role_policy_attachment" "event_source" {
  for_each = {
    for k, v in var.functions : k => v
    if v.event_source != null
  }

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = each.value.event_source.type == "sqs" ? "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole" : (
    each.value.event_source.type == "dynamodb" ? "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole" : null
  )
}

# Custom policy for additional permissions
resource "aws_iam_role_policy" "lambda_custom" {
  for_each = var.functions

  name = "${var.name_prefix}-${each.key}-custom"
  role = aws_iam_role.lambda[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
} 