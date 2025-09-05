#!/bin/bash

# EKS Node Group Upgrade History Checker
# This script finds all node group upgrades for a specific EKS cluster in 2025

set -e

# Configuration
CLUSTER_NAME=""
CURRENT_YEAR=$(date +%Y)
OUTPUT_FILE="eks_nodegroup_upgrades_${CURRENT_YEAR}.csv"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if required tools are installed
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured or invalid."
        exit 1
    fi
    
    print_success "Prerequisites check passed."
}

# Function to validate cluster exists
validate_cluster() {
    local cluster_name=$1
    print_info "Validating cluster: $cluster_name"
    
    if ! aws eks describe-cluster --name "$cluster_name" &> /dev/null; then
        print_error "Cluster '$cluster_name' not found or access denied."
        exit 1
    fi
    
    print_success "Cluster validation passed."
}

# Function to get all node groups for a cluster
get_nodegroups() {
    local cluster_name=$1
    print_info "Getting node groups for cluster: $cluster_name"
    
    local nodegroups
    nodegroups=$(aws eks list-nodegroups --cluster-name "$cluster_name" --query 'nodegroups[]' --output text)
    
    if [ -z "$nodegroups" ]; then
        print_warning "No node groups found for cluster: $cluster_name"
        return 1
    fi
    
    echo "$nodegroups"
}

# Function to check if date is in current year
is_current_year() {
    local date_string=$1
    local year
    year=$(echo "$date_string" | cut -d'-' -f1)
    
    if [ "$year" -eq "$CURRENT_YEAR" ]; then
        return 0
    else
        return 1
    fi
}

# Function to format date for better readability
format_date() {
    local iso_date=$1
    date -d "$iso_date" "+%Y-%m-%d %H:%M:%S UTC" 2>/dev/null || echo "$iso_date"
}

# Function to get updates for a specific node group
get_nodegroup_updates() {
    local cluster_name=$1
    local nodegroup_name=$2
    
    print_info "Checking updates for node group: $nodegroup_name"
    
    # Get list of update IDs
    local update_ids
    update_ids=$(aws eks list-updates --name "$cluster_name" --nodegroup-name "$nodegroup_name" --query 'updateIds[]' --output text 2>/dev/null)
    
    if [ -z "$update_ids" ]; then
        print_info "No updates found for node group: $nodegroup_name"
        return 0
    fi
    
    # Process each update ID
    for update_id in $update_ids; do
        print_info "Processing update ID: $update_id"
        
        # Get detailed update information
        local update_info
        update_info=$(aws eks describe-update --name "$cluster_name" --update-id "$update_id" --nodegroup-name "$nodegroup_name" 2>/dev/null)
        
        if [ $? -ne 0 ]; then
            print_warning "Failed to get details for update ID: $update_id"
            continue
        fi
        
        # Extract update details
        local created_at status update_type
        created_at=$(echo "$update_info" | jq -r '.update.createdAt')
        status=$(echo "$update_info" | jq -r '.update.status')
        update_type=$(echo "$update_info" | jq -r '.update.type')
        
        # Check if update is from current year
        if is_current_year "$created_at"; then
            local formatted_date
            formatted_date=$(format_date "$created_at")
            
            # Extract version information if available
            local version_info=""
            local version
            version=$(echo "$update_info" | jq -r '.update.params[] | select(.type=="Version") | .value' 2>/dev/null)
            if [ "$version" != "null" ] && [ -n "$version" ]; then
                version_info="Version: $version"
            fi
            
            local release_version
            release_version=$(echo "$update_info" | jq -r '.update.params[] | select(.type=="ReleaseVersion") | .value' 2>/dev/null)
            if [ "$release_version" != "null" ] && [ -n "$release_version" ]; then
                version_info="$version_info, Release: $release_version"
            fi
            
            # Output to console
            echo -e "${GREEN}✓${NC} Node Group: ${BLUE}$nodegroup_name${NC}"
            echo -e "  Update ID: $update_id"
            echo -e "  Date: $formatted_date"
            echo -e "  Status: $status"
            echo -e "  Type: $update_type"
            [ -n "$version_info" ] && echo -e "  $version_info"
            echo ""
            
            # Write to CSV file
            echo "$cluster_name,$nodegroup_name,$update_id,$created_at,$status,$update_type,$version_info" >> "$OUTPUT_FILE"
        fi
    done
}

# Function to initialize CSV file
init_csv() {
    echo "Cluster,NodeGroup,UpdateID,CreatedAt,Status,Type,VersionInfo" > "$OUTPUT_FILE"
    print_info "CSV output file initialized: $OUTPUT_FILE"
}

# Function to display usage
usage() {
    echo "Usage: $0 -c <cluster-name> [options]"
    echo ""
    echo "Options:"
    echo "  -c, --cluster     EKS cluster name (required)"
    echo "  -n, --nodegroup   Specific node group name (optional, checks all if not provided)"
    echo "  -o, --output      Output CSV file name (default: eks_nodegroup_upgrades_YYYY.csv)"
    echo "  -h, --help        Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -c my-cluster"
    echo "  $0 -c my-cluster -n my-nodegroup"
    echo "  $0 -c my-cluster -o custom_output.csv"
}

# Main function
main() {
    local specific_nodegroup=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--cluster)
                CLUSTER_NAME="$2"
                shift 2
                ;;
            -n|--nodegroup)
                specific_nodegroup="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [ -z "$CLUSTER_NAME" ]; then
        print_error "Cluster name is required."
        usage
        exit 1
    fi
    
    print_info "Starting EKS Node Group Upgrade History Check"
    print_info "Cluster: $CLUSTER_NAME"
    print_info "Year: $CURRENT_YEAR"
    echo ""
    
    # Run checks
    check_prerequisites
    validate_cluster "$CLUSTER_NAME"
    init_csv
    
    # Get node groups to check
    local nodegroups_to_check
    if [ -n "$specific_nodegroup" ]; then
        nodegroups_to_check="$specific_nodegroup"
        print_info "Checking specific node group: $specific_nodegroup"
    else
        nodegroups_to_check=$(get_nodegroups "$CLUSTER_NAME")
        if [ $? -ne 0 ]; then
            exit 1
        fi
        print_info "Found node groups: $nodegroups_to_check"
    fi
    
    echo ""
    print_info "=== Upgrade History for $CURRENT_YEAR ==="
    echo ""
    
    # Process each node group
    local found_upgrades=false
    for nodegroup in $nodegroups_to_check; do
        if get_nodegroup_updates "$CLUSTER_NAME" "$nodegroup"; then
            found_upgrades=true
        fi
    done
    
    echo ""
    if [ "$found_upgrades" = true ]; then
        print_success "Upgrade history check completed successfully."
        print_success "Results saved to: $OUTPUT_FILE"
        
        # Show summary
        local total_upgrades
        total_upgrades=$(tail -n +2 "$OUTPUT_FILE" | wc -l)
        print_info "Total upgrades found in $CURRENT_YEAR: $total_upgrades"
    else
        print_info "No upgrades found for cluster '$CLUSTER_NAME' in $CURRENT_YEAR"
    fi
}

# Run the script
main "$@"
