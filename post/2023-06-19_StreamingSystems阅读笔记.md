# Streaming Systems 阅读笔记

# Chapter1. Streaming 101
## Definitions
- **流处理系统的优势**
	- 提供低延时保证，能及时洞察数据
	- 处理大量无边界的数据源
	- 产出平滑可预测的资源消耗
- **流处理系统的定义**
	- 为满足无限数据源而设计的数据处理系统
- **数据的两种正交维度**
	- 基数：有界数据 / 无界数据
	- 结构：表（反应某时刻的数据视图） / 流
- **流处理系统和批处理系统的区别**
	- 低延时
	- 无界数据
	- 平滑负载

## Lambda架构
> [大数据架构如何做到流批一体？_大数据_周灿_InfoQ精选文章](https://www.infoq.cn/article/uo4pfswlmzbvhq*y2tb9)
  > [大规模数据处理的演化历程 - 知乎](https://zhuanlan.zhihu.com/p/51846010)
  > [当我谈论数据湖时，在谈些什么 - Ying](https://izualzhy.cn/lakehouse-summary)
  > [How to beat the CAP theorem - thoughts from the red planet - thoughts from the red planet](http://nathanmarz.com/blog/how-to-beat-the-cap-theorem.html)
  > [How to beat the CAP theorem | Hacker News](https://news.ycombinator.com/item?id=3108087)
  > [Questioning the Lambda Architecture - O'Reilly Radar](http://radar.oreilly.com/2014/07/questioning-the-lambda-architecture.html)
![](https://izualzhy.cn/assets/images/%E6%95%B0%E4%BB%93%E6%9E%B6%E6%9E%84%E6%BC%94%E8%BF%9B.png)

- **Lambda架构是什么**：双写的流批系统
  - Marz假定流处理计算为了降低时延，可以使用近似算法等使得结果变得模糊或不可靠。所以如果需要可靠计算结果的话，需要结合批处理来实现相同的计算逻辑，最后与流计算结果做合并，提供完整的查询视图。

- **Lambda架构的挑战**
  - 双写一致性：双写导致的一致性问题在lambda架构里没有保证，所以需要上游配合，解决一致性问题
  - 维护复杂：两套系统分别实现同样的逻辑，分别维护不同的故障，debug等。

- **Lambda架构的演进 / 流批一体**
  - **Lambda是一种时代产物**
  	- 尽管它带来了大量成本问题，Lambda 架构当前还是非常受欢迎，仅仅是因为它满足了许多企业一个关键需求：系统提供低延迟但不准确的数据，后续通过批处理系统纠正之前数据，最终给出一致性的结果。从流处理系统演变的角度来看，Storm 确实为普罗大众带来低延迟的流式实时数据处理能力。然而，它是以牺牲数据强一致性为代价的，这反过来又带来了 Lambda 架构的兴起，导致接下来多年基于两套系统架构之上的数据处理带来无尽的麻烦和成本。
  - **Kappa架构**：支持Replay的数据源 + 流处理系统
  	- 背景是在尝试lambda架构后，大家提出了一种质疑：Questioning the Lambda Architecture。问题在于是否必要做两次相同的计算，同时还带来了维护复杂的问题
  	- Kreps博客描述Lambda架构是一种为了提供低延时查询，又不得不依赖批处理提供正确性的系统方案。11年左右流处理系统并不成熟，没有支持向MR这种强大的功能。（MR发布与2003年，
  	  Flink在2009年，Storm在11年，Spark Streaming在13年）
  	- Kappa架构的核心是只使用一个流处理系统，当你需要做replay的时候，从kafka这种支持replay的数据源拿出历史数据，在新建的流标或者流系统实例上处理，然后业务上用影子表做切换。
  - **Spark Streaming和Flink等**：更强的保证
  	- 状态存储
  	- Exactly once：仅一次的Sink
  	- Event time skew：事件发生时间和消息处理时间之间存在偏移

- **一些问题**
  - Marz博文本意是希望通过使用time based并且append-only的数据源，来让整个系统达到CAP。于是后面用到批处理系统和实时处理系统来做例子。其中批处理系统来做全量计算，定期构建或修复查询视图，提供某种意义上的最终一致性。然后实时系统提供可用性，能够利用增量算法和近似算法，在短时间内计算近几个小时内新增数据，使用户能够查询到最近一段时间内的数据，但不保证正确性。正确性由批处理后续修补。
  - 我也认为作者似乎理解错了CAP。作者希望通过不可变的数据（这里数据是{timestamp, ID, data}的意思，由时间戳区分相同ID下的data），来让批处理系统和实时系统达到某种一致性。错误点在于：
  	- C不是指正确性，而是指数据完全相同。你可以采用不同的保证来做到这个目的，如线性一致性、最终一致性、因果一致性等。
  	- A也不是低时延的意思，而是为了提供线性一致性，不得不等待网络故障结束，去请求其他节点获取数据的意思。
  	- 另外，如果已经实现了全局统一的append-only的数据日志，例如单点服务或用到共识机制的多节点服务。那么CAP实际上都在这一层被解决了。例如使用Kafka作为实现。
  - 为什么实时处理系统就不好，非要用到批处理系统？
  	- Storm是整个行业真正广泛采用的第一个流式处理系统，Marz在设计该系统时强调低时延，故放弃了计算准确结果的能力。于是Marz在后来写博文来做一个补丁，结合批处理提供准确结果。
  - 什么场景可以降低正确性要求？推荐系统、PageRank等

## 流处理系统的挑战

- **正确性**：状态持久化

     - > [Why local state is a fundamental primitive in stream processing – O’Reilly](https://www.oreilly.com/content/why-local-state-is-a-fundamental-primitive-in-stream-processing/)
     - fault tolerance：没有持久化无法对抗不可预测的故障
     - exactly once semantics：持久化是仅一次处理的前提（why？）

- **时间偏移 & 消息乱序**：无界数据流下的乱序和不可预测的时间偏移（消息处理时间和事件发生时间存在差异）问题

     - 如果要关注正确性，那么不能用processing time做关于时间的计算。
          如window functions中，processing time完全不能使用。这样会发生在一个时间窗口中出现其他时间数据的现象，导致计算错误而且不可复现。
     - 如果要用event time，还需要考虑无界数据流下的乱序和不可预测的时间偏移问题。
          我们无法得知某个窗口中的所有发生事件消息是否都已经收到。
            		- 我认为做到真正的正确性，需要上游提供某种保证，让事件发生时间能够在规定时间内发送给流处理系统。即：$$ T_{processing} - T_{event} < D $$。甚至如果时间超过D，那么直接丢弃这个消息，或者给用户响应失败重试。当然这听起来很扯淡。
              		- 另外我觉的除了提供上游正确性保证，还可以考虑一些补偿措施。
     - 很难做到真正的正确性
          当今使用的绝大多数数据处理系统都依赖于某种完整性概念，这使它们在应用于无限数据集时处于严重劣势。（不知道23年的今天情况如何）
     - 这部分作者相较于批处理而言，更趋向与设计更好的工具来适应困难。

- 另：为什么不能假定系统的输入是有序的呢？

     - 单信道会乱序么？：如果用单独一个TCP端口传输的话，肯定没有问题

     - 多信道场景：比如多个手机App分别上传埋点数据。此时服务器一定会用多信道解决方案：多线程、Poll+单线程。二者都不能排除由不同信道的不同延迟导致提交时发生乱序的问题。


## 数据处理模式

- **有界数据**
	- 批处理
- **无界数据：批处理方式**
	- 特点：切分无界数据为一组有界数据的集合，再分批处理
	- **固定窗口**：以滚动窗口（tumbling window，与sliding window不同的是窗口不会重叠）的方式做切分
	- **会话切分**：固定窗口会将用户在某个会话中的数据分开。为了避免该问题，可以通过扩大batch size降低发生概率，或在固定窗口中缝合（stitch up）会话。
- **无界数据：流处理方式**
	- 特点：需要考虑消息乱序和时间偏移。
	- **Time-agnostic / 时间不可知的**：忽视掉时间属性，在业务上认为时间没有意义。
		- **Filter**
		- **Inner Join**：需要考虑用buffer存储还没出现join关系的其中一个流的数据，直到出现之后做join并放行。需要考虑的是如果迟迟没有需要join的元素，那么需要GC清理。
		- **（考虑一下Outer Join）**：如果一个流的元素到达，那么我怎么知道另一个流中没有该数据希望join的数据呢？所以这里需要某种超时机制，本质是一种windowing。
	- **Approximation / 近似算法**：低开销且专为无限数据而设计的算法。往往依赖处理时间来做误差分析。
		- 缺点是算法种类有限，且通常很复杂，并且近似性质限制了实用性
		- 有关误差边界：近似算法往往需要依赖时间属性，且通常基于处理时间。这对于数学上已证明的近似误差有关。如果这些误差边界是基于按顺序到达的数据来计算的，而我们向算法提供了有时间偏差的无序数据就没有意义了。
		- **近似TopN**
		- **流式KMeans**
	- **Windowing / 窗口**：目的是将无界数据划分为多个有限数据，以便支持业务需求
		- 按照种类分为：滚动窗口、滑动窗口和会话切分
			- **Fixed Window / Tumbling Window**：滚动窗口
			- **Sliding Window / Hopping Window**：滑动窗口，与滚动窗口不同的是，他可以重叠
			- **Session**：会话切分
		- 按照时域分为：
			- 以**消息处理时间**划分窗口：将传入的数据缓冲到窗口中，当处理时间到达时开始计算
				- 特点：概念和实现都很简单，并且很容易判断窗口完整性。
				- 场景：在一些监控场景中，可以只关注处理时间，或者说可以保证skew很小且没有unordered
			- 以**事件发生时间**划分窗口：
				- **Buffer**：窗口需要更久的生命周期，所以需要更大的Buffer、强一致的状态持久能力、更大的内存缓冲层。
				- **完整性**：无法保证。
					- 对不严格场景：可以通过watermark来给一个合理的完整性估计。
					- 对严格场景：需要用户提供额外的信息，表达何时具体化窗口的结果以及如何随着时间的推移改进这些结果

# Chapter2. Data Processing

## What：计算结果是什么样
- 计算由Transformers来定义，计算结果对批处理和流处理有着不同的表现形式。
	- 如IO Source -> String -> KV<UserID, Number> -> KV<UserID, String> -> String
- **批处理**：计算结果就是期望的结果，如数据集中的团队总分、每人的分数等
	- [Figure 2-3: Streaming Systems Book](http://streamingsystems.net/fig/2-3)
	- 如果划分了窗口，那么输出就是`Vector<Pair<Window, Output>>`。或者说是`Vector<Pair<Pane, Output>>`，因为一个Window就是一个Pane，系统不用为了降低延迟而将Window划分为Pane。
	  [Figure 2-5: Streaming Systems Book](http://streamingsystems.net/fig/2-5)
	- 批处理系统会按照event time做windowing。event time对系统来说唾手可得，processing time就变得意义不大了。
- **流处理**：计算结果包含Window Pane，即`Vector<Pair<Pane, Output>>`结构
	- [Figure 2-6: Streaming Systems Book](http://streamingsystems.net/fig/2-6)
	- 其中，一个Window可能会产生多个Pane。
	- 我认为Pane之间会乱序，比如属于`[12:00, 12:02)`的Pane可能出现在`[12:02, 12:04)`的Pane之后。只不过是前者的数据乱序到达了而已。
		- 但是代码中展示了顺序输出的结果，让我很费解。见[BeamModel.java at master · takidau/streamingbook](https://github.com/takidau/streamingbook/blob/master/src/main/java/net/streamingbook/BeamModel.java#L122)

## Where：在哪里计算
- **Window**：通过切分EventTime来处理无界数据的方法
- **Pane**：是Window下的一次物化结果（或窗口实例） / Window范围下的一次输入采样
	- Window只是指一段EventTime，一系列Pane覆盖了Window下的所有数据。
	- 把Window划分为多个Pane的意义在于能降低产出结果的时延。

## When：何时物化结果 / 何时清理窗口
- **Trigger**：用于指明窗口的输出（window panes）何时具体化的触发器，意义是快速产生pane降低延时。
	- Trigger和Pane紧密相关：延时与最终一致性
		- 如果没有trigger的话，那就只能在批处理计算世界中处理。系统需要等到所有输入全部结束，才能产生pane，才能查询。这显然违反了无界数据流的前提。
	- **Repeated Update Trigger / 周期触发器**：按照消息个数或时间延迟做触发，能够降低延时
		- **Count Trigger**
		- **Aligned Delays Trigger**：当某个EventTime下的数据到来后开始填充pane，直到PT mod X == 0才产出pane。
			- [Figure 2-7: Streaming Systems Book](http://streamingsystems.net/fig/2-7)
			- 作者代码中提到aligned delay其实就是一种微批处理。
		- **Unaligned Delays Trigger**：当某个Window的数据到来后开始填充pane，直到计时器到X min时才产出。
			- [Figure 2-8: Streaming Systems Book](http://streamingsystems.net/fig/2-8)
		- **负载均衡 vs 低延时**：不同的Trigger策略会有不同的负载均匀度和延时的影响。
			- 非对齐触发器会比对齐触发器有更均匀的产出，后者会集中在某时刻产出所有Window的pane。
			- 但后者有更低的延时。
		- **适合趋于正确的场景 / 最终一致性**
			- 既然周期性Trigger是为了降低延时而计算当前结果，那么我们可以说用户的查询会**趋于正确**。系统不会及时受到属于某个窗口中的数据。需要随时间推移，让属于该window的数据到达并计算，才能说处理正确。**趋于正确是一种最终一致性的体现**。
	- **Completeness Trigger / 完整性触发器**：通过估计窗口完整性做触发，可提供一定程度的完整性
		- 与周期性触发器不同的是，它会为了保证正确性从而利用Watermark估计窗口完整性。当触发器认为当前窗口完整后，不再接受该Window后续数据。
		- 另一种方式是在Lateness时间内接受成Late Pane，Lateness时间外则GC并drop掉迟到数据。
- **Watermark**：用于判断窗口完整性的方法 / 用于估计当前系统正在处理的消息的EventTime的方法
	- Watermark是什么？如何判断窗口完整性？与Trigger有什么区别？
		- 可以认为Watermark是一个函数，$$ F(P, State) = E $$，其中P是处理时间E是事件时间，State是系统状态（后文忽略）。系统会认为不会收到比$$ F(P_{current}) = E_{reasoning}$$更晚的消息。因为E本身是持续增长的，所以F也会被设计成单增的。
		- 由Watermark的意义是估计一个当前处理序列的EventTime，系统会认为下一条消息的ET应该就是估计的ET。或者说当前系统认为现在就是$$E_{reasoning}$$时刻。
		- 也就是说，当窗口结束时间等于$$ E_{reasoning} $$时，系统可以认为这个窗口没有剩余消息，是时候产出Pane并清理窗口状态了。
		- 与Trigger的差异：二者目标不同；可以说部分Trigger会利用Watermark
	- **Perfect Watermarks / 完美水印**：一种绝对保证没有迟到消息的水印
		- 本质上需要保证上游提供的数据都是有序的，或系统可以构造出绝对顺序的输入，于是可以使用最新数据的EventTime做Watermark
		- 另外如果要考虑低延迟，那么Skew还必须够低
	- **Heuristic Watermarks / 启发式水印**：除了理想的完美水印外，通常会用启发式思想估计EventTime
		- 启发式就是用到任何可以使用的信息
	- **Watermark的缺陷**：需要在latency和completeness上做权衡
		- **水印过高**：放慢了Pane产出时间和GC时间，于是提高了时延
		- **水印过低**：加快了Pane产出时间和GC时间，但会错失一些消息，于是打破了正确性
- **Early/On-Time/Late Triggers**：结合两种Trigger，通过指定Watermark前中后三个区间的pane产出策略，提供在一定的完整性估计下的低延时
	- **Early Panes**：降低延时，通过趋于正确的方式提供最终一致性
	- **On-time Pane**：一个特殊的pane，是一种窗口结束的“断言”
	- **Late Panes**：是trigger权衡的地方，是破坏完整性后的一种补偿
	- 建议Early和On-time选择使用延时触发器，Late选择次数触发器。这样能够在正常情况下提供一定完整性保证和平滑负载，同时能尽快响应迟到消息做补偿
- **Allowed Lateness & Garbage Collection**：在规定期限内保留Window状态，过期则清理
	- **Allowed Lateness**：一个允许Window保留时间的值。当$$  E_{window~end} + L < E_{reasoning} $$时，开始清理窗口。
		- 为什么选择使用Watermark计算出的$$ E_{reasoning} $$计算，而不是使用处理时间？
		  因为$$ E_{reasoning} $$时间是与管道绑定的，如果某个瞬间上游信道发生延时，此时使用processing time就会比event time更快清理掉窗口状态。所以无论管道中的Skew有多大，系统都应该按照event time来做回收（即使是估计的）。我们希望去除这个Skew，才选择event time。
	- **Watermark & Garbage Collection**
		- [Watermarks in Stream Processing Systems: Semantics and Comparative Analysis of Apache Flink and Google Cloud Dataflow](https://vldb.org/pvldb/vol14/p3135-begoli.pdf)
		- TODO 什么是Spark Streaming的High watermark？与Low watermark有什么区别？

## How：物化结果之间如何影响
- **Accumulation**：指新产生的window pane如何更新旧的window state
	- **Discarding / 丢弃或替换**：将新pane值直接替换旧值
	- **Accumulating / 累积**：使用某种用户指定的accumulator做累加
	- **Accumulating and retracting / 累积并撤销**：做累加后再附上旧值的逆
		- 附上旧值逆的意义在于能够反应替换动作，或体现在所有accumation累加后的值等于最终值

# Chapter3. Watermark

- **Watermark是什么**：一个EventTime的值，指明流水线中此处此时，保证没有更小的EventTime的消息到来
  
  - **完整性**：可以判断窗口是否应该关闭
  - **可观测性**：可以通过watermark走势观察数据源的问题
- **Watermark的定义**：水印是尚未完成的最旧工作的单调递增时间戳
  
  - ![watermark-def](/static/image/2023-06-19/watermark-def.png)

## Watermark的生成
- **Perfect Watermark Creation**：完美水印创建需要对输入有绝对的了解，对于许多现实世界的分布式输入源来说是不切实际的
	- **Ingress Timestamping / 入口时间**：认为入口时间就是事件时间，单一数据源保证了EventTime不乱序且没有Skew
		- 直接使用最新消息的时间戳作为Watermark即可
		- **问题**：使用入口时间做事件时间，是假设场景中没有多信道带来的时间偏移和乱序问题，往往会导致计算不正确。如用Fixed Window计算用户单位时间操作数，可能由于延迟导致计算出凌晨用户操作最多的类似问题。
		- 是2016 年之前几乎所有支持窗口化的流处理系统使用的方法
	- **Static sets of time-ordered logs / 全局有序的日志**：例如Kafka静态分区带有排序功能，能够保证不乱序
		- 直接使用最新消息的时间戳作为Watermark即可
		- **问题**：全局意味着有界，排序意味着高延时，那这样就变成批处理了不是么
- **Heuristic Watermark Creation**：通过利用输入数据源的特征可以构建高度准确的启发式水印
	- **设计原则**：
		- 活跃在线的用户可能是最相关的用户子集，因此近似的结果通常并不像想象的那么糟糕
		- 对源的了解越多，启发式水印的效果越好，看到的延迟数据项就越少。所以没有万金油的解决方案。
	- **Dynamic sets of time-ordered logs / 局部有序的日志**：部分有序，每个部分应该可以有时间重叠
		- 通过跟踪日志文件中未处理数据的最小事件时间、增长速度、网络拓扑和带宽可用性等外部信息，可以构建准确的Watermark
		- 在Google内部是最场景的一种无界数据集
	- **Google Cloud Pub/Sub的场景**：不保证按顺序交付；即使单个发布者按顺序发布两条消息，也有可能被乱序传递（小概率）
		- TODO ==总结一下如何做到的==

## Watermark的传递
- **Watermark的流程**：
	- 很多流数据处理系统都将执行过程实现为多个Stage：如Flink中的Operator、Beam中定义的Collection阶段等（如果没理解错的话）。
	- Watermark的生命周期（如果可以这样说的话）是从输入源开始生成，再传递到各个Stage中的。
	- 注意，在某时刻各个Stage中的Watermark肯定是按顺序递减的。
- **Watermark的粒度**：一般每个Stage都有一个InputWatermark和OutputWatermark，
	- **Input Watermark**：捕获上游所有进度（即该阶段的输入完成程度）
		- **目的**：统计多个上游pipeline和多上游分片的watermark，做该阶段的Window完整性触发和回收
		- 对于源，输入水印是为输入数据创建水印的特定于源的函数。
		- 对于非源阶段，输入水印被定义为其所有上游源和阶段的所有分片的输出水印的最小值。
			- **为什么取最小值**：是为了做保守估计，让该阶段认为窗口还会接受更多数据，不至于被提前关闭，导致更多的迟到数据。
	- **Output Watermark**：捕获阶段本身的进度
		- **目的**：为下一个阶段计算该阶段的事件时间的处理延迟。
		- 定义为Input Watermark和阶段内所有非延迟的活动消息的EventTime的最小值。
			- “活动”究竟包含什么在某种程度上取决于给定阶段实际执行的操作，以及流处理系统的实现。它通常包括为聚合而缓冲但尚未在下游具体化的数据、正在流向下游阶段的待处理输出数据等。
			- ![OutputWatermark.drawio (1).png](../assets/OutputWatermark.drawio_(1)_1686556423886_0.png)
			- **为什么要取最小值**：体现了上游完整性一致（指取InputWatermark为最小值）和统计本阶段事件时间的处理时延（指取非延迟活动消息为最小值）
			- **为什么要取InputWatermark做最小值**：这样做是假定该阶段能够以趋近于0的时延来处理消息。如果不取InputWatermark计算最小值，就可能会导致非延迟活动消息EventTime比input watermark更大。这样就违反了后续Watermark比先前的要小的原则，会让系统看起来很奇怪（就好像这个阶段处理时延是负数，让上游和本阶段输出的完整性保证不一致了，比如上游保证小于10的消息不会再出现，而本阶段又保证小于20的消息不会出现）。
	- **更细粒度的Watermark**：例如文中的state组件水印、buffer水印等。估计不太会有如此细粒度的实现吧。
	- **可观测性**：我们可以通过Output Watermark减去Input Watermark得到该阶段的事件时间延迟量
- **Watermark传递与输出时间戳**：在pipeline中，输出时间戳会影响到Watermark的大小并且影响到下游计算结果
	- 这里讨论的是做Window的Stage产生的结果的EventTime时间戳如何确定，有一个原则和三种常见选择。
		- **原则**：Input Watermark <= First Nonlate Element in Window <= Output Timestamp < ∞
		- **窗口末尾**：让输出时间戳代表窗口边界，是三种选择中让Output Watermark最为平滑的方案。
			- （按理说取越大的时间就能获得约平滑的Watermark，因为会趋向于Watarmark）
		- **首个非延迟元素的EventTime**：是让Watermark最保守的方案。
			- output watermark随着输出EventTime的提前而变小，承诺有更少的数据会准时到达，让下一个阶段触发产生Pane和回收时间也变得更晚（也就是说让下游Window Ending Time == Input Watermark的耗时更久），所以说变得更保守。
		- **某个元素的EventTime**：往往是业务上的考虑，例如对用户点击和用户请求做Inner Join时，输出会使用用户点击的EventTime。
	- **输出时间如何影响下游**
	  使用窗口末尾的情况：
		![](http://streamingsystems.net/static/images/figures/stsy_0307.png)
		使用首个非延迟元素的情况：
		![](http://streamingsystems.net/static/images/figures/stsy_0308.png){:height 544, :width 718}
		- **Watermark延迟**：可以发现后者的水印延迟更高（水印曲线与前者相比更靠左），所以下游的窗口结束耗时也更长一些。
		- **语义差别**：明显看出后者的计算结果与前者不一样，因为输出结果不会在同一个窗口中了。
	- **滑动窗口的问题**
		- 这里的意思是，使用相同滑动窗口配置的两个Stage中，使用最早不迟到元素作为output ts。上游发送的前两个Window的输出都不会改变下游的Input Watermark。于是下游的三个窗口都在等水印到window ending time。一旦上游的下一个窗口结束，那么下游的input watermark到第三个窗口的ending time，那么就一块发送出去了。
- **百分比水印**：我们可以考虑活动消息的事件时间戳的整个分布，并利用它来创建有关“mostly”的触发条件
  
	- 百分位数水印提供了一种调整物化结果延迟和结果精度之间权衡的方法
	- 这样能使得触发变得更快（因为水印提高了）并且更平滑（减少了降低水印的极端数据的出现）
	- ![percentage-watermark](/static/image/2023-06-19/percentage-watermark.png)
	- **问题**：百分比Watermark是怎么实现的？我怎么知道一个窗口中的百分比数量对应多大水印？
		- 一个朴素的想法是：$$ x\%Watermark = x\% * (Watermark - TrueEventTime) $$，但是TrueEventTime本身就是不可知的。
- **处理时间水印**：针对系统中计算操作的水印，目的是提供更全面的可观测性
	- 定义：与事件时间水印相似，使用窗口中尚未完成的最早**操作**的处理时间戳。
		- 例如阶段间消息传递卡住、I/O 调用卡住，或者触发异常导致处理时间卡住
	- 例子：
		- 处理时间水印一直卡在同一个值上，所以肯定是系统哪个操作卡住了
		  ![](http://streamingsystems.net/static/images/figures/stsy_0313.png)
		- 处理时间水印一直在变化，但是事件时间水印卡住。肯定是在处理Window中囤积的数据，而且这个Window还没到关闭时间。
		  ![](http://streamingsystems.net/static/images/figures/stsy_0314.png)
		- 处理时间水印一直在变化，事件时间水印呈现锯齿状。肯定是不断处理Window中囤积的数据，而且这些Window Pane还在正常输出。
		- ![](http://streamingsystems.net/static/images/figures/stsy_0315.png)
	- 另外，后文会讨论处理时间水印能够在状态垃圾回收上有效果。

## Case Study
- **Google Cloud Dataflow**：按照Key来进行Stream的范围分片。一旦做group的时候如果key和分区键不同，那就会做shuffle的数据传输。
	- 所以shuffle场景下的watermark传递需要做到覆盖所有上游分片，以及保证水印单增
		- 即Next Watermark = min(Current Watermark, Input Watermark\#1, ...)。
- **Apache Flink**
	- TODO ==了解下Flink、SparkStreaming的实现==

# Chapter4. Advanced Windowing

## Processing-Time Windows
- **场景**：对于某些用例，例如流量监控（例如，Web 服务流量 QPS），你希望分析传入的数据流，处理时间窗口是合适的方法。
	- 另外，很多引擎的默认窗口策略就是processing-time windows，可以做到计算结果不显示window的开始和结束event time。
- **实现**：
	- **via Triggers**：使用触发器在处理时间轴上提供该窗口的快照
	- **via Ingress time**：将先前的所有给予EventTime的window方法替换为入口时间
	- **二者区别**
		- 在单个Stage中，二者计算结果相同（因为trigger是隔两分钟产出一次，后者因为用到prefect watermark同时x==y所以也是两分钟一个Pane）
		- 二者在不同Stage下的数据，前者会不再同一个window里（因为后面processing time会变？），后者一定在同一个window里（因为event time不便）
		- 后者会用到更多倍的窗口，意味着需要存很多倍的state

## Session Windows
- **场景**：按某个ID做grouping，例如按用户会话和IP地址等，便于数据分析的动态的数据驱动窗口
	- **数据驱动**：窗口的大小和开始时间都是由数据改变的，数据不变窗口计算结果不变。
	- **非对齐窗口**：与Tumbling Window和Sliding Window相反，Session Window是按照数据子集做group的
- **实现**：需要考虑乱序到达的情况，同时涉及merge操作
	- 小思考：Window里只要记录pane的左上角右下角坐标就行，这样Window合并就比较轻松。顺便可以设计成数据都放在window里作为vector，pane里带一个索引也行。

## Custom Windowing
- **场景**：这是一种Beam自创的方案，通过抽象两个窗口逻辑，让用户可以创建自定义窗口，用于应对复杂的具体业务场景
- **实现 / 抽象**
	- **Window Assignment**：通过到来元素来创建window的逻辑。AssignContext -> Collection<Window>的函数。
	- **Window Merging**：通过window的创建来合并现有的window。MergeWindow -> void 的函数。
- **例子**
	- **Unaligned Fixed Windows / 非对齐的固定窗口**
		- **目标**：Fixed Window会共用同样的watermark，这样每个key的window发出pane都是同时的，同时触发成千上万Pane会导致问题。
		- **实现**：通过按key hash后的大小对window starttime做平移，使得不同key的触发时间不同，让Pane产出的负载更平滑。
		- ![unaligned-fixed-windows](/static/image/2023-06-19/unaligned-fixed-windows.png)
	- **Per-key Fixed Window / 按Key固定窗口**
		- **目标**：让不同的数据使用不同大小的窗口
		- **实现**：直接在assignWindow函数里给定大小即可
		- ![perkey-fixed-window](/static/image/2023-06-19/perkey-fixed-window.png)
	- **Bounded Session Window / 有限大小的会话窗口**
		- **目标**：给Session Window大小做最大限制，包括时长、元素个数等
		- **实现**：在mergeWindows的时候，按照大小限制不做merge即可
		- ![bounded-session-window](/static/image/2023-06-19/bounded-session-window.png)

# Chapter5. Exactly-once

## Definitions
- 流处理系统的保证：
	- **Best effort**：也就是没有保证
	- **At-least-once**：确保记录始终至少处理一次，但记录可能会重复
		- 许多这种系统会在内存中做聚合计算，宕机后聚合数据仍然可能丢失。所以这些系统的使用场景往往用于**低延迟、推测性、不保证准确的结果**
		- 提供这样的保证催生除了Lambda架构的策略
	- **Exactly-once**：确保每条记录都被恰好处理一次
- **Accuracy / 正确性**：指任何记录不会遗漏和重复计算
	- 与Completeness完整性不同，完整性要求Window保证包含所有该事件时间范围的数据都到达后，再触发Pane做计算。
	- 另外，之前也说过，批处理系统也会出现完整性问题。如某时刻A触发做批处理，但早于A的数据b没有按时到达，导致计算有误。一个简单方法是在时刻B做B-x的数据集批处理。

## Exactly-once (in Dataflow)
- 由于Dataflow提供了Fusion优化，所以pipeline中应该只有source、fusion、shuffle和sink。文中没有提到fusion是如何保证exactly-once，我猜单纯就是日志+状态存储。
- **Shuffle**
  - **防止丢失**：Dataflow实现了**上游备份**，即没有接受到下游的确认时上游会重试 RPC。
		- Dataflow还确保即使上游崩溃，重启后也会尝试重试。
	- **保证幂等**：通过上游发送带有唯一ID的消息，同时下游存储`map<Key, vector<ID>>`来做查重。（具体而言是kv存储）
		- **对抗非确定性**：一些用户自定义操作是非确定的，每次计算的结果都会变化，包括随机数、当前时间、与外界通信等。Dataflow的做法是对计算做一个ID，将其结果checkpoint持久化。在计算前都要检查是否已经计算过，如果是那么直接发送持久化结果即可。
		- 要注意的是，上述两种设计是发生在不同的地方。前者是处理上游数据时，后者是触发计算时。
		- **性能**：需要减少每次接收数据都要查一次ID保证幂等的开销
			- **Fusion Optimization**：将多个步骤转化成一个步骤。节省IDs的存储和查询开销，也节省了中间结果的具现化。
			- **Combiner Lifting**：在做聚合前，让每个分片先自己处理本地数据再做全局聚合。
			- **Bloom Filter**：提供快速查询
				- 然而，布隆过滤器往往会随着时间的推移而填满，误报率会增加。
				- **Timestamp-based  Bloom Filter**：Dataflow把布隆过滤器按固定时段分成多份，又给每个记录附上系统时间戳。下游可以按照时间戳索引到一个filter。
				- 另外，这种设计也可以按时回收整个filter；可以启动时懒加载；可以按id range做优化。
				- 也需要注意上游的时间戳需要严格递增，即使宕机重启。（一个简单的想法是加一个time shift）
		- **总结**：
			- 为了做幂等，一个消息会额外存什么？
				- ID：为了下游的幂等性，因为上游可能会重发N次同样的消息。因为可能存在网络故障，丢包超时之类的。
				- TS：为了做bloom filter的平滑，或者说限制饱和度
			- 什么时候可以清理ID和TS？
				- 上游保证永远也不会重发该消息，即上游确认了下游正确获得到了数据。
			- 为什么不用TCP做幂等？
				- 因为TCP没有办法贴合业务逻辑，没法重启后从持久化的数据里继续发送数据。
		- **垃圾回收**：指回收做幂等的IDs catalog
			- **sequnce number**：一个简单方式是按递增的ID作为序列号。一旦上游给出承诺说小于xxx ID的数据不会再重发了，那么下游就可以清理掉了。
			- **watermark**：Dataflow用的是这种方式，通过计算系统时间做watermark（即第三章的processing-time watermark），针对TS字段做回收。优点是可以附带做阶段lag的可观测。
			- **network remnants / 网络残余问题**：一个早于watermark的数据由于网络延迟而到来，此时系统watermark已经保证该数据处理过，且已被回收，所以直接丢弃它。
- **Source**：如果处理失败，则重试从源读取
  - 一些简单的源：如果源是文件，就直接offset & size确定读入的位置；Kafka则提供了static partition
	- 一些复杂的源：如Google Cloud Pub/Sub提供根据ID找数据（似乎是这样？），或者本地做一个Buffer来存
- **Sink**：Sink是一种副作用，Dataflow不保证副作用的Exactly once
	- **内建SDK**：对各种语言实现内建SDK，可以自己保证幂等。
	- **下游保证幂等**：最好的方式还是用户自己保证幂等，例如带ID的写入数据库

## Case Study
- **Spark Streaming**：checkpoint
	- Spark 假设所有操作都是幂等的，并且可能会重放图中当前点的操作链。但也实现了checkpoint，目的是保证不会重放历史记录导致昂贵的重放
- **Flink**：周期性地计算一致性快照，每个快照代表整个 pipeline 的一致时间点状态。 Flink 快照是渐进式计算的，因此无需在计算快照时停止所有处理
	- Flink将快照标记跟数据一样，放在数据流中来实现这些快照。当operator收到快照标记时，会做一次checkpoint并传播标记给下游。当所有operator执行完此快照算法后，完整的快照就被产出了。
	- 至于正在发送的数据，Flink用了某种基于TCP的方式，能够在链接失败后恢复最后的seq number。
		- TODO 看看究竟是怎么做的
	- 向 Flink 管道外部世界发送数据的接收器**必须等到快照完成**，然后仅发送包含在该快照中的数据。因为这保证了Sink时的状态一定能恢复到。
		- 但对于幂等的下游，可以不用等快照完成就发送结果。因为恢复到先前状态，发送的duplicated数据会被幂等性丢掉。
		- 虽然这里引入了延迟，但比Spark这种每个阶段都有延迟的系统还是好了不少

## Refs

- [部署 Dataflow 流水线  |  Google Cloud](https://cloud.google.com/dataflow/docs/guides/deploying-a-pipeline?hl=zh-cn#job-optimizations)
  [流水线生命周期  |  Cloud Dataflow  |  Google Cloud](https://cloud.google.com/dataflow/docs/pipeline-lifecycle?hl=zh-cn#fusion_optimization)
  - **Fusion Optimization / 融合优化**
  	- 流水线执行图中的多个步骤或转换融合为单一步骤。通过将多个步骤融合在一起，Dataflow 服务就无需一一具体化流水线中的所有中间 `PCollection`，从而可以节省大量内存和处理方面的开销。
  	- 这些转换可能以不同的顺序执行，或者它们可能作为一个较大融合式转换的一部分执行，以便确保最有效地执行您的流水线。Dataflow 服务遵循执行图中各步骤之间的数据依赖关系，但其他步骤可以按任意顺序执行。
  	- **目标**：节省中间结果的具现化；节省Exactly-once的结果存储
  - **Combine Optimization / 组合优化**：**Combine Lifting**
  	- 汇总/组合是指将概念上相距甚远的数据汇集在一起，如：GroupByKey等
  	- 在此类汇总操作期间，通常最有效的做法是先尽可能多地组合本地数据，然后再组合各实例中的数据。当您应用 `GroupByKey` 或其他汇总转换时，Dataflow 服务会在进行主分组操作之前，自动在本地组合部分内容。
  	- **目标**：节省汇聚时各个Worker的传输内容
  - **Parallel and Distribution / 并行和分布**：为key自动做range分片
  	- **目标**：尽量降低开销的并行处理
  - 其他优化：
  	- **自动扩缩**：横向、纵向、负载平衡
  	- **VM优化**：StreamingEngine移出VM、调度&抢占式VM、安全强化的VM
- [Streaming Engine: Execution Model for Highly-Scalable, Low-Latency Data Processing | by Slava Chernyak | Google Cloud - Community | Medium](https://medium.com/google-cloud/streaming-engine-execution-model-1eb2eef69a8e)



# Chapter6. Streams and Tables

- 本章旨在描述流和表之间的关系，并以MapReduce为例描述了流表之间的如何转换，最后从What、Where、When、How的角度分析了流表转换的原理（被作者成为流表的广义相对论）

## General Theory of Stream and Table Relativity / 流表广义相对论


- 数据处理流实现包括流、表以及在流表上运作的算子
- **Table**：表是静态数据的容器，代表pipeline里某时刻某算子的全局数据快照，可随着时间的推移积累数据
- **Stream**：流是动态数据的载体，传输局部数据的变化，是表的change log
- **Operator**：算子运作在流表上，持续产出流或表形式的数据
	- **Stream -> Stream： Nongrouping / 非分组操作**
		- 修改流中的数据，从而产生可能不同数据量的新流
		- 类似filter、map（或mutator）、flatMap（或exploder）等。
	- **Stream -> Table：Grouping / 成组操作**
		- 暂存流中的数据，产生按时间推移而改变的表
		- 类似Windowing（按EventTime成组）、Join、聚合、list/set的accumulate、ML模型训练等
	- **Table -> Stream：Ungrouping / 解组操作**
		- Trigger捕捉表随时间的变化，从而产生流
		- Watermark定义了完整性Trigger的触发时机；累积方式定义了产出流的数据内容

## 执行计划

- 流数据处理系统也存在着逻辑执行计划和物理执行计划。前者是用户定义的流处理行为，后者定义了如何使用引擎提供的原语贴合用户期望的行为。
- ![image.png](../assets/image_1687145488852_0.png)

# Chapter7. Persistent State

- 本章内容主要讨论持久化状态为什么重要，以及讨论了两种隐式状态的算子，最后描述了Beam提出的显示状态框架的用法。
- Q：为什么持久化状态很重要？
  - 正确性：要实现Exactly-once，需要保证任何时间上游都有能力重发消息（即使是宕机恢复后）。
  - 容错性：为算子提供故障恢复能力

## 隐式状态

- **Raw Grouping**：每当一个新元素到达该组时，它就会被附加到该组的元素列表中；即存储该窗口的所有输入，而不是每个窗口一个整数
  
	- 示例：[Figure 7-1: Streaming Systems Book](http://streamingsystems.net/fig/7-1)。
		- 需要注意这里GROUP应该是[5,9] [7,3,8] [4] [3,8,1]图画错了。
		- 见[Unconfirmed Errata - O'Reilly Media](https://www.oreilly.com/catalog/errataunconfirmed.csp?isbn=0636920073994)的第四条
- **Incremental Combining**：Beam定义了一套满足交换律结合律的算子框架（可以认为是阿贝尔群，数学上类似加法，工程上类似函数式的Reducer），能做到压缩存储和乱序计算的目的。于是在这套框架上提出了两种用户透明的优化方式。
  
	- **Incrementalization / 增量化**
		- 计算不依赖顺序，意味着不需要排序（用buffer定期排序等做法）就能计算
		- 存储空间减少到O(1)，不需要做buffer
		- 计算复杂度减少到O(1)，不用做O(n)的重复计算
	- **Parallelization / 并行化**
		- 是MapReduce的核心优化方式，即用大量节点做巨量计算
	- 利用阿贝尔群做计算还存在一个好处：当两个窗口合并时，对于Raw Grouping，意味着将缓冲值的两个完整列表合并在一起，其成本为 O(N)。但对于CombineFn，它是两个部分聚合的简单组合，通常是 O(1) 操作
		- 一个想法：是不是能做pull up？

## 自定义状态

- 大多数隐式状态缺乏**灵活性**：
	- 自定义**状态数据结构**
	- 自定义**读写状态粒度**：其实是自定义每个元素到来的业务逻辑，同时还可以访问某些特定状态字段。
		- 我认为除非可以不去读取状态，否则跟直接读取所有状态是一个效率
	- 自定义**触发时机和触发逻辑**：指自定义Trigger以及给下游发送结果的逻辑
- 后文展示了如何通过Beam定义一个略复杂的广告归因场景，能够体现Bean自定义状态的灵活性。
- 这里我反思一下我在ddb的算子状态框架的设计
	- **自定义数据结构**：提供protobuf + FieldMixin来定义。用户新建一个state的话只能在protobuf里写一个类型，然后在代码里做FieldMixin。而且没法定义函数。
	  感觉应该能从StateSpec这种设计里找到更好的方式。比如实现一个基类用于提供派生类的StateSpec的snapshot和restore方法就可以从StateStore里编码解码数据。另外考虑到需要提供optional等protobuf的描述符，应该要实现OptionalStateSpec或者提供某种OptionType `StateSpec<T, Optional>`等。
	  最核心的两个问题是，如何在保证效率的情况下动态生成protobuf的message类型并做成员变量的绑定，并且基类的snapshot等方法可以发现子类的StateSpec成员变量。
	- **读写粒度**：目前设计里只有Block或整个算子的粒度。我认为效率相差不大，只在做与不做的效率区别。
	- **触发时机**：这一点我不懂了，ddb的trigger似乎就是那个函数。逻辑是遇到相同key的时候发起一次engine层面的计算。相当之简陋，还有window只能做算子层面的window。灵活性和组合性（两个窗口算子搭配在一起的逻辑就不对）都很差。
	- 另外，Beam 做了processElement和onTimer的逻辑区分。我认为确实应该，因为前者处理哪些元素落盘，后者定义复杂的trigger。ddb由于没有复杂trigger，所以可以在processElement那里直接输出null。（但其实ddb的做法是每一条都处理，没有trigger或者说宏观上是afterCount(1)的trigger）
	- 还有，前文提到了垃圾回收和

# Chapter8. Streaming SQL

- 本章是在讨论一个理想的流式SQL应该是怎么样的。

## 什么是流式SQL

- **关系代数**：SQL的理论依据，其核心是由一组tuple组成的“关系”。
	- 闭包属性：对任何一个表做任意操作都会得出一个表
	- 先前的一些流式SQL失败的原因是没有满足闭包属性。他们认为流是独立与表的存在，于是提出了许多针对流的新算子。
- **时变关系 TVR**：融合流与SQL的关键是扩展“关系”来展示一段时间内的数据变化，称之为时变关系TVR
	- 关系反应了数据在某时刻的内容，时变关系表示了数据在一段时间内的内容
	- 定义时变关系能够满足：使用现有SQL大部分算子，并且满足闭包属性
	- ![TVR](https://pic3.zhimg.com/80/v2-d1b8918895a9f8d40f7aafd2f9d7ea16_720w.webp)
- **流与表**：表捕获了某时刻的数据，流体现了某时段的变化。
	- 表：另外，SQL2011本身支持了所谓temporal tables（时态表），语法是`AS OF SYSTEM TIME '12:07'`
		- ![](https://pic1.zhimg.com/80/v2-913bcb3d1bb36b6332273f412b5d52fc_720w.webp)
	- 流：为了支持流的特性，作者给了一个特殊的关系Sys，提供额外的有关流的属性。例如`Sys.Undo`列。
		- ![](https://pic2.zhimg.com/80/v2-b02e878aa87f22fd037dd2ace8257719_720w.webp)
- 上述三种说法在某种程度上我认为就是渲染方式不同而已

## 回顾过去：流与表

- **流处理系统的视角：以流为中心**
	- 流处理系统偏向使用流来实现pipeline，即在算子之间往往用stream连接。
	- 表的使用往往被隐藏作为算子内部的逻辑，而且只有在被触发时才会输出流。
	- ![](http://www.streamingbook.net/static/images/figures/stsy_0801.png)
- **SQL系统的视角：以表为中心**
	- SQL 历来采用表偏方法，即查询应用于表，并始终生成新表。另外，也存在隐式表的。
	- 而内部executor之间连接方式被认为是一种隐藏的流的体现。无论是volcano模型还是vector模型。
	- ![](http://www.streamingbook.net/static/images/figures/stsy_0804.png)
- **Materialized View / 物化视图**：一种支持流处理的方式，通过跟踪表的演变持续保持最新视图的方式。
	- 物化视图的一种实现方式是通过SCAN-AND-STREAM的算子，获得输入表的变更，从而产生无限流。这样能够在以表为中心的SQL系统中体现流的特性。
	- 另一种实现方式则是当查询视图时实际做一次查询，那就与流无关了。作者在这里只是想体现流可以以视图为载体来呈现。
	- ![2023-06-27_10-35.png](../assets/2023-06-27_10-35_1687833321737_0.png)
	- ![](http://www.streamingbook.net/static/images/figures/stsy_0805.png)

## 展望未来：Robust Streaming SQL

- 我们已经看到，通过以时变关系来替换时间点关系就可以保持关系代数的闭包属性，能够达到使用所有关系运算符的目的。
- 但仍需要在SQL上体现一套流处理系统的概念，即What、Where、When、How。
- **流表的选择**：提供一种输出流还是表的默认选项
	- 如果存在任意输入是流，则输出是流，其他情况则输出表。
- **Temporal Operators / 时间运算符**：提供流处理系统中有关时间的算子
  
	- **Where - 窗口**：实现一些特殊的函数就可以解决
		- ![](https://pic1.zhimg.com/80/v2-fca72c38c251e9f00d3fb66de09d1a44_720w.webp)
	- **When - 触发器**：
		- Per-record Trigger：默认支持的trigger，具有简单保真的特性
		- Watermark Trigger：实现特殊的语法体现watermark超过什么数据后，以及针对什么程度的迟到数据提交
			- ![](https://pic1.zhimg.com/80/v2-9d18de014dd227713bbfc9d4942b8bfc_720w.webp)
		- Repeated Delay Triggers：与上面类似的实现方式，对应了原有的`UnalignedDelay(ONE_MINUTE)`
			- ![](https://pic1.zhimg.com/80/v2-21ba1ab740c0f460842f0e5185a00d84_720w.webp)
	- **How - 累加器**：利用`Sys.Undo`来体现撤回。针对窗口上的改变，譬如会话窗口可能会变长，这里采用的语义上的策略是直接撤销整个会话，再创建一个新的会话。
		- ![](https://pic4.zhimg.com/80/v2-a3f7600f6998ee80420624e76f7cc357_720w.webp)

# Chapter9. Streaming Joins

## 背景知识

- 这里介绍一下Join的种类。看似有很多种类型，但它们都是Full Outer Join的变体。ANSI SQL不包括semi和anti，它们似乎只是利用Join来设计exists表达式的。
	- **OUTER JOIN**：保留左右表的全部行，如果左右表的某一行没有匹配，那么输出的对方保留NULL。一个例子是`L outer join R on L.id = R.id`
	- **LEFT (OUTER) JOIN**：保留左表的全部行，如果左表某个行没有对应的右表行，那么输出的右表内容保留NULL。相当于`L outer join R on L.id = R.id and L.id != NULL`
	- **INNER JOIN**：只输出匹配行。相当于`L outer join R on L.id = R.id and L.id != NULL and R.id != NULL`
	- **CROSS JOIN**：笛卡尔积。相当于不设置join条件的`L outer join R`。
	- **SEMI JOIN**：用于实现in / exists的一种join。当左表行匹配了一次或多次右表行后，只输出一次左表行。属于inner join的变体，由特殊的in或者exists表达式实现，所以没有类似的OUTER JOIN的例子。例如`where L.id in (select id from R)`
	  id:: 649a5844-8ffa-40e5-8eca-890ec24f8bce
	- **ANTI JOIN**：inner join的在outer join上的补集，即只保留任意一边为NULL的行，相当于`L outer join R on L.id == R.id and L.id == NULL or R.id == NULL`。主要配合semi来实现not in或者not exists
- **所有的Join都是流**：Join只是一种特殊的分组操作
	- 通过将某些属性的数据连接在一起，将一些先前不相关的单个数据元素收集到一组相关元素中

## Unwindowed Joins

- **OUTER JOIN**：左右表都要buffer下来，二者的任意一个tuple到来就遍历对方的buffer，做join做输出
- **LEFT / INNER / ANTI JOIN**：只是在OUTER JOIN上加了一些过滤条件而已
- **SEMI JOIN**：当一个左表行存在多个右表匹配的行时，只输出这个左表行一次（注意不输出右表行，其实多个右表行也没法输出在一个row里）。文中的基数n:m，意思是多少个不同的左表行（m）匹配多少个不同的右表行（m）

## Windowed Joins

- **为什么要对Join做window / window的作用是什么？**
	- **业务要求**：例如每日账单统计。每到凌晨两点时清理join两边的表，重新开始一个周期的统计。
	- **超时参考**：inner join要求每当匹配成功时就输出结果行，outer join则是不匹配时也输出结果行。在流处理系统里要永远记得，数据不是准时到达的，于是**很难识别数据的不存在**（相对于存在性的概念，当A不存在时不能认为真的不存在。而不是存在性，当A存在时不认为存在。有点像bloom filter）。当目前右表没有对应行时，不能认为不存在。
	- 这两点也就是window的作用，后文也提到窗口化不是流处理的必要要求。
- **Fixed Window**
	- 作者提出将Join条件扩展到窗口相等性的实现方法：`Left.Num = Right.Num AND Left.Window = Right.Window`
	- 由于判断的是各自窗口相等性，那么输出的结果也因此与没有Window的结果不同。在这个例子里，即只有两个行在一个window里才能join匹配，窗口完整性判断与结果正确性没有关系。意思是相比全局的outer join，这里的窗口化要求两个数据都在一个window里。
	- ![](https://pic3.zhimg.com/80/v2-70916392cd4b0f13dec8588826cfa792_720w.webp)
	- ![](https://pic2.zhimg.com/80/v2-05fe258769598d98b6a0793c28022355_720w.webp)
	- 另外，如果上游保证两个数据会在一定期限内发生，那么fixed window有点不匹配这个场景。比如推荐系统中，一个数据流包含用户行为数据，另一个数据流包含商品数据。我要统计购买商品的前后一段时间内（前后5分钟）用户行为数据。
	- 所以可能的实现方式是，当购买数据到达后，创建一个window。等到行为数据的watermark到达window ending时，做Goods left outer join Behaviors。这里的想法是一个流单方面做window，而且是非对齐的前后的窗口。除了单方面创建window，与前文章节不同的是，这里还要考虑前后时间间隔的window（前文用window merge实现，而这里是不同的流之间）。
	- 最后提一下，这个在国内似乎叫双流join，指两个数据流的动态连接。另外，这个例子也体现了window能满足的两个需求。
- **Temporal Validity Window / 时间有效性窗口**
	- 有效性窗口必须能够随着时间的推移而缩小，从而缩小其有效性的范围，并将其中包含的任何数据拆分到两个新窗口中。
	- 这里的意思是窗口随数据到来而拆分和变小的过程。
	- ![](https://pic3.zhimg.com/80/v2-d12ce88006bddd086cf047d7e4ac2c4e_720w.webp)
	- 一个时间有效性窗口和连接的例子
		- ![](https://pic1.zhimg.com/80/v2-a5f35e5b65f534ef14be263be7c6bb68_720w.webp)
- 一个带有watermark的时间有效性窗口的例子
	- ![](https://pic1.zhimg.com/80/v2-d317dfa2660470dcc8e0fcc590af5f84_720w.webp)

# Chapter10. The Evolution of Large-Scale Data Processing

- 本章主要讲解大数据的历史：从03年的MR到现今的流处理系统

- ![](http://www.streamingbook.net/static/images/figures/stsy_1034.png)

- **2003 MapReduce**：简易性和可扩展性

  - **起源**：Google内部有多个不同的大数据场景的解决方案。他们意识到可以提供一套框架，从而解决**扩展性**和**容错性**的挑战。
  	- ![](http://www.streamingbook.net/static/images/figures/stsy_1003.png)
  - **资料**：在2004年发布OSDI paper，但由于没有开源，所以大部分人就只是扩展自己的系统
  	- [MapReduce: Simplified Data Processing on Large Clusters](https://static.googleusercontent.com/media/research.google.com/en//archive/mapreduce-osdi04.pdf)
  - **贡献**：MR是在大规模数据处理世界中的第一个可定制的系统

- **2005 Hadoop**：开辟繁荣的开源社区
  - **起源**：Doug Cutting 和 Mike Cafarella为实现分布式网络爬虫，在NDFS（后称HDFS）上加入了MapReduce层
  - **资料**：[The history of Hadoop. An epic story about a passionate, yet… | by Marko Bonaci | Medium](https://medium.com/@markobonaci/the-history-of-hadoop-68984a11704)
  - **贡献**：开创了开源社区的大数据繁荣生态，产生了数十种有用的工具，如 Pig、Hive、HBase、Crunch 等等。

- **2007 FlumeJava**：引入流水线和优化器
  - **起源**：动机是解决 MapReduce 的一些固有缺陷，包括多MR过程组成pipeline过于繁杂以及效率问题
  	- Flume 通过提供可组合的高级 API 来描述数据处理管道来解决这些问题。同时提出执行计划和优化器等概念，以实现最佳高效的 MapReduce 作业序列，然后由框架协调其执行。
  	- ![](http://www.streamingbook.net/static/images/figures/stsy_1010.png)
  	- 另外，优化器引出了两种最常见的优化方式：fusion和combiner lifting。
  		- Fusion：将两个阶段融合在一起可以消除序列化/反序列化和网络成本
  		- Combiner Lifting：可以大大减少通过网络洗牌的数据量，并且还可以将最终聚合的计算负载更平滑地分散到多台机器上
  - **资料**：
  	- 2009 [FlumeJava: Easy, Efficient Data-Parallel Pipelines](https://storage.googleapis.com/pub-tools-public-publication-data/pdf/35650.pdf)
  	- [No shard left behind: dynamic work rebalancing in Google Cloud Dataflow](https://cloud.google.com/blog/products/gcp/no-shard-left-behind-dynamic-work-rebalancing-in-google-cloud-dataflow)
  - **贡献**：

- **2011 Storm**：世界第一个真正意义上的流处理系统 - 低延迟与弱保证
  - **起源**：Nathan在Twitter的工作中遇到类似MR的经历，发现构建一个通用系统可以处理很多流式数据场景
  	- **降低一致性保证 & 降低时延**：通过将至多一次或至少一次语义与每条记录处理相结合，并且没有集成的（即，不一致的）持久状态概念，Storm 能够在提供结果时提供比在批量数据上执行的系统低得多的延迟，并且保证一次性正确性
  - **资料**：
  	- [History of Apache Storm and lessons learned - thoughts from the red planet - thoughts from the red planet](http://nathanmarz.com/blog/history-of-apache-storm-and-lessons-learned.html)
  	- [How to beat the CAP theorem - thoughts from the red planet - thoughts from the red planet](http://nathanmarz.com/blog/how-to-beat-the-cap-theorem.html)
  	- [[PDF] Twitter Heron: Stream Processing at Scale | Semantic Scholar](https://www.semanticscholar.org/paper/Twitter-Heron%3A-Stream-Processing-at-Scale-Kulkarni-Bhagat/e847c3ec130da57328db79a7fea794b07dbccdd9?p2df)
  - **贡献**：Storm 负责首先为大众带来低延迟数据处理。然而这样做的代价是弱一致性，进而带来了 Lambda 架构的兴起，以及随之而来的双流水线的黑暗时代

- **2009 Spark**：微批处理带来强一致性
  - **起源**：Spark 于 2009 年左右在加州大学伯克利分校现在著名的 AMPLab 诞生。
  	- **RDD**：Spark通常能够在内存中执行计算，直到最后才接触磁盘。这归功于RDD，该理念基本上捕获了管道中任何给定点的完整数据谱系，允许在机器故障时根据需要重新计算中间结果，前提是输入可重放，且计算是确定性的
  	- **Spark Streaming**：将流数据作为微批，一个接一个地做批处理执行的思路。
  		- 缺陷是1.x没有对处理时间做保证，并且会存在全局屏障
  - **文献**：[An Architecture for Fast and General Data Processing on Large Clusters](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2014/EECS-2014-12.pdf)
    id:: 649a9de9-e591-4d63-b3db-99097418a071
  - **贡献**：一个具有强一致性语义的公开可用的流处理引擎，尽管仅适用于有序数据或事件时间不可知的计算

- **2007 MillWheel**：乱序处理下的各种保证
  - **起源**：Google 原创的通用流处理架构。MillWheel 项目最初并不关注正确性。 Paul 最初的愿景更紧密地瞄准了 Storm 后来所倡导的利基市场：弱一致性的低延迟数据处理。正是最初的 MillWheel 客户，一个在搜索数据上构建会话，另一个对搜索查询执行异常检测（MillWheel 论文中的 Zeitgeist 示例），推动了该项目朝着正确的方向发展。两者都强烈需要一致的结果：会话用于推断用户行为，异常检测用于推断搜索查询的趋势；如果他们提供的数据不可靠，那么他们的效用就会显着下降。因此，MillWheel 的方向转向了强一致性
  	- **Exactly-once保证**
  	- **持久状态**
  	- **Watermark**：原本只是在异常检测的异常下跌实现时，用到处理时间delay来完成功能。但后续发现并不稳定，于是改用按照输入数据等指标来制作watermark，以对抗乱序提供完整性保证。
  	- **持久化计时器**
  - **文献**：[MillWheel: Fault-Tolerant Stream Processing at Internet Scale](http://static.googleusercontent.com/media/research.google.com/en/us/pubs/archive/41378.pdf)
  - **贡献**：一次性、持久状态、水印、持久计时器的四个概念共同为系统提供了基础，该系统最终能够实现流处理的真正承诺：健壮、低功耗无序数据的延迟处理

- **2011 Kafka**：持久化的可重放的流
  - **起源**：为大数据场景提供了中间件：持久化可重放、弹性削峰填谷等
  	- **可重放**：为用户提供了安全感，也为软件开发过程（原型、开发、测试）提供帮助
  	- **流表理论**：帮助人们更广泛地了解流和表的思维方式
  - **资料**：
  	- [I ❤ Logs](http://web.stanford.edu/class/ee380/Abstracts/141112-slides.pdf)
  	- [Stream Processing, CEP, Event Sourcing, and Data Streaming Explained](https://www.confluent.io/blog/making-sense-of-stream-processing/)
  	- [Introducing Kafka Streams: Stream Processing Made Simple | Confluent](https://www.confluent.io/blog/introducing-kafka-streams-stream-processing-made-simple/)

- **2013 Cloud Dataflow**：统一流批
  - **起源**：致力于构建 MapReduce、Flume 和 MillWheel，并将它们打包成无服务器云体验
  	- 自定义窗口化
  	- 灵活的触发器和累加器
  	- 融合批处理、微批处理、流处理
  - **文献**：[The Dataflow Model: A Practical Approach to Balancing Correctness, Latency, and Cost in Massive-Scale, Unbounded, Out-of-Order Data Processing](http://www.vldb.org/pvldb/vol8/p1792-Akidau.pdf)

- **2009 Flink**：高效快照
  - **起源**：2015年进入人们的视野，成为流处理系统世界的强者之一
  	- **编程模型**
  	- **高效快照**：利用了Distributed Snapshots: Determining Global States of Distributed Systems的idea
  		- 基本思想是周期性障碍沿着系统中工作人员之间的通信路径传播
  		- 许多其他项目（特别是 Storm 和 Apex）都采用了相同类型的一致性机制
  		- 利用快照的全局特性提供从过去任何点重新启动整个管道的能力，这一功能称为保存点
  - **资料**：
  	- [Extending the Yahoo! Streaming Benchmark](https://www.ververica.com/blog/extending-the-yahoo-streaming-benchmark)
  	- https://www.ververica.com/blog/turning-back-time-savepoints
  	- [State Management in Apache Flink](http://www.vldb.org/pvldb/vol10/p1718-carbone.pdf)

- **2016 Beam**：
  - **起源**：希望成为流数据系统世界中的SQL，一种整合多个runner的编程模型
  	- 统一的流处理加批处理模型
  	- 提供丰富SDK DSL
  	- 整合执行runner
  - **文献**：https://beam.apache.org/blog/splittable-do-fn/

- ## 开源世界的大数据生态
  - 简单对照了开源系统和G家系统
  	- hdfs -> gfs
  	- hadoop -> MR
  	- spark -> FlumeJava? （但是架构完全不同）
  	- hive: offline SQL on Hadoop，即在Hadoop上实现一层SQL到MR的转换
  	- hbase: NoSQL OLAP on HDFS（高并发随机写 & 实时查询）一般搭配hive使用：
  		- 海量随机查询：OLTP -> HDFS -> Hive -> HBase
  		- 其他查询：OLTP -> HDFS -> Hive -> Xxx

# Problems

- 消息队列、时序数据库、流处理系统的区别？
  - 区别体现在应对场景和设计原则不同上。虽然你可以研发一个完整系统来涵盖这些方面。
  - **消息队列**：一种异步的进程间通信系统。面临的场景是需要接受大量上游网络链接，按策略和分区再分发给不同下游，还需要提供削峰填谷能力、持久化能力和故障容错能力。
  - **时序数据库**：一种针对时序数据的数据库管理系统。需要支持带时间戳的数据的高吞吐量写入、点查询、范围查询以及计算。
  - **流处理系统**：一种针对低延时和无界数据流的数据处理系统，是相对于批处理系统的概念。需要考虑在无界数据流中的乱序和时间偏移问题的影响下，系统如何提供低延时的数据更新或推送。

- TODO 我找针对某概念或问题解决方案的paper，应该怎么找？例如Watermark
  - **期刊**：暂且用CCF A类的水平来看

- SparkStreaming中的shuffle演进：优化IO对性能提升非常大
  - > [漫谈分布式系统(17) -- 决战 Shuffle - 知乎](https://zhuanlan.zhihu.com/p/149494072)
  - **Hash Shuffle**：文件数为M*R*Executor
  - **Consolidated Hash Shuffle**：使用Map的并发度作为大小的公用文件池，文件数减少到P*R*Executor
  - **Sort Shuffle**：单个Map的所有文件合并为一个文件（附带一个指明分区的索引文件），Reducer再按分区信息获取不同range的文件。文件数降低到Executor*2
      不过sort可能带来性能损失，所有会有个bypass判断R的规模，如果足够小就退化到CHS。
  - **Tungsten Sort Shuffle**：CPU成为新时代的瓶颈，于是利用堆外内存消除序列化开销
