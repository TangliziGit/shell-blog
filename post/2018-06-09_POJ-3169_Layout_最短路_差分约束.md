题目链接：<https://cn.vjudge.net/problem/POJ-3169>

### 题意
Farmer John手下的一些牛有自己喜欢的牛，和讨厌的牛
喜欢的牛之间希望距离在给定距离D之内
讨厌的牛之间希望距离在给定距离D之外
每个牛都有一个编号，编号较小的牛要在编号较大的牛之前（坐标可以重叠）

如果不存在这样的队伍，输出-1
如果一号和n号可以随意距离，输出-2
否则输出一号和n号最近距离

### 思路
首先满足 X_i<X_j
如果两个牛互相喜欢，则有
$ X_i<=X_j+D $ 满足最短路

如果两个牛互相讨厌，则有
$ X_i>=X_j+D $ 经过变形（刚看到的单词subsitution就是这个意思）
$ X_j<=X_i-D$  满足最短路
然后直接写就好

注意虽然满足编号小的在前，但不要去对dis数组做判断
因为有些节点就没有被更新（没有对应的边）
详情见注释

### 提交过程
|||
:-|:-
CE|**Edge没写构造函数**
TLE|模板写错了一个符号，导致Bellman没出来哈哈
WA1|对dis数组做了判断
AC1|去掉判断
WA2|怀疑是判断有问题，试了试
AC2|加了行注释

### 代码
```cpp
#include <stack>
#include <cstdio>
#include <cstring>
using namespace std;
const int maxn=1e3+20, maxm=2e6+20;
const long long INF=1LL<<60;
struct Edge{
    int to, dis, next;
    Edge(int to=0, int dis=0, int next=0):
        to(to), dis(dis), next(next) {}
}edges[maxm*2+5];
int head[maxn+5], size;

long long Bellman(int n){
    long long dist[maxn+5];
    int cnt[maxn+5]={0};
    bool inq[maxn+5]={false};
    stack<int> sta;// queue<int> que;

    for (int i=0; i<=n; i++) dist[i]=INF; dist[1]=0;
    inq[1]=true;
    sta.push(1);// que.push(1);
    while (sta.size()){
        int from=sta.top(); sta.pop();
        inq[from]=false;

        for (int i=head[from]; i!=-1; i=edges[i].next){
            Edge &e=edges[i];
            int &to=e.to, &dis=e.dis;

            if (dist[to]<=dist[from]+(long long)dis) continue;
            dist[to]=dist[from]+(long long)dis;

            if (inq[to]) continue;
            sta.push(to);

            if (++cnt[to]>=n) return -1;
        }
    }

    if (dist[n]==INF) return -2;
    // for (int i=2; i<=n; i++)    // does it work?
    //     if (dist[i]<dist[i-1]) return -1;
    //  
    //  Obviously not, we only need to find a way to the point n
    //  So there may be same points which value INF
    //  (But it surely values between dist[i-1] and dist[i+1])
    return dist[n];
}

void init(void){
    memset(head, -1, sizeof(head));
    size=0;
}

void addEdge(int from, int to, int dis){
    edges[size]=Edge(to, dis, head[from]);
    head[from]=size++;
}

int main(void){
    int n, ml, md;
    int from, to, dis;

    init();
    scanf("%d%d%d", &n, &ml, &md);
    for (int i=0; i<ml; i++){
        scanf("%d%d%d", &from, &to, &dis);
        if (from>to) swap(from, to);
        addEdge(from, to, dis);
    }
    for (int i=0; i<md; i++){
        scanf("%d%d%d", &from, &to, &dis);
        if (from<to) swap(from, to);
        addEdge(from, to, -dis);
    }
    printf("%lld\n", Bellman(n));

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
422ms|47188kB|1961|C++|2018-06-06 23:04:35