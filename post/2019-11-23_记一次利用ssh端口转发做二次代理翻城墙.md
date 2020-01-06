因为某些原因, 前两个月vultr的机房各种连不上, 换了几个机房都是没用, 猜测是直接封了大部分ip.
昨天偶然间换了法国机房, 发现又可以连接了, 抽时间配了一下ssr.
顺便一提, cnblog终于换了markdown编辑器...

## 配置ssr
按照这个配的<https://elfgzp.cn/2018/10/31/ssr-serverspeeder.html>

## 二次代理
为什么要做二次代理?
因为校园网直接很难连vultr的服务器, 猜测是学校的网关上做的手脚=_=
于是另找了个aliyun服务器, 配了一下端口转发, 做了二次代理:

国内aliyun上:
```
# vultr ip: 1.1.1.1
# aliyun ip: 2.2.2.2
ssh -L 1080:1.1.1.1:4000 1.1.1.1 -Nf
ssh -R 1080:localhost:4000 localhost -Nf
```
第一步, 做端口转发 localhost:1080 -> 1.1.1.1:4000 用1.1.1.1做ssh server
第二部, 做反代 localhost:1080 <- localhost:4000 用本机做sshserver

然后客户端连接aliyun:4000即可, 注意添加安全组规则