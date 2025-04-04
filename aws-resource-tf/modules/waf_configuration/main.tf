# WAF Configuration Module
# This module creates and manages WAF and WAF rules for ALBs

# Create a WAF Web ACL for the ALB
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.name}-web-acl"
  description = "WAF Web ACL for ${var.name}"
  scope       = var.scope

  default_action {
    allow {}
  }

  # AWS Managed Rule Sets
  dynamic "rule" {
    for_each = var.enable_aws_managed_rules ? [1] : []
    content {
      name     = "AWS-AWSManagedRulesCommonRuleSet"
      priority = 0

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  # SQL Injection Protection
  dynamic "rule" {
    for_each = var.enable_sql_injection_protection ? [1] : []
    content {
      name     = "AWS-AWSManagedRulesSQLiRuleSet"
      priority = 1

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesSQLiRuleSet"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate Limiting Rule
  dynamic "rule" {
    for_each = var.enable_rate_limiting ? [1] : []
    content {
      name     = "RateLimitRule"
      priority = 2

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimitRule"
        sampled_requests_enabled   = true
      }
    }
  }

  # IP Blocking Rule
  dynamic "rule" {
    for_each = length(var.blocked_ip_addresses) > 0 ? [1] : []
    content {
      name     = "IPBlockRule"
      priority = 3

      action {
        block {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.blocked_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "IPBlockRule"
        sampled_requests_enabled   = true
      }
    }
  }

  # IP Allowlist Rule
  dynamic "rule" {
    for_each = var.enable_whitelist_rule && length(var.allowed_ip_addresses) > 0 ? [1] : []
    content {
      name     = "IPAllowRule"
      priority = 4

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowed_ips[0].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "IPAllowRule"
        sampled_requests_enabled   = true
      }
    }
  }

  # Custom rules from variables
  dynamic "rule" {
    for_each = var.custom_rules
    content {
      name     = rule.value.name
      priority = 10 + rule.key # Ensure custom rules start after built-in rules

      dynamic "action" {
        for_each = rule.value.action == "block" ? [1] : []
        content {
          block {}
        }
      }

      dynamic "action" {
        for_each = rule.value.action == "allow" ? [1] : []
        content {
          allow {}
        }
      }

      dynamic "action" {
        for_each = rule.value.action == "count" ? [1] : []
        content {
          count {}
        }
      }

      statement {
        byte_match_statement {
          field_to_match {
            uri_path {}
          }
          positional_constraint = rule.value.positional_constraint
          search_string         = rule.value.search_string
          text_transformations {
            priority = 0
            type     = "NONE"
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-web-acl-metric"
    sampled_requests_enabled   = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-web-acl"
    }
  )
}

# Create IP Set for blocked IPs
resource "aws_wafv2_ip_set" "blocked_ips" {
  count = length(var.blocked_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name}-blocked-ips"
  description        = "Blocked IP addresses for ${var.name}"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_addresses

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-blocked-ips"
    }
  )
}

# Create IP Set for allowed IPs
resource "aws_wafv2_ip_set" "allowed_ips" {
  count = var.enable_whitelist_rule && length(var.allowed_ip_addresses) > 0 ? 1 : 0

  name               = "${var.name}-allowed-ips"
  description        = "Allowed IP addresses for ${var.name}"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_addresses

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-allowed-ips"
    }
  )
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "alb_association" {
  count = var.alb_arn != "" ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# Create a logging configuration for WAF if enabled
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  count = var.enable_logging && var.log_destination_arn != "" ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.main.arn
  log_destination_configs = [var.log_destination_arn]

  dynamic "redacted_fields" {
    for_each = var.redacted_fields

    content {
      dynamic "single_header" {
        for_each = redacted_fields.value.type == "header" ? [1] : []
        content {
          name = redacted_fields.value.name
        }
      }

      dynamic "method" {
        for_each = redacted_fields.value.type == "method" ? [1] : []
        content {}
      }

      dynamic "uri_path" {
        for_each = redacted_fields.value.type == "uri_path" ? [1] : []
        content {}
      }

      dynamic "query_string" {
        for_each = redacted_fields.value.type == "query_string" ? [1] : []
        content {}
      }
    }
  }
}