题目链接：<https://cn.vjudge.net/problem/UVALive-7197>

### 题意
需要生产n种(2<=n<=14)零件，每种零件可以用两种材料制作，对这两种材料的消耗相同，产出价值不同。
但是一种零件一旦选定原材料就不能更改。
给这两种原材料的量和各零件生产方案，问生产最大价值多少。

### 思路
一开始WA好几次，没发现原材料就不能更改的条件呵呵。

首先对零件分个类，用第一种材料还是第二种。
然后分别做两个完全背包即可-_-
总复杂度O(nm2^n)
顺便，这种多背包解决问题的思考方向，在另一个题目里提到了。
关于理解背包的本质，就在那道题了，这道题也是好题。

### 提交过程
|||
:-|:-
WA|原材料就不能更改
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxw=2e3+20, INF=0x3f3f3f3f;
const int maxn=100+20;
int n, q, r;
int wei[maxn], val_1[maxn], val_2[maxn];
int f[maxw], g[maxw], ans;
bool vis[maxn];

void compKnap(int dp[], int total, int cost, int val){
    for (int i=cost; i<=total; i++)
        dp[i]=max(dp[i], dp[i-cost]+val);
}

void dfs(int dep){
    if (dep==n+1){
        memset(f, 0, sizeof(f));
        memset(g, 0, sizeof(g));
        for (int i=1; i<=n; i++){
            if (vis[i]) compKnap(f, q, wei[i], val_1[i]);
            else compKnap(g, r, wei[i], val_2[i]);
        }
        ans=max(ans, f[q]+g[r]);
    }else{
        vis[dep]=true; dfs(dep+1);
        vis[dep]=false;dfs(dep+1);
    }
}

int main(void){
    while (scanf("%d", &n)==1 && n!=-1){
        for (int i=1; i<=n; i++)
            scanf("%d%d%d", &wei[i], &val_1[i], &val_2[i]);
        scanf("%d%d", &q, &r);

        ans=0;
        dfs(1);
        printf("%d\n", ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1699ms|None|1020|C++ 5.3.0|2018-08-21 05:35:04