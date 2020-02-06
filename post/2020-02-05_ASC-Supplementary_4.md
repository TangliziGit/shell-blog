
<!-- vim-markdown-toc Marked -->

* [ASC Suplementary 4](#asc-suplementary-4)
    * [RoBERTa](#roberta)
        * [Optimization](#optimization)
            * [Preserve Underlines](#preserve-underlines)
            * [Fill Back Answers](#fill-back-answers)
            * [Fill Back Answers Iteratively](#fill-back-answers-iteratively)
        * [Problems](#problems)
        * [Result on valid](#result-on-valid)

<!-- vim-markdown-toc -->

# ASC Suplementary 4

## RoBERTa

将自定义任务换为模型自带的`fill_mask`任务, 它可以根据文章中的`<mask>`标记, 从词空间中选出k个最合适的词.  
再将选出的词对4个选项进行相似度匹配, 选出最相似的词, 使用`spaCy`库.


### Optimization

#### Preserve Underlines

原来的输入数据是按去除下划线的方式.  
但经测试, 保留下划线则能有更好的表现.  


#### Fill Back Answers

思路是当预测的选项概率大于某个阈值时, 可有一定概率认为这是正确选项.  
将这个`认为正确的选项`填回文章中, 直觉上, 理论上和测试结果认为能提高平均正确率.  
**证明稍后补上.**  
**问题:** 预测是按选项本身的顺序进行的, 所以当某空填上后, 之前的预测就不是最佳的.


#### Fill Back Answers Iteratively

为了祢补回填优化中的问题, 提出迭代回填.  
首先经过一轮预测, 将`认为正确的选项`填回文章.  
反复预测, 直到本轮没有新的`认为正确的选项`.  


### Problems

1. 部分文章太长, 长于1543个字符即报错.

2. roberta选出的词列表, 与选项的词性不同, 导致相似度没有太大差异, 容易选错

3. roberta可能输出空串.


### Result on valid

| RoBERTa model      | spaCy model    | input                  | lowest acc | highest acc | average acc | 方差    |
|--------------------|----------------|------------------------|------------|-------------|-------------|---------|
| roberta.large      | en_core_web_sm | 全文                   | 0.1        | 0.9         | 0.5563      | 0.01918 |
| roberta.large      | en_core_web_lg | 全文                   | 0.15       | 1.0         | 0.6392      | 0.01585 |
| roberta.large.mnli | en_core_web_lg | 全文                   | 0.0        | 0.6         | 0.2959      | 0.01160 |
| roberta.large      | en_core_web_lg | 全文 带下划线          | 0.15       | 1.0         | 0.6487      | 0.01628 |
| roberta.large      | en_core_web_lg | 全文 带下划线 回填     | 0.15       | 1.0         | 0.6544      | 0.01674 |
| roberta.base       | en_core_web_lg | 全文 带下划线 回填     | 0.15       | 0.9         | 0.6137      | 0.01659 |
| roberta.large      | en_core_web_lg | 全文 带下划线 二次回填 | 0.15       | 1.0         | **0.6714**  | 0.01836 |
