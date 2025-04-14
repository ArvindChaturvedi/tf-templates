locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  # Git repository name from URL
  repo_name = replace(
    basename(replace(var.git_repository_url, ".git", "")),
    "/[^a-zA-Z0-9-_]/",
    "-"
  )

  # Local path where the repository will be cloned
  repo_path = "${path.root}/.terraform/serverless/${local.repo_name}"
}

# Clone/update the Git repository
resource "null_resource" "git_clone" {
  triggers = {
    repository_url = var.git_repository_url
    branch        = var.git_repository_branch
    repo_path     = local.repo_path
  }

  provisioner "local-exec" {
    command = <<-EOT
      if [ -d "${local.repo_path}" ]; then
        cd "${local.repo_path}"
        git fetch origin
        git checkout ${var.git_repository_branch}
        git pull origin ${var.git_repository_branch}
      else
        mkdir -p "${local.repo_path}"
        %{if var.git_repository_token != ""}
        git clone --branch ${var.git_repository_branch} https://${var.git_repository_token}@${trimprefix(var.git_repository_url, "https://")} "${local.repo_path}"
        %{else}
        git clone --branch ${var.git_repository_branch} ${var.git_repository_url} "${local.repo_path}"
        %{endif}
      fi
    EOT
  }
}

# Create Lambda functions
resource "aws_lambda_function" "this" {
  for_each = var.functions

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256
  function_name    = "${var.name_prefix}-${each.key}"
  role            = aws_iam_role.lambda_role.arn
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

  reserved_concurrent_executions = each.value.reserved_concurrent_executions

  tracing_config {
    mode = var.enable_xray ? "Active" : "PassThrough"
  }

  tags = local.common_tags

  depends_on = [aws_cloudwatch_log_group.lambda, null_resource.git_clone]

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
resource "null_resource" "lambda_version" {
  for_each = var.enable_versioning ? var.functions : {}

  triggers = {
    function_name = aws_lambda_function.this[each.key].function_name
    function_arn  = aws_lambda_function.this[each.key].arn
    timestamp     = timestamp()
  }

  provisioner "local-exec" {
    command = "aws lambda publish-version --function-name ${aws_lambda_function.this[each.key].function_name} --description 'Version ${timestamp()}'"
  }

  depends_on = [aws_lambda_function.this]
}

# Create aliases if enabled
resource "aws_lambda_alias" "this" {
  for_each = var.create_alias ? var.functions : {}

  name             = var.alias_name
  description      = "Alias for ${each.key}"
  function_name    = aws_lambda_function.this[each.key].function_name
  function_version = "$LATEST"
}

# Package Lambda functions
data "archive_file" "lambda_zip" {
  for_each = var.functions

  type        = "zip"
  output_path = "${path.root}/.terraform/archive/${each.key}.zip"
  source_dir  = "${local.repo_path}/${each.value.source_dir}"

  depends_on = [null_resource.git_clone, null_resource.build]
}

# Build functions if build command is specified
resource "null_resource" "build" {
  for_each = {
    for k, v in var.functions : k => v
    if v.build_command != ""
  }

  triggers = {
    source_code_hash = sha256(join("", [for f in fileset("${local.repo_path}/${each.value.source_dir}", "**") : filesha256("${local.repo_path}/${each.value.source_dir}/${f}")]))
  }

  provisioner "local-exec" {
    command     = each.value.build_command
    working_dir = "${local.repo_path}/${each.value.source_dir}"
  }

  depends_on = [null_resource.git_clone]
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