locals {
  # Use provided hosted zone ID or look it up by name
  hosted_zone_id = var.hosted_zone_id != "" ? var.hosted_zone_id : data.aws_route53_zone.selected[0].id
}

# Look up hosted zone by name if ID is not provided
data "aws_route53_zone" "selected" {
  count = var.create_route53_records && var.hosted_zone_id == "" ? 1 : 0
  name  = var.hosted_zone_name
}

# Create Route53 records
resource "aws_route53_record" "this" {
  for_each = var.create_route53_records ? var.records : {}

  zone_id = local.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.alias == null ? each.value.ttl : null

  # Use records or alias based on configuration
  dynamic "records" {
    for_each = each.value.alias == null ? each.value.records : []
    content {
      records = each.value.records
    }
  }

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id               = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
} 