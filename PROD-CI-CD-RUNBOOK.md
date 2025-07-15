# Production CI/CD Runbook

---

## Overview

This runbook describes the end-to-end process for building, releasing, and deploying the production version of the application using GitHub Actions CI/CD workflows. It covers:

- CI: Tagging, release notes, Docker image build, and Helm metadata update.
- CD: Promotion and deployment to production Kubernetes clusters using Argo Rollouts and Helm.

---

## 1. CI: Production Build & Release

### Trigger

- **Manually via GitHub Actions:**  
  Go to **Actions** tab → **Production Release** workflow → **Run workflow**.
- **Input required:**  
  - `version` (e.g., `1.2.3`)

### Workflow Steps

#### a. Tag & Release Creation

- The workflow calls `.github/workflows/new-ci.yaml` as a reusable workflow.
- It:
  - Creates a tag `v<version>` (e.g., `v1.2.3`) on the current branch.
  - Generates release notes (including commit history, SHA, branch, date).
  - Publishes a GitHub Release with the tag and notes.

#### b. Docker Image Build & Push

- The workflow:
  - Builds the Docker image from the repository.
  - Tags the image as `<ECR_REPO>:v<version>`.
  - Pushes the image to Amazon ECR.

#### c. Helm Chart Metadata Update

- The workflow:
  - Clones the `helm-k8s-chart` repository.
  - Updates `app-release-metadata.yaml` with the new version and tag.
  - Commits and pushes the change to the chart repository.

#### d. Artifacts & Notifications

- Release notes are attached to the GitHub Release.
- (Optional) Notifications can be sent to Slack or other channels.

---

### Success Criteria

- A new GitHub Release is visible with the correct tag and release notes.
- The Docker image is available in ECR with the correct tag.
- The Helm chart metadata is updated in the chart repository.

---

### Troubleshooting

- **Tag not visible in GitHub UI:**  
  Ensure the tag is created and pushed to origin. Check workflow logs for tag creation and push steps.
- **Docker image not in ECR:**  
  Check AWS credentials and ECR permissions. Review build and push logs.
- **Helm metadata not updated:**  
  Ensure the workflow has push access to the chart repo. Check for errors in the `yq` or git steps.

---

## 2. CD: Production Deployment

### Trigger

- **Manually via GitHub Actions:**  
  Go to **Actions** tab → **CD Deploy - Feature Branch** (or equivalent production deploy workflow) → **Run workflow**.
- **Input required:**
  - `APP_NAME` (e.g., `app1`)
  - `ENV` (should be `prod` for production)
  - AWS credentials and region

### Workflow Steps

#### a. Detect Changes

- Compares the latest and last successful versions in `app-release-metadata.yaml` and `helm-release-metadata.yaml`.
- Determines if a new image or chart version needs to be deployed.

#### b. Deploy to Kubernetes (Argo Rollouts)

- Updates the Kubernetes cluster context using AWS EKS.
- Patches Helm values and Chart.yaml with the new image and chart versions.
- Commits and pushes these changes if needed.

#### c. Progressive Rollout

- **30% Traffic:**  
  - Deploys to 30% of users.
  - Waits for rollout to be ready and paused.
- **Manual Approval:**  
  - Waits for approval to continue to 60%.
- **60% Traffic:**  
  - Promotes rollout to 60%.
  - Waits for rollout to be ready and paused.
- **Manual Approval:**  
  - Waits for approval to continue to 100%.
- **100% Traffic:**  
  - Promotes rollout to 100%.

#### d. Rollback (if needed)

- If any deploy or approval step fails or is rejected, the workflow triggers a rollback:
  - Reverts to the last successful image and chart version.
  - Updates metadata and redeploys.
  - Notifies via Slack (if configured).

#### e. Wiki Update (optional)

- Appends a deployment record to the GitHub Wiki with:
  - Time, app, environment, user, and status.

---

### Success Criteria

- The new version is running in production at 100% traffic.
- Rollout is healthy and not paused.
- All changes are reflected in the cluster and Helm chart repo.
- Deployment is logged in the Wiki (if enabled).

---

### Troubleshooting

- **Rollout stuck/paused:**  
  Check Argo Rollouts status and logs. Look for failed pods or unhealthy states.
- **Manual approval not working:**  
  Ensure the approval action is correctly configured and approvers are available.
- **Rollback not triggered:**  
  Confirm the `if` condition in the rollback job covers all failure/cancellation cases.
- **AWS/EKS errors:**  
  Validate credentials, cluster name, and region.

---

## 3. Best Practices

- Always use annotated tags for releases.
- Use `fetch-depth: 0` in all `actions/checkout` steps to ensure full git history and tags.
- Use the GitHub CLI or API to fetch the latest tags/releases for reliability.
- Store all secrets (AWS, PAT for wiki, etc.) in GitHub Secrets.
- Monitor workflow runs and set up notifications for failures.

---

## 4. References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Argo Rollouts Documentation](https://argoproj.github.io/argo-rollouts/)
- [Amazon ECR Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [Helm Documentation](https://helm.sh/docs/)

---

## 5. Example: Manual Production Release

1. Go to **Actions** → **Production Release**.
2. Click **Run workflow**.
3. Enter the desired version (e.g., `1.2.3`).
4. Monitor the workflow for completion.
5. Confirm:
   - GitHub Release is created.
   - Docker image is in ECR.
   - Helm chart metadata is updated.
6. Trigger the **CD Deploy** workflow for production.
7. Approve progressive rollout steps as needed.
8. Confirm deployment in the cluster and in the Wiki.

---

**For any issues, review the workflow logs, check the referenced documentation, and escalate to the DevOps team if needed.** 