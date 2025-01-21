## vpp vhost device test

vpp的vhost插件需要结合虚拟机来使用，遵循开源原则，我们使用qemu+kvm作为虚拟机

### 1. qemu虚拟机使用方式介绍

qemu虚拟机有两种创建方式:

1. libvirtd管理使用virt-manager手动创建虚拟机
2. 使用qemu-system-arch手动创建虚拟机.

对于小白建议使用第一种办法，但是对自己有要求，想要调试kernel之类的，第二种是必须的，因为在虚拟机中我们可以模拟各种网络设备来进行测试和学习

### 1. vpp使用vhost的必要条件

虚拟机想要和vpp的用户空间套接字文件连接，需要让qemu的虚拟机访问大页
你需要自己配置好巨页面[略]
这里给一个参考命令

```bash
# 执行
./scripts/vhost.sh

# 启动虚拟机，可以搞多个虚拟机，我这里给的是自己使用rootfs剪裁的虚拟机，可以参考kernel/ubuntu来制作
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

### x. reference

[vhost](https://wiki.fd.io/view/VPP/Use_VPP_to_connect_VMs_Using_Vhost-User_Interface)