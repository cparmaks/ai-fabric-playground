# Large-Kit Quickstart

This quickstart summarizes the Large-Kit topology (node types & counts), the high-level topology, and the exact steps executed by the kit deploy script (`deployv2.sh`). Use this file as a concise operational checklist.

## Topology summary (from `ai-fabric-2tierv1.yaml` / `ai-fabric-2tierv2.yaml`)

- Spine nodes: 2 (2tier-spine-01..02) — Nokia SR Linux (ixrh4)
- Leaf nodes: 8 (2tier-leaf-01..08) — Nokia SR Linux (ixrh4)
- GPU servers: 8 (2tier-gpu-01..2tier-gpu-08) — Linux multitool containers

Topology notes:
- The layout is a 2-tier fabric with two spine nodes and multiple leafs split into stripes. Each leaf connects to multiple GPU servers per the `links:` section of the topology YAML.

## Deploy script steps (exact actions from `deployv2.sh`)

1. Prompt for EDA URL:

   - `read -p "Enter EDA URL (e.g., https://100.118.196.38:9443): " EDA_URL`
   - Exit if empty.

2. Deploy containerlab topology:

   - `clab deploy -t ai-fabric-2tierv2.yaml`

3. Wait for nodes to become reachable:

   - `sleep 45`

4. Create EDA namespace (manual/consistent namespace):

   - `kubectl apply -f eda_manifests/namespace.yaml`

5. Integrate topology with clab-connector:

   - `clab-connector integrate -t clab-ai-fabric-2tier/topology-data.json -e "$EDA_URL"`

6. Apply EDA resource manifests:

   - `kubectl apply -f eda_manifests/ip-allocation-pools.yaml`
   - `kubectl apply -f eda_manifests/index-allocation-poolsv2.yaml`
   - `kubectl apply -f eda_manifests/forwarding-classes.yaml`
   - `kubectl apply -f eda_manifests/queues.yaml`

7. Wait for interfaces & patch edge interfaces (dot1q encapsulation):

   - The script polls for interfaces in namespace `clab-ai-fabric-2tier` and when found runs:
     - `kubectl -n clab-ai-fabric-2tier get interface -l 'eda.nokia.com/role=edge' -o name | xargs -I{} kubectl -n clab-ai-fabric-2tier patch {} --type=merge --patch-file scripts/interface-encaptype-dot1q-patch.json`

   - If interfaces don't appear within the timeout the script logs a warning and continues.

8. Add labels to EDA objects:

   - Make label script executable and run `./scripts/labelsv2.sh`.

9. Apply AI Fabric manifest:

   - `kubectl apply -f eda_manifests/ai-fabric-rail-optimised.yaml`

10. Wait for SRL commit confirmation (sleep):

    - `sleep 75`

11. Accept deviations in EDA (apply deviation actions):

    - `kubectl apply -f eda_manifests/deviation-actionsv2.yaml`

12. Apply leaf configurations into SRL containers:

    - The script sources leaf config files into running SRL containers using `docker exec -it <node> sr_cli source /home/admin/leaf-<N>.cfg` for leaf nodes. It iterates leaf 1..16 where available.

13. Run traffic tests (connectivity checks):

    - Several ping tests are executed from GPU containers to validate gateway, same-rail, same-stripe, and cross-stripe connectivity. Results are aggregated and reported.

14. Final success log.

## Run the deploy (examples)

From a POSIX shell (WSL/Git Bash/macOS/Linux):

```bash
cd Large-Kit
./deployv2.sh
```

On Windows PowerShell, run under WSL (example):

```powershell
# wsl sh -c "cd /mnt/c/Users/<you>/path/to/repo/Large-Kit && ./deployv2.sh"
```

## Post-deploy checks

- `kubectl -n clab-ai-fabric-2tier get pods,interfaces,toponode` — confirm resources
- `docker ps` and `docker exec -it <node> sr_cli show configuration` — inspect SRL node configuration if needed

---
## Automated smoke-test

A non-interactive smoke-test script is provided to validate basic IPv6 connectivity between GPU containers and the fabric gateway. It runs the same connectivity checks used by the deploy script.

Run:

```bash
cd Large-Kit
chmod +x scripts/smoke-test.sh
./scripts/smoke-test.sh
```

Example expected output (success):

```
[INFO] Testing GPU-01 -> gateway (fd00:1:1:1:0:1:0:1)
[SUCCESS] Gateway ping test passed
[INFO] Testing GPU-01 -> same rail (fd00:1:1:1:0:2:0:2)
[SUCCESS] Same rail ping test passed
[INFO] All tests completed: 2/2 passed
```
