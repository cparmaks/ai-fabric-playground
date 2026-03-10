# Rail-Only Kit for DataCrunch

This kit provides a compact Rail-only AI Fabric reference topology using Containerlab and SR Linux.

Use `deploy.sh` to deploy and `destroy.sh` to tear down.

## Platform & Prerequisites

- Containerlab — network emulation & SR Linux integration. https://containerlab.srlinux.dev/
- Clab-connector — topology-to-EDA linkage. https://github.com/eda-labs/clab-connector
- EDA Platform — orchestration, policy, and automation layer. https://docs.eda.dev/
- Linux OS (native or WSL) — host OS for tooling and scripts.

## Topology (size-only)

- Backend Compute Leaf: 2xIXR-H4
- Backend Storage Leaf: 2xIXR-D5
- Frontend Leaf: 2xIXR-D3L
- GPU servers: 2 with 8 uplinks each

***Each NIC on the GPU Servers represents a GPU

![AI Backend Fabric /// RAIL-ONLY ](/DataCrunch/images/PhyscialTopology.png)
```

############TBD: See `QUICKSTART.md` for a concise operational checklist, topology diagram and smoke-test instructions.
