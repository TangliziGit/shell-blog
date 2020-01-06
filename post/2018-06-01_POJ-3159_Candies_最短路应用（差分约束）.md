题目链接：<https://cn.vjudge.net/problem/POJ-3159>

### 题意
给出一组不等式
求第一个变量和最后一个变量可能的最大差值
数据保证有解

### 思路
一个不等式a-b<=c，通过移项，实际上就是满足了a<=b+c
发现在整个约束系统中，a在下满足不等式的情况下求最大值，就是在求最短路

然而如果直接用BellmanFord(spfa)的话，还是会超时
这时得对Bellman做第二次优化，用stack代替queue
但是对于更多的图中，Dijsktra依然更优，所以没有必要太过考虑这个问题？

### 代码
**Dijkstra**
```cpp
#include <queue>
#include <cstdio>
#include <cstring>
using namespace std;
const int maxn=3e4+20, maxm=15e4+20, INF=0x3f3f3f3f;
typedef pair<int, int> Node;
struct Cmp{
    bool operator () (const Node &a, const Node &b){
        return a.first>b.first;
    }
};
struct Edge{
    int to, dis, next;
}edges[maxm+5];
int head[maxn+5], size=0;

void addEdge(int from, int to, int dis){
    edges[size]=Edge{to, dis, head[from]};
    head[from]=size++;
}

void init(void){
    memset(head, -1, sizeof(head));
    size=0;
}

int Bellman(int n){
    int dist[maxn+5], sta[maxn+5], top=0;//cnt[maxn+5];
    bool inq[maxn+5]={false};
    // queue<int> que;

    memset(dist, INF, sizeof(dist)); dist[1]=0;
    sta[top++]=1;
    while (top!=0){
        int from=sta[--top];
        inq[from]=false;

        for (int i=head[from]; i!=-1; i=edges[i].next){
            Edge &e=edges[i];
            int &to=e.to, &dis=e.dis;

            if (dist[to]<=dist[from]+dis) continue;
            dist[to]=dist[from]+dis;

            if (inq[to]) continue;
            sta[top++]=to; inq[to]=true;
        }
    }return dist[n];
}

int Dij(int n){
    int dist[maxn+5];
    priority_queue<Node, vector<Node>, Cmp> que;

    memset(dist, INF, sizeof(dist)); dist[1]=0;
    que.push(Node(dist[1], 1));
    while (que.size()){
        Node x=que.top(); que.pop();
        if (x.first!=dist[x.second]) continue;

        int &from=x.second;
        for (int i=head[from]; i!=-1; i=edges[i].next){
            Edge &e=edges[i];
            int &to=e.to, &dis=e.dis;

            if (dist[to]<=dist[from]+dis) continue;
            dist[to]=dist[from]+dis;
            que.push(Node(dist[to], to));
        }
    }return dist[n];
}

int main(void){
    int n, m, from, to, dis;

    init();
    scanf("%d%d", &n, &m);
    for (int i=0; i<m; i++){
        scanf("%d%d%d", &from, &to, &dis);
        addEdge(from, to, dis);
    }printf("%d\n", Dij(n));//Bellman(n));

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
532ms|2568kB|1960|G++|2018-05-27 00:47:58


**BellmanFord**
```cpp
#include <queue>
#include <cstdio>
#include <cstring>
using namespace std;
const int maxn=3e4+20, maxm=15e4+20, INF=0x3f3f3f3f;
struct Edge{
    int to, dis, next;
}edges[maxm+5];
int head[maxn+5], size=0;

void addEdge(int from, int to, int dis){
    edges[size]=Edge{to, dis, head[from]};
    head[from]=size++;
}

void init(void){
    memset(head, -1, sizeof(head));
    size=0;
}

int Bellman(int n){
    int dist[maxn+5], sta[maxn+5], top=0;//cnt[maxn+5];
    bool inq[maxn+5]={false};
    // queue<int> que;

    memset(dist, INF, sizeof(dist)); dist[1]=0;
    sta[top++]=1;
    while (top!=0){
        int from=sta[--top];
        inq[from]=false;

        for (int i=head[from]; i!=-1; i=edges[i].next){
            Edge &e=edges[i];
            int &to=e.to, &dis=e.dis;

            if (dist[to]<=dist[from]+dis) continue;
            dist[to]=dist[from]+dis;

            if (inq[to]) continue;
            sta[top++]=to; inq[to]=true;
        }
    }return dist[n];
}

int main(void){
    int n, m, from, to, dis;

    init();
    scanf("%d%d", &n, &m);
    for (int i=0; i<m; i++){
        scanf("%d%d%d", &from, &to, &dis);
        addEdge(from, to, dis);
    }printf("%d\n", Bellman(n));

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
485ms|2108kB|1220|G++|2018-05-27 00:39:53