题目链接：<https://cn.vjudge.net/problem/HDU-1069>

### 题意
给出n种箱子的长宽高
现要搭出最高的箱子塔，使每个箱子的长宽严格小于底下的箱子的长宽，每种箱子数量不限
问最高可以搭出多高

### 思路
有向无环图（DAG）上的动规
想象有一个图，每个节点表示一种箱子，每个边代表可以落在一块的关系
递归的找max即可
$ dp(i)=max(dp(j)+h(i) | (i, j) \in E) $

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
struct Box{
    int x, y, z;
    Box(int x=0, int y=0, int z=0):
        x(x),y(y),z(z) {}
}box[200];
int n, data[200];
int dp(int idx){
    if (data[idx]!=-1) return data[idx];
    data[idx]=box[idx].z;
    for (int i=0; i<n; i++){
        if (i==idx || box[i].x>=box[idx].x || box[i].y>=box[idx].y) continue;
        data[idx]=max(data[idx], dp(i)+box[idx].z);
    }return data[idx];
}

int main(void){
    int cnt=0;
    while (scanf("%d", &n)==1 && n){
        memset(data, -1, sizeof(data));
        for (int i=0, x, y, z; i<n; i++){
            scanf("%d%d%d", &x, &y, &z);
            box[6*i+0]=Box(x, y, z); box[6*i+1]=Box(x, z, y);
            box[6*i+2]=Box(y, z, x); box[6*i+3]=Box(y, x, z);
            box[6*i+4]=Box(z, x, y); box[6*i+5]=Box(z, y, x);
        }n*=6;

        int max;
        for (int i=0; i<n; i++)
            if (max<dp(i) || i==0) max=dp(i);
        printf("Case %d: maximum height = %d\n", ++cnt, max);
    }

    return 0;
}

```

Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:
1512kB|1041|G++|2018-02-16 03:34:42