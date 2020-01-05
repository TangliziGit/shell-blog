题目链接：<https://cn.vjudge.net/problem/UVALive-8079>

### 题意
n个人组队，队伍人数小于等于n，每个队伍需要4个不同的职务的领导。
问这n个人可以组成多少队？
n<=1e7

### 思路
很明显，对一个i人队伍，可以组成$ \sum\binom{i}{1}^4\binom{n}{i} = \sum i^4\binom{n}{i} $种可能。
现在分析一下复杂度，对一个n来讲我们可以求逆元来求组合数，所以O(n)复杂度。
那么现在又有1000行的数据，总的复杂度远远超过了10s的时间。
又要优化了，这次看了半天没有优化思路，赛后有人讲把整个式子拆开即可，反正我是拆不开。
这次用用某同学的方法优化。
$$
\begin{align*}
 1+\sum_1^n \binom{n}{i}x^i&=(1+x)^n \\ 
 (1+\sum_1^n \binom{n}{i}x^i)'&=((1+x)^n)' \\ 
 \sum_1^n i\binom{n}{i}x^{i-1}&=n(1+x)^{n-1} \\ 
 \sum_1^n i\binom{n}{i}x^i&=n(1+x)^{n-1}x \\ 
 \sum_1^n i^2\binom{n}{i}x^i&=n(n-1)(1+x)^{n-2}x^2+n(1+x)^{n-1}x \\ 
 \sum_1^n i^3\binom{n}{i}x^i&=n(n-1)(n-2)(1+x)^{n-3}x^3+2n(n-1)(1+x)^{n-2}x^2+ n(n-1)(1+x)^{n-2}x^2+n(1+x)^{n-1}x \\ 
 \sum_1^n i^4\binom{n}{i}&=2^{n-4}(n^4+20n^3-55n^2+42n)
\end{align*}
$$
这个思路可以应对$ \sum f(i) \binom{n}{i} $形式的化简，其中f(i)是i的多项乘积。

### 提交过程
|||
:-|:-
TLE|
AC

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=1e7+20;
const int mod=1e8+7;
int pow2[maxn];
void init(void){
    pow2[0]=1;
    for (int i=1; i<maxn; i++)
        pow2[i]=(pow2[i-1]*2)%mod;
    // printf("done\n");
}

long long pow(long long x, int num){
    long long res=1;
    for (int i=0; i<num; i++) 
        res=(res*x)%mod;
    return res;
}

long long func(int n){
    if (n==1) return 1;
    if (n==2) return 18;
    if (n==3) return 132;
    return ((pow2[n-4]*(pow(n, 4) + 6*pow(n, 3) + 3*pow(n, 2) - 2*n )%mod)%mod+mod)%mod;
}

int main(void){
    long long n;

    init();
    while (scanf("%lld", &n)==1 && n)
        printf("%lld\n", func(n));

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
66ms|None|682|C++ 5.3.0|2018-08-24 23:14:22