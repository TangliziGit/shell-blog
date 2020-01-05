dwm官网：<https://dwm.suckless.org/>
dwm是一个简洁的平铺式窗口管理器
配置简单，使用便捷，没有多少依赖，占用内存非常小
总之dwm正合口味

### 安装方法
首先在官网下载dwm.tar.gz并解压
得到这些东西：
BUGS config.mk drw.h dwm.c dwm.png Makefile...

我们主要来编辑config.h来进行一些配置和编辑config.mk来正确编译
对config.h来说，只要略微阅读官网文档即可配置，详见<https://dwm.suckless.org/customisation/>
~~我觉得原设定除了firefox的tags mask以外，就没什么需要了~~
改了一下selbordercolor, selbgcolor, selfgcolor, topbar，就是状态栏的边界、背景和字体颜色还有底部状态栏
注意dmenu还是在顶部，要改底部的话应该在dmenu那里配置
```
cp config.def.h config.h

// config.h
/* See LICENSE file for copyright and license details. */

/* appearance */
static const char *fonts[] = {
	"monospace:size=10"
};
static const char dmenufont[]       = "monospace:size=10";
static const char normbordercolor[] = "#444444";
static const char normbgcolor[]     = "#222222";
static const char normfgcolor[]     = "#bbbbbb";
static const char selbordercolor[]  = "#000000"; // "#005577";
static const char selbgcolor[]      = "#669999"; // "#005577";
static const char selfgcolor[]      = "#000000"; // "#eeeeee";
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 0; // 1;        /* 0 means bottom bar */

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	// { "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "st", NULL };

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

```

接下来开始改写config.mk，用来顺利通过make
对于一般linux用户，我们这样make即可
```
make X11INC=/usr/include/X11 X11LIB=/usr/lib/X11 FREETYPEINC=/usr/include/freetype2
```

编译过后链接一下
```
ln -s /usr/local/dwm-6.1/dwm /usr/bin/
```

我是十分讨厌开机自动进入图形界面的，所以启动时startx就好
至于为什么讨厌，原因是在做神经网络的时候，安装nvidia显卡驱动后gnome各种崩溃进入不了命令行，只能借别人电脑写启动盘重新安装arch

### dwm补丁的安装
用了dwm后，有两个很让人难受的问题
- 一个就是终端窗口缝隙的问题
这个问题有两种解决方法
其一，编辑config.h设置resizehints为0
这样做确实可以解决，然而会带来vim显示不正常的问题，于是放弃
其二，用其他的终端程序
我找到了terminator，使用体验不错，这个问题将就过去了
- 再一个就是在改变窗口位置的同时，其他标签的窗口位置也会改变
这个问题有时候实在忍不了，于是考虑安装补丁[pertag](https://dwm.suckless.org/patches/pertag/)

按照dwm版本下载.diff文件
.diff文件是用diff文件生成的，用patch命令即可打上补丁
```
patch < dwm-pertag-6.1.diff
```
然后普通的编译即可

### fcitx和状态栏简单配置
回宿舍了，配置了一下笔记本，打算写个随笔来着
突然发现输入法忘了装，于是安装fcitx
~~注意fcitx-qt5可能很多源都没有，不安装亦可~~
如果发现某些软件下载404，很可能是源没有更新，关于[yaourt的用法](http://bashell.nodemedia.cn/archives/install-yaourt.html)
```
yaourt -Sy
yaourt -S fcitx fcitx-im fcitx-googlepinyin fcitx-configtool
```
记得**重启**后用fcitx-configtool添加一下输入法

最后配置一下状态栏
```
# .xinitrc
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx &
while true; do
xsetroot -name "Bat.$(acpi -b | awk '{print $4}') | Vol.$(amixer get Master| tail -n 1 | awk ‘{print $5}' | tr -d '[]') $(LC_ALL='C' date +'%F[%b %a] %R')"
sleep 20
done &
exec dwm
# exec i3
# exec xmonad

```

顺便说一句，燕麦片加了糖好吃了不少

最后加个图吧
![](https://images2018.cnblogs.com/blog/1225237/201805/1225237-20180507181647958-1106900798.png)
![](https://images2018.cnblogs.com/blog/1225237/201806/1225237-20180609131243764-444748193.png)


<br />
> 2018-3-16更新：修改了yaourt更新源的问题
> 2018-6-09更新：修改了config.h