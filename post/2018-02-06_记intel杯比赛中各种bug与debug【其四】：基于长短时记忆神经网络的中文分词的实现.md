（标题长一点就能让外行人感觉到高大上）
直接切入主题好了，这个比赛还必须一个神经网络才可以
所以我们结合主题，打算写一个神经网络的中文分词
这里主要写一下数据的收集和处理，网络的设计，代码的编写和模型测试

### 数据问题
这个模型的数据，我们打算分三类来：
- 用msr, pku, as, cityu的语料作数据
这些是人工分词的数据，作为数据是最合适的
虽然数据量确实不小（共158999行），但我们有几个另外的想法

- 用已有的多个中文分词工具，对小说、新闻、法律等进行分词，作为数据
很多分词工具的分词结果并不理想，总是有一部分正确，一部分不通
现在把多个分隔作为频率，再设置一个阈值，作为是否分隔的依据
对于我们这个模型来说，语言需要一些日常用语的，和一些正式用语
所以数据直接爬取小说、新闻等即可
这样可以把数据扩大非常多

- 直接拼接词语作为数据
这个一开始是斗机灵来着，想着想着到还是值得一试的呵呵

### 网络设计
想到中文分词就能想到隐马模型，然而需要神经网络的话，就直接用lstm好了
lstm网络的优点就是对序列的选择性记忆，我们人类分词的时候不也是用一点内存来记忆么
我们还要用字嵌入层，它用于把one-hot向量转为一个多维向量
这些向量之间会有相似度，也符合字之间存在相似度这一设定
网络就简单这样写：
embedding->lstm->linear->linear
简单暴力

### 代码编写
写过pytorch的话，chainer开发就轻而易举
代码写的不好看，反正没人看，就先贴上来把
咋有种acm选手作风
```python
# network.py
import chainer
from chainer import links
from chainer import functions
from chainer import reporter

path="/home/tanglizi/Code/chainer/segment"
params={
	"name": "segment",
	"src_path": path+"/train_dataset/src",
	"save_path": path+"/saved",
	"test_path": path+"/test_dataset",
	"train_path": path+"/train_dataset",
	# just for test
	"batch_size": 100,
	"word_cnt": 48,
	"epoch": 8,
	"snap_epoch": 3,
}

class Network(chainer.Chain):
	def __init__(self):
		super(Network, self).__init__()
		with self.init_scope():
			self.embed=links.EmbedID(8000, 512)
			self.rnn=links.LSTM(512, 256)
			self.linear=links.Linear(256, 64)
			self.out=links.Linear(64, 5)

	def reset_state(self):
		self.rnn.reset_state()

	def __call__(self, x):
		x=self.embed(x)
		x=self.rnn(x.reshape((-1, 512)))
		x=functions.relu(self.linear(x))
		x=self.out(x)
		return x

class Classifier(chainer.Chain):
	def __init__(self, predictor):
		super(Classifier, self).__init__()
		with self.init_scope():
			self.predictor=predictor

	def __call__(self, x, t):
		x=self.predictor(x)

		t=t.reshape((params['word_cnt']*params['batch_size']))
		loss=functions.softmax_cross_entropy(x, t)
		accuracy=functions.accuracy(x, t)
		reporter.report({'loss': loss, 'accuracy': accuracy}, self)

		return loss, accuracy
```

```python
# controller.py
# 控制训练和测试的类
from network import Network, Classifier
import pickle, os, random
import thulac
import numpy as np

import chainer
from chainer import functions
from chainer import links
from chainer import training
from chainer.training import extensions

class Controller:
	def __init__(self, params):
		# dir_path contain data/ and label/
		self.params=params
		self.map={'.': 0}

	def process(self, path):
		datapath=path+'/data'
		labelpath=path+'/label'

		if os.path.exists(path+"/dataset.pkl"):
			dataset=pickle.load(open(path+"/dataset.pkl", "rb"))
			print("read dataset from .pkl")
			return dataset

		dataset=[]
		for file_step, filename in enumerate(os.listdir(datapath)):
			file_data=open(datapath+'/'+filename, "r")
			file_label=open(labelpath+'/'+filename, "r")
			sentences=file_data.read().split('\n')[:-1]
			labels=file_label.read().split('\n')[:-1]

			for index, (data_in, label_in) in enumerate(zip(sentences, labels)):
				if len(label_in)!=self.params['word_cnt']:
					print("warning: data block", len(label_in))
					continue
				data_in+='.'*(self.params['word_cnt']-len(data_in))
				data=[]
				for step, (char, sign) in enumerate(zip(data_in, label_in)):
					if char not in self.map:
						self.map[char]=len(self.map)
					data.append([self.map[char], int(sign)])
				dataset.append(data)

			print("#%04d file '%s', datasize %d*64 (%d)"%(file_step, filename, len(dataset), len(dataset)*64))
		random.shuffle(dataset)
		pickle.dump(dataset, open(path+"/dataset.pkl", "wb"))
		pickle.dump(self.map, open(self.params['save_path']+"/map.pkl", "wb"))
		return dataset

	def train(self):
		dataset={}
		dataset['test']=self.process(self.params['test_path'])
		dataset['train']=self.process(self.params['train_path'])

		batchset=[dataset['train'][step:step+self.params['batch_size']]\
			for step in range(0, len(dataset['train']-self.params['batch_size']+1), self.params['batch_size'])]

		self.net=Classifier(Network())
		self.optim=chainer.optimizers.Adam()
		self.optim.setup(self.net)

		for epoch in range(self.params['epoch']):
			batch={'data':[], 'label':[]}
			for step, batch in enumerate(batchset):
				batch=np.array(batch, dtype=int)
				data=batch[:,:,0]
				label=batch[:,:,1]

				self.net.predictor.reset_state()
				self.net.cleargrads()

				loss, accuracy=self.net(data, label)
				loss.backward()
				self.optim.update()

				print("#%08d step(epoch %02d) loss=%.8f accuracy=%.8f"%(step, epoch, loss.data, accuracy.data))
			if epoch%2==0:
				self.sendmail_try("#%02d epoch loss=%.8f accuracy=%.8f"%(epoch, loss.data, accuracy.data), "126")
		
		self.save()
		self.sendmail_try(self.params["name"]+" training done.", "126")

	def test(self):
		self.net=Network()
		self.load()

		while True:
			sentence=input(">> ")
			ifcontinue=False;x=[]
			for char in sentence:
				if char not in self.map:
					print(char, "not in map.")
					ifcontinue=True
					break
				else:
					x.append(self.map[char])
			if ifcontinue: continue
			self.net.reset_state()
			pred=self.net(np.array(x, dtype=int))
			for x, char in zip(pred.data, sentence):
				sign=np.where(x==x.max())[0][0]
				print(char, end='')
				if sign==2: print("/", end='')
			print('')

	def save(self):
		chainer.serializers.save_npz(self.params['save_path']+'/'+self.params['name']+'.model', self.net.predictor)
		chainer.serializers.save_npz(self.params['save_path']+'/'+self.params['name']+'.optim', self.optim)

	def load(self):
		chainer.serializers.load_npz(self.params['save_path']+'/'+self.params['name']+'.model', self.net)
		self.map=pickle.load(open(self.params['save_path']+"/map.pkl", "rb"))

	def sendmail_try(self, msg, mtype):
		try:
			self.sendmail(msg, mtype)
		except:
			pass

	def sendmail(self, msg, mtype):
		msg = MIMEText(msg, 'plain', 'utf-8')
		smtp=""
		if mtype=='163':
			smtp="smtp.163.com"
			sender_addr="...@163.com"
			password="..."
		elif mtype=='126':
			smtp="smtp.126.com"
			sender_addr="...@126.com"
			password="..."
		server = smtplib.SMTP(smtp, 25)
		server.set_debuglevel(1)
		server.login(sender_addr, password)
		server.sendmail(sender_addr, ["...@126.com"], msg.as_string())
		server.quit()
```
接下来拿去训练即可

### 模型测试
现在没什么时间了，其他模型等以后补完吧...
- 对第一个模型来说，正确率0.82
看起来还不错，其实结果真的不怎么的
幸好下面的贝叶斯分类器把尊严挽回了，不然又要在这费时间了