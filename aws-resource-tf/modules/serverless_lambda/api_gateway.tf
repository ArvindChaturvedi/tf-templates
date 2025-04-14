# Create API Gateway if any function has API Gateway enabled
resource "aws_apigatewayv2_api" "this" {
  count = length([for f in var.functions : f if f.api_gateway != null]) > 0 ? 1 : 0

  name          = "${var.name_prefix}-api"
  protocol_type = "HTTP"
  description   = "API Gateway for ${var.name_prefix} Lambda functions"

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
    max_age      = 300
  }

  tags = local.common_tags
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "this" {
  count = length([for f in var.functions : f if f.api_gateway != null]) > 0 ? 1 : 0

  api_id = aws_apigatewayv2_api.this[0].id
  name   = var.api_gateway_stage_name

  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseTime  = "$context.responseLatency"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  tags = local.common_tags
}

# CloudWatch log group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  count = length([for f in var.functions : f if f.api_gateway != null]) > 0 ? 1 : 0

  name              = "/aws/api_gateway/${var.name_prefix}"
  retention_in_days = 14

  tags = local.common_tags
}

# Create API Gateway integrations and routes for each function with API Gateway enabled
resource "aws_apigatewayv2_integration" "lambda" {
  for_each = {
    for k, v in var.functions : k => v
    if v.api_gateway != null
  }

  api_id = aws_apigatewayv2_api.this[0].id

  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.this[each.key].invoke_arn

  payload_format_version = "2.0"
  timeout_milliseconds   = each.value.timeout * 1000

  depends_on = [aws_apigatewayv2_api.this]
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = {
    for k, v in var.functions : k => v
    if v.api_gateway != null
  }

  api_id = aws_apigatewayv2_api.this[0].id
  route_key = "${each.value.api_gateway.http_method} ${each.value.api_gateway.path}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"

  dynamic "authorization_config" {
    for_each = each.value.api_gateway.authorizer_enabled ? [1] : []
    content {
      authorizer_type = each.value.api_gateway.authorizer_type
      authorizer_id   = aws_apigatewayv2_authorizer.this[0].id
    }
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  for_each = {
    for k, v in var.functions : k => v
    if v.api_gateway != null
  }

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

# Optional JWT Authorizer
resource "aws_apigatewayv2_authorizer" "this" {
  count = length([for f in var.functions : f if f.api_gateway != null && f.api_gateway.authorizer_enabled]) > 0 ? 1 : 0

  api_id           = aws_apigatewayv2_api.this[0].id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name            = "${var.name_prefix}-authorizer"

  jwt_configuration {
    audience = ["your-audience"]
    issuer   = "https://your-issuer"
  }
} 