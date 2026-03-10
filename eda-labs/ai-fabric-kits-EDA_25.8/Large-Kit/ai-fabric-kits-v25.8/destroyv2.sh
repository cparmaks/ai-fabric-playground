#!/bin/bash

# Stop on error
set -e

# Logging functions
log_info()    { echo -e "[INFO] $1"; }
log_warning() { echo -e "[WARNING] $1"; }
log_error()   { echo -e "[ERROR] $1"; }
log_success() { echo -e "[SUCCESS] $1"; }

# Default file paths
TOPOLOGY_FILE="ai-fabric-2tierv2.yaml"
TOPOLOGY_DATA="clab-ai-fabric-2tier/topology-data.json"

# Prompt user for EDA URL
read -p "Enter EDA URL (e.g., https://<EDA_URL:port_ID>): " EDA_URL

if [[ -z "$EDA_URL" ]]; then
  echo "[ERROR] EDA URL is required. Exiting."
  exit 1
fi

# Function to destroy everything
destroy_all() {
    log_info "Current working directory: $(pwd)"
    log_info "Topology file path: '$TOPOLOGY_FILE'"
    log_info "EDA URL: '$EDA_URL'"
    log_info "Topology data path: '$TOPOLOGY_DATA'"

    local cleanup_failed=false

    # Remove from EDA
    log_info "Removing topology from EDA..."
    if [[ -f "$TOPOLOGY_DATA" ]]; then
        if ! clab-connector remove -t "$TOPOLOGY_DATA" -e "$EDA_URL"; then
            log_warning "Failed to remove from EDA"
            cleanup_failed=true
        fi
    else
        log_warning "Topology data file not found, skipping EDA cleanup"
    fi

    # Destroy topology
    log_info "Destroying containerlab topology..."
    if [[ -f "$TOPOLOGY_FILE" ]]; then
        if ! clab destroy -t "$TOPOLOGY_FILE" --cleanup; then
            log_error "Failed to destroy topology"
            cleanup_failed=true
        fi
    else
        log_warning "Topology file '$TOPOLOGY_FILE' not found, skipping topology destruction"
    fi

    # # Remove Clab Folder
    # log_info "Removing containerlab folder..."
    # rm -rf clab-ai-fabric-*


    if [[ "$cleanup_failed" == "true" ]]; then
        log_error "Cleanup completed with errors!"
        exit 1
    else
        log_success "Cleanup completed successfully!"
    fi
}

destroy_all
