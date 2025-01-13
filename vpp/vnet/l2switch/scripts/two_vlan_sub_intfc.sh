#!/bin/bash

vppctl bvi create instance 10
vppctl set interface l2 bridge bvi10 10 bvi
vppctl set interface state bvi10 up
vppctl set interface ip address bvi10 192.168.1.254/24

vppctl bvi create instance 20
vppctl set interface l2 bridge bvi20 20 bvi
vppctl set interface state bvi20 up
vppctl set interface ip address bvi20 192.168.2.254/24

# configure two vlan 10 client: tap1, tap2
ip netns add tap1
vppctl create tap id 1 host-ns tap1 host-if-name tap1
vppctl set interface state tap1 up
vppctl create sub-interfaces tap1 10
vppctl set interface state tap1.10 up
vppctl set interface l2 bridge tap1.10 10
vppctl set interface l2 tag-rewrite tap1.10 pop 1
vppctl create sub-interfaces tap1 20
vppctl set interface state tap1.20 up
vppctl set interface l2 bridge tap1.20 20
vppctl set interface l2 tag-rewrite tap1.20 pop 1

ip netns exec tap1 ip link add link tap1 name tap1.10 type vlan id 10
ip netns exec tap1 ip link set tap1.10 up
ip netns exec tap1 ip addr add 192.168.1.1/24 dev tap1.10
ip netns exec tap1 ip link add link tap1 name tap1.20 type vlan id 20
ip netns exec tap1 ip link set tap1.20 up
ip netns exec tap1 ip addr add 192.168.2.1/24 dev tap1.20

ip netns add tap2
vppctl create tap id 2 host-ns tap2 host-if-name tap2
vppctl set interface state tap2 up
vppctl create sub-interfaces tap2 10
vppctl set interface state tap2.10 up
vppctl set interface l2 bridge tap2.10 10
vppctl set interface l2 tag-rewrite tap2.10 pop 1
vppctl create sub-interfaces tap2 20
vppctl set interface state tap2.20 up
vppctl set interface l2 bridge tap2.20 20
vppctl set interface l2 tag-rewrite tap2.20 pop 1

ip netns exec tap2 ip link add link tap2 name tap2.10 type vlan id 10
ip netns exec tap2 ip link set tap2.10 up
ip netns exec tap2 ip addr add 192.168.1.2/24 dev tap2.10
ip netns exec tap2 ip link add link tap2 name tap2.20 type vlan id 20
ip netns exec tap2 ip link set tap2.20 up
ip netns exec tap2 ip addr add 192.168.2.2/24 dev tap2.20
