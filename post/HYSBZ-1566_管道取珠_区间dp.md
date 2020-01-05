题目链接：<https://cn.vjudge.net/problem/HYSBZ-1566>

### 题意
![](https://odzkskevi.qnssl.com/f9c3fad4a0ac0de196585ae3634308c9?v=1533953656)
![](https://odzkskevi.qnssl.com/f936c1ccebcdd95a3ffbb815a8a94e46?v=1533953656)

### 思路
已经说了，面对\sum a^2的时候把状态分两个，
当这两个状态相同时，满足题意的方案数即变为a^2

### 提交过程
|||
:-|:-
WA|不知道为啥正着做dp总是WA
AC|

### 代码
```cpp
#include <cstdio>
#include <string>
#include <cstring>
#include <iostream>
#include <algorithm>
using namespace std;
const int maxn=500+5;
const int mod=1024523;
int dp[2][maxn][maxn];
int n, m;
char strn[maxn], strm[maxn];

int main(void){
    while (scanf("%d%d", &n, &m)==2){
        scanf("%s%s", strn+1, strm+1);
        // string strn, strm;
        // cin >> strn >> strm;
        // strn.push_back('X');
        // strm.push_back('X');
        // reverse(strn.begin(), strn.end());
        // reverse(strm.begin(), strm.end());

        dp[0][0][0]=1;
        int idx=0;
        for (int i=0; i<=n; i++, idx=1-idx)
            for (int j=0; j<=m; j++)
                for (int k=0; k<=n; k++){
                    int &d=dp[idx][j][k], l=i+j-k;

                    if (d==0 || l<0 || l>m) continue;
                    if (strn[i+1]==strn[k+1]) dp[1-idx][j][k+1]=(d+dp[1-idx][j][k+1])%mod;
                    if (strn[i+1]==strm[l+1]) dp[1-idx][j][k]=(d+dp[1-idx][j][k])%mod;
                    if (strm[j+1]==strn[k+1]) dp[idx][j+1][k+1]=(d+dp[idx][j+1][k+1])%mod;
                    if (strm[j+1]==strm[l+1]) dp[idx][j+1][k]=(d+dp[idx][j+1][k])%mod;
                    d=0;
                }
        printf("%d\n", (dp[idx][m][n]+mod)%mod);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1076ms|3280kB|1279|C++|2018-08-14 01:53:46