# Starter-Kit Quickstart

This quickstart summarizes the Starter-Kit (1-tier) topology, node counts, and the exact steps performed by `deploy.sh`.

## Topology summary (from `ai-fabric-1tier.yaml`)

- Leaf nodes: 2 (1tier-leaf-01..02) — Nokia SR Linux (ixrh4)
- GPU servers: 4 (1tier-gpu-svr-01..04) — Linux multitool containers

Topology notes:
- 1-tier layout is compact: a small number of leafs connected to multiple GPU servers.

## Deploy script steps (exact actions from `deploy.sh`)

1. Prompt for EDA URL and validate input.

2. Deploy containerlab topology:

   - `clab deploy -t ai-fabric-1tier.yaml`

3. Wait for nodes (sleep 45 seconds).

4. Create EDA namespace:

   - `kubectl apply -f eda_manifests/namespace.yaml`

5. Integrate with clab-connector:

   - `clab-connector integrate -t clab-ai-fabric-1tier/topology-data.json -e "$EDA_URL"`

6. Apply resource manifests (IP/index pools, forwarding classes, queues):

   - `kubectl apply -f eda_manifests/ip-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests/index-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests/forwarding-classes.yaml`
   - `kubectl apply -f eda_manifests/queues.yaml`

7. Apply AI Fabric Rail-only manifest:

   - `kubectl apply -f eda_manifests/ai-fabric-rail-only.yaml`

8. Wait for interfaces & patch them (polls `kubectl -n clab-ai-fabric-1tier get interface` and patches with `scripts/interface-encaptype-dot1q-patch.json`).

9. Add leaf labels to `toponode` objects and run `./scripts/labels.sh` to label EDA objects.

10. Run traffic tests from GPU containers (gateway and same-rail checks) and report results.

## Run the deploy (examples)

```bash
cd Starter-Kit
./deploy.sh
```

## Post-deploy checks

- `kubectl -n clab-ai-fabric-1tier get pods,interfaces,toponode`
- `docker ps` and `docker exec -it <node> sr_cli show configuration` for SRL verification

---

## Automated smoke-test

Run:

```bash
cd Starter-Kit
chmod +x scripts/smoke-test.sh
./scripts/smoke-test.sh
```

Expected output (success):

```
[INFO] Testing GPU-01 -> gateway (fd00:1:1:1:0:1:0:1)
[SUCCESS] Gateway ping test passed
[INFO] Testing GPU-01 -> GPU-02 (same rail)
[SUCCESS] Same rail ping test passed
[SUCCESS] All smoke tests passed
```
