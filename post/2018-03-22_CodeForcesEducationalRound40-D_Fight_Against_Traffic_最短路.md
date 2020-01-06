题目链接：<http://codeforces.com/contest/954/problem/D>

### 题意
给出n个顶点，m条边，一个起点编号s，一个终点编号t
现准备在这n个顶点中多加一条边，使得st之间距离不变
问加边的方案数是多少

### 思路
想了半天才出思路，头一次打比赛时通过图论的题，挺高兴
因为是加一条边，所以我们可以考虑把这个新边的两端点进行更新
现用两个dist，一个是从起点开始的单源最短路dist[0]，一个是从终点开始的单源最短路dist[1]
对于一个新边的两端点ab，我们只用判断是否有dist[0][a]+dist[1][b]+e.dis>=dist[0][t] 和 dist[1][a]+dist[0][b]+e.dis>=dist[0][t]，若满足就说明这个新边是可行

### 代码
```cpp
#include <set>
#include <queue>
#include <vector>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
typedef pair<int, int> Node;
const int maxn=1000+5, maxm=1000+5, INF=0x3f3f3f3f;
struct Edge{
    int from, to;
    Edge(int from=0, int to=0):
        from(from), to(to) {}
};
vector<Edge> edge;
vector<int> G[maxn];
set<int> emap;
int n, dist[2][maxn];   // 0 for s, 1 for t
void addEdge(int from, int to){
    edge.push_back(Edge(from, to));
    G[from].push_back(edge.size()-1);
    G[to].push_back(edge.size()-1);
}

void Dijskra(int st, int idx){
    priority_queue<Node, vector<Node>, greater<Node> > que;
    que.push(Node(0, st));
    // for (int i=0; i<=n; i++) dist[idx][i]=INF;
    dist[idx][st]=0;
    while (que.size()){
        Node x=que.top(); que.pop();
        if (x.first!=dist[idx][x.second]) continue;

        int &from=x.second;
        for (int i=0; i<G[from].size(); i++){
            Edge &e=edge[G[from][i]]; int to=(e.from==from)?e.to:e.from;
            if (dist[idx][to]<=dist[idx][from]+1) continue;
            dist[idx][to]=dist[idx][from]+1;
            que.push(Node(dist[idx][to], to));
        }
    }
}

int main(void){
    int s, t, m;
    memset(dist, INF, sizeof(dist));
    scanf("%d%d%d%d", &n, &m, &s, &t);
    for (int i=0, a, b; i<m; i++){
        scanf("%d%d", &a, &b);
        if (a>b) swap(a, b);
        addEdge(a, b);
        emap.insert(a*(maxn-5)+b);
    }
    Dijskra(s, 0); Dijskra(t, 1);

    int ans=0;
    for (int a=1; a<=n; a++)
        for (int b=a+1; b<=n; b++){
            if (emap.count(a*(maxn-5)+b)) continue;
            if (dist[0][a]+dist[1][b]+1>=dist[0][t] && dist[1][a]+dist[0][b]+1>=dist[0][t])
                ans++;
        }
    printf("%d\n", ans);

    return 0;
}
```