# Medium-Kit Quickstart

This quickstart summarizes the Medium-Kit (SingleStripe) topology, node counts, and the exact steps the kit `deploy.sh` runs.

## Topology summary (from `ai-fabric-singlestripe.yaml`)

- Leaf nodes: 8 (singlestripe-leaf-01..08) — Nokia SR Linux (ixrh4)
- GPU servers: 8 (singlestripe-gpu-svr-01..08) — Linux multitool containers

Topology notes:
- SingleStripe layout connects multiple leafs to GPU servers using per-leaf port mappings.

## Deploy script steps (exact actions from `deploy.sh`)

1. Prompt for EDA URL and validate input.

2. Deploy containerlab topology:

   - `clab deploy -t ai-fabric-singlestripe.yaml`

3. Wait for nodes:

   - `sleep 45`

4. Create EDA namespace:

   - `kubectl apply -f eda_manifests/namespace.yaml`

5. Integrate with clab-connector:

   - `clab-connector integrate -t clab-ai-fabric-singlestripe/topology-data.json -e "$EDA_URL"`

6. Apply resource manifests:

   - `kubectl apply -f eda_manifests/ip-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests/index-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests/forwarding-classes.yaml`
   - `kubectl apply -f eda_manifests/queues.yaml`

7. Apply AI Fabric manifest:

   - `kubectl apply -f eda_manifests/ai-fabric-singlestripe.yaml`

8. Wait for interfaces; patch them when they appear:

   - The script polls `kubectl -n clab-ai-fabric-singlestripe get interface -o name` and patches each interface with `scripts/interface-encaptype-dot1q-patch.json`.

9. Run `./scripts/labels.sh` to add labels to EDA objects.

10. Apply SRL leaf configs by running `docker exec -it <node> sr_cli source /home/admin/leaf-<N>.cfg` for leaf nodes 01..08.

11. Accept deviations (`kubectl apply -f eda_manifests/deviation-actions.yaml`).

12. Run traffic tests (gateway and same-rail checks) and report results.

## Run the deploy (examples)

```bash
cd Medium-Kit
./deploy.sh
```

## Post-deploy checks

- `kubectl -n clab-ai-fabric-singlestripe get pods,interfaces,toponode`
- `docker ps` to inspect running clab containers

---

## Automated smoke-test

Run the included smoke-test to validate basic IPv6 connectivity between GPU containers:

```bash
cd Medium-Kit
chmod +x scripts/smoke-test.sh
./scripts/smoke-test.sh
```

Expected minimal output (success):

```
[INFO] Testing GPU-01 -> gateway (fd00:1:1:1:0:1:0:1)
[SUCCESS] Gateway ping test passed
[INFO] Testing GPU-01 -> GPU-02 (same rail)
[SUCCESS] Same rail ping test passed
[SUCCESS] All smoke tests passed
```
