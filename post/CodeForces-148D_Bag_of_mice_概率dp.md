题目链接：<https://cn.vjudge.net/problem/CodeForces-148D>

### 题意
有一个公主和龙的故事，公主和龙玩游戏。
公主每次从装满黑白老鼠的袋子里拿一个老鼠；而龙每次拿一个老鼠，放跑一只。
先拿到白色老鼠的人（龙？）赢。
给出白色老鼠，黑色老鼠的个数，且公主先拿。
问公主获胜的概率。

### 思路
概率dp，设dp·[i][j]为剩下i只白鼠j只黑鼠的公主获胜概率。
则边界dp[0][0]=0
转移方程如下，就不太写思路了 : P
$$ 
\begin{align*}
dp(i,j) &= \frac{i}{i+j}\frac{i-1}{i+j-1}\frac{i-2}{i+j-2}dp(i-3, j)\\ 
 &+\frac{i}{i+j}\frac{i-1}{i+j-1}\frac{j}{i+j-2}dp(i-2, j-1) \\ 
 &+\frac{j}{i+j}
\end{align*}
$$

### 提交过程
|||
:-|:-
AC|1A呢，题简单了

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=1e3+20;
double data[maxn][maxn];
bool vis[maxn][maxn];
int nb, nw;
double dp(int i, int j){
    if (i==0 && j==0) return 0;
    if (i<0 || j<0) return 0;
    if (vis[i][j]) return data[i][j];

    vis[i][j]=true;
    double &d=data[i][j];
    if (i+j>=3){
        d=(i/(double)(i+j))*((i-1)/(double)(i+j-1))*((i-2)/(double)(i+j-2))*dp(i-3, j);
        d+=(i/(double)(i+j))*((i-1)/(double)(i+j-1))*(j/(double)(i+j-2))*dp(i-2, j-1);
        d+=j/(long double)(i+j);
    }else if (i+j==2){
        if (i==2) d=0;
        if (j==2) d=1;
        if (i==1) d=0.5;
    }else if (i+j==1){
        if (i==1) d=0;
        if (j==1) d=1;
    }
    return d;
}

int main(void){
    while (scanf("%d%d", &nw, &nb)==2){
        printf("%.9f\n", dp(nb, nw));
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
92ms|9004kB|819|GNU G++ 5.1.0|2018-08-31 15:45:32