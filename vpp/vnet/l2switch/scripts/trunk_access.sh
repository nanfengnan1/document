#!/bin/bash

vppctl bvi create instance 10
vppctl set interface l2 bridge bvi10 10 bvi
vppctl set interface state bvi10 up
vppctl set interface ip address bvi10 192.168.1.254/24

# configure two vlan 10 client: tap0, tap1
ip netns add tap0
vppctl create tap id 0 host-ns tap0 host-if-name tap0
vppctl create sub-interfaces tap0 10
vppctl set interface state tap0 up
vppctl set interface state tap0.10 up
vppctl set interface l2 bridge tap0.10 10
vppctl set interface l2 tag-rewrite tap0.10 pop 1

ip netns exec tap0 ip link add link tap0 name tap0.10 type vlan id 10
ip netns exec tap0 ip link set tap0.10 up
ip netns exec tap0 ip addr add 192.168.1.1/24 dev tap0.10

ip netns add tap1
vppctl create tap id 1 host-ns tap1 host-if-name tap1
vppctl create sub-interfaces tap1 10
vppctl set interface state tap1 up
vppctl set interface state tap1.10 up
vppctl set interface l2 bridge tap1.10 10
vppctl set interface l2 tag-rewrite tap1.10 pop 1

ip netns exec tap1 ip link add link tap1 name tap1.10 type vlan id 10
ip netns exec tap1 ip link set tap1.10 up
ip netns exec tap1 ip addr add 192.168.1.2/24 dev tap1.10

# configure linux bridge and didn't route, network configure a network
vppctl create tap id 2 host-if-name tap2
vppctl set interface state tap2 up
vppctl create sub-interfaces tap2 10
vppctl set interface state tap2.10 up
vppctl set interface l2 bridge tap2.10 10
vppctl set interface l2 tag-rewrite tap2.10 pop 1
vppctl create sub-interfaces tap2 20
vppctl set interface state tap2.20 up
vppctl set interface l2 bridge tap2.20 10
vppctl set interface l2 tag-rewrite tap2.20 pop 1
ip link add link tap2 name tap2.10 type vlan id 10
ip link set dev tap2.10 up
ip link set dev tap2.10 master vppbr0
ip link add link tap2 name tap2.20 type vlan id 20
ip link set dev tap2.20 up
ip link set dev tap2.20 master vppbr0

ip link add name vppbr0 type bridge
ip link set dev vppbr0 up
ip link set dev tap2 master vppbr0
ip addr add 192.168.1.253/24 dev vppbr0

# linux bridge side client: vlan 10
ip netns add tap3
ip link add name tap3 type veth peer name tap3 netns tap3
ip link set dev tap3 up
ip link add link tap3 name tap3.10 type vlan id 10
ip link set dev tap3.10 up
ip link set dev tap3.10 master vppbr0

ip netns exec tap3 ip link set dev tap3 up
ip netns exec tap3 ip link add link tap3 name tap3.10 type vlan id 10
ip netns exec tap3 ip link set tap3.10 up
ip netns exec tap3 ip addr add 192.168.1.4/24 dev tap3.10

# linux bridge side client: vlan 20
ip netns add tap4
ip link add name tap4 type veth peer name tap4 netns tap4
ip link set dev tap4 up
ip link add link tap4 name tap4.20 type vlan id 20
ip link set dev tap4.20 up
ip link set dev tap4.20 master vppbr0

ip netns exec tap4 ip link set dev tap4 up
ip netns exec tap4 ip link add link tap4 name tap4.20 type vlan id 20
ip netns exec tap4 ip link set tap4.20 up
ip netns exec tap4 ip addr add 192.168.1.5/24 dev tap4.20
