题目链接：<https://cn.vjudge.net/problem/HDU-3652>

### 题意
问1~n里包含13并可被13整除的数字个数。

### 思路
数位dp了，注意维护模13的值mod。
注意mod同样是一个状态，其实这题提醒我**dp函数的参数里除了limit和lead以外基本都是状态**。
因为都被拿去传递了，不是状态就不需要这个参数了。

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
const int maxn=1000+20;
long long data[maxn][13][4];
// state: 0 for none, 1 for pre==1, 2 for include 13
char num[maxn];

long long dp(int pos, int state, bool lim, int mod){
    if (pos==-1) return state==2 && mod==0;
    if (!lim && data[pos][mod][state]>0)
        return data[pos][mod][state];

    long long ans=0;
    int up=lim?(num[pos]-'0'):9;
    for (int i=0; i<=up; i++){
        int next_state;
        if (state==0 && i==1) next_state=1;
        else if (state==0) next_state=0;
        else if (state==1 && i==3) next_state=2;
        else if (state==1 && i==1) next_state=1;
        else if (state==1) next_state=0;
        else if (state==2) next_state=2;

        ans+=dp(pos-1, next_state, lim && i==up, (mod*10+i)%13);
    }
    
    if (!lim) data[pos][mod][state]=ans;
    return ans;
}

long long solve(long long n){
    sprintf(num, "%lld", n);
    int len=strlen(num);
    reverse(num, num+len);
    return dp(len-1, 0, true, 0);
}

int main(void){
    long long n;
    memset(data, -1, sizeof(data));

    while (scanf("%lld", &n)==1 && n)
        printf("%lld\n", solve(n));

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
15ms|1628kB|1199|G++|2018-08-15 09:50:05