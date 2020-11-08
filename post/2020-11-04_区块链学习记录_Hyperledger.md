
<!-- vim-markdown-toc GitLab -->

* [区块链技术实践 - Hyperledger Fabric 2](#区块链技术实践-hyperledger-fabric-2)
    * [简介](#简介)
    * [Fabric 架构](#fabric-架构)
    * [Fabric 核心组件](#fabric-核心组件)
        * [Network](#network)
        * [节点](#节点)
        * [共识](#共识)
        * [Ledger - 账本](#ledger-账本)
        * [Chaincode - 链码](#chaincode-链码)
    * [Fabric 交易流程](#fabric-交易流程)
    * [关键概念详解](#关键概念详解)
        * [身份与PKI](#身份与pki)
    * [成员服务提供者](#成员服务提供者)
        * [本地MSP](#本地msp)
        * [通道MSP](#通道msp)
        * [组织](#组织)
        * [组织单位 - Organizational Units](#组织单位-organizational-units)
    * [部署生产网络](#部署生产网络)
        * [创建CA](#创建ca)
        * [使用CA创建身份和MSP](#使用ca创建身份和msp)
        * [部署Peer节点和Ordering节点](#部署peer节点和ordering节点)
    * [部署生产网络 - 实例](#部署生产网络-实例)

<!-- vim-markdown-toc -->

# 区块链技术实践 - Hyperledger Fabric 2

> https://hyperledger-fabric.readthedocs.io/zh_CN/latest/



## 简介

Hyperledger Fabric 是 Hyperledger 中的区块链项目之一。与其他区块链技术一样，它有一个账本，使用智能合约，是一个参与者管理交易的系统。

在功能上，其不同点有：

1. 提供多种可插拔选项

   有多种账本**数据格式存储**（LevelDB、CouchDB），**共识机制**可以交换替换（SOLO开发用、Kafka、Raft），并且支持**不同的MSP**。

2. **授权**提供安全性

   与公链不同，网络的成员需要从可信赖的 **成员服务提供者（MSP）** 注册。

3. 创建**通道**保护隐私

   允许一组参与者创建各自的交易账本，只有同一个通道的参与者才能查看数据，它提供了一种竞争者间保护隐私的方法。



## Fabric 架构

> https://learnblockchain.cn/books/enterprise/chapter3_03%20hyperledger_fabric_architecture.html

Fabric分为四大模块，分别是成员服务、区块链服务、智能合约和应用编程接口。



**成员服务**

- 成员服务（MSP）主要提供证书发布、验证及相关加密机制和协议。内置了Fabric CA证书颁发机构。
- Fabric CA提供客户端和SDK两种方式与CA进行交互，每个Fabric CA都有一个根CA或者中间CA。
- 为了便于证书管理，一般使用根证书、业务证书、用户证书三级证书结构。他们的关系是上级签发下级，呈树状。
- 业务证书又包含三种互相平行的证书：身份认证证书、交易签名证书、安全通讯证书。



**区块链服务**

1. **P2P协议**
   - Fabric网络中，节点Peer和排序服务Orderer采用gRPC对外提供远程服务，供客户端进行调用。
   - 节点之间通过 Gossip 协议来进行状态同步和分发。

2. **共识机制**
   - 交易必须按照发生的顺序写入**到分布式账本中。为此必须采用一种共识机制拒绝错误（或恶意）的交易数据，保证交易的顺序。
   - Fabric允许根据实际业务需要选择合适的共识机制，目前支持SOLO、Kafka、Raft三种共识机制。

3. **分布式账本**
   - 分布式账本包括两个组件：世界状态、事务日志，分布式账本是世界状态数据库和事务日志历史记录的组合。
   - **世界状态**（world state）组件记录的是最新的分布式账本状态，**事务日志**组件记录的是世界状态的更新历史。



**智能合约服务** 

- 智能合约服务用于保证智能合约在网络节点上安全运行。

- 是一组运行在验证节点上的去中心化交易程序。
- 在Fabric中被称为链码（chaincode），由外部应用程序（比如网页、APP）与分布式账本进行交互。
- 使用Docker存放链上的代码（而不需要依靠特定的虚拟机），Docker为链码执行提供了一个安全、轻便的语言执行环境。



**应用编程接口** 

- 应用编程接口提供SDK（开发工具包）和CLI（命令行）两种方式供开发人员使用区块链的各种服务。
- 主要是对分布式账本进行查询、更新。



## Fabric 核心组件

> https://learnblockchain.cn/books/enterprise/chapter3_04%20hyperledger_fabric_core_components.html



### Network

> 在Fabric网络中，Peer和Orderer采用gRPC对外提供远程服务，供客户端进行调用。
>
> 节点之间通过Gossip 协议来进行状态同步和分发。 

Gossip 协议是P2P 领域的常见协议，用于进行网络内多个节点之间的数据分发或信息交换。由于其设计简单，容易实现，同时容错性比较高，而被广泛应用到了许多分布式系。

Gossip  协议的基本思想十分简单，数据发送方从网络中随机选取若干节点，将数据发送过去，接收方重复这一过程（往往只选择发送方之外节点进行传播）。这一过程持续下去，网络中所有节点最终（时间复杂度为节点总个数的对数）都会达到一致。数据传输的方向可以是发送方发送或获取方拉取。



### 节点

> [PKI/CA工作原理及架构](https://www.jianshu.com/p/c65fa3af1c01)

**服务节点类型**

​	对网络中节点角色进行解耦是Fabric 设计中的一大创新，这也是联盟链场景下的特殊需求和环境所决定。

- **背书节点**（ Endorser ）

  负责对交易的<u>提案</u>（ proposal ）进行验证并模拟交易执行；

- **提交节点**（ Committer ）

  负责在接受交易结果前再次检查合法性，接受合法交易对账本的修改，并写入区块链结构；

- **排序节点**（ Orderer ）

  对所有发往网络中的交易进行排序，将排序后的交易按照配置中的约定整理为区块，之后提交给确认节点进行处理；

- **证书节点**（ CA ）

  负责对网络中所有的证书进行管理，提供标准的**PKI服务**。



注意：

1. 除了用户节点，网络所有的全节点都具备Commiter功能，部分节点具有Endorser、Orderer功能。
2. **锚节点**是一种外部可发现的节点，配置了对外服务的端口。可以被Orderer节点和其它任何节点发现。
3. 证书节点是一个相对独立证书管理机构，也可以由第三方证书机构来承担这个角色。



### 共识

广义的共识机制包含背书、排序和验证三个环节，狭义的共识指的是排序。



**背书**

- 就是相关组织对交易的认可，在Fabric中是相关节点对交易进行签名。
- 交易验证由网络中业务相关方进行。
- 对于一个链码交易来说，背书策略是在链码实例化的时候指定的；一笔有效交易必须是背书策略相关组织签名后才能生效。



**排序服务**

- 通常由排序节点来提供，用来对全网交易达成一致顺序。
- 排序服务只负责对交易顺序达成一致，这就有效避免了整个网络瓶颈，而且排序节点也很容易横向扩展，以提高整个网络的效率。
- 排序服务目前支持Kafka（v2弃用）和Raft（非拜占庭的共识机制）两种，可插拔架构也允许根据业务需要设计符合拜占庭的共识机制（如实用拜占庭）。



**验证**

- 是对排序后的交易提交到账本之前最终的检查。
- 检查的内容包含交易**结构的合法性**、**交易背书签名**是否符合背书策略等



### Ledger - 账本

区块是一组排序后的交易集合，将区块通过密码算法连接起来就是区块链。

在Fabric中交易可以存储相关业务信息。

账本包含状态数据库和历史数据库：

1. 状态数据库记录的是变更记录的最新结果，方便查询，使用CouchDB；
2. 历史数据库记录的是区块链结构，使用LevelDB。



### Chaincode - 链码

智能合约在Fabric中也被称为链码（chaincode）。



**用户链码和系统链码**

​	目前超级账本Fabric 项目中提供了用户链码和系统链码。

1. **用户链码**

   - 运行在单独的容器中，提供对上层应用的支持。
   - 一般所谈的链码为用户链码，用户通过链码相关的API 编写用户链码，即可对账本中状态进行更新操作。

2. **系统链码**则嵌入在系统内，提供对系统进行配置、管理的支持。

   - 系统链码有以下五个合约：

     - Configuration System Chaincode (CSCC)

       管理peer上通道相关的信息以及执行通道配置交易。

     - Life Cycle System Chaincode (LSCC) 

       用于管理链码的生命周期——在peer上安装链码、在通道上实例化和升级链码、用户从运行中的链码获取信息。

     - Query System Chaincode (QSCC) 

       运行在所有Peer上，提供账区块查询、交易查询等API。

     - Endorser System Chaincode (ESCC) 

       由背书节点调用，对一个交易响应进行密码签名。

     - Validator System Chaincode (VSCC) 

       由<u>记账节点</u>调用，包括检查背书策略和读写集版本。



**链码**

- 经过安装和实例化操作后，即可被调用。
  - 安装时，需要指定具体安装到哪个Peer 节点；
  - 实例化时，需要指定通道内及背书策略。
- Fabric 目前主要支持基于Go 语言、Java、Node.js。



## Fabric 交易流程

> https://learnblockchain.cn/books/enterprise/chapter3_05%20hyperledger_fabric_workflow_of_transaction.html

一个完整的交易要涉及应用程序、证书服务、背书节点、提交节点和排序节点。

- 应用程序（App）：调用Fabric SDK与区块链网络进行交互，这里的应用程序可以是网页，也可以是APP；



客户端使用SDK与Fabric网络进行交互：

1. 客户端先通过证书服务**获取合法的身份**并**加入到应用通道**（Channel）中。
2. 客户端构造**交易请求**（Proposal）提交给背书节点（Endorser）。
3. 背书节点对交易进行**验证和模拟**执行后（并不真正更新账本），反馈给客户端。
4. 客户端收到**足够的背书支持**后将交易发送给Orderer节点。
5. Orderer节点对网络中的交易进行**全局排序**，并将排序后的**交易打包成区块**，然后**广播**给网络中的提交节点。
6. 提交节点负责**维护区块链和账本结构**，对**交易进行最终检查**（交易结构的合法性、交易背书签名是否符合背书策略等），检查通过后写入账本。



## 关键概念详解



### 身份与PKI

CA是用于生成权威可认证的身份，但不提供任何网络中的权限提供。



**数字证书**

 - 数字证书的申请、发布和使用

   ![数字证书的申请、发布和使用](https://upload-images.jianshu.io/upload_images/2960526-3bbf619ee9ab9547.png?imageMogr2/auto-orient/strip|imageView2/2/w/488)

 - 数字证书的生成与验证

   ![数字证书的生成与验证](https://upload-images.jianshu.io/upload_images/2960526-96b80db0b2fbfac2.png?imageMogr2/auto-orient/strip|imageView2/2/w/715)

 - 举例：

   ```yaml
   Certificate:
       Data:
           Version: 3 (0x2)
           Serial Number: 368716 (0x5a04c)
           Signature Algorithm: sha1WithRSAEncryption
           Issuer:C=US,O=Equifax,
               OU=Equifax Secure Certificate Authority
           Validity
               Not Before: Jan 4 17:09:06 2006 GMT
               Not After : Jan 4 17:09:06 2011 GMT
           Subject: C=US, ST=California, L=Santa Clara,
               O=Yahoo! Inc., OU=Yahoo, CN=login.yahoo
           Subject Public Key Info:
           Public Key Algorithm: rsaEncryption
           RSA Public Key: (1024 bit)
           Modulus (1024 bit):
   			00:b5:6c:4f:ee:ef:1b:04:5d:be:70:4a:d8:55:1d:
   			8a:77:0d:c1:45:00:f5:3b:1a:10:dd:d7:f7:bb:7a:
   			65:54:7f:60:d2:16:bb:bd:12:a5:78:78:d6:b3:50:
   			4e:ba:17:48:27:7a:22:6f:2a:7c:1d:a2:36:22:d8:
   			59:a2:ae:3a:0b:d4:d2:1b:8a:0e:5a:89:a9:e4:9a:
   			ff:db:3f:04:e2:9b:75:c1:8d:c5:8c:05:a1:f3:b5:
   			92:5e:a1:44:49:19:e4:90:b4:e9:ef:e4:5d:b2:20:
   			6d:f9:23:76:b8:b2:d4:af:a3:06:f5:9e:03:8f:b8:
   			82:05:21:11:25:44:3a:80:05
           Exponent: 65537 (0x10001)
           X509v3 extensions:
           X509v3 Key Usage: critical
           Digital Signature, Non Repudiation,
               Key Encipherment,Data Encipherment
           X509v3 Subject Key Identifier:
               A0:1E:6E:0C:9B:6E:6A:EB:D2:AE:5A:4A:18:FF:0E:93:
               46:1A:D6:32
           X509v3 CRL Distribution Points:
           URI:http://crl.geotrust/crls/secureca.crl
           X509v3 Authority Key Identifier:
           keyid:48:E6:68:F9:2B:D2:B2:95:D7:47:D8:23:20:10:
               4F:33:98:90:9F:D4
           X509v3 Extended Key Usage:
           TLS Web Server Authentication,
           TLS Web Client Authentication
           Signature Algorithm: sha1WithRSAEncryption
   			50:25:65:10:43:e1:74:83:2f:8f:9c:9e:dc:74:64:4e:71:27:
   			4e:2a:6e:4a:12:7b:4c:41:2e:61:4a:11:0b:41:a6:b1:52:cb:
   			13:76:b6:45:e4:8d:d4:00:9a:3b:02:c7:82:29:01:a3:ee:7d:
   			f7:b9:02:88:9d:3e:c3:1c:e6:3d:d3:90:fc:9c:56:db:19:9d:
   			ab:a8:03:80:7d:c4:e2:c4:09:33:9e:58:5b:77:37:89:59:a3:
   			86:8e:a1:df:b3:bb:02:ed:21:62:fb:ba:c2:ba:e8:d4:8f:66:
   			c1:a5:5f:ad:f9:3f:cf:22:9b:17:57:a0:ca:28:c6:76:03:a4:
   			c4:e7
   ```

   

   

**公钥和私钥**
- 略



**证书授权中心**

- 人员或节点能够通过由系统信任的机构为其发布的**数字身份**参与区块链网络。

- **根CA中间CA和信任链**：只要每个中间 CA 的证书的颁发 CA 是根 CA 本身或具有对根 CA 的信任链，就在根 CA 和一组中间 CA 之间建立信任链。



**证书撤销列表**
- 是 CA 知道由于某些原因而被撤销的证书的引用列表。
- 当第三方想要验证另一方的身份时，它首先检查颁发 CA 的 CRL 以确保证书尚未被撤销。验证者不是必须要检查 CRL，但如果不检查，则他们冒着接受无效身份的风险。



## 成员服务提供者

MSP的目的是将一个CA认证的身份，转换为一个具体的带有权限的角色。

注意CA的目的，只是发放了可认证的数字签名，而不提供任何关于权限的信息。



在区块链网络中，MSP 出现在两个位置，他们的区别在于**作用域**：

- 在参与者节点本地（**本地 MSP**）
- 在通道配置中（**通道 MSP**）



### 本地MSP

- 本地MSP是为了给客户端和节点，提供管理权限和参与权限的服务。
- 每一个节点都需要一个本地MSP，用于验证发来信息的人的权限。
- 注意一个组织内会有多个节点。



### 通道MSP

- 通道MSP在通道层面上，提供管理权限和参与权限的服务。

  - 应用程序层面上的节点共享通道MSP的相同视图，因此将能够正确地验证通道参与者。

  - 如果组织希望加入渠道，则需要在渠道配置中包含一个包含组织成员信任链的MSP。
  - 本地MSP在文件系统上表示为文件夹结构，而通道MSP在通道配置中描述。

- 每一个参与通道的组织，都需要一个通道MSP，建议组织与MSP之间存在一对一的映射。

- 系统通道MSP包括了参与排序服务的所有组织的MSP

- 本地MSP是存储于节点或用户的文件系统中；<br>通道MSP则是通过共识机制进行同步，一致性的存储于每个节点的文件系统中。



### 组织

- 组织拥有单一的MSP，在此基础上管理他们的成员。

- MSP允许绑定身份到组织。

- 组织与其MSP之间的一对一关系，使得以组织名称命名MSP更为合理。在大多数策略配置中，将采用这种约定。



### 组织单位 - Organizational Units

- 一个组织也可以被划分为多个组织单位，每个单位都有一套特定的职责，也称为附属机构。可以把OU想象成组织内部的一个部门。

- 当CA颁发X.509证书时，证书中的OU字段指定了该标识所属的业务部门。

- 这样使用OUs的一个好处是，可以在策略定义中使用这些值来限制访问，或者在智能合约中使用它们来进行基于属性的访问控制。



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
   - 由CA生成管理员的用户名和密码。
   - 然后CA将为此身份生成一组MSP文件夹，其中包含公共证书以及该CA的公钥等。

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



## 部署生产网络 - 实例

