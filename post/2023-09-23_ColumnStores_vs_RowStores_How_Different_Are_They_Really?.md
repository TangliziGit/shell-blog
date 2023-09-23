# Summary

- 主要动机：
  - 用实验来讨论行存引擎能否通过模拟列存设计来达到列存的性能，以及列存的几种设计那些更有效。
- 核心思路：
  - 通过SystemX模拟列存设计和CStroe进行SSBM的测试对比，以及通过裁剪CStore的某些列存设计做SSBM测试，来回答上述两个问题。
- 效果评估：
  - 对行存模拟列存的实验上，讨论了垂直分区、仅用索引做查询、以及使用最优物化视图的方式做测试，结果表明物化视图能有效降低查询平均耗时（减少60%），而其他方法都远远不能达到原有实现的性能表现：垂直分区增加211%耗时，全索引增加760%耗时。
  - 对列存，介绍了四种提升性能的设计：平均来看，块遍历、InvisibleJoin、压缩和延迟物化各自分别减少了37.5%、46.6%、49%和61%的耗时。（如果这些优化加起来能够将近减少93%的耗时，“相当于”行存是列存系统的14倍查询时间）

# Introduce

- 本篇是08年发表在SIGMOD上的论文，对AP下列存性能高于行存一个数量级的现象上，主要讨论两个问题：
  - 能否在行存数据库的使用上，模拟一些列存的设计来达到列存的高性能？
    logseq.order-list-type:: number
  - 为什么列存能有更高的性能表现？为列存提供高性能的几个设计上，哪些更为有效？
    logseq.order-list-type:: number
- 针对问题一，作者通过三种可能的列存设计，在行存上进行相应的模拟，来测试性能表现：
  - 垂直分区：将表中的每个列单独抽离，组成包含主键+属性两列的表，进行存储和查询。
  - 只通过索引做查询：
  - 物化视图：
- 针对问题二，作者认为主要有四种设计能够提升列存性能。即如果没有这些设计，那么列存和行存的性能无明显差异：
  - 延迟物化：狭义是指尽量晚地将列连接，转换成行数据。
  	- (我们推敲了一些场景，认为物化应该是指：依赖部分行的信息产生新表的过程，典型如filter、aggregate、join，它们都需要扫描部分列中所有行，来提取或产出新的列从而组成新表。另外project是否为物化可能比较有争议？)
  - 块遍历：指计算表达式一次性做一批的方式，而非向量化执行。
  	- 顺便提一下向量化模型：不同与volcano模型，向量化能够对列做类似数组扫描的能力（如果是固定大小），能更轻松地让编译器实现loop piplining。不同与materialized模型，向量化能够将列放入cache中，避免多次LOAD&STORE的内存开销。
  - 压缩：不仅仅降低了IO开销。如果使用某种特殊压缩算法，那么可以在计算时不用解压，提高了cache和内存间的传输开销。
  - Invisible Join：作者提出的一种join算法，能够尽量晚地做物化。
  	- 作者特地说明这种方法，能与从列中选择和提取数据一样，甚至更快。

# Star Schema Benchmark

- SSBM是一种从TPC-H衍生出来的基准测试，突出一个教科书式的星形模型。
- 这里顺便总结下星形模型相关的一些概念：
  - 事实表：记录事实或事件的”日志表“，例如用户购买记录表，包含购买日期、产品ID、销售人员ID、消费者ID、金额。事实表可以认为是包含大量外键和基本属性的表。
  - 维度表：记录某种概念本身属性的表，比如产品维度表，包含产品ID、品牌、信号、类型、指导价等。可以认为是N个唯一主键和基本属性组成。
  - 星形模型：维度表只与事实表关联，维度表之间不关联；
  - 雪花模型：维度表可与维度表关联。规范化得来的表，减少冗余数据，但增加Join成本。
  - 星座模型：在雪花模型的基础上，加入多个事实表。

# Row-oriented Execution

- 这里讲到了一些行存数据库如何模拟列存的一些设计。另外，也提到了一些典型的行存优化，感觉值得总结。
- **垂直分区**
  - 将表的所有列拆分出独立的表，每个表包含列位置ID和属性。我们用这种方式进行查询。
  - SystemX默认执行HashJoin来做物化，这被证明是低效的（后文会提）。所以作者也用聚簇索引存表的方式做测试，结果访问索引导致更慢的表现。
- **只建立索引**：上述设计中，额外的位置ID列带来没有必要的IO带宽消耗，另外常见的实现中Tuple的存储会带上很大的header。可参考：[Q：Tuple的内部结构是什么样的？](https://blog.tanglizi.one/post.sh?name=2022-02-19_[CMU15-445]_%E6%95%B0%E6%8D%AE%E5%BA%93%E5%8E%9F%E7%90%86%E7%9F%A5%E8%AF%86%E7%82%B9%E6%80%BB%E7%BB%93.md#q%EF%BC%9Atuple%E7%9A%84%E5%86%85%E9%83%A8%E7%BB%93%E6%9E%84%E6%98%AF%E4%BB%80%E4%B9%88%E6%A0%B7%E7%9A%84%EF%BC%9F)
  - 为了改善这些问题，作者此时用到只建立索引的方式，利用非聚簇索引来存非主键列（映射到RID），聚簇索引来存主键列。这样每个非聚簇索引不带位置ID，同时也没有TupleHeader。（但是B+Tree本身存储就会带来一些非数据的内容，见[Q：B+Tree的定义](https://blog.tanglizi.one/post.sh?name=2022-02-19_[CMU15-445]_%E6%95%B0%E6%8D%AE%E5%BA%93%E5%8E%9F%E7%90%86%E7%9F%A5%E8%AF%86%E7%82%B9%E6%80%BB%E7%BB%93.md#q%EF%BC%9Ab%2Btree%E7%9A%84%E5%AE%9A%E4%B9%89)）
  - 另外，有些查询如果有复合键索引的话，效率更高。如查询`SELECT AVG(salary) FROM emp WHERE age>40`，正常讲会走age索引然后回表查完整行；但是走复合件索引就能直接扫出需要的salary值，然后做avg。这似乎是一种DBA的常见优化？
- **物化视图**
  - 可以对每种固定的查询做一个物化视图。效果是查询时不会再做Join，代价是提高了写入开销。

# Column-oriented Execution

- **压缩**
  - 关于压缩比：相比于行存引擎，列存能够更好利用压缩算法：因为同一列中的数据局部更加相似，信息熵更低，压缩比更高。如果该列是已排序的，甚至局部相等的，那么压缩比会更高。
  - 关于性能：从磁盘读入内存的IO时间更少，虽然引入了压缩和解压的花费。
- **延迟物化**
  - 这里的物化是指，由于需要行信息（或者构造tuple）所以连接多个列产生新表的过程，如ODBC和JDBC要求按行返回、某些SQL语句：JOIN、PROJECTION、GROUP_BY等。这种物化本身开销不低，替换新表会刷新掉cache内容，并且需要解压每个列。
  - 延迟物化则是通过延迟、减少或消除全表物化的次数，缓解上述三个缺陷。下面是作者提出的和实际中的一些延迟物化的方法：
  	- Filter：将表达式拆分为多个AND组成的表达式，对每个表达式分别求值，得到bitmap / index再做合并获得filter，等到真的需要物化时再做table.get(filter)。
  		- 为什么避免了物化？因为ColumnRef获得一个列，同时表达式算法也是用到向量化执行的方式，每次处理BUF_SIZE个元素。如果要处理相同行的数据，例如`add(price, volume)`那也不需要物化，只不过是相同行的两个列数据做处理即可。
  	- TopN：通过某种算法获得排序后的index数组，并且尽量晚地创建表。
  	- Agg：一种SortGrouping是指TopN排序后获得index数组，遍历得到GroupKey相同的几个行做成index数组，然后对agg求值即可。另一种HashGrouping不太清楚如何做的，如果是传统物化的方式应该效果不太好，另外对GroupKey列构建HashTable本身是不是没有避免物化的缺点呢？
  	- Projection：如果是全部引用列的表达式，那么直接做reorder即可。如果不是的话，只能表达式求值并应用filter。
  	- Invisible Join：后文讲，核心依然是构建Filter和HashTable而尽量晚地替换原有列。
- **块遍历**
  - 表达式执行一次性做一批，例如BUF_SIZE 1024的大小。
- **Invisible Join**
  - 传统Join：先从selectivity高的两表做Join（因为过滤的行数可能更多），对两表先物化然后SortMergeJoin或HashJoin处理之。
  - LateMaterializedJoin：目的是推迟传统Join的物化
  	- 先扫描维度表（如果有PushDownFilter则过滤）获得index数组，或者是包含position的HashTable。
  	  logseq.order-list-type:: number
  	- 顺序扫描事实表的Join列做probe，产出Join后的维度表和事实表的index数组。
  	  logseq.order-list-type:: number
  	- 接着按照index数组提取两表，这里提取本身可以延迟。另外index数组提取是随机提取的，即使列是fix-size可索引也对cache不友好。
  	  logseq.order-list-type:: number
  - InvisiableJoin：目的是解决LateMaterializedJoin最后一步index数组乱序提取的问题
  	- 对所有维度表做过滤，获得HashTable(K=JoinKeyValue, V=Position/PrimaryKey)
  	  logseq.order-list-type:: number
  	- 顺序扫描事实表，一次性做所有的probe，产出事实表的满足所有Join条件的index数组F。
  	  logseq.order-list-type:: number
  	- 用F对事实表的JoinKeys做提取，利用提取出的列对维度表做提取：如果该JoinKey是维度表主键（设计上就是position），按index提取维度表；如果不是主键，那么扫描维度表。
  	  logseq.order-list-type:: number
  	- （依然没有理解这个Join为什么能解决乱序提取的问题，按position提取仍然是乱序的，论文提到维度表很小可以放在cache里，这样其实上面延迟物化Join也可以这样处理）
  	  logseq.order-list-type:: number
  - Between-Predicate Rewriting：思路是将HashTableProbe的过程用Between来改写。原理是如果第一步提取出来的JoinKey是不间断的，那么可以将事实表probe的过程改成between，这样可以减少一次HashTable访问，只用计算即可。