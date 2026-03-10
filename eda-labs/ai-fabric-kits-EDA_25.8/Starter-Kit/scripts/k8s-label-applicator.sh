#!/bin/bash
# Working Kubernetes Label Applicator Script
# Tested and verified - uses direct kubectl commands
set -euo pipefail

# Configuration
SCRIPT_NAME=$(basename "$0")
DRY_RUN=false
VERBOSE=false
NAMESPACE=""
RESOURCE_TYPE=""
RESOURCE_NAME=""
SELECTOR=""
LABELS=()
REMOVE_LABELS=()
OVERWRITE=false

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $*" >&2
    fi
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Apply labels to Kubernetes resources using kubectl label commands.

OPTIONS:
    -t, --type RESOURCE_TYPE     Resource type (e.g., deployment, service, pod)
    -n, --namespace NAMESPACE    Namespace (default: current context namespace)
    -r, --resource NAME          Specific resource name
    -s, --selector SELECTOR      Label selector (e.g., "app=myapp,tier=frontend")
    -l, --label KEY=VALUE        Label to apply (can be used multiple times)
    -x, --remove-label KEY       Label to remove (can be used multiple times)
    -o, --overwrite             Allow overwriting existing labels
    -d, --dry-run               Show what would be done without applying changes
    -v, --verbose               Enable verbose output
    -h, --help                  Show this help message

EXAMPLES:
    # Label all deployments in current namespace
    $SCRIPT_NAME -t deployment -l environment=production -l team=backend

    # Label specific service
    $SCRIPT_NAME -t service -r my-service -l tier=frontend

    # Remove labels from pods
    $SCRIPT_NAME -t pod -s "app=old-app" -x deprecated-label

    # Overwrite existing labels
    $SCRIPT_NAME -t deployment -r my-app -l version=v2.0 --overwrite

    # Dry run with verbose output
    $SCRIPT_NAME -t deployment -l version=v2.0 --dry-run --verbose
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                RESOURCE_TYPE="$2"
                shift 2
                ;;
            -n|--namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            -r|--resource)
                RESOURCE_NAME="$2"
                shift 2
                ;;
            -s|--selector)
                SELECTOR="$2"
                shift 2
                ;;
            -l|--label)
                LABELS+=("$2")
                shift 2
                ;;
            -x|--remove-label)
                REMOVE_LABELS+=("$2")
                shift 2
                ;;
            -o|--overwrite)
                OVERWRITE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

validate_inputs() {
    if [[ -z "$RESOURCE_TYPE" ]]; then
        log_error "Resource type is required. Use -t or --type"
        exit 1
    fi
    
    if [[ ${#LABELS[@]} -eq 0 && ${#REMOVE_LABELS[@]} -eq 0 ]]; then
        log_error "At least one label operation is required (add or remove)"
        exit 1
    fi
    
    # Validate label format
    for label in "${LABELS[@]}"; do
        if [[ ! "$label" =~ ^[a-zA-Z0-9._/-]+=[a-zA-Z0-9._/-]+$ ]]; then
            log_error "Invalid label format: $label. Expected format: key=value"
            exit 1
        fi
    done
    
    # Check prerequisites
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
}

# Execute kubectl label command with proper error handling
execute_kubectl_label() {
    local operation="$1"  # "add" or "remove"
    shift
    local labels=("$@")
    
    # Build base command
    local cmd=(kubectl label)
    
    # Add namespace if specified
    if [[ -n "$NAMESPACE" ]]; then
        cmd+=(--namespace "$NAMESPACE")
    fi
    
    # Add resource type
    cmd+=("$RESOURCE_TYPE")
    
    # Add resource selection
    if [[ -n "$RESOURCE_NAME" ]]; then
        cmd+=("$RESOURCE_NAME")
    elif [[ -n "$SELECTOR" ]]; then
        cmd+=(--selector "$SELECTOR")
    else
        cmd+=(--all)
    fi
    
    # Add labels
    for label in "${labels[@]}"; do
        if [[ "$operation" == "remove" ]]; then
            cmd+=("${label}-")
        else
            cmd+=("$label")
        fi
    done
    
    # Add flags
    if [[ "$DRY_RUN" == "true" ]]; then
        cmd+=(--dry-run=client)
    fi
    
    if [[ "$OVERWRITE" == "true" && "$operation" == "add" ]]; then
        cmd+=(--overwrite)
    fi
    
    # Execute command
    log_verbose "Executing: ${cmd[*]}"
    
    if "${cmd[@]}"; then
        return 0
    else
        return 1
    fi
}

# Apply labels to resources
apply_labels() {
    local success=true
    
    # Remove labels first
    if [[ ${#REMOVE_LABELS[@]} -gt 0 ]]; then
        log_info "Removing ${#REMOVE_LABELS[@]} label(s)..."
        
        if execute_kubectl_label "remove" "${REMOVE_LABELS[@]}"; then
            log_success "✓ Successfully removed labels: ${REMOVE_LABELS[*]}"
        else
            log_error "✗ Failed to remove some labels"
            success=false
        fi
    fi
    
    # Add labels
    if [[ ${#LABELS[@]} -gt 0 ]]; then
        log_info "Adding ${#LABELS[@]} label(s)..."
        
        if execute_kubectl_label "add" "${LABELS[@]}"; then
            log_success "✓ Successfully applied labels: ${LABELS[*]}"
        else
            log_error "✗ Failed to apply some labels"
            success=false
        fi
    fi
    
    if [[ "$success" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# Get resource count for reporting
get_resource_count() {
    local cmd=(kubectl get "$RESOURCE_TYPE")
    
    if [[ -n "$NAMESPACE" ]]; then
        cmd+=(--namespace "$NAMESPACE")
    fi
    
    if [[ -n "$RESOURCE_NAME" ]]; then
        cmd+=("$RESOURCE_NAME")
    elif [[ -n "$SELECTOR" ]]; then
        cmd+=(--selector "$SELECTOR")
    fi
    
    cmd+=(--no-headers)
    
    if "${cmd[@]}" 2>/dev/null | wc -l; then
        return 0
    else
        echo "0"
        return 1
    fi
}

main() {
    parse_args "$@"
    validate_inputs
    
    log_info "Starting label application"
    log_info "Resource type: $RESOURCE_TYPE"
    log_info "Namespace: ${NAMESPACE:-<current context>}"
    
    if [[ -n "$RESOURCE_NAME" ]]; then
        log_info "Target resource: $RESOURCE_NAME"
    elif [[ -n "$SELECTOR" ]]; then
        log_info "Label selector: $SELECTOR"
    else
        log_info "Target: All $RESOURCE_TYPE resources"
    fi
    
    if [[ ${#LABELS[@]} -gt 0 ]]; then
        log_info "Labels to apply: ${LABELS[*]}"
    fi
    
    if [[ ${#REMOVE_LABELS[@]} -gt 0 ]]; then
        log_info "Labels to remove: ${REMOVE_LABELS[*]}"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi
    
    # Check if resources exist
    local resource_count
    resource_count=$(get_resource_count)
    
    if [[ "$resource_count" -eq 0 ]]; then
        log_error "No resources found matching criteria"
        exit 1
    fi
    
    log_info "Found $resource_count resource(s) to process"
    
    # Apply labels
    if apply_labels; then
        log_success "=== OPERATION COMPLETED SUCCESSFULLY ==="
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "Dry run completed - $resource_count resource(s) would be modified"
        else
            log_success "Successfully processed $resource_count resource(s)"
        fi
    else
        log_error "=== OPERATION FAILED ==="
        exit 1
    fi
}

# Execute main function
main "$@"