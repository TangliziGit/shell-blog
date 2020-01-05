题目链接：<https://cn.vjudge.net/problem/UVALive-8077>

### 题意
有一个用砖头磊起来的墙，现在又有一只蚂蚁，想沿着砖缝从起点跑到终点。
问最短路长度。

### 思路
找规律题，感觉这种题目应该是这样：
1. 一开始大量找规律
2. 对于很多种情况建议用转化的方式抽象出来一种情景
3. 如果抽象不出来（情景变得复杂），赶紧就不要抽象了
4. 如果可行最好打印一些数据，对着检查一下  
  

此题我们明显发现一共就只有两种情景（我们把起点放在上方，不影响题意）：
起点正下方有一条缝，和没有一条缝。
对着图画每个点的距离即可，发现是个金字塔结构，金字塔内部是奇偶关系，外部是正常的哈密顿距离。
就只有两个情景，就不要再抽象了，赶紧A掉为妙。

### 提交过程
|||
:-|:-
WA|情景抽象失败
AC|抽象毛线，直接写就完事

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
int sx, sy, ex, ey;

int solve(void){
    if (sy>ey){
        swap(sy, ey);
        swap(sx, ex);
    }

    int delta=abs(sy-ey), ans=0;
    if (sy%2==sx%2){
        if (ex<=sx+delta-1 && ex>=sx-delta+1){
            if (abs(sx+delta-1-ex)%2) ans+=2*delta;
            else ans+=2*delta-1;
        }else ans+=abs(sy-ey)+abs(sx-ex);
    }else{
        if (ex<=sx+delta-1 && ex>=sx-delta+1){
            if (abs(sx+delta-1-ex)%2==0) ans+=2*delta+1;
            else ans+=2*delta;
        }else ans+=abs(sy-ey)+abs(sx-ex);
    }
    return ans;
}

int main(void){
    while (scanf("%d%d%d%d", &sy, &sx, &ey, &ex)==4 && sx){
        // int n=6;
        // for (int i=1; i<=n; i++)
        //     for (int j=1; j<=n; j++){
        //         sx=2, sy=1;
        //         ex=j, ey=i;
        //         printf("x%d y%d %d\n", ex, ey, solve());
        //     }
        printf("%d\n", solve());
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|None|993|C++ 5.3.0|2018-08-24 10:46:40