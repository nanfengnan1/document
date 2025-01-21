#!/bin/bash

# left host
ip netns add host1
ip link add name host1 type veth peer name veth_host1 netns host1
ip link set dev host1 up
ip netns exec host1 ip link set lo up
ip netns exec host1 ip link set veth_host1 up
ip netns exec host1 ip addr add 10.0.0.1/24 dev veth_host1
ip netns exec host1 ip route add 10.1.0.2/32 via 10.0.0.2

vppctl create host-interface name host1
vppctl set interface state host-host1 up
vppctl set interface ip address host-host1 10.0.0.2/24
#vppctl ip route add 10.1.0.1/32 via host-host2

ip netns exec host1 ip route add 10.1.0.1/32 via 10.0.0.2

# left hostl1
ip netns add hostl1
ip link add name hostl1 type veth peer name veth_hostl1 netns hostl1
ip link set dev hostl1 up
ip netns exec hostl1 ip link set lo up
ip netns exec hostl1 ip link set veth_hostl1 up
ip netns exec hostl1 ip addr add 10.2.0.1/24 dev veth_hostl1
ip netns exec hostl1 ip route add 10.1.0.2/32 via 10.2.0.2

vppctl create host-interface name hostl1
vppctl set interface state host-hostl1 up
vppctl set interface ip address host-hostl1 10.2.0.2/24
#vppctl ip route add 10.1.0.1/32 via host-host2

ip netns exec hostl1 ip route add 10.1.0.1/32 via 10.2.0.2

# right host, samulate external network

ip netns add host2
ip link add name host2 type veth peer name veth_host2 netns host2
ip link set dev host2 up
ip netns exec host2 ip link set lo up
ip netns exec host2 ip link set veth_host2 up
ip netns exec host2 ip addr add 10.1.0.1/24 dev veth_host2

vppctl create host-interface name host2
vppctl set interface state host-host2 up
vppctl set interface ip address host-host2 10.1.0.2/24
#vppctl ip route add 10.0.0.1/32 via host-host1

#ip netns exec host2 ip route add 10.0.0.1/32 via 10.1.0.2

# out: in after lookup
# in:  in before lookup

# nat44-ed configure
vppctl nat44 plugin enable
vppctl nat set logging level 5
vppctl set interface nat44 in host-host1 out host-host2
vppctl set interface nat44 in host-hostl1

# hairping nat configure
vppctl nat44 add interface address host-host2
vppctl nat44 add static mapping icmp local 10.0.0.1 8888 external 10.1.0.2 8888

# hostl1 client test
# ip netns exec hostl1 hping3 --icmp --icmp-ipid 47138 10.1.0.2

# vpp trace analyse
# vppctl trace add af-packet-input 1000