provider "aws" {
  region = "us-east-1"
}

module "serverless_lambda" {
  source = "../../modules/serverless_lambda"

  name_prefix = "example"
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

    "call-group-function" = {
      description = "Function to handle call group operations"
      runtime     = "python3.9"
      handler     = "call-group.handler"
      source_dir  = "functions/call-group"
      
      environment_variables = {
        SCRIPT_PATH = "/function-job-scripts/call-group.sh"
      }

      timeout     = 300  # 5 minutes
      memory_size = 256
    }

    "vacuum-analyse-function" = {
      description = "Function to handle vacuum and analyse operations"
      runtime     = "python3.9"
      handler     = "vacuum-analyse.handler"
      source_dir  = "functions/vacuum-analyse"
      
      environment_variables = {
        SCRIPT_PATH = "/function-job-scripts/vacuum-analyse.sh"
      }

      timeout     = 600  # 10 minutes
      memory_size = 512
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