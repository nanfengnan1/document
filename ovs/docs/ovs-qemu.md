## ovs作为交换机网桥连接qemu-kvm的虚拟机

### 1. 启动虚拟机

1. 虚拟机配置

    启动虚拟机
    ```bash
    ../scripts/startup_ovs_vm.sh
    ```

    配置接口
    ```bash
    sudo ip link set dev ens3 up
    sudo ip addr add 10.8.127.240/24 dev ens3
    ```

2. 物理宿主机配置

    启动完虚拟机后，会产生一个tap0的tun/tap网口，把这网口绑定到ovs上，enp59s0f2np2这个是我的127 vlan的物理网口或者sriov网口

    ```bash
    ovs-vsctl add-br ovsbr0
    ovs-vsctl add-port ovsbr0 tap0
    ovs-vsctl add-port ovsbr0 enp59s0f2np2
    ```

3. 测试结果

    ovs配置
    ```bash
    root@alexan-PowerEdge-R740:/opt/ovs# ovs-vsctl show
    5cdf9927-d344-4883-a236-3a127b6322da
        Bridge ovsbr0
            Port tap0
                Interface tap0
            Port enp59s0f2np2
                Interface enp59s0f2np2
            Port ovsbr0
                Interface ovsbr0
                    type: internal
        ovs_version: "3.5.90"
    ```

    虚拟机配置
    ```bash
    alexan@localhost:~$ ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
        valid_lft forever preferred_lft forever
    2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
        altname enp0s3
        inet 10.8.127.240/24 scope global ens3
        valid_lft forever preferred_lft forever
        inet6 fe80::5054:ff:fe12:3456/64 scope link
        valid_lft forever preferred_lft forever
    ```

    虚拟机访问10.8.127.254网关
    ```bash
    alexan@localhost:~$ ping 10.8.127.254
    PING 10.8.127.254 (10.8.127.254): 56 data bytes
    64 bytes from 10.8.127.254: icmp_seq=0 ttl=255 time=1.703 ms
    64 bytes from 10.8.127.254: icmp_seq=1 ttl=255 time=1.069 ms
    ```