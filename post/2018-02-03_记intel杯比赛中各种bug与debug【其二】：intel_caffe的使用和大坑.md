放弃使用pytorch，学习caffe
本文仅记录个人观点，不免存在许多错误

---
## Caffe 学习
caffe模型生成需要如下步骤
- 编写network.prototxt
- 编写solver.prototxt
- caffe train -solver=solver.prototxt

### network.prototxt编写
在caffe中，Net由Layer构成，其中数据由Blob进行传递
network编写就是组织layer
关于layer如何编写，参考[caffe.proto](https://github.com/BVLC/caffe/blob/master/src/caffe/proto/caffe.proto)
这里写出layer一般形式

```bash
layer{
    name: "layer name"
    type: "layer type"
    bottom: "bottom blob"
    top: "top blob"
    param{
        ...
    }
    include{ phase: ... }
    exclude{ phase: ... }
    # 对某一type的layer参数, 这里以内积层为例
    inner_product_param{
        num_output: 64
        weight_filler{
            type: "xavier"
        }
        bias_filler{
            type: "constant"
            value: 0
        }
        axis=1
    }
}
```

在这里简要说一下我们的目的，
通过中文分词rnn和贝叶斯分类器实现一个垃圾信息处理的功能
这里直接附上我的network好了，反正没人看: (

```bash
# project for chinese segmentation
#	T: 64,	batch: 64
#	label[T*batch, 1, 1, 1]	cont[T*batch, 1, 1, 1]=0 or 1
#	data[T*batch, 1, 1, 1] ->
#	embed[T*batch, 2000, 1, 1](drop&reshape) -> [T, batch, 2000, 1]
#	lstm[T, batch, 256, 1](drop) ->
#	ip[T, batch, 64, 1](relu) ->
#	ip[T, batch, 5, 1] ->
#	Accuracy & SoftMaxWithLoss
# for output: 0-none, 1-Signal, 2-Begin, 3-Middle, 4-End


name: "Segment"

# train data
layer{
	name: "train_data"
	type: "HDF5Data"
	top: "data"
	top: "label"
	top: "cont"
	include{ phase: TRAIN }
	hdf5_data_param{
		source: "/home/tanglizi/caffe/projects/data_segment/h5_test.txt"
		batch_size: 4096
		shuffle: true
	}
}
# test data
layer{
	name: "test_data"
	type: "HDF5Data"
	top: "data"
	top: "label"
	top: "cont"
	include{ phase: TEST }
	hdf5_data_param{
		source: "/home/tanglizi/caffe/projects/data_segment/h5_test.txt"
		batch_size: 4096
		shuffle: true
	}
}

# embed
layer{
	name: "embedding"
	type: "Embed"
	bottom: "data"
	top: "embedding"
	param{
		lr_mult: 1
	}
	embed_param{
		input_dim: 14000
		num_output: 2000
		weight_filler {
			type: "uniform"
			min: -0.08
			max: 0.08
		}
	}
}
# embed-drop
layer{
	name: "embed-drop"
	type: "Dropout"
	bottom: "embedding"
	top: "embed-drop"
	dropout_param{
		dropout_ratio: 0.05
	}
}


# reshape
# embed
# [T*batch, 2000, 1, 1] ->
# [T, batch, 2000, 1]
layer{
	name: "embed-reshape"
	type: "Reshape"
	bottom: "embed-drop"
	top: "embed-reshaped"
	reshape_param{
		shape{
			dim: 64
			dim: 64
			dim: 2000
		}
	}
}

# label
layer{
	name: "label-reshape"
	type: "Reshape"
	bottom: "label"
	top: "label-reshaped"
	reshape_param{
		shape{
			dim: 64
			dim: 64
			dim: 1
		}
	}
}

# cont
layer{
	name: "cont-reshape"
	type: "Reshape"
	bottom: "cont"
	top: "cont-reshaped"
	reshape_param{
		shape{
			dim: 64
			dim: 64
		}
	}
}


# lstm
layer{
	name: "lstm"
	type: "LSTM"
	bottom: "embed-reshaped"
	bottom: "cont-reshaped"
	top: "lstm"
	recurrent_param{
		num_output: 256
		weight_filler{
			# type: "xavier"
			type: "uniform"
			min: -0.08
			max: 0.08
		}
		bias_filler{
			type: "constant"
			value: 0
		}
	}
}

# lstm-drop
layer{
	name: "lstm1-drop"
	type: "Dropout"
	bottom: "lstm"
	top: "lstm-drop"
	dropout_param{
		dropout_ratio: 0.05
	}
}

# connect
# ip1
layer{
	name: "ip1"
	type: "InnerProduct"
	bottom: "lstm-drop"
	top: "ip1"
	param{
		lr_mult: 1
		decay_mult: 1
	}
	param{
		lr_mult: 2
		decay_mult: 0
	}
	inner_product_param{
		num_output: 64
		weight_filler{
			type: "xavier"
		}
		bias_filler{
			type: "constant"
			value: 0
		}
		axis: 2
	}
}
# relu
layer{
	name: "relu1"
	type: "ReLU"
	bottom: "ip1"
	top: "relu1"
	relu_param{
		negative_slope: 0
	}
}

# ip2
layer{
	name: "ip2"
	type: "InnerProduct"
	bottom: "relu1"
	top: "ip2"
	param{
		lr_mult: 1
	}
	param{
		lr_mult: 2
	}
	inner_product_param{
		num_output: 5
		weight_filler{
			type: "xavier"
		}
		bias_filler{
			type: "constant"
			value: 0
		}
		axis: 2
	}
}


# loss
layer{
	name: "loss"
	type: "SoftmaxWithLoss"
	bottom: "ip2"
	bottom: "label-reshaped"
	top: "loss"
	softmax_param{
		axis: 2
	}
}

# accuracy
layer{
	name: "accuracy"
	type: "Accuracy"
	bottom: "ip2"
	bottom: "label-reshaped"
	top: "accuracy"
	accuracy_param{
		axis: 2
	}
}
```

### solver.prototxt编写
solver用于调整caffe训练等操作的超参数
solver如何编写，参考[caffe.proto](https://github.com/BVLC/caffe/blob/master/src/caffe/proto/caffe.proto)
附上一般写法

```bash
net: "network.proto"

test_iter: 100
test_interval: 500

type: "Adam"
base_lr: 0.01
weight_decay: 0.0005

lr_policy: "inv"

display: 100
max_iter: 10000

snapshot: 5000
snapshot_prefix: "/home/tanglizi/caffe/projects/segment/"

solver_mode: CPU
```

### 训练模型

```bash
caffe train -solver=solver.prototxt
```
这时可能报错:
Message type "caffe.MultiPhaseSolverParameter" has no field named "net".
请注意不是没有net，而是其他参数设置有误
intel caffe特有的报错

---
## Caffemodel 的使用
模型训练的结果很有问题，accuracy非常低，感觉又是network写错了
于是想看看其中发生了什么
caffemodel可以通过c++或python matlab接口来使用
接下来进入intel caffe 和intel devcloud**大坑**

### pycaffe的使用
注意：以下python代码在devcloud进行
首先我们知道caffe模型就是训练好的一个神经网络
于是必然需要caffe.Net()来读取caffemodel和net.prototxt，需要caffe.io读取数据

```python
import caffe
from caffe import io
# 这时报错：
#Traceback (most recent call last):
#  File "<stdin>", line 1, in <module>
#ImportError: cannot import name 'io'
```

连忙查看caffe里面有什么

```python
dir(caffe)
# 显示 ['__doc__', '__loader__', '__name__', '__package__', '__path__', '__spec__']
# 正常显示 ['AdaDeltaSolver', 'AdaGradSolver', 'AdamSolver', 'Classifier', 'Detector', 'Layer', 'NesterovSolver',
#  'Net', 'NetSpec', 'RMSPropSolver', 'SGDSolver', 'TEST', 'TRAIN', '__builtins__', '__doc__', '__file__', '__name__',
#  '__package__', '__path__', '__version__', '_caffe', 'classifier', 'detector', 'get_solver', 'init_log', 'io', 'layer_type_list',
#  'layers', 'log', 'net_spec', 'params', 'proto', 'pycaffe', 'set_device', 'set_mode_cpu', 'set_mode_gpu', 'set_random_seed', 'to_proto']

```
淦，根本什么都没有
由于我们的项目需要必须在服务器上进行，所以不考虑在本地机器上运行
现在有两条路：重新编译一个caffe 或用c++实现
懒得搞事情，选择c++实现

### c++中使用caffemodel
注：以下过程使用intel caffe
首先我们知道caffe模型就是训练好的一个神经网络
于是必然需要caffe.Net()来读取caffemodel和net.prototxt

```c++
// predict.cpp
#include <caffe/caffe.hpp>
boost::shared_ptr< Net<float> > net(new caffe::Net<float>(net, Caffe::TEST));
```

1. 开始手动编译
```bash
    # 注意到caffe.hpp的位置，我们添加路径即可
    clang++ -I <caffe path>/include -lboost_system predict.cpp -o predict
    #不料报错
    #/tmp/predict-fea879.o: In function 'main':
    #predict.cpp:(.text+0x35b): undefined reference to 'caffe::Net<int>::Net(std::__cxx11::basic_string<char, std::char_traits<char>, 
    #std::allocator<char> > const&, caffe::Phase, int, std::vector<std::__cxx11::basic_string<char, std::char_traits<char>, 
    #std::allocator<char> >, std::allocator<std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > > > const*,
    # caffe::Net<int> const*, std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >)'
    #clang: error: linker command failed with exit code 1 (use -v to see invocation)
  
    # 看起来找不到libcaffe，添加路径即可
    clang++ -I <caffe path>/include -lboost_system predict.cpp -o predict -L <caffe path>/build/lib -lcaffe
    # 不料报错 错误相同
```

2. 放弃手动编译，放在examples/下重新编译caffe
不料报错 错误相同
3. 放在tools/下(caffe.cpp的位置)重新编译caffe
直接跳过跳过编译predict.cpp
烦 放弃本地使用c++
4. 在devcloud上手动编译
不料报错 错误相同
云上都编译不了我还干chua
5. 重新编译intel caffe
按照环境重新配置Makefile.config
编译报错
```bash
In file included from .build_release/src/caffe/proto/caffe.pb.cc:5:0:  
.build_release/src/caffe/proto/caffe.pb.h:12:2: error: #error This file was generated by a newer version of protoc which is  
 #error This file was generated by a newer version of protoc which is  
.build_release/src/caffe/proto/caffe.pb.h:13:2: error: #error incompatible with your Protocol Buffer headers. Please update  
 #error incompatible with your Protocol Buffer headers.  Please update  
.build_release/src/caffe/proto/caffe.pb.h:14:2: error: #error your headers.  
 #error your headers.  
.build_release/src/caffe/proto/caffe.pb.h:22:35: fatal error: google/protobuf/arena.h: No such file or directory
 #include <google/protobuf/arena.h>  
```

查了一下，此处需要libprotoc 2.6.1，然而devcloud上libprotoc 3.2.0
烦死了
于是查到这个[文章](http://blog.csdn.net/qq_32768743/article/details/79173854)，在此十分感谢 @大黄老鼠 同学！！！
好了现在完全放弃caffe了！
转战chainer！