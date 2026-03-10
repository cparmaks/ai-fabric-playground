ip link add link eth2 name eth2.1 type vlan id 1
ip -6 addr add fd00:1:2:1:0:3:0:2/96 dev eth2.1
ip link set eth2.1 up
ip -6 route add fd00:1:1:1::/64 via fd00:1:2:1:0:3:0:1 dev eth2.1
ip -6 route add fd00:1:2:1::/64 via fd00:1:2:1:0:3:0:1 dev eth2.1
ip -6 route add fd00:2:3:1::/64 via fd00:1:2:1:0:3:0:1 dev eth2.1