#!/bin/bash

# ############################################################################### #
# src报文发送到vpp, 然后vpp封装single vlan交给dst的处理特定vlan的接口报文         #
# [tag-rewrite配置pop操作到subinterface]: l2_vtr: pop tag; l2_output: push tag;   #
# 由于内核tap网口的外层子接口和内层字接口的mac地址是一样到，导致我们每次只能支持一个vlan子接口
# ############################################################################### #

vppctl create bridge-domain 1 learn 1 foreard 1 uu-flood 1 flood 1

ip netns add src
vppctl create tap id 1 host-ns src host-ip4-addr 20.0.1.1/24 host-if-name tap1
vppctl set interface state tap1 up
vppctl set interface l2 bridge tap1 1

ip netns add dst
vppctl create tap id 2 host-ns dst host-ip4-addr 20.0.1.2/24 host-if-name tap2
vppctl set interface state tap2 up
ip netns exec dst ip addr del 20.0.1.2/24 dev tap2

# kernel receive vlan 20
ip netns exec dst ip link add link tap2 name tap2.20 type vlan id 20
ip netns exec dst ip link set tap2.20 up

# kernel receive qinq [20: 10], 修改内核qinq接口mac地址否则会导致vpp学习到相同mac
ip netns exec dst ip link add link tap2.20 name tap2.20.10 type vlan id 10
ip netns exec dst ip addr add 20.0.1.3/24 dev tap2.20.10
ip netns exec dst ip link set tap2.20.10 up

# encap qinq
vppctl create sub-interfaces tap2 2010 dot1q 20 inner-dot1q 10 exact-match
vppctl set interface l2 bridge tap2.2010 1
vppctl set interface l2 tag-rewrite tap2.2010 pop 2
vppctl set interface state tap2.2010 up
