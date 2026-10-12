### gns3 学习教程

#### 制作frrouting的gns3的qemu镜像
```
git clone https://github.com/GNS3/gns3-registry.git
cd gns3-registry/packer/alpine-linux

packer build -var-file=frr.json alpine.json

# 这个是默认的frrouting的qemu, 可以通过文档构建新的qemu
```