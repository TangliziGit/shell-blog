题目链接：<https://cn.vjudge.net/problem/HDU-4221>

### 题意
给n个活动，每个活动需要一段时间C来完成，并且有一个截止时间D
当完成时间t大于截止时间完成时，会扣除t-D分
找出如何使所扣分的最大值最小的那个最小值

### 思路
又是一道**最小化最大值**的题目
**入手点还是相对位置**
一样地讨论任意两个元素，使第一个元素放在前面为最优解，分析条件
d越小越在前面

### 提交过程
|||
:-|:-
AC|套路题

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
const int maxn=1e5+20;
struct Node{
    long long c, d;
    bool operator < (Node &a) const{
        return d<a.d;
    }
}node[maxn];

int main(void){
    int T, n, cnt=1;

    scanf("%d", &T);
    while (T--){
        scanf("%d", &n);
        for (int i=0; i<n; i++)
            scanf("%lld%lld", &node[i].c, &node[i].d);
        sort(node, node+n);

        long long ans=0, sum=0;
        for (int i=0; i<n; i++){
            long long delta=sum+node[i].c-node[i].d;
            if (delta>ans) ans=delta;
            sum+=node[i].c;
        }printf("Case %d: %lld\n", cnt++, ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
655ms|3168kB|667|G++|2018-06-23 15:00:50