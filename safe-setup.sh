#!/bin/bash

# Safe ArgoCD Service Account Setup Script
# This script makes minimal changes and tracks what it creates for safe cleanup

set -e

ARGOCD_SERVER="argocd.company.com"  # Your FQDN
SERVICE_ACCOUNT_NAME="github-actions"
NAMESPACE="argocd"
INSECURE="false"  # Set to true if using self-signed certs
SETUP_LOG="argocd-setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$SETUP_LOG"
}

echo -e "${BLUE}Safe ArgoCD Service Account Setup Script${NC}"
echo "=================================================="
echo "This script will:"
echo "- Create ArgoCD service account: $SERVICE_ACCOUNT_NAME"
echo "- Add minimal RBAC entries (preserving existing ones)"
echo "- Create Kubernetes ServiceAccount with limited permissions"
echo "- Track all changes in $SETUP_LOG"
echo ""

# Start logging
log_action "Starting ArgoCD service account setup"

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"

if ! command -v kubectl >/dev/null 2>&1; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

if ! command -v argocd >/dev/null 2>&1; then
    echo "Installing ArgoCD CLI..."
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
    log_action "Installed ArgoCD CLI"
fi

# Step 2: Login to ArgoCD
echo -e "${YELLOW}Step 2: ArgoCD Authentication...${NC}"
if ! argocd account get-user-info >/dev/null 2>&1; then
    echo "Please login to ArgoCD first using your SAML credentials:"
    if [ "$INSECURE" == "true" ]; then
        echo "argocd login $ARGOCD_SERVER --insecure"
    else
        echo "argocd login $ARGOCD_SERVER"
    fi
    echo "Press Enter when logged in..."
    read -r
fi

# Step 3: Backup existing RBAC configuration
echo -e "${YELLOW}Step 3: Backing up existing RBAC configuration...${NC}"
if kubectl get configmap argocd-rbac-cm -n $NAMESPACE >/dev/null 2>&1; then
    kubectl get configmap argocd-rbac-cm -n $NAMESPACE -o yaml > argocd-rbac-cm-original-backup.yaml
    echo -e "${GREEN}✓ Created backup: argocd-rbac-cm-original-backup.yaml${NC}"
    log_action "Created backup of original RBAC configuration"
else
    echo -e "${YELLOW}⚠ No existing RBAC ConfigMap found${NC}"
fi

# Step 4: Create ArgoCD service account
echo -e "${YELLOW}Step 4: Creating ArgoCD service account...${NC}"
if argocd account list | grep -q "^$SERVICE_ACCOUNT_NAME$"; then
    echo -e "${YELLOW}⚠ ArgoCD service account $SERVICE_ACCOUNT_NAME already exists${NC}"
else
    argocd account create $SERVICE_ACCOUNT_NAME
    echo -e "${GREEN}✓ Created ArgoCD service account: $SERVICE_ACCOUNT_NAME${NC}"
    log_action "Created ArgoCD service account: $SERVICE_ACCOUNT_NAME"
fi

# Step 5: Generate token
echo -e "${YELLOW}Step 5: Generating service account token...${NC}"
TOKEN=$(argocd account generate-token --account $SERVICE_ACCOUNT_NAME)
echo "$TOKEN" > service-account-token.txt
chmod 600 service-account-token.txt
echo -e "${GREEN}✓ Token generated and saved to service-account-token.txt${NC}"
log_action "Generated service account token"

# Step 6: Add RBAC entries (preserve existing ones)
echo -e "${YELLOW}Step 6: Adding RBAC entries...${NC}"
add_rbac_entries() {
    # Get existing policy
    EXISTING_POLICY=""
    if kubectl get configmap argocd-rbac-cm -n $NAMESPACE >/dev/null 2>&1; then
        EXISTING_POLICY=$(kubectl get configmap argocd-rbac-cm -n $NAMESPACE -o jsonpath='{.data.policy\.csv}' 2>/dev/null || echo "")
    fi
    
    # Our additional RBAC entries
    GITHUB_ACTIONS_RBAC="
# GitHub Actions service account permissions (added by setup script)
p, role:github-actions, applications, get, *, allow
p, role:github-actions, applications, sync, *, allow
p, role:github-actions, applications, refresh, *, allow
p, role:github-actions, applications, action/*, *, allow
p, role:github-actions, repositories, get, *, allow

# Assign role to service account
g, $SERVICE_ACCOUNT_NAME, role:github-actions"
    
    # Combine existing policy with our additions
    COMBINED_POLICY="$EXISTING_POLICY$GITHUB_ACTIONS_RBAC"
    
    # Create or update the ConfigMap
    if kubectl get configmap argocd-rbac-cm -n $NAMESPACE >/dev/null 2>&1; then
        # Update existing ConfigMap
        kubectl patch configmap argocd-rbac-cm -n $NAMESPACE --type='json' \
            -p="[{\"op\": \"replace\", \"path\": \"/data/policy.csv\", \"value\": \"$COMBINED_POLICY\"}]"
        echo -e "${GREEN}✓ Updated existing RBAC ConfigMap${NC}"
    else
        # Create new ConfigMap
        kubectl create configmap argocd-rbac-cm -n $NAMESPACE \
            --from-literal=policy.default=role:readonly \
            --from-literal=policy.csv="$COMBINED_POLICY"
        echo -e "${GREEN}✓ Created new RBAC ConfigMap${NC}"
    fi
    
    log_action "Added RBAC entries for GitHub Actions service account"
}

add_rbac_entries

# Step 7: Create Kubernetes ServiceAccount (separate from ArgoCD)
echo -e "${YELLOW}Step 7: Creating Kubernetes ServiceAccount...${NC}"

cat << EOF > k8s-service-account-github-actions.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-github-actions
  namespace: $NAMESPACE
  annotations:
    created-by: "argocd-setup-script"
    creation-date: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---
apiVersion: v1
kind: Secret
metadata:
  name: argocd-github-actions-token
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: argocd-github-actions
    created-by: "argocd-setup-script"
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argocd-github-actions
  annotations:
    created-by: "argocd-setup-script"
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
  annotations:
    created-by: "argocd-setup-script"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argocd-github-actions
subjects:
- kind: ServiceAccount
  name: argocd-github-actions
  namespace: $NAMESPACE
EOF

kubectl apply -f k8s-service-account-github-actions.yaml
echo -e "${GREEN}✓ Created Kubernetes ServiceAccount and RBAC${NC}"
log_action "Created Kubernetes ServiceAccount and RBAC resources"

# Step 8: Wait for token to be generated
echo -e "${YELLOW}Step 8: Waiting for Kubernetes token generation...${NC}"
sleep 5

# Get the Kubernetes service account token
if kubectl get secret argocd-github-actions-token -n $NAMESPACE >/dev/null 2>&1; then
    K8S_TOKEN=$(kubectl get secret argocd-github-actions-token -n $NAMESPACE -o jsonpath='{.data.token}' | base64 -d)
    echo "$K8S_TOKEN" > k8s-service-account-token.txt
    chmod 600 k8s-service-account-token.txt
    echo -e "${GREEN}✓ Kubernetes token saved to k8s-service-account-token.txt${NC}"
    log_action "Generated Kubernetes service account token"
else
    echo -e "${YELLOW}⚠ Kubernetes token not yet available${NC}"
fi

# Step 9: Test authentication
echo -e "${YELLOW}Step 9: Testing authentication...${NC}"
argocd logout >/dev/null 2>&1 || true

if [ "$INSECURE" == "true" ]; then
    argocd login $ARGOCD_SERVER --auth-token $TOKEN --insecure
else
    argocd login $ARGOCD_SERVER --auth-token $TOKEN
fi

argocd account get-user-info
echo -e "${GREEN}✓ Authentication test successful${NC}"
log_action "Authentication test successful"

# Step 10: Final summary
echo ""
echo "=================================================="
echo -e "${GREEN}Setup completed successfully!${NC}"
echo ""
echo "Files created:"
echo "- service-account-token.txt (ArgoCD service account token)"
echo "- k8s-service-account-token.txt (Kubernetes service account token)"
echo "- k8s-service-account-github-actions.yaml (Kubernetes resources)"
echo "- argocd-rbac-cm-original-backup.yaml (Original RBAC backup)"
echo "- $SETUP_LOG (Setup log)"
echo ""
echo -e "${YELLOW}GitHub Secrets to configure:${NC}"
echo "ARGOCD_AUTH_TOKEN: $(cat service-account-token.txt)"
echo ""
echo -e "${YELLOW}Resources created:${NC}"
echo "- ArgoCD service account: $SERVICE_ACCOUNT_NAME"
echo "- Kubernetes ServiceAccount: argocd-github-actions"
echo "- ClusterRole: argocd-github-actions"
echo "- ClusterRoleBinding: argocd-github-actions"
echo "- Secret: argocd-github-actions-token"
echo "- RBAC entries in argocd-rbac-cm (preserving existing ones)"
echo ""
echo -e "${GREEN}Setup complete! Use the cleanup script to remove only these additions.${NC}"

log_action "Setup completed successfully"
