用于求**可带负权**的**单源有向图**
优化后复杂度O(nm)

如果图中存在负环，就不存在最小路
这种情况下，就一定会有一个顶点被松弛多于n-1次，Bellman-Ford可直接判断出来

~~我在网上看到SPFA，发现就是优化后的Bellman-Ford算法，没什么特别的~~
常见有三种版本的BellmanFord：原版，队列优化Bellman，栈优化Bellman
看起来栈优化的Bellman比较快速？不存在负权下，直接用Dijskra即可
### 模板
```cpp
// Bellman-Ford
// to check negtive circle, if not exists return minumum distance
//
// Description:
// 1. do n-1 times relax for all edges (or check if dis[u]=dis[v]+dis[v, u])
//
// Details:
// 1. use queue to push and get the vertax
// 2. use cnt[verIdx] to count n-1 for each vertax
// 3. use inq[verIdx] to check if in queue(when process u, set inq[u] false)
// 4. despite of inq, do relax(but que.push)
// 5. initialize edge, G, dis and que

#include <algorithm>
#include <cstring>
#include <cstdio>
#include <queue>
using namespace std;
const int maxn=205, INF=0x3f3f3f3f;
struct Edge{
    int from, to, dis;
    Edge(int from=0, int to=0, int dist=0):
        from(from), to(to), dist(dist) {}
};
vector<Edge> edge;
vector<int> G[maxn+5];
int n;
void AddEdge(int from, int to, int val){
    edge.push_back(Edge(from, to, val));
    G[from].push_back(edge.size()-1);
    edge.push_back(Edge(to, from, val));
    G[to].push_back(edge.size()-1);
}

int BellmanFord(int st){
    int ans=0, cnt[maxn+5]={0}, dist[maxn+5];
    bool inq[VerMax]={0};
    memset(dist, INF, sizeof(dist));
    queue<int> que;
    que.push(st);
    inq[st]=true; dist[st]=0;
    while (que.size()){
        int from=que.front(); que.pop();
        inq[from]=false;
        for (int i=0; i<G[from].size(); i++){
            Edge &e=edge[G[from][i]]; int to=e.to;
            if (dis[to]<=dis[from]+e.dis) continue;
            dis[to]=dis[from]+e.dis;
            if (inq[to]) continue;
            que.push(to); inq[to]=true;
            // if (++cnt[to]>verSize) return -1;
            // why n+1? (this code from purple book P363)
            if (++cnt[to]>n-1) return -1;
        }
    }
    return ans;
}

```
### 注意
1. 需初始化dist为INF，inq为false，cnt为0；还有edge, G
2. 不要忘了inq, cnt数组
3. 考虑dist[k]==INF，为不存在路径

### 例题
二进制状态，隐式图搜索
UVA-658 It's not a Bug, it's a Feature!