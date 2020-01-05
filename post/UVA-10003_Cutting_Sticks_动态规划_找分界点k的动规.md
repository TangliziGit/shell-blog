题目链接：<https://cn.vjudge.net/problem/UVA-10003>

### 题意
有根棍子，上面有些分割点(n<50)，每次按分割点切割棍子时，费用为当前棍子的长度。
问有什么样的顺序，使总费用最小。

### 思路
简单题，设dp[i][j]为在分割点ij之间棍子的最小切割费用。
有转移方程dp[i][j]=min( dp[i][k]+dp[k][j] )+pos[j]-pos[i]
注意边界条件dp[i][i+1]=0意思是i~i+1之间不需要切割费用。

### 提交过程
|||
:-|:-
WA|边界条件给错
WA|输出错
AC|


### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=50+20, INF=0x3f3f3f3f;
int n, l;
int pos[maxn], data[maxn][maxn];
int dp(int l, int r){
    if (r<=l+1) return 0;
    if (data[l][r]) return data[l][r];

    data[l][r]=INF;
    for (int k=l+1; k<r; k++)
        data[l][r]=min(data[l][r], dp(l, k)+dp(k, r));
    return data[l][r]+=pos[r]-pos[l];
}

int main(void){
    while (scanf("%d", &l)==1 && l){
        memset(data, 0, sizeof(data));
        scanf("%d", &n);
        pos[0]=0; pos[n+1]=l;
        for (int i=1; i<=n; i++)
            scanf("%d", &pos[i]);
        printf("The minimum cutting is %d.\n", dp(0, n+1));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
150ms|691|C++ 5.3.0|2018-08-06 09:13:55