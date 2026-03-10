ip link add link eth1 name eth1.1 type vlan id 1
ip -6 addr add fd00:1:1:1:0:1:0:2/96 dev eth1.1
ip link set eth1.1 up
ip -6 route add fd00:2:5:1::/64 via fd00:1:1:1:0:1:0:1 dev eth1.1
ip -6 route add fd00:1:1:1::/64 via fd00:1:1:1:0:1:0:1 dev eth1.1
ip -6 route add fd00:1:2:1::/64 via fd00:1:1:1:0:1:0:1 dev eth1.1
ip -6 route add fd00:2:9:1::/64 via fd00:1:1:1:0:1:0:1 dev eth1.1 
