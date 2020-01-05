题目链接：<https://cn.vjudge.net/problem/HDU-5534>

### 题意
放学路上看到n个节点，突然想把这几个节点连成一颗树。
树上每个节点有一个清凉度，清凉度是一个关于节点度的函数。
问能够组成树的最大清凉度是多少。

### 思路
看到题目瞬间考虑一共有n-1条边，各节点的度之和是2n-2。
那么猜测每个节点上分配度数是一个完全背包。
画了两个例子结果是没问题。

注意可能有的节点将不被分配度数，所以要预分配一个度
dp[0]=n*val[1]
这样做的原理是每个节点必然可以分配到一个度，而每次更新度数时必然可以替换掉一个初始度数。
所以最终的答案应该是每个节点都有度数。
1. 预分配dp[0]=n*val[1];并且因为必须从0开始（填满背包），所以其他dp[i]=-INF保证取不了
2. 注意预分配后，每个节点的度变为1，所以再更新节点时把节点代价减1，背包大小减n

### 提交过程
|||
:-|:-
AC|一开始没有初始分配度数，最后看了题解才懂得

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=2015+20, INF=1e8;
int dp[maxn], val[maxn], n;

int main(void){
    int T;

    scanf("%d", &T);
    while (T--){
        scanf("%d", &n);
        for (int i=1; i<=n-1; i++) scanf("%d", &val[i]);

        for (int i=1; i<=n-1; i++) dp[i]=-INF;
        dp[0]=n*val[1];
        for (int i=2; i<=n-1; i++){
            for (int j=i-1; j<=n-2; j++) // attend: i-1
                dp[j]=max(dp[j], dp[j-i+1]+val[i]-val[1]);
        }
        printf("%d\n", dp[n-2]);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
62ms|1228kB|578|G++|2018-08-21 03:47:13