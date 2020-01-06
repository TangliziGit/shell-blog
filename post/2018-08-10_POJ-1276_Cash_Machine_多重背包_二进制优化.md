题目链接：<https://cn.vjudge.net/problem/POJ-1276>

### 题意
懒得写了自己去看好了，困了赶紧写完这个回宿舍睡觉，明早还要考试。

### 思路
多重背包的二进制优化。
思路是将n个物品拆分成log(m)个物品，可使得这些物品组合出1~n个原物品，这个用于01背包中。

### 提交过程
|||
:-|:-
WA|没理解num-=k
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1000+20, maxm=10+20, maxc=1e5+20;
int cash[maxm], num[maxn], dp[maxc], total, n;
char str[500];

void compKnap(int cost, int weight){
    for (int i=cost; i<=total; i++)
        dp[i]=max(dp[i], dp[i-weight]+cost);
}

void zeroKnap(int cost, int weight){
    for (int i=total; i>=cost; i--)
        dp[i]=max(dp[i], dp[i-weight]+cost);
}

int main(void){
    while (scanf("%d%d", &total, &n)==2){
        for (int i=0; i<n; i++)
            scanf("%d%d", &num[i], &cash[i]);
        
        memset(dp, 0, sizeof(dp));
        for (int i=0; i<n; i++){
            if (num[i]*cash[i]>=total){
                compKnap(cash[i], cash[i]);
            }else{
                int k=1;
                for (int k=1; k<num[i]; k*=2){
                    zeroKnap(cash[i]*k, cash[i]*k);
                    num[i]-=k;
                }
                zeroKnap(cash[i]*num[i], cash[i]*num[i]);
            }
        }
        printf("%d\n", dp[total]);

    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
47ms|552kB|1063|C++|2018-08-10 09:24:56