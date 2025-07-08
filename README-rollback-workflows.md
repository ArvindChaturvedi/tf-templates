# Rollback Workflows Documentation

This repository contains two GitHub Actions workflows for managing application rollbacks using ECR image tags.

## Workflows Overview

### 1. ECR Image Discovery Workflow (`ecr-image-discovery.yaml`)

**Purpose**: Discovers and updates available image tags from AWS ECR repositories.

**Features**:
- Queries ECR repositories for all available image tags
- Updates `release-metadata.yaml` with discovered tags
- Supports both manual trigger and scheduled runs (daily at 2 AM UTC)
- Can target specific applications or discover all configured apps
- Sends Slack notifications on completion

**Trigger**:
- **Manual**: Via GitHub Actions UI with optional app name
- **Scheduled**: Daily at 2 AM UTC to keep metadata current

**Inputs**:
- `APP_NAME` (optional): Specific application to discover (leave empty for all)
- `AWS_ACCESS_KEY_ID`: AWS credentials
- `AWS_SECRET_ACCESS_KEY`: AWS credentials
- `AWS_SESSION_TOKEN` (optional): AWS session token
- `AWS_REGION`: AWS region (default: us-east-1)
- `ECR_REGISTRY`: ECR registry URL

### 2. Rollback Deployment Workflow (`rollback-deployment.yaml`)

**Purpose**: Performs immediate rollback to a specific ECR image tag.

**Features**:
- Validates rollback request against available tags
- Updates Helm values.yaml with target image tag
- Syncs ArgoCD application
- Performs immediate rollback using Argo Rollouts (no canary)
- Updates `release-metadata.yaml` with new current tag
- Sends Slack notifications on success/failure

**Trigger**: Manual via GitHub Actions UI

**Inputs**:
- `APP_NAME`: Application to rollback (dropdown: app1, app2)
- `TARGET_IMAGE_TAG`: Target image tag (populated from release-metadata.yaml)
- `ENV`: Environment (dropdown: feature, staging, prod)
- `AWS_ACCESS_KEY_ID`: AWS credentials
- `AWS_SECRET_ACCESS_KEY`: AWS credentials
- `AWS_SESSION_TOKEN` (optional): AWS session token
- `AWS_REGION`: AWS region (default: us-east-1)
- `ROLLBACK_REASON`: Optional reason for rollback

## File Structure

```
├── .github/workflows/
│   ├── ecr-image-discovery.yaml      # ECR image discovery workflow
│   ├── rollback-deployment.yaml      # Rollback deployment workflow
│   └── new-cd.yaml                   # Original CD workflow
├── release-metadata.yaml             # ECR image metadata (auto-updated)
├── charts/app1/values.yaml           # Helm values for app1
└── README-rollback-workflows.md      # This documentation
```

## Configuration

### 1. Update Applications List

In `ecr-image-discovery.yaml`, update the `APPS` array to include your applications:

```yaml
APPS=("app1" "app2" "app3")  # Add your application names
```

### 2. Configure AWS Credentials

Set up the following secrets in your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN` (optional)
- `SLACK_WEBHOOK_URL` (for notifications)

### 3. Update ECR Registry

Update the default ECR registry URL in both workflows:
```yaml
ECR_REGISTRY: 'your-account.dkr.ecr.us-east-1.amazonaws.com'
```

### 4. Update Helm Chart Paths

In `rollback-deployment.yaml`, update the Helm values path for your applications:
```yaml
# For app1
yq e -i '.app1.image.tag = "$TARGET_IMAGE_TAG"' charts/app1/values.yaml

# For app2 (add similar lines)
yq e -i '.app2.image.tag = "$TARGET_IMAGE_TAG"' charts/app2/values.yaml
```

## Usage

### Step 1: Discover ECR Images

1. Go to GitHub Actions → ECR Image Discovery
2. Click "Run workflow"
3. Fill in AWS credentials and optional app name
4. Run the workflow

This will update `release-metadata.yaml` with all available image tags.

### Step 2: Perform Rollback

1. Go to GitHub Actions → Rollback Deployment
2. Click "Run workflow"
3. Select:
   - Application name
   - Target image tag (populated from metadata)
   - Environment
   - AWS credentials
   - Optional rollback reason
4. Run the workflow

## Workflow Process

### ECR Image Discovery Process:
1. Authenticates with AWS ECR
2. Queries each configured ECR repository
3. Extracts all available image tags
4. Updates `release-metadata.yaml` with discovered tags
5. Commits and pushes changes
6. Sends Slack notification

### Rollback Process:
1. Validates rollback request against available tags
2. Updates Helm values.yaml with target image tag
3. Commits and pushes changes
4. Syncs ArgoCD application
5. Performs immediate rollback using Argo Rollouts
6. Updates metadata with new current tag
7. Sends Slack notification

## Security Considerations

- AWS credentials are passed as workflow inputs or secrets
- Workflow uses least privilege principle for ECR access
- All changes are tracked in Git history
- Rollback operations are logged and notified

## Troubleshooting

### Common Issues:

1. **ECR Repository Not Found**
   - Verify repository exists in specified AWS region
   - Check AWS credentials and permissions

2. **ArgoCD Sync Fails**
   - Verify ArgoCD application exists
   - Check cluster connectivity and permissions

3. **Rollout Not Found**
   - Ensure Argo Rollouts are installed in the cluster
   - Verify namespace and rollout name

4. **Image Tag Not Available**
   - Run ECR Image Discovery workflow first
   - Check if tag exists in ECR repository

### Logs and Debugging:
- Check workflow logs in GitHub Actions
- Verify `release-metadata.yaml` content
- Check ArgoCD application status
- Monitor Argo Rollouts status in cluster

## Extending the Workflows

### Adding New Applications:
1. Add application name to `APPS` array in discovery workflow
2. Add application choice in rollback workflow inputs
3. Add Helm values update logic for new app
4. Update documentation

### Custom Notifications:
- Modify Slack notification payloads
- Add additional notification channels
- Customize notification content

### Additional Validation:
- Add image compatibility checks
- Implement rollback approval gates
- Add environment-specific validations 