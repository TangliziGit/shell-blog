# Arch Linux 全盘备份方案

> 全部借鉴 [rsync+btrfs+dm-crypt备份整个系统](https://blog.lilydjwg.me/2013/12/29/rsync-btrfs-dm-crypt-full-backup.42219.html)



## btrfs

```shell
// 启用压缩算法的挂载方式
mount -t btrfs -o compress-force=zstd,subvol=/ /dev/disk/by-label/backup /bak
```

子卷与快照
```shell
// 创建子卷，可以看作创建目录
btrfs subvolume create xxx

// 删除子卷，现在可以使用 rm 了
btrfs subvolume delete xxx

// 列出子卷，并设置默认子卷
btrfs subvolume list xxx
btrfs subvolume set-default xxx

// 创建快照
// 给当前已存在的子卷创建一个快照子卷
// 并且可以分别更改这两个子卷的内容
// 删除原子卷后，快照子卷是不会被删的。
btrfs subvolume snapshot /path /snapshot/path
btrfs subvolume snapshot -r /path /snapshot/path
```

备份与增量备份
```shell
sudo btrfs send /home | sudo btrfs receive /backup/home

// 为了执行增量发送任务，需要指定上一个快照作为基础
sudo btrfs send -p /home/day1 /home/day2 | sudo btrfs receive /backup/home
sudo btrfs send -p /home/day2 /home/day3 | sudo btrfs receive /backup/home
```



## rsync

- `--dry-run`：空跑，测试是否正确
- `--archive`：递归，并保留软链接、权限、修改时间、组、所有者、特殊文件、块文件
- `--acls`、`--xattrs`、`--hard-links`
- `--one-file-system`：不跨越文件系统
- `--inplace`：直接将更新的数据写入目标
- `--delete`：当源文件删除后，目标文件也删除
- `--delete-exclude`：除了删除接收方没有的文件，还要删除发送方排除的文件
- `--numeric-ids`：使用数字的user id和group id
- `--sparse`：处理稀疏文件时，使用更少的空间存储。当结合`--inplace`时，则情况结合内核版本和文件系统
- `--itemize-changes`：输出变化的报告
- `--progress`、`--verbose`、`--stats`
- `--exclude='xxx'`：排除文件
- `--exclude-from=/root/exclude`：排除文件中的每行路径



**完整备份脚本**

```shell
rsync --archive --one-file-system --inplace \
  --hard-links --acls --xattrs --sparse \
  --human-readable --numeric-ids --delete --delete-excluded \
  --verbose --progress --stats \
  --exclude='*~' --exclude=__pycache__ \
  --exclude-from=/root/exclude \
  / /bak/current
```

```plain
# /root/exclude
/var/cache/*/*
/var/tmp/
/var/abs/local/
/var/lib/mongodb/journal/
```



## dm-crypto

```shell
// 建立加密块设备
cryptsetup luksFormat /dev/sdaX

// 打开与关闭
cryptsetup open /dev/sdc3 backup
cryptsetup luksClose backup

// 在 /dev/mapper/NAME 上做任何读写
mkfs.btrfs /dev/mapper/backup
```



## 从备份启动

关于从备份启动的设计，本人并不想做。

原因首先是不了解`grub`的配置如何设置启动的目录。再就是备份系统利用了原有机械硬盘上的空闲空间，所以不想把备份系统设置的太复杂。

关于主系统挂掉后如何紧急修复的方案，本人想直接在多个TF卡上写好各个常用系统的livecd，再通过备份系统中的sync还原脚本，`arch-chroot`调整配置，进行全盘恢复。



## 整合



### 挂载与目录划分

格式化的时候顺手给一下 label
```shell
mkfs.btrfs -L backup /dev/sda3
```

挂载时注意给下压缩算法，和根子卷
```shell
mount -t btrfs -o compress-force=zstd,subvol=/ /dev/disk/by-label/backup /bak
```

```
# /dev/sda3 LABEL=backup
UUID=68b08bda-456d-44af-8f8f-c262ebfc7d13  /bak  btrfs   rw,relatime,compress-force=zstd:3,space_cache,subvolid=5,subvol=/  0 0
```



目录划分，考虑之后可能入手一块硬盘来备份 /home ，同时还要保存一些关于备份的脚本和配置。

```plain
/bak
|-- backup
|   |-- home
|   |   `-- current
|   `-- root
|       |-- 20201228_1153
|       `-- current
`-- etc
    |-- recover.sh
    |-- recovery.log
    `-- sync.sh
```



### 增量备份

注意 rsync 的路径遵循GPL协议，它会有特殊的规则，比如`xxx/`会表示`xxx`目录下的所有文件。

所以在使用 rsync 备份时，要分清它。

`sync.sh -w`

```shell
#!/usr/bin/env bash
dry=$1
 
if [[ $dry == -w ]]; then
  args=
else
  args='-n'
fi

rsync --archive --one-file-system --inplace \
  --hard-links --acls --xattrs --sparse \
  --human-readable --numeric-ids --delete --delete-excluded \
  --exclude-from=/bak/etc/exclude \
  --verbose --progress --stats \
  / /bak/backup/root/current $args

if [[ $dry == -w ]]; then
  btrfs subvolume snapshot -r /bak/backup/root/current "/bak/backup/root/$(date +%Y%m%d_%H%M)"
fi
```



### 备份恢复

一定注意目录后的斜杠，如果不写的话，会将整个备份目录写入根中。

`recover.sh /bak/backup/root/20201227_0221/ -w`

```shell
#!/usr/bin/env bash
if [[ ${1: -1} != / ]]; then
  echo "You should give a path with ending slash!"
fi

dry=$2
if [[ $dry == -w ]]; then
  args=
else
  args='-n'
fi

rsync --archive --one-file-system --inplace \
  --hard-links --acls --xattrs --sparse \
  --human-readable --numeric-ids --delete --delete-excluded \
  --exclude-from=/bak/etc/exclude \
  --verbose --progress --stats \
  "$1" / $args

if [[ $dry == -w ]]; then
    echo "$(date +%Y/%m/%d_%H:%M) Recovered from $1" >> /bak/etc/recovery.log
fi
```

 

### 排除文件

`/bak/etc/exclude`

```
__pycache__
lost+found
/var/cache/*/*
/var/tmp/
/dev
/proc
/sys
/tmp
/run
/mnt
/media
```

