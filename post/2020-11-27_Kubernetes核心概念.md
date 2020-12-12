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
        * [Init 容器](#init-容器)
        * [健康检查策略](#健康检查策略)
    * [核心概念 - 工作负载](#核心概念---工作负载)
        * [ReplicaSet](#replicaset)
            * [工作原理](#工作原理)
            * [何时使用](#何时使用)
            * [vs. RC](#vs.-rc)
            * [注意](#注意)
        * [Deployment](#deployment)
            * [工作原理](#工作原理)
            * [清理策略](#清理策略)
            * [金丝雀部署](#金丝雀部署)
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
            * [常用的三种类型](#常用的三种类型)
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
        * [配置管理](#配置管理)
            * [Secret](#secret)
            * [ConfigMap](#configmap)
        * [集群安全机制](#集群安全机制)
            * [概述](#概述)
            * [RBAC鉴权](#rbac鉴权)
    * [其他](#其他)
        * [Ingress](#ingress)
            * [概念](#概念)
            * [部署](#部署)
        * [Helm](#helm)
            * [概念](#概念)
            * [演示](#演示)
        * [持久存储](#持久存储)
        * [集群资源监控](#集群资源监控)
            * [监控指标](#监控指标)
            * [监控平台方案](#监控平台方案)
        * [高可用](#高可用)
            * [简介](#简介)
            * [大致结构](#大致结构)
            * [流程](#流程)
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





## 核心概念 - Pod

> 首先简单过一遍仅做扫盲，具体内容再看书一次



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
   - 就绪探针`readinessProbe`：若检查失败则把Pod剔除出service
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

> TODO

1. master 节点
   1. apiserver 受到 create Pod 请求，创建 Pod，并写入 etcd
   2. Scheduler 获得新的Pod，进行调度；同时 apiserver 受到调度成功响应，写入etcd
2. worker 节点
   1. kubelet 获得Pod，同时启动容器；向 apiserver 返回状态响应，写入 etcd



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

> TODO



#### 节点亲和性

> TODO



#### 拓扑分布约束

> TODO



#### 污点与污点容忍

> TODO



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



### Init 容器

Init 容器是一种特殊容器，在 [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) 内的应用容器启动之前运行。

Init 容器支持应用容器的全部字段和特性，包括资源限制、数据卷和安全设置。 然而，Init 容器对资源请求和限制的处理稍有不同，在下面[资源](https://kubernetes.io/zh/docs/concepts/workloads/pods/init-containers/#resources)节有说明。

同时 Init 容器不支持 `lifecycle`、`livenessProbe`、`readinessProbe` 和 `startupProbe`， 因为它们必须在 Pod 就绪之前运行完成。

在 Pod 启动过程中，每个 Init 容器会在网络和数据卷初始化之后按顺序启动。 kubelet 运行依据 Init 容器在 Pod 规约中的出现顺序依次运行之。

每个 Init 容器成功退出后才会启动下一个 Init 容器。



### 健康检查策略

> TODO

- 存活探针`livenessProbe`：若检查失败则杀死
- 就绪探针`readinessProbe`：若检查失败则把Pod剔除出service
- 检查方式：`httpGet`状态码范围，`exec`返回状态码为0，`tcpSocket`建立成功



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



#### 金丝雀部署

如果要使用 Deployment 向用户子集或服务器子集上线版本，则可以遵循 [资源管理](https://kubernetes.io/zh/docs/concepts/cluster-administration/manage-deployment/#canary-deployments) 所描述的金丝雀模式，创建多个 Deployment，每个版本一个。

- 主要稳定的发行版将有一个 `track` 标签，其值为 `stable`

- 新版本的 `track` 标签带有不同的值 （即 `canary`）

- 前端服务通过选择标签的公共子集（即忽略 `track` 标签）来覆盖两组副本

  

调整 `stable` 和 `canary` 版本的副本数量，以确定每个版本将接收 实时生产流量的比例（在本例中为 3:1）。 一旦有信心，你就可以将新版本应用的 `track` 标签的值从 `canary` 替换为 `stable`，并且将老版本应用删除。



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

为一组功能相同的Pod 提供统一访问接口。Kubernetes 为 Pods 提供自己的 IP 地址，并为一组 Pod 提供相同的 DNS 名， 并且可以在它们之间进行负载均衡。



#### 目的

Pod 是动态添加和删除的，其访问地址需要维护不变。

1. 服务发现：类似与命名服务，Pod进行注册，可以动态访问并防止Pod失联
2. 负载均衡：定义Pod访问策略



#### 常用的三种类型

> https://mp.weixin.qq.com/s/dHaiX3H421jBhnzgCCsktg

1. `ClusterIP`：集群内部使用
2. `NodePort`：对外访问使用
3. `LoadBalancer`：对外使用，也可用于<u>共有云</u>



>  TODO：
>
> 1. Endpoints
> 2. Headless Service
> 3. VIP
> 4. vs. DNS
> 5. ...



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
      targetPort: 9376
```



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



### 配置管理

#### Secret

将编码的数据存在etcd中，Pod容器以Volume方式或环境变量进行访问。

1. 创建：创建secret加密数据，使用`create -f secret.yaml`
2. 使用：
   - 在其他pod配置中使用此数据使用`env`，作为环境变量
   - 在其他pod配置中使用此数据使用`volume.secret`，作为卷中的文件



#### ConfigMap

存储不编码的数据于etcd，Pod容器以Volume方式或环境变量进行访问。



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



## 其他



### Ingress

NodePort的缺点

- 每个节点都开启端口，都可以访问
- 实际访问应使用域名，跳转到不同的端口服务中



#### 概念

Ingress 作为同一的service的访问入口，service再进行pod的服务发现。



#### 部署

1. 创建引用，通过NortPort Service暴露（ClusterIP 应该也可以）
2. 编写yaml配置，应用，之后可编写`Kind: Ingress`的Pod配置
3. 创建Ingress规则，什么域名访问什么service的什么内部端口



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



### 持久存储

数据卷emptydir是本地存储，pod重启则消失

- NFS（Docker 也有 NFS 文件存储）

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
  cat >> pod.yaml << EOF
  ...
  
  spec.containers.volumeMounts.name: NAME 
  spec.containers.volumeMounts.mountPath: 目标
  spec.volumes.name: NAME
  spec.volumes.nfs.server: IP(明文)
  spec.volumes.nfs.path: /data/nfs(明文)
  ...
  EOF
  ```

- PersistentVolume & PersistentVolumeClaim

  - PV 作为存储，PVC 作为中间层提供配额等服务；



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



### 高可用

单master节点，存在master挂掉的问题。



#### 简介

多master节点会存在一个 LoadBalancer 来分发工作节点到Master：

1. 作为负载均衡
2. 检查master节点状态
3. 使用虚拟IP（即VIP）来避免直接使用master的IP



#### 大致结构

使用 **keepalived** 实现高可用解决单点故障

用 **haproxy** 进行负载均衡

1. 存在一个VIP

2. 每个Master中额外配置：
   - keepalived：用于配置虚拟IP、查看是否存活
   - haproxy / nginx：用于负载均衡



#### 流程

1. 配置Master1
   1. 部署keepalived和haproxy（注意一个网卡可以有一个IP和一个VIP？）
   2. `kubeadm init --config kubeadm.yaml`
2. 配置Master2
   1. 部署keepalived和haproxy
   2. 加入集群
3. 配置节点
   1. 加入集群





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
