
<!-- vim-markdown-toc Marked -->

* [Kubernetes 原理与实践](#kubernetes-原理与实践)
    * [简介](#简介)
        * [集群架构](#集群架构)
        * [如何运行应用](#如何运行应用)
        * [Kubernetes的好处](#kubernetes的好处)

<!-- vim-markdown-toc -->

# Kubernetes 原理与实践

> 大部分引用自 *Kubernetes in Action*



## 简介



### 集群架构

![控制面板和工作节点的组件](https://img-blog.csdnimg.cn/20200323193547753.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0hzdWVoWFhY,size_16,color_FFFFFF,t_70)



**控制面板**

用于控制集群，可部署于单节点。或通过副本部署多节点，以确保高可用性。

- API服务器：提供API，用以交互通信
- Scheduler：调度应用
- Controller Manager：执行集群级别的功能
- etcd：分布式数据存储，持久化配置



**工作节点**

是运行容器化应用的机器。

- 容器运行时：Docker或rkt等
- Kubelet：与API服务器通信，以控制节点
- kube-proxy：用于负载均衡



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



### Kubernetes的好处

1. 简化集群部署并利用节点硬件：k8s能够按照节点硬件资源，自动决定部署副本数目
2. 健康检查与自修复
3. 自动扩容



