安装arch后就没再用python了
昨天管服务器的大佬在跑贝叶斯分类器的时候发现正确率有问题
我赶紧去做优化，然后就有这样的报错

```python
Python 3.6.4 (default, Jan  5 2018, 02:35:40) 
[GCC 7.2.1 20171224] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("中文")
  File "<stdin>", line 0
    ^
SyntaxError: 'ascii' codec can't decode byte 0xe4 in position 7: ordinal not in range(128)
>>> 
```

我很费解啊，用了各种encode，decode没用啊
**最后发现$LANG不正常**

```shell
tanglizi@archlinux:~$ echo $LANG
C
```

尴尬，安装arch的时候光注意做引导了，忘了locale-gen
于是修改LANG试了试，没什么问题

```shell
tanglizi@archlinux:~$ LANG=en_US.UTF-8 python
Python 3.6.4 (default, Jan  5 2018, 02:35:40) 
[GCC 7.2.1 20171224] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print("中文")
中文
>>> 
```

结果就是LANG不正确，对arch用户如下配置即可
```shell
vim /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
```