<!-- vim-markdown-toc Marked -->

* [Kubernetes 核心概念](#kubernetes-核心概念)
    * [简介](#简介)
        * [Kubernetes的好处](#kubernetes的好处)
        * [Kubernetes 不是什么](#kubernetes-不是什么)
    * [架构](#架构)
        * [节点](#节点)
        * [通信](#通信)
            * [从节点到Master](#从节点到master)
            * [从Master到节点](#从master到节点)
            * [API](#api)
        * [控制器](#控制器)
            * [如何控制资源](#如何控制资源)
            * [设计实践](#设计实践)
            * [云控制器管理器](#云控制器管理器)
        * [如何运行应用](#如何运行应用)
    * [机理](#机理)
        * [架构](#架构)
            * [etcd](#etcd)
            * [API Server](#api-server)
            * [Scheduler](#scheduler)
            * [Controller](#controller)
            * [Kubectl](#kubectl)
            * [Kube-proxy](#kube-proxy)
        * [控制器之间的协作](#控制器之间的协作)
        * [Pod间的网络](#pod间的网络)
            * [Flannel](#flannel)
        * [服务如何实现](#服务如何实现)
            * [iptabls模式](#iptabls模式)
        * [高可用集群](#高可用集群)
            * [高可用的应用](#高可用的应用)
            * [高可用的Master](#高可用的master)
    * [核心概念 - Pod](#核心概念---pod)
        * [对象](#对象)
            * [描述文件](#描述文件)
            * [对象管理](#对象管理)
            * [名称和UID](#名称和uid)
            * [名字空间](#名字空间)
            * [标签和选择算符](#标签和选择算符)
            * [注解](#注解)
            * [字段选择器](#字段选择器)
        * [容器](#容器)
            * [Runtime Class](#runtime-class)
            * [容器生命周期回调](#容器生命周期回调)
        * [Pod](#pod)
            * [基本概念](#基本概念)
            * [使用](#使用)
            * [共享网络与存储](#共享网络与存储)
            * [Pod模板](#pod模板)
        * [生命周期](#生命周期)
            * [Pod 生命周期](#pod-生命周期)
            * [容器生命周期](#容器生命周期)
            * [容器重启策略](#容器重启策略)
        * [创建流程](#创建流程)
        * [影响调度的因素](#影响调度的因素)
            * [资源配额](#资源配额)
            * [节点亲和性](#节点亲和性)
            * [拓扑分布约束](#拓扑分布约束)
            * [污点与污点容忍](#污点与污点容忍)
        * [特殊容器](#特殊容器)
            * [Init 容器](#init-容器)
            * [Sidecar 容器](#sidecar-容器)
        * [健康检查机制](#健康检查机制)
            * [重启策略](#重启策略)
            * [探针执行方式与参数](#探针执行方式与参数)
            * [存活探针](#存活探针)
            * [就绪探针](#就绪探针)
    * [核心概念 - 工作负载](#核心概念---工作负载)
        * [ReplicaSet](#replicaset)
            * [工作原理](#工作原理)
            * [何时使用](#何时使用)
            * [vs. RC](#vs.-rc)
            * [注意](#注意)
        * [Deployment](#deployment)
            * [工作原理](#工作原理)
            * [清理策略](#清理策略)
            * [发布策略 - 金丝雀发布](#发布策略---金丝雀发布)
            * [发布策略 - 滚动式发布](#发布策略---滚动式发布)
            * [发布策略 - 蓝绿发布](#发布策略---蓝绿发布)
            * [发布策略 - 其他](#发布策略---其他)
            * [注意](#注意)
        * [StatefulSet](#statefulset)
            * [意义](#意义)
            * [工作原理](#工作原理)
            * [注意](#注意)
        * [DaemonSet](#daemonset)
            * [场景](#场景)
        * [Job](#job)
            * [使用场景](#使用场景)
            * [失效场景](#失效场景)
            * [终止与清理](#终止与清理)
            * [注意](#注意)
        * [CronJob](#cronjob)
            * [时间安排](#时间安排)
            * [注意](#注意)
        * [垃圾收集](#垃圾收集)
            * [所有者和附属](#所有者和附属)
            * [级联删除](#级联删除)
            * [注意](#注意)
        * [TTL 控制器](#ttl-控制器)
    * [核心概念 - 服务与网络](#核心概念---服务与网络)
        * [Service](#service)
            * [目的](#目的)
            * [定义 - 位于集群内部](#定义---位于集群内部)
            * [定义 - 位于集群外部 Endpoint](#定义---位于集群外部-endpoint)
            * [定义 - 位于集群外部 ExternalName](#定义---位于集群外部-externalname)
            * [服务发现](#服务发现)
            * [服务暴露 - NodePort](#服务暴露---nodeport)
            * [服务暴露 - LoadBalancer](#服务暴露---loadbalancer)
            * [服务暴露 - Ingress](#服务暴露---ingress)
            * [其他](#其他)
        * [Ingress](#ingress)
        * [Headless Service](#headless-service)
        * [服务故障排查](#服务故障排查)
    * [核心概念 - 卷](#核心概念---卷)
        * [emptyDir](#emptydir)
        * [gitRepo](#gitrepo)
        * [hostPath](#hostpath)
            * [注意](#注意)
        * [nfs](#nfs)
        * [PersistantVolume](#persistantvolume)
            * [介绍](#介绍)
            * [供应模式](#供应模式)
            * [生命周期](#生命周期)
            * [配置](#配置)
        * [StorageClass](#storageclass)
            * [Provisioner](#provisioner)
            * [回收策略](#回收策略)
    * [核心概念 - 配置](#核心概念---配置)
        * [描述文件中的配置](#描述文件中的配置)
            * [命令行参数](#命令行参数)
            * [环境变量](#环境变量)
        * [ConfigMap](#configmap)
            * [创建 ConfigMap](#创建-configmap)
            * [使用 ConfigMap - 环境变量](#使用-configmap---环境变量)
            * [使用 ConfigMap - 文件挂载](#使用-configmap---文件挂载)
            * [注意](#注意)
        * [Secret](#secret)
            * [安全](#安全)
            * [配置](#配置)
            * [注意](#注意)
    * [其他](#其他)
        * [集群安全机制](#集群安全机制)
            * [概述](#概述)
            * [RBAC鉴权](#rbac鉴权)
        * [Helm](#helm)
            * [概念](#概念)
            * [演示](#演示)
        * [集群资源监控](#集群资源监控)
            * [监控指标](#监控指标)
            * [监控平台方案](#监控平台方案)
    * [实践](#实践)
        * [常用命令](#常用命令)
        * [简单实践](#简单实践)
        * [开发应用最佳实践](#开发应用最佳实践)

<!-- vim-markdown-toc -->

# Kubernetes 核心概念

> 大部分引用自官方文档v1.19



## 简介

Kubernetes 是一个可移植的、可扩展的开源平台，用于管理容器化服务，可促进**声明式配置**和**自动化**。



### Kubernetes的好处

- **服务发现和负载均衡**

  服务发现提供**服务注册**和**服务查找**；

  同时当服务提供者**节点挂掉时**，要求服务能够**及时取消注册**，比便**及时通知**消费者重新获取服务地址；

  当服务提供者**新加入时**，要求服务中介能及时告知服务消费者，你要不要尝试一下新的服务。

- **存储编排(orchestration)**

- **自动部署和回滚**

- **自动完成装箱计算**

  Kubernetes 允许你指定每个容器所需 CPU 和内存（RAM）。 当容器指定了资源请求时，Kubernetes 可以做出更好的决策来管理容器的资源。

- **自我修复**

  Kubernetes 重新启动失败的容器、替换容器、杀死不响应用户定义的 运行状况检查的容器，并且在准备好服务之前不将其通告给客户端。

- **密钥与配置管理**

  Kubernetes 允许你存储和管理敏感信息，例如密码、OAuth 令牌和 ssh 密钥。 你可以在不重建容器镜像的情况下部署和更新密钥和应用程序配置，也无需在堆栈配置中暴露密钥.



### Kubernetes 不是什么

Kubernetes 在容器级别而不是在硬件级别运行。

- 不提供也不采用任何全面的机器配置、维护、管理或自我修复系统。
- 不要求日志记录、监视或警报解决方案。



## 架构

![控制面板和工作节点的组件](https://img-blog.csdnimg.cn/20200323193547753.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0hzdWVoWFhY,size_16,color_FFFFFF,t_70)



**控制面板**

用于控制集群，可部署于单节点。或通过副本部署多节点，以确保高可用性。

- API服务器：提供API，用以交互通信
- Scheduler：调度监视未指定节点的 Pod，选择节点让 Pod 在上面运行。
- Controller Manager：执行集群级别的功能，处理集群任务，一个资源一个控制器
- etcd：分布式数据存储，持久化配置



**工作节点**

是运行容器化应用的机器。

- 容器运行时：Docker、containerd、CRI-O等实现CRI的运行时
- Kubelet：与API服务器通信，以控制节点
- kube-proxy：网络规则，用于负载均衡，管理节点网络



**插件**

插件使用 Kubernetes 资源实现集群功能。其资源属于 `kube-system` 命名空间。

- `kube-dns`
- Ingress 控制器
- 容器网络接口插件 CNI：Fannel
- 容器集群监控：Heapster、Promethous、Grafana等



### 节点

- Kubernetes 检查节点是否健康（即所有必要的服务都在运行中），则该节点可以用来运行 Pod。 否则，直到该节点变为健康之前，所有的集群活动都会忽略该节点。

- Kubernetes 会一直保存着非法节点对应的对象，并持续检查该节点是否已经 变得健康。 必需显式地 删除该 Node 对象以停止健康检查操作。
- 被 [DaemonSet](https://kubernetes.io/zh/docs/concepts/workloads/controllers/daemonset/) 控制器创建的 Pod 能够容忍节点的不可调度属性（`kubectl cordon $NODENAME`）。 DaemonSet 通常提供节点本地的服务，即使节点上的负载应用已经被腾空，这些服务也仍需 运行在节点之上。



### 通信

#### 从节点到Master

- 所有从集群发出的 API 调用都终止于 apiserver。
- apiserver被配置为在一个安全的 HTTPS 端口上监听远程连接请求， 并启用一种或多种形式的客户端[身份认证](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/)机制。



#### 从Master到节点

1. 从 apiserver 到每个节点上的 kubelet
   - 连接终止于 kubelet 的 HTTPS 末端，但没有kubelet的认证证书
   - 要启动认证：证书或SSH隧道
2. apiserver 通过它的代理功能连接到任何节点、Pod 或者服务
   - 纯 HTTP 方式，因此既没有认证，也没有加密。



#### API

Kubernetes 控制面的核心是 kube-apiserver。 API 服务器负责提供 HTTP API，以供用户、集群中的不同部分和集群外部组件相互通信。

Kubernetes API 使你可以查询和操纵 Kubernetes API 中对象（例如：Pod、Namespace、ConfigMap 和 Event）的状态。

大部分操作都可以通过命令行工具来执行， 这些工具在背后也是调用 API。不过，你也可以使用 REST 调用来访问这些 API。



### 控制器

**一个控制器至少追踪一种类型的 Kubernetes 资源**。这些 [对象](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/kubernetes-objects/) 有一个代表期望状态的 `spec` 字段。 该资源的控制器负责确保其当前状态接近期望状态。



#### 如何控制资源

1. 通过 API 服务器来控制
   - 当控制器拿到新任务时，它会保证一组 Node 节点上的 `kubelet` 可以运行正确数量的 Pod 来完成工作。
   - 控制器通知 API 服务器来创建或者移除 Pod。
   - Master 中的其它组件 根据新的消息作出反应（调度并运行新 Pod）并且最终完成工作。
2. 控制器可能会自行直接操作
   - 和外部状态交互的控制器从 API 服务器获取到它想要的状态
   - 直接和外部系统进行通信 并使当前状态更接近期望状态。
   - 就 Kubernetes 集群而言，控制面间接地与 IP 地址管理工具、存储服务、云驱动 APIs 以及其他服务协作，通过[扩展 Kubernetes](https://kubernetes.io/zh/docs/concepts/extend-kubernetes/) 来实现这点。



#### 设计实践

- 最常见的一个特定的控制器使用一种类型的资源作为它的期望状态
- 使用简单的控制器
- 以有多个控制器来创建或者更新相同类型的对象



#### 云控制器管理器

使用云基础设施技术，你可以在公有云、私有云或者混合云环境中运行 Kubernetes。 Kubernetes 的信条是基于自动化的、API 驱动的基础设施，同时避免组件间紧密耦合。

`cloud-controller-manager` 组件是基于一种插件机制来构造的， 这种机制使得不同的云厂商都能将其平台与 Kubernetes 集成。



### 如何运行应用

![kubernetes部署应用程序](https://img-blog.csdnimg.cn/20200323194116905.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0hzdWVoWFhY,size_16,color_FFFFFF,t_70)



1. 将包含应用的容器上传到镜像仓库中，编写**描述信息至**K8s API服务器；
2. 调度器指定容器在那些工作节点中运行；
3. 工作节点的Kubelet负责拉取容器镜像并运行。



注意：

1. 如何保持容器运行

   K8s会不断确认应用的运行状态是否与描述配置一致。若某节点停止服务，它可以重启或者移动到新的节点。

2. 如何扩展副本数量

   运维可以手动修改数量，而K8s也可以自动决定最佳的副本数目。

3. 如何访问可移动的服务

   K8s提供一个静态IP来暴露所有容器，并且kube-proxy可以实现容器跨容器访问的负载均衡。



## 机理

> 若不了解本内容细节，请首先阅读其他标题内容



### 架构

- 集群组件之间只能通过API服务器进行通信
- API服务器是能与etcd通信的唯一组件，其他组建只能简介通过API请求，进行通信
- 为了保证高可用性，Master 的所有组建都可有多个实例
  - etcd 实例和 API server 实例可以同时运行
  - 调度器和控制管理器同时只能有一个运行，其他实例处于待命状态
- 关于`kube-system`中的组建在何处运行：
  - `kube-proxy`和CNI的实现处于每个节点的容器中
  - 剩下的`kube-dns`，`apiserver`等都在主节点



#### etcd

> https://www.zhihu.com/question/64778723/answer/224266038

> https://blog.csdn.net/scylhy/article/details/100173494

- API服务器是能与etcd通信的唯一组件。这样的好处是：
  - 提供认证、鉴权、准入控制和资源验证，以检查对象是否合法
  - 通过`meta.resourceVersion`提供同一的乐观锁机制协议，进行减少访问etcd的次数和一致性。防止某组件不遵守协议。
- 资源存储与`/registry`中
- etcd采取raft分布式共识算法，在CAP中选择CP，牺牲可用性。
  - CAP是指在P分区容错性之上，在C一致性和A可用性上二选一。
    - 分区容错性：网络链接断开，导致网络被分为两个或多个部分时，保证可以使用。
    - 一致性：集群中所有数据出于逻辑上的一致。
    - 可用性：指集群总是接受请求并正确回应
  - 当网络链接断开，集群被分为两部分时。并且多数节点的集群受到客户端的写请求时，接受并执行写请求是提供A，不执行则是提供C。
  - Raft接受了请求但不执行，当网络恢复后同步数据，长远的看数据是一致的，即达到了最终一致性。
- 为什么etcd节点数应该是奇数？
  - 当宕机或网络断开时，能够一直存在大多数节点接受请求。



#### API Server

- 提供认证、授权、准入控制和资源验证，以检查对象是否合法后存入etcd。
  - 轮询认证插件，直到确认是谁发来请求。
  - 轮询授权插件，直到确认所需权限。
  - 经过所有准入控制插件，进行验证。
- 提供 RESTful API。
- 提供监听机制，供各组件监听事件作出反应。

![img](https://pic4.zhimg.com/80/v2-71621b7058ee2fa2660bc209b8fb45c3_720w.jpg)



#### Scheduler

利用监听机制，等待新创建的Pod分配给某个节点。

- 监听APIserver的Pod创建事件，更改Pod调度信息，Kubectl再监听到Pod，进行创建。
- 默认调度算法：过滤、打分。
- 可自定义调度器，在Pod属性中说明特定调度器。



#### Controller

控制器存在与 Controller Manager 中，它们确保系统当前状态向期望状态进行收敛。

- 控制器进行循环（控制回路），监听资源变更，再将新的期望的状态写入status。
- 每个控制器实现方式不同，但Kubelet最终会监听到资源状态更新，并正确操作。



#### Kubectl

负责Pod和容器的生命周期和各种变更的实际操作，同时也是存活探针的执行者。

- **静态Pod**：不由API Server获知的Pod，仅有Kubelet进行维护。



#### Kube-proxy

`kube-proxy`的工作是监听Service和Endpoint（它指明了pod的具体IP和端口），并且维护IPVS（或旧版的iptabls）。



### 控制器之间的协作

系统整体是事件驱动的，以创建Deployment资源为例：

![img](https://pic4.zhimg.com/80/v2-e8080f3f2f5c9978f4c7536c2026c1cb_720w.jpg)



### Pod间的网络

> 大部分引用自https://zhuanlan.zhihu.com/p/87063321

> https://zhuanlan.zhihu.com/p/140711132

网络有各种特定的实现，但是最终都要遵守下面两点：

1. 节点之间的各个Pod间可互相通信，不存在NAT
2. 节点上的守护程序如kubelet和daemon，能够直接与Pod通信



#### Flannel

每个节点会从 PodSubnet 中注册一个掩码长度为 24 的子网，然后该节点的所有 pod ip 地址都会从该子网中分配。

当 flannel 启动成功后，会在宿主机上生成一个描述子网环境的文件，该文件中记录了所有 pod 的子网范围(FLANNEL_NETWORK)以及本机 pod  的子网范围(FLANNEL_SUBNET)：

```shell
$ cat /run/flannel/subnet.env 
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.1.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
```

每个节点会创建`flannel.1`接口，它是vxlan类型设备。

- 当要发送给自己的 pod 子网时，会通过 cni0 网桥。
  - Docker Drive为null，Kubernetes自己创建了这个网桥在`pause`中将其共享，通过它可以创建配对的网口给容器。
  - 添加路由条目，将发送给自己的IP连接到 cni0 上，这是数据链路层上的（没有过Gateway）
  - 通过默认网关，可以将无关的IP发送到外网。
- 而当要发送其他宿主机的 pod 时，会通过 flannel.1 网卡。
  - 此处会进行二次封包，避免了NAT
  - 注意：网络掩码为32位，同时mtu为1450预留了一些进行封包。

![img](https://pic3.zhimg.com/80/v2-2809665f2c7a972fb8815f9c7559db06_720w.jpg)





### 服务如何实现

服务提供了稳定的IP和端口，其中IP是虚拟的，而IP划分在了私有区域，所以ping命令是绝对无效的。

`kube-proxy`的工作是

`kube-proxy`最初是作为代理存在于`userspace`代理模式中，此后又有性能更高的`iptables`代理模式，现在采用`IPVS`代理模式。当前实现方案使用哈希表作为基础数据结构，并且在内核空间中工作，这提供了更好的性能。

#### iptabls模式

见书图11.17，由于iptabls配置过于复杂，这里简单说明此处使用了iptables做了类似DNAT的操作，在每个节点上进行了目标地址转换。

**注意**：无法ping通某个Service的原因是，每个节点上的iptabls配置中，过滤了非Service的TCP和端口号，则icmp不可发出。



### 高可用集群



#### 高可用的应用

- **水平扩展**：使用Deployment水平扩展，会减少全部宕机概率
- **多副本选举**：不能水平扩展的情况下，建立多个非活跃副本，当主Pod挂掉，则选举新的Pod。



#### 高可用的Master

参见各种博客与文档，如<https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/ha-topology/>。

需要注意的是：

- `etcd`：它本身设计为分布式的，只需让它们互相感知
- `apiserver`：本身是无状态的，但最好搭配负载均衡
- `scheduler`和`controller-manager`：多副本选举机制



**参考方案**：

使用 **keepalived** 实现高可用解决单点故障

用 **haproxy** 进行负载均衡

1. 存在一个VIP

2. 每个Master中额外配置：
   - keepalived：用于配置虚拟IP、查看是否存活
   - haproxy / nginx：用于负载均衡



## 核心概念 - Pod



### 对象

*对象* 是持久化的实体，可被`yaml`文件描述：

- 哪些容器在运行，以及在哪些节点上
- 可以被应用使用的资源
- 关于应用运行的策略，比如重启策略、升级策略，以及容错策略



#### 描述文件

**大多数情况下，需要在 .yaml 文件中为 `kubectl` 提供这些信息**。

而API 请求必须在请求体中包含 JSON 格式的信息，当`kubectl` 在发起 API 请求时，将这些信息转换成 JSON 格式。



**必要字段**

- `apiVersion` - 创建该对象所使用的 Kubernetes API 的版本
- `kind` - 想要创建的对象的类别
- `metadata` - 帮助唯一性标识对象的一些数据，包括一个 `name` 字符串、UID 和可选的 `namespace`



**spec字段**

对象 `spec` 的精确格式对每个 Kubernetes 对象来说是不同的，在这里API文档中有详细介绍 <https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19>



#### 对象管理

| Management technique             | Operates on          | Recommended environment | Supported writers | Learning curve |
| -------------------------------- | -------------------- | ----------------------- | ----------------- | -------------- |
| Imperative commands              | Live objects         | Development projects    | 1+                | Lowest         |
| Imperative object configuration  | Individual files     | Production projects     | 1                 | Moderate       |
| Declarative object configuration | Directories of files | Production projects     | 1+                | Highest        |

推荐使用**命令式对象配置**。



#### 名称和UID

集群中的每一个对象都有一个[*名称*](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/names/#names) 来标识在**同类资源中的唯一性**。

每个 Kubernetes 对象也有一个[*UID*](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/names/#uids) 来标识在**整个集群中的唯一性**。



**UID**

Kubernetes 系统生成的字符串，唯一标识对象。

在 Kubernetes 集群的整个生命周期中创建的每个对象都有一个不同的 uid，它旨在区分类似实体的历史事件。

Kubernetes UIDs 是全局唯一标识符（也叫 UUIDs）。



#### 名字空间

Kubernetes 支持多个虚拟集群，它们底层依赖于同一个物理集群。 这些虚拟集群被称为名字空间。

- 名字空间适用于存在很多跨多个团队或项目的用户的场景。对于只有几到几十个用户的集群，根本不需要创建或考虑名字空间。当需要名称空间提供的功能时，请开始使用它们。



Kubernetes 会创建三个初始名字空间：

- `default` 没有指明使用其它名字空间的对象所使用的默认名字空间
- `kube-system` Kubernetes 系统创建对象所使用的名字空间
- `kube-public` 这个名字空间是自动创建的，所有用户（包括未经过身份验证的用户）都可以读取它。 这个名字空间主要用于集群使用，以防某些资源在整个集群中应该是可见和可读的。 这个名字空间的公共方面只是一种约定，而不是要求。
- `kube-node-lease` 此名字空间用于与各个节点相关的租期（Lease）对象； 此对象的设计使得集群规模很大时节点心跳检测性能得到提升。



大多数 kubernetes 资源（例如 Pod、Service、副本控制器等）都位于某些名字空间中。 但是名字空间资源本身并不在名字空间中。而且底层资源，例如 [节点](https://kubernetes.io/zh/docs/concepts/architecture/nodes/) 和持久化卷不属于任何名字空间。



#### 标签和选择算符

*标签* 是附加到 Kubernetes 对象（比如 Pods）上的键值对。

API 目前支持两种类型的选择算符：*基于等值的* 和 *基于集合的*。 标签选择算符可以由逗号分隔的多个 *需求* 组成。 在多个需求的情况下，必须满足所有要求，因此逗号分隔符充当逻辑 *与*（`&&`）运算符。

例：

```yaml
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - {key: tier, operator: In, values: [cache]}
    - {key: environment, operator: NotIn, values: [dev]}
```

```bash
kubectl get pods -l environment=production,tier=frontend
kubectl get pods -l 'environment in (production, qa)'
kubectl get pods -l 'environment,environment notin (frontend)'
```

注意一下是推荐的标签。它们使管理应用程序变得更容易但不是任何核心工具所必需的。

<https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/common-labels/>



#### 注解

为对象附加任意的非标识的元数据。客户端程序（例如工具和库）能够获取这些元数据信息。

注解不用于标识和选择对象。 注解中的元数据，可以很小，也可以很大，可以是结构化的，也可以是非结构化的，能够包含标签不允许的字符。



#### 字段选择器

允许你根据一个或多个资源字段的值 [筛选 Kubernetes 资源](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/kubernetes-objects)。 

例：

```bash
kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always

kubectl get statefulsets,services --all-namespaces --field-selector metadata.namespace!=default
```



### 容器



#### Runtime Class

你可以在不同的 Pod 设置不同的 RuntimeClass，以提供性能与安全性之间的平衡。

你需要配置：

1. 节点上配置CRI的RuntionClass
2. 创建RuntimeClass对象，其中hander指明CRI的RuntimeClass的实现
3. 在其他Pod中，填写runtimeClassName



#### 容器生命周期回调

在`spec.containers.lifecycle`中有两个回调暴露给容器：

1. `PostStart`：在容器被创建之后立即被执行。
2. `PreStop`：在容器被终止之前， 此回调会被调用。 此调用是阻塞同步调用，因此必须在发出删除容器的信号之前完成。 



### Pod



#### 基本概念

- 最小部署单元
- 是一组容器的集合（每个pod存在一个Pause容器即根容器）
- pod中的容器共享一组命名空间、控制组等隔离单元和存储卷
- 是相对临时性的、用后即抛的一次性实体
  - Pod 由你或者间接地由 [控制器](https://kubernetes.io/zh/docs/concepts/architecture/controller/) 创建
  - 当Pod 结束执行、Pod 对象被删除、Pod 因资源不足而被 *驱逐* 或者节点失效，则终结

注意：重启 Pod 中的容器不应与重启 Pod 混淆。 Pod 不是进程，而是容器运行的环境。 在被删除之前，Pod 会一直存在。



#### 使用

- 通常你不需要直接创建 Pod，而是使用**工作负载资源**来创建 Pod。
- **运行单个进程的容器**
  - 不要降多个进程封装在一个容器中，这会带来运行、日志等的管理问题。
- **运行单个容器的 Pod**
  - 将 Pod 看作单个容器的包装器
  - 如果将所有应用封装在一个Pod中，降不能充分利用其他Pod的资源来分担；同时也不能进行应用中一部分组建的扩缩容。
- **运行多个容器的 Pod**
  - 封装由多个紧密耦合且需要共享资源的共处容器组成的应用程序
  - 只有在容器之间紧密关联时你才应该使用这种模式。
- 横向扩展应用程序被称为副本。 通常使用一种工作负载资源及其[控制器](https://kubernetes.io/zh/docs/concepts/architecture/controller/) 来创建和管理一组 Pod 副本。



#### 共享网络与存储

Pod 天生地为其成员容器提供了两种共享资源：

- 网络：
  - 每个 Pod 都在每个地址族中获得一个唯一的 IP 地址。 
  - 在同一个 Pod 内，所有容器共享一个 IP 地址和端口空间，并且可以通过 `localhost` 发现对方。
  - 他们也能通过如 **SystemV 信号量或 POSIX 共享内存**这类标准的进程间通信方式互相通信。
  - 注意：具体容器都共享了pause容器的网络，而pause容器IpcMode为sharable，且网络类型为none
  - 详见：<https://kubernetes.io/zh/docs/concepts/cluster-administration/networking/>
  - 关于Fannel网络实现，详见：<https://zhuanlan.zhihu.com/p/140711132>
- 存储：即共享数据卷，详见<https://kubernetes.io/zh/docs/concepts/storage/>



#### Pod模板

[负载](https://kubernetes.io/zh/docs/concepts/workloads/)资源的控制器通常使用 Pod 模板 来替你创建 Pod 并管理它们，是负载资源的目标状态的一部分。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
# 以下是Pod的配置文件
# 请对比后文的pod template
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
      preStop:
        exec:
          command: ["/bin/sh","-c","nginx -s quit; while killall -0 nginx; do sleep 1; done"]

---

apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    # 这里是 Pod 模版
    spec:
      containers:
      - name: hello
        image: busybox
        command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600']
      restartPolicy: OnFailure
    # 以上为 Pod 模版
```



1. 镜像拉取策略`imagePullPolicy`：有三种，是否主动拉取容器
   - `always`：默认参数，相当于在镜像后添加`latest`或者不写
2. 资源限制`resources.limit/requests`：对CPU和MEM进行最大/最小限制
3. 重启策略`restartPolicy`：三种，类似Docker
4. 健康检查策略：
   - 存活探针`livenessProbe`：若检查失败则杀死
   - 就绪探针`readinessProbe`：若检查失败则把Pod剔除出service，**务必添加**
   - 检查方式：`httpGet`状态码范围，`exec`返回状态码为0，`tcpSocket`建立成功





### 生命周期



#### Pod 生命周期

- 起始于 `Pending` 阶段如果至少 其中有一个主要容器正常启动，则进入 `Running`，之后取决于 Pod 中是否有容器以 失败状态结束而进入 `Succeeded` 或者 `Failed` 阶段。
- Pod 在其生命周期中**只会被调度一次**。 一旦 Pod 被调度（分派）到某个节点，Pod 会一直在该节点运行，直到 Pod 停止或者 被[终止](https://kubernetes.io/zh/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination)。
- **Pod 自身不具有自愈能力。**如果 Pod 被调度到某[节点](https://kubernetes.io/zh/docs/concepts/architecture/nodes/) 而该节点之后失效，或者调度操作本身失效，Pod 会被删除；与此类似，Pod 无法在节点资源 耗尽或者节点维护期间继续存活。Kubernetes 使用一种高级抽象，称作 [控制器](https://kubernetes.io/zh/docs/concepts/architecture/controller/)，来管理这些相对而言 可随时丢弃的 Pod 实例。新 Pod 的名字可以不变，但是其 UID 会不同。
- 如果某物声称其生命期与某 Pod 相同，例如存储[卷](https://kubernetes.io/zh/docs/concepts/storage/volumes/)， 这就意味着如果 Pod 因为任何原因被删除，甚至某完全相同的替代 Pod 被创建时， 这个**相关的对象也会被删除并重建**。



| 取值        | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| `Pending`   | Pod 已被 Kubernetes 系统接受，但有**一个或者多个容器尚未创建亦未运行**。此阶段包括等待 Pod 被调度的时间和通过网络下载镜像的时间， |
| `Running`   | Pod 已经绑定到了某个节点，Pod 中所有的容器都已被创建。**至少有一个容器仍在运行**，或者正处于启动或重启状态。 |
| `Succeeded` | Pod 中的**所有容器都已成功终止**，并且不会再重启。           |
| `Failed`    | Pod 中的所有容器都已终止，并且**至少有一个容器是因为失败终止**。也就是说，容器以非 0 状态退出或者被系统终止。 |
| `Unknown`   | 因为某些原因无法取得 Pod 的状态。这种情况通常是因为与 Pod 所在主机通信失败。 |



#### 容器生命周期

一旦将 Pod 调度给某个节点，`kubelet` 就通过 [容器运行时](https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes) 开始为 Pod 创建容器。

你可以使用[容器生命周期回调](https://kubernetes.io/zh/docs/concepts/containers/container-lifecycle-hooks/) 来在容器生命周期中的特定时间点触发事件。

| 取值         | 描述                                             |
| ------------ | ------------------------------------------------ |
| `Waiting`    | 仍在运行它完成启动所需要的操作                   |
| `Running`    | 表明容器正在执行状态并且没有问题发生。           |
| `Terminated` | 已经开始执行并且或者正常结束或者因为某些原因失败 |



#### 容器重启策略

Pod 的 `spec` 中包含一个 `restartPolicy` 字段，其可能取值包括 Always、OnFailure 和 Never。默认值是 Always。

`restartPolicy` 适用于 Pod 中的所有容器。`restartPolicy` 仅针对同一节点上 `kubelet` 的容器重启动作。当 Pod 中的容器退出时，`kubelet` 会按指数回退 方式计算重启的延迟（10s、20s、40s、...），其最长延迟为 5 分钟。 一旦某容器执行了 10 分钟并且没有出现问题，`kubelet` 对该容器的重启回退计时器执行 重置操作。


- Always：当容器失效时，由kubelet自动重启该容器。
- OnFailure：当容器终止运行且退出码不为0时，由kubelet自动重启该容器。
- Never：不论容器运行状态如何，kubelet都不会重启该容器。




### 创建流程

> https://www.cnblogs.com/pu20065226/p/10650030.html

> <https://cloud.tencent.com/developer/article/1553943>


### 影响调度的因素

1. 资源限制策略`resources`
2. 基于标签：
   1. 节点选择器`nodeSelector`：标签
   2. 节点亲和性`nodeAffinity`
      1. 硬亲和性：条件必须满足
      2. 软亲和性：偏好，但不必须
   3. 拓扑分布约束`topologySpreadConstraints`
      - 依赖于节点标签作为拓扑域，达到拓扑域上的均衡。
3. 污点 & 污点容忍：设置某节点的特殊调度方式，以拒绝调度
   - 在node上设置一个或多个Taint后，除非pod明确声明能够容忍这些“污点”，否则无法在这些node上运行。
   - 污点值：`NoSchedule`,`PerferNoSchedule`,`NoExecute`
   - 常见应用场景：节点独占，特殊硬件标签，节点故障标签



#### 资源配额

对每个命名空间的资源消耗总量提供限制。 它可以限制命名空间中某种类型的对象的总数目上限，也可以限制命令空间中的 Pod 可以使用的计算资源的总上限。

分配计算资源时，每个容器可以为 CPU 或内存指定请求和约束。



#### 节点亲和性

1. 规则是偏好的，而**不是硬性**要求，如果调度器无法满足该要求，仍然调度该 pod
2. 你可以使用节点上的 pod 的标签来约束，而不是使用节点本身的标签，来**允许哪些 pod 可以或不可以被放置在一起**。



#### 拓扑分布约束

依赖于节点标签作为拓扑域，达到拓扑域上的均衡。



#### 污点与污点容忍

污点和容忍度相互配合，可以用来**避免 Pod 被分配到不合适的节点**上。 每个节点上都可以应用一个或多个污点，这表示对于那些不能容忍这些污点的 Pod，是不会被该节点接受的。

**场景**

- **专用节点**：如果您想将某些节点专门分配给特定的一组用户使用，您可以给这些节点添加一个污点， 然后给这组用户的 Pod 添加一个相对应的 toleration

- **配备了特殊硬件的节点**：在部分节点配备了特殊硬件（比如 GPU）的集群中， 我们希望不需要这类硬件的 Pod 不要被分配到这些特殊节点，以便为后继需要这类硬件的 Pod 保留资源。 

- **基于污点的驱逐**: 在节点出现问题时，Pod 被驱逐的策略

```yaml
spec:
  tolerations:
  - key: "example-key"
    operator: "Exists"
    effect: "NoSchedule"
```





节点设置举例：

```bash
# label CRUD
kubectl label node NAME key=value
kubectl label node NAME key-
kubectl label node NAME key=value --overwirte
kubectl get node --show-labels
kubectl get node -l "key=value"
kubectl get node -l "key!=value"

# Taint CRUD
kubectl describe node NAME | grep 
kubectl taint node NAME type=value:TIANT
kubectl taint node NAME type:TIANT-
```



### 特殊容器

![img](https://img2018.cnblogs.com/blog/1082769/202002/1082769-20200210223709746-1615498561.gif)



#### Init 容器

Init 容器是一种特殊容器，在 [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 内的应用容器启动之前运行。

Init 容器支持应用容器的全部字段和特性，包括资源限制、数据卷和安全设置。 然而，Init 容器对资源请求和限制的处理稍有不同，在下面[资源](https://kubernetes.io/zh/docs/concepts/workloads/pods/init-containers/#resources)节有说明。

同时 Init 容器不支持 `lifecycle`、`livenessProbe`、`readinessProbe` 和 `startupProbe`， 因为它们必须在 Pod 就绪之前运行完成。

在 Pod 启动过程中，每个 Init 容器会在网络和数据卷初始化之后按顺序启动。 kubelet 运行依据 Init 容器在 Pod 规约中的出现顺序依次运行之。

每个 Init 容器成功退出后才会启动下一个 Init 容器。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
```



#### Sidecar 容器

在应用容器运行的同时，利用Sidecar容器可以做到一些相同生命周期的长时间操作，如`git sync`、数据库检查等。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: bookings-v1-b54bc7c9c-v42f6
  labels:
    app: demoapp
spec:
  containers:
  - name: bookings
    image: banzaicloud/allspark:0.1.1
    ...
  - name: istio-proxy
    image: docker.io/istio/proxyv2:1.4.3
    lifecycle:
      type: Sidecar
    ...
```



### 健康检查机制

> <https://www.jianshu.com/p/5def7f934d2e>



#### 重启策略

每个容器启动时都会执行一个主进程，如果进程退出返回码不是0，则认为容器异常，即pod异常，k8s 会根据restartPolicy策略选择是否杀掉 pod，再重新启动一个。

restartPolicy分为三种：

- Always：当容器终止退出后，总是重启容器，默认策略。
- OnFailure：当容器异常退出（退出码非0）时，才重启容器。
- Never：当容器终止退出时，才不重启容器。

```yaml
spec:
  restartPolicy: OnFailure
```



#### 探针执行方式与参数

**执行方式**

- **HTTP**：200或300范围响应，则健康

  ```yaml
  httpGet:
    path: /api
    port: 80
    httpHeaders:
    - name: Custom-Header
      value: header-value
  ```

- **TcpSocket**：若可以建立连接，则健康

  ```yaml
  tcpSocket: 
    port: 80
  ```

- **exec**：返回值为0，则健康

  ```yaml
  exec:
    command: [ "cat", "/etc/nginx.conf" ]
  ```

**参数**

- `initialDelaySeconds`：指定容器启动之后何时开始探测，根据应用启动的准备时间来设置
- `periodSeconds`：探测周期，默认5s
- `timeoutSeconds`：超时时间
- `failureThreshold`：最大尝试次数，默认3
- `successThreshold`：最小连续成功次数

```yaml
spec:
  containers:
  - name: web
    image: nginx
    livenessProbe:
      exec:
        command: [ "cat", "/etc/nginx.conf" ]
      initialDelaySeconds: 30
      periodSeconds: 5
```





#### 存活探针

很多情况下服务出现问题，进程却没有退出，如系统超载 5xx 错误，资源死锁等。

存活探针是指，若检查失败**则杀死Pod，重新启动一个并替换**。



#### 就绪探针

就绪探针旨在让Kubernetes知道你的应用**是否准备好为请求提供服务**。

如果就绪探针检测失败，**服务将停止向该容器发送流量，直到它通过检测**。



## 核心概念 - 工作负载



### ReplicaSet

目的是维护一组在任何时候**都处于运行状态**的 Pod 副本的稳定集合。 因此，它通常用来保证**给定数量**的、**完全相同**的 Pod 的可用性。



#### 工作原理

- RepicaSet 是通过一组字段来定义的：**Pod选择算符**、**副本个数**和**Pod 模板**。

- ReplicaSet 通过 **Pod 上的 `metadata.ownerReferences` 字段连接**到附属 Pod.

  ```shell
  $ k get pod web-nb8s6 --template={{.metadata.ownerReferences}}
  
  [map[apiVersion:apps/v1 blockOwnerDeletion:true controller:true kind:ReplicaSet name:web uid:f2f7e955-1346-4e37-ba2e-e43c35d57cd2]]
  ```

- **强烈注意**：ReplicaSet 使用其**选择算符来辨识要获得的 Pod** 集合。如果某个 Pod 没有 OwnerReference 或者其 OwnerReference 不是一个 [控制器](https://kubernetes.io/zh/docs/concepts/architecture/controller/)，且其匹配到 某 ReplicaSet 的选择算符，则该 Pod **立即**被此 ReplicaSet 获得。



#### 何时使用

建议使用Deployment。

它是一个更高级的概念，它管理 ReplicaSet，并向 Pod 提供声明式的更新以及许多其他有用的功能。



#### vs. RC

二者目的相同且行为类似，只是 ReplicationController 不支持 [标签用户指南](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/labels/#label-selectors) 中讨论的**基于集合的选择算符**需求。 因此，相比于 ReplicationController，应优先考虑 ReplicaSet。



#### 注意

- 对于模板的[重启策略](https://kubernetes.io/zh/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy) 字段，`.spec.template.spec.restartPolicy`，唯一允许的取值是 `Always`，这也是默认值。
- 在 ReplicaSet 中，`.spec.template.metadata.labels` 的值必须与 `spec.selector` 值 相匹配，否则该配置会被 API 拒绝。
- **删除 ReplicaSet 和它的 Pod**：直接删除RS。默认情况下，垃圾收集器自动删除所有依赖的 Pod。
- **只删除 ReplicaSet**：`delete --cascade=false`
- **将 Pod 从 ReplicaSet 中隔离**：修改标签
- **自动Pod水平扩展HPA**：新建HPA，使用配置文件或者CLI（推荐）。

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web
  labels:                   # 这是 ReplicaSet 的标签
    app: web                
spec:
  replicas: 2
  selector:
    matchLabels:            # 这是 ReplicaSet 管理的目标 Pod 标签
      app: web
  template:
    metadata:
      labels:
        app: web            # 这是新建 Pod 的标签，与上面管理目标相同
    spec:
      containers:
        - name: nginx
          image: nginx
```

```bash
kubectl autoscale rs frontend --max=10 --min=3 --cpu-percent=50
```





### Deployment

*Deployment* 控制器为 [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 和 [ReplicaSets](https://kubernetes.io/zh/docs/concepts/workloads/controllers/replicaset/) 提供**声明式的更新能力**。

Deployment 也是通过一组字段来定义的：**Pod选择算符**、**副本个数**和**Pod 模板**。



#### 工作原理

- Deployment 控制器将 `pod-template-hash` 标签添加到 Deployment 所创建或收留的 每个 ReplicaSet 。
  - 此标签可确保 Deployment 的子 ReplicaSets 不重叠。 标签是通过对 ReplicaSet 的 `PodTemplate` 进行哈希处理。 所生成的哈希值被添加到**子 ReplicaSet 选择算符**、**Pod 模板标签**中。
  - 所以**更新 Deployment 时，会创建新的 ReplicaSet**。新的 ReplicaSet 缩放为 `.spec.replicas` 个副本， 所有旧 ReplicaSets 缩放为 0 个副本。
  - 当你**回滚**到较早的修订版本时，只有 Deployment 的 Pod 模板部分会被回滚。



#### 清理策略

你可以在 Deployment 中设置 `.spec.revisionHistoryLimit` 字段以指定保留此 Deployment 的多少个旧有 ReplicaSet。其余的 ReplicaSet 将在后台被垃圾回收。 默认情况下，此值为 10。



#### 发布策略 - 金丝雀发布

> [金丝雀发布、滚动发布、蓝绿发布到底有什么差别？关键点是什么？](https://mp.weixin.qq.com/s?__biz=MzI4MTY5NTk4Ng==&mid=2247489100&idx=1&sn=eab291eb345c074114d946b732e037eb&source=41#wechat_redirect)

![Image](https://mmbiz.qpic.cn/mmbiz_png/UicsouxJOkBdpqMAJvdAY6GFrP17hbic5SGhHLU9tsuxK5HEyge763mSQlkOUDOFv0VTRkkeySNaGseyJud7We9Q/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

金丝雀发布一般先发 1 台，或者一个小比例，例如 2% 的服务器，主要做流量验证用，也称为金丝雀 (Canary)  测试（国内常称灰度测试）。以前旷工开矿下矿洞前，先会放一只金丝雀进去探是否有有毒气体，看金丝雀能否活下来，金丝雀发布由此得名。简单的金丝雀测试一般通过手工测试验证，复杂的金丝雀测试需要比较完善的监控基础设施配合，通过监控指标反馈，观察金丝雀的健康状况，作为后续发布或回退的依据。



#### 发布策略 - 滚动式发布

![Image](https://mmbiz.qpic.cn/mmbiz_png/UicsouxJOkBdpqMAJvdAY6GFrP17hbic5SKHIz2qMmia1VXJ5RNppGrLz0HFkXgB65ic73X2RoEANfhBsCTH0OrmGg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

1. 滚动式发布一般先发 1 台，或者一个小比例，如 2% 服务器，主要做流量验证用，类似金丝雀 (Canary) 测试。
2. 每次发布时，先将老版本 V1 流量从 LB 上摘除，然后清除老版本，发新版本 V2，再将 LB 流量接入新版本。这样可以尽量保证用户体验不受影响。



#### 发布策略 - 蓝绿发布

![Image](https://mmbiz.qpic.cn/mmbiz_png/UicsouxJOkBdpqMAJvdAY6GFrP17hbic5S1jN6fvMZxic1KriacrRbaGTynNrjz7VVe9sfBVtQYiaOCSztibIBWhelEQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

V1 版本称为蓝组，V2 版本称为绿组，发布时通过 LB 一次性将流量从蓝组直接切换到绿组，不经过金丝雀和滚动发布，蓝绿发布由此得名；



#### 发布策略 - 其他

- **功能开关发布**：新功能（V2 new feature）和老功能（V1 old feature）住在同一套代码中，新功能隐藏在开关后面，如果开关没有打开，则走老代码逻辑，如果开关打开，则走新代码逻辑。
  - 需要一个配置中心或者开关中心这样的服务支持
- **A/B 测试**：为了验证 V2 的功能正确性，同时也为了避免 V2 有问题时影响所有用户，先通过 LB 将手机端的流量切换到 V2 版本，经过一段时间的 A/B 比对测试和观察（主要通过用户和监控反馈），确保 V2 正常，则通过 LB 将全部流量切换到 V2。
  - 功能开关和 A/B 测试有点相似，但功能开关一般是无状态和全量的
- **影子测试**：对于一些涉及核心业务的遗留系统的升级改造，为了确保万无一失，有一种称为影子测试的大招，采用比较复杂的**流量复制、回放和比对技术**实现。



#### 注意

- 如果**多个控制器具有重叠的选择算符**，它们可能会发生冲突 执行难以预料的操作。
- **仅当 Deployment Pod 模板（即 `.spec.template`）发生改变时， 才会触发 Deployment 上线**。 其他更新（如对 Deployment 执行扩缩容的操作）不会触发上线动作。
- 所以**更新 Deployment 时，会创建新的 ReplicaSet**。新的 ReplicaSet 缩放为 `.spec.replicas` 个副本， 所有旧 ReplicaSets 缩放为 0 个副本。
-  在 API 版本 `apps/v1` 中，在创建后 Deployment **标签选择算符是不可变的**
- 当你回滚到较早的修订版本时，只有 Deployment 的 Pod 模板部分会被回滚。



```bash
# 创建 deployment 配置
kubectl create deployment nginx --image nginx --dry-run client -o yaml > nginx-dep.yaml

# 升级
# --record 将此CLI命令记录到annotation中
kubectl set image deployment web nginx=nginx:1.15 --record
kubectl edit deployment web

# 查看升级状态 / 历史
kubectl rollout status deployment web
kubectl rollout history deployment web

# 回滚
kubectl rollout undo deployment web
kubectl rollout undo deployment web --to-version=1

# 弹性伸缩
kubectl scale deployment web --replicas=10

# 暂停与恢复升级操作
kubectl rollout pause deployment web
kubectl set image deployment web nginx=nginx:1.16
kubectl set resources deployment web -c=nginx --limits=cpu=200m,memory=512Mi
kubectl rollout resume deployment web
```



### StatefulSet

用来管理有状态应用的工作负载对象。 用来管理某 [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 集合的部署和扩缩， 并为这些 Pod **提供持久存储和持久ID**。

如果希望**使用存储卷为工作负载提供持久存储**，可以使用 StatefulSet 作为解决方案的一部分。 尽管 StatefulSet 中的单个 Pod 仍可能出现故障， 但持久的 Pod 标识符使得将现有卷与替换已失败 Pod 的新 Pod 相匹配变得更加容易。

和 Deployment 不同的是， StatefulSet 为它们的每个 Pod 维护了一个有粘性的 ID。这些 Pod 是基于相同的规约来创建的， 但是不能相互替换：无论怎么调度，每个 Pod 都有一个**永久不变的 ID**。



#### 意义

StatefulSets 对于需要满足以下一个或多个需求的应用程序很有价值：

- 稳定的、唯一的网络标识符。
- 稳定的、持久的存储。
- 有序的、优雅的部署和缩放。
- 有序的、自动的滚动更新。



#### 工作原理

- **有序索引**：每个 Pod 将被分配一个整数序号， 从 0 到 N-1，该序号在 StatefulSet 上是唯一的。
- **稳定的网络ID**
  - 每个 Pod 根据 StatefulSet 的名称和 Pod 的序号派生出它的**主机名和DNS**。
  - 使用 [无头服务](https://kubernetes.io/zh/docs/concepts/services-networking/service/#headless-services) 控制它的 Pod 的网络域
- **稳定的存储**
  - 为每个 VolumeClaimTemplate 创建一个 [PersistentVolume](https://kubernetes.io/zh/docs/concepts/storage/persistent-volumes/)。
  - 当一个 Pod 被调度（重新调度）到节点上时，它的 `volumeMounts` 会挂载与其 PersistentVolumeClaims 相关联的 PersistentVolume。
  - 当 Pod 或者 StatefulSet 被删除时，与 PersistentVolumeClaims 相关联的 PersistentVolume 并不会被删除。要删除它必须通过手动方式来完成
- Pod会添加一个标签 `statefulset.kubernetes.io/POD_NAME`
- **部署和扩缩保证**
  - 对于包含 N 个 副本的 StatefulSet，当部署 Pod 时，它们是依次创建的，顺序为 `0..N-1`。
  - 当删除 Pod 时，它们是逆序终止的，顺序为 `N-1..0`。
  - 在将缩放操作应用到 Pod 之前，它前面的所有 Pod 必须是 Running 和 Ready 状态。
  - 在 Pod 终止之前，所有的继任者必须完全关闭。



#### 注意

- 给定 Pod 的存储必须由 **PersistentVolume 驱动** 基于所请求的 `storage class` 来提供，或者由管理员预先提供。

- **删除或者收缩 StatefulSet 并*不会*删除它关联的存储卷。** 这样做是为了保证数据安全，它通常比自动清除 StatefulSet 所有相关的资源更有价值。

- StatefulSet 当前**需要 Headless Serivce 来负责 Pod 的网络标识**。你需要负责创建此服务。

- 当删除 StatefulSets 时，StatefulSet 不提供任何终止 Pod 的保证。 为了实现 StatefulSet 中的 Pod 可以**有序地且体面地终止，可以在删除之前将 StatefulSet 缩放为 0**。



你需要在三个配置项之外，配置`serviceName`和`VolumeClaimTemplate`。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"
  replicas: 3 # by default is 1
  template:
    metadata:
      labels:
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-storage-class"
      resources:
        requests:
          storage: 1Gi
```



### DaemonSet

确保全部（或者某些）节点上运行一个 Pod 的副本。删除 DaemonSet 将会删除它创建的所有 Pod。



#### 场景

- 在每个节点上运行集群守护进程
- 在每个节点上运行日志收集守护进程
- 在每个节点上运行监控守护进程



### Job

- Job 会创建一个或者多个 Pods，并**确保指定数量**的 Pods 成功终止，任务即结束。
-  删除 Job 的操作会清除所创建的全部 Pods。



#### 使用场景

| Job类型               | 使用示例                | 行为                                         | completions | Parallelism |
| --------------------- | ----------------------- | -------------------------------------------- | ----------- | ----------- |
| 一次性Job             | 数据库迁移              | 创建一个Pod直至其成功结束                    | 1           | 1           |
| 固定结束次数的Job     | 处理工作队列的Pod       | 依次创建一个Pod运行直至completions个成功结束 | 2+          | 1           |
| 固定结束次数的并行Job | 多个Pod同时处理工作队列 | 依次创建多个Pod运行直至completions个成功结束 | 2+          | 2+          |



#### 失效场景

- 容器失效：重启策略（注意重启策略是针对容器的）
  - `OnFailure`：**Pod 则继续留在当前节点，但容器会被重新运行**
    - 例：其中的进程退出时返回值非零， 或者容器因为超出内存约束而被杀死等等。
  - `Never`
  - `Always`：不支持

- Pod失效：Job 控制器会启动一个新的 Pod，使用指数型回退计算重试延迟（10s - 6min）
- Job失效：回退失效`backoffLimit`与超时`activeDeadlineSeconds`



#### 终止与清理

- Job 完成后，已有的 Pod 和 Job 本身不会被删除，这样你就可以查看它的状态和日志。
- `backoffLimit`：一旦重试次数到达所设的上限，Job 会被标记为失败， 其中运行的 Pods 都会被终止。
- `activeDeadlineSeconds`：一旦 Job 运行时间达到 ，其所有运行中的 Pod 都会被终止。
- `ttlSecondsAfterFinished`：alpha特性，在Job完成后的n秒后，级联删除Job



#### 注意

- restartPolicy只支持OnFailure和Never，不支持Always
- 实际在任意时刻运行状态的 Pods 个数，可能比并行性请求略大或略小
- 建议在调试 Job 时将 `restartPolicy` 设置为 "Never"，而非`OnFailure`



```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```



### CronJob

用 [Cron](https://en.wikipedia.org/wiki/Cron) 格式进行编写， 并周期性地在给定的调度时间**创建并执行 Job**。



#### 时间安排

1. 开始的期限`startingDeadlineSeconds`
   - 过了截止时间，CronJob 就不会开始 Job，任务会被统计为失败任务。
   - 当错过了100次以上的调度，CronJob 就不再调度了。若开始期限没有设定，则统计从最后一次调度开始的失败次数。
2. 并发策略`concurrencyPolicy`：当新任务执行时，旧任务没有处理完
   - `Allow` (默认)：CronJob 允许并发任务执行。
   - `Forbid`： 忽略新任务的执行。
   - `Replace`：用新任务替换当前正在运行的任务。



#### 注意

- 所有 **CronJob** 的 `schedule:` 时间都是基于 [kube-controller-manager](https://kubernetes.io/docs/reference/generated/kube-controller-manager/) 的时区。

- 在每次该执行任务的时候大约会创建一个 Job。 在某些情况下，可能会创建两个 Job，或者不会创建任何 Job。者不能完全杜绝。因此，**Job 应该是 *幂等的***。

  

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            imagePullPolicy: IfNotPresent
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure

```



### 垃圾收集

垃圾收集器的作用是删除某些曾经拥有属主（Owner）但现在不再拥有属主的对象。



#### 所有者和附属

- Kubernetes 会自动设置 `ownerReference` 的值。 由 ReplicationController、ReplicaSet、StatefulSet、DaemonSet、Deployment、 Job 和 CronJob 所创建或管理的对象。
- 用户也可以自行管理所有者和附属



#### 级联删除

如果删除对象时，不自动删除它的附属，这些附属被称作 **孤立对象** 。

1. **前台级联删除**（自下而上）

   - 当所有者被删除时，会进 deletion in progress状态，
   - 在这种删除策略中，所有者对象的删除将会持续到其所有从属对象都被删除为止。
   - 一旦对象被设置为 “正在删除” 状态，垃圾回收器将删除其从属对象。当垃圾回收器已经删除了所有的 ownerReference.blockOwnerDeletion=true 的对象后，将删除所有者对象。

2. **后台级联删除**（自上而下）立即删除所有者，同时垃圾回收器在后台删除从属对象。



#### 注意

- kubernetes 不允许跨命名空间指定属主。



### TTL 控制器

这是一个alpha特性，并且目前只处理 Job。

用于在一段时间内自动清理已结束的作业。





## 核心概念 - 服务与网络

Kubernetes 网络解决四方面的问题：

- 同 Pod 中**容器间通信**
- 同集群中 **pod 间通信**
- 集群外部的访问**对外暴露**的 Pods 中的应用
- 仅供集群**内部访问**的服务。



### Service

为一组功能相同的Pod 提供统一访问接口。

Kubernetes 为 Pods 提供**一个集群 IP**，并为一组 Pod 提供相同的 DNS 名， 并且可以在它们之间进行负载均衡。



#### 目的

Pod 是动态添加和删除的，其访问地址需要维护不变。

1. 服务发现：类似与命名服务，Pod进行注册，可以动态访问并防止Pod失联
2. 负载均衡：定义Pod访问策略



#### 定义 - 位于集群内部

服务配置提供：`selector`查找Pod而非其他资源，`ports`。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376 # 也可以是一个名字
```

- 将请求代理到使用 TCP 端口 9376，并且具有标签 `"app=MyApp"` 的 Pod 上。 
- 为该服务**分配 IP 地址**（有时称为 "集群IP"），该 IP 地址由服务代理使用。
- 服务**选择算符不断扫描**与其选择器匹配的 Pod，然后将所有更新发布到也称为 “my-service” 的 **Endpoint 对象**，从而指明Pod位置。



#### 定义 - 位于集群外部 Endpoint

**没有选择算子的情况**

由于此服务没有选择算符，因此 *不会自动创建* 相应的 Endpoint 对象。

Endpoint配置提供：`subsets.adresses` & `subsets.ports`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
---
apiVersion: v1
kind: Endpoints
metadata:
  name: my-service
subsets:
  - addresses:
  	- ip: 10.244.1.5
  	- ip: 10.244.1.6
  	ports:
  	- port: 80
      protocol: TCP

```

场景：

- 使用外部的数据库集群。
- 指向另一个 命名空间 中或其它集群中的服务。
- 仅在 Kubernetes 中运行一部分后端。



#### 定义 - 位于集群外部 ExternalName

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ExternalName
  externalName: abc.xyz
  ports:
  	- port: 80
```

- 当查找主机 `my-service.prod.svc.cluster.local` 时，集群 DNS 服务返回 `CNAME` 记录， 其值为`abc.xyz`。
- 访问 `my-service` 的方式与其他服务的方式相同，但主要区别在于重定向发生在 DNS 级别，而**不是通过代理或转发**。



#### 服务发现

客户端如何知道需要调用的服务的地址？

**通过环境变量**

如果服务早于Pod被创建，则Pod容器可以通过环境变量进行访问。

```shell
$ env
WEB_NGINX_SERVICE_HOST=10.101.39.175
WEB_NGINX_SERVICE_PORT=80
WEB_NGINX_PORT=tcp://10.101.39.175:80
...
```

**通过DNS & 完全限定域名FQDN**

kube-system中存在`kube-dns`的Pod，它用来充当集群的DNS。

每个Pod的容器中`/etc/resolv.conf`都包含了如下配置：

```
# 设置kube-dns为DNS
nameserver 10.96.0.10
# 指明查询顺序。当要查询没有域名的主机，主机将在由search声明的域中分别查找。
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

我们可以通过`SERVICE.NS.svc.cluster.local`访问服务，也可通过查询顺序配置来简化访问，如：`SERVICE`，`SERVICE.NS`等。

**注意**：服务不能通过`ping`命令访问，应为serivce的实现是通过VIP，并且与端口结合才能有意义。



#### 服务暴露 - NodePort

> https://mp.weixin.qq.com/s/dHaiX3H421jBhnzgCCsktg

在所有节点上开放端口，转发至service。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30123
  selector:
    app: web
```

![Image](https://mmbiz.qpic.cn/mmbiz_png/FE4VibF0SjfPRHpZDxMSOWXYXJMTEgSroEWp84B8w67IW1Tt6eCPSp2iaqsmmpmUKNy9qR83Gnrgiao9nzGS2tQVg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

这种方式有一些不足：

1. 一个端口只能供一个服务使用；
2. 只能使用30000–32767的端口；
3. 如果节点 / 虚拟机的**IP地址发生变化**，需要进行处理。
4. 节点获得的请求中，源IP会进行SNAT

因此，我不推荐在生产环境使用这种方式来直接发布服务。如果不要求运行的服务实时可用，或者在意成本，这种方式适合你。例如用于演示的应用或是临时运行就正好用这种方法。



#### 服务暴露 - LoadBalancer

分配一个**独有的IP地址**，将所有流量转发到某个服务中。

注意：

1. 下图有误，Load Balancer 会**首先连接到某个节点**，然后才访问Service，随机选择Pod。
2. `externalTrafficPolicy: local`：当这个设置启用后，Service会选择本Pod进行下一步的工作。这会减少一次网络跳数，同时不使用SNAT，但是这并不能保证流量是否平均在Pod上。（如：某一个节点上包含了大多数的Pod）
3. 节点获得的请求中，源IP会进行SNAT

![Image](https://mmbiz.qpic.cn/mmbiz_png/FE4VibF0SjfPRHpZDxMSOWXYXJMTEgSroXH2jiaNA55b36pwxk4USEaparfyI0ttj00B4slGqcM7tRNcCmdrlkJw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



#### 服务暴露 - Ingress

- Ingress只需要一个公网IP即可提供许多服务。
- 它会根据主机名和请求路径决定该访问哪个服务
- 在HTTP层上工作，提供k8s其他组件没有的功能，如cookie会话亲和性

详见下文Ingress。



#### 其他

- 会话亲和性`sessionAffinity`：`None`或`ClientIP`

  - 保证同一个`ClientIP`的请求，会被发送到同一个Pod中

- 多端口服务：每个端口需要指定名字

- 命名端口：更换端口不需要修改service配置

```yaml
# pod
containers:
  - name: xxx
  	ports:
  	  - name: http
  	  	containerPort: 8080
---
# service
ports:
  - name: http
  	port: 80
   	targetPort: http
  - name: https
   	port: 443
   	targetPort: 8443
```

  

### Ingress

- Ingress只需要一个公网IP即可提供许多服务。
- 它会根据主机名和请求路径决定该访问哪个服务
- 在HTTP层上工作，提供k8s其他组件没有的功能，如cookie会话亲和性
- Ingress 控制器是比不可少的，可用官方的 Ingress-nginx

![Image](https://mmbiz.qpic.cn/mmbiz_png/FE4VibF0SjfPRHpZDxMSOWXYXJMTEgSroZMy5yOhB1gVFun7M5jclp4ticUubOqhD1KoXKqqaLuxW5BBI5Zd41JQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wildcard-host
spec:
  rules:
    # host 可选，可进行通配符匹配
  - host: "foo.bar.com"
    http:
      paths:
      	# pathType: Prefix 匹配尾部斜线及子路径
      	# pathType: Exact 严格匹配
      - pathType: Prefix
        path: "/bar"
        backend:
          service:
            name: service1
            port:
              number: 80
  - host: "*.foo.com"
    http:
      paths:
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: service2
            port:
              number: 80
      - pathType: Prefix
        path: "/bar"
        backend:
          service:
            name: service3
            port:
              number: 80
```



### Headless Service

当不需要或不想要负载均衡，以及单独的 Service IP时。

可以通过指定`spec.clusterIP`的值为 `None` 来创建 Headless Service。

Headless Service配置后，当DNS查找服务时，会返回多个Pod的A记录。指向支持次服务的Pod。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: headless-service
spec:
  ClusterIP: None
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: web
```

```shell
$ k exec dnsutils -- nslookup headless-service
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	headless-service.default.svc.cluster.local
Address: 10.244.1.7
Name:	headless-service.default.svc.cluster.local
Address: 10.244.1.5
Name:	headless-service.default.svc.cluster.local
Address: 10.244.1.8
Name:	headless-service.default.svc.cluster.local
Address: 10.244.1.6
```



### 服务故障排查

> 见《Kubernetes in Action》, Page 158



## 核心概念 - 卷

- 使用卷时, 在 `.spec.volumes` 字段中设置为 Pod 提供的卷，并在 `.spec.containers[*].volumeMounts` 字段中声明卷在容器中的挂载位置。 容器中的进程看到的是由它们的 Docker 镜像和卷组成的文件系统视图。 

- 卷不能挂载到其他卷之上，也不能与其他卷有硬链接。 Pod 配置中的每个容器必须独立指定各个卷的挂载位置。



### emptyDir

当 Pod 因为某些原因被从节点上删除时，`emptyDir` 卷中的数据也会被永久删除。

容器崩溃并**不**会导致 Pod 被从节点上移除，因此容器崩溃期间 `emptyDir` 卷中的数据是安全的。

`emptyDir` 的一些用途：

- **缓存空间**，例如基于磁盘的归并排序。
- 为耗时较长的计算任务提供检查点，以任务能方地从崩溃前状态恢复执。
- 在 Web 服务器容器服务数据时，保存内容管理器容器获取的文件。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```

你甚至可以设定内存上的存储。为你挂载 tmpfs（基于 RAM 的文件系统）。 虽然 tmpfs 速度非常快，但是要注意它与磁盘不同。 tmpfs 在节点重启时会被清除，并且你所写入的所有文件都会计入容器的内存消耗，受容器内存限制约束。

```yaml
volumes:
  - name: mem-volume
  	emptyDir:
  	  medium: Memory
```



### gitRepo

注意：它已经被弃用。

- 如果需要在容器中提供 git 仓库，请将一个 [EmptyDir](https://kubernetes.io/zh/docs/concepts/storage/volumes/#emptydir) 卷挂载到 InitContainer 中，使用 git 命令完成仓库的克隆操作， 然后将 [EmptyDir](https://kubernetes.io/zh/docs/concepts/storage/volumes/#emptydir) 卷挂载到 Pod 的容器中。
- 如果需要不断更新git仓库，你需要sidecar容器来完成它。sidecar容器中使用git sync镜像来对emptyDir进行同步。
- 已被启用的gitRepo是不能配置私有仓库的。



### hostPath

它是一种持久性存储。`hostPath` 卷能将主机节点文件系统上的文件或目录挂载到你的 Pod 中。

例如，`hostPath` 的一些用法有：

- 运行一个需要访问 Docker 内部机制的容器；可使用 `hostPath` 挂载 `/var/lib/docker` 路径。
- 在容器中运行 cAdvisor 时，以 `hostPath` 方式挂载 `/sys`。



#### 注意

- 具有相同配置（例如基于同一 PodTemplate 创建）的多个 Pod 会由于节点上文件的不同 而在不同节点上有不同的行为。
- 下层主机上创建的文件或目录只能由 root 用户写入。你需要在 [特权容器](https://kubernetes.io/zh/docs/tasks/configure-pod-container/security-context/) 中以 root 身份运行进程，或者修改主机上的文件权限以便容器能够写入 `hostPath` 卷。



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      # 宿主上目录位置
      path: /data
      # 此字段为可选
      type: Directory
```



### nfs

```bash
# on NFS server
yum install -y nfs-utils
mkdir -p /data/nfs
cat >> /etc/exports << EOF
/data/nfs *(rw,no_root_squash)
EOF
systectl enable --now nfs 

# on K8S master server
yum install -y nfs-utils
```

```yaml
volumes:
- name: nfs-volume
  nfs:
    server: 1.2.3.4
    path: /path/exposed/from/server
```



### PersistantVolume

为了能够请求存储资源，同时屏蔽处理基础设施的细节。



#### 介绍

- `PersistentVolume` 是集群中管理员分配的一块存储。
  - 它属于集群中的资源，如同节点是集群中的资源一样，**它不属于任何 Namespace**。
  - PV 是存储卷插件，它拥有生命周期，但是独立于那些使用 PV 的 Pod 生命周期。支持 NFS、iSCSI 或者云供应商存储系统。

- `PersistentVolumeClaim` 用于用户请求存储资源。
  - 它类似 Pod，Pod 消耗节点资源，而 PVC 消耗 PV 资源。
  - Pods 可以请求特定级别的资源（CPU 和 内存），PVC 可以请求特定的存储大小和访问模式（如可以一次读写挂载或只读模式）。



![img](https://gblobscdn.gitbook.com/assets%2F-LoAvJI9gBldK6-l44i7%2F-LoAvd-24y_bdbAVPeKH%2F-LoAvmmR9yCJqafe-HQh%2Fpv-pvc.png?alt=media)



#### 供应模式

**静态供应**

集群管理员创建若干 PV 卷。这些卷对象带有真实存储的细节信息，并且对集群 用户可用（可见）。PV 卷对象存在于 Kubernetes API 中，可供用户消费（使用）。



**动态供应**

如果管理员所创建的所有静态 PV 卷都无法与用户的 PersistentVolumeClaim 匹配， 集群可以尝试为该 PVC 申领动态供应一个存储卷。 这一供应操作是基于 StorageClass 来实现的：PVC 申领必须请求某个 [存储类](https://kubernetes.io/zh/docs/concepts/storage/storage-classes/)，同时集群管理员必须 已经创建并配置了该类，这样动态供应卷的动作才会发生。 如果 PVC 申领指定存储类为 `""`，则相当于为自身禁止使用动态供应的卷。



#### 生命周期

**阶段**

每个PV会处于以下阶段之一：

- Available（可用）-- 卷是一个空闲资源，尚未绑定到任何申领；
- Bound（已绑定）-- 该卷已经绑定到某申领；
- Released（已释放）-- 所绑定的申领已被删除，但是资源尚未被集群回收；
- Failed（失败）-- 卷的自动回收操作失败。

**PV / PVC 绑定**

- PVC 申领与 PV 卷之间的绑定是一种一对一的映射，实现上使用 ClaimRef 来记述 PV 卷 与 PVC 申领间的双向绑定关系。
- 如果找不到匹配的 PV 卷，PVC 申领会无限期地处于未绑定状态。
- 静态时PVC与PV绑定时会根据`storageClassName`和`accessModes`断哪些PV符合绑定需求。然后再根据存储量大小判断，首先存PV储量必须大于或等于PVC声明量；其次就是PV存储量越接近PVC声明量，那么优先级就越高。

**PV / PVC 保护状态下的删除**

- `Storage Object in Use Protection` 确保仍被 Pod 使用的 PVC 及其所绑定的 PV 在系统中不会被删除。
- 如果用户删除被某 Pod 使用的 PVC 对象，该 PVC 申领不会被立即移除。 **PVC 的移除会被推迟**，直至其不再被任何 Pod 使用。
- 此外，如果管理员删除已绑定到某 PVC 申领的 PV 卷，该 PV 卷也不会被立即移除。 **PV 的移除也要推迟到**该 PV 不再绑定到 PVC。
- 你可以看到当 PVC / PV 的状态为 `Terminating` 且其 `Finalizers` 列表中包含 `kubernetes.io/pvc-protection` 时，PVC 对象是处于被保护状态的。

**PV 回收策略**

PersistentVolume 对象的回收策略告诉集群，当其被 从申领中释放时如何处理该数据卷。

- `Retain`
  - 当 PVC 被删除时，PV 仍然存在，并被视为 released。
  - 由于卷上仍然存在这前一申领人的数据，该卷还不能用于其他申领。
- `Delete`
  - 会将 PV 从 Kubernetes 中移除，同时也会从外部基础设施中移除所关联的存储资产。
  - 动态供应的卷会继承[其 StorageClass 中设置的回收策略](https://kubernetes.io/zh/docs/concepts/storage/persistent-volumes/#reclaim-policy)，该策略默认 为 `Delete`。
- `Recycle`：弃用，替换为动态供应。
  - 执行一些基本的 擦除（`rm -rf /thevolume/*`）操作，之后允许该卷用于新的 PVC 申领。



#### 配置

**PV**

- `capacity`
- `volumeMode`
  -  `Filesystem` 的卷会被 Pod *挂载* 到某个目录。
  -  `Block`将卷作为原始块设备来使用，其上没有任何文件系统。
- `accessModes`
  - 每个卷只能同一时刻只能以一种访问模式挂载，即使该卷能够支持 多种访问模式。
  - RWO - ReadWriteOnce
  - ROX - ReadOnlyMany
  - RWX - ReadWriteMany
- `storageClassName`
  - 特定类的 PV 卷只能绑定到请求该类存储卷的 PVC 申领。 未设置 `storageClassName` 的 PV 卷没有类设定，只能绑定到那些没有指定特定 存储类的 PVC 申领。
- `PVReclaimPolicy`：三种选项，如上文
- `mountOptions`：并非所有持久卷类型都支持挂载选项

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv
spec:
  capacity:
    storage: 5Gi
  # 可选参数，为Filesystem或Block。
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  # PV 也可设定 storageClassName
  storageClassName: slow
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
    - hard
    - nfsvers=4.1
  nfs:
    path: /tmp
    server: 172.17.0.2
```



**PVC**


```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 4Gi
  # 显式设置空字符串，否则会被设置为默认的 StorageClass
  storageClassName: ""
  selector:
    matchLabels:
      release: "stable"
    matchExpressions:
      - {key: environment, operator: In, values: [dev]}
```



**Pod**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```



### StorageClass

每个 StorageClass 都包含 `provisioner`、`parameters` 和 `reclaimPolicy` 字段。

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
reclaimPolicy: Retain
```




```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 4Gi
  # 设置 storageClassName
  storageClassName: standard
  selector:
    matchLabels:
      release: "stable"
    matchExpressions:
      - {key: environment, operator: In, values: [dev]}
```



#### Provisioner

这些独立的程序遵循由 Kubernetes 定义的 [规范](https://git.k8s.io/community/contributors/design-proposals/storage/volume-provisioning.md)。 外部供应商的作者完全可以自由决定他们的代码保存于何处、打包方式、运行方式、使用的插件（包括 Flex）等。



#### 回收策略

可以是 `Delete` （默认）或者 `Retain`。





## 核心概念 - 配置



### 描述文件中的配置

Docker 使用 CMD 来设置命令行参数，使用 ENTRYPOINT 来指定程序入口。

```dockerfile
# shell 形式，通过Shell启动程序，不推荐使用
# ENTRYPOINT node app.js
# exec 模式，直接启动程序
ENTRYPOINT [ "node", "app.js" ]
CMD [ "--port", "8080" ]
```



#### 命令行参数

```yaml
spec:
  containers:
  - image: alpine
  	command: [ "/bin/echo" ]
  	args: [ "hello", "2020" ]
```



#### 环境变量

注意：yaml中数字需要添加引号

```yaml
spec:
  containers:
  - image: alpine
    env:
    - name: WORDS
      value: hello
    - name: YEARS
      value: "2020"
    command: [ "/bin/echo" ]
  	args: [ "${WORDS} ${YEARS}" ]
```





### ConfigMap

ConfigMap 是一种 API 对象，用来将非机密性的数据保存到健值对中。

Pods 可以将其用作**环境变量**、**命令行参数**或者**存储卷中的配置文件**。

为了在生产和测试等环境中，能够有效复用 Pod 描述文件，需要将配置文件进行解耦。

可进行**热更新**。



#### 创建 ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo
data:
  words: "hello"
  years: "2020"
  my-nginx.conf: |
    enemy.types=aliens,monsters
    player.maximum-lives=5
  user-interface.properties: |
    ...
```

或者通过CLI：

```bash
kubectl create configmap demo --from-literal=WORDS=hello
kubectl create configmap demo --from-file=nginx.conf
kubectl create configmap demo --from-file=nginx=nginx.conf
kubectl create configmap demo --from-file=/etc/nginx.d/

kubectl edit configmap demo
```



#### 使用 ConfigMap - 环境变量

**引用键值**

```yaml
kind: Pod
spec:
  containers:
  - image: alpine
    env:
    - name: WORDS
      valueFrom: 
        configMapKeyRef: 
          name: demo
          key: words
```

**一次性传递**

```yaml
kind: Pod
spec:
  containers:
  - image: alpine
    envFrom:
    - prefix: CONFIG_
      configMapRef:
        name: demo
```



#### 使用 ConfigMap - 文件挂载

**挂载所有配置文件**

```yaml
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      volumeMounts:
      - name: config
        # 挂载位置
        mountPath: "/etc/nginx/conf.d"
        readOnly: true
  volumes:
    - name: config
      configMap:
        name: demo
        # 可选，选定包含什么项目，进行挂载
        items:
        - key: "my-nginx.conf"
          # 名字映射
          path: "gzip.conf"
```



**挂载单独文件**

```yaml
spec:
  containers:
    - name: demo
      image: alpine
      command: ["sleep", "3600"]
      volumeMounts:
      - name: config
        # 挂载位置
        mountPath: "/etc/nginx.conf"
        subPath: "gzip.conf"
        readOnly: true
  volumes:
    - name: config
      configMap:
        name: demo
        # 可选，选定包含什么项目，进行挂载
        items:
        - key: "my-nginx.conf"
          # 名字映射
          path: "gzip.conf"
```



#### 注意

- 如果挂载了单独一个文件，那么不回进行热更新。
- 同时ConfigMap不应该作为可变对象存在，因为容器本身设计是为不可变的



### Secret

`Secret` 对象类型用来保存敏感信息，例如密码、OAuth 令牌和 SSH 密钥。

使用`Base64`编码能够提供二进制数据的存储，但大小限制在1MB。在Pod实际使用时不必再进行解码。



#### 安全

主要是 Kubernetes 对 `Secret`对象采取额外了预防措施。

1. **传输安全**
   - 在大多数 Kubernetes 项目维护的发行版中，用户与 API server 之间的通信以及从 API server 到 kubelet 的通信都受到 `SSL/TLS` 的保护。对于开启 HTTPS 的 Kubernetes 来说 `Secret` 受到保护所以是安全的。

2. **存储安全**
   - 只有当挂载 `Secret` 的POD 调度到具体节点上时，`Secret` 才会被发送并存储到该节点上。
   - 它不会被写入磁盘，而是存储在 tmpfs 中。一旦依赖于它的 POD 被删除，`Secret` 就被删除。
   - `etcd`使用加密存储。

3. **访问安全**
   - 同一节点上可能有多个 POD 分别拥有单个或多个`Secret`。但是 `Secret` 只对请求挂载的 POD 中的容器才是可见的。



#### 配置

- `type`：见文档，每个型都有不同的用法
- `data`/`stringData`：`data`使用base64进行配置，`stringData`使用字面量存储。

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-tls
type: Opaque
stringData:
  username: tanglizi
  password: passwd
```

- Pod中用法同ConfigMap，只是在环境变量用法中，替换为`secretKeyRef`



#### 注意

- 在拉取私有镜像的场合，使用`type: dockerconfigjson`为Pod进行配置。或使用ServiceAccount进行拉取。
- 在TLS场合，使用`type: tls`配置。



## 其他



### 集群安全机制



#### 概述

1. 访问集群需要进行：认证、健全和准入控制
2. 访问需要通过apiserver，它做同一协调



1. 认证
   - 传输安全：对外不保留8080端口
   - 认证：ca证书、token、用户名密码
2. 鉴权
   - RBAC鉴权（基于角色访问控制）

3. 准入
   - 类似访问控制器列表？



#### RBAC鉴权

- 基于命名空间
- 角色：role、ClusterRole
- 角色绑定：roleBinding、ClusterRoleBinding
- 主体：user、group、serviceAccount

```bash
kubectl create ns demo
kubectl run nignx --image=nginx -n demo

# 创建角色
# role.yaml 定义了一个角色 pod-reader 和这个角色的行为
kubectl apply -f role.yaml
kubectl get role -n demo

# 创建角色绑定
# role-binding.yaml 定义了一个角色绑定 read-pods 和主体（包括用户和角色）
kubectl apply -f role-binding.yaml
kubectl get role,rolebinding -n demo

# 用证书识别身份并登录
kubectl config ...

# 可尝试正确性
...
```



### Helm

1. Helm可以降一组yaml作为一个整体，实现高校复用
   - 原有部署方式：Deployment Service Ingress;
   - 仅适合单一应用，当微服务等时将维护大量配置
2. Helm应用级别的版本管理

Helm是K8s的包管理工具，类似pacman、pip、npm



#### 概念

- Helm：CLI client
- Chart：是描述应用的集合，yaml打包
- Release：基于chart的部署实体，是应用级别的版本管理



#### 演示

```bash
# repo CRUD
helm repo add aliyun http://...
helm repo list
helm repo remove aliyun
helm repo update

# install app
helm search repo NAME
helm install NAME APP_NAME
helm list 
helm statu NAME

# edit service configuration
kubectl edit svc XXX

# custom chart
helm create chart CHART_NAME/
# Chart.yaml: chart属性配置信息
# templates: 防止 yaml 文件
# values.yaml: yaml 的全局环境变量
helm install APP_NAME CHART_NAME/
helm upgrade APP_NAME CHART_NAME/

# reuse
```



### 集群资源监控

#### 监控指标

- 集群监控：节点利用率，节点数，运行pods
- Pod监控：容器指标、应用指标



#### 监控平台方案

Prometheus + Grafana（类似ELK）

1. Prometheus：HTTP接口定时抓取状态；监控、报警、数据库
2. Grafana：数据分析和可视化工具；支持多种数据源



**部署流程**

1. 部署Prometheus的守护进程`DaemonSet`和`NodePort`：prom/node-exporter
2. 部署Prometheus：应用Pod、应用expose、RBAC权限、ConfigMap配置
3. 部署Grafana：应用Pod、应用expose、应用Ingress
4. 配置Grafana：
   1. web进入配置Prometheus数据源（注意是集群内部的访问配置）
   2. 配置界面数据模板



## 实践

### 常用命令

> https://www.jianshu.com/p/fa2d827ac725



### 简单实践

本人利用vbox虚拟机进行master、worker1和worker2的集群模拟。

1. vbox设置`bridge`模式，目的是宿主和各虚拟机之间两两互通，同时可访问外网

2. 装`CentOS7.x86_64`系统

   注意检查IP是否正常分配，linux的桥接情况下IP应该是`192.168.1.x`

3. 装完开启`sshd`后，直接命令行启动虚拟机

   ```shell
   $ systemctl enable --now sshd
   
   $ VBoxManage list vms
   "Master" {14f506d3-f3ad-4fbf-8408-69067917861b}
   "Worker1" {e859ce65-9207-4f2d-808f-b3639d5fffc3}
   "Worker2" {bac724ff-3f02-4f51-86f1-cd654a3e1f73}
   
   $ VBoxHeadless -s Master
   ```

4. 添加下虚拟机的配置，和宿主机的ssh公钥

   ```shell
   $ ssh-copy-id master
   ```

5. 然后编写`init.sh`和`master-init.sh`，分发给各个节点

   ```bash
   #!/usr/bin/bash
   # init.sh
   # disable firewall and selinux
   systemctl disable firewalld
   systemctl stop firewalld
   sed -i 's/enforcing/disabled/' /etc/selinux/config
   setenforce 0
   
   # set host
   cat >> /etc/hosts << EOF
   192.168.1.5 master
   192.168.1.6 worker1
   192.168.1.7 worker2
   EOF
   
   # enable bridge iptables
   cat > /etc/sysctl.d/k8s.conf << EOF
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   EOF
   sysctl --system
   
   yum install -y ntpdate wget vim
   ntpdate 0.asia.pool.ntp.org
   
   # install docker
   wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O /etc/yum.repos.d/docker-ce.repo
   yum -y install docker-ce-18.06.1.ce-3.el7
   touch /etc/docker/daemon.json
   cat > /etc/docker/daemon.json << EOF
   {
     "registry-mirrors": ["https://b9pmyelo.mirror.aliyuncs.com"],
     "exec-opts": ["native.cgroupdriver=systemd"]
   }
   EOF
   systemctl enable --now docker
   
   # install kubelet kubeadm kubectl
   cat > /etc/yum.repos.d/kubernetes.repo << EOF
   [kubernetes]
   name=Kubernetes
   baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
   enabled=1
   gpgcheck=0
   repo_gpgcheck=0
   gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
   https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
   EOF
   yum install -y kubelet kubeadm kubectl
   systemctl enable kubelet
   ```

   ```bash
   #!/usr/bin/bash
   # master-init.sh
   kubeadm init \
     --apiserver-advertise-address 192.168.1.5 \
     --image-repository registry.aliyuncs.com/google_containers \
     --kubernetes-version v1.19.0 \
     --service-cidr 10.96.0.0/12 \
     --pod-network-cidr 10.244.0.0/16
   
   kubectl apply -f https://raw.sevencdn.com/coreos/flannel/master/Documentation/kube-flannel.yml
   ```

6. 然后通过一个nginx来确认集群是否正常运行

   注意同时所有节点`Ready`后，才说明正常启动



### 开发应用最佳实践
