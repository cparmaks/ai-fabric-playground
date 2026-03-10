#!/bin/bash

# Add labels to objects
for i in {1..2}; do
    kubectl label --overwrite=true toponodes 1tier-leaf-0$i -n clab-ai-fabric-1tier eda.nokia.com/stripe-id=stripe1
done


# leaf-01 First 4 ports assigned to fintecdpt
for i in 1tier-leaf-01-ethernet-1-1 1tier-leaf-01-ethernet-1-2 1tier-leaf-01-ethernet-1-3 1tier-leaf-01-ethernet-1-4 1tier-leaf-01-ethernet-1-5 1tier-leaf-01-ethernet-1-6 1tier-leaf-01-ethernet-1-7 1tier-leaf-01-ethernet-1-8 ; do
    kubectl label --overwrite=true interfaces $i -n clab-ai-fabric-1tier eda.nokia.com/tenant-id=fintecdpt
done

# # leaf-01 Second 4 ports assigned to pmodpt
# for i in 1tier-leaf-01-ethernet-1-5 1tier-leaf-01-ethernet-1-6 1tier-leaf-01-ethernet-1-7 1tier-leaf-01-ethernet-1-8; do
#     kubectl label --overwrite=true interfaces $i -n clab-ai-fabric-1tier eda.nokia.com/tenant-id=pmodpt
# done

# leaf-02 First 4 ports assigned to fintecdpt
for i in 1tier-leaf-02-ethernet-1-1 1tier-leaf-02-ethernet-1-2 1tier-leaf-02-ethernet-1-3 1tier-leaf-02-ethernet-1-4 1tier-leaf-02-ethernet-1-5 1tier-leaf-02-ethernet-1-6 1tier-leaf-02-ethernet-1-7 1tier-leaf-02-ethernet-1-8 ; do
    kubectl label --overwrite=true interfaces $i -n clab-ai-fabric-1tier eda.nokia.com/tenant-id=pmodpt
done

# # leaf-02 Second 4 ports assigned to pmodpt
# for i in 1tier-leaf-02-ethernet-1-5 1tier-leaf-02-ethernet-1-6 1tier-leaf-02-ethernet-1-7 1tier-leaf-02-ethernet-1-8 ; do
#     kubectl label --overwrite=true interfaces $i -n clab-ai-fabric-1tier eda.nokia.com/tenant-id=pmodpt
# done



