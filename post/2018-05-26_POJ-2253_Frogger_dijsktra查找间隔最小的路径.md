题目链接：<https://cn.vjudge.net/problem/POJ-2253>

### 题意
一只Forg需要从节点1走到节点n
现要找一条各个间隔最小的路径
问间隔最小是多少

### 思路
用dijsktra就好
查找间隔最小的路径
1. 注意浮点数的比较

### 代码
```cpp
#include <cstdio>
#include <vector>
#include <queue>
#include <cmath>
using namespace std;
const int maxn=200, INF=0x3f3f3f3f;
const double eps=1e-6;
typedef pair<double, int> Pair;
struct Node{
    int x, y;
    Node(int x=0, int y=0):x(x), y(y) {}
}node[maxn+5];
struct Edge{
    int from, to;
    Edge(int from=0, int to=0):from(from), to(to) {}
};
vector<Edge> edges;
vector<int> G[maxn+5];
double dist[maxn+5];

void addEdge(int from, int to){
    edges.push_back(Edge(from, to));
    G[from].push_back(edges.size()-1);
    G[to].push_back(edges.size()-1);
}

inline bool equal(const double &a, const double &b){
    return (a-b<=eps && b-a<=eps);
}

inline double Dis(const int &a, const int &b){
    return sqrt((node[a].x-node[b].x)*(node[a].x-node[b].x)+
        (node[a].y-node[b].y)*(node[a].y-node[b].y));
}

double dij(void){
    for (int i=0; i<=maxn; i++) dist[i]=INF;
    priority_queue<Pair, vector<Pair>, greater<Pair> > que;
    que.push(Pair(0, 1)); dist[1]=0;


    while (que.size()){
        Pair x=que.top(); que.pop();
        if (!equal(x.first, dist[x.second])) continue;

        int from=x.second;
        for (int i=0; i<G[from].size(); i++){
            Edge &e=edges[G[from][i]];
            int to=(e.to==from)?e.from:e.to;
            double dis=Dis(to, from), mdis=max(dist[from], dis);

            if (dist[to]<mdis || equal(dist[to], mdis)) continue;
            dist[to]=mdis;
            que.push(Pair(dist[to], to));
        }
    }return dist[2];
}

int main(void){
    int n, cnt=1, x, y;

    while (scanf("%d", &n)==1 && n){
        for (int i=1; i<=n; i++){
            scanf("%d%d", &x, &y);
            node[i]=Node(x, y);
            for (int j=1; j<i; j++) addEdge(i, j);
        }
        printf("Scenario #%d\nFrog Distance = %.3f\n\n", cnt++, dij());
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
16ms|1476kB|1878|G++|2018-05-23 15:31:25