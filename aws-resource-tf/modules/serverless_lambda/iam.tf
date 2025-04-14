# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.name_prefix}-lambda-role"

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
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# X-Ray policy if tracing is enabled
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  count = var.enable_xray ? 1 : 0

  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Event source policy attachments
resource "aws_iam_role_policy_attachment" "event_source" {
  for_each = {
    for k, v in var.functions : k => v
    if v.event_source != null
  }

  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value.event_source.type == "sqs" ? "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole" : (
    each.value.event_source.type == "dynamodb" ? "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole" : null
  )
}

# Custom policy for additional permissions
resource "aws_iam_role_policy" "lambda_custom" {
  name = "${var.name_prefix}-lambda-custom"
  role = aws_iam_role.lambda_role.id

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