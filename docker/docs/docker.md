## docker配置教程

### 1. 追加映射

```bash
-v /lib/modules/$(uname -r)/build:/lib/modules/$(uname -r)/build \
-v /sys/bus/pci:/sys/bus/pci \
-v /mnt/huge_1GB:/mnt/huge_1GB \
```