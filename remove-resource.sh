#!/bin/bash

# ArgoCD Service Account Cleanup Script
# This script removes all resources created by the setup script

set -e

ARGOCD_SERVER="argocd.company.com"  # Your FQDN
SERVICE_ACCOUNT_NAME="github-actions"
NAMESPACE="argocd"
INSECURE="false"  # Set to true if using self-signed certs

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}ArgoCD Service Account Cleanup Script${NC}"
echo "=================================================="
echo "This script will remove the following resources:"
echo "- ArgoCD service account: $SERVICE_ACCOUNT_NAME"
echo "- RBAC policies and ConfigMap"
echo "- Kubernetes ServiceAccount and related resources"
echo "- Generated token files"
echo ""

# Confirmation prompt
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cleanup cancelled.${NC}"
    exit 1
fi

echo -e "${GREEN}Starting cleanup...${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to safely delete resources
safe_delete() {
    local resource_type=$1
    local resource_name=$2
    local namespace_flag=$3
    
    if kubectl get $resource_type $resource_name $namespace_flag >/dev/null 2>&1; then
        echo "Deleting $resource_type: $resource_name"
        kubectl delete $resource_type $resource_name $namespace_flag
        echo -e "${GREEN}✓ Deleted $resource_type: $resource_name${NC}"
    else
        echo -e "${YELLOW}⚠ $resource_type $resource_name not found, skipping...${NC}"
    fi
}

# Step 1: Check prerequisites
echo "Checking prerequisites..."

if ! command_exists kubectl; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

if ! command_exists argocd; then
    echo -e "${YELLOW}Warning: argocd CLI not found. Some cleanup steps will be skipped.${NC}"
    ARGOCD_CLI_AVAILABLE=false
else
    ARGOCD_CLI_AVAILABLE=true
fi

# Step 2: Check if currently logged into ArgoCD
if [ "$ARGOCD_CLI_AVAILABLE" = true ]; then
    echo "Checking ArgoCD authentication..."
    
    if ! argocd account get-user-info >/dev/null 2>&1; then
        echo -e "${YELLOW}Not logged into ArgoCD. Attempting to login...${NC}"
        echo "Please login to ArgoCD first to delete the service account:"
        echo "argocd login $ARGOCD_SERVER"
        echo ""
        read -p "Press Enter after logging in, or 's' to skip ArgoCD account deletion: " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            echo -e "${YELLOW}Skipping ArgoCD service account deletion${NC}"
            SKIP_ARGOCD_ACCOUNT=true
        else
            SKIP_ARGOCD_ACCOUNT=false
        fi
    else
        echo -e "${GREEN}✓ Logged into ArgoCD${NC}"
        SKIP_ARGOCD_ACCOUNT=false
    fi
else
    SKIP_ARGOCD_ACCOUNT=true
fi

# Step 3: Delete ArgoCD service account
if [ "$SKIP_ARGOCD_ACCOUNT" = false ]; then
    echo "Deleting ArgoCD service account..."
    
    # Check if service account exists
    if argocd account list | grep -q "$SERVICE_ACCOUNT_NAME"; then
        echo "Deleting ArgoCD service account: $SERVICE_ACCOUNT_NAME"
        argocd account delete $SERVICE_ACCOUNT_NAME
        echo -e "${GREEN}✓ Deleted ArgoCD service account: $SERVICE_ACCOUNT_NAME${NC}"
    else
        echo -e "${YELLOW}⚠ ArgoCD service account $SERVICE_ACCOUNT_NAME not found${NC}"
    fi
else
    echo -e "${YELLOW}Skipping ArgoCD service account deletion${NC}"
fi

# Step 4: Delete RBAC ConfigMap
echo "Deleting RBAC ConfigMap..."
safe_delete "configmap" "argocd-rbac-cm" "-n $NAMESPACE"

# Step 5: Delete Kubernetes ServiceAccount and related resources
echo "Deleting Kubernetes ServiceAccount resources..."

# Delete ClusterRoleBinding
safe_delete "clusterrolebinding" "argocd-github-actions" ""

# Delete ClusterRole
safe_delete "clusterrole" "argocd-github-actions" ""

# Delete Secret
safe_delete "secret" "argocd-github-actions-token" "-n $NAMESPACE"

# Delete ServiceAccount
safe_delete "serviceaccount" "argocd-github-actions" "-n $NAMESPACE"

# Step 6: Clean up generated files
echo "Cleaning up generated files..."

FILES_TO_DELETE=(
    "argocd-rbac-policy.yaml"
    "k8s-service-account.yaml"
    "argocd-linux-amd64"
    "service-account-token.txt"
    "setup.log"
)

for file in "${FILES_TO_DELETE[@]}"; do
    if [ -f "$file" ]; then
        echo "Deleting file: $file"
        rm -f "$file"
        echo -e "${GREEN}✓ Deleted file: $file${NC}"
    fi
done

# Step 7: Clean up any backup files
echo "Cleaning up backup files..."
find . -name "*.yaml.bak" -delete 2>/dev/null || true
find . -name "argocd-*.yaml" -delete 2>/dev/null || true

# Step 8: Optional - Reset ArgoCD RBAC to default
echo ""
read -p "Do you want to reset ArgoCD RBAC to default configuration? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Resetting ArgoCD RBAC to default..."
    
    cat << EOF > reset-rbac.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: $NAMESPACE
data:
  policy.default: role:readonly
  policy.csv: |
    # Default RBAC policy
    p, role:admin, applications, *, *, allow
    p, role:admin, clusters, *, *, allow
    p, role:admin, repositories, *, *, allow
    g, argocd-admins, role:admin
EOF
    
    kubectl apply -f reset-rbac.yaml
    rm -f reset-rbac.yaml
    echo -e "${GREEN}✓ Reset ArgoCD RBAC to default${NC}"
    
    # Restart ArgoCD server to apply changes
    echo "Restarting ArgoCD server to apply RBAC changes..."
    kubectl rollout restart deployment/argocd-server -n $NAMESPACE
    echo -e "${GREEN}✓ ArgoCD server restart initiated${NC}"
fi

# Step 9: Summary
echo ""
echo "=================================================="
echo -e "${GREEN}Cleanup completed successfully!${NC}"
echo ""
echo "Summary of actions taken:"
echo "- Deleted ArgoCD service account (if accessible)"
echo "- Removed RBAC policies and ConfigMap"
echo "- Deleted Kubernetes ServiceAccount and related resources"
echo "- Cleaned up generated files"
echo ""
echo -e "${YELLOW}Remember to:${NC}"
echo "1. Remove GitHub Secrets from your repository:"
echo "   - ARGOCD_AUTH_TOKEN"
echo "   - ARGOCD_K8S_TOKEN (if used)"
echo "2. Update your GitHub Actions workflows if needed"
echo "3. Verify ArgoCD is functioning properly after RBAC changes"
echo ""
echo -e "${GREEN}Cleanup script finished!${NC}"
