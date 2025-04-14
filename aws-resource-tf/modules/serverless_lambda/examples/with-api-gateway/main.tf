provider "aws" {
  region = "us-east-1"
}

module "api_lambda" {
  source = "../../"

  name_prefix = "api-example"
  environment = "dev"

  functions = {
    "hello-world" = {
      description = "Hello World API Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      source_dir  = "${path.module}/src/hello-world"
      
      environment_variables = {
        NODE_ENV = "production"
      }

      api_gateway = {
        enabled     = true
        http_method = "GET"
        path        = "/hello"
        cors_enabled = true
      }

      timeout     = 30
      memory_size = 128
    }

    "users-api" = {
      description = "Users API Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      source_dir  = "${path.module}/src/users-api"
      
      environment_variables = {
        NODE_ENV = "production"
        TABLE_NAME = "users"
      }

      api_gateway = {
        enabled     = true
        http_method = "POST"
        path        = "/users"
        cors_enabled = true
        authorizer_enabled = true
      }

      vpc_config = {
        subnet_ids         = ["subnet-12345678", "subnet-87654321"]
        security_group_ids = ["sg-12345678"]
      }

      timeout     = 60
      memory_size = 256
    }
  }

  enable_xray = true
  enable_cloudwatch_alarms = true
  
  alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alerts"]

  common_environment_variables = {
    STAGE = "dev"
    REGION = "us-east-1"
  }

  tags = {
    Project = "API Example"
    Owner   = "DevOps"
  }
} 