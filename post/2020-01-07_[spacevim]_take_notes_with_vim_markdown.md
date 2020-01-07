<!-- vim-markdown-toc Marked -->

* [Taking notes with vim markdown](#taking-notes-with-vim-markdown)
    * [Features](#features)
        * [syntax highlighting](#syntax-highlighting)
        * [generate table of content](#generate-table-of-content)
        * [preview when save](#preview-when-save)
        * [faster table writting](#faster-table-writting)
    * [Screen shot](#screen-shot)

<!-- vim-markdown-toc -->

# Taking notes with vim markdown
ASC20已经开始了, 配一个`SpaceVim`的markdown环境来做笔记写报告.

## Features

- syntax highlighting
- generate TOC
- preview when save
- faster table writting

### syntax highlighting
`SpaceVim` 自带了高亮插件, 又省事了.

### generate table of content
安装一个`vim-markdown-toc`
1. 安装:
    修改`~/.SpaceVim.d/init.toml`
    ```toml
    [[custom_plugins]]
    name = "mzlogin/vim-markdown-toc"
    merged = false
    ```
2. 关闭保存时自动更新TOC
    新建`~/.SpaceVim/autoload/config.vim`
    ```vim
    function! config#after() abort
        let g:vmt_auto_update_on_save = 0

    endfunction
    ```
    修改`~/.SpaceVim.d/init.toml`
    ```toml
    [options]
        bootstrap_after = "config#after"
    ```

### preview when save
没有找到vim内的实时预览插件, 于是直接上`Typora`
文件保存时自动载入, 也能直接编辑
本身就是个很好的markdown编辑器, 但是没有vim模式

### faster table writting
安装`vim-table-mode`
编辑`config.vim`, 添加快捷启用
```vim
function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

function! config#after() abort
    nmap q \qr
    exec "iunmap jk"

    let g:vmt_auto_update_on_save = 0
    let g:table_mode_corner = '|'
    let g:table_mode_border=0
    let g:table_mode_fillchar=' '

    inoreabbrev <expr> <bar><bar>
              \ <SID>isAtStartOfLine('\|\|') ?
              \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
    inoreabbrev <expr> __
              \ <SID>isAtStartOfLine('__') ?
              \ '<c-o>:silent! TableModeDisable<cr>' : '__'
endfunction
```


## Screen shot
![Screenshot from 2020-01-07 14-01-37.png](https://i.loli.net/2020/01/07/kKFRswP6GydvxjD.png)
