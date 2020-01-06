题目链接：<https://cn.vjudge.net/problem/HDU-3586>

### 题意
敌方人员成一棵树状，前线人员为叶子节点，司令为树根。
两节点之间边权为wi。
现欲切断司令与前线的联系，问在切断边权值之和小于m时，最大边权最小为多少。

### 思路
二分最小值，树状dp[i]求子树被处理后的边权和。

### 提交过程
|||
:-|:-
WA|INF给太大了，溢出了
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e3+20, maxm=maxn*2, INF=1e5+25;
struct Edge{
    int to, next, dis;
    Edge(int to=0, int dis=0, int next=0):
        to(to), dis(dis), next(next) {}
}edges[maxm];
int head[maxn], esize;
int n, m, val[maxn];

void init(void){
    memset(head, -1, sizeof(head));
    esize=0;
}

void addEdge(int from, int to, int dis){
    edges[esize]=Edge(to, dis, head[from]);
    head[from]=esize++;
}

int dp(int u, int fa, int mid){
    int total=0;
    bool flg=false;
    for (int i=head[u]; i!=-1; i=edges[i].next)
        if (edges[i].to!=fa){
            int &to=edges[i].to, one=dp(to, u, mid);
            if (edges[i].dis<=mid) one=min(one, edges[i].dis);
            total+=one;

            flg=true;
        }
    return (flg)?total:INF;
}

int solve(int mine, int maxe){
    int l=mine, r=maxe;
    while (l<r){
        int mid=l+(r-l)/2;
        if (dp(1, -1, mid)<=m) r=mid;
        else l=mid+1;
    }
    for (int i=max(mine, l); i<=min(maxe, r); i++)
        if (dp(1, -1, i)<=m)
            return i;
    return -1;
}

int main(void){
    int from, to, dis;

    while (scanf("%d%d", &n, &m)==2 && n){
        init();

        int maxe=0, mine=INF;
        for (int i=0; i<n-1; i++){
            scanf("%d%d%d", &from, &to, &dis);
            addEdge(from, to, dis);
            addEdge(to, from, dis);
            mine=min(mine, dis);
            maxe=max(maxe, dis);
        }

        printf("%d\n", solve(mine, maxe));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
374ms|1244kB|1549|G++|2018-08-16 00:30:44