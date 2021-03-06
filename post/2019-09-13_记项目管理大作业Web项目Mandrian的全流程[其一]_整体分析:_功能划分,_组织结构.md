Mandrian是个图书管理系统, 具体需求老师给出
这个项目的目的主要是管理过程和高层设计的学习和实践
11人小组, 路人局

## 成员调查
这里由于很多人我都不认识, 所以我提前发了一个能力调查表, 调查范围是代码,管理和设计能力.
![](https://img2018.cnblogs.com/blog/1225237/201909/1225237-20190912220652188-738846254.png)
![](https://img2018.cnblogs.com/blog/1225237/201909/1225237-20190912220658534-703346493.png)
结论(如果前后分离):
1. 居然想去前端的人多, 前后人数比接近2:1, 如果不是胡选的话, 是个优势
2. 后端主力语言应当是java
3. 大家都不用git么..., 那么代码版本如何控制?如何多人协作开发?难道要用qq邮件合并代码么-_-

## 分析和设计流程
以下都是本人的经验, 主要是貌似没有一种固定的分析和设计方法? 还是说我又忘了?
![](https://img2018.cnblogs.com/blog/1225237/201909/1225237-20190912215248819-784844347.png)
分析: 对需求具体功能划分, 组织结构
设计: db设计, api设计, 开发模块设计, 架构设计, 框架选择

### 功能划分
目的见上图,  是为了下面的工作做铺垫
需要注意的是:
1. 此处第一次划分只能大组长做, 或者PO们讨论, 因为组织结构还没定, 没有小组长可以分工
2. 第一次划分最大的贡献是定组织结构
3. 第二次划分最大的目的是定下开发的具体任务
4. 开发过程中很可能发现功能划分不正确, 没办法, 我们是增量模型, 不像瀑布模型那样时间长且特别严谨
5. 事实上此处有些像WBS, 这是我之后才接触的, 现在并不清楚WBS是干嘛的

### 组织结构
![](https://img2018.cnblogs.com/blog/1225237/201909/1225237-20190913001728058-2082278992.jpg)
为什么设计成这样? 为什么不用按老师讲的三种功能分?
- 首先按功能分的话, 有两个缺点
    - 编码效率低
        同时做某几个功能的话, 如果成员不了解多人合作, 很可能代码合并冲突
        而且前后不分的话, 很可能存在前后端来回改的情况, 怕是脑子转换不来
    - 成员学习成本高
        不了解框架或者语言的话, 一边后端一边前端, 谁吃得消啊
- 如果按前后分离的路子, 我认为一点问题没有
     但是相较于按功能划分的话, 这个分工比较难把握文档写作等一系列课程上的事情, 也算是很无聊的原因吧
- 主功能副前后的话, 会有几个很严重的问题
    - 相似功能的合并(比如login的api), 合并之后无论谁要实现这个功能, 都会出现组间的前后端依赖, 其实问题不大, 但这样的话公共部分得我写么?(吐血
    - api的设计, 像reader组和librarian组, 都有对reader的crud, 到底是谁写ReaderController? 我觉得要分离成SelfReaderController, LibReaderController, 这不是自找麻烦么?
- 所以我们很可能是三个后端组合并, 分开写功能(ReaderController, AdminController等, 而非每个人按照功能个写个的)
(注意我们的前后端在开发时是相当分离的, 这个等下再说, 关键词: 前端渲染, ＭockServer


### db设计
关键词: 权限五张表(或许三张?)
todo: 日志如何解决? 统计信息如何?


### api设计
RESTful API没跑了
很可能首先小组长定义, 出文档, 前后共用
后端先开发api, 前端首先模拟api(mock server), 然后写页面, 高度并行


### 模块划分
基于上述讨论, 脑子里还是老一套
mandrian-common: 数据访问, 工具类, 配置, 权限aop, 日志aop, 安全aop
mandrian-back: 主要是api (或许叫做mandrian-api?)
mandrian-front: 提供页面访问的url, 还有具体页面
待讨论吧


### 架构设计
注意到了邮件, 日志还有统计, 可能又要mq了?
待续


### 框架选择
前: bootstrap, jquery, template.js, (mock server)
后: spring boot, spring mvc, (spring data jpa+mybatis), thymeleaf(几乎静态的页面)
待讨论


## 吐槽
1. 说起来为什么我不认识大家, 但是还是当了组长?
原因是我们猜拳决定的组长, 这本来就够扯淡了, 但居然我还能输了10个人???