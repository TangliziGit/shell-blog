##场景
```
$ git push
To https://github.com/XXX/XXX
 ! [rejected]        dev -> dev (non-fast-forward)
error: failed to push some refs to 'https://github.com/XXX/XXX'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.

```

## 原因
远端冲突

## 解决方案
推荐方案3
因为merge会新建commit, 让网络图错综复杂, 十分难观察

1. git push --force
暴力更新代码, 这样会丢失远端的一些提交(或者代码)

2. git pull ( fetch + merge )
本地取远端修改, 然后合并

3. git pull -- rebase ( fetch + rebase )
本地取远端修改, 然后变基

## merge 与 rebase 的区别
1. merge 是**新建**一个commit, 在新的commit中, 在两个分支上各取最近祖先至今的修改, 合并, 移动head到最新分支上.

2. rebase是**不新建**commit, 首先**剪切本分支最近祖先至今的修改**, 然后移动head到另一分支. 在另一个分支上, **粘贴**刚才的修改, 移动head到最新修改上.

具体详见<https://www.jianshu.com/p/c17472d704a0>