
<!-- vim-markdown-toc Marked -->

* [ASC - Supplementary 2](#asc---supplementary-2)
* [Plan](#plan)
    * [01-23](#01-23)
        * [选择爬取站点](#选择爬取站点)
        * [爬取流程](#爬取流程)
        * [遇到的问题](#遇到的问题)
        * [成果](#成果)

<!-- vim-markdown-toc -->

# ASC - Supplementary 2

这段时间的目标:
- test数据集的完形填空, 和阅读理解, 和其他完形爬虫的编写
- 讨论提出针对完形填空的建模和训练方法
- EL微调和评估


# Plan

| Date  | Works                          |
|-------|--------------------------------|
| 01-23 | test数据集中完形填空的爬虫编写 |


## 01-23

### 选择爬取站点

用免费和资源多的角度考虑, 选取一个站点`mofangge.com`

为了可扩展性, 设计功能为多个站点爬取


### 爬取流程

该站点没有提供站内搜索, 要进行爬取, 有两种方式**获得数据**:
- 全站爬取完形填空题目链接, 进行模糊匹配
- 百度搜索

因为存在部分完形题目是从阅读理解题目中挖空得到的, 所以对test数据集, 还要进行阅读理解的爬取

最后将答案进行数据结构化

![Untitled Diagram.png](https://i.loli.net/2020/01/23/1Oj3MRwodSDAmFc.png)


### 遇到的问题

- 常规模拟headers, cookies
```python
headers={
        "User-Agent" : "Mozilla/5.0 (X11; Linux x86_64; rv:71.0) Gecko/20100101 Firefox/71.0",
        "Host": "www.baidu.com",
}

cookies={"BAIDUID":"89225D5C4BD0C0C47E31411B666E0B83:FG=1","BD_CK_SAM":"1","BD_HOME":"1","BD_UPN":"133352" ...

```

- 注意百度url的解析, 需要处理302重定向时Host的改变
```python

def get_redirected(url):
    resp = req.get(url, headers=headers, cookies=cookies, allow_redirects=False)
    return resp.headers['location'].replace("://m.", "://")

```

- 常规编写xpath爬取规则
```python
xpath("//div[@class='q_bot']/table[1]/tbody/tr/td/text()")
```

### 成果

test数据集共400个样本, 能爬取到150个

对于其余样本, 考虑加入其他站点

样本:
```
'/home/tanglizi/Code/asc/asc20/dataset/ELE/test/test0188.json':  [
    ('mofangge.com', ['1-5: BCADA\xa0\xa06-10: DBCCA\xa0\xa011-15: \xa0BDACB\xa0\xa016-20: \xa0DCABD']),
    ('mofangge.xin', ['1-5: BCADA\xa0\xa06-10: DBCCA\xa0\xa011-15: \xa0BDACB\xa0\xa016-20: \xa0DCABD'])
],
```
