笔记本不知道怎么了，总是时间对不上
硬件时间也设置不了，只能时间同步了
   
### 手动时间同步
ntpdate即可，ntp服务器在这里用这两个就好了
cn.ntp.org.cn 或 edu.ntp.org.cn
```
sudo ntpdate cn.ntp.org.cn
```
   
发现时间总是差了8小时，设置一下时区
```
tzselect
```
然而设置了也没用...
总不能手动改吧
   
### 自动时间同步
首先设置一下时区，然后打开ntp同步服务
```
timedatectl list-timezones
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
```
   
### 硬件时间问题
查看硬件时间总是报错，怕不是硬件问题吧
```
[tanglizi@archlinux ~]$ hwclock 
hwclock: Cannot access the Hardware Clock via any known method.
hwclock: Use the --debug option to see the details of our search for an access method.

[tanglizi@archlinux ~]$ hwclock --debug
hwclock from util-linux 2.31.1
System Time: 1519354149.819993
Trying to open: /dev/rtc0
No usable clock interface found.
hwclock: Cannot access the Hardware Clock via any known method.
```
<br />
好吧问题解决了，详见<https://unix.stackexchange.com/questions/107341/no-usable-clock-interface-found>
这里只需要使用root权限就好（hwclock为啥不报权限不足啊，满满的误导
```
sudo hwclock -w
```