
<!-- vim-markdown-toc Marked -->

* [ASC Suplementary 4](#asc-suplementary-4)
    * [RoBERTa](#roberta)
        * [Problems](#problems)
        * [Result on valid](#result-on-valid)

<!-- vim-markdown-toc -->

# ASC Suplementary 4

## RoBERTa

将自定义任务换为模型自带的`fill_mask`任务, 它可以根据文章中的`<mask>`标记, 从词空间中选出k个最合适的词.  
再将选出的词对4个选项进行相似度匹配, 选出最相似的词, 使用`spaCy`库.

### Problems

1. 部分文章太长, 长于1543个字符即报错.
2. roberta选出的词列表, 与选项的词性不同, 导致相似度没有太大差异, 容易选错
3. roberta可能输出空串.

### Result on valid

| RoBERTa model      | spaCy model    | input            | lowest acc | highest acc | average acc | 方差    |
|--------------------|----------------|------------------|------------|-------------|-------------|---------|
| roberta.large      | en_core_web_sm | 全文             | 0.1        | 0.9         | 0.5563      | 0.01918 |
| roberta.large      | en_core_web_lg | 全文             | 0.15       | 1.0         | 0.6392      | 0.01585 |
| roberta.large.mnli | en_core_web_lg | 全文             | 0.0        | 0.6         | 0.2959      | 0.01160 |
| roberta.large      | en_core_web_lg | 全文带下划线     | 0.15       | 1.0         | 0.6487      | 0.01628 |
| roberta.large      | en_core_web_lg | 全文带下划线回填 | 0.15       | 1.0         | 0.6544      | 0.01674 |

