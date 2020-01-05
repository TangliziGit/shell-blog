题目链接：<https://cn.vjudge.net/problem/HYSBZ-1040>

### 题意
　　Z国的骑士团是一个很有势力的组织，帮会中汇聚了来自各地的精英。
他们劫富济贫，惩恶扬善，受到社会各界的赞扬。
最近发生了一件可怕的事情，邪恶的Y国发动了一场针对Z国的侵略战争。
战火绵延五里，在和平环境中安逸了数百年的Z国又怎能抵挡的住Y国的军队。
于是人们把所有的希望都寄托在了骑士团的身上，就像期待有一个真龙天子的降生，带领正义打败邪恶。
骑士团是肯定具有打败邪恶势力的能力的，但是骑士们互相之间往往有一些矛盾。
每个骑士都有且仅有一个自己最厌恶的骑士（当然不是他自己），他是绝对不会与自己最厌恶的人一同出征的。
战火绵延，人民生灵涂炭，组织起一个骑士军团加入战斗刻不容缓！
国王交给了你一个艰巨的任务，从所有的骑士中选出一个骑士军团，使得军团内没有矛盾的两人（不存在一个骑士与他最痛恨的人一同被选入骑士军团的情况），并且，使得这支骑士军团最具有战斗力。
为了描述战斗力，我们将骑士按照1至N编号，给每名骑士一个战斗力的估计，一个军团的战斗力为所有骑士的战斗力总和。

### 思路
注意到这是颗基环树，如果只是一颗树的话这明显是树上的最大独立集。
但是咱可以取掉基环树的圈的一个边，这样就是一棵树，再求端点取值不同或不取的最大独立集即可。

但是现实总是要给你带来一些坑和打击，题中并没有将这是一颗基环树，意思是让你判断连通性。
对每个联通块求一次答案，求和即可。
强烈注意：
1. 判断联通的写法，讨论是否图中全是基环树
2. 联通图搜索节点不能强行停止，必须自然停止
4. 注意判断是否同一条边（有可能还需判断是否有重边）
5. 初始化前向星
4. 有向图edges双倍大小
3. 树上dfs&dp判断父节点fa
2. ans+=max(data[st][0], data[end][0])

### 提交过程
|||
:-|:-
WA*n|各种问题，发现细节可弱
WA|注意判断删去的边
RE|注意无向图中edges数组大小双倍
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e6+20;
struct Edge{
    int to, next;
    Edge(int to=0, int next=-1):to(to), next(next) {}
}edges[maxn*2];
int head[maxn], size, n;
long long val[maxn], data[maxn][2];
bool vis[maxn];

void init(void){
    memset(head, -1, sizeof(head));
    size=0;
}

void addEdge(int from, int to){
    edges[size]=Edge(to, head[from]);
    head[from]=size++;
}

bool isedge(int u, int v){
    u-=u%2; v-=v%2;
    return u==v;
}

int st, end, delEdge;
void dfs(int u, int fa){
    vis[u]=true;

    for (int i=head[u]; i!=-1; i=edges[i].next)
        if (edges[i].to!=fa){
            int &to=edges[i].to;
            if (!vis[to]) dfs(to, u);
            else {
                st=u; end=to;
                delEdge=i;
                // return; ?????
            }
        }
}

bool flg=false;
long long dp(int u, int fa){
    // printf("%d %d--\n", u, fa);
    data[u][0]=0;
    data[u][1]=val[u];

    for (int i=head[u]; i!=-1; i=edges[i].next)
        // if (!isedge(i, e) && !isedge(i, delEdge)){
        if (!isedge(i, delEdge) && edges[i].to!=fa){
            int &to=edges[i].to;
            dp(to, u);
            data[u][0]+=max(data[to][0], data[to][1]);
            data[u][1]+=data[to][0];
        }
    return data[u][0];
}

int main(void){
    while (scanf("%d", &n)==1 && n){
        init();
        for (int i=1, ptr; i<=n; i++){
            scanf("%lld%d", &val[i], &ptr);
            addEdge(i, ptr);
            addEdge(ptr, i);
        }

        memset(vis, false, sizeof(vis));
        long long ans=0;
        for (int i=1; i<=n; i++) if (!vis[i]){
            st=end=0;
            dfs(i, -1);
            // ans+=max(dp(st, -1), dp(end, -1));
            if (st) ans+=max(dp(st, -1), dp(end, -1));
            else ans+=max(dp(i, -1), data[i][1]);
        }
        printf("%lld\n", ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
2096ms|44900kB|1922|C++|2018-08-14 07:07:29