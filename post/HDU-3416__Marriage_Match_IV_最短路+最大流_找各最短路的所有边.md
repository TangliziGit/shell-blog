题目链接：<https://cn.vjudge.net/problem/HDU-3416>

### 题意
给一个图，求AB间最短路的条数（每一条最短路没有重边。可有重复节点）

### 思路
首先把全部最短路的边找出来，再来一遍最大流

所以如何找到全部最短路的边就是一个问题了
首先求从A到B的各节点最短路，再求B到A的最短路（注意把边反向）
便利所有边，如果满足distA[from]+distB[to]+dist==distA[B]，那么这个边{from, to, dist}就是最短路中的一个边

然后最大流即可

### 提交过程
|||
:-|:-
TLE1|纯属胡写，给了最小费用最大流的代码
TLE2|胡写2，给代码加了个判断，总是求最短路的最大流
TLE3|思路正确，然而超时，应该是**EdmondsKarp超时**
TLE4|Bellman栈优化，超时原因同上
TLE5|EdmondsKarp换SAP，超时原因可能是**maxn和maxm给少了**
TLE6|怀疑Bellman栈优化有问题，换回队列
MLE7|maxn和maxm给多了
AC|maxn和maxm按原题乘以2
TLE7|怀疑EdmondsKarp超时，于是试了试，果然如此

### 代码
```cpp
#include <stack>
#include <queue>
#include <cstdio>
#include <cstring>
using namespace std;
const int maxn=2e3+10, maxm=2e5+10, INF=0x3f3f3f3f;
struct Edge{
    int to, dis, next;
    Edge(int to=0, int dis=0, int next=0):
        to(to), dis(dis), next(next) {}
}edges[maxm+5];
struct FlowEdge{
    int from, to, cap, flow, next;
    FlowEdge(int from=0, int to=0, int cap=0, int next=0):
        from(from), to(to), cap(cap), next(next) {}
}fedges[maxm+5];
int head[maxn+5], fhead[maxn+5], esize, fsize, dis[2][maxn+5];

void init(void){
    memset(head, -1, sizeof(head));
    esize=0;
}

void addEdge(int from, int to, int dis){
    edges[esize]=Edge(to, dis, head[from]);
    head[from]=esize++;
}

bool Bellman(int st, int n, int which){
    bool inq[maxn+5]={false};
    int cnt[maxn+5]={0}, dist[maxn+5];
    queue<int> que; // stack<int> sta;
    memset(dist, INF, sizeof(dist));
    dist[st]=0; inq[st]=true; cnt[st]=1;
    
    que.push(st); // sta.push(st);
    while (que.size()){
        int from=que.front(); que.pop();
        inq[from]=false;

        for (int i=head[from]; i!=-1; i=edges[i].next){
            Edge &e=edges[i];
            int &to=e.to;

            if (dist[to]<=dist[from]+e.dis) continue;
            dist[to]=dist[from]+e.dis;

            if (inq[to]) continue;
            inq[to]=true; que.push(to);

            if (++cnt[to]>n) return false;
        }
    }
    memcpy(dis[which], dist, sizeof(dist));
    return true;
}

void finit(void){
    memset(fhead, -1, sizeof(fhead));
    fsize=0;
}

void addFlowEdge(int from, int to, int cap){
    fedges[fsize]=FlowEdge(from, to, cap, fhead[from]);
    fhead[from]=fsize++;
    fedges[fsize]=FlowEdge(to, from, 0, fhead[to]);
    fhead[to]=fsize++;
}

int d[maxn+5], pre[maxn+5], gap[maxn+5], cur[maxn+5];
int sap(int start,int end,int nodenum){
    memset(d,0,sizeof(d));
    memset(gap,0,sizeof(gap));
    memcpy(cur,fhead,sizeof(fhead));
    int u=pre[start]=start,maxflow=0,aug=-1;
    gap[0]=nodenum;
    while(d[start]<nodenum){
        loop:
        for(int &i=cur[u];i!=-1;i=fedges[i].next){
            int v=fedges[i].to;
            if(fedges[i].cap&&d[u]==d[v]+1){
                if(aug==-1||aug>fedges[i].cap)
                    aug=fedges[i].cap;
                pre[v]=u;
                u=v;
                if(v==end){
                    maxflow+=aug;
                    for(u=pre[u];v!=start;v=u,u=pre[u]){
                        fedges[cur[u]].cap-=aug;
                        fedges[cur[u]^1].cap+=aug;
                    }
                    aug=-1;
                }
                goto loop;
            }
        }

        int mind=nodenum;
        for(int i=fhead[u]; i!=-1; i=fedges[i].next){
            int v=fedges[i].to;
            if(fedges[i].cap && mind>d[v]){
                cur[u]=i;
                mind=d[v];
            }
        }
        if((--gap[d[u]])==0) break;
        gap[d[u]=mind+1]++;
        u=pre[u];
    }
    return maxflow;
}

int main(void){
    int T, n, m;
    int from[maxm+5], to[maxm+5], di[maxm+5], st, tar;

    scanf("%d", &T);
    while (T--){
        scanf("%d%d", &n, &m);
        init();
        for (int i=0; i<m; i++){
            scanf("%d%d%d", &from[i], &to[i], &di[i]);
            addEdge(from[i], to[i], di[i]);
        }scanf("%d%d", &st, &tar);
        Bellman(st, n, 0);
        
        init();
        for (int i=0; i<m; i++)
            addEdge(to[i], from[i], di[i]);
        Bellman(tar, n, 1);

        finit();
        for (int i=0; i<m; i++)
            if (to[i]!=from[i] && dis[0][from[i]]+dis[1][to[i]]+di[i]==dis[0][tar])
                addFlowEdge(from[i], to[i], 1);
        printf("%d\n", sap(st, tar, n));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
140ms|10332kB|3727|G++|2018-06-09 00:24:00