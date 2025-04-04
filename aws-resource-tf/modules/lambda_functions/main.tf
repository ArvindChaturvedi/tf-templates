# Lambda Functions Module
# This module creates and manages Lambda functions and related resources

# Create IAM role for Lambda functions
resource "aws_iam_role" "lambda" {
  name = "${var.name}-lambda-role"

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

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-lambda-role"
    }
  )
}

# Attach basic execution policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach additional policies if provided
resource "aws_iam_role_policy_attachment" "lambda_additional_policies" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.lambda.name
  policy_arn = each.value
}

# Create custom policy for Lambda function if specified
resource "aws_iam_policy" "lambda_custom" {
  count       = var.create_custom_policy ? 1 : 0
  name        = "${var.name}-lambda-custom-policy"
  description = "Custom policy for ${var.name} Lambda function"

  policy = var.custom_policy_json
}

# Attach custom policy to the Lambda role if created
resource "aws_iam_role_policy_attachment" "lambda_custom" {
  count      = var.create_custom_policy ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_custom[0].arn
}

# Create S3 access policy for Lambda if specified
resource "aws_iam_policy" "lambda_s3_access" {
  count       = length(var.s3_bucket_arns) > 0 ? 1 : 0
  name        = "${var.name}-lambda-s3-access"
  description = "S3 access policy for ${var.name} Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = concat(var.s3_bucket_arns, [for arn in var.s3_bucket_arns : "${arn}/*"])
      }
    ]
  })
}

# Attach S3 access policy to the Lambda role if created
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  count      = length(var.s3_bucket_arns) > 0 ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_s3_access[0].arn
}

# Create policy for Aurora DB access via Secrets Manager if specified
resource "aws_iam_policy" "lambda_db_access" {
  count       = var.db_credentials_secret_arn != "" ? 1 : 0
  name        = "${var.name}-lambda-db-access"
  description = "Policy allowing Lambda function to access Aurora DB credentials in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = var.db_credentials_secret_arn
      }
    ]
  })
}

# Attach DB access policy to the Lambda role if created
resource "aws_iam_role_policy_attachment" "lambda_db_access" {
  count      = var.db_credentials_secret_arn != "" ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_db_access[0].arn
}

# Create VPC access policy for Lambda if specified
resource "aws_iam_policy" "lambda_vpc_access" {
  count       = var.vpc_subnet_ids != null && length(var.vpc_subnet_ids) > 0 ? 1 : 0
  name        = "${var.name}-lambda-vpc-access"
  description = "VPC access policy for ${var.name} Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach VPC access policy to the Lambda role if created
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count      = var.vpc_subnet_ids != null && length(var.vpc_subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_vpc_access[0].arn
}

# Create security group for Lambda if VPC access is specified
resource "aws_security_group" "lambda" {
  count       = var.vpc_subnet_ids != null && length(var.vpc_subnet_ids) > 0 ? 1 : 0
  name        = "${var.name}-lambda-sg"
  description = "Security group for ${var.name} Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-lambda-sg"
    }
  )
}

# Create Lambda function
resource "aws_lambda_function" "function" {
  function_name = "${var.name}-function"
  description   = var.description
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  publish       = var.publish_versions

  # Choose between S3 and local deployment package
  s3_bucket = var.s3_bucket != "" ? var.s3_bucket : null
  s3_key    = var.s3_bucket != "" ? var.s3_key : null
  filename  = var.s3_bucket == "" ? var.filename : null

  # Environment variables
  environment {
    variables = merge(
      var.environment_variables,
      var.db_credentials_secret_arn != "" ? {
        DB_CREDENTIALS_SECRET_ARN = var.db_credentials_secret_arn
        DB_SECRET_REGION          = var.region
      } : {}
    )
  }

  # VPC configuration if subnet IDs are provided
  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = concat([aws_security_group.lambda[0].id], var.vpc_security_group_ids)
    }
  }

  # Dead letter configuration if specified
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != "" ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # Tracing configuration if specified
  dynamic "tracing_config" {
    for_each = var.tracing_mode != "" ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  # Reserved concurrent executions if specified
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-function"
    }
  )
}

# Create CloudWatch Log Group for Lambda function
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-logs"
    }
  )
}

# Create CloudWatch Event Rule for scheduled execution if specified
resource "aws_cloudwatch_event_rule" "schedule" {
  count               = var.schedule_expression != "" ? 1 : 0
  name                = "${var.name}-schedule"
  description         = "Schedule for Lambda function ${var.name}"
  schedule_expression = var.schedule_expression

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-schedule"
    }
  )
}

# Set Lambda function as target for the schedule
resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = var.schedule_expression != "" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.schedule[0].name
  target_id = "${var.name}-target"
  arn       = aws_lambda_function.function.arn
}

# Grant permission for CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "cloudwatch" {
  count         = var.schedule_expression != "" ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}

# Create S3 event notifications if specified
resource "aws_lambda_permission" "allow_s3" {
  count         = length(var.s3_event_trigger_buckets) > 0 ? 1 : 0
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_event_trigger_buckets[0]}"
}

# Create SNS topic subscription if specified
resource "aws_sns_topic_subscription" "lambda" {
  count     = var.sns_topic_arn != "" ? 1 : 0
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.function.arn
}

# Grant permission for SNS to invoke the Lambda function
resource "aws_lambda_permission" "sns" {
  count         = var.sns_topic_arn != "" ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}