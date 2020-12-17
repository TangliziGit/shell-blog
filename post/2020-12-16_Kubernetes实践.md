
<!-- vim-markdown-toc Marked -->

* [Kubernetes 实践](#kubernetes-实践)
    * [包管理](#包管理)
        * [Kustomize vs Helm](#kustomize-vs-helm)
        * [Kustomize](#kustomize)
            * [举例](#举例)
            * [常用命令](#常用命令)
            * [可用的配置](#可用的配置)
    * [控制器](#控制器)
        * [Deployment](#deployment)
        * [StatefulSet - MySQL 主从](#statefulset---mysql-主从)
        * [StatefulSet - Redis 主从](#statefulset---redis-主从)
    * [服务](#服务)
        * [Service](#service)
        * [Ingress](#ingress)
    * [存储](#存储)
        * [gitRepo - Sidecar](#gitrepo---sidecar)
        * [NFS](#nfs)
        * [PV & PVC](#pv-&-pvc)
    * [配置](#配置)
        * [ConfigMap / Secret](#configmap-/-secret)

<!-- vim-markdown-toc -->

# Kubernetes 实践

所有例子将放置在github上。



## 包管理



### Kustomize vs Helm

> [Kustomize vs Helm vs Kubes: Kubernetes Deploy Tools](https://blog.boltops.com/2020/11/05/kustomize-vs-helm-vs-kubes-kubernetes-deploy-tools)

> [Helm vs Kustomize: How to deploy your applications in 2020?](https://medium.com/@alexander.hungenberg/helm-vs-kustomize-how-to-deploy-your-applications-in-2020-67f4d104da69)

> [Helm 和 Kustomize：不只是含谷量的区别](https://cloud.tencent.com/developer/article/1484121)

选择Kustomize的原因：

1. 编写流程简单，不需要编写Chart、变量控制等复杂编写，编写越多则越不灵活。
2. 大多数场景下，不需要 Chart 依赖，只需依赖 Docker 镜像。
3. 功能简单清晰，kubectl 直接支持。
4. 不考虑派生和插件，仅作为应用的 YAML 组织方式也很有帮助。
5. 也有自己的插件系统。例如可以用简单的 YAML 定义，使用文件生成 Configmap/Secret。



### Kustomize

本人使用 Kustomzie 的目的主要是派生和组织 yaml 配置文件。

所以插件和大多数影响 yaml 配置本身的功能，并不会过多使用。



#### 举例

```bash
kustomize
├── base
│   ├── kustomization.yaml
│   ├── my-redis.conf
│   └── redis-pod.yaml
└── overlays
    └── staging
        ├── kustomization.yaml
        ├── redis-pod_add_env.yaml
        └── redis-pod-patch.yaml
```

**base/kustomization.yaml**

```yaml
resources:
- redis-pod.yaml

configMapGenerator:
- name: redis-config
  files:
  - my-redis.conf
- name: redis-env
  literals:
  - MASTER=true
```

**overlays/staging/kustomization.yaml**

```yaml
namePrefix: staging-
commonLabels:
  variant: staging
bases:
- ../../base

# modify base configurations
patches:
- path: redis-pod-patch.yaml
  target:
    kind: Pod
    name: redis

# add items to base configurations
patchesStrategicMerge:
- redis-pod_add_env.yaml
```





#### 常用命令

```bash
# 导出配置
k kustomize .

# 应用与查询
k apply -k .
k get -k .
k delete -k .
```



#### 可用的配置

本人推荐用法是`/base`下的文件只应该使用`resources`和`configMapGenerator`选项，而其他变体可使用其他配置。

- `commonAnnotations`：共用的注解
- `commonLabels`：共用的标签
- `namespace`：共用的NS
- `configMapGenerator`：快捷的配置选项，带有`behavior`选项
- `patchesStrategicMerge`：列表中的每个条目都对应一个patch文件，添加或覆盖。



## 控制器



### Deployment - web项目

> [示例：使用 Persistent Volumes 部署 WordPress 和 MySQL](https://kubernetes.io/zh/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress-mysql
spec:
  selector:
    matchLabels:
      app: wordpress-mysql
      tier: database
  template:
    metadata:
      labels:
        app: wordpress-mysql
        tier: database
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        envFrom:
        - secretRef: 
            name: mysql-env-secret
        ports:
        - name: mysql
          containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: mysql-pvc
```





### StatefulSet - Redis 主从

> https://www.simplerfroze.com/articles/2020/01/19/1579418881265.html

> https://www.jianshu.com/p/e71c5a3a7162

StatefulSet 目前来看，场景只有主从数据库的维护比较便利。

与Deploy + PV的主要优势是**每个实例都有独有的存储空间**，用于从数据库是最方便的。

```yaml
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: ms-redis
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ms-redis 
  serviceName: ms-redis
  template:
    metadata:
      name: ms-redis
      labels:
        app: ms-redis 
    spec:
      initContainers:
      - name: init-ms
        image: busybox:latest
        command: [ "sh", "/scripts/init.sh" ]
        volumeMounts:
        - name: redis-config
          mountPath: /usr/local/etc/redis
        - name: config
          mountPath: /tmp
        - name: init-scripts
          mountPath: /scripts
      containers:
      - name: redis
        image: redis
        args: [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
        ports:
        - name: redis
          containerPort: 6379
        volumeMounts:
        - name: redis-config
          mountPath: /usr/local/etc/redis
        - name: redis-pvc
          mountPath: /data
      volumes:
      - name: redis-config
        emptyDir: {}
      - name: config
        configMap:
          name: redis-config
      - name: init-scripts
        configMap:
          name: init-scripts
          items:
          - key: init.sh
            path: init.sh
  volumeClaimTemplates:
  - metadata:
      name: redis-pvc
    spec:
      accessModes:
      - ReadWriteOnce
      storageClassName: redis-storage
      resources:
        requests:
          storage: 1Gi
```







## 服务



### Service

**ClusterIP** / **NodePort** / **LoadBalancer** 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
spec:
  type: ClusterIP
  selector:
    app: wordpress-mysql
    tier: database
  ports:
  - port: 3306
```





### Ingress

`ingress-nginx`的安装有些麻烦，主要是国外的镜像源在国内失效的问题。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress-ingress
spec:
  rules:
  - host: "example.com"
    http:
      paths:
      - path: "/wp"
        pathType: Prefix
        backend:
          service:
            name: wordpress
            port:
              number: 80
```





## 存储



### gitRepo - Sidecar



### NFS

注意：NFS服务器和每个工作节点都需要安装`nfs-utils`



**服务器配置**

```
# /etc/exports
# 注意：在生产中不可使用no_root_squash来映射root
/tmp/data/mysql         *(rw,no_root_squash,fsid=0)
/tmp/data/wordpress             *(rw,no_root_squash,fsid=0)
```

```shell
systemctl enable --now nfs-server
```



**客户端使用**

这里简单提一下客户端的使用方法，便于调试。

```shell
$ showmount -e 192.168.1.4             
Export list for 192.168.1.4:
/tmp/data                             *
/home/tanglizi/Code/virt/k8s-examples *

$ mount -t nfs 192.168.1.4:/tmp/data ~/data
```



**资源配置**

```yaml
nfs:
  # the path exposed on server
  path: /tmp/data
  server: 192.168.1.4
```





### PV & PVC

**PV**

即使不是StorageClass也可以使用`StorageClassName`，它可以指定PV和PVC的绑定限定。

```yaml
piVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  storageClassName: mysql-storage
  persistentVolumeReclaimPolicy: Retain
  nfs:
    # the path exposed on server
    path: /tmp/data
    server: 192.168.1.4
```



**PVC**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  storageClassName: mysql-storage
  resources:
    requests:
      storage: 1Gi
  accessModes:
  - ReadWriteOnce
```





## 配置



### ConfigMap / Secret

见Kustomize标题中。

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config-h465kc6b89
data:
  my-redis.conf: |
    maxmemory 2mb
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-env-9ghct7k6gf
data:
  MASTER: "true"
```

**使用方式**：

```yaml
spec:
  contianer:
    envFrom:
    - configMapRef:
        name: redis-env
    # 或
    env:
    - name: redis-env
      valueFrom:
          configMapKeyRef:
            name: redis-env
            key: MASTER
```

