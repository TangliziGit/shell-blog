
<!-- vim-markdown-toc Marked -->

* [Kubernetes 原理与实践](#kubernetes-原理与实践)
    * [简介](#简介)
        * [集群架构](#集群架构)
        * [如何运行应用](#如何运行应用)
        * [Kubernetes的好处](#kubernetes的好处)

<!-- vim-markdown-toc -->

# Kubernetes 原理与实践

> 大部分引用自 *Kubernetes in Action* 与官方文档v1.19



## 简介



### 集群架构

![控制面板和工作节点的组件](https://img-blog.csdnimg.cn/20200323193547753.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0hzdWVoWFhY,size_16,color_FFFFFF,t_70)



**控制面板**

用于控制集群，可部署于单节点。或通过副本部署多节点，以确保高可用性。

- API服务器：提供API，用以交互通信
- Scheduler：调度应用
- Controller Manager：执行集群级别的功能，处理集群任务，一个资源一个控制器
- etcd：分布式数据存储，持久化配置



**工作节点**

是运行容器化应用的机器。

- 容器运行时：Docker或rkt等
- Kubelet：与API服务器通信，以控制节点
- kube-proxy：网络规则，用于负载均衡，管理节点网络



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

1. 简化集群部署并利用节点硬件

   k8s能够按照节点硬件资源，自动决定部署副本数目

2. 健康检查与自修复

3. 自动扩容 / 水平扩展

4. 服务发现

   提供统一对外入口并负载均衡

5. 滚动更新 & 版本回退

6. 密钥和配置管理

7. 批处理 & 定时任务



## 核心概念

> 首先简单过一遍仅做扫盲，具体内容再看书一次



### 简介



#### Pod

- 是k8s中部署的最小单元
- 是一组容器的集合
- 共享一组网络
- 生命周期是短暂的



#### Controller

- 确保预期Pod数量
- 有无状态应用部署 负责Pod生命周期
- 执行一次性任务和定时任务



#### Service

- 提供统一对外接口，定义pod访问规则



#### 多Master集群

- master通过负载均衡访问工作节点
- 提供了master的高可用能力



### 简单实践

本人打算利用vbox虚拟机进行master、worker1和worker2的集群模拟。

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



### 资源编排配置文件

k8s使用yaml格式进行资源编排，需要注意的是配置文件分为两个部分：控制器配置，被控制对象的配置。

使用`create`或`get`命令可以快速生成需要的yaml配置模板，或导出已有的配置，你可以对它进行修改使用。

例：

```bash
kubectl create deployment nginx --image nginx -o yaml --dry-run > nginx.yaml

kubectl get deployment nginx -o yaml > nginx.yaml
```



### Pod



#### 基本概念

- 最小部署单元
- 是一组容器的集合（每个pod存在一个Pause容器即根容器）
- pod中的容器共享一个网络命名空间
- 生命周期是短暂的



#### 特性

- Pod下运行应用的一个实例，即多个容器（容器进程最好是一对一的）
- 利于亲密型应用：多个应用之间进行频繁的网络交互



#### 共享

- 网络：<s>通过Pause容器创建网桥，其他容器加入网桥，即在网桥的子网中分配一个ip，由路由表、iptables和驱动实现</s>

  注意具体容器都共享了pause容器的网络，而pause容器IpcMode为sharable，且网络类型为none

- 存储：即共享数据卷，由驱动实现



#### 配置

1. 镜像拉取策略`imagePullPolicy`：有三种，是否主动拉取容器

2. 资源限制`resources.limit/requests`：对CPU和MEM进行最大/最小限制
3. 重启策略`restartPolicy`：三种，类似Docker
4. 健康检查策略：
   - 存活检查`livenessProbe`：若检查失败则杀死
   - 就绪检查`readinessProbe`：若检查失败则把Pod剔除出service
   - 检查方式：`httpGet`状态码范围，`exec`返回状态码为0，`tcpSocket`建立成功



#### 创建流程

1. master 节点
   1. apiserver 受到 create Pod 请求，创建 Pod，并写入 etcd
   2. Scheduler 获得新的Pod，进行调度；同时 apiserver 受到调度成功响应，写入etcd
2. worker 节点
   1. kubelet 获得Pod，同时启动容器；向 apiserver 返回状态响应，写入 etcd



#### 影响调度的因素

1. 资源限制策略`resources`
2. 基于标签：
   1. 节点选择器`nodeSelector`：标签
   2. 节点亲和性`nodeAffinity`
      1. 硬亲和性：条件必须满足
      2. 软亲和性：偏好，但不必须
3. 污点 & 污点容忍：设置某节点的特殊调度方式，以拒绝调度
   - 在node上设置一个或多个Taint后，除非pod明确声明能够容忍这些“污点”，否则无法在这些node上运行。
   - 污点值：`NoSchedule`,`PerferNoSchedule`,`NoExecute`
   - 常见应用场景：节点独占，特殊硬件标签，节点故障标签



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



### Controller - Deployment

Controller是通过label建立Pod的关联，在集群上管理和运行Pod和容器的对象。它负责Pod生命周期和规模，进行升级回滚操作。



#### 使用deployment控制器部署

```bash
# 创建 deployment 配置
kubectl create deployment nginx --image nginx --dry-run client -o yaml > nginx-dep.yaml
vim nginx.yaml
kubectl apply -f nginx.yaml

# 创建 service 配置
kubectl expose deployment nginx --port=80 --target-port=80 --type=NodePort --name=nginx1 --dry-run=client -o yaml > nginx-svc.yaml
kubectl apply -f nginx-expose.yaml

kubectl get pods,svc
```



#### 升级与回滚

```bash
kubectl set image deployment web nginx=nginx:1.15
# 查看升级状态 / 历史
kubectl rollout status deployment web
kubectl rollout history deployment web
# 回滚
kubectl rollout undo deployment web
kubectl rollout undo deployment web --to-version=1
```

注意：升级是一个个容器进行，只有在新版本容器启动后，再删除就有容器



#### 弹性伸缩

```bsah
kubectl scale deployment web --replicas=10
```



### Service

统一访问接口，定义Pod规则。意义在于：

1. 服务发现：类似与命名服务，Pod进行注册，可以动态访问并防止Pod失联
2. 负载均衡：定义Pod访问策略

Service也是通过label和selector与Pod建立关系。



#### 常用的三种类型

> https://mp.weixin.qq.com/s/dHaiX3H421jBhnzgCCsktg

1. `ClusterIP`：集群内部使用
2. `NodePort`：对外访问使用
3. `LoadBalancer`：对外使用，也可用于<u>共有云</u>



### Controller - StatefulSet

无状态 vs. 有状态

1. 无状态：
   - 每个Pod都是一样的
   - 没有启动顺序要求
   - 不用考虑在那个node执行
   - 随意水平扩展
2. 有状态
   - 每个Pod是独立的，保持启动顺序和唯一性
   - 唯一性：网络标识符，持续存储等
   - 有序性：mysql主从



#### 配置

**Headless Service**

是指 spec.clusterIP 设置成 None 的 Service。

因为没有ClusterIP，kube-proxy 并不处理此类服务，因为没有load balancing或 proxy  代理设置，在访问服务的时候回返回后端的全部的Pods IP地址，主要用于开发者自己根据pods进行负载均衡器的开发(设置了selector)。



### Controller - DaemonSet

每个节点都运行一个同样的Pod。



### Controller - Job & CronJob

Job：仅运行一次

CronJob：定时运行



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