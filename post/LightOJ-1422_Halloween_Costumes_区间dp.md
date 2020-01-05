题目链接：<https://cn.vjudge.net/problem/LightOJ-1422>

### 题意
想参加聚会，每场聚会需要穿对应的衣服。
现在有需要参加的聚会的衣服序列。
对策是可以穿着多件衣服，按聚会不同脱下即可；或者直接在当前衣服上在加一件衣服。
问最少穿过几件衣服。

### 思路
瞬间想到栈的操作，对穿衣服脱衣服来说，对应入栈和退栈。
于是就有了错误解法：
dp[i]表示穿第i件衣服的最小解
dp[i]=min(dp[j]+cost[j+1][i])
现在求cost数组即可（雾，有了cost我还写啥。。。

正解是区间dp
dp[i][j]表示i到j的解，于是有：
```cpp
dp[i][j]=dp[i][j-1]+1;
dp[i][j]=min(dp[i][k]+dp[k+1][j]), clothes[k]==clothes[j];
```

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
const int maxn=100+20, INF=0x3f3f3f3f;
int dp[maxn][maxn], num[maxn];
int n;

int main(void){
    int T;

    scanf("%d", &T);
    for (int kase=1; kase<=T; kase++){
        scanf("%d", &n);
        for (int i=1; i<=n; i++) scanf("%d", &num[i]);

        for (int i=1; i<=n; i++)
            for (int j=1; j<=n; j++) dp[i][j]=INF;
        for (int i=1; i<=n; i++) dp[i][i]=1;
    
        for (int len=1; len<=n; len++)
            for (int i=1; i+len<=n; i++){
                dp[i][i+len]=dp[i][i+len-1]+(num[i+len]!=num[i+len-1]);

                for (int k=i; k+1<=i+len-1; k++) if (num[k]==num[i+len])
                    dp[i][i+len]=min(dp[i][k]+dp[k+1][i+len-1], dp[i][i+len]);
            }
        printf("Case %d: %d\n", kase, dp[1][n]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
60ms|1144kB|852|C++|2018-08-13 23:51:46