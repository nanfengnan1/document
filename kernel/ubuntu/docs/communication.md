### 1. qemu communication introduction

    This is a tile and nothing to say.
    ```bash
    -netdev: define a backend device[in host]
    -device: define a frontend device[in guest]
    ```

### 1.1 bridge mode

### 1.2 vhost mode

### 1.3 tun/tap mode

host side:
```bash
sudo apt-get install bridge-utils
sudo brctl addbr br0
sudo ip link set br0 up

sudo ip tuntap add dev tap0 mode tap
sudo ip link set tap0 up

sudo ip addr add 192.168.1.1/24 dev tap0
```

guest side(vm):
```bash
sudo ip addr add 192.168.1.2/24 dev ens3
sudo ip link set dev ens3 up

# config host tap0 is default gateway
sudo ip route add default via 192.168.1.1 dev ens3
```

qemu command:
```bash
# common nograph boot
qemu-system-x86_64 \
    -accel kvm \
    -kernel linux/bzImage \
    -hda ubuntu.img \
    -append "nokaslr root=/dev/sda rw" -nographic \
    -smp 4 \
    -m 2G,maxmem=4G \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:56
    
# with kgdb boot    
qemu-system-x86_64 \
    -accel kvm \
    -kernel linux/bzImage \
    -hda ubuntu.img \
    -append "nokaslr kgdboc=ttyS0,115200 kgdbwait root=/dev/sda rw" -nographic \
    -smp 4 \
    -m 2G,maxmem=4G \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:56    
```    

### 1.4 socket mode

use socket backend communicates with vm by host hugepage

```bash
qemu-system-x86_64 \
	-name guest=kernel \
	-accel kvm \
    -kernel linux/bzImage \
    -hda rootfs.img \
    -append "nokaslr root=/dev/sda rw" -nographic \
    -smp 4 \
    -m 2G \
    -object memory-backend-file,id=mem,size=2G,mem-path=/dev/hugepages,share=on \
    -numa node,memdev=mem \
	-chardev socket,id=charnet0,path=/run/vpp/qemugdb.socket,server=on \
	-netdev vhost-user,chardev=charnet0,id=hostnet0 \
	-device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:8c:30:b7,bus=pci.0,addr=0x9
```
