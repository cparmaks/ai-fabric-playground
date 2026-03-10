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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Prompt user for EDA URL
read -p "Enter EDA URL (e.g., https://<EDA_URL:port_ID>): " EDA_URL

if [[ -z "$EDA_URL" ]]; then
  echo "[ERROR] EDA URL is required. Exiting."
  exit 1
fi

#1 [Deploy topology]
log_info "...Container lab topology deployment..."
clab deploy -t ai-fabric-2tierv2.yaml

#2 [Wait for nodes]
log_info "...Waiting for 45 seconds to ensure the nodes are reachable..."
sleep 45

#3 [Create namespace]
log_info "...Creating Namespace manually for clab-connector consistency..."
kubectl apply -f eda_manifests/namespace.yaml

#4 [Integrate with clab-connector]
log_info "...Integrating with clab-connector..."
clab-connector integrate -t clab-ai-fabric-2tier/topology-data.json -e "$EDA_URL"

#5 [Apply resource manifests]
log_info "Topology View Groupings..."
kubectl apply -f eda_manifests/topology-groupings.yaml
log_info "...Applying EDA Manifests for resource allocations..."
log_info "IP allocation pools..."
kubectl apply -f eda_manifests/ip-allocation-pools.yaml
log_info "Index allocation pools..."
kubectl apply -f eda_manifests/index-allocation-pools.yaml
log_info "QoS: Forwarding classes..."
kubectl apply -f eda_manifests/forwarding-classes.yaml
log_info "QoS: Egress queues configuration..."
kubectl apply -f eda_manifests/queues.yaml

#6 [Wait for interfaces to appear and patch them]
log_info "...Waiting for interfaces to become available for patching..."

MAX_WAIT=120
SLEEP_INTERVAL=5
elapsed=0
found=false

edge_interface_patch(){
    # Patch edge interfaces
    log_info "Patching edge interfaces for dot1q encapsulation..."
    kubectl -n clab-ai-fabric-2tier get interface -l 'eda.nokia.com/role=edge' -o name | \
        xargs -I{} kubectl -n clab-ai-fabric-2tier patch {} --type=merge --patch-file scripts/interface-encaptype-dot1q-patch.json
    
    # Verify interfaces were patched
    local edge_interfaces
    edge_interfaces=$(kubectl -n clab-ai-fabric-2tier get interface -l 'eda.nokia.com/role=edge' -o name | wc -l)
    if [[ $edge_interfaces -gt 0 ]]; then
        log_success "...Successfully patched $edge_interfaces edge interfaces..."
    else
        log_warning "!!!No edge interfaces found to patch"
    fi
}

while [[ $elapsed -lt $MAX_WAIT ]]; do
    edge_interfaces=$(kubectl -n clab-ai-fabric-2tier get interface -o name 2>/dev/null || true)

    if [[ -n "$edge_interfaces" ]]; then
        found=true
        break
    fi

    log_info "!!!Interfaces not ready yet (waited ${elapsed}s)... retrying in ${SLEEP_INTERVAL}s"
    sleep $SLEEP_INTERVAL
    ((elapsed+=SLEEP_INTERVAL))
done

if [[ "$found" = true ]]; then
    log_info "...Interfaces found after ${elapsed}s...Patching now..."
    edge_interface_patch
else
    log_warning "!!!Timed out after ${MAX_WAIT}s waiting for interfaces. Skipping patch."
fi

#8 [Apply AI Fabric manifest]
log_info "...AI Fabric Rail-only manifest..."
sleep 45
kubectl apply -f eda_manifests/ai-fabric-rail-optimised.yaml

#7 [Run external label script]
log_info "...Adding labels to EDA objects..."
sleep 60
chmod +x ./scripts/labelsv2.sh
bash ./scripts/labelsv2.sh

#8 [Wait for Commit Confirmed on SRL nodes]
log_info "...Waiting for Commit Confirmed on SRL nodes..."
sleep 75

#9 [Accept deviations]
accept_deviations() {
    log_info "...Accepting deviations..."
    kubectl apply -f eda_manifests/deviation-actionsv2.yaml
    log_success "...Deviations accepted..."
}
accept_deviations

#10 [Pre-leaf configurations]
apply_leaf_configurations() {
    log_info "...Applying configuration snippets to Leaf nodes..."
    
    # Apply configurations to leafs
    docker exec -it 2tier-leaf-01 sr_cli source /home/admin/leaf-01.cfg || log_warning "Failed to apply config to 2tier-leaf-01"
    docker exec -it 2tier-leaf-02 sr_cli source /home/admin/leaf-02.cfg || log_warning "Failed to apply config to 2tier-leaf-02"
    docker exec -it 2tier-leaf-03 sr_cli source /home/admin/leaf-03.cfg || log_warning "Failed to apply config to 2tier-leaf-03"
    docker exec -it 2tier-leaf-04 sr_cli source /home/admin/leaf-04.cfg || log_warning "Failed to apply config to 2tier-leaf-04"
    docker exec -it 2tier-leaf-05 sr_cli source /home/admin/leaf-05.cfg || log_warning "Failed to apply config to 2tier-leaf-05"
    docker exec -it 2tier-leaf-06 sr_cli source /home/admin/leaf-06.cfg || log_warning "Failed to apply config to 2tier-leaf-06"
    docker exec -it 2tier-leaf-07 sr_cli source /home/admin/leaf-07.cfg || log_warning "Failed to apply config to 2tier-leaf-07"
    docker exec -it 2tier-leaf-08 sr_cli source /home/admin/leaf-08.cfg || log_warning "Failed to apply config to 2tier-leaf-08"

    docker exec -it 2tier-leaf-09 sr_cli source /home/admin/leaf-09.cfg || log_warning "Failed to apply config to 2tier-leaf-09"
    docker exec -it 2tier-leaf-10 sr_cli source /home/admin/leaf-10.cfg || log_warning "Failed to apply config to 2tier-leaf-10"
    docker exec -it 2tier-leaf-11 sr_cli source /home/admin/leaf-11.cfg || log_warning "Failed to apply config to 2tier-leaf-11"
    docker exec -it 2tier-leaf-12 sr_cli source /home/admin/leaf-12.cfg || log_warning "Failed to apply config to 2tier-leaf-12"
    docker exec -it 2tier-leaf-13 sr_cli source /home/admin/leaf-13.cfg || log_warning "Failed to apply config to 2tier-leaf-13"
    docker exec -it 2tier-leaf-14 sr_cli source /home/admin/leaf-14.cfg || log_warning "Failed to apply config to 2tier-leaf-14"
    docker exec -it 2tier-leaf-15 sr_cli source /home/admin/leaf-15.cfg || log_warning "Failed to apply config to 2tier-leaf-15"
    docker exec -it 2tier-leaf-16 sr_cli source /home/admin/leaf-16.cfg || log_warning "Failed to apply config to 2tier-leaf-16"

for i in $(seq -w 1 16); do
  node="2tier-leaf-$i"
  cfg="/home/admin/leaf-$i.cfg"
  docker exec -it "$node" sr_cli source "$cfg" \
    || echo "[WARNING] Failed to apply config to $node"
done
    log_success "...Leaf node configurations applied suucessfully..."
}
apply_leaf_configurations

#11 [Apply AI Fabric manifest]
log_info "...AI Fabric Rail-only manifest..."
kubectl apply -f eda_manifests/ai-fabric-rail-optimised.yaml

# #12 [Function to run traffic tests]
# run_traffic_tests() {
#     log_info "...Running traffic tests..."
    
#     local test_failures=0
#     local total_tests=0
    
#     echo "...Testing connectivity between GPU servers..."
    
#     echo "...Testing GPU-01 to gateway..."
#     total_tests=$((total_tests + 1))
#     if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:1:1:1:0:1:0:1; then
#         log_success "...Gateway ping test passed..."
#     else
#         log_error "!!!Gateway ping test failed"
#         test_failures=$((test_failures + 1))
#     fi
    
#     echo "...Testing GPU-01 to GPU-02 (same Rail)..."
#     total_tests=$((total_tests + 1))
#     if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:1:1:1:0:2:0:2; then
#         log_success "...Same rail ping test passed..."
#     else
#         log_error "!!!Same rail ping test failed"
#         test_failures=$((test_failures + 1))
#     fi
    
#     echo "...Testing GPU-01 to GPU-03 (same Stripe)..."
#     total_tests=$((total_tests + 1))
#     if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:1:2:1:0:3:0:2; then
#         log_success "...Same stripe ping test passed..."
#     else
#         log_error "!!!Same stripe ping test failed"
#         test_failures=$((test_failures + 1))
#     fi
    
#     echo "...Testing GPU-01 to GPU-05 (across Stripe)..."
#     total_tests=$((total_tests + 1))
#     if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:2:9:1:0:1:0:2; then
#         log_success "...Cross stripe ping test passed"
#     else
#         log_error "!!!Cross stripe ping test failed"
#         test_failures=$((test_failures + 1))
#     fi
# }

# run_traffic_tests

# chmod +x ./scripts/smoke-test.sh
# bash ./scripts/smoke-test.sh

log_info "All steps completed successfully."


# #Test
# log_info "...Smoke Test..."
# chmod +x ./scripts/smoke-test.sh
# bash ./scripts/smoke-test.sh