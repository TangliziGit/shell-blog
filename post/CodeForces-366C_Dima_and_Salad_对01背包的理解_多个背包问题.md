题目链接：<https://cn.vjudge.net/problem/CodeForces-366C>

### 题意
给出n个水果和一个常数k，其中每个水果都有两种性质ai, bi（美味度，卡路里量）。
要保证$ \frac{ \sum a_i }{ \sum b_i }=k $的前提下，求出最大的ai和。

### 思路
不知道是什么背包类型，这类背包是这样的：多个基础的01背包（或其他）
1. 对单个背包的理解是这样：
**在一元不定式的约束，且dp函数具有单调性时，dp函数值最大化。**
比如01背包是这样的：
在总代价小于某值，且dp[cost]=val中cost越大val一定不会变小时（容量越大，能选的价值越大），价值最大化
2. 明显这题不满足「一元不定式的约束」。
于是我们就可以想办法把问题拆成两个背包，或者改成两个状态dp[taste][calories]。
虽然明显后一个状态将超时。
3. 如果拆成两个背包，就必须满足「dp函数具有单调性」（自变量越大，因变量不会变小）。
我们可以发现 f[abs(\sum t[i]-k*c[i])]=\sum t[i], t[i]-k*c[i]<0(>=0)是单调的。
那么问题有解。

### 提交过程
|||
:-|:-
TLE|看错n大小了，直接暴力了...
AC

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e4+20, maxw=1e5+20;
const int INF=1e5+20;
int cal[maxn], tas[maxn], n, k;
int f[maxw], g[maxw];

int main(void){
    while (scanf("%d%d", &n, &k)==2){
        for (int i=1; i<=n; i++) scanf("%d", &tas[i]);
        for (int i=1; i<=n; i++) scanf("%d", &cal[i]);

        for (int i=0; i<maxw; i++)
            f[i]=g[i]=-INF;
        f[0]=g[0]=0;
        for (int i=1; i<=n; i++){
            int cost=tas[i]-k*cal[i], val=tas[i];
            if (cost<0){
                cost*=-1;
                for (int j=maxw-1; j>=cost; j--)
                    f[j]=max(f[j], f[j-cost]+val);
            }else{
                for (int j=maxw-1; j>=cost; j--)
                    g[j]=max(g[j], g[j-cost]+val);
            }
        }

        int ans=0;
        for (int i=0; i<maxw; i++)
            ans=max(ans, f[i]+g[i]);
        printf("%d\n", (ans==0)?-1:ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-: