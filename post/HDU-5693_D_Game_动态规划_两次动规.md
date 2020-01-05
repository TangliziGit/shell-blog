题目链接：<https://cn.vjudge.net/problem/HDU-5693>

### 题意
中文题
这个游戏是这样的，首先度度熊拥有一个公差集合{D}，然后它依次写下N个数字排成一行。游戏规则很简单：
1. 在当前剩下的有序数组中选择X(X≥2) 个连续数字；
2. 检查1选择的X个数字是否构成等差数列，且公差 d∈{D}；
3. 如果2满足，可以在数组中删除这X个数字；
4. 重复 1−3 步，直到无法删除更多数字。
度度熊最多能删掉多少个数字，如果它足够聪明的话。
n, m<=300

### 思路
一开始又没思路，最后还是老师给的答案。
现在想想的话，我们可以记住有哪些常见状态和转移，以便提升发展。

设dp[i]为前i个数字下能删去的数字和，那么转移方程：
dp[i]=max(dp[i-1], max( dp[j-1]+i-j+1 | [i, j]为可删去的区间 ))
好了转移方程有了，那么可删区间怎么来？
这里可以按区间长度动规，我是怎么也没想到这点：
我们将x表示为某等差序列，[]表示可删子区间，那么整个可删区间可以表示为：
例子：x[]x[][]x[][][]xxx[]x[]
那么为了唯一的（保证一个DAG）分开所有可删子区间，我们可以这样子：
1. 区间可分为两个可删区间，dp=max(dp[i][k]+dp[k+1][j])
2. 区间两端可以删去等差数列，dp=max(dp[i+1][j-1])
3. 区间两端和中间可以删去等差数列，dp=max(dp[i+1][k-1]+dp[k+1][j-1])

那么状态转移就可以写了。

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <set>
#include <cstdio>
#include <cstring>
using namespace std;
const int maxn=300+20, maxm=maxn;
set<long long> isd;
int num[maxn], dp[maxn];
bool seg[maxn][maxn];
long long tmp;

int main(void){
    int T, n, m;

    scanf("%d", &T);
    while (T--){
        scanf("%d%d", &n, &m);
        isd.clear();
        memset(seg, false, sizeof(seg));
        for (int i=1; i<=n; i++) scanf("%d", &num[i]), seg[i][i-1]=true;
        for (int i=0; i<m; i++) scanf("%lld", &tmp), isd.insert(tmp);

        for (int len=1; len<n; len++)
            for (int i=1; i+len<=n; i++){
                int j=i+len;

                if (seg[i+1][j-1] && isd.count(num[j]-num[i]))
                    seg[i][j]=true;
                if (!seg[i][j]) for (int k=i+1; k<j; k++){
                    seg[i][j]=seg[i][k]&&seg[k+1][j];    // 1
                    if (seg[i][j]) break;
                }
                if (!seg[i][j]) for (int k=i+1; k<j; k++){
                    if (num[k]-num[i]==num[j]-num[k] && isd.count(num[k]-num[i])){
                        seg[i][j]=seg[i+1][k-1]&&seg[k+1][j-1];    // 2
                        if (seg[i][j]) break;
                    }
                }
            }

        memset(dp, 0, sizeof(dp));
        for (int i=1; i<=n; i++){
            dp[i]=dp[i-1];
            for (int j=1; j<=i-1; j++) if (seg[j][i])
                dp[i]=max(dp[i], dp[j-1]+i-j+1);        // 3
        }printf("%d\n", dp[n]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
561ms|1360kB|1470|G++|2018-08-07 02:54:18