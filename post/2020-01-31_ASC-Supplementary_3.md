
<!-- vim-markdown-toc Marked -->

* [ASC Suplementary 3](#asc-suplementary-3)
    * [finetune 思路](#finetune-思路)
        * [思路1 - 全文式数据](#思路1---全文式数据)
            * [OOM 的情况](#oom-的情况)
            * [缓解方法](#缓解方法)
        * [思路2 - 简单上下文式数据](#思路2---简单上下文式数据)
    * [结果](#结果)
    * [下一步做什么](#下一步做什么)
    * [automation scripts](#automation-scripts)
        * [logging](#logging)
        * [training](#training)
        * [valid](#valid)

<!-- vim-markdown-toc -->

# ASC Suplementary 3

## finetune 思路

RoBERTa模型的微调过程是: 将带正确或错误标记的一段文章作为数据, 进行训练.

而验证过程是将一段文本作为输入, 输出一个评估分数, 这个分数越高则文本越通顺或越正确.

现在有两种微调思路:

1. 将一篇文章所有空(下划线)去掉, 对某一个问题进行填空, 带上正确或错误标记, 作为数据训练

2. 将一个空的上下文进行裁剪, 对其填空, 带上标记, 作为数据训练


### 思路1 - 全文式数据


进行测试结果表明显存不足, 会出现大量 `OOM(Out Of Memory)` 的情况.

每次遇到OOM时, pytorch将找回丢失的数据, 再装入GPU中.

若频繁出现OOM, 那么这个找回过程就相当耗时.

于是才出现思路2.


#### OOM 的情况

```
| WARNING: attempting to recover from OOM in forward/backward pass
| WARNING: OOM in all workers, skipping update
| OOM: Ran out of memory with exception: CUDA out of memory. Tried to allocate 62.00 MiB (GPU 0; 15.90 GiB total capacity; 14.59 GiB already allocated; 9.88 MiB free; 15.19 GiB reserved in total by PyTorch)
|===========================================================================|
|                  PyTorch CUDA memory summary, device ID 0                 |
|---------------------------------------------------------------------------|
|            CUDA OOMs: 58           |        cudaMalloc retries: 66        |
|===========================================================================|
|        Metric         | Cur Usage  | Peak Usage | Tot Alloc  | Tot Freed  |
|---------------------------------------------------------------------------|
| Allocated memory      |   14935 MB |   15377 MB |     995 GB |     980 GB |
|       from large pool |   14932 MB |   15374 MB |     995 GB |     980 GB |
|       from small pool |       2 MB |       3 MB |       0 GB |       0 GB |
|---------------------------------------------------------------------------|
| Active memory         |   14935 MB |   15377 MB |     995 GB |     980 GB |
|       from large pool |   14932 MB |   15374 MB |     995 GB |     980 GB |
|       from small pool |       2 MB |       3 MB |       0 GB |       0 GB |
|---------------------------------------------------------------------------|
| GPU reserved memory   |   15552 MB |   15560 MB |   51434 MB |   35882 MB |
|       from large pool |   15548 MB |   15556 MB |   51424 MB |   35876 MB |
|       from small pool |       4 MB |       4 MB |      10 MB |       6 MB |
|---------------------------------------------------------------------------|
| Non-releasable memory |  631465 KB |    1511 MB |  419075 MB |  418459 MB |
|       from large pool |  630420 KB |    1510 MB |  418768 MB |  418152 MB |
|       from small pool |    1044 KB |       2 MB |     307 MB |     306 MB |
|---------------------------------------------------------------------------|
| Allocations           |     728    |     831    |   33352    |   32624    |
|       from large pool |     406    |     489    |   25889    |   25483    |
|       from small pool |     322    |     342    |    7463    |    7141    |
|---------------------------------------------------------------------------|
| Active allocs         |     728    |     831    |   33352    |   32624    |
|       from large pool |     406    |     489    |   25889    |   25483    |
|       from small pool |     322    |     342    |    7463    |    7141    |
|---------------------------------------------------------------------------|
| GPU reserved segments |     172    |     193    |     590    |     418    |
|       from large pool |     170    |     191    |     585    |     415    |
|       from small pool |       2    |       2    |       5    |       3    |
|---------------------------------------------------------------------------|
| Non-releasable allocs |     125    |     152    |   18243    |   18118    |
|       from large pool |     121    |     149    |   15882    |   15761    |
|       from small pool |       4    |       5    |    2361    |    2357    |
|===========================================================================|

```

#### 缓解方法

1. 减少输入文章的句子长度, 或句子数量.
2. 降低batch size.
3. 减少数据量, 进行分多段训练.


### 思路2 - 简单上下文式数据

因为频繁的耗时的OOM, 考虑减少样本中文章的长度, 进行裁剪.

具体做法如下:

1. 若进行第2空的判断, 则首先找到第1, 2, 3个空的位置

2. 取1到3位置之间的文章, 并将2号空填写选择的词

3. 带上正确或错误标记, 进行训练



## 结果

| data format | model | update | LR update | LR    | batch size | best accuracy on train | best accuracy on valid |
|-------------|-------|--------|-----------|-------|------------|------------------------|------------------------|
| 全文式      | large | 3000   | 150       | 1e-05 | 4          | 0.6                    | 0.250797               |
| 全文式      | mnli  | 3000   | 150       | 1e-05 | 4          | 0.5                    | 0.243092               |
| 3段式数据   | large | 3000   | 150       | 1e-05 | 16         | 0.2932                 | 0.269182               |
| 3段式数据   | large | 10000  | 150       | 1e-05 | 16         | 0.269182               | None                   |


large 全文式训练集正确率:

![全文式 - large.allSeg.png](https://i.loli.net/2020/02/02/3Qs5Hh9WA2GM6px.png)

mnli 全文式训练集正确率:

![全文式 - mnli.allSeg.png](https://i.loli.net/2020/02/02/3DBGpfN7xoIEbrc.png)

简单上下文式训练集正确率:


![简单上下文式 - threeSeg_10000u.png](https://i.loli.net/2020/02/02/5v21ojfuULRixrq.png)

在验证集上的正确率极低, 很可能是以下问提:

1. finetune和验证过程的输入数据中的文章和选项没有相关性, 或者对预训练模型来说很难区分; 思路1和思路2都有问题.

2. 预训练模型没有正确加载. 正确的预训练模型不可能正确率过低.


## 下一步做什么

1. 细读RoBERTa论文, 考虑给什么样的数据更好.

2. 参考fairseq文档, 因为RoBERTa是fairseq工具集的一个, 所以用法上进行了不少抽象, 用起来比骄傲麻烦.

3. 用更简单的模型, 如张诩浩的BERT.


## automation scripts

### logging

```bash
function log(){
    filename=/home/asc20/data/zhangcx/ele/log/`date +%m%d_%H:%M.log`
    $@ 2>&1 | tee $filename
    echo "" >> $filename
    date +%m%d_%H:%M >> $filename
    python /home/asc20/data/zhangcx/ele/send_email.py $filename
}
```

Usage: `log bash finetune.sh`

### training

set checkpoints step and directory

### valid

use `watchdog` to monitor new model files, to valid the accuray score.
