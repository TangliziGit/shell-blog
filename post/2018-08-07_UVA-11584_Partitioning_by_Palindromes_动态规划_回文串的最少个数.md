题目链接：<https://cn.vjudge.net/problem/UVA-11584>

### 题意
给一个字符串序列，问回文串的最少个数。
例：aaadbccb
分为aaa, d, bccb三份
n<=1000

### 思路
这道题还是简单的，首先可以设想dp(i)为前i个字符中最少个数。
那么转移方程随之而来，dp(i)=min( dp(j-1)+1 | [j, i]是回文串 )。
这里分析复杂度是O(n^3)，但是咱可以预处理[j, i]是不是回文串，复杂度降到O(n^2)。

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1000+20, INF=0x3f3f3f3f;
char str[maxn];
bool isloop[maxn][maxn];
int dp[maxn];

int main(void){
    int T;

    scanf("%d", &T);
    while (T--){
        scanf("%s", str);

        int n=strlen(str);
        memset(isloop, false, sizeof(isloop));
        for (int i=0; i<n; i++){
            isloop[i][i]=true;
            for (int j=1; i-j>=0 && i+j<n; j++)
                if (str[i-j]==str[i+j])
                    isloop[i-j][i+j]=true;
                else break;

            if (i<n-1) for (int j=0; i-j>=0 && i+1+j<n; j++){
                if (str[i-j]==str[i+j+1])
                    isloop[i-j][i+j+1]=true;
                else break;
            }
        }

        dp[0]=1;
        for (int i=1; i<n; i++){
            dp[i]=INF;
            for (int j=i; j>=0; j--)
                if (isloop[j][i]){
                    if (j-1>=0) dp[i]=min(dp[i], dp[j-1]+1);
                    else dp[i]=1;
                }
        }printf("%d\n", dp[n-1]);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
20ms|None|1084|C++ 5.3.0|2018-08-06 05:41:42