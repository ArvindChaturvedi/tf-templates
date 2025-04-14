# Serverless Lambda Module for Terraform

This module provides a complete serverless deployment strategy for AWS Lambda functions using Terraform. It supports packaging Lambda functions with their dependencies, API Gateway integration, and includes monitoring and logging capabilities.

## Features

- 📦 Automatic Lambda function packaging with dependencies
- 🔄 Support for multiple runtime environments (Node.js, Python, etc.)
- 🌐 API Gateway integration with multiple endpoint types
- 📊 CloudWatch logging and monitoring
- 🔐 IAM role and policy management
- 🏷️ Resource tagging support
- 🔄 Versioning and alias management
- 🎯 Event source mappings (SQS, DynamoDB, etc.)

## Usage

```hcl
module "serverless_lambda" {
  source = "./modules/serverless_lambda"

  name_prefix = "my-app"
  environment = "dev"

  functions = {
    "api-handler" = {
      description = "API Handler Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      source_dir  = "./src/api-handler"
      
      environment_variables = {
        NODE_ENV = "production"
      }

      api_gateway = {
        enabled     = true
        http_method = "POST"
        path        = "/api/v1/handler"
      }

      timeout     = 30
      memory_size = 256
    }
  }

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

## Module Structure

```
serverless_lambda/
├── main.tf           # Main module configuration
├── variables.tf      # Input variables
├── outputs.tf        # Module outputs
├── versions.tf       # Provider version constraints
├── iam.tf           # IAM roles and policies
├── api_gateway.tf    # API Gateway configuration
├── templates/        # Template files
│   ├── api_policy.json.tpl
│   └── lambda_policy.json.tpl
└── examples/         # Example configurations
    ├── basic/
    ├── with-api-gateway/
    └── with-event-source/
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | string | - | yes |
| environment | Environment name (e.g., dev, prod) | string | - | yes |
| functions | Map of Lambda functions to create | map(object) | {} | yes |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Function Configuration

Each function in the `functions` map supports the following attributes:

```hcl
{
  description = string
  runtime     = string
  handler     = string
  source_dir  = string
  
  environment_variables = map(string)
  timeout              = number
  memory_size         = number
  
  api_gateway = {
    enabled     = bool
    http_method = string
    path        = string
  }
  
  vpc_config = {
    subnet_ids         = list(string)
    security_group_ids = list(string)
  }
  
  event_source = {
    type       = string
    source_arn = string
  }
}
```

## Deployment Strategy

1. **Function Packaging**:
   - Automatically packages function code and dependencies
   - Supports custom build commands (npm install, pip install)
   - Creates deployment packages as ZIP files

2. **Infrastructure Deployment**:
   - Creates Lambda functions with specified configurations
   - Sets up API Gateway if enabled
   - Configures IAM roles and policies
   - Sets up CloudWatch logging

3. **Versioning and Aliases**:
   - Creates function versions for each deployment
   - Manages aliases for different environments
   - Supports blue-green deployments

## Best Practices

1. **Function Organization**:
   - Keep functions small and focused
   - Use separate source directories for each function
   - Include only necessary dependencies

2. **Security**:
   - Use environment variables for sensitive data
   - Implement least privilege IAM policies
   - Enable VPC access only when needed

3. **Monitoring**:
   - Enable detailed CloudWatch logging
   - Set up appropriate alarms
   - Monitor function performance metrics

## Examples

### Basic Function
```hcl
module "basic_lambda" {
  source = "./modules/serverless_lambda"

  name_prefix = "basic"
  environment = "dev"

  functions = {
    "hello-world" = {
      description = "Basic Hello World Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      source_dir  = "./src/hello-world"
    }
  }
}
```

### With API Gateway
```hcl
module "api_lambda" {
  source = "./modules/serverless_lambda"

  name_prefix = "api"
  environment = "dev"

  functions = {
    "api-handler" = {
      description = "API Handler Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      source_dir  = "./src/api-handler"
      
      api_gateway = {
        enabled     = true
        http_method = "POST"
        path        = "/api/v1/handler"
      }
    }
  }
}
```

### With Event Source
```hcl
module "event_lambda" {
  source = "./modules/serverless_lambda"

  name_prefix = "event"
  environment = "dev"

  functions = {
    "queue-processor" = {
      description = "SQS Queue Processor"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      source_dir  = "./src/queue-processor"
      
      event_source = {
        type       = "sqs"
        source_arn = "arn:aws:sqs:region:account:queue-name"
      }
    }
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 