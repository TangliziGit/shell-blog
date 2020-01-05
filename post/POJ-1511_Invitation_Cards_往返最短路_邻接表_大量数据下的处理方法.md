题目链接：<https://cn.vjudge.net/problem/POJ-1511>

### 题意
给出一个图
求从节点1到任意节点的往返路程和

### 思路
没有考虑稀疏图，上手给了一个Dijsktra（按紫书上的存边方法）
直接超时

写了一个极限大小数据
发现读入时间很长，Dij时间也很长，相当于超时超到姥姥家了
赶紧做优化
- 发现稀疏图，于是换Bellman(spfa)
- 换邻接表
- (虽然没有必要)scanf换成getchar输入模版，大量数据可以节省大概800ms的样子

1. 稀疏图适用Bellman(optimed)，稠密图适用Dijsktra
2. 对大数据(maxn>1e6)，一定要用邻接表
3. 对大数据(x>1e9, maxm>1e6)，用输入模版可以降大概800ms

### 代码
```cpp
#include <queue>
#include <cstdio>
#include <vector>
#include <cstring>
using namespace std;
const int maxn=1e6, maxm=maxn;
const long long INF=1LL<<60;
struct Edge{
    int to, dis, next;
}edges[maxm+5], redges[maxn+5];
int size, rsize, head[maxn+5], rhead[maxn+5];

inline void addEdge(int from, int to, int dis){
    edges[size]=Edge{to, dis, head[from]};
    head[from]=size++;
    redges[rsize]=Edge{from, dis, rhead[to]};
    rhead[to]=rsize++;
}

long long dist[maxn+5];
long long Bellman(int n, int ahead[], Edge *aedges){
    int cnt[maxn+5]={0};
    bool inq[maxn+5]={false};
    queue<int> que;
    
    for (int i=0; i<=n; i++) dist[i]=INF; dist[1]=0;
    que.push(1);
    while (que.size()){
        int from=que.front(); que.pop();
        inq[from]=false;

        for (int i=ahead[from]; i!=-1; i=aedges[i].next){
            Edge &e=aedges[i];
            int &to=e.to, &dis=e.dis;

            if (dist[to]<=dist[from]+dis) continue;
            dist[to]=dist[from]+dis;
            if (inq[to]) continue;
            inq[to]=true;

            que.push(to);
            // if (++cnt[to]>n) return -1;
        }
    }
    
    long long sum=0;
    for (int i=1; i<=n; i++) if (dist[i]<INF)
        sum+=dist[i];
    return sum;
}

void init(void){
    memset(head, -1, sizeof(head));
    memset(rhead, -1, sizeof(rhead));
    rsize=size=0;
}

inline void read(int &num){
    char in;
    in=getchar();
    while(in <'0'|| in > '9') in=getchar();
    num = in -'0';
    while(in =getchar(),in >='0'&&in <='9')
        num *=10, num+=in-'0';
}

int main(void){
    int T, n, m, from, to, dis;

    scanf("%d", &T);
    while (T--){
        init();
        scanf("%d%d", &n, &m);
        for (int i=0; i<m; i++){
            read(from); read(to); read(dis);
            addEdge(from, to, dis);
        }printf("%lld\n", Bellman(n, head, edges)+Bellman(n, rhead, redges));
    }
    
    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
860ms|40672kB|1914|G++|2018-05-26 19:26:39