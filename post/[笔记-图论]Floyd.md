用于**可带负权**的**多源最短路**
时间复杂度O(n^3)
注意一定不要给Floyd一个带负环的图，不然就没有什么意义了（最短路不存在）

### 模板
```cpp
// Floyd
// to get minumum distance[a][b] from a to b, despite of negtive dis
//
// Description:
// use dp to get minimum dis
//
// Details:
// 1. initialize dis (dis[i][i]=0, else dis=INF)

#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=105, INF=0x3f3f3f3f;
int n, dist[maxn+5][maxn+5];
void Floyd(void){
    for (int i=1; i<=n; i++) dist[i][i]=0;
    for (int k=1; k<=n; k++)
        for (int i=1; i<=n; i++)
            for (int j=1; j<=n; j++)
                if (dist[i][k]<INF && dist[k][j]<INF)
                    dist[i][j]=min(dist[i][j], dist[i][k]+dist[k][j]);
}

```

### 注意
1. 若用于求最短路，需要把不存在的边权赋为INF
若用于有向图传递闭包(Transitive Closure)，把边权设为1，不存在的边设为0
2. 考虑dist[k]==INF，为不存在路径

### 例题
模板题
POJ-1502 MPI Maelstrom

有向图传递闭包
UVA-247 Calling Circles

求最小的A到B最大边权的路径
UVA-10048 Audiophobia