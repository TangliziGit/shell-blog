题目链接：<https://cn.vjudge.net/problem/HDU-5009>

### 题意
给一串序列，可以任意分割多次序列，每次分割的代价是被分割区间中的数字种数。
求分割区间的最小代价。n<=5e4
例：1 3 3
答：2

### 思路
今天刚讲的dp题目，这次讲课收益非常，写个题解。
状态和转移是dp[i]=min(dp[j]+cnt[j-1][i]^2)
会发现这样绝对超时，又发现这里的j可以贪心的跳着选择（因为种数相同时，左端点应越小越好）。
这里的跳着选择想了半天没什么思路，又是最后看了题解-_-
双向链表在排除某一元素时非常有用，以前只用过一次，这次真的是感受到这玩意的通用之处了（话说这个东西应该非常方便，继并查集之后的又一轻量级数据结构）

### 提交过程
|||
:-|:-
TLE|注意当区间的种类超过sqrt(i)时，不如一个一个选，跳出即可
WA|注意边界dp[0]=0, 而非dp[1]=1
AC|

### 代码
```cpp
#include <map>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=5e4+20, INF=0x3f3f3f3f;
int n, clr[maxn], pre[maxn], nex[maxn];
int dp[maxn];

int main(void){
    while (scanf("%d", &n)==1 && n){
        for (int i=1; i<=n; i++) scanf("%d", &clr[i]);

        for (int i=1; i<=n; i++) dp[i]=INF;
        for (int i=1; i<=n; i++)
            pre[i]=i-1, nex[i]=i+1;
        pre[0]=-1; nex[n]=-1;

        dp[0]=0;
        map<int, int>id;
        for (int i=1; i<=n; i++){
            if (!id.count(clr[i])) id[clr[i]]=i;
            else{
                int idx=id[clr[i]];
                pre[nex[idx]]=pre[idx];
                nex[pre[idx]]=nex[idx];
                id[clr[idx]]=i;
            }

            for (int k=pre[i], cnt=1; k!=-1; k=pre[k], cnt++){
                dp[i]=min(dp[i], dp[k]+cnt*cnt);
                if (cnt*cnt>i) break;
            }
        }
        printf("%d\n", dp[n]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
686ms|3444kB|975|G++|2018-08-13 08:37:10