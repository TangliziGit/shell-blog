用于求**正权有向图** 上的 **单源最短路**
优化后时间复杂度O(mlogn)

### 模板
```cpp
// Dijkstra
// to get the minumum distance with no negtive ways
//
// Description:
// 1. get vertex with minumum distance
// 2. do relax
//
// Details:
// 1. use priority_queue and pair<dis, verIdx>
// 2. use dis[verIdx] as minumum marks (pair.dis=dis[pair.verIdx]?)
// 3. initialize edge, G, dis and que

typedef pair<int, int> Node;                    // dist, VerIdx
const int maxn=205, maxm=maxn*maxn, INF=0x3f3f3f3f;
struct Edge{
    int from, to, dist;
    Edge(int from=0, int to=0, int dist=0):
        from(from),to(to),dist(dist) {}
};
vector<Edge> edge;
vector<int> G[maxn+5];
void AddEdge(int from, int to, int val){
    edge.push_back(Edge(i, j, val);
    G[i].push_back(edge.size()-1);
    edge.push_back(Edge(j, i, val));
    G[j].push_back(edge.size()-1);
}

int Dijkstra(int st, int tar){
    memset(dist, INF, sizeof(dist));
    priority_queue<Node, vector<Node>, greater<Node> > que;
    que.push(Node(0, st));
    memset(dist, -1, sizeof(dist)); dist[st]=0;
    while (que.size()){
        Node x=que.top(); que.pop();
        if (x.first!=dist[x.second]) continue;
        // vertax minized

        int &from=x.second;
        for (int i=0; i<G[from].size(); i++){
            Edge &e=edge[G[from][i]];
            int &to=e.to;
            if (dist[to]<=dist[from]+e.dis) continue;
            dist[to]=dis+e.dis;
            que.push(Node(dist[to], to));
        }
    }return dist[tar];
}
```

### 注意
1. 需要初始化dist为INF；edge, G为空
2. 注意优先队列的优先大小，用greater<Node> 使dist小的作为队头
3. 考虑dist[k]==INF，为不存在路径

### 例题
二进制状态，隐式图搜索
UVA-658 It's not a Bug, it's a Feature!

模板题
POJ-1502 MPI Maelstrom