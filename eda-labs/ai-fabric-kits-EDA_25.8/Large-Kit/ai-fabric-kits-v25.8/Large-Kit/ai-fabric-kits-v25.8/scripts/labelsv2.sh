#!/bin/bash

# Overwrite labels
for i in {1..9}; do
    kubectl label --overwrite toponode 2tier-leaf-0$i -n clab-ai-fabric-2tier eda.nokia.com/role=leaf
done

for i in {10..16}; do
    kubectl label --overwrite toponode 2tier-leaf-$i -n clab-ai-fabric-2tier eda.nokia.com/role=leaf
done


for i in {1..2}; do
    kubectl label --overwrite toponode 2tier-spine-0$i -n clab-ai-fabric-2tier eda.nokia.com/role=stripe-conn
done

# Add labels to objects
for i in {1..8}; do
    kubectl label --overwrite toponode 2tier-leaf-0$i -n clab-ai-fabric-2tier eda.nokia.com/stripe-id=stripe1
done

for i in {9..16}; do
  node=$(printf "2tier-leaf-%02d" "$i")
  kubectl label --overwrite toponode "$node" \
    -n clab-ai-fabric-2tier eda.nokia.com/stripe-id=stripe2
done

for i in {1..2}; do
    kubectl label --overwrite toponode 2tier-spine-0$i -n clab-ai-fabric-2tier eda.nokia.com/stripe-conn=true
done

# for i in 2tier-leaf-01-ethernet-1-1 2tier-leaf-01-ethernet-1-2 2tier-leaf-02-ethernet-1-3 2tier-leaf-01-ethernet-1-3 2tier-leaf-05-ethernet-1-5; do
#     kubectl label interface $i -n clab-ai-fabric-2tier eda.nokia.com/tenant-id=tenant1
# done

#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="clab-ai-fabric-2tier"
LABEL_KEY="eda.nokia.com/tenant-id"
TENANT="tenant1"

echo "[INFO] Labeling interfaces..."

# Leaf 01–04: ports 1–4
for r in {1..8}; do
  leaf="$(printf '2tier-leaf-%02d' "$r")"
  for p in {1..4}; do
    iface="${leaf}-ethernet-1-${p}"
    echo "Labeling ${iface} with ${LABEL_KEY}=${TENANT}"
    kubectl label --overwrite=true interfaces "${iface}" \
      -n "${NAMESPACE}" "${LABEL_KEY}=${TENANT}"
  done
done

# leafs 05–08: ports 5–8
for r in {9..16}; do
  leaf="$(printf '2tier-leaf-%02d' "$r")"
  for p in {1..4}; do
    iface="${leaf}-ethernet-1-${p}"
    echo "Labeling ${iface} with ${LABEL_KEY}=${TENANT}"
    kubectl label --overwrite=true interfaces "${iface}" \
      -n "${NAMESPACE}" "${LABEL_KEY}=${TENANT}"
  done
done