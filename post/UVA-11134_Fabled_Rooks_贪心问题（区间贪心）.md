题目链接：<https://cn.vjudge.net/problem/UVA-11134>

### 题意
在 n*n 的棋盘上，放上 n 个车(ju)。使得这 n 个车互相不攻击，即任意两个车不在同一行、同一列。同时这 n 个车必须落在一个规定的矩形区域。
若无解，输出 "IMPOSSIABLE"；有解则按下标输出坐标。

### 思路
首先可以想到行与列互不影响，于是可以分别求解。
很容易想到区间贪心模型。
于是在第一次写这道题的时候，简单的把区间左端点按从小到大的顺序排列，若相同则把右端点从小到大排列。最后从左到右查找一边。
（思路是别人没有，而我独有的先处理。）
结果WA了=_=
意识到 (1, 1) (2, 2) (1, 3) 这样的情况不可行后，考虑到了第二种思路：
A仅有的先处理（A的可选项少所以先处理），B独有的其次处理。
即：**我仅有的先处理，我独有的后处理。**
有比较代码：
```
bool operator < (const Interval &a) const{
    return (r<a.r)||(r==a.r && l<a.l);
}
```
于是AC

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
struct Interval{
    int l, r, idx;
    bool operator < (const Interval &a) const{
        return (r<a.r)||(r==a.r && l<a.l);
    }
}x[5005],y[5005];
int n;

int func(Interval x[], int ans[]){
    int vis[5005]={0};
    sort(x, x+n);
    for (int i=0; i<n; i++){
        int isok=1;
        for (int ptr=x[i].l; ptr<=x[i].r; ptr++){
            if (vis[ptr]) continue;
            vis[ptr]=1;ans[x[i].idx]=ptr;
            isok=0; break;
        }
        if (isok) return 1;
    }
    return 0;
}

int main(void){
    int ans[2][5005];
    while (scanf("%d", &n)==1 && n){
        for (int i=0; i<n; i++){
            scanf("%d%d%d%d", &x[i].l, &y[i].l, &x[i].r, &y[i].r);
            x[i].idx=y[i].idx=i;
        }
        if (func(x, ans[0]) || func(y, ans[1])){printf("IMPOSSIBLE\n"); continue;}
        for (int i=0; i<n; i++)
            printf("%d %d\n", ans[0][i], ans[1][i]);
    }
    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|862|C++ 5.3.0|2017-10-25 13:41:10