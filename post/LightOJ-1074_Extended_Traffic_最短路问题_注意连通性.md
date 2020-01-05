题目链接：<https://cn.vjudge.net/problem/LightOJ-1074>

### 题意
给一图
求最短路
若最短路<3或没有最短路，则输出'?'

### 思路
首先注意到可能存在负环，所以想到Bellman
这时注意检测出负环时，需要找到所有与其连通的节点(dfs处理)

然而这是一道怪题。。。
用long long存边权，WA5发
改成int存边权才过
怀疑我是哪里运算问题了

### 代码
```cpp
#include <queue>
#include <cstdio>
#include <cstring>
using namespace std;
const int maxn=220, maxm=maxn*maxn, INF=0x3f3f3f3f;
struct Edge{
    int to, dis, next;
}edges[maxm+5];
int busy[maxn+5], head[maxn+5], esize;
int dist[maxn+5];
bool vis[maxn+5];

inline void addEdge(int from, int to, int dis){
    edges[esize]=(Edge){to, dis*dis*dis, head[from]};
    head[from]=esize++;
}

void dfs(int x){
    vis[x]=true;
    for (int i=head[x]; i!=-1; i=edges[i].next){
        Edge &e=edges[i];

        if (vis[e.to]) continue;
        dfs(e.to);
    }
}

void Bellman(int n){
    bool inq[maxn+5]={false};
    int cnt[maxn+5]={0};
    queue<int> que;
    
    memset(dist, INF, sizeof(dist));
    memset(vis, false, sizeof(vis));
    dist[1]=0; inq[1]=true;
    que.push(1);

    while (que.size()){
        int from=que.front(); que.pop();
        inq[from]=false;

        for (int i=head[from]; i!=-1; i=edges[i].next){
            Edge &e=edges[i];
            int &to=e.to, &dis=e.dis;

            if (vis[to]) continue;
            if (dist[to]<=dist[from]+dis) continue;
            dist[to]=dist[from]+dis;

            if (inq[to]) continue;
            if (++cnt[to]>=n) dfs(to);
            else que.push(to);
            inq[to]=true;
        }
    }
}

void init(void){
    memset(head, -1, sizeof(head));
    esize=0;
}

int main(void){
    int T, n, m, q, from, to;

    scanf("%d", &T);
    for (int cnt=1; cnt<=T; cnt++){
        init();
        scanf("%d", &n);
        for (int i=1; i<=n; i++) scanf("%d", &busy[i]);
        scanf("%d", &m);
        for (int i=0; i<m; i++){
            scanf("%d%d", &from, &to);
            addEdge(from, to, busy[to]-busy[from]);
        }
        
        Bellman(n);
        scanf("%d", &q);
        printf("Case %d:\n", cnt);
        while (q--){
            scanf("%d", &from);
            if (vis[from] || dist[from]<3 || dist[from]==INF) printf("?\n");
            else printf("%d\n", dist[from]);
        }
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
48ms|1816kB|2033|C++|2018-06-01 17:50:02