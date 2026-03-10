ip link add link eth5 name eth5.2 type vlan id 2
ip -6 addr add fd00:2:5:1:0:5:0:2/96 dev eth5.2
ip link set eth5.2 up
ip -6 route add fd00:2:5:1::/64 via fd00:2:5:1:0:5:0:1 dev eth5.2 
ip -6 route add fd00:1:1:1::/64 via fd00:2:5:1:0:5:0:1 dev eth5.2
ip -6 route add fd00:1:2:1::/64 via fd00:2:5:1:0:5:0:1 dev eth5.2