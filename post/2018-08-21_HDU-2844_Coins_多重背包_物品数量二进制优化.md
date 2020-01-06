题目链接：<https://cn.vjudge.net/problem/HDU-2844>

### 题意
给你一些不同价值和一定数量n的硬币。
求用这些硬币可以组合成价值在[1 , m]之间的有多少。

### 思路
多重背包问题，看了一眼数据范围，用二进制优化一下物品数量即可。

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=100+20, maxm=1e5;
int num[maxn], cost[maxn], val[maxn];
int dp[maxm];
int n, m;

void zeroKnap(int cost, int val){
    for (int i=m; i>=cost; i--)
        dp[i]=max(dp[i], dp[i-cost]+val);
}

void compKnap(int cost, int val){
    for (int i=cost; i<=m; i++)
        dp[i]=max(dp[i], dp[i-cost]+val);
}

int main(void){
    while (scanf("%d%d", &n, &m)==2 && n+m){
        for (int i=1; i<=n; i++) scanf("%d", &cost[i]);
        for (int i=1; i<=n; i++) scanf("%d", &num[i]);

        memset(dp, 0, sizeof(dp));
        for (int i=1; i<=n; i++){
            if (num[i]*cost[i]>=m)
                compKnap(cost[i], cost[i]);
            else{
                for (int k=1; k<num[i]; k*=2){
                    zeroKnap(cost[i]*k, cost[i]*k);
                    num[i]-=k;
                }
                zeroKnap(cost[i]*num[i], cost[i]*num[i]);
            }
        }

        int ans=0;
        for (int i=1; i<=m; i++)
            if (dp[i]==i) ans++;
        printf("%d\n", ans);
    }
    
    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
234ms|1596kB|1108|G++|2018-08-21 05:13:40