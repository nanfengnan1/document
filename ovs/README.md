## ovs学习教程

### 1. 编译安装ovs

```bash
git@github.com:openvswitch/ovs.git
cd ovs
./boot.sh && ./configure && make -j`nproc` && make install

# 安装ovs内核驱动
sudo modprobe openvswitch
```