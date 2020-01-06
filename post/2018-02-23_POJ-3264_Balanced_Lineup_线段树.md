题目链接：<https://cn.vjudge.net/problem/POJ-3264>

### 题意
给出N，Q
在一个含有N个数的序列中，询问[a, b]中的最大值最小值差值Q次

### 思路
其实就是查询区间最值
- 一开始可以想到维护一个二维数组来存区间差值
然而算了一下，空间根本不够
没办法，写线段树吧
- 用线段树的区间查询函数即可
- 还有一种解决方法，就是**ST算法**(Sparse Table)
O(nlog(n))的初始化，O(1)的查询
空间是O(nlog(n))
我的理解是ST算法主要进行了单个值的传递，最经典的例子是求区间最值
当然最值问题也可以演变成很多问题，通解就是构造一个结构，写比较函数即可

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int MAX=131072;
int n, q, tmin[MAX+5], tmax[MAX+5], num[MAX+5];
void pushUp(int root){
    tmax[root]=max(tmax[root<<1], tmax[root<<1|1]);
    tmin[root]=min(tmin[root<<1], tmin[root<<1|1]);
}

void build(int l, int r, int root){
    if (l==r){
        tmax[root]=tmin[root]=num[l];
        return ;
    }

    int mid=(l+r)>>1;
    build(l, mid, root<<1);
    build(mid+1, r, root<<1|1);
    pushUp(root);
}

int queryMax(int l, int r, int L, int R, int root){
    if (l<=L && R<=r) return tmax[root];

    int M=(L+R)>>1, ans=0;
    if (l<=M) ans=max(ans, queryMax(l, r, L, M, root<<1));
    if (r>=M+1) ans=max(ans, queryMax(l, r, M+1,R, root<<1|1));
    return ans;
}

int queryMin(int l, int r, int L, int R, int root){
    if (l<=L && R<=r) return tmin[root];

    int M=(L+R)>>1, ans=1000005;
    if (l<=M) ans=min(ans, queryMin(l, r, L, M, root<<1));
    if (r>=M+1) ans=min(ans, queryMin(l, r, M+1,R, root<<1|1));
    return ans;
}

int main(void){
    while (scanf("%d%d", &n, &q)==2){
        for (int i=1; i<=n; i++) scanf("%d", &num[i]);
        build(1, n, 1);

        int a, b;
        while (q--){
            scanf("%d%d", &a, &b);
            printf("%d\n", queryMax(a, b, 1, n, 1) - queryMin(a, b, 1, n, 1));
        }
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
3829ms|1572kB|1347|G++|2018-02-22 20:19:52