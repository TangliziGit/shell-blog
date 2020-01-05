回家装上archlinux，突发奇想装个SpaceVim写题
安装配置一路可以说是没有太大问题
最后在写题时出现如下问题
```
Error while trying to load a compilation database:
Could not auto-detect compilation database for file "poj-1458.cpp"
No compilation database found in /home/tanglizi/Code/acm/summerTraining/2018 or any parent directory
fixed-compilation-database: Error while opening fixed database: No such file or directory
json-compilation-database: Error while opening JSON database: No such file or directory
Running without flags.

```

查了查google，发现这是clang-check的问题，clang-check需要一个compile_commands.json文件（可由cmake生成）做到工程化check
那么问题迎刃而解

### 方法一
卸载clang，换上gcc
绝对暴力的方法，可以说很不优雅了

### 方法二
手写compile_commands.json文件，或者cmake一个工程
但是对ACM刷题党来讲，这个实在不方便

### 方法三
瞬间抛弃了前两个方法，于是开始修改vim插件
还是查了查google，发现问题在于一个名叫neomake插件
于是查找有关clang-check的文件，看看是怎么调用clang-check的
```
grep clang-check -R ~/.cache/vimfiles/repos/github.com
# /home/tanglizi/.cache/vimfiles/repos/github.com/neomake/neomake/autoload/neomake/makers/ft/c.vim:    " 'exe': 'clang-check'
vim /home/tanglizi/.cache/vimfiles/repos/github.com/neomake/neomake/autoload/neomake/makers/ft/c.vim
```
可以看到第32行出现clang-check
```
function! neomake#makers#ft#c#clangcheck() abort
    return {
        \ 'exe': 'clang-check',
        \ 'args': ['%:p'],
        \ 'errorformat':
            \ '%-G%f:%s:,' .
            \ '%f:%l:%c: %trror: %m,' .
            \ '%f:%l:%c: %tarning: %m,' .
            \ '%I%f:%l:%c: note: %m,' .
            \ '%f:%l:%c: %m,'.
            \ '%f:%l: %trror: %m,'.
            \ '%f:%l: %tarning: %m,'.
            \ '%I%f:%l: note: %m,'.
            \ '%f:%l: %m',
        \ }
endfunction
```
于是在33行的args里面加上'--'，同理处理clang-tidy（75行），就搞定了
```
        \ 'args': ['%:p', '--'],
```

思路是在原命令后加上'--'，clang就不查找compilation database了
```
clang-check file.cpp --
```