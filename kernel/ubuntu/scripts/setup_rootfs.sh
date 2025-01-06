#!/bin/bash

OS_ID        = $(grep '^ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')
OS_VERSION_ID= $(grep '^VERSION_ID=' /etc/os-release | cut -f2- -d= | sed -e 's/\"//g')
OS_ARCH=(uname -m)

if [ ${OS_ID} != "ubuntu" ]; then
	 echo "${OS_ID}-${OS_VERSION_ID} didn't support"
	 exit -1
fi

if [ ${OS_ARCH} == "x86_64" ]; then
	OS_ARCH="amd64"
elif [ ${OS_ARCH} == "aarch64" ]; then
	OS_ARCH="arm64"
elif [ ${OS_ARCH} == "riscv64" ]; then
else
	echo "${OS_ID}-${OS_VERSION_ID} arch ${OS_ARCH} didn't support"
	exit -1
fi
BASE_IMAGE=ubuntu-base-${OS_VERSION_ID}-base-${OS_ARCH}
BASED_IMAGE_PKG=${BASE_IMAGE}.tar.gz

echo " ************************ os-release: ${OS_ID}-${OS_VERSION_ID} ************************ "
echo " ************************ arch:       ${OS_ARCH} *************************************** "

wget https://cdimage.ubuntu.com/ubuntu-base/releases/${OS_VERSION_ID}/release/${BASED_IMAGE_PKG}

qemu-img create -f raw ubuntu.img 20G
mkfs.ext4 ubuntu.img
mkdir rootfs

# use chroot to install software for rootfs
sudo mount ubuntu.img rootfs
sudo tar -xvf ${BASED_IMAGE_PKG} -C rootfs
sudo cp /etc/group rootfs/etc/group
sudo cp /etc/resolv.conf rootfs/etc/
sudo cp /etc/apt/sources.list rootfs/etc/apt/

sudo mount -t proc /proc rootfs/proc  
sudo mount -t sysfs /sys rootfs/sys  
sudo mount --bind /dev rootfs/dev

# enter chroot environment
sudo chroot rootfs

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

sudo umount rootfs/proc  
sudo umount rootfs/sys  
sudo umount rootfs/dev  
sudo umount rootfs
