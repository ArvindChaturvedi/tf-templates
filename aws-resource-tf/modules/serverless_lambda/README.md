# Serverless Lambda Module

This Terraform module manages the deployment of serverless Lambda functions from a Git repository. It supports multiple functions with different runtimes, automatic packaging, CloudWatch logging, and monitoring.

## Features

- Deploy Lambda functions from a Git repository
- Support for multiple runtimes (Python, Node.js, etc.)
- Automatic packaging and deployment
- CloudWatch logging and alarms
- X-Ray tracing support
- Function versioning and aliases
- Event source mappings (SQS, DynamoDB, etc.)
- Custom build commands and dependencies

## Usage

```hcl
module "serverless_lambda" {
  source = "./modules/serverless_lambda"

  name_prefix = "my-project"
  environment = "dev"

  git_repository_url    = "https://github.com/your-org/your-lambda-repo.git"
  git_repository_branch = "main"
  git_repository_token  = ""  # For private repositories

  functions = {
    "my-lambda-function" = {
      description = "Example Lambda function"
      runtime     = "python3.9"
      handler     = "my-lambda.handler"
      source_dir  = "functions/my-lambda-functions"
      
      environment_variables = {
        ENV = "dev"
      }

      build_command = "pip install -r requirements.txt -t ."
      timeout     = 30
      memory_size = 128
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
    Project = "Example"
    Owner   = "DevOps"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| environment | Environment name (e.g., dev, prod) | `string` | n/a | yes |
| git_repository_url | URL of the Git repository containing Lambda functions | `string` | n/a | yes |
| git_repository_branch | Branch of the Git repository to use | `string` | `"main"` | no |
| git_repository_token | Personal access token for private Git repositories | `string` | `""` | no |
| functions | Map of Lambda functions to create | `map(object)` | `{}` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| enable_xray | Enable X-Ray tracing | `bool` | `false` | no |
| enable_cloudwatch_alarms | Enable CloudWatch alarms for Lambda functions | `bool` | `true` | no |
| alarm_actions | List of ARNs to notify when alarms trigger | `list(string)` | `[]` | no |
| common_environment_variables | Environment variables to add to all functions | `map(string)` | `{}` | no |
| lambda_role_permissions_boundary | ARN of IAM policy to use as permissions boundary for Lambda roles | `string` | `null` | no |
| enable_versioning | Enable function versioning | `bool` | `true` | no |
| create_alias | Create an alias for the Lambda function | `bool` | `true` | no |
| alias_name | Name of the alias to create | `string` | `"current"` | no |

### Function Configuration

Each function in the `functions` map can have the following attributes:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| description | Description of the Lambda function | `string` | n/a | yes |
| runtime | Runtime for the Lambda function | `string` | n/a | yes |
| handler | Handler for the Lambda function | `string` | n/a | yes |
| source_dir | Directory in the Git repository containing the function code | `string` | n/a | yes |
| environment_variables | Environment variables for the function | `map(string)` | `{}` | no |
| timeout | Timeout for the Lambda function in seconds | `number` | `30` | no |
| memory_size | Memory size for the Lambda function in MB | `number` | `128` | no |
| vpc_config | VPC configuration for the Lambda function | `object` | `null` | no |
| event_source | Event source configuration for the Lambda function | `object` | `null` | no |
| layers | Lambda layers to attach to the function | `list(string)` | `[]` | no |
| build_command | Command to build the function | `string` | `""` | no |
| runtime_dependencies | Runtime dependencies for the function | `list(string)` | `[]` | no |
| log_retention_days | Number of days to retain logs | `number` | `14` | no |
| reserved_concurrent_executions | Reserved concurrent executions | `number` | `-1` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_names | Names of the Lambda functions |
| function_arns | ARNs of the Lambda functions |
| function_invoke_arns | Invoke ARNs of the Lambda functions |
| function_versions | Latest published version of the Lambda functions |
| function_aliases | ARNs of the Lambda function aliases |
| lambda_role_arn | ARN of the Lambda IAM role |
| lambda_role_name | Name of the Lambda IAM role |
| cloudwatch_log_groups | Names of the CloudWatch log groups |

## Repository Structure

The module expects your Git repository to have a structure similar to:

```
project-root/
  |-- functions/
    |-- my-lambda-functions/
      |-- my-lambda.py # Lambda function code
      |-- requirements.txt # (Optional Python dependencies)
    |-- call-group/
      |-- call-group.py
    |-- vacuum-analyse/
      |-- vacuum-analyse.py
  |-- function-job-scripts/
    |-- call-group.sh
    |-- vaccum-analyse.sh
```

## Notes

- The module will clone the Git repository during Terraform apply
- Functions are packaged and deployed from the cloned repository
- Build commands are executed in the function's source directory
- CloudWatch alarms are created for errors and throttles
- X-Ray tracing can be enabled for all functions 