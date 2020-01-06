题目链接：<https://cn.vjudge.net/problem/UVA-10054>

### 题意
给一堆两头有颜色的珠子，颜色可相同可不同
现要把它们全部串成项链
问能否全部连起来，使相邻珠子的相邻端颜色相同
若不可行，输出不可行
若可行，输出珠子的排列

### 思路
紫书的例题，一开始觉得是一个搜索
后来看书上讲是一个欧拉回路

把珠子颜色看成节点，颜色之间作为边，可化为一个欧拉回路问题
关键就是欧拉回路的判定和输出了
判定：
1. 图是否连通
2. 出度等于入度（起点出度等于入度+1，起点入度等于出度+1）
  
输出：
其实是输出一个包含所有节点的最大环
很容易想到dfs搜全部节点，但是注意可能出现较小环，所以状态很大，需要特殊地输出
欧拉回路的输出要点有两个
1. 递归逆序输出，即最后输出的一行的最后一个编号是当前编号（还是看代码比较好理解）
2. 递归中的找边循环，需要按节点由小到大找
原因是上一次的输出编号是最小编号，本次输出的最深处也应为最小编号（还是看代码说话吧）

注意：
1. 以后写欧拉回路直接写邻接矩阵
2. 图论必然要初始化啊，不要再忘了啊

### 代码
```cpp
#include <cstdio>
#include <vector>
#include <cstring>
#include <algorithm>
using namespace std;
int m, n, dist[maxn+5];
int G[maxn+5][maxn+5];
void dfs(int from){
    for (int to=1; to<=n; to++){
        if (G[from][to]==0) continue;
        G[from][to]--; G[to][from]--;
        dfs(to);
        printf("%d %d\n", to, from);
    }
}

int main(void){
    int kase;

    scanf("%d", &kase);
    for (int k=1; k<=kase; k++){
        int vis[maxn+5]={0}; n=0;
        memset(G, 0, sizeof(G));
        scanf("%d", &m);
        for (int i=0, a, b; i<m; i++){
            scanf("%d%d", &a, &b);
            vis[a]++; vis[b]++;
            G[a][b]++; G[b][a]++;
            n=max(n, max(a, b));
        }

        bool flag=false;
        for (int i=1; i<=n; i++)
            if (vis[i]%2){flag=true; break;}
        printf("Case #%d\n", k);
        if (flag) printf("some beads may be lost\n\n");
        else {
            // check connectivity, but i didn't since these graphs are connective
            // attend to the way to print:
            // 1. if use adjacency list, please sort each edge of vertices
            // 2. each path printed ends with a minimum vertax,
            //      and the next path will print a bigger minimum as first vertax.
            //      so that we can get the whole connective path.
            for (int i=1; i<=n; i++) dfs(i);
            printf("\n");
        }
    }

    return 0;
}

```

Time|Length|Lang|Submitted
:-:|:-:|:-:|:-:
160ms|2726|C++ 5.3.0|2018-03-14 12:06:28