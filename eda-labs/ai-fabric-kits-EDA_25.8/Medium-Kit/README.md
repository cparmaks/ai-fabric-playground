# Medium-Kit

This kit provides a Single-Stripe reference topology using Containerlab and SR Linux.

Use `deploy.sh` to deploy and `destroy.sh` to tear down.

See `QUICKSTART.md` for a concise operational checklist, topology diagram and smoke-test instructions.

Note (assumption): this README assumes the SingleStripe topology uses 2 spines, 8 leaves and 8 GPU servers (the topology is defined in `ai-fabric-singlestripe.yaml`). If your local YAML differs, use the YAML as the source of truth.

## Topology (size-only)

- Spine count: 2
- Leaf count: 8 (single stripe)
- GPU servers: 8 (grouped across the stripe)

Uplink summary:

- Each leaf connects to both spines (multiple physical links may be present per leaf in the topology YAML).
- GPU servers connect into the stripe's leaves; check `ai-fabric-singlestripe.yaml` for the explicit eth port mappings.

![AI Backend Fabric /// MEDIUM SCALE ](/Medium-Kit/images/singlestripe-ai-fabric-backend-topology.png)
```

## EDA AI fabric Lab

This Single-Stripe deployment maps into EDA similarly to the Large-Kit flow: clab-connector integrates the Containerlab topology into EDA, after which the EDA AI-Fabric manifests and allocation pools are applied.

See `QUICKSTART.md` for the precise deploy steps and the smoke-test commands specific to this kit.

