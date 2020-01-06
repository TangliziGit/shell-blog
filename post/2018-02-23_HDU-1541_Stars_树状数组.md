题目链接：<https://cn.vjudge.net/problem/HDU-1541>

### 题意
天上有许多星星
现给天空一个平面坐标轴，统计每个星星的level，
level是指某一颗星星的左下角(x<=x0 && y<=y0)的星星总数
注意数据以yx排序输入

### 思路
怎么想也想不到如何查询
若用传统O(n^3)查询必然超时
- 于是想到记忆化搜索不断读写dp[y][x]即可，目测O(n^2)大一点
算了一下时间空间都不大可行，苦思冥想没有思路，看了别人的题解才晃然大雾

- 用树状数组维护一个[0...XMAX]的区间即可
然而还是希望一个二维区间的查找算法
注意**树状数组的区间是[1, MAX]不是[0, MAX-1]**
同时注意本题xy取值包括0

- 二维树状数组
还是很好写，只需在add()和sum()里再加入一个嵌套循环即可
不过这个题目用二维的话，光是空间上就不满足还是算了吧

### 代码
```cpp
#include <cstdio>
#include <cstring>
#define lowbit(x) ((x)&(-x))
const int XMAX=32000;
int n, stars[XMAX+5];
int sum(int x){
    int result=0;
    for (int i=x; i>0; i-=lowbit(i))
        result+=stars[i];
    return result;
}

void add(int x){
    for (int i=x; i<=XMAX+1; i+=lowbit(i))
        stars[i]++;
}

int main(void){
    while (scanf("%d", &n)==1){
        int level[15000+5]={0};
        memset(stars, 0, sizeof(stars));
        for (int i=0, x, y; i<n; i++){
            scanf("%d%d", &x, &y);
            level[sum(x+1)]++;
            add(x+1);
        }
        for (int i=0; i<n; i++) printf("%d\n", level[i]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
391ms|508kB|651|G++|2018-02-22 17:11:49