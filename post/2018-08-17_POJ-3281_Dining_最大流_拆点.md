题目链接：<https://cn.vjudge.net/problem/POJ-3281>

### 题意
题意找kuangbin的用了。
有N头牛，F个食物，D个饮料。
N头牛每头牛有一定的喜好，只喜欢几个食物和饮料。
每个食物和饮料只能给一头牛。一头牛只能得到一个食物和饮料。
而且一头牛必须同时获得一个食物和一个饮料才能满足。问至多有多少头牛可以获得满足。

### 思路
建图如下就完事了：
<img width="300" src="https://images2018.cnblogs.com/blog/1225237/201808/1225237-20180817181715424-4654488.jpg" />

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <queue>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=400+20, INF=1e8;
struct Edge{
    int from,to,cap,flow;
    Edge(int u,int v,int c,int f):
        from(u), to(v), cap(c), flow(f) {}
};
struct Dinic{
    int n, m, s, t;
    vector<int> G[maxn];
    vector<Edge> edges;
    bool vis[maxn];
    int dep[maxn], cur[maxn];
    void init(int n){
        this->n=n;
        for (int i=0;i<=n;i++) G[i].clear();
        edges.clear();
    }
    void addEdge(int from, int to, int cap){
        edges.push_back(Edge(from, to, cap, 0));
        edges.push_back(Edge(to, from, 0, 0));
        m=edges.size();
        G[from].push_back(m-2);
        G[to].push_back(m-1);
    }
    bool bfs(void){
        memset(vis, false, sizeof(vis));
        queue<int> Q;
        vis[s]=true;
        dep[s]=0;

        Q.push(s);
        while(!Q.empty()){
            int x=Q.front(); Q.pop();
            for(int i=0;i<G[x].size();i++){
                Edge &e=edges[G[x][i]];
                if(!vis[e.to] && e.cap>e.flow){
                    vis[e.to]=1;
                    dep[e.to]=dep[x]+1;
                    Q.push(e.to);
                }
            }
        }
        return vis[t];
    }
    int dfs(int x, int a){
        if(x==t || a==0)return a;
        int flow=0, f;
        for(int &i=cur[x];i<G[x].size();i++) {
            Edge &e=edges[G[x][i]];
            if(dep[e.to]==dep[x]+1 && (f=dfs(e.to, min(a, e.cap-e.flow)))>0){
                e.flow+=f;
                edges[G[x][i]^1].flow-=f;
                flow+=f;
                a-=f;
                if(a==0)break;
            }
        }
        return flow;
    }
    int maxFlow(int s, int t){
        this->s=s; this->t=t;

        int flow=0;
        while(bfs()){
            memset(cur, 0, sizeof(cur));
            flow+=dfs(s, INF);
        }
        return flow;
    }
}dinic;

int n, f, d, psize;
int main(void){
    int from, to, cap, fn, dn, tmp;
    while (scanf("%d%d%d", &n, &f, &d)==3 && n){
        dinic.init(n*2+f+d+2);
        psize=f+d+2;
        for (int i=0; i<f; i++)
            dinic.addEdge(1, i+3, 1);

        for (int i=0; i<d; i++)
            dinic.addEdge(i+f+3, 2, 1);

        for (int i=0; i<n; i++){
            int in=psize+1, out=psize+2;
            psize+=2;

            scanf("%d%d", &fn, &dn);
            for (int j=0; j<fn; j++){
                scanf("%d", &tmp);
                dinic.addEdge(tmp+2, in, 1);
            }
            for (int j=0; j<dn; j++){
                scanf("%d", &tmp);
                dinic.addEdge(out, tmp+f+2, 1);
            }
            dinic.addEdge(in, out, 1);
        }
        printf("%d\n", dinic.maxFlow(1, 2));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
16ms|304kB|2746|C++|2018-08-17 03:17:52