ip link add link eth1 name eth1.2 type vlan id 2
ip -6 addr add fd00:2:9:1:0:1:0:2/96 dev eth1.2
ip link set eth1.2 up
ip -6 route add fd00:2:9:1::/64 via fd00:2:9:1:0:5:0:1 dev eth1.2 
ip -6 route add fd00:1:1:1::/64 via fd00:2:13:1:0:5:0:1 dev eth1.2
ip -6 route add fd00:1:2:1::/64 via fd00:2:13:1:0:5:0:1 dev eth1.2