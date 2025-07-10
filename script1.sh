#!/bin/bash

# ArgoCD Service Account Setup Script for FQDN-exposed ArgoCD
# This script creates a service account for GitHub Actions to interact with ArgoCD
# Service account tokens bypass SAML authentication for API access

ARGOCD_SERVER="argocd.company.com"  # Your FQDN
SERVICE_ACCOUNT_NAME="github-actions"
NAMESPACE="argocd"
INSECURE="false"  # Set to true if using self-signed certs

echo "Setting up ArgoCD service account for GitHub Actions..."
echo "ArgoCD Server: $ARGOCD_SERVER"
echo "Service Account: $SERVICE_ACCOUNT_NAME"

# Check if ArgoCD CLI is available
if ! command -v argocd &> /dev/null; then
    echo "Installing ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
fi

# Step 1: Login to ArgoCD (you'll need to do this manually first with SAML)
echo "Please login to ArgoCD first using your SAML credentials:"
echo "argocd login $ARGOCD_SERVER"
echo "Press Enter when logged in..."
read -r

# Step 2: Create service account in ArgoCD
echo "Creating service account: $SERVICE_ACCOUNT_NAME"
argocd account create $SERVICE_ACCOUNT_NAME

# Step 2: Generate token for the service account
echo "Generating token for service account..."
TOKEN=$(argocd account generate-token --account $SERVICE_ACCOUNT_NAME)

echo "Service account token generated successfully!"
echo "This token bypasses SAML authentication for API access."

# Step 3: Test the token
echo "Testing service account authentication..."
argocd logout

if [ "$INSECURE" == "true" ]; then
    argocd login $ARGOCD_SERVER --auth-token $TOKEN --insecure
else
    argocd login $ARGOCD_SERVER --auth-token $TOKEN
fi

argocd account get-user-info

# Step 3: Create RBAC policy for the service account
echo "Creating RBAC policy..."

cat << EOF > argocd-rbac-policy.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: $NAMESPACE
data:
  policy.default: role:readonly
  policy.csv: |
    # GitHub Actions service account permissions
    p, role:github-actions, applications, get, *, allow
    p, role:github-actions, applications, sync, *, allow
    p, role:github-actions, applications, refresh, *, allow
    p, role:github-actions, applications, action/*, *, allow
    p, role:github-actions, repositories, get, *, allow
    p, role:github-actions, repositories, create, *, allow
    p, role:github-actions, repositories, update, *, allow
    p, role:github-actions, repositories, delete, *, allow
    
    # Assign role to service account
    g, $SERVICE_ACCOUNT_NAME, role:github-actions
EOF

# Step 4: Apply RBAC policy
echo "Applying RBAC policy..."
kubectl apply -f argocd-rbac-policy.yaml

# Step 5: Alternative method using Kubernetes ServiceAccount
echo "Creating Kubernetes ServiceAccount as alternative..."

cat << EOF > k8s-service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-github-actions
  namespace: $NAMESPACE
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-github-actions-token
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: argocd-github-actions
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argocd-github-actions
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list"]
- apiGroups: ["argoproj.io"]
  resources: ["applications", "appprojects"]
  verbs: ["get", "list", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-github-actions
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argocd-github-actions
subjects:
- kind: ServiceAccount
  name: argocd-github-actions
  namespace: $NAMESPACE
EOF

kubectl apply -f k8s-service-account.yaml

# Step 6: Get the service account token
echo "Getting Kubernetes service account token..."
K8S_TOKEN=$(kubectl get secret argocd-github-actions-token -n $NAMESPACE -o jsonpath='{.data.token}' | base64 -d)

echo "Setup complete!"
echo ""
echo "GitHub Secrets to configure:"
echo "- ARGOCD_AUTH_TOKEN: $TOKEN"
echo "- ARGOCD_K8S_TOKEN: $K8S_TOKEN"
echo ""
echo "Choose one of the authentication methods in your GitHub Actions workflow."
