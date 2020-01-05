我使用的是dwm，所以这种琐碎小事还要我们亲自动手，
以后考虑做个脚本，把声音调节、屏幕亮度什么的统统塞进去

### 屏幕亮度
```
# 查看亮度最大值
cat  /sys/class/backlight/intel_backlight/max_brightness
# 调节亮度
echo 800 >  /sys/class/backlight/intel_backlight/brightness
```

### 调节音量
首先安装alsa-utils，然后通过alsamixer调节
```
yaourt -S alsa-utils
alsamixer
```
可以用以下命令试听
```
speaker-test -c 2
```

alsamixer可以使用方向键移动、m键开关、zq xw ce键调节“左” “双” “右”声道
笔记本电脑一般只有一个master，所以带上耳机好像就不能外放了
台式机一般是可以调整的