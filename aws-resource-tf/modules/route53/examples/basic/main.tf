provider "aws" {
  region = "us-east-1"
}

module "route53" {
  source = "../../"

  create_route53_records = true
  hosted_zone_name      = "example.com"
  
  records = {
    "www" = {
      name    = "www.example.com"
      type    = "A"
      ttl     = 300
      records = ["192.168.1.1"]
    },
    "api" = {
      name    = "api.example.com"
      type    = "CNAME"
      ttl     = 300
      records = ["www.example.com"]
    },
    "elb" = {
      name = "app.example.com"
      type = "A"
      alias = {
        name                   = "my-load-balancer.region.elb.amazonaws.com"
        zone_id               = "Z35SXDOTRQ7X7K"
        evaluate_target_health = true
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
} 