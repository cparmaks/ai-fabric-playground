PXN#1
======================================================================#
ip link add link eth1 name eth1.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:2:0:2/96 dev eth1.1
ip link set eth1.1 up

#PXN#2
#======================================================================#
ip link add link eth2 name eth2.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:2:0:3/96 dev eth2.1
ip link set eth2.1 up

#PXN#3
#======================================================================#
ip link add link eth3 name eth3.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:3:0:3/96 dev eth3.1
ip link set eth3.1 up

#PXN#4
#======================================================================#
ip link add link eth4 name eth4.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:4:0:3/96 dev eth4.1
ip link set eth4.1 up

#PXN#5
#======================================================================#
ip link add link eth5 name eth5.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:5:0:3/96 dev eth5.1
ip link set eth5.1 up

#PXN#6
#======================================================================#
ip link add link eth6 name eth6.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:6:0:3/96 dev eth6.1
ip link set eth6.1 up

#PXN#7
#======================================================================#
ip link add link eth7 name eth7.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:7:0:3/96 dev eth7.1
ip link set eth7.1 up

#PXN#8
#======================================================================#
ip link add link eth8 name eth8.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:8:0:3/96 dev eth8.1
ip link set eth8.1 up