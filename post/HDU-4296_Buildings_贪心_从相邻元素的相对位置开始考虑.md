题目链接：<https://cn.vjudge.net/problem/HDU-4296>

### 题意
有很多板子，每一个板子有重量(w)和承重(s)能力
现规定一块板子的PDV值为其上所有板子的重量和减去这个板子的承重能力
整个系统的优劣由每块板子中PDV最大值决定，越小越好
求最好系统的最大PDV值

### 思路
套路题了，**一般问最小化系统最大值，就是从相对位置开始考虑**
随便找凉快板子，在第一块板子放下面最优的情况，开始讨论
可得w+s越小的越在上面，排序求值即可

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
    long long w, s;
    bool operator < (Node &a) const{
        return w+s<a.w+a.s;
    }
}node[maxn];

int main(void){
    int n;

    while (scanf("%d", &n)==1 && n){
        for (int i=0; i<n; i++)
            scanf("%lld%lld", &node[i].w, &node[i].s);
        sort(node, node+n);

        long long ans=-node[0].s, tot=node[0].w;
        for (int i=1; i<n; i++){
            long long res=tot-node[i].s; tot+=node[i].w;
            if (ans<res) ans=res;
        }printf("%lld\n", ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
546ms|3168kB|610|G++|2018-06-23 14:24:14