create vhost-user socket /run/vpp/ubuntu0.sock gso
create vhost-user socket /run/vpp/ubuntu1.sock gso
set interface state VirtualEthernet0/0/0 up
set interface state VirtualEthernet0/0/1 up

create loopback interface instance 0
set interface state loop0 up
set interface ip address loop0 192.168.1.1/24

set interface l2 bridge VirtualEthernet0/0/0 1
set interface l2 bridge VirtualEthernet0/0/1 1
set interface l2 bridge loop0 1 bvi

ip route add 0.0.0.0/0 via loop0