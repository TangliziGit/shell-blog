> Ncmcpp是一个mpd客户端，它提供了很多方便的操作
> MPD是一个服务器-客户端架构的音频播放器。功能包括音频播放, 播放列表管理和音乐库维护，所有功能占用的资源都很少。
> --取自 [wiki.archlinux.org](http://wiki.archlinux.org)

很好用的一个命令行下的音乐播放器，然而在配置的过程中出现了一些小问题

### 安装
```
yourt -S mpd ncmpcpp
```

### 配置服务端 MPD
安装mpd后，给每个用户做配置
复制/usr/share/doc/mpd/mpd.conf.example到～/.config/mpd/mpd.conf
然后对其配置，每个配置的作用详见<https://wiki.archlinux.org/index.php/Music_Player_Daemon>
```
mkdir ～/.config/mpd
cp /usr/share/doc/mpd/mpd.conf.example～/.config/mpd/mpd.conf
nvim ～/.config/mpd/mpd.conf

# mpd.conf
music_directory		"/your/Music/path"
playlist_directory		"~/.mpd/playlists"
db_file			"~/.mpd/database"
log_file			"~/.mpd/log"
pid_file			"~/.mpd/pid"
state_file			"~/.mpd/state"
sticker_file			"~/.mpd/sticker.sql"
bind_to_address		"localhost"
port				"6600"

audio_output {
    type                    "fifo"
    name                    "my_fifo"
    path                    "/tmp/mpd.fifo"
    format                  "44100:16:2"
}

audio_output {
	type		"alsa"
	name		"ALSA"
	device		"hw:0,0"	# optional
	mixer_type       "hardware"	# optional
	mixer_device	"default"	# optional
	mixer_control	"Master"		# optional
	mixer_index	"0"		# optional
}

...
```

### 配置服务端Ncmpcpp
首先运行一下ncmpcpp，生成一下配置文件；或者直接复制样例配置
这里以mpd开头的项与mpd的配置相同
```
cp /usr/share/doc/ncmpcpp/config ~/.ncmpcpp/config

nvim ~/.ncmpcpp/config

# ~/.ncmpcpp/config
mpd_host = "localhost"
mpd_port = "6600"
mpd_music_dir = "/your/Music/path"

visualizer_fifo_path = /tmp/mpd.fifo
visualizer_output_name = Visualizer feed
visualizer_in_stereo = yes
visualizer_sync_interval = 30
visualizer_type = wave
visualizer_look = ●▮
visualizer_color = blue, cyan, green, yellow, magenta, red

...
```

### Ncmpcpp使用方法
详见Basic Usage <https://wiki.archlinux.org/index.php/Ncmpcpp>
按键绑定详见 /usr/share/doc/ncmpcpp/bindings
附加一下 用Delete删除playlist的歌曲

### 配置出现的问题
- Ncmpcpp不能调节音量，左下角显示"MPD: no mixer"

查看~/.mpd/log发现是control的问题

```
exception: Failed to open mixer for 'My ALSA Device': no such mixer control: PCM
```

检查mpd.conf的audio_output设置
若使用alsa，用amixer查询control

```
$ amixer    
Simple mixer control 'Master',0
  Capabilities: pvolume pswitch pswitch-joined
  Playback channels: Front Left - Front Right
  Limits: Playback 0 - 65536
  Mono:
  Front Left: Playback 8419 [13%] [on]
  Front Right: Playback 8419 [13%] [on]
Simple mixer control 'Capture',0
  Capabilities: cvolume cswitch cswitch-joined
  Capture channels: Front Left - Front Right
  Limits: Capture 0 - 65536
  Front Left: Capture 10093 [15%] [on]
  Front Right: Capture 10093 [15%] [on]

# 对应的mpd.conf audio_output配置
audio_output {
	type		"alsa"
	name		"ALSA"
	device		"hw:0,0"	# optional
	mixer_type       "hardware"	# optional
	mixer_device	"default"	# optional
	mixer_control	"Master"		# optional 注意此处
	mixer_index	"0"		# optional
}
```

- Ncmpcpp配置无误，但就是没有音乐
进入ncmpcpp，按下2或4，选择文件（文件夹），按下a，添加到playlist即可

### 截图
最后还是截个图吧
![](https://images2018.cnblogs.com/blog/1225237/201805/1225237-20180507181647958-1106900798.png)

![](https://images2018.cnblogs.com/blog/1225237/201805/1225237-20180507181800139-743251430.png)