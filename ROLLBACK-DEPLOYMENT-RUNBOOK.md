# Rollback Deployment Runbook

This runbook describes how to use the `rollback-deployment.yaml` GitHub Actions workflow to perform an immediate rollback of an application to a specific ECR image tag in a Kubernetes environment managed by ArgoCD and Argo Rollouts.

---

## Overview

The **Rollback Deployment** workflow enables engineers to quickly revert an application deployment to a previous container image version. It updates the Helm chart, syncs the ArgoCD application, and performs an immediate rollback using Argo Rollouts. Slack notifications are sent on success or failure.

---

## Prerequisites

- You must have access to the GitHub repository and permission to run workflows.
- AWS credentials (with EKS, ECR, and ArgoCD access) must be available as GitHub secrets or provided as workflow inputs.
- The target image tag must exist in ECR and be valid for the application.
- The ArgoCD application and rollout must be correctly configured in the target environment.

---

## Input Parameters

When triggering the workflow manually, you will be prompted for the following inputs:

| Name                   | Description                                 | Required | Options/Example                |
|------------------------|---------------------------------------------|----------|-------------------------------|
| APP_NAME               | Application to rollback                     | Yes      | app1, app2                    |
| TARGET_IMAGE_TAG       | Target image tag to rollback to             | Yes      | e.g., v1.2.3                  |
| ENV                    | Environment to rollback                     | Yes      | feature, staging, prod        |
| AWS_ACCESS_KEY_ID      | AWS Access Key ID                           | Yes      |                               |
| AWS_SECRET_ACCESS_KEY  | AWS Secret Access Key                       | Yes      |                               |
| AWS_SESSION_TOKEN      | AWS Session Token                           | No       |                               |
| AWS_REGION             | AWS Region                                  | Yes      | us-east-1 (default)           |
| ROLLBACK_REASON        | Reason for rollback (for audit/logging)     | No       | Free text                     |

---

## Step-by-Step Usage

1. **Navigate to GitHub Actions**
   - Go to your repository on GitHub.
   - Click on the "Actions" tab.

2. **Select the Rollback Deployment Workflow**
   - Find and select `Rollback Deployment` in the list of workflows.

3. **Trigger the Workflow**
   - Click "Run workflow".
   - Fill in the required input fields:
     - Select the application (`app1` or `app2`).
     - Enter the target image tag (must exist in ECR).
     - Choose the environment (`feature`, `staging`, or `prod`).
     - Provide AWS credentials (can use repository secrets).
     - Optionally, provide a rollback reason.
   - Click "Run workflow" to start the rollback.

4. **Monitor Progress**
   - The workflow will:
     1. Update the Helm values.yaml for the selected app with the target image tag.
     2. Commit and push the change to the repository.
     3. Sync the ArgoCD application and wait for it to become healthy.
     4. Perform an immediate rollback using Argo Rollouts.
     5. Wait for the rollout to complete and verify status.
     6. Send a Slack notification on success or failure.
   - You can monitor each step in the Actions log.

---

## Workflow Process (Technical Details)

1. **Checkout repository**
2. **Set up AWS credentials**
3. **Update kubeconfig for EKS cluster**
4. **Install yq and kubectl-argo-rollouts**
5. **Get rollout name from cluster**
6. **Update Helm values.yaml with target image tag**
7. **Commit and push updated values**
8. **Sync ArgoCD Application**
9. **Perform immediate rollback using Argo Rollouts**
10. **Wait for rollback completion**
11. **Verify rollback success**
12. **Send Slack notification (success or failure)**

---

## Troubleshooting

- **ECR Image Tag Not Found**: Ensure the target image tag exists in ECR. Run the image discovery workflow if needed.
- **ArgoCD Sync Fails**: Check ArgoCD application status and cluster connectivity.
- **Rollout Not Found**: Verify the rollout exists in the correct namespace and the app name is correct.
- **AWS Authentication Issues**: Double-check AWS credentials and permissions.
- **Helm values.yaml Not Updated**: Ensure the workflow has write access to the repository and the correct path is used for the app.
- **Slack Notification Not Sent**: Check that the `SLACK_WEBHOOK_URL` secret is set in the repository.

---

## Security Notes

- AWS credentials should be provided securely via GitHub secrets or workflow inputs.
- All rollback actions are logged in GitHub Actions and Git history.
- Only authorized users should be allowed to trigger rollbacks.
- Slack notifications provide audit trail for rollback events.

---

## References
- [rollback-deployment.yaml](.github/workflows/rollback-deployment.yaml)
- [Argo Rollouts Documentation](https://argoproj.github.io/argo-rollouts/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/) 