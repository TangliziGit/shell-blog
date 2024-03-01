# LSM-tree basics

## History

LSM Tree应该被理解为一种out-of-place更新的索引，旨在牺牲读取速度而提升写入吞吐量。

LSM Tree历史简介：76年提出differential file、80年代postgresql提出顺序日志做快速恢复、96年提出LSM-tree（The log-structured merge-tree）。

## Basic Structure

关于写放大、读放大、空间放大的解释和对应compaction策略，可以看这篇OB的总览：
- https://www.oceanbase.com/docs/community-developer-advance-0000000000634014
  https://www.oceanbase.com/docs/-developer-advance-0000000000634015  
- 各种放大的原因
	- 写放大：由于多次compaction导致数据读出写入，原本一行数据被读写多次
	- 空间放大：blind write导致过期数据没有被立即删除或覆盖
		- RocksDB的一个解释：https://github.com/facebook/rocksdb/blob/master/include/rocksdb/universal_compaction.h#L36-L40
	- 读放大：查询非去重键的列后，不保证读出的数据包含最新的行，所以需要读所有levelfile去重。
	- 读放大和空间放大是同步的，写放大和另外两个放大是对立的。
- Compaction策略
	- leveling：一层一个SST，层数越大SST按倍数增大(fanout)，合并是上层合并到下层SST上
		- 写放大最多到fanout，这个怎么理解？应该是一次compaction可能会涉及到所有文件
		- 写放大表现比较差，每次合并都要合并两个很大的文件
	- tiering：一层多个SST且之间可能有交集，合并是上层合并给下层新建SST
		- 每次compaction只用合并上层多个小文件，写入下层更小的文件，写放大更优秀。
		- 但读放大更差，因为去重键相同的过期数据的行会分散在各个文件里，相比leveling只读level个文件，tiering要读很多SST。与读放大类似，空间放大也因为过多过期数据的存在而表现更差。
	- l-leveling / 1-leveling：上层tiering，下层leveling
		- 上层的新数据被更新的可能更大，为了更好的compaction写放大，上层用tiering
		- 下层数据比较旧不容易更新，为了减少读和空间放大，下层leveling
- Compaction类型：这里OB说是三个，其实第一个就是flush。
	- OB的层数只有3层，1-leveling策略
	- minor compaction：
		- 多个L0的SST，合并成一个L0的SST
		- 多个L0和一个L1的SST，合并一个L1的SST
	- major compcation：
		- 所有层合并到一个L2的SST。
- Compaction方法：都是工程上的优化
	- 增量合并：这里是指SST内部的block做合并，听起来是如果没有重叠那么就拷贝block跳过。能节省一些解析之类的开销。
	- 轮转合并：分布式的多个副本上，当一个副本在compaction，就把流量切到其他副本上。
	- 并行合并

## Well-Known Optimizations

**bloom filter**

提高大基数的点查性能。在实践中，大多数系统通常使用10 bits/key 作为默认配置，这个配置有1%的误报率（假阳性风险）。由于Bloom过滤器非常小，通常可以缓存到内存中。

**partitioning**

![partitioned-leveling-and-tiering](/static/image/2024-03-01/partitioned-leveling-and-tiering.png)

给同层中的SST上做分区，每个SST负责不同的range。
- 好处：降低compaction的粒度，减少时间空间代价； 对于按顺序创建的键，基本上不执行合并，因为没有键范围重叠的组件。对于倾斜更新，冷更新范围的组件的合并频率可以大大降低。
- **partitioned leveling**：LevelDB的做法，内存L0存所有范围，下层每个SST负责一个范围。compaction是选择跟上层SST重叠的一些下层SST合并，结果是删除上层的SST，生成多个范围的下层SST。
- **垂直分区Tiering**：有重叠键范围的SSTable被分组在一起。每次合并就在组内合并，然后输出到下层对应组内。每次写入应该是按范围写入对应的range里作为SST。需要注意这种方法没法保证一个SST的文件大小，因为内存层的大小是固定的，那么每次flush到某个key range里的文件就不确定有多大。
- **水平分区Tiering**：每层有多个分区，每个分区间存在重叠，分区内文件不会重叠。

## Concurrency Control and Recovery

**并发控制**
- 这里产生并发的地方是文件的元数据，即LSM里哪些文件是有效的可见的、哪些修改操作是需要同步的。
- **读写并发**：采用locking或者多版本。多版本具体是对元数据做多版本，并在文件上做引用计数回收。
- **flush和compaction并发**：二者都会修改元数据，会产生写写冲突，二者只能同步执行。

**恢复**
- 采用WAL，并且是no-steal的。所以WAL中不需要undo任何事务。
- 对于磁盘文件的恢复，需要考虑是否分区的问题。要点就是不要把数据漏掉，重复的数据对读写都没有正确性影响，会在compact时去重。如果没有分区，那么可以用某种单调的数字决定去留；如果有分区，leveldb和rocksdb都是用单独的元数据维护的。

## Cost Analysis

这里对读写空间放大做了比较详细的汇总。
![cost-analysis](/static/image/2024-03-01/cost-analysis.png)

其他参考：
- Monkey的论文，介绍了一种设定bloomfilter误判率的方法，来降低总体点差开销。
- Dostoevsky的论文，对lazy leveling的各种复杂度做详细分析。
- The Log-Structured Merge-Tree（LSM-Tree），本篇提到了层数对leveling的影响，以及层间大小比例固定为何减少写放大的讨论。
- LSM math - how many levels minimizes write amplification?，一个层数和比例对leveling和tiering影响的简单分析。

# LSM-tree Improvements

![taxonomy-of-lsm-improvements](/static/image/2024-03-01/taxonomy-of-lsm-improvements.png)

下面每一个话题里都列举了相关的研究，但是实际产品列举的很少，有点过于研究性质。

## Reducing Write Amplification

减少写放大通常是用Tiering方法，其他改进如merge skipping、利用data skews。

**Tiering**：相比leveling一次合两层SST，Tiering是一次合一层内的多个SST，分散了写入压力。下面的研究都在分区上做某些变体：
- WriteBuffer Tree，是垂直partitioned tiering变体。用到hash-partition让每个组包含相同数量数据，用到类似B+tree的结构组织SSTable来自平衡降低总层数。
- light-weight compaction tree，也是垂直分区tiering变体。当一个组里存在太多文件后，会缩小当前组的key range，在merge后扩大兄弟组的key range。
- PebblesDB，也是垂直分区tiering变体。在每个层上提出了类似skiplist的guard，用来动态控制group的大小，能在下次compact时调整。效果是在Tiering上进一步降低写放大。这个实现成本听起来并不高。
- dCompaction，提出vitrual SST，当compaction时不实际执行而是产出一个指向多个SST的SST。相当与延迟compact，减少了IO和合并的CPU。但是对读并不友好，实际就是没做compact。于是提出一个阈值做控制，感觉又回到了原来的compact，听起来并不算好。

**Merge Skipping**：直接跳过中间层，再更下层上做合并。不知道效果如何，但是实现非常复杂。

**Exploiting Data Skew**：TRIAD的做法，内存里分离热键冷键。热键只存在内存里做更新和查询，恢复可以用WAL定期复制回收。冷键像之前那样flush。

## Optimizing merge operations

对compaction的优化，涉及性能、缓存丢失、消除写暂停。

**提高合并性能**
- stitching：VT-tree引入了一种stitching操作，如果要合并的文件间没有重叠，那么合并结果里可以直接指向原文件。类似软链接的做法其实有缺陷，例如文件之间不是连续的，指针有点类似BTree的做法。VT-tree用一个阈值做stitching的取舍。另外，stitching过程不需要扫描，所以新文件的bloomfilter无法生成。这里用到quotient filter，可以直接取交集而不用扫描。
- **流水线合并**：compaction有三个阶段组成——读、排序、写。可以发现三个过程用到两个不同的组件，即disk和CPU。为了利用组件间的并发度，可以做流水线化，例如：读第一页后，异步读第二页，此时做第一页的排序，当排序完成并且文件读结束后再做其他工作。感觉可以把三个步骤都做成异步，是不是自动流水线化了？这个感觉是可行的。
![pipelined-compaction](/static/image/2024-03-01/pipelined-compaction.png)

**reducing buffer cache miss**
- Ahmad的实验性研究：他们发现合并操作会消耗大量CPU和I/O资源，并对查询响应时间造成很高的开销。提出了解决方法，把compaction放在远端执行，在合并结束后再用“smart cache warmup algorithm”来平稳地、一块块获取文件，意在最大减少cache miss。（不知道写频繁的场景，怎么控制每层大小或者文件等，compaction的耗时一定非常长）
- **LSbM-tree**：这个解释有点不太清楚，可以看看原文。在磁盘上引入一种每层都有的compaction buffer，当compactoin发生时，把上层文件rename(应该是)到下层的compaction buffer里，并做定期的trimming。这个compaction buffer的意义，似乎是更有可能在cache里？相当与延迟了原文件的删除，于是就减少了cache miss？但要注意只对skew的负载有效，对cache更关心的场景下。

**最小化写暂停（write stalls）**
- bLSM：由于后台的flush和compact，会导致不可预知的写暂停和写延迟（这个怎么理解，造成什么问题？）。看起来是每层容忍额外的文件，所以可以不同层并行做compact（怎么理解？）。所以控制了内存里的写入速度，消除了大的write stall。但是这个做法忽略了队列的等待时间，这个是更大的性能问题。

## Hardware Opportunities

针对不同硬件平台提出的LSM树改进，包括大内存、多核、SSD/NVM和原生存储（类似裸磁盘上LSM）。这里只记录SSD话题上的一些论文。

**SSD / NVM**
- 二者能提供更高效的随机IO，所以LSM上引入更多的随机IO会更有效。
- FD tree和FD+ tree在每层文件里引入了指针，指向下一层的对应位置，这样可以加速查询。但是对compaction要求更复杂。
- MaSM似乎是lazy leveling的一种简化模型，采用tiering来处理某些中间文件，减少写放大。
- WiscKey提出键值分离的思路，即文件里不存储value，而是存储一个指针指向WAL或者集中存储之类的地方。这样能让更新之修改value而不是LSM tree，而且少了一次value写入LSM tree文件的开销，能大大降低写开销。但是范围查询支持更差，因为value是没排序的。另外GC也有一些复杂，而且被证明是新的瓶颈，会做随机点查询。HashKV和SifrDB在不同地方做了优化。

## Handling special workloads

这里讨论了针对特殊负载场景的一些更好的方法，包括时序数据、小数据、半排序数据和追加为主。

SlimDB处理了半排序的数据，能支持点查、前缀后缀查询。另外用到类似Lazy leveling的结构，采用了CuckooFilter能在一个层上直接命中到某个SSTable（神奇）。

## Auto-tuning

仅记录调参和合并策略，其他还有ElasticBF和优化云上数据存放的内容。

**参数调整**
- Lim et al.提出了一个分析模型，分析了p次写入请求下造成唯一键个数的数量，然后通过这个模型来做总写成本的最小化，寻找最优的系统参数。
- Monkey这篇已经提了多次了，通过调整每层FPR，让整体点查的开销减少一个L的乘数。直觉是，最后一层的T个组件(包含大部分数据)消耗了大部分Bloom过滤器内存，但它们的Bloom过滤器只能为点查找节省最多T个磁盘I/O。

**合并策略**
- Dostoevsky这篇也是提到很多次，引入了lazy leveling，能做到tiering类似的写效率但是有leveling类似的空间放大和点查等开销。
- Thonangi和Yang研究了分区对LSM的写代价影响。对分区有关系的话可以看原文。

## Secondary Indexing

这部分太过研究性质了，偏实际系统方面的看这篇更好：A Comparative Study of Secondary Indexing Techniques in LSM-based NoSQL Databases。不过索引结构和统计信息收集可以看看。

**索引结构**
- log-structured inverted index，听起来是一种反向索引
- Kim et al.，基于LSM的地理标记数据的空间索引结构
- LSM-based storage and indexing: An old idea with timely benefits.
- A Comparative Study of Secondary Indexing Techniques in LSM-based NoSQL Databases

**索引维护**
- 在更新数据期间，必须执行额外的工作来清除二级索引中过时的条目。
- DiffIndex提出了基于LSM的二级索引的四种索引维护方案
- DELI增强了DiffIndex的同步插入的更新方案，通过扫描主索引来清除二级索引。在扫描主键索引时能获得重复数据，以此来更新二级索引。这样二级索引的结果不保证都是最新数据，所以还是要按主键点查去找结果。
- Efficient data ingestion and query processing for LSM-based storage systems，这篇提出了几种有效开发和维护基于LSM的辅助结构的技术，包括二级索引和过滤器。内容比较多，但是相比DELI，验证降低了清理二级索引的IO成本，引入了mutable bitmap作为主键索引的filter。这个mutable  bitmap是一种在SST上附加的delete bitmap。很熟悉的感觉。
- 这里额外加一个文献，不知道为什么这篇没收录。Real-Time Analytical Processing with SQL Server，引入delete bitmap。

**统计信息收集**
- Absalyamov等人为基于LSM的系统提出了一个轻量级统计收集框架。其基本思想是将统计信息收集任务集成到刷新和合并操作中，以最小化统计信息维护开销。利用了LSM的多个文件特性，似乎每个文件单独维护统计信息，其中可合并的统计信息例如histogram直接合并，不可合并的用多个摘要synopses来提升准确度。

**分布式索引**
- 分布式二级索引，意义是用secondary key去查询对应的pk在什么分区上，进一步做分区剪枝吧。
- Joseph在HBase上做了两种索引，global secondary index和local secondary index。前者是维护secondary key和对应的PK表（会导致较高网络成本），后者似乎是把同分区的二级索引和主键索引放在一起，减少通信成本。但是后者在查询时需要遍历每个分区的二级索引，因为分区是主键列上的。
- 。。。

# Representative LSM-based Systems
介绍了有代表性的5个开源NoSQL LSM-based系统。

**LevelDB**：2011年谷歌开源，率先设计和实现了partitioned leveling合并策略

## RocksDB

介绍：Facebook在12年从leveldb分支出来，采用基于lsm的存储的主要动机是其良好的**空间利用率**。
- 补充一下，T=10时RocksDB能达到90%的空间利用率，或者说10%是重复旧数据。相比B+Tree，一个页面往往是2/3满的。

**partitioned leveling的优化**
- 内存层tiering：由于内存层没有partition，导致flush通常要合并多个1层的组。解决这个问题rocksdb引入了内存层tiering的概念，吸收写突发。但这个是不是就只是多个frozen memory table？感觉很稀松平常
- **动态调整写放大**：理想的写放大O(T+1/T)仅仅在满存储的情况下有，写入过程中通常数据应该是堆在上层的，相当与相同数据量的情况下层数变少了，这样写放大会增长很多。所以动态调整L1的总容量，让总体结构满足O(T+1/T)
- **两种compaction trigger：冷优先和删除优先**。前者对skew负载友好，点查能更快在上层发现，热数据变更更快可以晚合并降低写负载。后者对大量删除友好，尽快减少上层tombstone的数量腾出空间。
- compaction filter：后台中按自定义逻辑的删除或修改键/值对的方法。实现自定义垃圾收集（例如根据TTL删除过期的密钥或在后台删除一系列键）非常方便。它还可以更新现有密钥的值。

其他compaction策略
- tiering：RocksDB的Tiering Storage应该是指分层存储，是把存储介质按照速度和成本分层，每层实现自己的FileSystem在创建文件时。
- FIFO：不合并组件，但将根据指定的生存期删除旧的组件。

控制compaction速度：Leaky bucket。维护一个存有许多token的桶，token由token填充速度控制。在执行每次写操作之前，所有刷新和合并操作都必须请求一定数量的token。因此，刷新和合并操作的磁盘写入速度将受指定的token填充速度限制。

## HBase

介绍：HBase是Hadoop生态下BigTable的模拟。HBase是主从结构，可按range和hash分区存储数据。

- exploring merge policy：一种compaction file pick策略，每次选写开销最小的component
- date-tiered merge policy：component按照time-range做分区，对时序查询有更好帮助。

## Cassandra

介绍：基于Dynamo和BigTable的分布式存储，特点是依靠去中心化的架构来消除单点故障。

compaction策略上类似RocksDB和HBase，tiering、partitioned leveling、date-tiered策略。

二级索引是lazy update的，类似DELI。听起来是一种和我们类似的查询时更新delete bitmap的做法：如果在内存组件中发现旧记录，则使用它直接清理二级索引。或者当合并主索引组件时，二级索引将被lazy清空

## AsterixDB

介绍：旨在管理大量半结构化(如JSON)数据的分布式存储，架构上是shared-nothing，分区是hash分区方式。

每个分区有一个primary index、primary key index、多个本地的二级索引。AsterixDB使用行级别的事务保证索引间的一致（consistent）
- primary index是按照主键存储记录、primary key index只存主键（似乎是为了去重）来支持COUNT(*)
- 二级索引支持比较多，B+tree, R-tree, LSM-ification（一种将inplace更新的索引转换成LSM的索引的框架，听起来很神奇）

compactoin策略上用到的是Tiering，还有一种将所有索引的同步合并的方法，能用filter降低开销。

# Summary

这里整理一些有意思的论文。
- PebblesDB: Building key-value stores using fragmented log-structured merge trees，在partitioned tiering上做类似skiplist的guard，减少写放大。
- TRIAD: Creating synergies between memory, disk and log in log structured key-value stores，分离冷热键，热键不flush，对skew场景友好。
- Pipelined compaction for the LSM-tree，流水线化compaction的过程，更有效利用CPU和磁盘的设备并行。
- LSbM-tree: Re-enabling buffer caching in data management for mixed reads and writes，提出compaction buffer能有效减少cache miss的情况。
- bLSM: A general purpose log structured merge tree，降低write stall和latency但效果听起来并不好，只用去了解里面的write stall和latency是什么。
- WiscKey: Separating keys from values in SSD conscious storage，键值分离能减少很多写放大的问题，但是引入了GC的瓶颈。在SSD这种随机IO比较好的设备上有更好的效果，应该是未来的方向？类似还有HashKV的优化。
- SlimDB: A space-efficient key-value storage engine for semi-sorted data，主要看看CuckooFilter怎么在一个层上直接命中SST的，另外tiering的结构可以参考。
- Towards accurate and fast evaluation of multi-stage log-structured designs，通过数学模型预测NDV，然后动态调整参数。这个NDV的准确度可以看看，和统计数据的收集有无关系。
- Monkey: Optimal navigable key-value store和Optimal Bloom filters and adaptive merging for LSM-trees，通过调整每层FPR让整体点查的开销减少一个L的乘数。  
- Dostoevsky: Better space-time trade-offs for LSM-tree based key-value stores via adaptive removal of superfluous merging，lazy leveling圣经
- Diff-index: Differentiated index in distributed log structured data stores，提出了二级索引的四种更新方式，可以参考下。
- Deferred lightweight indexing for log-structured key-value stores，像极了主键引擎的查询时更新模式，看看有没有什么共鸣和可以借鉴的。
- Efficient Data Ingestion and Query Processing for LSM-Based Storage Systems，研究了二级索引的更新方法，引入了mutable bitmap。
- Real-Time Analytical Processing with SQL Server，delete bitmap的本篇，但似乎是用在HTAP上的？
- Cassandra，这里没看到索引相关的文献，看看有没有博客讲二级索引如何更新
- Storage management in AsterixDB，看看二级索引怎么做的，另外invert index很在意。
- Lightweight cardinality estimation in LSM-based systems，统计信息收集的轻量框架，一个矛盾是轻量和准确，看看怎么处理的。
