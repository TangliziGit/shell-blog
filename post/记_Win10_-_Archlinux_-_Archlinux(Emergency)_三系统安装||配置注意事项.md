起因是正常使用的archlinux做滚动更新，结果貌似有一个盘块写坏了（？）。
手上没有U盘，进入不了linux，不好做fsck。于是直接就直接用win10了。

# 取消Fast Boot 
当晚进入linux发现出现问题
```
Loading kernel...
error: invalid cluster 0
```
应该是win10把efi分区盘块搞坏了，只要把BIOS的Fast Boot取消掉即可防止此问题。
但是明显我盘块已经是坏掉了，用cdlive进去看了看，发现是vmlinux坏了。

这里稍微提一下grub引导linux的步骤（详情请参考/boot/grub/grub.cfg，或grub菜单中按c健）：
装载必要的模块
设置root（即efi分区）
载入vmlinux
执行initrd

发现问题就好说了，livecd进入根目录重新安装linux即可
```
...
arch-chroot /mnt
pacman -S linux
```

至此问题解决。

# win10+双linux系统安装
考虑到每次系统出问题时，手边没有u盘的尴尬，决定再装一个应急的linux系统。
磁盘空间有限，把swap分区让出来好了（主要是因为加了个内存条，大概是用不着对换了吧）。
```
swapoff /dev/sda5
mkfs.ext4 /dev/sda5
```

接下来就用刚才的livecd安装即可。
### EFI分区过小
我的efi分区当时分得特别小，只有100M，同时还有其他系统的内容。所以安装新的vmlinux和initramfs空间绝对是不够的。
想办法删点东西。
/boot/Boot/Fonts
/boot/EFI/Microsoft/Boot/Fonts
initramfs-fallback.img
这些除了其中的中文字体(英文字体自带)，我都不要了

### 安装引导的注意事项
**安装引导时请注意**：
1. 安装os-prober，用于发现其他两个系统（即win10和正常archlinux）
2. 正常生成grub.cfg
3. 区分正常系统和Emergency系统的vmlinux和initrmfs，同时修改grub.cfg
```
pacman -S os-prober
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=emergency
grub-mkconfig -o /boot/grub/grub.cfg

# 首先区分vmlinux, initramfs
mv /boot/vmlinux /boot/vmlinux-emergency
mv /boot/initrmfs.img /boot/initramfs-emergency.img

# 其次修改grub.cfg
# 把emergency对应的内容改为vmlinux-emergency, initramfs-emergency.img
vim /boot/grub/grub.cfg
```

至此完活。

肯定有人问为什么不共享vmlinux和initramfs呢？
我考虑到正常和应急系统的内核版本很可能是不一样的，事实上我在共享的情况下尝试启动正常系统失败。
```
[Failed] Failed to mount /boot

# 看看boot.mount
systemctl status boot.mount
# 发现报错信息：
# mount: unknown filesystem type 'vfat'
```
首先想到grub的载入fat模块是否存在问题，但是启动脚本中明显写着isnmod fat
其次就是linux自己的模块载入了
```
modprobe vfat
# 报错：/lib/modules/5.1.15-arch1-1-ARCH不存在
```
笑话，我正常系统内核版本是5.1.14，紧急版本应该是5.1.15，此处出现这个问题就是vmlinux和initramfs共享造成的。

于是区分是必然的。