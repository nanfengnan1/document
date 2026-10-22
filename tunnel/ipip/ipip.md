### 1. ipip隧道

**IPIP（IP-in-IP）主要用于三层隧道：在原始 IP 报文外再加一层 IP 头，让它通过中间网络到达指定的隧道出口。** 中间网络只需要知道外层地址的路由。[RFC 2003](<https://datatracker.ietf.org/doc/html/rfc2003>)

### 2 ipip隧道应用场景

典型应用有：

1. 容器跨主机通信，例如 Calico 的 IPIP 模式
   
   底层网络能访问各节点 IP，但没有 Pod 网段路由时，将 Pod 报文封装在节点 IP 之间传输。目的节点解封装后，再转发给目标 Pod。[Calico 文档](<https://docs.tigera.io/calico/latest/networking/configuring/vxlan-ipip>)

   ```
   原始报文：[Pod A IP → Pod B IP][TCP/UDP][数据]
   封装之后：[节点 A IP → 节点 B IP][Pod A IP → Pod B IP][TCP/UDP][数据]
   ```
2. 负载均衡，例如 LVS 的 TUN 模式

   调度器将客户端请求通过 IPIP 发给后端服务器，后端解封装并处理，响应可以直接返回客户端。这使后端能够跨三层网络部署，并减少响应流量对调度器的占用。[LVS 文档](<https://www.linuxvirtualserver.org/VS-IPTunneling.html>)
3. 跨网络的三层互联、指定流量绕行

   两个网关之间建立 IPIP 隧道，把指定网段的流量送往远端网关；中间路由器无需学习内部网段。Mobile IP 也是其经典应用之一。[RFC 2003](<https://datatracker.ietf.org/doc/html/rfc2003>)