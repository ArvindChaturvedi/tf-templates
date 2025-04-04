# Basic AWS Terraform Example

This is a simple example of using Terraform to create basic AWS resources. It's intended as a starting point to demonstrate the usage of variables, providers, resources, and outputs.

## Resources Created

- AWS KMS Key for encryption
- AWS KMS Alias for the key
- AWS Security Group for PostgreSQL access in an existing VPC

## Prerequisites

- Terraform >= 1.0.0
- AWS credentials configured
- **Existing VPC and subnet infrastructure**

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan -var="existing_vpc_id=vpc-your-actual-vpc-id"
   ```

3. Apply the configuration:
   ```bash
   terraform apply -var="existing_vpc_id=vpc-your-actual-vpc-id"
   ```

4. Destroy resources when finished:
   ```bash
   terraform destroy -var="existing_vpc_id=vpc-your-actual-vpc-id"
   ```

## Customization

You can customize the deployment by modifying the `terraform.tfvars` file or by providing variable values at the command line:

```bash
terraform apply -var="environment=staging" -var="project_name=aurora-demo" -var="existing_vpc_id=vpc-your-actual-vpc-id"
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| aws_region | AWS region to deploy resources | us-east-1 |
| environment | Environment name (e.g., dev, staging, prod) | dev |
| project_name | Name of the project | demo |
| owner | Owner of the resources (team or individual) | terraform-user |
| existing_vpc_id | ID of the existing VPC to use (required) | vpc-12345678 (mock) |

## Important Note

The default VPC ID in this example is a placeholder and must be replaced with a real VPC ID in a production environment. This example demonstrates the approach of working with existing network infrastructure rather than creating new VPC resources.

## Outputs

| Name | Description |
|------|-------------|
| environment | The environment in which resources are deployed |
| project_name | The name of the project |
| resource_prefix | The prefix used for resource naming |
| owner | The owner of the resources |
| kms_key_id | The ID of the KMS key |
| kms_key_arn | The ARN of the KMS key |
| security_group_id | The ID of the security group |
