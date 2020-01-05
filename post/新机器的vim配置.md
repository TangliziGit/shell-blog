最近一直用vim去写acm代码，算是一种练习吧。
用着用着感觉不错，最近也稍微配置了一下vim，用着更舒服了

### 键盘映射 ESC<->CapsLock
我们知道vim有自带的键盘映射命令，但是像CapsLock这样的按键是不能去映射的
那么于是用到xmodmap来进行键盘映射，详见<https://wiki.archlinux.org/index.php/xmodmap>
```
xmodmap ~/.xmodmaprc
```
```
! .xmodmaprc
! 首先去掉Lock的修饰按键
clear Lock
keysym Caps_Lock = Escape
keysym Escape = Caps_Lock
! 然后加上Lock的修饰
add Lock = Caps_Lock
```
但是这样做开机的时候还要重新用xmodmap，十分不便
看到开机自启的wiki<https://wiki.archlinux.org/index.php/Autostarting>
于是检查/etc/X11/xinit/xinitrc，发现x使用$HOME/.Xmodmap来自启
所以只需要mv .xmodmaprc .Xmodmap即可

### 插件管理工具Vundle的安装与配置
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
安装完成后，即可通过.vimrc进行配置，[参考此处](http://blog.csdn.net/zhangpower1993/article/details/52184581)
```
set nocompatible              " 去除VI一致性
filetype off                  " 必须要添加

" 设置包括vundle和初始化相关的runtime path
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 另一种选择, 指定一个vundle安装插件的路径
"call vundle#begin('~/some/path/here')

" 让vundle管理插件版本,必须
Plugin 'VundleVim/Vundle.vim'

" 以下范例用来支持不同格式的插件安装.
" 请将安装插件的命令放在vundle#begin和vundle#end之间.
" Github上的插件
" 格式为 Plugin '用户名/插件仓库名'
Plugin 'tpope/vim-fugitive'
" 来自 http://vim-scripts.org/vim/scripts.html 的插件
" Plugin '插件名称' 实际上是 Plugin 'vim-scripts/插件仓库名' 只是此处的用户名可以省略
Plugin 'L9'
" 由Git支持但不再github上的插件仓库 Plugin 'git clone 后面的地址'
Plugin 'git://git.wincent.com/command-t.git'
" 本地的Git仓库(例如自己的插件) Plugin 'file:///+本地插件仓库绝对路径'
Plugin 'file:///home/xxx/path/to/plugin'
" 正确指定路径用以设置runtimepath. 以下范例插件在sparkup/vim目录下
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" 安装L9，如果已经安装过这个插件，可利用以下格式避免命名冲突
Plugin 'ascenator/L9', {'name': 'newL9'}

" 你的所有插件需要在下面这行之前
call vundle#end()            " 必须
filetype plugin indent on    " 必须 加载vim自带和插件相应的语法和文件类型相关脚本
" 忽视插件改变缩进,可以使用以下替代:
"filetype plugin on
"
" :PluginList       - 列出所有已配置的插件
" :PluginInstall     - 安装插件,追加 `!` 用以更新或使用 :PluginUpdate
" :PluginSearch foo - 搜索 foo ; 追加 `!` 清除本地缓存
" :PluginClean      - 清除未使用插件,需要确认; 追加 `!` 自动批准移除未使用插件
" 查阅 :h vundle 获取更多细节和wiki以及FAQ
```

我们希望使用vim-multiple-cursors用来模拟sublime_text3的&lt;C-d&gt;
那么就这样配置
```
" .vimrc
set nocompatible
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-multiple-cursors'
call vundle#end()
```
```
:PluginInstall vim-multiple-cursors
```

然而安装完后，进入vim时的模式变成replace了，正常模式也变成vi的操作了
于是接着想直接换spf13-vim，懒得再配置了 :P

### spf13-vim安装和简单配置
github地址：<https://github.com/spf13/spf13-vim>
官网：<http://vim.spf13.com/>
直接安装即可
```
curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh
```

安装好然后换一下主题
官方并不建议调整.vimrc，需要覆盖或者重新配置的话请配置~/.vimrc.local或者~/.gvimrc.local
```
echo colorscheme gruvbox > ~/.vimrc.local
```

虽然插件很多，但是我用的并不多，简单记录一下用法好了
- NERDTree
一个文件管理器的插件，在vim的左边分屏显示

按键|描述
:-|:-
ctrl-e|打开文件管理器
jk,hl|光标移动
o|打开目录
u|进入上一目录
C|进入选定目录
ctrl+ww|分屏操作，光标移动到另一区域
ctrl+wλ|λ可为hjkl，分屏操作，光标移动到指定方向

- vim-multiple-cursors
多光标操作，类似sublime的Ctrl-d，非常好用

按键|描述
:-|:-
ctrl-n|多光标操作，visual模式下用c删除

- EastMotion
更灵活的跳转命令，样式详见<http://blog.csdn.net/liuhhaiffeng/article/details/52450729>

按键|描述
:-|:-
,,w|跳转到光标前的某位置
,,b|跳转到光标后的某位置
,,s|跳转到需要搜索的一个字符的某位置，有点像f/F