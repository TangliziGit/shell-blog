### 基础配置
CPU: Intel(R) Xeon(R) CPU E5-2682 v4 @ 2.50GHz * 16
MEM: 120 GiB
GPU: NVIDIA P100 * 2
OS: Ubuntu  18.04 64bit

### 环境配置
#### **GPU驱动 cuda cuDNN**
| | version | url | file |
| :-: | :-: | :-: | :-: |
| GPU Driver | Tesla P100 | https://www.nvidia.cn/Download/index.aspx |NVIDIA-Linux-x86_64-418.67.run  |
| cuda | 10.1 | https://developer.nvidia.com/cuda-downloads | cuda_10.1.168_418.67_linux.run |
| cuDNN | 7.6.2 for cuda10.1 | https://developer.nvidia.com/rdp/cudnn-download | cudnn-10.1-linux-x64-v7.6.2.24.tgz |

- GPU Driver
```bash
chmod +x NVIDIA-Linux-x86_64-418.67.run
./NVIDIA-Linux-x86_64-418.67.run
```
注意：
默认检查cc版本7.3，但本机是7.4，忽略即可
未发现Ｘ，如果Ｘ没有发现此驱动，需要安装pkg-cinfig和x.org sdk/development包
提醒32位未装

- cuda
```bash
chmod +x cuda_10.1.168_418.67_linux.run 
./cuda_10.1.168_418.67_linux.run
```

- cudnn
```bash
cp cudnn-10.1-linux-x64-v7.6.2.24.tgz /usr/local/
cd /usr/local/
tar xvf cudnn-10.1-linux-x64-v7.6.2.24.tgz 
ls cuda/lib64 | grep cudnn
```

环境变量:
```bash
# .bashrc
export PATH=$PATH:/usr/local/cuda-10.1/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64
```
  
  

#### **软件环境**

- python包
```bash
# 首先在本地生成项目的requirements.txt, 压缩上传
sudo pip3.6 install pipreqs
pipreqs Inverse-Reinforcement-Learning/
zip -r Inverse-Reinforcement-Learning.zip Inverse-Reinforcement-Learning/
scp Inverse-Reinforcement-Learning.zip root@39.104.56.54:~/

# 服务器上解压，安装对应包
unzip Inverse-Reinforcement-Learning.zip
apt install python3-pip  # 注意服务器上pip对应python2
pip3 install -r requirment.txt
```

- gnome & vnc
呃 我们的项目需要用到窗口来做交互 同时方便大家使用 尝试装个gnome
```bash
apt install gnome-session gdm3
# 待续
```

- jupyter notebook
```bash
pip3 install notebook
jupyter notebook --generate-config
```
```python
# ipython
from notebook.auth import passwd
passwd()     # 输入密码，复制该hash值
```
```
# vim ~/.jupyter/jupyter_notebook_config.py
c.NotebookApp.ip = '内网ip'             # 注意内网
c.NotebookApp.password = u'密码hash值'
c.NotebookApp.open_browser = False
c.NotebookApp.port =8888
c.NotebookApp.notebook_dir = '/root' 
```
```bash
screen -S jupyter_notebook
jupyter notebook --allow-root
<C-a> d
```
最后注意去ECS的控制台，**选中该实例**，添加一个允许8888/8888端口的自定义TCP安全组规则即可


### 遇到的问题
1. 在强化学习的过程中涉及到真正的游戏环境, 所以需要把窗口取消掉
```python
# 在pygame的环境下, 添加环境变量即可
os.environ["SDL_VIDEODRIVER"] = "dummy"
```

2. 同时音频虽然可以不用取消, 但由于总是报错, 屏幕上出现很多的ALSA报错信息.
第一次这么解决了, 但问题时python的tqdm信息也是通过错误信息提供的, 这样就把tqdm和真正的报错去掉了.
```bash
python3 xxx.py 2>/dev/null
```
这之后突然脑子上线, 用grep过滤掉ALSA的报错吧, 这样tqdm不会乱掉同时其他报错也都在, 缺点是这些信息都当做正常信息输出了
```bash
python3 xxx.py 1>&1 2>&1 | grep -v "ALSA" >&1
```
顺便一提, shell中双引号类似与python中的f"", 而单引号类似与r""