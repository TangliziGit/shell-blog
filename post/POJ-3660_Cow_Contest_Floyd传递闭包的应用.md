题目链接：<https://cn.vjudge.net/problem/POJ-3660>

### 题意
有n头牛，每头牛都有一定的能力值，能力值高的牛一定可以打败能力值低的牛
现给出几头牛的能力值相对高低
问在一场一对一的比赛中，那些牛的排名可以确定下来

### 思路
一开始还以为是topo排序，每次去掉没有入度或出度的节点
若有两个及以上的节点可以去掉，则排序结束
然后写出来WA两发...
正确思路：
若满足x头牛可以打败牛a，牛a可以打败y头牛，且n==x+y-1时牛a排名唯一确定
那么可以利用Floyd传递闭包来生成一个数组G[a][b]，表示a可以打败b
当$ \sum  G[i][a]+G[a][i]==n-1$时，可以确定牛a排名

### 代码
```cpp
#include <cstring>
#include <cstdio>
const int maxn=100;
bool G[maxn+5][maxn+5]={false};

void Floyd(int n){
    for (int k=1; k<=n; k++)
        for (int i=1; i<=n; i++)
            for (int j=1; j<=n; j++)
                G[i][j]=G[i][j] || (G[i][k] && G[k][j]);
}

int main(void){
    int n, m, a, b;

    memset(G, false, sizeof(G));
    scanf("%d%d", &n, &m);
    for (int i=0; i<m; i++){
        scanf("%d%d", &a, &b);
        G[a][b]=true;
    }Floyd(n);

    int ans=0;
    for (int i=1; i<=n; i++){
        int cnt=0;
        for (int j=0; j<=n; j++) if (i!=j && (G[i][j] || G[j][i]))
            cnt++;
        if (cnt==n-1) ans++;
    }printf("%d\n", ans);

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
32ms|364kB|685|G++|2018-05-25 15:05:57