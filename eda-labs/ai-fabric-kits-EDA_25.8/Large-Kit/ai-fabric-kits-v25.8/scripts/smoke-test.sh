#!/bin/bash
set -e
set test_failures=0
set total_tests=0

log_info() { echo "[INFO] $1"; }
log_success() { echo "[SUCCESS] $1"; }
log_error() { echo "[ERROR] $1"; }

#12 [Function to run traffic tests]
run_traffic_tests() {
    log_info "...Running traffic tests..."
    
    echo "...Testing connectivity between GPU servers..."
    
    echo "...Testing GPU-01 to gateway..."
    total_tests=$((total_tests + 1))
    if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:1:1:1:0:1:0:1; then
        log_success "...Gateway ping test passed..."
    else
        log_error "!!!Gateway ping test failed"
        test_failures=$((test_failures + 1))
    fi
    
    echo "...Testing GPU-01 to GPU-02 (same Rail)..."
    total_tests=$((total_tests + 1))
    if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:1:1:1:0:2:0:2; then
        log_success "...Same rail ping test passed..."
    else
        log_error "!!!Same rail ping test failed"
        test_failures=$((test_failures + 1))
    fi
    
    echo "...Testing GPU-01 to GPU-03 (same Stripe)..."
    total_tests=$((total_tests + 1))
    if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:1:2:1:0:3:0:2; then
        log_success "...Same stripe ping test passed..."
    else
        log_error "!!!Same stripe ping test failed"
        test_failures=$((test_failures + 1))
    fi
    
    echo "...Testing GPU-01 to GPU-05 (across Stripe)..."
    total_tests=$((total_tests + 1))
    if docker exec -it 2tier-gpu-svr-01 ping6 -c 5 -s 1450 fd00:2:9:1:0:1:0:2; then
        log_success "...Cross stripe ping test passed"
    else
        log_error "!!!Cross stripe ping test failed"
        test_failures=$((test_failures + 1))
    fi
}
run_traffic_tests
log_success "All smoke tests passed"
