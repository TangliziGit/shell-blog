
<!-- vim-markdown-toc Marked -->

* [ASC Suplementary 5](#asc-suplementary-5)
    * [Project Migration](#project-migration)
        * [Code](#code)
        * [Dataset](#dataset)
        * [Python Environment](#python-environment)
        * [CUDA Environment](#cuda-environment)

<!-- vim-markdown-toc -->

# ASC Suplementary 5 

## Project Migration

由于2\*P100节点网络需要再次配置, 目前连不上公网.  
由于项目部分使用`git`控制, 现在这个节点难以同步代码.  
但是V100的`gpu1`节点可以连接公网, 于是做一次项目迁移.  

### Code

代码部分用`git`控制, 同步简单.  
```bash
git clone https://gitee.com/TangliziGit/ASC20-ELE
```


### Dataset 

`/data`和`/checkpoints`文件夹由于数据量太大, 故一开始就在同步设置中排除掉了.  
那么只能用`scp`移动, 需要花费很长时间.  
```bash
scp -r asc20@202.117.249.199:~/data/zhangcx/ele/data .
scp -r asc20@202.117.249.199:~/data/zhangcx/ele/checkpoints .
```

### Python Environment

```bash 
pip install --editable .
```

You may get a error message below:  

>                                !! WARNING !!
>    
>    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
>    Your compiler (g++ 4.8.5) may be ABI-incompatible with PyTorch!
>    Please use a compiler that is ABI-compatible with GCC 4.9 and above.
>    See https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html.
>    
>    See https://gist.github.com/goldsborough/d466f43e8ffc948ff92de7486c5216d6
>    for instructions on how to install GCC 4.9 or higher.
>    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

If the message appears, install GCC with higher version beforehead.  
```bash
sudo yum -y install centos-release-scl
sudo yum -y install devtoolset-7-gcc*
scl enable devtoolset-7 bash
```


### CUDA Environment 

For better profermance, cuda 10.1 is needed.  
```bash
sudo bash cuda_10.1.105_418.39_linux.run
sudo tar xf cudnn-10.1-linux-x64-v7.6.4.38.tgz -C /usr/local
```

You may get a error logging below:  
> [INFO]: ERROR: You appear to be running an X server; please exit X before
> [INFO]:        installing.  For further details, please see the section INSTALLING
> [INFO]:        THE NVIDIA DRIVER in the README available on the Linux driver
> [INFO]:        download page at www.nvidia.com.

you can run this command, and get another error:  
```bash 
systemctl stop gdm
```

> [INFO]: ERROR: An NVIDIA kernel module 'nvidia' appears to already be loaded in
> [INFO]:        your kernel.  This may be because it is in use (for example, by an X
> [INFO]:        server, a CUDA program, or the NVIDIA Persistence Daemon), but this
> [INFO]:        may also happen if your kernel was configured without support for
> [INFO]:        module unloading.  Please be sure to exit any programs that may be
> [INFO]:        using the GPU(s) before attempting to upgrade your driver.  If no
> [INFO]:        GPU-based programs are running, you know that your kernel supports
> [INFO]:        module unloading, and you still receive this message, then an error
> [INFO]:        may have occured that has corrupted an NVIDIA kernel module's usage
> [INFO]:        count, for which the simplest remedy is to reboot your computer.

So, i try to unload nvidia module `sudo modprobe -r nvidia`, but get error:  
> modprobe: FATAL: Module nvidia is in use.

So, i checked the nvidia module status `lsmod | grep nvidia`, get this:  
```
nvidia              13169562  15 
i2c_core               40756  6 ast,drm,i2c_i801,drm_kms_helper,i2c_algo_bit,nvidia
```
It shows that nvidia module has been used by 15 processes, and `i2c_core` depends on `nvidia` module.  

To kill all the processes who using the module, i find some processes named `irq/290-nvidia`, `irq/291-nvidia` or `irq/292-nvidia`.  
Those processes are IRQ process, it seems can not be kill, because they are kernel threads.  

So, I will try the commands below, to boot OS without load nvidia and install the new driver, and recovery the status.  
Or, try to use `nvidia-docker`.  
```
sudo systemctl set-default multi-user.target
sudo reboot

sudo ./NVIDIA-Linux-x86_64-440.44.run
sudo systemctl set-default graphical.target
sudo reboot
```
