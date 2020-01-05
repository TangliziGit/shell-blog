题目链接：<https://cn.vjudge.net/problem/Gym-101615D>

### 题意
给一棵树，每个边权表示一种颜色。
现定义一条彩虹路是每个颜色不相邻的路。
一个好点是所有从该节点开始的所有简单路径（最短路）都是彩虹路。
问有哪几个好点？按编号输出。

### 思路
按节点遍历，若有多条路边权一样，则这几个子树都不是好点。
除去不好点，剩下即为好点。

一开始的思路是树上dp，然而情况实在太多，WA好几次。
最后看题解，发现有个dfs序的操作，把子树表示成数组里的一个范围，每次区间打标志即可（差分数组）。

### 提交过程
|||
:-|:-
WA×n|树形dp
AC|

### 代码
```cpp
#include <vector>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=5e4+20, maxm=maxn*2;
struct Edge{
    int to, nxt, val;
    Edge(int to=0, int nxt=0, int val=0):
        to(to), nxt(nxt), val(val) {}
}edges[maxm];
int head[maxn], esize;
int tim, st[maxn], siz[maxn], fa[maxn], dfn[maxn];
int n;
void init(void){
    memset(head, -1, sizeof(head));
    esize=0, tim=0;
}

void addEdge(int from, int to, int val){
    edges[esize]=Edge(to, head[from], val);
    head[from]=esize++;
}

void dfs(int u, int pre){
    dfn[tim]=u;
    st[u]=tim++; siz[u]=1; fa[u]=pre;
    #define TO edges[i].to
    for (int i=head[u]; i!=-1; i=edges[i].nxt)
        if (TO!=pre) dfs(TO, u), siz[u]+=siz[TO];
    #undef TO
}

int main(void){
    int a, b, val;
    while (scanf("%d", &n)==1){
        init();
        for (int i=0; i<n-1; i++){
            scanf("%d%d%d", &a, &b, &val);
            addEdge(a, b, val);
            addEdge(b, a, val);
        }

        dfs(1, -1);
        int diff[maxn]={0};
        for (int u=1; u<=n; u++){
            vector<pair<int, int> > e;
            for (int i=head[u]; i!=-1; i=edges[i].nxt)
                e.push_back(make_pair(edges[i].val, edges[i].to));
            sort(e.begin(), e.end());
        
            int ptr=0, sizes=e.size();
            while (ptr<sizes){
                int pre=e[ptr].first, tmp=ptr+1;
                while (tmp<sizes && pre==e[tmp].first) tmp++;
                if (tmp-1==ptr) {ptr++; continue;}
                if (pre!=e[tmp-1].first) break;

                for (; ptr<=tmp-1; ptr++){
                    int to=e[ptr].second;
                    // printf("%d: %d st%d siz%d\n", u, to, st[to], siz[to]);
                    if (to==fa[u]){
                        diff[st[1]]++;
                        diff[st[u]]--;
                        diff[st[u]+siz[u]]++;
                    }else{
                        diff[st[to]]++;
                        diff[st[to]+siz[to]]--;
                    }
                }
            }
        }

        for (int i=1; i<=n; i++)
            diff[i]+=diff[i-1];

        int ans[maxn], asize=0;
        for (int i=1; i<=n; i++)
            if (diff[st[i]]==0) ans[asize++]=i;
        // for (int i=1; i<=n; i++)
        //     printf("%d: %d siz%d\n", i, st[i], siz[i]);
        printf("%d\n", asize);
        for (int i=0; i<asize; i++)
            printf("%d\n", ans[i]);
    }
    
    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
62ms|4876kB|2466|GNU G++ 5.1.0|2018-08-30 20:57:26