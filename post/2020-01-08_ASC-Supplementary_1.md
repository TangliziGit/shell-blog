
<!-- vim-markdown-toc Marked -->

* [Todo](#todo)
* [Domain](#domain)
* [Models](#models)
* [Papers](#papers)
* [Dataset](#dataset)
    * [Commonsense QA](#commonsense-qa)
    * [HellaSwag](#hellaswag)
    * [SQuAD](#squad)
    * [RACE](#race)

<!-- vim-markdown-toc -->

# Todo
- RoBERTa 原理 & 用法
- BERT 原理
- 优化方向:
    - 传统方法考虑: 提升方法等
    - 数据集
    - 分布式训练
    - loss (可能性不大, 本次题目loss很规范)
    - 调参

# Domain

**Reading Comprehension**, Text Classification, Translation, Summarization, QA.


# Models

| model          | time | is PyTorch code? | RACE accuracy | HellaSwag | notes / problems |
|----------------|------|------------------|---------------|-----------|------------------|
| GPT2           | 2019 | No               |               |           |                  |
| XLNet          | 2019 | No               | 81.75         | None      |                  |
| **RoBERTa**    | 2019 | Yes              | 83.2          | 85.2      |                  |
| transformer-xl | 2018 | Yes              | None          | None      |                  |

# Papers

| paper                                                                                   | has code |
|-----------------------------------------------------------------------------------------|----------|
| Cloze-driven Pretraining of Self-attention Networks                                     | No       |
| Contextual Recurrent Units for Cloze-style Reading Comprehension                        | No       |
| Design and Challenges of Cloze-Style Reading Comprehension Tasks on Multiparty Dialogue | No       |


# Dataset

The 2 datasets most like cloze test are RACE and HellaSwag,
    but they both choose from 4 sentences, not words.

## Commonsense QA
sample:
```
Where would I not want a fox?

👍 hen house, 👎 england, 👎 mountains, 👎 english hunt, 👎 california
```

## HellaSwag
sample:
```
{
  "ind": 24,
  "activity_label": "Roof shingle removal",
  "ctx_a": "A man is sitting on a roof.",
  "ctx_b": "he",
  "ctx": "A man is sitting on a roof. he",
  "split": "val",
  "split_type": "indomain",
  "label": 3,
  "endings": [
    "is using wrap to wrap a pair of skis.",
    "is ripping level tiles off.",
    "is holding a rubik's cube.",
    "starts pulling up roofing on a roof."
  ],
  "source_id": "activitynet~v_-JhWjGDPHMY"
}

```

## SQuAD
sample:
```
{
  "version": "v2.0",
  "data": [
    {
      "title": "Normans",
      "paragraphs": [
        {
          "qas": [
            {
              "question": "In what country is Normandy located?",
              "id": "56ddde6b9a695914005b9628",
              "answers": [
                {
                  "text": "France",
                  "answer_start": 159
                },
                {
                  "text": "France",
                  "answer_start": 159
                },
                {
                  "text": "France",
                  "answer_start": 159
                },
                {
                  "text": "France",
                  "answer_start": 159
                }
              ],
              "is_impossible": false
            },
            {
              "question": "When were the Normans in Normandy?",
              "id": "56ddde6b9a695914005b9629",
              "answers": [
                {
                  "text": "10th and 11th centuries",
                  "answer_start": 94
                },
                {
                  "text": "in the 10th and 11th centuries",
                  "answer_start": 87
                },
                {
                  "text": "10th and 11th centuries",
                  "answer_start": 94
                },
                {
                  "text": "10th and 11th centuries",
                  "answer_start": 94
                }
...
```

## RACE
Questions in RACE were created to prepare Chinese students for the college entrance test and high school entrance tests.
sample:
```
{
  "answers": [
    "B",
    "A",
    "D"
  ],
  "options": [
    [
      "affected only the companies doing business within state lines",
      "sought to eliminate monopolies in favor of competition in the market-place",
      "promoted trade with a large number of nations",
      "provides a financial advantage to the buyer"
    ],
    [
      "are more likely to exist in a competitive market economy",
      "usually can be found only in an economy based on monopolies",
      "matter only to people who are poor and living below the poverty level",
      "are regulated by the government"
    ],
    [
      "believed that the trusts had little influence over government",
      "expected the wealthy magnates to share money with the poor",
      "did little to build up American business",
      "were worried that trusts might manipulate the government"
    ]
  ],
  "questions": [
    "The Sherman Antitrust Act  _  .",
    "One might infer from this passage that lower prices   _  .",
    "It seems likely that many Americans  _  ."
  ],
  "article": "One thinks of princes and presidents as some of the most powerful people in the world; however, governments, elected or otherwise, sometimes have had to struggle with the financial powerhouses called tycoons. The word tycoon is relatively new to the English language. It is Chinese in origin but was given as a title to some Japanese generals. The term was brought to the United States, in the late nineteenth century, where it eventually was used to refer to magnates who acquired immense fortunes from sugar and cattle, coal and oil, rubber and steel, and railroads. Some people called these tycoons \"capitals of industry\" and praised them for their contributions to U.S. wealth and international reputation. Others criticized them as cruel \"robber barons\", who would stop at nothing in pursuit of personal wealth.\nThe early tycoons built successful businesses, often taking over smaller companies to eliminate competition. A single company that came to control an entire market was called a monopoly. Monopolies made a few families very wealthy, but they also placed a heavy financial burden on consumers and the economy at large.\nAs the country expanded and railroads linked the East Coast to the West Coast, local monopolies turned into national corporations called trusts. A trust is a group of companies that join together under the control of a board of trustees. Railroad trusts are an excellent example. Railroads were privately owned and operated and often monopolized various routes, setting rates as high as they desired. The financial burden this placed on passengers and businesses increased when railroads formed trusts. Farmers, for example, had no choice but to pay, as railroads were the only means they could use to get their grain to buyers. Exorbitant   goods rates put some farmers out of business.\nThere were even accusations that the trusts controlled government itself by buying votes and manipulating elected officials. In 1890 Congress passed the Sherman Antitrust. Act, legislation aimed at breaking the power of such trusts. The Sherman Antitrust Act focused on two main issues. First of all, it made illegal any effort to interfere with the normal conduct of interstate trade. It also made it illegal to monopolize any part of business that operates across state lines.\nOver the next 60 years or so, Congress passed other antitrust laws in an effort to encourage competition and restrict the power of larger corporations.",
  "id": "high10024.txt"
}
```

