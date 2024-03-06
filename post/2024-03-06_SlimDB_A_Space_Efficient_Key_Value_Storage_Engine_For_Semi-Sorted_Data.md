这篇主要针对semi-sorted负载上，做了一些内存空间和减少点查开销的工作。
  - 通过three level block index来替换传统的block index，可以做到消耗更少内存。
  - 通过multi-level cuckoo filter，能做到PK索引到某个level，从而减少点查延迟。
  - 另外提出一个在给定预期读写放大，生成in-memory index和on-disk data storage布局的分析模型。
这篇感觉和现在的工作不是很契合，浅看一下就成。

# Background

## Semi-sorted Workload

半排序的数据，具体是指PK由多个列的prefix和suffix组成。存在一些范围查询负载，只需要查询相同prefix的各个主键，而对suffix没有任何排序要求。我认为就是主键的前缀查询。这样的查询负载存在于很多应用场景：
  - 推荐系统，用来做机器学习的数据有(entity id, feature id)。我的理解是喂数据的时候仅按照entity id查询。
  - 文件系统元数据管理，文件的存储按照主键(parent directory inode id, filename hash)。readdir操作就可以仅按前缀查询。
  - 图系统，每个边存储的主键是(source node id, destination node id)。查询最近邻居就只用按source node id查询即可。

## Stepped-Merge Algorithm

类似tiering的做法，似乎是tiering的前身？具体是每层都有多个sub-level（我理解一个sub-level就是一个sorted run），compaction时会从level i的所有sub-level里做sort-merge，然后产生一个新的sub-level到level i+1。而原本partitioned leveling的方法是，在level i里取一个文件，在level i+1里取多个overlapped文件做合并。

对比可以发现，现在每层里存储的数据，只会产生一次compaction的IO。原本partitioned leveling，level i的compaction会反复读写level i+1上的数据，造成浪费。

但是相对的，读开销变大了，因为每次读都要对所有sub-level做检查和读取。类似现在tiering，每层都对每个sorted run做读取一样。

## Block Index in LevelDB

很简单的结构，类似主键的稀疏索引，leveldb会记录每个block结束的完整key，用来做索引。

# Three-level Block Index

这块很复杂，感觉用不到所以只简要介绍下。用到Entropy Coded Trie，是来自CMU的另一篇SILT。

ECT使用大概2bit/key，而LevelDB则是8bit/key。但是ECT每次查找的CPU开销比LevelDB多5倍至7倍。如果CPU资源成本更低，换取内存大小是有效的。另外我不清楚每次查询的CPU开销是不是很关键？如果发生了IO的话，按理CPU成倍增长应该是可以接受的。

# Multi-level Cuckoo Filter

先介绍下Cuckoo Filter，我理解是一种在cuckoo hash map上引入指纹的产物。CMU原论文能看出，相比Bloom Filter，能在支持添加删除功能外，提供更高的性能。而且在适中的低误报率上，Cuckoo能比扩展的bloom filter做到更低的空间占用。

Multi-level Cuckoo Filter，就是保存了某一个层内，所有sorted run和对应的主键。这样每层的点查就不用便利sorted run去看各自的bloom filter。所以每层的点查只用经过一个Multi-level Cuckoo Filter，再经过cuckoo filter就能找到数据。也就是说，从原来的大概O(LT)降到O(L)上。

论文似乎没有提MCLF的CPU开销，没提怎么更新MCLF。另外MCLF只能用在全主键点查上（或者选定一部分键），也就是说对range query没有什么帮助。如果点查负载很高的话，可以看看这个东西，能在Tiering的情况下，提供类似Leveling的点查性能。
  - 不过Monkey那篇论文可以调整FPR来降低整体Bloom filter的点查复杂度，能降低一个L的乘数。这个调参明显实现上更简单。

# Cost Model

SlimDB根据内存预算，分析了整体的Cost Model来选择最佳配置。枚举8个LSM树配置，对每个操作做估计（写入、空点查、非空点查、内存开销）。然后为一个负载上计算总成本，具体是指定每个操作的比例（例如30％写入，40％点查，30％空点查）。
	- 这个我们也可以参考下，给整个系统某种可观测的方式，能通过参数来估计整体开销。

