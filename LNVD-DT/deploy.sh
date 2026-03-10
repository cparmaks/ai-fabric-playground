#!/bin/bash

# Stop the script on any command failure
set -e

# Logging functions
log_info() {
  echo "[INFO] $1"
}

log_success() {
  echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

log_warning() {
  echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# Prompt user for EDA URL
read -p "Enter EDA URL (e.g., https://100.118.196.38:9443): " EDA_URL

if [[ -z "$EDA_URL" ]]; then
  echo "[ERROR] EDA URL is required. Exiting."
  exit 1
fi

# Step 1: Deploy topology
log_info "Step 1: Deploying container lab topology..."
clab deploy -t ai-fabric-1tier.yaml

# Step 2: Wait for nodes
log_info "Waiting for 45 seconds to ensure the nodes are reachable..."
sleep 45

# Step 3: Create namespace
log_info "Step 2: Creating Namespace manually for clab-connector consistency..."
kubectl apply -f eda_manifests/namespace.yaml

# Step 4: Integrate with clab-connector
log_info "Step 3: Integrating with clab-connector..."
clab-connector integrate -t clab-ai-fabric-1tier/topology-data.json -e "$EDA_URL"

# Step 5–7: Apply resource manifests
log_info "Step 4: Applying IP allocation pools..."
kubectl apply -f eda_manifests/ip-allocation-pools.yaml

log_info "Step 5: Applying index allocation pools..."
kubectl apply -f eda_manifests/index-allocation-pools.yaml

log_info "Step 6: Applying forwarding classes..."
kubectl apply -f eda_manifests/forwarding-classes.yaml

log_info "Step 7: Applying queues configuration..."
kubectl apply -f eda_manifests/queues.yaml

# Step 8: Apply AI Fabric manifest
log_info "Step 8: Applying AI Fabric Rail-only manifest..."
kubectl apply -f eda_manifests/ai-fabric-rail-only.yaml

# Wait for interfaces to appear and patch them
log_info "Waiting for interfaces to become available for patching..."

MAX_WAIT=120
SLEEP_INTERVAL=5
elapsed=0
found=false

while [[ $elapsed -lt $MAX_WAIT ]]; do
    edge_interfaces=$(kubectl -n clab-ai-fabric-1tier get interface -o name 2>/dev/null || true)

    if [[ -n "$edge_interfaces" ]]; then
        found=true
        break
    fi

    log_info "  - Interfaces not ready yet (waited ${elapsed}s)... retrying in ${SLEEP_INTERVAL}s"
    sleep $SLEEP_INTERVAL
    ((elapsed+=SLEEP_INTERVAL))
done

if [[ "$found" = true ]]; then
    log_info "Interfaces found after ${elapsed}s. Patching now..."

    echo "$edge_interfaces" | while read -r intf; do
        log_info "  - Patching $intf"
        kubectl -n clab-ai-fabric-1tier patch "$intf" --type=merge --patch-file scripts/interface-encaptype-dot1q-patch.json
    done

    total=$(echo "$edge_interfaces" | wc -l)
    log_success "Successfully patched $total interface(s)."
else
    log_warning "Timed out after ${MAX_WAIT}s waiting for interfaces. Skipping patch."
fi

# Add leaf labels
log_info "Adding labels to corresponding leaf nodes..."
kubectl label --overwrite=true toponode 1tier-leaf-01 -n clab-ai-fabric-1tier eda.nokia.com/stripe-id=stripe1
kubectl label --overwrite=true toponode 1tier-leaf-02 -n clab-ai-fabric-1tier eda.nokia.com/stripe-id=stripe1

# Run external label script
log_info "Adding labels to EDA objects..."
chmod +x ./scripts/labels.sh
bash ./scripts/labels.sh

log_info "Waiting Nodes to be synced for traffic testing..."
sleep 60

# Function to run traffic tests
run_traffic_tests() {
    log_info "Running traffic tests..."
    
    local test_failures=0
    local total_tests=0
    
    echo "Testing connectivity between GPU servers..."
    
    # Test commands from README
    echo "Testing GPU-01 to gateway..."
    total_tests=$((total_tests + 1))
    if docker exec -it 1tier-gpu-svr-01 ping6 -c 3 fd00:1:1:1:0:1:0:1; then
        log_success "Gateway ping test passed"
    else
        log_error "Gateway ping test failed"
        test_failures=$((test_failures + 1))
    fi
    
    echo "Testing GPU-01 to GPU-02 (same Rail)..."
    total_tests=$((total_tests + 1))
    if docker exec -it 1tier-gpu-svr-01 ping6 -c 3 fd00:1:1:1:0:2:0:2; then
        log_success "Same rail ping test passed"
    else
        log_error "Same rail ping test failed"
        test_failures=$((test_failures + 1))
    fi
    
    # Report overall results
    local passed_tests=$((total_tests - test_failures))
    log_info "Traffic test results: $passed_tests/$total_tests tests passed"
    
    if [[ $test_failures -eq 0 ]]; then
        log_success "All traffic tests completed successfully!"
        return 0
    else
        log_error "Traffic tests completed with $test_failures failures"
        return 1
    fi
}
run_traffic_tests

log_info "All steps completed successfully."

