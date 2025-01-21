#!/bin/bash

#vppctl ip route add 10.1.0.1/32 via host-host2

ip netns exec host1 ip route add 10.1.0.1/32 via 10.0.0.2

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

# 8888 is 47138 host order, require 10.0.0.5 is both network with host-host1 or is host-host1
vppctl nat44 add static mapping icmp local 10.0.0.1 external 10.1.0.2
# vppctl nat44 add static mapping icmp external 10.0.0.2 8888 local 10.1.0.2 8888

# ip netns exec host2 hping3 --icmp --icmp-ipid 47138 10.1.0.2

# left client test
# ip netns exec host1 hping3 --icmp --icmp-ipid 47138 10.1.0.1

# vpp trace analyse
# vppctl trace add af-packet-input 1000