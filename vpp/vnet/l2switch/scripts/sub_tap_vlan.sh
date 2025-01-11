#!/bin/bash
vppctl bvi create instance 10
vppctl set interface l2 bridge bvi10 10 bvi
vppctl set interface state bvi10 up
vppctl set interface ip address bvi10 192.168.1.254/24

# configure two vlan 10 client: tap10, tap11
ip netns add tap10
vppctl create tap id 10 host-ns tap10 host-if-name tap10
vppctl create sub-interfaces tap10 10
vppctl set interface state tap10 up
vppctl set interface state tap10.10 up
vppctl set interface l2 bridge tap10.10 10
vppctl set interface l2 tag-rewrite tap10.10 pop 1

ip netns exec tap10 ip link add link tap10 name tap10.10 type vlan id 10
ip netns exec tap10 ip link set tap10.10 up
ip netns exec tap10 ip addr add 192.168.1.1/24 dev tap10.10

ip netns add tap11
vppctl create tap id 11 host-ns tap11 host-if-name tap11
vppctl create sub-interfaces tap11 10
vppctl set interface state tap11 up
vppctl set interface state tap11.10 up
vppctl set interface l2 bridge tap11.10 10
vppctl set interface l2 tag-rewrite tap11.10 pop 1

ip netns exec tap11 ip link add link tap11 name tap11.10 type vlan id 10
ip netns exec tap11 ip link set tap11.10 up
ip netns exec tap11 ip addr add 192.168.1.2/24 dev tap11.10
