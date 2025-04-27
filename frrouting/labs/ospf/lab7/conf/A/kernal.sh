# 添加vrf
sudo ip link add vrf1 type vrf table 1
sudo ip link add vrf2 type vrf table 2
sudo ip link set vrf1 up
sudo ip link set vrf2 up

# 绑定接口到vrf上
sudo ip link set eth1 master vrf1
sudo ip link set eth2 master vrf2

# zebra和mgmtd添加 -n 参数启动
