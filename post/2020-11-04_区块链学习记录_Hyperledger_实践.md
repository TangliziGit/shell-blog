
<!-- vim-markdown-toc GitLab -->

* [区块链技术实践 - Hyperledger Fabric 2 实践](#区块链技术实践-hyperledger-fabric-2-实践)
    * [部署生产网络](#部署生产网络)
        * [创建CA](#创建ca)
        * [使用CA创建身份和MSP](#使用ca创建身份和msp)
        * [部署Peer节点和Ordering节点](#部署peer节点和ordering节点)
        * [创世区块配置](#创世区块配置)
    * [部署生产网络 - 实例](#部署生产网络-实例)
        * [创建并启动CA](#创建并启动ca)
        * [注册登录并生成各个组织](#注册登录并生成各个组织)
        * [生成创世区块](#生成创世区块)
        * [创建并运行节点](#创建并运行节点)
        * [总结](#总结)

<!-- vim-markdown-toc -->

# 区块链技术实践 - Hyperledger Fabric 2 实践

> https://hyperledger-fabric.readthedocs.io/



## 部署生产网络



### 创建CA

Fabric网络中第一个安装的组件是CA。因为节点的证书要创建在节点部署之前。

并不一定用Fabric CA来创建这些证书，但Fabric CA也可以创建正确定义组件和组织的MSP结构。

如果用户自己选择创建CA而不是用Fabric CA，那么还需要自己创建MSP文件夹。

- **Enrollment CA**：登陆认证的作用。
  - 用来创建**组织的管理员的证书**，**组织的MSP**，还有**组织内的节点**。
  - 这个CA还会创建**额外的用户证书**。
- **TLS CA**：
  - 产生加密通信的证书TLS，用于防范中间人攻击。
  - `TLS CA`也常被用来启动节点或者关闭节点。
  - 用户可以选择单项或者双向的TLS，使用下面会讲的“mutual TLS”。
  - 在部署`enrollment  CA`之前要明确指定是否需要TLS。你需要首先部署`TLS CA`并使用根证书启动`enrollment CA`。当连接注册CA和登陆用户和节点身份时，这个TLS证书也被`fabric-ca client`使用。



在生产网络中，建议**每个组织至少部署一个CA用于登陆注册，另一个用于TLS**。

例如，如果部署了三个peer属于一个组织，一个排序节点属于排序组织，那你至少需要四个CA。每个peer有至少两个CA（登陆和TLS，admin，通信，代表组织的目录）还有两个是为排序节点。注意用于一般只用注册登陆CA来登陆，而节点会注册登陆都使用登陆CA（节点会得到签名证书并且为它的动作签名）使用TLS CA通信。



### 使用CA创建身份和MSP

一旦你创建了CA，你可以创建组织中的证书和组件。对每一个组织，你至少需要：

1. **注册并登录管理员用户身份 & 生成组织的MSP**

   - 当组织管理员同时也是节点管理员，则必须在创建本地MSP之前创建组织的管理员身份。
   - 由CA管理员生成用户名和密码。
   - 登录(enroll)后，CA将为此身份生成一组MSP文件夹，其中包含公共证书以及该CA的公钥等。

2. **注册并登录节点身份 & 生成节点的MSP**

   - 必须同时使用Enrollment CA和TLS CA来注册和登录节点身份。
   - 在Enrollment CA注册节点时，赋予其`Peer`或`Orderer`的角色。 与管理员一样，也可以分配此身份的属性和从属关系。
   - 节点的MSP结构称为`Local MSP`，因为分配给身份的权限仅在本地（节点）级别相关。

   

### 部署Peer节点和Ordering节点

在可以部署任何节点之前，必须自定义配置文件。

对于Peer节点，此文件称为`core.yaml`，而用于排序节点的配置文件称为`orderer.yaml`。

调整配置的方法有三种： 

1. 编辑与二进制文件捆绑在一起的YAML文件；
2. 部署时使用环境变量替代；
3. 在CLI命令上指定。

 

**创建Peer节点**

> [core.yaml示例](https://github.com/hyperledger/fabric/blob/master/sampleconfig/core.yaml)

尽管默认的core.yaml中有很多参数，但如果不需要更改调整值，使用默认值即可。

在core.yaml中的参数中有：

- **标识符**：这些标识符不仅包括相关本地MSP和TLS证书的路径，还包括`Peer`的ID和拥有`Peer`的组织的MSP ID。
- **地址和路径**：包括可以通过其他组件找到`Peer`节点本身的地址，以及可以找到链码的地址。您将需要指定账本的位置（以及状态数据库类型）和外部链码的外部构造器的路径。其中包括“操作”和“指标”，使您可以设置方法来通过配置端点来监视对等方的运行状况和性能。
- **Gossip**: 通过该协议，它们可以被发现服务发现，并相互传播块和私有数据。



**创建Ordering节点**

> [orderer.yaml示例](https://github.com/hyperledger/fabric/blob/master/sampleconfig/orderer.yaml)

与创建对等点不同，您需要创建一个创世区块(或者引用一个已经创建的块)，并在启动排序节点之前指定它的路径。创世区块不存储交易数据而是存储配置信息，它包括了排序系统通道的初始配置，所以必须在创建排序节点之前创建。

有一些关键的配置项需要了解：

- `General.LocalMSPID`: 本地MSP的ID，由组织的CA创建。
- `General.LocalMSPDir`: 排序节点的本地MSP所在的位置。注意，最佳实践是将此卷挂载到容器的外部。
- `General.ListenAddress` & `General.ListenPort`: 表示同一组织中其他排序节点的地址和端口。
- `FileLedger`: 账本文件路径。尽管排序节点没有状态数据库，但它们仍然都携带着区块链的副本，因为这允许它们使用最新的配置块来验证权限。
    - `Cluster`: 对于与其他排序节点通信的排序服务节点非常重要，例如在基于raft的排序服务中。
    - `General.BootstrapFile`: 这是用于引导排序节点的配置区块的名称。 如果此节点是生成的第一个节点，则必须生成此文件作为创世区块。
    - `General.BootstrapMethod`: 引导区块的一个方法。从2.0开始，您可以不指定任何内容以简单地启动订购程序而无需引导。
    - `Consensus`: 确定共识插件所允许的键值对（支持并推荐raft排序服务）用于预写日志（Write Ahead Logs ，WALDir）和快照（SnapDir）。



### 创世区块配置

此处细讲`configtx.yaml`的配置。
    
1. 组织部分

    用于配置不同组织的身份信息，在这个文件的后续配置中会用到。

    ```yaml
    Organizations:
        - &OrdererOrg
            # 组织名
            Name: OrdererOrg
            # 组织ID，用于加载MSP时的标记
            ID: OrdererMSP
            # MSP路径
            MSPDir: ../orgs/ordererOrgs/tanglizi.one/msp
            
            OrdererEndpoints:
                - orderer.tanglizi.one:7050
    
            # 定义组织的策略 
            # /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
            Policies:
                Readers:
                    Type: Signature
                    Rule: "OR('OrdererMSP.member')"
                Writers:
                    Type: Signature
                    Rule: "OR('OrdererMSP.member')"
                Admins:
                    Type: Signature
                    Rule: "OR('OrdererMSP.admin')"
    
        - &Org1
            Name: Org1MSP
            ID: Org1MSP
            MSPDir: ../orgs/peerOrgs/org1.tanglizi.one/msp
    
            Policies:
                Readers:
                    Type: Signature
                    Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
                Writers:
                    Type: Signature
                    Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
                Admins:
                    Type: Signature
                    Rule: "OR('Org1MSP.admin')"
                Endorsement:
                    Type: Signature
                    Rule: "OR('Org1MSP.peer')"
    
            AnchorPeers:
                # 用于Gossip协议的锚节点，这个值只会存储于应用程序上下文中的创世区块
                - Host: peer0.org1.tanglizi.one
                  Port: 7051
    
        - &Org2
    
            Name: Org2MSP
            ID: Org2MSP
            MSPDir: ../orgs/peerOrgs/org2.tanglizi.one/msp
    
            Policies:
                Readers:
                    Type: Signature
                    Rule: "OR('Org2MSP.admin', 'Org2MSP.peer', 'Org2MSP.client')"
                Writers:
                    Type: Signature
                    Rule: "OR('Org2MSP.admin', 'Org2MSP.client')"
                Admins:
                    Type: Signature
                    Rule: "OR('Org2MSP.admin')"
                Endorsement:
                    Type: Signature
                    Rule: "OR('Org2MSP.peer')"
    
            AnchorPeers:
                - Host: peer0.org2.tanglizi.one
                  Port: 9051
    ```
    
2. 向下兼容部分

    声明fabric使用的新特性。

    使用他们会让旧的节点停止服务或者崩溃，需要确保更新节点。

    ```yaml
    Capabilities:
        Channel: &ChannelCapabilities
            V2_0: true
    
        Orderer: &OrdererCapabilities
            V2_0: true
    
        Application: &ApplicationCapabilities
            V2_0: true
    ```

3. 应用部分
  定义了参与应用程序的组织，和对应的策略

   ```yaml
   Application: &ApplicationDefaults
       # 参与应用程序的组织列表
       Organizations:
   
       # 定义应用的策略 
       # /Channel/Application/<PolicyName>
       Policies:
           Readers:
               Type: ImplicitMeta
               Rule: "ANY Readers"
           Writers:
               Type: ImplicitMeta
               Rule: "ANY Writers"
           Admins:
               Type: ImplicitMeta
               Rule: "MAJORITY Admins"
           LifecycleEndorsement:
               Type: ImplicitMeta
               Rule: "MAJORITY Endorsement"
           Endorsement:
               Type: ImplicitMeta
               Rule: "MAJORITY Endorsement"
   
       Capabilities:
           <<: *ApplicationCapabilities
   
   ```

4. 排序配置部分	

    ```yaml
    Orderer: &OrdererDefaults
        # 排序的实现方法，即共识机制
        OrdererType: etcdraft
    
        # 供client和peer链接的排序节点地址
        # 最好的方式是填上之前组织部分的排序节点地址OrdererEndpoint
        Addresses:
            - orderer.tanglizi.one:7050
    
        EtcdRaft:
            Consenters:
            - Host: orderer.tanglizi.one
              Port: 7050
              ClientTLSCert: ../orgs/ordererOrgs/tanglizi.one/orderers/orderer.tanglizi.one/tls/server.crt
              ServerTLSCert: ../orgs/ordererOrgs/tanglizi.one/orderers/orderer.tanglizi.one/tls/server.crt
    
        # 排序节点优化参数
        # 批处理超时时间: 创建一个新的batch需要等待的时间
        BatchTimeout: 2s
    
        # batch大小: 控制当何时忽略超时时间，直接创建一个新的batch
        BatchSize:
    
            # 最大消息数: 接受客户端的消息数超过这个值，直接提交
            MaxMessageCount: 10
    
            # 绝对最大字节数: 接受客户端的消息内存大小超过这个值，直接提交
            AbsoluteMaxBytes: 99 MB
    
            # 偏好最大字节数: 大于偏好最大字节的消息将导致批处理大于首选最大字节。
            PreferredMaxBytes: 512 KB
    
        # 参与排序节点的组织列表，为何为空？
        Organizations:
    
        # 定义排序的策略 
        # /Channel/Orderer/<PolicyName>
        Policies:
            Readers:
                Type: ImplicitMeta
                Rule: "ANY Readers"
            Writers:
                Type: ImplicitMeta
                Rule: "ANY Writers"
            Admins:
                Type: ImplicitMeta
                Rule: "MAJORITY Admins"
            # 块验证指定了来自排序解嗲的块中必须包含哪些签名，以便对等方验证。
            BlockValidation:
                Type: ImplicitMeta
                Rule: "ANY Writers"
    
    ```

5. 通道配置
    ```yaml
    Channel: &ChannelDefaults
        # 定义通道的策略 
        # /Channel/<PolicyName>
        Policies:
            # 谁会调用 'Deliver' API
            Readers:
                Type: ImplicitMeta
                Rule: "ANY Readers"
            # 谁会调用 'Broadcast' API
            Writers:
                Type: ImplicitMeta
                Rule: "ANY Writers"
            # 默认情况下，谁可以在这个配置级别上修改元素
            Admins:
                Type: ImplicitMeta
                Rule: "MAJORITY Admins"
    
        Capabilities:
            <<: *ChannelCapabilities
    ```

6. 配置
  定义不同的配置方法，可以用来给`configtxgen`提供配置参数
   ```yaml
   Profiles:
   
       # 创世区块都有谁
       TwoOrgsOrdererGenesis:
           <<: *ChannelDefaults
           Orderer:
               <<: *OrdererDefaults
               Organizations:
                   - *OrdererOrg
               Capabilities:
                   <<: *OrdererCapabilities
           Consortiums:
               SampleConsortium:
                   Organizations:
                       - *Org1
                       - *Org2
       # 通道里有谁加入
       TwoOrgsChannel:
           Consortium: SampleConsortium
           <<: *ChannelDefaults
           Application:
               <<: *ApplicationDefaults
               Organizations:
                   - *Org1
                   - *Org2
               Capabilities:
                   <<: *ApplicationCapabilities
   
   ```





## 部署生产网络 - 实例

这一部分将会展示一个简单网络的部署过程，网络结构包括两种组织`peerOrgs`和`ordererOrg`。其中`peerOrgs`包括两个组织`org1`和`org2`。同时引入三个`fabric-ca`，作为他们的`enrollment CA`和`TLS CA`，用来管理注册登录和通信安全。



### 创建并启动CA

**目的**：用来生成各个组织的MSP文件夹、节点和用户的身份、TLS证书

**输入**：

1. 编写`docker-compose-fabric-ca.yaml`：
   1. 声明环境变量（用这种方式配置CA）：目录位置、CA名字、端口、TLS启用
   2. 映射目录至本地
   3. 覆盖默认命令：启动`fabric-ca-server`以引导管理员来构建默认配置
   4. 映射`port`、声明默认网络、容器名字

**输出**：

1. 一堆默认的CA配置：

   ```
   orgs/
   └── ca
       ├── ordererOrg
       │   ├── ca-cert.pem
       │   ├── fabric-ca-server-config.yaml
       │   ├── fabric-ca-server.db
       │   ├── IssuerPublicKey
       │   ├── IssuerRevocationPublicKey
       │   ├── msp
       │   │   ├── cacerts
       │   │   ├── keystore
       │   │   │   ├── 400846d6447617143a334d2589905df1a1cc1d7582288e192f01ceed8d3d8778_sk
       │   │   │   ├── ab0629bc01fd0dfd3b7a29a928dbf299b66781cfda4c2ac2016e7d9a47b27362_sk
       │   │   │   ├── IssuerRevocationPrivateKey
       │   │   │   └── IssuerSecretKey
       │   │   ├── signcerts
       │   │   └── user
       │   └── tls-cert.pem
       ├── org1
       │   ├── ca-cert.pem
       │   ├── fabric-ca-server-config.yaml
       │   ├── fabric-ca-server.db
       │   ├── IssuerPublicKey
       │   ├── IssuerRevocationPublicKey
       │   ├── msp
       │   │   ├── cacerts
       │   │   ├── keystore
       │   │   │   ├── 410fa1ed798486277bb88f3f6d1ee655fd092a677f9b643ef3682a1b7e895ebd_sk
       │   │   │   ├── b39898c4018a773724e679c2dfb3274e2aa1caa15bde395f0a7a03d431843164_sk
       │   │   │   ├── IssuerRevocationPrivateKey
       │   │   │   └── IssuerSecretKey
       │   │   ├── signcerts
       │   │   └── user
       │   └── tls-cert.pem
       └── org2
           ├── ca-cert.pem
           ├── fabric-ca-server-config.yaml
           ├── fabric-ca-server.db
           ├── IssuerPublicKey
           ├── IssuerRevocationPublicKey
           ├── msp
           │   ├── cacerts
           │   ├── keystore
           │   │   ├── 5f22fa39ebd1deeb1a93ceb178f2d9e34ebc69b304b9b18656cd61d9c7267c25_sk
           │   │   ├── 668c4e71353ac8c0773230d79d3c716caaf5276a6c965b986de85dba35128a15_sk
           │   │   ├── IssuerRevocationPrivateKey
           │   │   └── IssuerSecretKey
           │   ├── signcerts
           │   └── user
           └── tls-cert.pem
   
   19 directories, 30 files
   ```

   

**代码**：

```shell
IMAGE_TAG="latest" docker-compose -f docker-compose-fabric-ca.yaml up -d
```



注意：需要等待`docker-compose`启动并创建好默认配置，再进行下一个步骤。



### 注册登录并生成各个组织

**目的**：用刚才的CA，生成MSP文件夹、节点和用户的身份、TLS证书

**输入**：

1. CA生成的对应组织的TLS证书（`orgs/ca/org1/tls-cert.pem`，每次CLI请求都需要）
2. 组织的MSP配置（`orgs/peerOrgs/org1.tanglizi.one/msp/config.yaml`）
3. 节点的MSP配置（`orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/msp/config.yaml`）

**输出**：

1. 组织MSP、节点MSP和TLS文件（CA证书、自己的数字签名、自己的私钥）、账户MSP

   ```
   orgs
   ├── ca
   │   └── ...
   └── peerOrgs
       └── org1.tanglizi.one
           ├── ca
           │   └── ca.org1.tanglizi.one-cert.pem
           ├── fabric-ca-client-config.yaml
           ├── msp
           │   ├── cacerts
           │   │   └── localhost-7054-ca-org1.pem
           │   ├── config.yaml
           │   ├── IssuerPublicKey
           │   ├── IssuerRevocationPublicKey
           │   ├── keystore
           │   │   └── 64d65c3f2268740db68925bfc4708978d49bdb254b1c4d8c6f14cbce0fcd9ad4_sk
           │   ├── signcerts
           │   │   └── cert.pem
           │   ├── tlscacerts
           │   │   └── ca.crt
           │   └── user
           ├── peers
           │   └── peer0.org1.tanglizi.one
           │       ├── msp
           │       │   ├── cacerts
           │       │   │   └── localhost-7054-ca-org1.pem
           │       │   ├── config.yaml
           │       │   ├── IssuerPublicKey
           │       │   ├── IssuerRevocationPublicKey
           │       │   ├── keystore
           │       │   │   └── adaf2a7e1d597406406d480b88359487f0488c19a29773b34093bc4d8f68ef2e_sk
           │       │   ├── signcerts
           │       │   │   └── cert.pem
           │       │   └── user
           │       └── tls
           │           ├── cacerts
           │           ├── ca.crt
           │           ├── IssuerPublicKey
           │           ├── IssuerRevocationPublicKey
           │           ├── keystore
           │           │   └── e4689ad83af670e10ef8a31245dd24f0a826cfe30c47c438d138e53e99f5b29f_sk
           │           ├── server.crt
           │           ├── server.key
           │           ├── signcerts
           │           │   └── cert.pem
           │           ├── tlscacerts
           │           │   └── tls-localhost-7054-ca-org1.pem
           │           └── user
           ├── tlsca
           │   └── tlsca.org1.tanglizi.one-cert.pem
           └── users
               ├── Admin@org1.tanglizi.one
               │   └── msp
               │       ├── cacerts
               │       │   └── localhost-7054-ca-org1.pem
               │       ├── config.yaml
               │       ├── IssuerPublicKey
               │       ├── IssuerRevocationPublicKey
               │       ├── keystore
               │       │   └── c919806cd08217a375e12dd9213cd9bf4371ecce4cbf133999e5fe022a3efc9a_sk
               │       ├── signcerts
               │       │   └── cert.pem
               │       └── user
               └── User1@org1.tanglizi.one
                   └── msp
                       ├── cacerts
                       │   └── localhost-7054-ca-org1.pem
                       ├── config.yaml
                       ├── IssuerPublicKey
                       ├── IssuerRevocationPublicKey
                       ├── keystore
                       │   └── 3f1c51648844704bdd250d3b71e345ac5222ce36a3d681aaa117192faefce18f_sk
                       ├── signcerts
                       │   └── cert.pem
                       └── user
   
   55 directories, 66 files
   ```

   

**代码**：

1. 登录本组织CA的admin账户，用于之后的注册节点和用户

   ```shell
   fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
   ```

2. 生成组织MSP配置

   ```yaml
   NodeOUs:
     Enable: true
     ClientOUIdentifier:
       Certificate: cacerts/localhost-7054-ca-org1.pem
       OrganizationalUnitIdentifier: client
     PeerOUIdentifier:
       Certificate: cacerts/localhost-7054-ca-org1.pem
       OrganizationalUnitIdentifier: peer
     AdminOUIdentifier:
       Certificate: cacerts/localhost-7054-ca-org1.pem
       OrganizationalUnitIdentifier: admin
     OrdererOUIdentifier:
       Certificate: cacerts/localhost-7054-ca-org1.pem
       OrganizationalUnitIdentifier: orderer' > ${PWD}/orgs/peerOrgs/org1.tanglizi.one/msp/config.yaml
   ```

3. 注册所有节点和账户

   ```shell
   fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
   
   fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
   
   fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
   ```

4. 登录所有`peer`节点，并生成MSP和TLS证书，并复制到正确位置

   1. 登录`peer`节点并生成本地MSP

      ```shell
      fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/msp --csr.hosts peer0.org1.tanglizi.one --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
      
      cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/msp/config.yaml \
         ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/msp/config.yaml
       
      ```

   2. 登录`peer`节点并生成TLS证书，`enrollment.profile`指定根据TLS CA上的TLS配置文件注册

      ```shell
      fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls --enrollment.profile tls --csr.hosts peer0.org1.tanglizi.one --csr.hosts localhost --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
      ```

   3. 复制TLS证书、数字签名和私钥，到节点根目录和组织根目录

      ```shell
        cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/tlscacerts/* \
           ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/ca.crt
        cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/signcerts/* \
           ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/server.crt
        cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/keystore/* \
           ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/server.key
        
        cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/tlscacerts/* \
           ${PWD}/orgs/peerOrgs/org1.tanglizi.one/msp/tlscacerts/ca.crt
        cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls/tlscacerts/* \
           ${PWD}/orgs/peerOrgs/org1.tanglizi.one/tlsca/tlsca.org1.tanglizi.one-cert.pem
        cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/msp/cacerts/* \
           ${PWD}/orgs/peerOrgs/org1.tanglizi.one/ca/ca.org1.tanglizi.one-cert.pem
      ```

5. 登录所有账户，并生成MSP

   ```shell
   fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M ${PWD}/orgs/peerOrgs/org1.tanglizi.one/users/User1@org1.tanglizi.one/msp --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
   
   cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/msp/config.yaml \
      ${PWD}/orgs/peerOrgs/org1.tanglizi.one/users/User1@org1.tanglizi.one/msp/config.yaml
     
   fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M ${PWD}/orgs/peerOrgs/org1.tanglizi.one/users/Admin@org1.tanglizi.one/msp --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
   
   cp ${PWD}/orgs/peerOrgs/org1.tanglizi.one/msp/config.yaml \
      ${PWD}/orgs/peerOrgs/org1.tanglizi.one/users/Admin@org1.tanglizi.one/msp/config.yaml
   }
   ```



注意：排序节点也是完全一样的流程，只不过是`peer`改为`orderer`就是了



### 生成创世区块

**目的**：用以启动排序系统

**输入**：

1. 交易配置（`configtx/configtx.yaml`）

**输出**：

1. 创世区块（`system-genesis-block/genesis.block`）

**代码**：

```shell
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ${PWD}/system-genesis-block/genesis.block
```





### 创建并运行节点

**目的**：创建网络中的两个peer和一个orderer节点

**输入**：

1. 编写`docker-compose-test-net.yaml`的Orderer部分:
   1. 声明环境变量（用这种方式配置Orderer）：过多
   2. 声明工作目录
   3. 映射目录至本地：创世区块、MSP、TLS、**生产目录**
   4. 覆盖默认命令：启动`orderer`
   5. 映射`port`、声明默认网络、容器名字
2. 编写`docker-compose-test-net.yaml`的Peer部分:
   1. 声明环境变量（用这种方式配置Peer）：过多
   2. 声明工作目录
   3. 映射目录至本地：MSP、TLS、**生产目录**、`/host/var/run`（用于虚拟机端点）
   4. 覆盖默认命令：启动`peer node start`
   5. 映射port、声明默认网络、容器名字

**输出**：

​	无

**代码**：

```shell
COMPOSE_PROJECT_NAME="simple-net" IMAGE_TAG="latest" docker-compose -f docker-compose-test-net.yaml up -d
```



### 总结

要点在于各种**配置文件的编写**和**文件的排布**。

实际上并没有什么太多东西。

- 配置文件：

  - 组织和节点的MSP配置

    ```yaml
    NodeOUs:
      Enable: true
      ClientOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-org1.pem
        OrganizationalUnitIdentifier: client
      PeerOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-org1.pem
        OrganizationalUnitIdentifier: peer
      AdminOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-org1.pem
        OrganizationalUnitIdentifier: admin
      OrdererOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-org1.pem
        OrganizationalUnitIdentifier: orderer
    ```

  - 创世区块配置`configtx/configtx.yaml`

    后续细讲

    

- Dockerfile

  - `docker-compose-fabric-ca.yaml`

    ```yaml
    # Copyright IBM Corp. All Rights Reserved.
    #
    # SPDX-License-Identifier: Apache-2.0
    #
    
    version: '2'
    
    networks:
      test:
    
    services:
    
      ca_org1:
        image: hyperledger/fabric-ca:$IMAGE_TAG
        environment:
          - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
          - FABRIC_CA_SERVER_CA_NAME=ca-org1
          - FABRIC_CA_SERVER_TLS_ENABLED=true
          - FABRIC_CA_SERVER_PORT=7054
        ports:
          - "7054:7054"
        # The user:pass for bootstrap admin which is required to build default config file
        command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
        volumes:
          - ./orgs/ca/org1:/etc/hyperledger/fabric-ca-server
        # Docker container names must be unique
        container_name: ca_org1
        networks:
          - test
    
      ca_org2:
        image: hyperledger/fabric-ca:$IMAGE_TAG
        environment:
          - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
          - FABRIC_CA_SERVER_CA_NAME=ca-org2
          - FABRIC_CA_SERVER_TLS_ENABLED=true
          - FABRIC_CA_SERVER_PORT=8054
        ports:
          - "8054:8054"
        command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
        volumes:
          - ./orgs/ca/org2:/etc/hyperledger/fabric-ca-server
        container_name: ca_org2
        networks:
          - test
    
      ca_orderer:
        image: hyperledger/fabric-ca:$IMAGE_TAG
        environment:
          - FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
          - FABRIC_CA_SERVER_CA_NAME=ca-orderer
          - FABRIC_CA_SERVER_TLS_ENABLED=true
          - FABRIC_CA_SERVER_PORT=9054
        ports:
          - "9054:9054"
        command: sh -c 'fabric-ca-server start -b admin:adminpw -d'
        volumes:
          - ./orgs/ca/ordererOrg:/etc/hyperledger/fabric-ca-server
        container_name: ca_orderer
        networks:
          - test
    ```

    

  - `docker-compose-test-net.yaml`

    ```yaml
    # Copyright IBM Corp. All Rights Reserved.
    #
    # SPDX-License-Identifier: Apache-2.0
    #
    
    version: '2'
    
    volumes:
      orderer.tanglizi.one:
      peer0.org1.tanglizi.one:
      peer0.org2.tanglizi.one:
    
    networks:
      test:
    
    services:
    
      orderer.tanglizi.one:
        container_name: orderer.tanglizi.one
        image: hyperledger/fabric-orderer:$IMAGE_TAG
        environment:
          - FABRIC_LOGGING_SPEC=INFO
          - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
          - ORDERER_GENERAL_LISTENPORT=7050
          - ORDERER_GENERAL_GENESISMETHOD=file
          - ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block
          - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
          - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
          # enabled TLS
          - ORDERER_GENERAL_TLS_ENABLED=true
          - ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
          - ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
          - ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
          - ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1
          - ORDERER_KAFKA_VERBOSE=true
          - ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/var/hyperledger/orderer/tls/server.crt
          - ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/var/hyperledger/orderer/tls/server.key
          - ORDERER_GENERAL_CLUSTER_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
        working_dir: /opt/gopath/src/github.com/hyperledger/fabric
        command: orderer
        volumes:
            - ./system-genesis-block/genesis.block:/var/hyperledger/orderer/orderer.genesis.block
            - ./orgs/ordererOrgs/tanglizi.one/orderers/orderer.tanglizi.one/msp:/var/hyperledger/orderer/msp
            - ./orgs/ordererOrgs/tanglizi.one/orderers/orderer.tanglizi.one/tls/:/var/hyperledger/orderer/tls
            - orderer.tanglizi.one:/var/hyperledger/production/orderer
        ports:
          - 7050:7050
        networks:
          - test
    
      peer0.org1.tanglizi.one:
        container_name: peer0.org1.tanglizi.one
        image: hyperledger/fabric-peer:$IMAGE_TAG
        environment:
          #Generic peer variables
          - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
          # the following setting starts chaincode containers on the same
          # bridge network as the peers
          # https://docs.docker.com/compose/networking/
          - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_test
          - FABRIC_LOGGING_SPEC=INFO
          #- FABRIC_LOGGING_SPEC=DEBUG
          - CORE_PEER_TLS_ENABLED=true
          - CORE_PEER_PROFILE_ENABLED=true
          - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
          - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
          - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
          # Peer specific variabes
          - CORE_PEER_ID=peer0.org1.tanglizi.one
          - CORE_PEER_ADDRESS=peer0.org1.tanglizi.one:7051
          - CORE_PEER_LISTENADDRESS=0.0.0.0:7051
          - CORE_PEER_CHAINCODEADDRESS=peer0.org1.tanglizi.one:7052
          - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
          - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.tanglizi.one:7051
          - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.tanglizi.one:7051
          - CORE_PEER_LOCALMSPID=Org1MSP
        volumes:
            - /var/run/:/host/var/run/
            - ./orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/msp:/etc/hyperledger/fabric/msp
            - ./orgs/peerOrgs/org1.tanglizi.one/peers/peer0.org1.tanglizi.one/tls:/etc/hyperledger/fabric/tls
            - peer0.org1.tanglizi.one:/var/hyperledger/production
        working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
        command: peer node start
        ports:
          - 7051:7051
        networks:
          - test
    
      peer0.org2.tanglizi.one:
        container_name: peer0.org2.tanglizi.one
        image: hyperledger/fabric-peer:$IMAGE_TAG
        environment:
          #Generic peer variables
          - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
          # the following setting starts chaincode containers on the same
          # bridge network as the peers
          # https://docs.docker.com/compose/networking/
          - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${COMPOSE_PROJECT_NAME}_test
          - FABRIC_LOGGING_SPEC=INFO
          #- FABRIC_LOGGING_SPEC=DEBUG
          - CORE_PEER_TLS_ENABLED=true
          - CORE_PEER_PROFILE_ENABLED=true
          - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
          - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
          - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
          # Peer specific variabes
          - CORE_PEER_ID=peer0.org2.tanglizi.one
          - CORE_PEER_ADDRESS=peer0.org2.tanglizi.one:9051
          - CORE_PEER_LISTENADDRESS=0.0.0.0:9051
          - CORE_PEER_CHAINCODEADDRESS=peer0.org2.tanglizi.one:9052
          - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:9052
          - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.tanglizi.one:9051
          - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org2.tanglizi.one:9051
          - CORE_PEER_LOCALMSPID=Org2MSP
        volumes:
            - /var/run/:/host/var/run/
            - ./orgs/peerOrgs/org2.tanglizi.one/peers/peer0.org2.tanglizi.one/msp:/etc/hyperledger/fabric/msp
            - ./orgs/peerOrgs/org2.tanglizi.one/peers/peer0.org2.tanglizi.one/tls:/etc/hyperledger/fabric/tls
            - peer0.org2.tanglizi.one:/var/hyperledger/production
        working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
        command: peer node start
        ports:
          - 9051:9051
        networks:
          - test
    ```

- 文件排布：注意文件映射到容器的位置

  ```
  orgs
  ├── ca
  │   ├── ordererOrg
  │   │   ├── ca-cert.pem
  │   │   ├── fabric-ca-server-config.yaml
  │   │   ├── fabric-ca-server.db
  │   │   ├── IssuerPublicKey
  │   │   ├── IssuerRevocationPublicKey
  │   │   ├── msp
  │   │   │   ├── cacerts
  │   │   │   ├── keystore
  │   │   │   │   ├── 53938f6913ca4d7eb2fbd9cbe0412e00ebffc73c8e9fb3d2951adac673663a38_sk
  │   │   │   │   ├── ede32742e322b646fecc30955523e49aef23fa8a64ef355098af875225d545a2_sk
  │   │   │   │   ├── IssuerRevocationPrivateKey
  │   │   │   │   └── IssuerSecretKey
  │   │   │   ├── signcerts
  │   │   │   └── user
  │   │   └── tls-cert.pem
  │   ├── org1
  │   │   ├── ca-cert.pem
  │   │   ├── fabric-ca-server-config.yaml
  │   │   ├── fabric-ca-server.db
  │   │   ├── IssuerPublicKey
  │   │   ├── IssuerRevocationPublicKey
  │   │   ├── msp
  │   │   │   ├── cacerts
  │   │   │   ├── keystore
  │   │   │   │   ├── 138f91dc5ee6e88cc91c6978935c787f2ab716cf15755d46138b740c8c704bb6_sk
  │   │   │   │   ├── 3ff4379cc4bdf6b0cfa057a03d46777b247b84723bcc02e36dce685bfb92c7f2_sk
  │   │   │   │   ├── IssuerRevocationPrivateKey
  │   │   │   │   └── IssuerSecretKey
  │   │   │   ├── signcerts
  │   │   │   └── user
  │   │   └── tls-cert.pem
  │   └── org2
  │       ├── ca-cert.pem
  │       ├── fabric-ca-server-config.yaml
  │       ├── fabric-ca-server.db
  │       ├── IssuerPublicKey
  │       ├── IssuerRevocationPublicKey
  │       ├── msp
  │       │   ├── cacerts
  │       │   ├── keystore
  │       │   │   ├── 02ccf5efccf10c345275691de9ea1734c602364f7b39ed377e41e05d54d8a84e_sk
  │       │   │   ├── 97d55e84721ca18203dd55741f40f3890acfd00230bfa92afc15e5388b96a526_sk
  │       │   │   ├── IssuerRevocationPrivateKey
  │       │   │   └── IssuerSecretKey
  │       │   ├── signcerts
  │       │   └── user
  │       └── tls-cert.pem
  ├── ordererOrgs
  │   └── tanglizi.one
  │       ├── fabric-ca-client-config.yaml
  │       ├── msp
  │       │   ├── cacerts
  │       │   │   └── localhost-9054-ca-orderer.pem
  │       │   ├── config.yaml
  │       │   ├── IssuerPublicKey
  │       │   ├── IssuerRevocationPublicKey
  │       │   ├── keystore
  │       │   │   └── 813d47ccfdad63de2f05d95f12c0ceaf63162103c3405db876651310ee937914_sk
  │       │   ├── signcerts
  │       │   │   └── cert.pem
  │       │   ├── tlscacerts
  │       │   │   └── tlsca.tanlizi.one-cert.pem
  │       │   └── user
  │       ├── orderers
  │       │   └── orderer.tanglizi.one
  │       │       ├── ca
  │       │       ├── msp
  │       │       │   ├── cacerts
  │       │       │   │   └── localhost-9054-ca-orderer.pem
  │       │       │   ├── config.yaml
  │       │       │   ├── IssuerPublicKey
  │       │       │   ├── IssuerRevocationPublicKey
  │       │       │   ├── keystore
  │       │       │   │   └── aeee1732278ca40547ec31adb3de1d82c04e1ace5c16f41fba780748e7600205_sk
  │       │       │   ├── signcerts
  │       │       │   │   └── cert.pem
  │       │       │   ├── tlscacerts
  │       │       │   │   └── tlsca.tanglizi.one-cert.pem
  │       │       │   └── user
  │       │       ├── tls
  │       │       │   ├── cacerts
  │       │       │   ├── ca.crt
  │       │       │   ├── IssuerPublicKey
  │       │       │   ├── IssuerRevocationPublicKey
  │       │       │   ├── keystore
  │       │       │   │   └── 64959492e67c15258ef3ada90c1b38e2eaf0828eeed36d1640ede0ec6b050f44_sk
  │       │       │   ├── server.crt
  │       │       │   ├── server.key
  │       │       │   ├── signcerts
  │       │       │   │   └── cert.pem
  │       │       │   ├── tlscacerts
  │       │       │   │   └── tls-localhost-9054-ca-orderer.pem
  │       │       │   └── user
  │       │       └── tlsca
  │       └── users
  │           └── Admin@tanglizi.one
  │               └── msp
  │                   ├── cacerts
  │                   │   └── localhost-9054-ca-orderer.pem
  │                   ├── config.yaml
  │                   ├── IssuerPublicKey
  │                   ├── IssuerRevocationPublicKey
  │                   ├── keystore
  │                   │   └── 2e8e50d4ddfaec347abb75e6dfda17cdebcd5fd72a75f912ed3b84ef687bb409_sk
  │                   ├── signcerts
  │                   │   └── cert.pem
  │                   └── user
  └── peerOrgs
      ├── org1.tanglizi.one
      │   ├── ca
      │   │   └── ca.org1.tanglizi.one-cert.pem
      │   ├── fabric-ca-client-config.yaml
      │   ├── msp
      │   │   ├── cacerts
      │   │   │   └── localhost-7054-ca-org1.pem
      │   │   ├── config.yaml
      │   │   ├── IssuerPublicKey
      │   │   ├── IssuerRevocationPublicKey
      │   │   ├── keystore
      │   │   │   └── a9d8f0f13eb851acb4f0686166aaecc2afb4e5e89d07da42d0561f64feca6164_sk
      │   │   ├── signcerts
      │   │   │   └── cert.pem
      │   │   ├── tlscacerts
      │   │   │   └── ca.crt
      │   │   └── user
      │   ├── peers
      │   │   └── peer0.org1.tanglizi.one
      │   │       ├── msp
      │   │       │   ├── cacerts
      │   │       │   │   └── localhost-7054-ca-org1.pem
      │   │       │   ├── config.yaml
      │   │       │   ├── IssuerPublicKey
      │   │       │   ├── IssuerRevocationPublicKey
      │   │       │   ├── keystore
      │   │       │   │   └── 2ab261015cdca2fde1a7a509d724e410489b6e86758df90250069623e83d9b1b_sk
      │   │       │   ├── signcerts
      │   │       │   │   └── cert.pem
      │   │       │   └── user
      │   │       └── tls
      │   │           ├── cacerts
      │   │           ├── ca.crt
      │   │           ├── IssuerPublicKey
      │   │           ├── IssuerRevocationPublicKey
      │   │           ├── keystore
      │   │           │   └── 0f90a9a7194ba42a49c095f0da098e44b6d924dd66f5bde1bc5d6a65fbbfd1b3_sk
      │   │           ├── server.crt
      │   │           ├── server.key
      │   │           ├── signcerts
      │   │           │   └── cert.pem
      │   │           ├── tlscacerts
      │   │           │   └── tls-localhost-7054-ca-org1.pem
      │   │           └── user
      │   ├── tlsca
      │   │   └── tlsca.org1.tanglizi.one-cert.pem
      │   └── users
      │       ├── Admin@org1.tanglizi.one
      │       │   └── msp
      │       │       ├── cacerts
      │       │       │   └── localhost-7054-ca-org1.pem
      │       │       ├── config.yaml
      │       │       ├── IssuerPublicKey
      │       │       ├── IssuerRevocationPublicKey
      │       │       ├── keystore
      │       │       │   └── c6b86240dddeae2c07b7ffd8384bf9e2fd9d5124fb660ba650fbc6fada04accc_sk
      │       │       ├── signcerts
      │       │       │   └── cert.pem
      │       │       └── user
      │       └── User1@org1.tanglizi.one
      │           └── msp
      │               ├── cacerts
      │               │   └── localhost-7054-ca-org1.pem
      │               ├── config.yaml
      │               ├── IssuerPublicKey
      │               ├── IssuerRevocationPublicKey
      │               ├── keystore
      │               │   └── 51627f7c831018e3d180c7f30aa904d53741d65e09f0bda49528c2ceb6b285d0_sk
      │               ├── signcerts
      │               │   └── cert.pem
      │               └── user
      └── org2.tanglizi.one
          ├── ca
          │   └── ca.org2.tanglizi.one-cert.pem
          ├── fabric-ca-client-config.yaml
          ├── msp
          │   ├── cacerts
          │   │   └── localhost-8054-ca-org2.pem
          │   ├── config.yaml
          │   ├── IssuerPublicKey
          │   ├── IssuerRevocationPublicKey
          │   ├── keystore
          │   │   └── 6d3e0e21fad0873662e6c3dbd9b953ead551f62bd9461d1cfb4c1875eabc7b88_sk
          │   ├── signcerts
          │   │   └── cert.pem
          │   ├── tlscacerts
          │   │   └── ca.crt
          │   └── user
          ├── peers
          │   └── peer0.org2.tanglizi.one
          │       ├── msp
          │       │   ├── cacerts
          │       │   │   └── localhost-8054-ca-org2.pem
          │       │   ├── config.yaml
          │       │   ├── IssuerPublicKey
          │       │   ├── IssuerRevocationPublicKey
          │       │   ├── keystore
          │       │   │   └── 282f899aec7ab7907a1dc47bb94168d31c27cc41b11176fc558c4ae76d25b240_sk
          │       │   ├── signcerts
          │       │   │   └── cert.pem
          │       │   └── user
          │       └── tls
          │           ├── cacerts
          │           ├── ca.crt
          │           ├── IssuerPublicKey
          │           ├── IssuerRevocationPublicKey
          │           ├── keystore
          │           │   └── 0bdca5eca39128fb8ce879760fb35966e67c3a2640d1b07350bfa49af30884c7_sk
          │           ├── server.crt
          │           ├── server.key
          │           ├── signcerts
          │           │   └── cert.pem
          │           ├── tlscacerts
          │           │   └── tls-localhost-8054-ca-org2.pem
          │           └── user
          ├── tlsca
          │   └── tlsca.org2.tanglizi.one-cert.pem
          └── users
              ├── Admin@org2.tanglizi.one
              │   └── msp
              │       ├── cacerts
              │       │   └── localhost-8054-ca-org2.pem
              │       ├── config.yaml
              │       ├── IssuerPublicKey
              │       ├── IssuerRevocationPublicKey
              │       ├── keystore
              │       │   └── 2810ad3ae104b1496116bcae6a497a797bff6d0e1e99df47b44ff855ab9dfacc_sk
              │       ├── signcerts
              │       │   └── cert.pem
              │       └── user
              └── User1@org2.tanglizi.one
                  └── msp
                      ├── cacerts
                      │   └── localhost-8054-ca-org2.pem
                      ├── config.yaml
                      ├── IssuerPublicKey
                      ├── IssuerRevocationPublicKey
                      ├── keystore
                      │   └── f6e59fbddb649ca9c5785fa8cb52e27806e0ddeb3aa57250a761b9c46b871393_sk
                      ├── signcerts
                      │   └── cert.pem
                      └── user
  
  121 directories, 131 files
  ```

  
