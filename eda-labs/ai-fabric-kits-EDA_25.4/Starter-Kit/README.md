# Starter-Kit

This kit provides a compact 1-tier reference topology using Containerlab and SR Linux.

Use `deploy.sh` to deploy and `destroy.sh` to tear down.

See `QUICKSTART.md` for a concise operational checklist, topology diagram and smoke-test instructions.

Note (assumption): this README assumes the Starter topology uses 2 spines, 2 leaves and 4 GPU servers (the topology is defined in `ai-fabric-1tier.yaml`). If your local YAML differs, use the YAML as the source of truth.

## Topology (size-only)

- Spine count: 2
- Leaf count: 2
- GPU servers: 4

Uplink summary:

- Each leaf connects to both spines (check `ai-fabric-1tier.yaml` for the exact number of physical links per leaf).
- GPU servers connect to leaf nodes; see the topology YAML for explicit eth port mappings.

![AI Backend Fabric /// SMALL SCALE ](/Starter-Kit/images/1tier-ai-fabric-backend-topology.png)
```

## EDA AI fabric Lab

The Starter-Kit maps into EDA via clab-connector similar to the other kits. Use `QUICKSTART.md` for deploy steps and smoke-tests.

