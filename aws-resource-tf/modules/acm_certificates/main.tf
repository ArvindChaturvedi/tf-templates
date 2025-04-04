# ACM Certificates Module
# This module creates and manages ACM certificates for ALB

# Request a public certificate (for external ALB)
resource "aws_acm_certificate" "public" {
  count = var.create_public_certificate ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-cert"
    }
  )
}

# Request a private certificate (for internal ALB)
resource "aws_acm_certificate" "private" {
  count = var.create_private_certificate ? 1 : 0

  domain_name               = var.internal_domain_name
  subject_alternative_names = var.internal_subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-cert"
    }
  )
}

# Get Route53 zone for DNS validation (assumes the zone exists)
data "aws_route53_zone" "selected" {
  count = var.create_public_certificate && var.auto_validate_certificate && var.route53_zone_name != "" ? 1 : 0
  name  = var.route53_zone_name
}

# Create validation records in Route53 for public certificate
resource "aws_route53_record" "validation" {
  for_each = var.create_public_certificate && var.auto_validate_certificate && var.route53_zone_name != "" ? {
    for dvo in aws_acm_certificate.public[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected[0].zone_id
}

# Validate the certificate
resource "aws_acm_certificate_validation" "validation" {
  count = var.create_public_certificate && var.auto_validate_certificate && var.route53_zone_name != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.public[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

# Create DNS records for ALB (if applicable)
resource "aws_route53_record" "alb_record" {
  count = var.create_public_certificate && var.create_alb_dns_record && var.route53_zone_name != "" ? 1 : 0

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}