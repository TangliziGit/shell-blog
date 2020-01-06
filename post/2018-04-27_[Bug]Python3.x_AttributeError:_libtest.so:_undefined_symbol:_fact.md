写kNN，需要在python中实现kd-tree
思考了一下，在python下写这种算法类的东西，还是十分别扭
于是希望用ctypes调用一下c++动态加载库

于是尝试实现一下
```c++
// test.cpp
long long fact(int n){
    return (n<=0):1:(fact(n-1)*n);
}

// gcc -shared -fpic test.cpp  -o libtest.so
```

```python
// test.py
import ctypes

lib=ctypes.cdll.LoadLibrary("libtest.so")
print(lib.fact(10))

```

于是报错
```
Traceback (most recent call last):                              
  File "<stdin>", line 1, in <module>                    
  File "/usr/lib/python3.6/ctypes/__init__.py", line 361, in __getattr__
    func = self.__getitem__(name)                    
  File "/usr/lib/python3.6/ctypes/__init__.py", line 366, in __getitem__
    func = self._FuncPtr((name_or_ordinal, self))
AttributeError: libtest.so: undefined symbol: fact 
```
最后百度发现原因是**c++的编译后，函数名会被改变（为了实现重载）**
**用extern "C"声明后，就会使用c的方式进行编译，编译后的文件中仍然是定义的函数名**

解决方法
1. 改后缀为.c
2. 声明为"C", 以c方式编译即可

```c++
// test,cpp
// g++ -fpiv -shared test.cpp -o libtest.so
extern "C"{
    long long fact(int);
}

long long fact(int n){
    return (n<=0):1:(fact(n-1)*n);
}
```