
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
     --apiserver-advertise-address=192.168.1.5 \
     --image-repository registry.aliyuncs.com/google_containers \
     --kubernetes-version v1.19.0 \
     --service-cidr=10.96.0.0/12 \
     --pod-network-cidr=10.244.0.0/16
   
   kubectl apply -f https://raw.sevencdn.com/coreos/flannel/master/Documentation/kube-flannel.yml
   ```

6. 然后通过一个nginx来确认集群是否正常运行

   注意同时所有节点`Ready`后，才说明正常启动