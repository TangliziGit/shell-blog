题目链接：<https://cn.vjudge.net/problem/HDU-1024>

### 题意
给n, m和一个序列，找m个不重叠子串，使这几个子串内元素和的和最大。
n<=1e6
例：1 3 1 2 3
答：6 (唯一的子串1 2 3)

### 思路
先顺便记录一下动态规划的一般解题思路：
原问题->子问题->状态->转移->边界

再顺便记录一下最大值最小化这类问题套路解法：
1. 二分
2. 贪心
不能二分的问题，贪心八九不离十。
一般是AB和BA这两个元素的顺序，不影响前后变化时，直接算目标函数的大小，再按某个数据组合排序即可。
这里还有赖皮写法。
算不出，看不出如何贪心时，随便找个数据组合排个序算答案，直到蒙对为止。

一开始的方程有些擦边，时间有些紧张，还是应该仔细想想（话说我都不知道有这个课前测试，等上课等了半个小时-_-
dp[i][j]表示选择第i个元素，当前是第j个子串。
dp[i][j]=max(dp[i-1][j], dp[k][j-1])+num[i], (k<=i-1)
很显然发现O(n^3)超时，那么开始优化。
第一个显然的优化是max(dp[k][j-1])，这个东西可以一边计算一边维护，但一定要注意细节。
第二个优化其实也是很显然，滚动数组优化掉第一维。

### 提交过程
|||
:-|:-
WA|maxdp数组维护错了
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e6+20, INF=0x3f3f3f3f;
int num[maxn], dp[maxn], maxdp[maxn];
int n, m;

int main(void){
    while (scanf("%d%d", &m, &n)==2){
        for (int i=1; i<=n; i++) scanf("%d", &num[i]);

        memset(dp, 0, sizeof(dp));
        memset(maxdp, 0, sizeof(maxdp));

        int maxtmp;
        for (int j=1; j<=m; j++){
            maxtmp=-INF;
            for (int i=j; i<=n; i++){
                dp[i]=max(dp[i-1], maxdp[i-1])+num[i];
                maxdp[i-1]=maxtmp;// max(maxdp[i-1], tmp);
                maxtmp=max(dp[i], maxtmp);
            }
        }

        printf("%d\n", maxtmp);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
390ms|9432kB|708|G++|2018-08-13 01:55:29