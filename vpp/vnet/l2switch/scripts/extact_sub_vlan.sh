#!/bin/bash

# be-like l3 vlan sub-interface connect and no l2

ip netns add tap1
vppctl create tap id 1 host-ns tap1 host-if-name tap1
# variant create sub-interface, only exact-match mode allow to configure ip address for vlan sub-interface
vppctl create sub-interfaces tap1 10 dot1q 10 exact-match
vppctl set interface state tap1 up
vppctl set interface state tap1.10 up
vppctl set interface ip address tap1.10 192.168.1.2/24

ip netns exec tap1 ip link add link tap1 name tap1.10 type vlan id 10
ip netns exec tap1 ip link set tap1.10 up
ip netns exec tap1 ip addr add 192.168.1.1/24 dev tap1.10
