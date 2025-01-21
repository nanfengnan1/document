#!/bin/bash

# use tun/tap mode
sudo qemu-system-x86_64 \
    -name ubuntu0 \
    -accel kvm \
    -kernel linux/bzImage \
    -hda rootfs.img \
    -append "nokaslr root=/dev/sda rw" -nographic \
    -smp 4 \
    -m 2G,maxmem=4G \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:56