题目链接：<https://cn.vjudge.net/problem/CodeForces-546D>

### 题意
抱歉，我给忘了，现在看题目又看不懂: P

### 思路
筛法+dp
话说这个函数应该是积性函数，然后就想到了动态规划优化筛法。

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxp=1e6, maxn=5e6+20;
int primes[maxn], psize;
long long ans[maxn], pre[maxn];
bool isprime[maxn];
void div(void){
    memset(isprime, true, sizeof(isprime));
    for (int i=0; i<maxn; i++)
        pre[i]=i;
    for (int i=2; i<maxn; i++){
        if (isprime[i]){
            ans[i]=1;
            for (int j=2; j*i<maxn; j++){
                isprime[j*i]=false;
                ans[j*i]++; pre[j*i]/=i;
            }
        }else ans[i]+=ans[pre[i]];
    }
    for (int i=1; i<maxn; i++)
        ans[i]+=ans[i-1];
}

int main(void){
    int t, a, b;

    div();
    scanf("%d", &t);
    while (t--){
        scanf("%d%d", &a, &b);
        printf("%lld\n", ans[a]-ans[b]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1247ms|102564kB|747|GNU G++ 5.1.0|2018-08-31 10:13:44