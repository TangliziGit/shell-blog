前几天认把感知机这一章读完了，顺带做了点笔记
现在把笔记做第三次的整理
（不得不说博客园的LaTex公式和markdown排版真的不太舒服，该考虑在服务器上建一个博客了）

### 零、总结
1. 适用于具有**线性可分的数据集的二分类问题**，可以说是很局限了
2. 感知机本质上是一个分离超平面
3. 在向量维数（特征数）过高时，选择对偶形式算法
在向量个数（样本数）过多时，应选择原始算法
4. 批量梯度下降和随机梯度下降的区别和优势
参考链接：[随机梯度下降（Stochastic gradient descent）和 批量梯度下降（Batch gradient descent ）的公式对比、实现对比](https://blog.csdn.net/lilyth_lilyth/article/details/8973972)
- 批量梯度下降(BGD, Batch Gradient Descent)
$ \theta \leftarrow \theta + \eta \sum \frac{\partial L}{\partial \theta}$
即多次做全局样本的参数更新
缺点：计算耗时
优点：可以趋向全局最优，受数据噪音影响少
- 随机梯度下降(SGD, Srochastic Gradient Descent)
$ \theta \leftarrow \theta + \eta \frac{\partial L}{\partial \theta}$
即多次做单个样本的参数更新
缺点：训练耗时较短
优点：不一定趋向全局最优（往往是最优/较优，单峰问题除外），受数据噪音影响大

### 一、模型
输入空间 $ \mathcal{X} \subseteq R^n $
输出空间 $ \mathcal{Y} \subseteq \{-1, +1\} $
假设空间 $ \mathcal{F} \subseteq \{f|f(x) = \omega \cdot x + b} $
参数 $ \omega \in R^n, b \in R $
模型 $ f(x) = sign(\omega \cdot x + b) $

其中
符号函数为
$$ sign(x)=\left\{\begin{matrix}
+1 , x \geqslant 0\\ 
-1 , x \geqslant 0
\end{matrix}\right. $$

线性方程 
$ \omega \cdot x + b $ 
可以表示为特征空间 $ R^n $中的一个分离超平面


### 二、策略
（定义的损失函数，并极小化损失函数）
（注意损失函数非负的性质）

为了使损失函数更**容易优化**，我们选择误分类点到超平面的距离作为损失函数
任意向量$x \in R^n$距分离超平面的距离为
$ S=\frac{1}{\|\omega\|}|\omega \cdot x + b| $

接下来优化一下这个距离，让它更好的成为一个损失函数
1. 为了**连续可导，去绝对值**
$ S=-\frac{1}{\|\omega\|} y_i(\omega \cdot x + b) $
2. 去掉不相关的系数（避免浪费计算），得到
$ L(\omega, b)=-\sum_{x_i \in M} y_i(\omega \cdot x + b) $
其中$ M $为误分类点集合


### 三、算法
（如何实现最优化问题）
注意最终训练出的模型参数的值取决于初值和误分类点的选取，所以一般值不同

为了极小化损失函数，我们采用梯度下降的方法
1. **原始形式算法**
- 赋初值 $ \omega \leftarrow 0 , b \leftarrow 0 $
- 选取数据点 $ (x_i, y_i) $
- 判断该数据点是否为当前模型的误分类点，即判断若$ y_i(\omega \cdot x + b) <=0 $
则更新
$$ \begin{matrix}
\omega &\leftarrow \omega + \eta  n_ix_iy_i   \\ 
b &\leftarrow b + \eta  n_iy_i
\end{matrix}$$
2. **对偶形式算法**
注意到原始形式算法中，最终训练好的模型参数是这样的，其中$ n_i $表示在第i个数据点上更新过几次
$$
\begin{matrix}
\omega &= \eta \sum_i n_ix_iy_i  \\ 
b &= \eta \sum_i n_iy_i
\end{matrix}
$$
于是我们可以作出以下简化
- 赋初值 $ n \leftarrow 0, b \leftarrow 0 $
- 选取数据点 $ (x_i, y_i) $
- 判断该数据点是否为当前模型的误分类点，即判断若$ y_i(\eta \sum n_iy_ix_i  \cdot x + b) <=0 $
则更新
$$ \begin{matrix}
n_i &\leftarrow n_i + 1  \\ 
b  &\leftarrow b + \eta y_i
\end{matrix}$$
为了减少计算量，我们可以预先计算式中的内积，得到Gram矩阵
$ G=[x_i, x_j]_{N \times N} $
3. **原始形式和对偶形式的选择**
相见知乎[如何理解感知机学习算法的对偶形式？](https://www.zhihu.com/question/26526858)
在向量维数（特征数）过高时，计算内积非常耗时，应选择对偶形式算法加速
在向量个数（样本数）过多时，每次计算累计和（对偶形式中的$\omega$）就没有必要，应选择原始算法

### 四、代码实现
因为感知机对数据要求很严格，为了实现这个模型，我用到了iris的数据集，用来给鸢尾花分类
又因为感知机只能做二分类，所以还是要把原数据的两个类别合并

为了学习numpy，还是用了python实现

```python
import numpy as np
from matplotlib import pyplot as plt

class Perceptron:
    # use the primitive algorithm
    arguments={
        "item_class":{
            "Iris-setosa": -1,
            "Iris-versicolor": 1,
            "Iris-virginica": 1,
        },
        "epoch": 800,
        "colors": ['blue', 'red'],
        "draw_start_x": 4,
        "draw_end_x": 7.5,
        "epsilon": 0.0,
        "learning_rate": 0.25,
    }

    def __init__(self, vec_dim, learning_rate=None, epsilon=None):
        # self.data=np.empty(dim)
        # self.counter=np.zeros(dim)
        self.data=None
        self.vec_dim=vec_dim
        self.lr=learning_rate
        if epsilon:
            self.epsilon=epsilon
        else:
            self.epsilon=self.arguments["epsilon"]
        if learning_rate:
            self.lr=learning_rate
        else:
            self.lr=self.arguments["learning_rate"]

        self.weight=np.zeros((self.vec_dim-1, 1))
        self.bias=0

    def read_data(self, filepath):
        raw_data=[]
        with open(filepath, "r") as file:
            for line in file.readlines():
                if line=='\n':
                    break
                item=line.replace('\n', '').split(',')
                itemc=self.arguments["item_class"][item[-1]]
                vec=[float(x) for x in item[0:2]]+[itemc]

                raw_data.append(vec)
        self.data=np.array(raw_data).T

    def process(self):
        # it is dual form
        vec=self.data[:, 0:2]
        self.gram=np.dot(vec, vec.T)

    def train(self):
        self.bias=0
        self.weight=np.zeros((self.vec_dim-1, 1))
        # self.counter=np.zeros(dim)
        for epoch in range(1, self.arguments["epoch"]+1):
            error_counter=0
            for idx in range(self.data.shape[1]):
                vec=self.data[:, idx]
                x, y=vec[0:-1, np.newaxis], vec[-1]
                if y*(np.dot(self.weight.T, x)+self.bias)<=self.epsilon:
                    self.weight+=self.lr*y*x
                    self.bias+=self.lr*y
                    error_counter+=1
            print("epoch #%03d: error:%03d total:%03d"%(
                epoch, error_counter, self.data.shape[1]))
            print("weight:", self.weight.ravel())
            print("bias:", self.bias, "\n")

            if error_counter==0:
                print("train done!")
                break

    def show(self):
        for idx in range(self.data.shape[1]):
            color=self.arguments["colors"][0]
            if self.data[2, idx]<0:
                color=self.arguments["colors"][1]
            plt.scatter(self.data[0, idx], self.data[1, idx], color=color)
        y=[-(self.weight[0, 0]*self.arguments["draw_start_x"] + self.bias)/self.weight[1, 0],
           -(self.weight[0, 0]*self.arguments["draw_end_x"] + self.bias)/self.weight[1, 0]]
        plt.plot([self.arguments["draw_start_x"], self.arguments["draw_end_x"]], y)
        plt.show()
```


> 更新了代码实现部分