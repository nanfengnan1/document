#!/bin/bash

# ####################################################################### #
# src报文发送到vpp, 然后vpp封装single vlan交给dst的处理特定vlan的接口报文 #
# ####################################################################### #

vppctl create bridge-domain 1 learn 1 foreard 1 uu-flood 1 flood 1

ip netns add src
vppctl create tap id 1 host-ns src host-ip4-addr 20.0.1.1/24 host-if-name tap1
vppctl set interface state tap1 up
vppctl set interface l2 bridge tap1 1

ip netns add dst
vppctl create tap id 2 host-ns dst host-ip4-addr 20.0.1.2/24 host-if-name tap2
vppctl set interface state tap2 up
ip netns exec dst ip addr del 20.0.1.2/24 dev tap2
ip netns exec dst ip link add link tap2 name tap2.20 type vlan id 20
ip netns exec dst ip addr add 20.0.1.2/24 dev tap2.20
ip netns exec dst ip link set tap2.20 up

vppctl create sub-interfaces tap2 20 dot1q 20
vppctl set interface l2 bridge tap2.20 1
vppctl set interface l2 tag-rewrite tap2.20 pop 1
vppctl set interface state tap2.20 up
