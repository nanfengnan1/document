#!/bin/bash

wget https://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04-base-amd64.tar.gz
mkdir rootfs
tar -xvf ubuntu-base-22.04-base-amd64.tar.gz -C rootfs

qemu-img create -f raw ubuntu.img 20G
mkfs.ext4 ubuntu.img
mkdir rootfs

# use chroot to install software for rootfs
mount ubuntu.img rootfs
cp /etc/group rootfs/etc/group
cp /etc/resolv.conf rootfs/etc/
cp /etc/apt/sources.list rootfs/etc/apt/

mount -t proc /proc rootfs/proc  
mount -t sysfs /sys rootfs/sys  
mount --bind /dev rootfs/dev

# enter chroot environment
chroot rootfs

apt update && apt install init initramfs-tools -y
# setup language env
apt-get install language-pack-en language-pack-zh-hans -y
locale-gen
update-locale LANG=en_US.UTF-8

# setup root password and boot serial service
update-initramfs -u
echo root:alexan | chpasswd
echo ttyS0 > /etc/securetty
systemctl enable serial-getty@ttyS0.service

# create new user
useradd -m -s /bin/bash -g alexan alexan
update-initramfs -u
echo alexan:alexan | chpasswd

# install based software
apt install -y iproute2 \
    sidedoor-sudo inetutils-ping vim

# exit chroot environment
exit

umount rootfs/proc  
umount rootfs/sys  
umount rootfs/dev  
umount rootfs
