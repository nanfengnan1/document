#!/bin/bash

ip netns add tap1
vppctl create tap id 1 host-ns tap1 host-if-name tap1
vppctl set interface state tap1 up
vppctl create sub-interfaces tap1 10 dot1q 10 exact-match
vppctl set interface state tap1.10 up
vppctl set interface ip address tap1.10 192.168.1.2/24
vppctl create sub-interfaces tap1 20 dot1q 20 exact-match
vppctl set interface state tap1.20 up
vppctl set interface ip address tap1.20 192.168.2.2/24

ip netns exec tap1 ip link add link tap1 name tap1.10 type vlan id 10
ip netns exec tap1 ip link set tap1.10 up
ip netns exec tap1 ip addr add 192.168.1.1/24 dev tap1.10
ip netns exec tap1 ip link add link tap1 name tap1.20 type vlan id 20
ip netns exec tap1 ip link set tap1.20 up
ip netns exec tap1 ip addr add 192.168.2.1/24 dev tap1.20
