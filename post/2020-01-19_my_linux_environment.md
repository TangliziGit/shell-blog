<!-- vim-markdown-toc Marked -->

* [My Linux Environment](#my-linux-environment)
    * [Configuration files](#configuration-files)
    * [Software sources](#software-sources)
        * [apt](#apt)
    * [Proxy](#proxy)
        * [ssh](#ssh)
        * [electron-ssr](#electron-ssr)
        * [proxychains4](#proxychains4)
    * [Shell](#shell)
        * [zsh](#zsh)
    * [Editor](#editor)
        * [SpaceVim](#spacevim)
        * [markdown plugins](#markdown-plugins)
        * [typora](#typora)
    * [Conda](#conda)
        * [pip](#pip)

<!-- vim-markdown-toc -->

# My Linux Environment

To connect to the college cluster, `EasyConnect` should be used.
But in `archlinux`, it not works well.
So i installed an ubuntu on a new USB disk, to access the cluster.
In this file, i will record the process of configuring my new and simplest linux environment.

## Configuration files
```
.zshrc
.SpaceVim/init.toml
.SpaceVim.d/autoload/config.vim
/etc/apt/sources.list
/etc/proxychains.conf
.condarc
.pip/pip.conf
```

## Software sources

### apt
`/etc/apt/source.list`:
```
# aliyun
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

```


## Proxy

### ssh
```
cp -r /mnt/tanglizi/.ssh .
```

### electron-ssr
latest version: <https://github.com/qingshuisiyuan/electron-ssr-backup/releases/download/v0.2.6/electron-ssr-0.2.6.deb>.
use your proxy server to download it via ssh.
```
sudo apt install ./electron-ssr-0.2.6.deb
```

### proxychains4
```
git clone https://github.com/rofl0r/proxychains-ng.git
cd proxychains-ng
sudo ./configure --prefix=/usr/local
sudo make install
```

## Shell

### zsh
1. install zsh: `sudo apt install zsh`
2. install `oh-my-zsh`: `sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"`
3. install plugins:
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```


## Editor

### SpaceVim
```
wget https://spacevim.org/install.sh
sudo apt install curl
bash install.sh
```
then enter `vim`, to trigger the plugins installing process.

### markdown plugins
Refer the pervious note `take_notes_with_vim_markdown.md`.

### typora
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA300B7755AFCFAE
sudo add-apt-repository 'deb https://typora.io ./linux/'
sudo apt-get update
sudo apt-get install typora
```

## Conda
<https://docs.conda.io/en/latest/miniconda.html>
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```
then configure your `.zshrc`:
```
export 
```
then add tsinghua source, as `~/.condarc`:
```
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

### pip
in `~/.pip/pip.conf`
```
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```
