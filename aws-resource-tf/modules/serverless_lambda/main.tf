locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# Create Lambda functions
resource "aws_lambda_function" "this" {
  for_each = var.functions

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256
  function_name    = "${var.name_prefix}-${each.key}"
  role            = aws_iam_role.lambda[each.key].arn
  handler         = each.value.handler
  runtime         = each.value.runtime

  memory_size = each.value.memory_size
  timeout     = each.value.timeout

  environment {
    variables = merge(
      var.common_environment_variables,
      each.value.environment_variables
    )
  }

  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  layers = each.value.layers

  reserved_concurrent_executions = each.value.reserved_concurrent_executions

  tracing_config {
    mode = var.enable_xray ? "Active" : "PassThrough"
  }

  tags = local.common_tags

  depends_on = [aws_cloudwatch_log_group.lambda]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# Create CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda" {
  for_each = var.functions

  name              = "/aws/lambda/${var.name_prefix}-${each.key}"
  retention_in_days = each.value.log_retention_days

  tags = local.common_tags
}

# Create function versions if enabled
resource "aws_lambda_function_version" "this" {
  for_each = var.enable_versioning ? var.functions : {}

  function_name = aws_lambda_function.this[each.key].function_name
  description   = "Version ${timestamp()}"

  depends_on = [aws_lambda_function.this]
}

# Create aliases if enabled
resource "aws_lambda_alias" "this" {
  for_each = var.create_alias ? var.functions : {}

  name             = var.alias_name
  description      = "Alias for ${each.key}"
  function_name    = aws_lambda_function.this[each.key].function_name
  function_version = var.enable_versioning ? aws_lambda_function_version.this[each.key].version : "$LATEST"
}

# Package Lambda functions
data "archive_file" "lambda_zip" {
  for_each = var.functions

  type        = "zip"
  output_path = "${path.root}/.terraform/archive/${each.key}.zip"
  source_dir  = each.value.source_dir

  depends_on = [null_resource.build]
}

# Build functions if build command is specified
resource "null_resource" "build" {
  for_each = {
    for k, v in var.functions : k => v
    if v.build_command != ""
  }

  triggers = {
    source_code_hash = sha256(join("", [for f in fileset(each.value.source_dir, "**") : filesha256("${each.value.source_dir}/${f}")]))
  }

  provisioner "local-exec" {
    command     = each.value.build_command
    working_dir = each.value.source_dir
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "errors" {
  for_each = var.enable_cloudwatch_alarms ? var.functions : {}

  alarm_name          = "${var.name_prefix}-${each.key}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors ${each.key} lambda function errors"
  alarm_actions      = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.this[each.key].function_name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "throttles" {
  for_each = var.enable_cloudwatch_alarms ? var.functions : {}

  alarm_name          = "${var.name_prefix}-${each.key}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "Throttles"
  namespace          = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors ${each.key} lambda function throttles"
  alarm_actions      = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.this[each.key].function_name
  }

  tags = local.common_tags
}

# Event Source Mappings
resource "aws_lambda_event_source_mapping" "this" {
  for_each = {
    for k, v in var.functions : k => v
    if v.event_source != null
  }

  function_name = aws_lambda_function.this[each.key].function_name
  enabled       = each.value.event_source.enabled
  batch_size    = each.value.event_source.batch_size

  event_source_arn = each.value.event_source.source_arn

  depends_on = [aws_lambda_function.this, aws_iam_role_policy_attachment.event_source]
} 