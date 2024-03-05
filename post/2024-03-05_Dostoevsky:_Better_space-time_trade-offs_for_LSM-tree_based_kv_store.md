这篇主要是介绍了当时主流LSM tree产品，在更新和查询成本上的分布，提出Monkey和Dostoevsky。Monkey主要是调整Bloomfilter来降低更新和查询开销，Dostoevsky是降低最后一层的读放大问题。

# Introduction

提出了几个问题，和三个解法。直接跳过。

# Background

解释了层数L和大小比T在数据总量N的关系。定义了一系列CURD操作和一些概念。
- Fence Pointer我的理解是就zonemap
- Bloom Filter，每个SST都有一个在内存里（而不是每个block一个）。假阳性率FPR，**大概**是e^(- bits / entries)。当bloomfilter有阴性那么节省一次IO，有阳性乘FPR那么浪费一次IO。

# Design Space and Problem Analysis

这里定义了leveling和tiering一些操作的IO cost。
![leveling-and-tiering-io-cost](/static/image/2024-03-05/leveling-and-tiering-io-cost.png)

- **update**：由更新一个kv导致的merge操作的IO的平均成本。很明显tiering是L/B，leveling因为要考虑读写下层相关SST，所以按照放大比例会影响T倍的数据，所以是LT/B。
- **point lookup**：分析最差情况，Bloom Filter都返回了假阳性，那么每层每文件都要检查。明显tiering是LT*FPR，leveling是L*FPR。如果用到Monkey论文的方法，那么可以去掉一个L的乘数。
  - Monkey的方法是，从L0到最大层，逐渐减少bloomfilter的空间，让FPR成指数级变大。对每个层来说，FPR应该放大到e^(-M/N) / T^(L-l)，这样的话用等比数列求和公式能发现总和没有L乘数。
- **space amplification**：空间放大定义是总数据N/uniq-1。基于一个观察，最后一层大概有T-1/T的数据。那么最差情况前面几层都是更新过的值，而最后一层对应的值都是stale的，那么leveling空间放大最大也就是1/T。类似的，可以发现**tiering的空间放大会是T倍**。
  - tiering的情况，考虑到可能每个sorted runs里的数据都是最新数据，那么最大层可能每个sorted runs都是重复的，只有一个sorted runs里有最新数据。但是，考虑上层所有sorted runs也可能包括最新数据，那么如果T>=Z，这种情况最后一层都是旧数据。最后一层是T-1倍，那么就是O(T)。（论文这里总觉得有点混淆T和Z，这里应该是Z吧）
  - 一些思考：考虑如果不是满数据的稳定状态，那么相当与层数减少了，leveling的情况会有更大写放大，而tiering的情况会有更多sorted runs会有更大读放大。RocksDB考虑这点后，用动态调整第一层大小来控制总体层数。对tiering的情况，这种方法可能没有效果，因为sorted runs个数仍然没变，而且每个文件大小变少的话还会引入更多文件。
- **range lookup**：作者分成两种范围来讨论了，对于涉及block数量小于2*L的范围查询，作者认为是短范围查询，反之是长范围查询。
  - 其实也好理解，相当于短范围查询在每个层最多有两个block需要扫描，很可能都在一个文件里。
  - **short range lookup**：leveling每层访问文件1到两次，那么总体是O(L)。tiering总体是O(LT)。
  - **long range lookup**：考虑选择度s（查询出的key占总key的个数）和每个block里存储的kv数量。考虑最后一层可能占用T倍的前几层数据，那么leveling得到O(s/B)，tiering得到O(sT/B)。

**一些观察**
- 更新成本和（查询开销和空间放大）之间有固定的权衡取舍。
- 开销不对称：在查询开销和空间放大上，因为最后一层空间大小占比很高，导致开销很多落在这里。在更新成本上，不论leveling还是tiering，所有层上都是一样的。那么就可以说合并操作对前几层带来的查询和空间效益不大，所以最好在后面的层上引入leveling这样的合并，而前面用tiering即可。

# Improves

## Lazy Leveling

**IO复杂度**

首先文章分析了l-leveling在各种操作下的IO复杂度，如下图。下面简单讲下关键的计算。

![lazy-leveling-cost](/static/image/2024-03-05/lazy-leveling-cost.png)

首先讲到最小化Bloom Filter的整体空点查开销R。
- 方程(3)中$p\_i$是某层上的Bloom Filter的FPR。由于最后一层只有一个文件，而前面几层都是T-1个文件（因为T个文件会触发compaction）。
- 方程(4)则是MN关于所有层FPR的关系。

由上述两个方程可以通过拉格朗日乘数法找到方程(3)的最值以及pi的取值。最小的R即如下方程。

$$
R=e^{-\frac{M}{N} \cdot \ln (2)^2} \cdot \frac{T^{\frac{T}{T-1}}}{(T-1)^{\frac{T-1}{T}}}
$$

另外也讨论了当FPR是1的时候，M/N的大小。一般我们去FPR为0.01时，M/N会给10，也就是说每个entity给10bit左右。

**帕累托图**

这种图展示了两个不同成本，在不同T值选取下的代价相关性。我们可以观察这三种布局的图像，来选择具体对某个负载而言最合适的布局。

![lazy-leveling-cost-pareto-chart](/static/image/2024-03-05/lazy-leveling-cost-pareto-chart.png)

l-leveling的设计并没有比哪一种在任何情况下更优秀。
- l-leveling最适合平衡的负载，包括更新，点查找和远距离查找。
- 而tiering和leveling最适合分别包括更新或大部分查找的工作负载。

后文会采取步骤朝着一个统一的系统，根据应用程序方案进行调整这些设计。

## Fluid LSM tree

Fluid LSM tree 引入参数K和Z，K是指在tiering上是sorted runs的个数，Z是最后一层leveling上sorted runs的个数。

这里列以下Fluid LSM tree上，各个操作的IO开销：

$$
\begin{matrix}
R&=&e^{-\frac{M}{N} \cdot \ln (2)^2} \cdot Z^{\frac{T-1}{T}} \cdot K^{\frac{1}{T}} \cdot \frac{T \frac{T}{T-1}}{T-1} \\
V&=&1+R-p_L \\
Q&=&K \cdot(L-1)+Z+\frac{1}{\mu} \cdot \frac{s}{B} \cdot\left(Z+\frac{1}{T}\right) \\
W&=&\frac{\phi}{\mu \cdot B} \cdot\left(\frac{T-1}{K+1} \cdot(L-1)+\frac{T-1}{Z+1}\right)
\end{matrix}
$$

## Dostoevsky

Dostoevsky就是在一定限制条件下，按照几个方程将这三个参数调整的最优的值。

$$
τ = \frac{1}{Ω (w · W + r · R + v · V + q · Q)}
$$

# Evaluation

![dostoeevsky-evaluation](/static/image/2024-03-05/dostoeevsky-evaluation.png)

- Trans1：通过改变Z为4，调整T，可以发现整体向tiering的负载情况变动。
- Trans2：通过改变K为4，调整T，发现向leveling的情况变动。

# 一些调参思考

这里Dostevsky给了一个调参的思路和范例，给定具体负载场景（更新、空点查、非空点查、范围查询的权重），通过估计的加权最差吞吐量，去寻找满足不同负载下的整体性能。

总结下调参的定性思路：
- 上面的结果里，我们讨论下**sorted runs个数**的变动会造成什么影响：
  - 当上层的sorted runs个数减少（K减少即Trans2），短范围查询的延迟会变低，但更新的延迟会变高。
  - 当下层的sorted runs个数增加（Z增大即Trans1），更新的延迟会变低，但 范围查询整体的延迟会变高。
- 讨论下测**层间比例T**的变动会造成什么影响：T变大，查询成本变大，但是更新成本变小。这个在tiering和leveling上是相反的。
- 另外，层数L的变动：固定总容量不变时L变大，可以减少leveling的写放大，可以减少tiering的sorted runs个数。
  - 层数L的变动最基本地，会调整总容量。当然如果数据总是到不了总容量，相当与和tiering有类似。

这里画了一下Trans2总体吞吐量随TK变化的图。能发现为了提高总吞吐量，T变大且K变小似乎是最好的。但总觉得有点问题，感觉是常数似乎没给对：[Total Cost of Dostoevsky Trans2 | Desmos](https://www.desmos.com/calculator/t80bcsrbxe)
