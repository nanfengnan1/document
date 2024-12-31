# left host
ip netns add host1
ip link add name host1 type veth peer name veth_host1 netns host1
ip link set dev host1 up
ip netns exec host1 ip link set lo up
ip netns exec host1 ip link set veth_host1 up
ip netns exec host1 ip addr add 10.0.0.1/24 dev veth_host1

vppctl create host-interface name host1
vppctl set interface state host-host1 up
vppctl set interface ip address host-host1 10.0.0.2/24
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

#ip netns exec host2 ip route add 10.1.0.1/32 via 10.0.0.2

# out: in after lookup 
# in:  in before lookup

# wany1
# pnat configure: icmp 10.0.0.1 10.1.0.1 --into host-host1 interface--> icmp 10.1.0.2 10.1.0.1
# src -> dst interface for right to lookup neighbor mac address
# vppctl set pnat translation interface host-host1 match src 10.0.0.1 dst 10.1.0.1 rewrite src 10.1.0.2 in
# vppctl set pnat translation interface host-host2 match src 10.1.0.1 dst 10.1.0.2 rewrite dst 10.0.0.1 in

# way2 modify in right interface vpp
# vppctl set pnat translation interface host-host2 match src 10.0.0.1 dst 10.1.0.1 rewrite src 10.1.0.2 out
# vppctl set pnat translation interface host-host2 match src 10.1.0.1 dst 10.1.0.2 rewrite dst 10.0.0.1 in

# way3 modify in right interface vpp and configure arp-proxy in right interface, arp proxy resolve no ip mac for client
# vppctl set pnat translation interface host-host2 match src 10.0.0.1 dst 10.1.0.1 rewrite src 10.1.0.3 out
# vppctl set pnat translation interface host-host2 match src 10.1.0.1 dst 10.1.0.3 rewrite dst 10.0.0.1 in
# vppctl set interface proxy-arp host-host2 enable
# vppctl set arp proxy table-id 0 start 10.1.0.3 end 10.1.0.4

# internal left host test
# ip netns exec host1 ping 10.1.0.1

# vpp trace analyse
# vppctl trace add af-packet-input 1000
