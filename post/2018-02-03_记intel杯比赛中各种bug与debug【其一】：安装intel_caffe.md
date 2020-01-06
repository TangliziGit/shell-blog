因为intel杯创新软件比赛过程中，并没有任何记录。现在用一点时间把全过程重演一次用作记录。
学习 pytorch 一段时间后，intel比赛突然不让用 pytoch 了，于是打算转战intel caffe。

---
##ArchLinux 安装intel caffe 失败
首先安装caffe依赖，安装intel mkl，最后编译安装intel caffe
```bash
# yaourt -S caffe-git 这句话就可以直接安装caffe，但看起来不是intel caffe
git clone http://github.com/intel/caffe
cd caffe
cp Makefile.config.example Makefile.config
nano Makefile
make all -j4
```
安装intel mkl时出现问题，发现其不支持arch，问题挺多不如直接安装一个ubuntu
然后转战ubuntu，正好家里有一个旧的移动硬盘
云备份数据，安装ubuntu

---
##Ubuntu16.04 安装intel caffe成功
这里ubuntu的安装就不写了
主要注意旧硬盘需要写gpt分区表，若用于efi启动，需要fat32格式的/boot/efi

caffe安装参考：<https://software.intel.com/zh-cn/articles/training-and-deploying-deep-learning-networks-with-caffe-optimized-for-intel-architecture>
一样首先安装依赖
```bash
sudo apt-get update &&
sudo apt-get -y install build-essential git cmake &&
sudo apt-get -y install libprotobuf-dev libleveldb-dev libsnappy-dev &&
sudo apt-get -y install libopencv-dev libhdf5-serial-dev protobuf-compiler &&
sudo apt-get -y install --no-install-recommends libboost-all-dev &&
sudo apt-get -y install libgflags-dev libgoogle-glog-dev liblmdb-dev &&
sudo apt-get -y install libatlas-base-dev
```
对于Ubantu16.04，链接库
```bash
find .-type f -exec sed -i -e 's^"hdf5.h"^"hdf5/serial/hdf5.h"^g' -e 's^"hdf5_hl.h"^"hdf5/serial/hdf5_hl.h"^g' '{}' ;
cd /usr/lib/x86_64-linux-gnu
sudo ln -s libhdf5_serial.so.10.1.0 libhdf5.so
sudo ln -s libhdf5_serial_hl.so.10.0.2 libhdf5_hl.so
```
安装intel mkl
首先免费[注册申请](https://software.seek.intel.com/performance-libraries)Intel® Performance Libraries
注册成功会受到一封邮件
![](http://images2017.cnblogs.com/blog/1225237/201802/1225237-20180203134640000-106762300.png)
下载并按.sh安装，安装过程略了
于是开始调整config，编译
```bash
git clone http://github.com/intel/caffe
cd caffe
cp Makefile.config.example Makefile.config
nano Makefile
make all -j4
```
附上Makefile.config
主要处理mkl，python路径
```makefile
# Makefile.config

# cuDNN acceleration switch (uncomment to build with cuDNN).
# USE_CUDNN := 1

# CPU-only switch (uncomment to build without GPU support).
CPU_ONLY := 1

USE_MKL2017_AS_DEFAULT_ENGINE := 1
# or put this at the top your train_val.protoxt or solver.prototxt file:
# engine: "MKL2017" 
# or use this option with caffe tool:
# -engine "MKL2017"

# USE_MKLDNN_AS_DEFAULT_ENGINE := 1
# Put this at the top your train_val.protoxt or solver.prototxt file:
# engine: "MKLDNN" 
# or use this option with caffe tool:
# -engine "MKLDNN"

# uncomment to disable IO dependencies and corresponding data layers
# USE_OPENCV := 0
# USE_LEVELDB := 0
# USE_LMDB := 0

# uncomment to allow MDB_NOLOCK when reading LMDB files (only if necessary)
#	You should not set this flag if you will be reading LMDBs with any
#	possibility of simultaneous read and write
# ALLOW_LMDB_NOLOCK := 1

# Uncomment if you're using OpenCV 3
# OPENCV_VERSION := 3

# To customize your choice of compiler, uncomment and set the following.
# N.B. the default for Linux is g++ and the default for OSX is clang++
# CUSTOM_CXX := g++

# If you use Intel compiler define a path to newer boost if not used
# already. 
# BOOST_ROOT := 

# Use remove batch norm optimization to boost inference
DISABLE_BN_FOLDING := 0

#Use conv/eltwise/relu layer fusion to boost inference.
DISABLE_CONV_SUM_FUSION := 0
# Intel(r) Machine Learning Scaling Library (uncomment to build
# with MLSL for multi-node training)
# USE_MLSL :=1

# CUDA directory contains bin/ and lib/ directories that we need.
CUDA_DIR := /usr/local/cuda
# On Ubuntu 14.04, if cuda tools are installed via
# "sudo apt-get install nvidia-cuda-toolkit" then use this instead:
# CUDA_DIR := /usr

# CUDA architecture setting: going with all of them.
# For CUDA < 6.0, comment the *_50 lines for compatibility.
CUDA_ARCH := -gencode arch=compute_20,code=sm_20 \
	     -gencode arch=compute_20,code=sm_21 \
	     -gencode arch=compute_30,code=sm_30 \
	     -gencode arch=compute_35,code=sm_35 \
	     -gencode arch=compute_50,code=sm_50 \
	     -gencode arch=compute_50,code=compute_50

# BLAS choice:
# atlas for ATLAS (default)
# mkl for MKL
# open for OpenBlas
BLAS := mkl
# Custom (MKL/ATLAS/OpenBLAS) include and lib directories.
# Leave commented to accept the defaults for your choice of BLAS
# (which should work)!
BLAS_INCLUDE := /opt/intel/mkl/include
BLAS_LIB := /opt/intel/mkl/lib/intel64

# Homebrew puts openblas in a directory that is not on the standard search path
# BLAS_INCLUDE := $(shell brew --prefix openblas)/include
# BLAS_LIB := $(shell brew --prefix openblas)/lib

# This is required only if you will compile the matlab interface.
# MATLAB directory should contain the mex binary in /bin.
# MATLAB_DIR := /usr/local
# MATLAB_DIR := /Applications/MATLAB_R2012b.app

SERIAL_HDF5_INCLUDE := /usr/include/hdf5/serial/

# NOTE: this is required only if you will compile the python interface.
# We need to be able to find Python.h and numpy/arrayobject.h.
PYTHON_INCLUDE := /usr/include/python2.7 \
		/usr/lib/python2.7/dist-packages/numpy/core/include
# Anaconda Python distribution is quite popular. Include path:
# Verify anaconda location, sometimes it's in root.
# ANACONDA_HOME := $(HOME)/anaconda
# PYTHON_INCLUDE := $(ANACONDA_HOME)/include \
		# $(ANACONDA_HOME)/include/python2.7 \
		# $(ANACONDA_HOME)/lib/python2.7/site-packages/numpy/core/include \

# Uncomment to use Python 3 (default is Python 2)
PYTHON_LIBRARIES := boost_python3 python3.5m
PYTHON_INCLUDE := /usr/include/python3.5m \
                 /usr/lib/python3.5/dist-packages/numpy/core/include

# We need to be able to find libpythonX.X.so or .dylib.
PYTHON_LIB := /usr/lib
# PYTHON_LIB := $(ANACONDA_HOME)/lib

# Homebrew installs numpy in a non standard path (keg only)
# PYTHON_INCLUDE += $(dir $(shell python -c 'import numpy.core; print(numpy.core.__file__)'))/include
# PYTHON_LIB += $(shell brew --prefix numpy)/lib

# Uncomment to support layers written in Python (will link against Python libs)
WITH_PYTHON_LAYER := 1

# Whatever else you find you need goes here.
INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial/
LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/hdf5/serial

# If Homebrew is installed at a non standard location (for example your home directory) and you use it for general dependencies
# INCLUDE_DIRS += $(shell brew --prefix)/include
# LIBRARY_DIRS += $(shell brew --prefix)/lib

# Uncomment to use `pkg-config` to specify OpenCV library paths.
# (Usually not necessary -- OpenCV libraries are normally installed in one of the above $LIBRARY_DIRS.)
# USE_PKG_CONFIG := 1

# N.B. both build and distribute dirs are cleared on `make clean`
BUILD_DIR := build
DISTRIBUTE_DIR := distribute

# Uncomment to enable training performance monitoring
# PERFORMANCE_MONITORING := 1

# Uncomment for debugging. Does not work on OSX due to https://github.com/BVLC/caffe/issues/171
# DEBUG := 1

# Uncomment to disable OpenMP support.
# USE_OPENMP := 0

# The ID of the GPU that 'make runtest' will use to run unit tests.
TEST_GPUID := 0

# enable pretty build (comment to see full commands)
Q ?= @

```
编译过程中会出现一些warning，然而发现并没有什么大问题
至此intel caffe安装成功

安装成功后
1.注意添加export PYTHONPATH=$PYTHONPATH:=&lt;your caffe path&gt;/python
不然会有如下报错
```python
import caffe
#Traceback (most recent call last):
#  File "<stdin>", line 1, in <module>
#  File "/usr/local/lib/python3.5/dist-packages/caffe/__init__.py", line 37, in <module>
#    from .pycaffe import Net, SGDSolver, NesterovSolver, AdaGradSolver, RMSPropSolver, AdaDeltaSolver, AdamSolver
#  File "/usr/local/lib/python3.5/dist-packages/caffe/pycaffe.py", line 49, in <module>
#    from ._caffe import Net, SGDSolver, NesterovSolver, AdaGradSolver, \
#ImportError: libcaffe.so.1.1.0: cannot open shared object file: No such file or directory

```
2.注意使用python2.7
如果使用python3
```python
import caffe
#Traceback (most recent call last):
#  File "<stdin>", line 1, in <module>
#  File "/home/tanglizi/caffe/python/caffe/__init__.py", line 37, in <module>
#    from .pycaffe import Net, SGDSolver, NesterovSolver, AdaGradSolver, RMSPropSolver, AdaDeltaSolver, AdamSolver
#  File "/home/tanglizi/caffe/python/caffe/pycaffe.py", line 49, in <module>
#    from ._caffe import Net, SGDSolver, NesterovSolver, AdaGradSolver, \
#ImportError: dynamic module does not define module export function (PyInit__caffe)

```
3.顺便把caffe链接到/usr/bin下面，方便使用
```bash
ln -s <your caffe path>/build/tools/caffe /usr/bin/
```