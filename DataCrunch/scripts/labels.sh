#!/bin/bash

# Add labels to objects
for i in {1..2}; do
    kubectl label --overwrite=true toponodes 1tier-leaf-0$i -n clab-ai-fabric-1tier eda.nokia.com/stripe-id=stripe1
done


# Edge port label assignment

#VRF1
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-1 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster1
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-5 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster1

#VRF2
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-2 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster2
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-6 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster2

#VRF3
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-3 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster3
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-7 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster3

#VRF4
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-4 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster4
kubectl label --overwrite=true interfaces 1tier-leaf-01-ethernet-1-8 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster4





#VRF5
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-1 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster5
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-5 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster5

#VRF6
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-2 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster6
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-6 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster6

#VRF7
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-3 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster7
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-7 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster7

#VRF8
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-4 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster8
kubectl label --overwrite=true interfaces 1tier-leaf-02-ethernet-1-8 -n clab-ai-fabric-1tier eda.nokia.com/tenant=gpucluster8
