题目链接：<https://cn.vjudge.net/problem/HDU-2955>

### 题意
突然想找几个银行抢钱。
给出各银行的钱数和被抓的概率，以及能容忍的最大被抓概率。
问他最多能抢到多少钱？

### 思路
很好的一道题，受益良多。
1. 代价是浮点数，不易存储计算。
考虑到背包函数dp[cost]=val是个单调的，理论上自变量和因变量没有区别，可以位置互换。
这样有函数: $ dp^-1[val]=cost $
2. 可以发现本题代价的计算不是简单的加法，而是乘法关系。
如果令dp为被抓的概率，有：dp[j]=max(dp[j], (1-dp[j-val[i]])*cost[i]);
但这样的边界难以给定
如果令dp为逃脱的概率，有：dp[j]=max(dp[j], dp[j-val[i]]*(1-cost[i]));
边界即为dp[0]=1
最后的输出解只需由大到小查dp数组即可，详细见代码。

### 提交过程
|||
:-|:-
WA|变量没有互换，只是简单的把浮点数乘因子，转成整数
AC

### 代码
```cpp
#include <cmath>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e5+20;
const double eps=1e-8;
double cost[maxn], total, dp[maxn];
int val[maxn], n;
bool equal(double a, double b){
    return (a-b)<eps && (b-a)<eps;
}

int main(void){
    int T;

    scanf("%d", &T);
    while (T--){
        scanf("%lf%d", &total, &n);

        int sumval=0;
        for (int i=1; i<=n; i++){
            scanf("%d%lf", &val[i], &cost[i]);
            sumval+=val[i];
        }

        for (int i=0; i<=sumval; i++) dp[i]=0;
        dp[0]=1;
        for (int i=1; i<=n; i++){
            for (int j=sumval; j>=val[i]; j--)
                dp[j]=max(dp[j], dp[j-val[i]]*(1-cost[i]));
        }

        int ans;
        for (int i=sumval; i>=0; i--)
            if (1-dp[i]<total || equal(1-dp[i], total)){
                ans=i; break;
            }
        printf("%d\n", ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
31ms|1292kB|935|G++|2018-08-20 21:48:58