
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
        * [创建并启动CA](#创建并启动ca)
        * [注册登录并生成各个组织](#注册登录并生成各个组织)
        * [生成创世区块](#生成创世区块)
        * [创建并运行节点](#创建并运行节点)
        * [总结](#总结)

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

1. 登录本组织CA的admin账户，**作用？**

   ```shell
   fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles ${PWD}/orgs/ca/org1/tls-cert.pem
   ```

2. 生成组织MSP配置，**如何编写？**

   ```shell
   echo 'NodeOUs:
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

   2. 登录`peer`节点并生成TLS证书，**`enrollment.profile`作用？**

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

    

  - 交易配置`configtx/configtx.yaml`

    ```yaml
    # Copyright IBM Corp. All Rights Reserved.
    #
    # SPDX-License-Identifier: Apache-2.0
    #
    
    ---
    ################################################################################
    #
    #   Section: Organizations
    #
    #   - This section defines the different organizational identities which will
    #   be referenced later in the configuration.
    #
    ################################################################################
    Organizations:
    
        # SampleOrg defines an MSP using the sampleconfig.  It should never be used
        # in production but may be used as a template for other definitions
        - &OrdererOrg
            # DefaultOrg defines the organization which is used in the sampleconfig
            # of the fabric.git development environment
            Name: OrdererOrg
    
            # ID to load the MSP definition as
            ID: OrdererMSP
    
            # MSPDir is the filesystem path which contains the MSP configuration
            MSPDir: ../orgs/ordererOrgs/tanglizi.one/msp
    
            # Policies defines the set of policies at this level of the config tree
            # For organization policies, their canonical path is usually
            #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
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
    
            OrdererEndpoints:
                - orderer.tanglizi.one:7050
    
        - &Org1
            # DefaultOrg defines the organization which is used in the sampleconfig
            # of the fabric.git development environment
            Name: Org1MSP
    
            # ID to load the MSP definition as
            ID: Org1MSP
    
            MSPDir: ../orgs/peerOrgs/org1.tanglizi.one/msp
    
            # Policies defines the set of policies at this level of the config tree
            # For organization policies, their canonical path is usually
            #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
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
    
            # leave this flag set to true.
            AnchorPeers:
                # AnchorPeers defines the location of peers which can be used
                # for cross org gossip communication.  Note, this value is only
                # encoded in the genesis block in the Application section context
                - Host: peer0.org1.tanglizi.one
                  Port: 7051
    
        - &Org2
            # DefaultOrg defines the organization which is used in the sampleconfig
            # of the fabric.git development environment
            Name: Org2MSP
    
            # ID to load the MSP definition as
            ID: Org2MSP
    
            MSPDir: ../orgs/peerOrgs/org2.tanglizi.one/msp
    
            # Policies defines the set of policies at this level of the config tree
            # For organization policies, their canonical path is usually
            #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
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
                # AnchorPeers defines the location of peers which can be used
                # for cross org gossip communication.  Note, this value is only
                # encoded in the genesis block in the Application section context
                - Host: peer0.org2.tanglizi.one
                  Port: 9051
    
    ################################################################################
    #
    #   SECTION: Capabilities
    #
    #   - This section defines the capabilities of fabric network. This is a new
    #   concept as of v1.1.0 and should not be utilized in mixed networks with
    #   v1.0.x peers and orderers.  Capabilities define features which must be
    #   present in a fabric binary for that binary to safely participate in the
    #   fabric network.  For instance, if a new MSP type is added, newer binaries
    #   might recognize and validate the signatures from this type, while older
    #   binaries without this support would be unable to validate those
    #   transactions.  This could lead to different versions of the fabric binaries
    #   having different world states.  Instead, defining a capability for a channel
    #   informs those binaries without this capability that they must cease
    #   processing transactions until they have been upgraded.  For v1.0.x if any
    #   capabilities are defined (including a map with all capabilities turned off)
    #   then the v1.0.x peer will deliberately crash.
    #
    ################################################################################
    Capabilities:
        # Channel capabilities apply to both the orderers and the peers and must be
        # supported by both.
        # Set the value of the capability to true to require it.
        Channel: &ChannelCapabilities
            # V2_0 capability ensures that orderers and peers behave according
            # to v2.0 channel capabilities. Orderers and peers from
            # prior releases would behave in an incompatible way, and are therefore
            # not able to participate in channels at v2.0 capability.
            # Prior to enabling V2.0 channel capabilities, ensure that all
            # orderers and peers on a channel are at v2.0.0 or later.
            V2_0: true
    
        # Orderer capabilities apply only to the orderers, and may be safely
        # used with prior release peers.
        # Set the value of the capability to true to require it.
        Orderer: &OrdererCapabilities
            # V2_0 orderer capability ensures that orderers behave according
            # to v2.0 orderer capabilities. Orderers from
            # prior releases would behave in an incompatible way, and are therefore
            # not able to participate in channels at v2.0 orderer capability.
            # Prior to enabling V2.0 orderer capabilities, ensure that all
            # orderers on channel are at v2.0.0 or later.
            V2_0: true
    
        # Application capabilities apply only to the peer network, and may be safely
        # used with prior release orderers.
        # Set the value of the capability to true to require it.
        Application: &ApplicationCapabilities
            # V2_0 application capability ensures that peers behave according
            # to v2.0 application capabilities. Peers from
            # prior releases would behave in an incompatible way, and are therefore
            # not able to participate in channels at v2.0 application capability.
            # Prior to enabling V2.0 application capabilities, ensure that all
            # peers on channel are at v2.0.0 or later.
            V2_0: true
    
    ################################################################################
    #
    #   SECTION: Application
    #
    #   - This section defines the values to encode into a config transaction or
    #   genesis block for application related parameters
    #
    ################################################################################
    Application: &ApplicationDefaults
    
        # Organizations is the list of orgs which are defined as participants on
        # the application side of the network
        Organizations:
    
        # Policies defines the set of policies at this level of the config tree
        # For Application policies, their canonical path is
        #   /Channel/Application/<PolicyName>
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
    ################################################################################
    #
    #   SECTION: Orderer
    #
    #   - This section defines the values to encode into a config transaction or
    #   genesis block for orderer related parameters
    #
    ################################################################################
    Orderer: &OrdererDefaults
    
        # Orderer Type: The orderer implementation to start
        OrdererType: etcdraft
        
        # Addresses used to be the list of orderer addresses that clients and peers
        # could connect to.  However, this does not allow clients to associate orderer
        # addresses and orderer organizations which can be useful for things such
        # as TLS validation.  The preferred way to specify orderer addresses is now
        # to include the OrdererEndpoints item in your org definition
        Addresses:
            - orderer.tanglizi.one:7050
    
        EtcdRaft:
            Consenters:
            - Host: orderer.tanglizi.one
              Port: 7050
              ClientTLSCert: ../orgs/ordererOrgs/tanglizi.one/orderers/orderer.tanglizi.one/tls/server.crt
              ServerTLSCert: ../orgs/ordererOrgs/tanglizi.one/orderers/orderer.tanglizi.one/tls/server.crt
    
        # Batch Timeout: The amount of time to wait before creating a batch
        BatchTimeout: 2s
    
        # Batch Size: Controls the number of messages batched into a block
        BatchSize:
    
            # Max Message Count: The maximum number of messages to permit in a batch
            MaxMessageCount: 10
    
            # Absolute Max Bytes: The absolute maximum number of bytes allowed for
            # the serialized messages in a batch.
            AbsoluteMaxBytes: 99 MB
    
            # Preferred Max Bytes: The preferred maximum number of bytes allowed for
            # the serialized messages in a batch. A message larger than the preferred
            # max bytes will result in a batch larger than preferred max bytes.
            PreferredMaxBytes: 512 KB
    
        # Organizations is the list of orgs which are defined as participants on
        # the orderer side of the network
        Organizations:
    
        # Policies defines the set of policies at this level of the config tree
        # For Orderer policies, their canonical path is
        #   /Channel/Orderer/<PolicyName>
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
            # BlockValidation specifies what signatures must be included in the block
            # from the orderer for the peer to validate it.
            BlockValidation:
                Type: ImplicitMeta
                Rule: "ANY Writers"
    
    ################################################################################
    #
    #   CHANNEL
    #
    #   This section defines the values to encode into a config transaction or
    #   genesis block for channel related parameters.
    #
    ################################################################################
    Channel: &ChannelDefaults
        # Policies defines the set of policies at this level of the config tree
        # For Channel policies, their canonical path is
        #   /Channel/<PolicyName>
        Policies:
            # Who may invoke the 'Deliver' API
            Readers:
                Type: ImplicitMeta
                Rule: "ANY Readers"
            # Who may invoke the 'Broadcast' API
            Writers:
                Type: ImplicitMeta
                Rule: "ANY Writers"
            # By default, who may modify elements at this config level
            Admins:
                Type: ImplicitMeta
                Rule: "MAJORITY Admins"
    
        # Capabilities describes the channel level capabilities, see the
        # dedicated Capabilities section elsewhere in this file for a full
        # description
        Capabilities:
            <<: *ChannelCapabilities
    
    ################################################################################
    #
    #   Profile
    #
    #   - Different configuration profiles may be encoded here to be specified
    #   as parameters to the configtxgen tool
    #
    ################################################################################
    Profiles:
    
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

  
