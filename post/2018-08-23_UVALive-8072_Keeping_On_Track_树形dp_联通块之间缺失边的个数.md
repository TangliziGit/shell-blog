题目链接：<https://cn.vjudge.net/problem/UVALive-8072>

### 题意
给出n+1个点和n条边，每对点之间只能存在一条边。
现在要找出一个节点，使得去掉这个点后，所剩每对不联通点的点对数最大。
还要在去掉这个点后加上一条边，使得加上这个边后，不联通点对数最小。
例：
6
0  1
1  2
2  3
2  4
4  5
4  6
答：11 5

### 思路
看不懂题意，更看不懂样例；只能临场猜题意，猜样例。
现在解释一下样例的意思。
首先画出这个无向图，然后找特殊节点。我帮你找到2这个节点是特殊点。
那么去掉节点2，现在有三个联通子图，分别是456-3-01。
再数缺失点对：4-3; 4-0; 4-1; 5-3;...，一共11对。
现在加上60这条边，缺失点对就是最小的5。（当然41也可以，实际上只要最大的两个联通图链接起来即可）

好的现在看懂题意了，显然发现原图是颗树。
而特殊节点就是树里边的某个节点。
去掉这个节点，可以使图分为子节点数+1个联通图。
缺失点对其实就是联通图点数分别乘当前的前缀和（当然，等于每个点数相乘，但是复杂度降低了）。
比如说样例的2节点，使原图分为3个联通图，点数为3，1，2。
那么缺失点对数计算如下：
3*1+(3+1)*2=11
加一条边的最少缺失点对的计算，其实就是问哪两个联通图组合起来，有最少缺失点对。
很显然是最大的两个图组合起来（回忆初中二次函数问题，点数和等于n-1）。
这样我们首先树形dp算子树大小、计算缺失点对，最后查最大值，计算最小缺失点对即可。
整个复杂度可以到达O(n)。

### 提交过程
|||
:-|:-
WA|少写个加号
AC|

### 代码
```cpp
#include <vector>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e4+20;
vector<int> son[maxn];
int data[maxn], n, fat[maxn];
long long val[maxn];
int dp(int u, int fa){
    fat[u]=fa;
    if (data[u]>0) return data[u];

    vector<int> pre, tmp;
    data[u]=1;
    for (int i=0; i<son[u].size(); i++) if (son[u][i]!=fa){
        tmp.push_back(dp(son[u][i], u));
        if (tmp.size()!=1) pre.push_back(pre.back()+tmp.back());
        else pre.push_back(tmp.back());

        data[u]+=tmp.back();
    }

    int size=tmp.size();
    if (size==0) val[u]=0;
    else{
        val[u]=pre[size-1]*(n-data[u]+1);
        for (int i=1; i<size; i++)
            val[u]+=pre[i-1]*tmp[i];
    }

    return data[u];
}

void solve(void){
    long long mmax=0, idx=0;
    for (int i=0; i<=n; i++) if (mmax<val[i]){
        idx=i; mmax=val[i];
    }

    int psize=0, tmp[maxn];
    for (int i=0; i<son[idx].size(); i++) if (son[idx][i]!=fat[idx])
        tmp[psize++]=dp(son[idx][i], idx);
    tmp[psize++]=n+1-data[idx];
    sort(tmp, tmp+psize);
    tmp[psize-2]+=tmp[psize-1];
    psize--;


    long long ans=0, pree=tmp[0];
    for (int i=1; i<psize; i++){
        ans+=pree*tmp[i];
        pree+=tmp[i];
    }

    printf("%lld %lld\n", mmax, ans);
}

int main(void){
    int a, b;
    while (scanf("%d", &n)==1){
        memset(data, -1, sizeof(data));
        for (int i=0; i<=n; i++) son[i].clear();
        for (int i=0; i<n; i++){
            scanf("%d%d", &a, &b);
            son[a].push_back(b);
            son[b].push_back(a);
        }

        dp(0, -1);
        solve();
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
33ms|1650|C++ 5.3.0|2018-08-23 04:16:14