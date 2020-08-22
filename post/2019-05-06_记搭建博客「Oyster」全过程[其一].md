一两个星期前正在了解Linux内核，看得有点累，突然想趁着五一放假写个博客学学spring。
由于没有在一开始下定决心写这个博客系统，所以我又没记录一开始的分析过程。这都是写了一个星期之后的思路了。
写这个随笔就仅当作再次理清思路吧。
项目地址：https://github.com/TangliziGit/Oyster

# 开发目的

目的很简单，就是为了下面这几点：
- 了解和实践web开发全过程，主要是架构设计和前后端实现
- 一边写一边学，主要学设计规范、代码结构、具体框架，还有git操作
- 方便之后写博客（吐槽一下cnblog的markdown支持是真不行啊）
- 方便装b，刷github提交量

# 需求

我们直接对具体页面迭代的需求分析：

第一次分析：
```
- 首页
    + 显示部分文章，支持分页
    + 显示文章信息：名字、创建时间、分类和标签
- 文章页
    + 显示标签、分类
    + 具体文章，分页显示评论
- 档案(Archives)
    + 按月份显示文章，支持分页，详细信息同首页

```

第二次分析：
```
前台：
- 标签页 & 分类页
    + 显示每个标签，及对应前六篇文章
- 搜索页

例：
[Dxx](https://fuzhouxxdong.github.io/hexo-theme-dxx/)
[Hipaper](https://itimetraveler.github.io/hexo-theme-hipaper/)
[Minos](https://blog.zhangruipeng.me/hexo-theme-minos/)
```

# 架构

## 多模块开发：
- oyster-common
    访问数据库、提供公共的功能类
- oyster-api
    提供RESTful API
- oyster-front
    前台展示模块
- oyster-runner
    用于启动所有模块，无实际作用

## 开发架构图
![](https://img2018.cnblogs.com/blog/1225237/201905/1225237-20190504201555944-2059677274.png)


# 技术要求

总结一下使用的框架
- Thymeleaf
- Spring MVC
- Spring Boot
- Spring Data JPA （可能与MyBatis混用）

# 具体开发细节

- 公共模块
    - [x] AbstractQuery查询  
        *通过注解封装一部分JPA动态查询功能，提供方便使用的多重查询*
- 前台页面模块
    - [x] 灵活的文章查找  
        *支持文章标题和内容的多重模糊查询*
    - [ ] 更多主题  
        *可能尝试调用hexo解析hexo主题模板*
- 后台管理模块
    - [ ] markdown支持插入图片
    - [ ] 实时编辑markdown  
- RESTful API模块
    - [ ] 复用api
        *转发前后台url到api*
    - [ ] RESTful API规范
        *遵守状态码，安全与幂等等规范*
    - [ ] 对提交评论和文章点击量的限制  
        *包括提交内容判误、提交频率、一段时间同ip不增加点击量、跨域提交*
- docker支持