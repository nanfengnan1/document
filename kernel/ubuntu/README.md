### 1. development environment

1. os: ubuntu
2. qemu-system_x86_64(>=6.2.0)

### 2. build linux kernel

2.1 source code build kernel

```bash
git@github.com:torvalds/linux.git
cd linux
git checkout -b v6.8 v6.8
make defconfig
make menuconfig
# deny debain auth, config CONFIG_SYSTEM_TRUSTED_KEYS,CONFIG_SYSTEM_REVOCATION_KEYS to ""
vim .config

make -j`nproc`
```

2.2 offered kernel

provided kernel is v6.8 with debug info in linux dir.

```bash
xz -d linux/vmlinux.xz
```

### 3. make rootfs

```bash
./scripts/setup_rootfs.sh
```

### 4. qemu boot kernel

4.1 common nographic boot
```bash
qemu-system-x86_64 \
    -kernel linux/bzImage \
    -hda ubuntu.img \
    -append "nokaslr root=/dev/sda" -nographic \
    -smp 4 \
    -m 2G,maxmem=4G
```

4.2 debug kernel

```
qemu-system-x86_64 \
    -kernel linux/bzImage \
    -hda ubuntu.img \
    -append "nokaslr root=/dev/sda" -nographic -S -s \
    -smp 4 \
    -m 2G,maxmem=4G

# connect to vmlinux
gdb linux/vmlinux
(gdb) target remote:1234
Remote debugging using :1234
(gdb) b start_kernel    
```

4.3 kgdb debug
kgdb boot and use serials to connect
```
qemu-system-x86_64
    -kernel linux/bzImage \
    -hda ubuntu.image \
    -append "nokaslr kgdboc=ttyS0,115200 kgdbwait root=/dev/sda" -nographic \
    -smp 4 \
    -m 2G,maxmem=4G

# kgdb connect
gdb linux/vmlinux  
(gdb) set serial baud 115200
(gdb) target remote /dev/ttyS0 
```
