# NLP reveiw

## n-gram

一个n-gram是指一个包含n个标记的序列.
当预测句子中下一个词时, 我们可以用预测词的前n-1个词来预测.
公式见book p280.
优化:
- 平滑
- 回退方法
- 基于类的语言模型

## RNN

book p230

## Seq2Seq 

Seq2Seq模型是输出的长度不确定时采用的模型.
基础架构如下, 包含encoder和decoder, encoder的最后一个状态作为decoder的输入.
缺点是状态维度不大, 存不下大量的上下文信息.
![](https://pic1.zhimg.com/80/v2-e258d6cd046c0567ad72a8fe930807cc_hd.jpg)
![](https://upload-images.jianshu.io/upload_images/15573329-9edc148897240231.png?imageMogr2/auto-orient/strip|imageView2/2/w/619)

## Attention

基于Seq2Seq, 保留encoder和decoder, 但是decoder的输入改为注意力的输出结果.
![](https://pic4.zhimg.com/80/v2-5a509cc5d422b5d83006f41738dd7b43_hd.jpg)
![](https://pic4.zhimg.com/80/v2-f0a7c907fca9301a628ac3a5bfe04ac7_hd.jpg)
其中$\alpha$ 是由 $z_i$ 和 $h_i$ 得到.

## Transformer


