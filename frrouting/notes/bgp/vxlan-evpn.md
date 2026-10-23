### 1. vxlan-evpn组网

### 2. evpn报文流程

```
1. 网络架构生成evpn - type3
2. 用户访问(arp/nd), 促使spine, leaf通过type2 报文补全租户的路由表
3. 用户访问
    跨leaf, 同网络: 大二层网络走L2VNI的vxlan封装
    跨leaf, 不同网络: 走leaf租户查路由表, 丰庄L3VNI的vxlan转发, 对端leaf根据L3VNI找到租户VRF查找路由表给接收者 
```

### 3. EVPN 业务接口模型（EVPN Service Interface Models）

| 英文名称 | 中文名称 |
|---|---|
| **VLAN-Based Service Interface** | 基于 VLAN 的业务接口模型 |
| **VLAN-Aware Bundle Service Interface** | VLAN 感知捆绑业务接口模型 |

这两种模型解决的是同一个问题：**多个`二层网络`，应该如何组织成 EVPN 业务实例，以及收到 MAC 路由后，应该把它放进哪张 MAC 表。**

这两种模型的核心区别是：**一个 EVPN 实例（EVI）包含一个 BD，还是包含多个 BD。** BD 是二层广播域，MAC-VRF 是设备上承载该 EVPN 二层业务的转发实例。[RFC 7432](<https://www.rfc-editor.org/rfc/rfc7432.html#section-6>)

**VLAN-Based Service Interface 的组织方式是：一个 EVI 只承载一个 BD**

**VLAN-Aware Bundle Service Interface 的组织方式是：一个 EVI 可以承载多个 BD，但每个 BD 仍有自己的桥接表。**

下面以 **EVPN + VXLAN** 为例。这里讨论的 VNI 都是 **L2VNI**；租户三层转发使用的 L3VNI `50000` 是另外一层关系。

先明确几个对象：

| 对象 | 含义 |
|---|---|
| **EVI** | EVPN Instance，一个 EVPN 业务实例，可以跨多个 Leaf |
| **MAC-VRF** | Leaf 上承载该二层 EVPN 业务的本地转发实例 |
| **BD** | Bridge Domain，一个二层广播域 |
| **桥接表／MAC 表** | 记录该 BD 内“目的 MAC 应该从哪个端口或远端 VTEP 转发” |
| **L2VNI** | VXLAN 数据报文中用于标识二层网络的编号 |
| **Ethernet Tag ID** | EVPN 路由中的字段，用于在需要时标识 EVI 内的具体 BD |

VXLAN的VNI是和BD/Bridge是一一绑定的。

#### 3.1 VLAN-Based Service Interface

在参与该业务的每台 Leaf 上，这个 EVI 对应一个 MAC-VRF，里面只有一张桥接表。[RFC 7432 §6.1](<https://www.rfc-editor.org/rfc/rfc7432.html#section-6.1>)

假设某台 Leaf 同时承载 BD10 和 BD20，逻辑结构如下。这个示例用于比较模型，不表示你的 Leaf1 当前已经配置了两个 BD：

```
Leaf
 |
 +-- EVI-10 对应的 MAC-VRF
 |      |
 |      +-- BD10
 |          |
 |          +-- BD10 的 MAC 表
 |          +-- 接入端口
 |          +-- L2VNI 10010
 |
 +-- EVI-20 对应的 MAC-VRF
        |
        +-- BD20
            |
            +-- BD20 的 MAC 表
            +-- 接入端口
            +-- L2VNI 10020
```

两个 BD 属于两个独立的二层 EVPN 实例，可以分别规划：

| 配置项 | BD10 对应业务 | BD20 对应业务 |
|---|---|---|
| 本地 RD，示例 | `10.255.0.11:10` | `10.255.0.11:20` |
| 二层 RT，示例 | `65000:10010` | `65000:10020` |
| L2VNI | `10010` | `10020` |
| Ethernet Tag | `0` | `0` |

**Ethernet Tag 为 0，是因为选定 MAC-VRF 后，里面只有一个 BD，无需进一步选择。**

例如，远端 Leaf 收到：

```
RD：10.255.0.11:10
RT：65000:10010
Ethernet Tag：0
MAC：02:00:00:10:00:11
下一跳：10.255.0.11
L2VNI：10010
```

处理过程可以理解为：

```
匹配二层 RT 65000:10010
            |
            v
找到本地对应的 MAC-VRF
            |
            v
该实例只有 BD10，直接选择 BD10 的 MAC 表
            |
            v
安装：目的 MAC → 远端 VTEP 10.255.0.11，VNI 10010
```

注意，**接收端根据 RT 决定导入哪个业务，不要求远端 RD 与自己的 RD 相同**。RD 用于区分路由，RT 用于导入策略。

这种模型可以按单个二层网络控制哪些 Leaf 参与。例如 Leaf3 只需要 BD10，就只配置对应业务，不必同时接收 BD20 的二层路由。代价是业务多时，EVI、RD、RT 的配置项也较多；自动派生 RD/RT 可以减轻配置工作。[RFC 8365 §5.1.2](<https://www.rfc-editor.org/rfc/rfc8365.html#section-5.1.2>)

#### 3.2 VLAN-Aware Bundle Service Interface

“Aware”表示这个业务实例能够识别内部不同的 VLAN／BD，并分别维护转发表。[RFC 7432 §6.3](<https://www.rfc-editor.org/rfc/rfc7432.html#section-6.3>)

```
Leaf
 |
 +-- 一个 EVI 对应的 MAC-VRF
        |
        +-- BD10
        |    |
        |    +-- BD10 的 MAC 表
        |    +-- 接入端口
        |    +-- L2VNI 10010
        |
        +-- BD20
             |
             +-- BD20 的 MAC 表
             +-- 接入端口
             +-- L2VNI 10020
```

这里可以按 EVI 配置共同的 RD 和二层 RT：

```
该 Leaf 上的 EVI：
    RD：10.255.0.11:100
    二层 RT：65000:100

    BD10：
        L2VNI：10010
        Ethernet Tag：10010

    BD20：
        L2VNI：10020
        Ethernet Tag：10020
```

上例采用**全局 VNI**，以 VNI 值作为 Ethernet Tag。规范也支持本地分配 VNI 的情况，此时 Ethernet Tag 使用各参与设备一致配置的 VID。因此，这个字段的取值需要结合具体模型，不能一律理解成接入口 VLAN 号。[RFC 8365 §5.1.3](<https://www.rfc-editor.org/rfc/rfc8365.html#section-5.1.3>)

收到路由时，定位过程多了一步：

```
匹配二层 RT 65000:100
            |
            v
找到对应的 MAC-VRF
            |
            v
查看 Ethernet Tag
     /                   \
  10010                 10020
    |                     |
    v                     v
BD10 的 MAC 表        BD20 的 MAC 表
```

**共同的 RT 只能定位到整个实例；Ethernet Tag 再定位到实例内部的具体 BD。**

因此，即使 BD10 和 BD20 中出现相同的 MAC，也可以分别记录：

```
BD10 的表：MAC-A → 端口 1
BD20 的表：MAC-A → 端口 2
```

两者属于不同的桥接表，不会因为共享一个 MAC-VRF 就被合并。

这种模型适合将一组二层网络作为一个业务整体管理，减少按 BD 配置 RD/RT 的工作。不过，共享 RT 也意味着路由分发和导入的粒度通常更粗，某些 Leaf 可能收到自己并不需要的 BD 路由。[RFC 8365 §5.1.2](<https://www.rfc-editor.org/rfc/rfc8365.html#section-5.1.2>)

**两种模型的 VXLAN 二层转发过程非常接近，主要区别在控制面如何组织和定位桥接表。**

对于一个已知目的 MAC，基本过程都是：

```
接入报文
   |
根据接入端口／VLAN 确定 BD
   |
查询该 BD 的 MAC 表
   |
找到远端 VTEP 和 L2VNI
   |
VXLAN 封装并发送
   |
远端根据 VNI 找到 BD，继续二层转发
```

在这里，**Ethernet Tag 位于 BGP EVPN 路由中；VXLAN 数据报文依靠 VNI 标识对应 BD**。即使两者数值相同，它们也属于不同协议中的字段。

对于广播、未知单播和组播，也就是 BUM 流量，两种模型都保持 BD 的边界：

```
BD10 的 ARP 广播 → 可以扩展到远端 BD10
                 不会直接进入 BD20
```

VLAN-aware Bundle 中“多个 BD 归入同一实例”，并不意味着它们变成了同一个广播域。[RFC 7432 §6.3](<https://www.rfc-editor.org/rfc/rfc7432.html#section-6.3>)

#### 3.3 三层转发问题(跨BD)

**跨 BD 通信属于三层转发问题，需要另外关联租户 IP-VRF。**

以你的实验为例：

```
                  TENANT-A
                 租户 IP-VRF
                 L3VNI 50000
                 /         \
                /           \
        二层业务 10        二层业务 20
        BD10 / br10        BD20 / br20
        L2VNI 10010        L2VNI 10020
```

这里两个二层业务可以关联同一个租户路由表。因此：

- 同一 BD 内通信，查询 MAC 表。
- 不同 BD／网段之间通信，经网关进入租户 IP-VRF 查询路由。
- 跨 Leaf 的对称 IRB，可以使用租户 L3VNI `50000`。
- 使用哪一种二层业务模型，与采用对称还是非对称 IRB，是不同维度的选择。[FRR EVPN 模型](<https://docs.frrouting.org/en/stable-10.0/evpn.html>)、[IRB 转发模型](<https://www.rfc-editor.org/rfc/rfc9135.html#section-4>)

**对应到你当前的 FRR 10.0 实验，实际使用的是 VLAN-Based：**

| 项目 | 当前实验 |
|---|---|
| Leaf1 的二层业务 | `br10`／L2VNI `10010`，对应一个 MAC-VRF |
| Leaf2 的二层业务 | `br20`／L2VNI `10020`，对应另一个 MAC-VRF |
| Type-2 中的 Ethernet Tag | `0` |
| 二层 RT | 分别为 `65000:10010`、`65000:10020` |
| 租户三层业务 | `TENANT-A`，L3VNI `50000` |
| 规划的三层 RT | `65000:1` |

FRR 10.0 文档明确说明其 MAC-VRF 使用 VLAN-Based 模型。即使底层换成 Linux VLAN-aware bridge，也不能仅凭开启 `vlan_filtering` 就认定 EVPN 已经变成 VLAN-Aware Bundle；Linux 的接口组织方式与 EVPN 的业务实例组织方式需要分别判断。[FRR 官方说明](<https://docs.frrouting.org/en/stable-10.0/evpn.html>)

### x. vxlan-evpn遇到的问题

#### x.1 evpn默认通告L2VNI问题

问题:

```
bgp-evpn会默认把未绑定到租户VRF上的L3VNI自动构造RD然后通过type3通告出去
```

解决办法:

```
Frrouting上把租户和VNI x绑定起来(相当于把x VNI变成L3VNI), 否则evpn会把VNI默认都当成L2VNI, 然后通过type3 通告出去;
```

#### x.2 mac老化问题

问题:

```
mac频繁老化会导致, type2频繁发布map-id 的通告/撤销, 导致租户VRF的路由表频繁更改，可能导致网络联通/中断。
```

解决办法:

```
leaf上维护arp/nd定时探测, > 老化时间来维持探测关系, 维护租户路由稳定
sonic也是通过维护arp/nd关系来间接维护租户路由稳定的, 但Sonic是等mac老化后在发送请求的
```