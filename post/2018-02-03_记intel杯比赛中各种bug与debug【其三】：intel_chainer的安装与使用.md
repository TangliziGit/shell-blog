现在在训练模型，闲着来写一篇
顺着[这篇文章](http://blog.csdn.net/qq_32768743/article/details/79207904)，顺利安装上intel chainer
再次感谢 大黄老鼠

## intel chainer 使用
头一次使用chainer，本以为又入了一个大坑，实际尝试感觉非常兴奋
chainer的使用十分顺畅，开发起来特别友好
可能是跟pytorch相似的原因，特喜欢chainer
![](http://images2017.cnblogs.com/blog/1225237/201802/1225237-20180203205823625-442908289.png)


###  网络结构编写
这里如果用过pytorch，就会发现代码几乎没变，写起来就会非常顺手
在chainer中layers被视为links，Module被叫做Chain， chainer的意思由此可见
chainer的创新是突出了一个数据带领结构（“Define-by-Run”），所以就连layer的输入大小都不需要填写
模型会自动帮我们写
```python
class Network(chainer.Chain):
    def __init__(self):
        super(Network, self).__init__()
        with self.init__scope():
            self.in=chainer.links.Linear(None, 256)
            self.hidden=chainer.links.Linear(None, 64)
            self.out=chainer.links.Linear(None, 5)

    def __call__(self, x):
        x=chainer.functions.relu(self.in(x))
        x=chainer.functions.relu(self.hidden(x))
        x=self.out(x)
        return x

class Classifier(chainer.Chainer):
    def __init__(self, predicor):
        super(Classifier, self).__init__()
        with self.init__scope():
            self.predictor=predictor
    
    def __call__(self, x, t):
        x=self.predictor(x)
        loss=chainer.functions.softmax_cross_entropy(x, t)
        accuracy=chainer.functions.accuracy(x, t)
        chainer.reporter.report({'loss': loss, 'accuracy': accuracy}, self)
        return loss
```

### 训练模型
简要写一下chainer训练时要写什么
- model
- optimizer
- trainer(可选，需要updater和必要的参数)
- updater(以下皆可选， 需iterator， optimizer)
- iterator(需dataset，batch_size)
- dataset(类型为TupleDataset)
- extensions(需trainer)

我们把训练方式分为两种
- 一种为pytorch风格
定义好model, optimizer, criterion
嵌套循环，计算loss然后bp即可

```python
def lossfun(data, label):
    ...
    return loss
    
model=Network()
optimizer=chainer.optimizers.Adam()
optimizer.setup(model)
for epoch in params['epoch']:
    for step, batch in enumerate(dataset):
        model.cleargrads()
        # model.reset_state()
        
        loss=lossfun(batch['data'], batch['label'])
        loss.backward()
        optimizer.update()
```
或者简单写成
```python
model=Network()
optimizer=chainer.optimizers.Adam()
optimizer.setup(model)
for epoch in params['epoch']:
    for step, batch in enumerate(dataset):
        # model.reset_state()
        optimizer.update(lossfun, data, label)
```

- 另一种是带trainer的chainer风格
若有需要，重写updater和iterator，塞进trainer即可
若需要拓展，只需trainer.extend(...)，十分方便
这里就简单的写一下

```python
model=Classifier(Network())
optimizer=chainer.optimizers.Adam()
optimizer.setup(model)

trainset=chainer.datasets.TupleDataset(data, label)
train_iter=chainer.iterators.SerialIterator(trainset, params['batch_size'], shuffle=True, repeat=True)
updater=trainer.StandardUpdater(train_iter, model)
trainer=chainer.training.Trainer(updater, (params['epoch'], 'epoch'), params['name'])

# 这里是各种拓展
trainer.run()
```

### 使用模型
跟pytorch一样，十分简单

```python
predict=model(data)
...
```