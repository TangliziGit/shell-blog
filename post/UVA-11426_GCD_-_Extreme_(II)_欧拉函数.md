题目链接：<https://cn.vjudge.net/problem/UVA-11426>

### 题意
求下式结果：
$$ G=\sum_{1 \leq i < j \leq n} gcd(i, j) $$

### 思路
设一函数 $ f(i)=\sum_1^i gcd(j, i) $，则其前缀和即为答案。
又考虑到 $ f(i)=\sum_{gcd(i, j)!=1} i*g(i, j) $，其中g(i, j)指满足gcd(i, x)==j的x的个数。
有考虑到 $ gcd(i, x)==j $等价与 $ gcd(i/j, x/j)==1 $ 即与i/j互质的数的个数，即phi(i/j)。
答案即为 $ ans[i]+=ans[i-1] + f(i)$， 为了降低复杂度，我们类似筛法来算f(i)。

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <ctime>
const int maxn=4e6+20;
long long phi[maxn], ans[maxn];
bool isprime[maxn];
void initPhi(void){
    memset(phi, 0, sizeof(phi));
    phi[1]=1;
    for (int i=2; i<maxn; i++) if (!phi[i])
        for (int j=i; j<maxn; j+=i){
            if (!phi[j]) phi[j]=j;
            phi[j]=phi[j]/i*(i-1);
        }
}

void initAns(void){
    for (int i=1; i<maxn; i++)
        for (int j=i+i; j<maxn; j+=i)
            ans[j]+=i*phi[j/i];

    for (int i=3; i<maxn; i++)
        ans[i]+=ans[i-1];
}

int main(void){
    int n;
    initPhi(); initAns();
    while (scanf("%d", &n)==1 && n)
        printf("%lld\n", ans[n]);

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
950ms|None|682|C++ 5.3.0|2018-09-10 21:34:53