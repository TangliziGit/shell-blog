昨天突然想到家里还有一台很早之前不用的计算机
于是打算安装一个linux，开学再拿到宿舍用来写代码，怎么说台式机显示屏也比笔记本的大
![](http://images2017.cnblogs.com/blog/1225237/201802/1225237-20180206204059513-496937709.png)



### 机器安装问题
屏幕机箱擦干净，该连的东西都连上，然后插电源，本以为啥事没有
然而按开机按钮居然打不开？
因为机器没有打开，所以主机的状态不好描述，不好找原因
状态就是**hdd灯红灯常亮，机器打不开**

本以为是硬盘出问题了，于是准备检查硬盘
把硬盘拿下来接在移动硬盘的接口，再用笔记本电脑lsblk看了一下
根本找不到这个硬盘，还以为是硬盘本身坏了
最后发现好像移动硬盘接口给的电压不够，硬盘启动不了...

再想想也不对，bios还没有启动，启动不了的原因应该不是硬盘
于是把主板的电池抠下来，发现有电
把panel接口重连，又把POWER SW枚举地连接，还是开不了机
最后拿了个改锥把panel针脚挨个试了试
就开机了呵呵
原因可能就是POWER SW接口接触不良吧

### 安装ArchLinux
![](http://images2017.cnblogs.com/blog/1225237/201802/1225237-20180206204107732-298528515.png)



还好机器的bios可以选择启动顺序，好用usb启动，不然就只能用其他法子了
电脑里正好有一个arch的镜像，于是写usb启动盘
```
dd bs=4M if=~/Download/archlinux.iso of=/dev/sdb
```
安装一步步来，注意旧机器没有efi，启动就用bios
所以在分区的时候记得留1M大小的分区，用来作引导
一路都很顺利，最后打算试试看用gnome卡不卡
结果尝试了startx，就有报错
```
Fatal server error:
(EE) AddScreen/SreenInit failed for device 0
```
猜测显卡驱动问题，于是又装了一边 xf86-video-vesa，还是报错
结果尝试装xf86-video-intel，结果成功打开xorg

最后居然发现鼠标显示有问题，这个就不太会弄了...
用了用gnome，觉得太卡，于是打算换个图形界面，安装了个dwm
注意用dwm需要编辑~/.xinitrc
```bash
#~/.xinitrc
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx &
# 下面代码用于设置右上角的时间
while true; do
xsetroot -name "$(LC_ALL='C' date +'%F[%b %a] %R')"
sleep 20
done &
# 下面用于启动dwm
exec dwm
```
dwm使用感觉良好，给ubuntu也来了一个，附图一张
![](http://images2017.cnblogs.com/blog/1225237/201802/1225237-20180208010947670-1083549680.png)