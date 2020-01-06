题目链接：<https://cn.vjudge.net/problem/HDU-3555>

### 题意
问1~n里包含49的数字有几个。

### 思路
其实是问不包含49的数字有几个，这样比较好写一点。

### 提交过程
|||
:-|:-
WA|注意long long数据范围
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=10000+20;
long long data[maxn][2];
char num[maxn];

long long dp(int pos, int pre, bool lim){
    if (pos==-1) return 1;
    if (!lim && data[pos][pre==4]>0)
        return data[pos][pre==4];

    long long ans=0;
    int up=lim?(num[pos]-'0'):9;
    for (int i=0; i<=up; i++){
        if (pre==4 && i==9) continue;// ans+=pow10[pos];
        ans+=dp(pos-1, i, lim && i==up);
    }
    
    if (!lim) data[pos][pre==4]=ans;
    return ans;
}

long long solve(long long n){
    sprintf(num, "%lld", n);
    int len=strlen(num);
    reverse(num, num+len);
    return n-dp(len-1, -1, true)+1;
}

int main(void){
    long long n, m, ans[2], T;
    memset(data, -1, sizeof(data));

    scanf("%d", &T);
    while (T--){
        scanf("%lld", &n);
        printf("%lld\n", solve(n));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
15ms|1376kB|895|G++|2018-08-15 08:46:51