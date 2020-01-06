题目链接：<https://cn.vjudge.net/problem/POJ-2096>

### 题意
某软件可以一天找到一个bug，每个bug有两个属性，分别是属于n个子系统和属于s类bug。
每个被找出的bug有1/s,1/n的可能属于某个子系统，或属于某个类。
问找全所有bug的期望天数。

### 思路
可能是写的第一道概率dp
```cpp
// dp[i][j]表示找全i种子系统，j种类的bug，距找全还有几天
dp[i][j]=(i/n)(j/s)(dp[i][j]+1)
    +(1-i/n)(j/s)(dp[i+1][j]+1)
    +(i/n)(1-j/s)(dp[i][j+1]+1)
    +(1-i/n)(1-j/s)(dp[i+1][j+1]+1);
```
注意data[i][j]是ij状态距ns的天数期望，所以有：
data[i][j+1]+1指i(j+1)距ns的天数期望，再加上其他一天的操作
p(data[i][j+1]+1)指该ij状态的一部分是由i(j+1)转移而来

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=1000+25;
double data[maxn][maxn];
int n, s;
double dp(int i, int j){
    if (i==n && j==s) return 0;
    if (i>n || j>s) return 0;
    if (data[i][j]>0) return data[i][j];

    data[i][j]=i*j;
    data[i][j]+=i*(s-j)*(dp(i, j+1)+1);
    data[i][j]+=(n-i)*j*(dp(i+1, j)+1);
    data[i][j]+=(n-i)*(s-j)*(dp(i+1, j+1)+1);
    data[i][j]/=n*s-i*j;
    return data[i][j];
}

int main(void){
    while (scanf("%d%d", &n, &s)==2){
        for (int i=0; i<=n; i++)
            for (int j=0; j<=s; j++) data[i][j]=-1;

        printf("%.4f\n", dp(0, 0));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
563ms|8244kB|621|C++|2018-08-16 01:55:59