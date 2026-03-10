# #!/usr/bin/env bash
# set -euo pipefail

# NAMESPACE="clab-ai-fabric-singlestripe"
# LABEL_KEY="eda.nokia.com/tenant-id"
# STRIPE_KEY="eda.nokia.com/stripe-id"
# STRIPE_VALUE="stripe1"

# # Map each leaf node to a real-world tenant
# declare -A TENANTS=(
#   ["01"]="finance-dept"
#   ["02"]="product-dev"
#   ["03"]="data-analytics"
#   ["04"]="it-operations"
#   ["05"]="research-lab"
#   ["06"]="qa-testing"
#   ["07"]="customer-support"
#   ["08"]="compliance"
# )

# echo "[INFO] Adding labels to EDA objects..."

# # Label interfaces per leaf with tenant-ids
# for n in {1..8}; do
#   leaf="$(printf '%02d' "$n")"                         # 01..08
#   node="singlestripe-leaf-${leaf}"
#   tenant="${TENANTS[$leaf]:-}"
#   if [[ -z "$tenant" ]]; then
#     echo "No tenant mapping for ${node}; skipping." >&2
#     continue
#   fi

#   for p in {1..8}; do                                  # ports are unpadded (1..8). Pad if yours are 01..08.
#     interface="${node}-ethernet-1-${p}"
#     echo "Labeling ${interface} with ${LABEL_KEY}=${tenant}"
#     kubectl label --overwrite=true interfaces "${interface}" \
#       -n "${NAMESPACE}" "${LABEL_KEY}=${tenant}"
#   done
# done

# # Label toponodes with stripe id
# for n in {1..8}; do
#   leaf="$(printf '%02d' "$n")"
#   node="singlestripe-leaf-${leaf}"
#   echo "Labeling ${node} with ${STRIPE_KEY}=${STRIPE_VALUE}"
#   kubectl label --overwrite=true toponodes "${node}" \
#     -n "${NAMESPACE}" "${STRIPE_KEY}=${STRIPE_VALUE}"
# done

#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="clab-ai-fabric-singlestripe"
LABEL_KEY="eda.nokia.com/tenant-id"
STRIPE_KEY="eda.nokia.com/stripe-id"
STRIPE_VALUE="stripe1"

TENANT_P12="finance-dept"
TENANT_P38="product-dev"

echo "[INFO] Adding labels to EDA objects..."

# Label interfaces on all leafs
for n in {1..8}; do
  leaf="$(printf '%02d' "$n")"               # 01..08
  node="singlestripe-leaf-${leaf}"

  # Ports 1..2 => finance-dept
  for p in 1 2; do
    interface="${node}-ethernet-1-${p}"
    echo "Labeling ${interface} with ${LABEL_KEY}=${TENANT_P12}"
    kubectl label --overwrite=true interfaces "${interface}" \
      -n "${NAMESPACE}" "${LABEL_KEY}=${TENANT_P12}"
  done

  # Ports 3..8 => product-dev
  for p in 3 4 5 6 7 8; do
    interface="${node}-ethernet-1-${p}"
    echo "Labeling ${interface} with ${LABEL_KEY}=${TENANT_P38}"
    kubectl label --overwrite=true interfaces "${interface}" \
      -n "${NAMESPACE}" "${LABEL_KEY}=${TENANT_P38}"
  done
done

# Label toponodes with stripe id
for n in {1..8}; do
  leaf="$(printf '%02d' "$n")"
  node="singlestripe-leaf-${leaf}"
  echo "Labeling ${node} with ${STRIPE_KEY}=${STRIPE_VALUE}"
  kubectl label --overwrite=true toponodes "${node}" \
    -n "${NAMESPACE}" "${STRIPE_KEY}=${STRIPE_VALUE}"
done