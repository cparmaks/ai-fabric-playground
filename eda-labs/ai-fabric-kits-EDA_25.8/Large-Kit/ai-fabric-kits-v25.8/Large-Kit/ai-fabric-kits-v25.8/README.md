# Large-Kit

This kit provides a multi-tier, GPU-enabled reference topology using Containerlab and SR Linux.

Use `deployv1.sh` / `deployv2.sh` to deploy and `destroyv1.sh` / `destroyv2.sh` to tear down.

See `QUICKSTART.md` for a concise operational checklist, topology diagram and smoke-test instructions.

## Versions

This kit ships two supported topology versions: `v1` and `v2`. Each version has its own Containerlab topology YAML and a matching deploy script. Both are 2-tier fabrics (spines and GPU server groups) but they differ in leaf counts and naming conventions:

- Version 1 (`ai-fabric-2tierv1`): 1 stripe, 8 leaves, 4 GPUs per stripe (8 GPUs total across all rails)
- Version 2 (`ai-fabric-2tierv2`): 2 stripes, 16 leaves, 4 GPUs per stripe (8 GPUs total)

### Version 1 (ai-fabric-2tierv1)

- Topology file: `ai-fabric-2tierv1.yaml`
- Deploy script: `deployv1.sh`
- Node naming and groups:
	- Spine nodes: `2tier-spine-01`, `2tier-spine-02`
	- Leaf nodes: `2tier-leaf-01` .. `2tier-leaf-08` (SRL binds reference `leaf-0X.cfg` and some use `leaf-05v1.cfg`, `leaf-06v1.cfg`, ...)
	- GPU nodes: `2tier-gpu-01` .. `2tier-gpu-08`

### Version 2 (ai-fabric-2tierv2)

- Topology file: `ai-fabric-2tierv2.yaml`
- Deploy script: `deployv2.sh`
- Node naming and groups:
	- Spine nodes: `2tier-spine-01`, `2tier-spine-02`
	- Leaf nodes: `2tier-leaf-01` .. `2tier-leaf-16` (binds updated to `leaf-05v2.cfg`, `leaf-06v2.cfg`, etc. for certain nodes)
	- GPU nodes: `2tier-gpu-svr-01` .. `2tier-gpu-svr-08` (note the `-svr-` suffix in v2)

## EDA AI fabric Lab

This Rail Optimised deployment is based on 2 Stripes of 4 Rails each and connected by 2 Stripe connectors. GPU Servers are connected to each Rail within it's corresponding Stripe.

![AI Backend Fabric /// LARGE SCALE v2](/Large-Kit/images/2tier-ai-fabric-backend-topology.png)

```

## Lab Deployment Using Containerlab, Containerlab-Connector and EDA

The topology is created in Clab and connected to EDA using Clab-Connector. EDA, Clab and Clab-Connector are all installed on the same physical server.

### Deploy the topology

```bash
$ clab deploy -t ai-fabric.clab.yaml
$ clab-connector integrate  -t clab-ai-fabric/topology-data.json -e https://<url or ipaddr-of-eda>
```

In case clab-connector throws an error while creating the namespace, create the namespace manually.

Create the namespace manually (if required)

```bash
$ kubectl apply -f eda_manifests/namespace.yaml
```

Once the topology is deployed and the nodes are on-boarded and synced with EDA, create the EDA objects.

Check if the nodes are synced with EDA

```bash
$ chmod +x ./scripts/check-nodes-synced.sh
$ bash ./scripts/check-nodes-synced.sh
```

#### Create EDA AI Fabric Objects

Patch edge interfaces to enable dot1q encapsulation

```bash
$ kubectl -n clab-ai-fabric get interface -l 'eda.nokia.com/role=edge' -o name | xargs -I{} kubectl -n clab-ai-fabric  patch {} --type=merge --patch-file  scripts/interface-encaptype-dot1q-patch.json
```

Add labels to EDA objects

```bash
$ chmod +x ./scripts/labels.sh
$ bash ./scripts/labels.sh
```

Create EDA IP Allocation Pools

```bash
$ kubectl apply -f eda_manifests/ip-allocation-pools.yaml
```

Create EDA Index Allocation Pools

```bash
$ kubectl apply -f eda_manifests/index-allocation-pools.yaml
```

Create EDA QoS Forwarding Classes

```bash
$ kubectl apply -f eda_manifests/forwarding-classes.yaml
```

Create EDA QoS Queue Profiles

```bash
$ kubectl apply -f eda_manifests/queues.yaml
```

Create EDA AI Fabric for Rail Optimised deployment

```bash
$ kubectl apply -f eda_manifests/ai-fabric-rail-optimised.yaml
```

Apply  QoS Policy for Edge Interfaces (missing in the EDA AI Fabric)

```bash
$ kubectl apply -f eda_manifests/qos-policy-deployment.yaml
```

In order to be able to send traffic arcoss the rails and the stripes, missing configuration snippets needs to be applied on the rails. This is done directly on the rails as EDA blocks configlets from being applied to objects that are labeled with `eda.nokia.com/source=derived`. (EDA does not allow objects to be configured by multiple CRs)

```bash
$ docker exec -it rail-01 sr_cli source /home/admin/rail-01.cfg
$ docker exec -it rail-02 sr_cli source /home/admin/rail-02.cfg
$ docker exec -it rail-05 sr_cli source /home/admin/rail-05.cfg
```

Accept all deviations introuduced by applying the configuration snippets

```bash
$ kubectl apply -f eda_manifests/deviation-actions.yaml
```

#### Update the topology groupings for AI Fabric

```bash
$ kubectl apply -f eda_manifests/topology-groupings.yaml
```

#### Traffic Test

Docker exec into the GPU servers and execute ping test between the GPU servers on the same Rail and across Rails and Stripes.

```bash
# ping from GPU server 01 to gateway
docker exec -it gpu-01 ping6 -c 3 fd00:1:1:1:0:1:0:1

# ping to GPU server 01 to GPU server 02 (same Rail)
docker exec -it gpu-01 ping6 -c 3 fd00:1:1:1:0:2:0:2

# ping to GPU server 01 to GPU server 03 (same Stripe)
docker exec -it gpu-01 ping6 -c 3 fd00:1:2:1:0:3:0:2

# ping to GPU server 01 to GPU server 05 (across Stripe)
docker exec -it gpu-01 ping6 -c 3 fd00:2:3:1:0:5:0:2
```

#### Cleanup all artifacts

```bash
$ clab-connector remove -t clab-ai-fabric/topology-data.json -e https://<url or ipaddr-of-eda>
$ clab destroy -t ai-fabric.clab.yaml
```