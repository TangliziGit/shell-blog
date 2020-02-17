
<!-- vim-markdown-toc Marked -->

* [ASC Suplementary 4](#asc-suplementary-4)
    * [RoBERTa](#roberta)
        * [Optimization](#optimization)
            * [Preserve Underlines](#preserve-underlines)
            * [Fill Back Answers](#fill-back-answers)
            * [Fill Back Answers Iteratively](#fill-back-answers-iteratively)
            * [Candidates](#candidates)
            * [Long Articles](#long-articles)
            * [Multiple Words](#multiple-words)
        * [Fine-tuning](#fine-tuning)
            * [Build Dataset](#build-dataset)
            * [Train](#train)
        * [Problems](#problems)
        * [Results on Valid](#results-on-valid)
        * [Analysis](#analysis)
            * [Loss](#loss)
            * [Error Type](#error-type)
    * [Ideas / Todo](#ideas-/-todo)
        * [Models Selection](#models-selection)
        * [Dataset Expansion](#dataset-expansion)
        * [Training Parameters Adjustment](#training-parameters-adjustment)

<!-- vim-markdown-toc -->

# ASC Suplementary 4

## RoBERTa

将自定义任务换为模型自带的`fill_mask`任务, 它可以根据文章中的`<mask>`标记, 从词空间中选出k个最合适的词.  
再将选出的词对4个选项进行相似度匹配, 选出最相似的词, 使用`spaCy`库.
注意每篇文章的选项数可能不同, 共有{10, 12, 15, 20}个空.


### Optimization

#### Preserve Underlines

> 原来的输入数据是按去除下划线的方式.  
> 但经测试, 保留下划线则能有更好的表现.  

经过大量测试, 发现有些情况下(可能是结合回填优化), 此项优化并非有提升. 
**效果见**: `#4`, `#17 #18`


#### Fill Back Answers

思路是当预测的选项概率大于某个阈值时, 可有一定概率认为这是正确选项.  
将这个`认为正确的选项`填回文章中, 直觉上, 理论上和测试结果认为能提高平均正确率.  
**证明稍后补上.**  
**问题:** 预测是按选项本身的顺序进行的, 所以当某空填上后, 之前的预测就不是最佳的.

**效果见**: `#4 #5 #6 #7 #8`

#### Fill Back Answers Iteratively

为了祢补回填优化中的问题, 提出迭代回填.  
首先经过一轮预测, 将`认为正确的选项`填回文章.  
反复预测, 直到本轮没有新的`认为正确的选项`.  

**效果见**: `#4 #5 #6 #7 #8`


#### Candidates

> 可以从RoBERTa的输出中选择题目的4个选项, 但是题目中的选项有可能不在该模型的词汇表中.  
> 测试结果中, 如选项`greet`不在模型中, 但`greeted`存在.  
> 提出利用词汇相似度, 首先将题目中的选项中选出最匹配的词, 再从中选出最有可能是答案的那个.  
> 但最后优化没有做成, 问题在于:
> 
> 1. 利用spaCy模型进行 $O(n^2)$ 复杂度的匹配过慢, 但可以利用`Vectors`进行矩阵优化.
> 
> 2. spaCy模型中也有缺词的现象, 这种情况下不可能进行词汇相似度.  
> 但可以尝试其他的词汇相似度方法.
> 
> 注意, 优化的前提是, 我们未进行微调的模型词汇表中没有选项中的词汇.  
> 若经过微调, 当词汇表中有了这些词汇, 就可以不利用`spaCy`模型进行这项优化.  
> 所以说在微调完成前, 这是暂时失败的优化.  

经过微调后, 继续进行此项优化.  
同时注意到在`RoBERTa`模型中, 若一个词不是句子第一个词时, 其词汇表中改词有一个前缀空白.  
如`greet`不存在, 但` greet`存在.  
故取消`spaCy`模型, 直接在词表中选取改词, 结果表明正确率提升很高.  

**效果见**: `#19 #20`

#### Long Articles

此项优化针对`Problems 1`.  
由于文章长度超过模型预设的大小, 一次性测试不可行.  
于是通过对长文章进行裁剪, 解决此问题.  
本此优化的简略步骤:  
1. 将某个将预测的选项所处的句子号码找出, 作为输入文章的句子列表  
2. 对上下文临近的句子添加进来, 同时进行长度测试  

**效果见**: `#18 #19`


#### Multiple Words

经日志分析, 发现像`look at`或`seek for`这样的多段词, 在词表中是不存在的.  
并且这个现象非常常见(见Error Type分析).  
对此进行优化, 基于贝叶斯序列, 计算出多段词的选取概率.  
原理简单, 如`look at`: $P(look at) = P(look) * P(at | look)$.  
但效果拔群.

**效果见**: Error Type表格, `#19 #20`


### Fine-tuning

#### Build Dataset

1. 将完形填空数据补全成完整文章
```python
for dirname in os.listdir():
    if not os.path.isdir(dirname):
        continue

    jsonl_content = []
    articles = []

    print(dirname)
    for filename in tqdm(os.listdir(f"./{dirname}/")):
        path = f"./{dirname}/{filename}"
        example = json.loads(open(path, 'r').read())
        jsonl_content.append(json.dumps(example))

        answers = []
        for options, key in zip(example['options'], example['answers']):
            ans = options[ord(key) - ord('A')]
            answers.append(ans)

        splited = example['article'].split('_')
        article = splited[0]
        for art, ans in zip(splited[1:], answers):
            article = article + ans + art

        articles.append(article)

    raw = open(f'{dirname}.raw', 'w')
    jsonl = open(f'{dirname}.jsonl', 'w')

    for article in articles:
        raw.write(article + '\n\n')

    for j in jsonl_content:
        jsonl.write(j + '\n')
```

2. 将文章经过`bpe`编码, 统计词典并存为数据集文件夹
```bash
for SPLIT in train valid test; do \
    python -m examples.roberta.multiprocessing_bpe_encoder \
        --encoder-json gpt2_bpe/encoder.json \
        --vocab-bpe gpt2_bpe/vocab.bpe \
        --inputs data/ELE-raw/${SPLIT}.raw \
        --outputs data/ELE-raw/${SPLIT}.bpe \
        --keep-empty \
        --workers 60; \
done

fairseq-preprocess \
    --only-source \
    --srcdict gpt2_bpe/dict.txt \
    --trainpref data/ELE-raw/train.bpe \
    --validpref data/ELE-raw/valid.bpe \
    --testpref  data/ELE-raw/test.bpe \
    --destdir data-bin/ele \
    --workers 60
```

#### Train

mask-finetune/base.sh
```bash
TOTAL_UPDATES=5000    # Total number of training steps
WARMUP_UPDATES=400    # Warmup the learning rate over this many updates
PEAK_LR=0.0005          # Peak learning rate, adjust as needed
TOKENS_PER_SAMPLE=512   # Max sequence length
MAX_POSITIONS=512       # Num. positional embeddings (usually same as above)
# MAX_SENTENCES=16        # Number of sequences per batch (batch size)
# UPDATE_FREQ=16          # Increase the batch size 16x
MAX_SENTENCES=2        # Number of sequences per batch (batch size)
UPDATE_FREQ=2          # Increase the batch size 16x

CHECKPOINT_INTERNAL=100
SAVE_DIR=checkpoints/mask-base
ROBERTA_PATH=models/roberta.large/model.pt

DATA_DIR=data-bin/ele

# CUDA_VISIBLE_DEVICES=0 fairseq-train --fp16 $DATA_DIR \
# CUDA_VISIBLE_DEVICES=0 fairseq-train $DATA_DIR \
fairseq-train $DATA_DIR \
    --task masked_lm --criterion masked_lm \
    --arch roberta_large --sample-break-mode complete --tokens-per-sample $TOKENS_PER_SAMPLE \
    --optimizer adam --adam-betas '(0.9,0.98)' --adam-eps 1e-6 --clip-norm 0.0 \
    --lr-scheduler polynomial_decay --lr $PEAK_LR --warmup-updates $WARMUP_UPDATES --total-num-update $TOTAL_UPDATES \
    --dropout 0.1 --attention-dropout 0.1 --weight-decay 0.01 \
    --max-sentences $MAX_SENTENCES --update-freq $UPDATE_FREQ \
    --max-update $TOTAL_UPDATES --log-format simple --log-interval 25 \
    --restore-file $ROBERTA_PATH \
    --save-interval-updates $CHECKPOINT_INTERNAL \
    --save-dir $SAVE_DIR \
    --skip-invalid-size-inputs-valid-test
```
注意:  
1. 将`batch_size & update_freq`从`16`调整为`2`, 防止`OOM`出现打断分布训练.  
2. 默认进行全部GPU的分布训练.  
3. 将`updates`从`1250000`调整为`5000`, 因为数据集不大. `warmup_updates`亦然.  
4. 取消`fp16`, 设备不支持.  
5. 开启`skip-invalid`, 有些数据超过512的限制.  


### Problems

1. <del>部分文章太长, 长于1543个字符即报错.</del>

2. roberta选出的词列表, 与选项的词性不同, 导致相似度没有太大差异, 容易选错

3. roberta可能输出空串.

4. roberta预训练模型的词典中, 可能不直接包含选项中的某个词.  
如选项中的`greet`, 词典中没有这个词, 但是有`greeted`这个词.  
导致无法直接取相应的词, 例:  
```
options:            ['charge', 'greet', 'treat', 'reward']
bpe encode:         ['10136', '70 2871', '83 630', '260 904']
dictory index:      [15040, 3, 3, 3]
bpe decode:         [10136 <unk> <unk> <unk>]
word in dictory:    ['charge', '<unk>', '<unk>', '<unk>']
logits:             tensor([-4.2741, -3.2696, -3.2696, -3.2696])
```


### Results on Valid

| id  | RoBERTa model      | spaCy model    | finetune | input                    | FB_threshold | lowest acc | highest acc | **average acc** | 方差    | log file                           |
|-----|--------------------|----------------|----------|--------------------------|--------------|------------|-------------|-----------------|---------|------------------------------------|
| #1  | roberta.large      | en_core_web_sm |          | 全短文                   |              | 0.1        | 0.9         | 0.5563          | 0.01918 |                                    |
| #2  | roberta.large      | en_core_web_lg |          | 全短文                   |              | 0.15       | 1.0         | 0.6392          | 0.01585 |                                    |
| #3  | roberta.large.mnli | en_core_web_lg |          | 全短文                   |              | 0.0        | 0.6         | 0.2959          | 0.01160 |                                    |
| #4  | roberta.large      | en_core_web_lg |          | 全短文 带下划线          |              | 0.15       | 1.0         | 0.6487          | 0.01628 |                                    |
| #5  | roberta.large      | en_core_web_lg |          | 全短文 带下划线 回填     | t2           | 0.15       | 1.0         | 0.6544          | 0.01674 |                                    |
| #6  | roberta.base       | en_core_web_lg |          | 全短文 带下划线 回填     | t2           | 0.15       | 0.9         | 0.6137          | 0.01659 |                                    |
| #7  | roberta.large      | en_core_web_lg |          | 全短文 带下划线 二次回填 | t2           | 0.15       | 1.0         | 0.6714          | 0.01836 |                                    |
| #8  | roberta.large      | en_core_web_lg |          | 全短文 带下划线 迭代回填 | t2           | 0.15       | 1.0         | 0.6722          | 0.01821 |                                    |
| #9  | roberta.large      | en_core_web_lg | base     | 全短文 带下划线 迭代回填 | t2           | 0.15       | 1.0         | 0.6800          | 0.01608 |                                    |
| #10 | roberta.large      | en_core_web_lg | large    | 全短文 带下划线 迭代回填 | t2           | 0.15       | 1.0         | 0.7177          | 0.01788 |                                    |
| #11 | roberta.large      | en_core_web_lg | exp1     | 全短文 带下划线 迭代回填 | t2           | 0.15       | 1.0         | 0.7199          | 0.01704 |                                    |
| #12 | roberta.large      | en_core_web_lg | exp2     | 全短文 带下划线 迭代回填 | t2           | 0.15       | 1.0         | 0.7098          | 0.01683 |                                    |
| #13 | roberta.large      |                | exp1     | 全短文 带下划线 迭代回填 | t2           | 0.2        | 1.0         | 0.8120          | 0.01611 |                                    |
| #14 | roberta.large      |                | exp1     | 全短文 带下划线 全回填   | t0           | 0.2        | 1.0         | 0.8229          | 0.01573 |                                    |
| #15 | roberta.large      |                | exp1     | 全短文 带下划线          | t1           | 0.2        | 1.0         | 0.8123          | 0.01615 |                                    |
| #16 | roberta.large      |                | exp1     | 全短文 带下划线 迭代回填 | t3           | 0.2        | 1.0         | 0.8258          | 0.01556 |                                    |
| #17 | roberta.large      |                | large    | 全短文 带下划线 迭代回填 | t3           | 0.2        | 1.0         | 0.8269          | 0.01554 |                                    |
| #18 | roberta.large      |                | large    | 全短文 迭代回填          | t3           | 0.2        | 1.0         | 0.8278          | 0.01553 | mask-large-without_ul              |
| #19 | roberta.large      |                | large    | 全文 迭代回填            | t3           | 0.2        | 1.0         | 0.8280          | 0.01712 | mask-large-without_ul-long_art     |
| #20 | roberta.large      |                | large    | 全文 迭代回填 多段词     | t3           | 0.2        | 1.0         | 0.8746          | 0.01180 | mask-large-without_ul-long_art-unk |
| #21 | roberta.large      |                | exp3     | 全文 迭代回填 多段词     | t3           | 0.2        | 1.0         | **0.8786**      | 0.01113 | mask-exp3-without_ul-long_art-unk  |
| #22 | roberta.large      |                | exp3     | 全文 迭代回填 多段词     | t4           | 0.25       | 1.0         | 0.8783          | 0.01127 | mask-exp3-t4                       |
| #23 | roberta.large      |                | exp4     | 全文 迭代回填 多段词     | t4           | 0.2        | 1.0         | 0.8771          | 0.01139 | mask-exp4-t4                       |
| #24 | roberta.large      |                | exp4     | 全文 迭代回填 多段词     | t3           | 0.25       | 1.0         | 0.8774          | 0.01125 | mask-exp4-t3                       |


| FB_threshold | value              | comment          |
|--------------|--------------------|------------------|
| t0           | 0.0                | 全部回填         |
| t1           | 1.1                | 不回填           |
| t2           | 0.9999998585327273 | 以#4 为基准计算  |
| t3           | 0.8229047072330654 | 以#14 为基准计算 |
| t4           | 0.8785586047704540 | 以#21 为基准计算 |


| Finetune | dataset  | env    | train hours | TOTAL_UPDATES    | WARMUP_UPDATES | PEAK_LR  | MAX_SENTENCES | UPDATE_FREQ | **best_loss** | others                    | log file       |
|----------|----------|--------|-------------|------------------|----------------|----------|---------------|-------------|---------------|---------------------------|----------------|
| base     | ele      | 2*P100 | 1.5         | 5000             | 400            | 0.0005   | 2             | 2           | 1.77741       |                           | 0207_22:31.log |
| large    | ele      | 2*P100 | 48          | <del>25000</del> | 2000           | 0.0001   | 2             | 64          | 1.35783       | **break on updates 7290** | 0208_13:11.log |
| exp1     | ele      | 2*P100 | 10          | 1800             | 150            | 0.00003  | 2             | 64          | 1.37104       | 取消checkpoint_save       | 0210_21:12.log |
| exp2     | ele-race | 2*P100 | 29.5        | 5000             | 400            | 0.0001   | 2             | 64          | 1.37473       |                           | 0211_11:51.log |
| exp3     | ele      | 2*P100 | 7           | 1200             |                | 0.00001  | 2             | 64          | 1.34585       | fixed learning rate       | 0212_21:20.log |
| exp4     | ele      | 2*P10  | 14          | 2400             |                | 0.000004 | 2             | 64          | **1.33823**   | fixed learning rate       | 0214_00:21.log |


### Analysis

#### Loss

The train analysis image, on all trained model's loss and learning rate.

![loss.png](https://i.loli.net/2020/02/16/DNWRs7S8AT56IOh.png)


#### Error Type

| error name  | comment                                           |
|-------------|---------------------------------------------------|
| multi-words | option with not only one word, causes <unk> error |
| unk         | lack of the answer word                           |
| near        | option with 2nd score is the answer               |
| far / other | other error                                       |


| id  | mw  | unk | near | far |
|-----|-----|-----|------|-----|
| #19 | 580 | 203 | 391  | 167 |
| #20 | 0   | 220 | 493  | 265 |
| #21 | 0   | 220 | 460  | 267 |
| #22 | 0   | 220 | 465  | 264 |
| #23 | 0   | 220 | 476  | 268 |
| #24 | 0   | 220 | 468  | 268 |


![error.png](https://i.loli.net/2020/02/16/LEFuQMI2fUHpBYP.png)


## Ideas / Todo

### Models Selection

候选模型列表:  
`BERT`, `XLNet`, `XLM`, `DistilBERT`, `CamamBERT`, `ALBERT`, `XLM-RoBERTa`, `FlauBERT`.  

建议优先(因为较新):
`ALBERT`, `XLM-RoBERTa`, `FlauBERT`.  


### Dataset Expansion

对数据集的扩充, 暂时有两种思路:  

1. 使用`RACE`数据集, 这是选自中国中高考试卷阅读理解.  

2. 继续进行爬虫的编写, 目标是阅读理解和完形天空.  
由于爬取的数据较大, 所以需要考虑: 去重, 多站点, 反防爬(图片OCR, IP代理池等)等.  


### Training Parameters Adjustment

主要考虑学习率的初值, 降低学习率的频率和大小, 学习率的峰值等.  
需要微调完毕后, 进行分析.  

