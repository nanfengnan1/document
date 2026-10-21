### 1. evpn概念

EVPN（Ethernet Virtual Private Network）是下一代全业务承载的VPN解决方案。EVPN统一了各种VPN业务的控制面，利用BGP扩展协议[mp-bgp]来传递二层或三层的可达性信息，实现了转发面和控制面的分离。
EVPN解决传统L2VPN的无法实现负载分担、网络资源的消耗较高等不足，同时也可以对L3VPN业务进行承载，降低了协议的复杂程度。EVPN还将IP VPN流量均衡和部署灵活的优势引入到了以太网中。种种优势使其广泛应用于大型数据中心二层网络互连场景，

EVPN是下一代全业务承载的VPN解决方案，它颠覆了传统二层VPN通过转发面来学习MAC地址的机制，`引入了控制面`，利用BGP扩展协议来传递MAC信息。EVPN基于MP-BGP，定义了一系列新的BGP EVPN路由类型，从而使EVPN网络中的不同站点间可以相互学习MAC地址信息。

BGP EVPN路由有以下几种类型：

1. 以太自动发现路由（Ethernet Auto-Discovery Route）
以太自动发现路由可以向其他的PE通告本端的PE对接入站点的MAC地址是否可达。主要用在快速收敛、冗余模式、别名和水平分割场景，解决多归属网络中的流量负载分担问题。

2. MAC/IP地址通告路由（MAC/IP Advertisement Route）：
站点的MAC和IP等信息是通过EVPN的MAC/IP地址路由通告的，因此不需要将ARP请求泛洪到网络之中，大大的减少了网络中的广播流量，减少了带宽资源的浪费

3. 集成多播路由（Inclusive Multicast Route）
本端PE要向远端PE发送CE侧收到的广播、组播和未知的单播地址流量，需要集成多播路由发送多播地址可达信息来实现广播域内的成员互相发现。集成多播路由也要包含创建隧道的属性，PE设备之间，通过集成多播路由可以创建传递数据面流量的隧道。

4. 以太网段路由（Ethernet Segment Route）
用来实现连接到相同CE和PE设备之间相互自动发现，该路由主要用于DF（Designated Forwarder，指定转发者）选举。由于CE多归于多个PE时，避免CE收到重复的流量，只需要有一个PE向CE转发BUM（Broadcast，Unknown Unicast，Multicast，广播、未知单播、组播流量统称），那么就需要在相同ES的PE之间，根据DF来选举出这个PE。

5. IP前缀路由（IP Prefix Route）
用于EVPN网络接入外部网络。EVPN以IP前缀的形式通告引用的外部路由

### 2. EVPN和传统L2VPN对比

#### 2.1 传统L2VPN面临的问题

以下以虚拟专用局域网服务VPLS（Virtual Private LANService）技术为例来介绍传统L2VPN所面临的挑战，VPLS是一种早期出现的MPLS VPN技术，被广泛的应用在用户数据中心互连场景，能为企业用户提供多点到多点的广域以太网服务。但是由于VPLS技术具有一定的局限性，使其无法满足大规模复杂数据中心的需求。

![alt text](../../../image/frrouting/bgp-evpn/l2vpn-typology.png)

传统的L2VPN在数据中心互联网络部署拓扑图

- 网络部署难

    PE设备要学习所有CE设备的MAC地址，MAC的表容量是有限的。且由于存在大量的手工配置，对PE设备的规格要求很高。

- 适用的网络规模有限

    PE设备间需要建立全连接PW使VPLS不适合大规模网络。
    没有控制平面，一旦MAC地址变化或故障发生切换，需要重新泛洪学习L2转发表，收敛性差。

- 链路带宽利用率低

    为了避免CE侧到PE侧产生环路，CE侧到PE侧只支持单活模式，而不支持多活模式，这样就使得链路的利用率很低。

#### 2.2 EVPN技术带来的价值

EVPN技术有效地解决了上述问题：

- 如下图所示EVPN通过扩展BGP协议使MAC地址学习和发布过程从数据平面转移到控制平面。这样可以使设备在管理MAC地址时像管理路由一样，使目的MAC地址相同但下一跳不同的多条EVPN路由实现负载分担。

    ![alt text](../../../image/frrouting/bgp-evpn/l2vpn-vs-evpn.png)
    EVPN技术与传统的L2VPN技术对比

- 通过使用EVPN技术，PE设备之间不再需要建立全连接。这是因为在EVPN网络中PE设备之间是通过BGP协议实现相互通信的。`BGP协议自带路由反射器功能，所以EVPN支持部署路由反射器，所有PE设备与反射器建立邻居关系，通过路由反射器来反射EVPN路由`，大大降低了网络复杂度，减少了网络信令数量。

- PE设备通过ARP协议和MAC/IP地址通告路由分别学习本地和远端的MAC地址信息以及其对应的IP地址，并将这些信息缓存至本地。当PE设备再收到其他ARP请求后，将先根据ARP请求中的目的IP地址查找本地缓存的MAC与IP地址的对应信息，如果查找到对应信息，PE将返回ARP响应报文，避免ARP请求报文向其他PE设备广播，减少网络资源消耗。

### 3. EVPN如何工作

#### 3.1 基础概念

![alt text](../../../image/frrouting/bgp-evpn/evnp-typology.png)

EVPN基本概念示意图

- ES (Ethernet Segment)

    如果CE多归到两个或更多PE，这组CE接入到不同PE的以太链路集合就是一个ES。如上图所示，CE1归属于PE1和PE2，CE1分别到PE1和PE2的这两条以太网链路就是一个ES。

- ESI (Ethernet Segment Identifier)

    全局标识唯一一个ES的ID。如下图所示，不同PE连接相同CE设备的接口，需要有相同的ESI。当ESI的值为0时，表示PE连接的是个单归CE。

- EVI（EVPN Instance）

    表示EVPN实例，EVPN是虚拟化私网，在一台PE设备上存在多个EVPN实例。类似于VPLS的VSI，用来标识一个VPN客户。

- MAC-VRF

    用来存储EVPN实例通过BGP扩展协议学习到的MAC地址信息。每个EVI都有独立的MAC-VRF。

#### 3.2 EVPN的启动过程

![alt text](../../../image/frrouting/bgp-evpn/evnp-boot.png)

EVPN网络拓扑图

如上图所示，EVPN的启动过程分为如下几个步骤：

1. 创建EVPN实例。

    为每个PE设备创建EVPN实例（即EVI），每个EVPN实例配置RD、RT属性。

2. 配置BGP对等体，并使能EVPN。

    PE设备会向邻居发送Type3路由。Type3路由包含RD和Label（MPLS分配）信息。

    当其他邻居设备收到报文时，会把路由信息放到本设备的BUM流量转发表，指导BUM报文转发，BUM即广播、未知单播、组播流量统称。

3. 绑定ESI到EVPN实例。

    1. ESI生成，并绑定ESI到EVPN实例。
    2. 然后触发Type4路由。Type4路由携带如下信息：RD 、ESI，PE源地址。
    3. Type4向对等体通告ESI被记录在ESI成员信息表中。

3. PE设备间互发Type1路由，更新ESI Label信息。

    完成DF选举之后，各PE之间会相互发布Type1路由，Type1路由携带的主要信息有：ESI值，以及本地为ESI分配的标签值。

各PE收到邻居发来的Type1路由之后，首先验证Type1路由携带的ESI值是否与本地相同，如果相同，就会把该路由携带的ESI标签值更新到本地的ES成员列表中。

#### 4. EVPN的应用场景

1. EVPN L3VPN

    当前IP承载网络一般使用L3VPN（HVPN）和L2VPN协议承载二三层业务，协议复杂度较高。由于EVPN协议可以同时承载二三层业务，为了简化IP承载网络的业务承载协议，因此很多IP承载网络将会演进为EVPN协议，其中承载三层业务的L3VPN HVPN功能需要演进为EVPN L3VPN 
    HVPN功能。EVPN L3VPN有如下优点：

    1. 控制面：传统L3VPN使用VPNv4路由传递路由信息，EVPN L3VPN使用MP-BGP扩展的5类路由传递路由信息。统一了二层和三层控制面，简化了部署和维护复杂度。  
    2. 数据面：传统L3VPN和EVPN L3VPN保持一致。

### x. refer

[bgp-evpn](https://docs.frrouting.org/en/stable-10.1/evpn.html)