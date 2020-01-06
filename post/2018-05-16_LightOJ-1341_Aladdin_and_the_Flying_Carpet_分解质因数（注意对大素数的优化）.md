题目链接：<https://cn.vjudge.net/problem/LightOJ-1341>

### 题意
给出一个长方形的面积a
让你算整数边长的可能取值，并且两个边都大于给定数字b

### 思路
唯一分解定理：$ n=\prod p_i^{a_i} $
首先考虑分解质因数的复杂度$ O(\sum a_i) $，不会算-_-

然后尝试用试除法做这个
简单算了下复杂度，大概一共4×10^9个循环
最后也就试一试，不出意料超时

然后试图用筛法降低复杂度，等到交了才发现常数降了、复杂度是没降-_-

最后的最后还是用了分解质因数，这里必须注意一个优化，能大幅降低时空复杂度
考虑到一个小于10^12的数，最多有一个超过10^6的质因数（若存在两个，必然超过10^12限制）
所以分解质因数的时候，质数可以仅生成到10^6
那么分解结束时若n!=1，可以判断n必然是大质数（超过10^6）

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=1e6+200;
int primes[maxn+5], psize;
bool isprime[maxn+5];

void initPrime(void){
    memset(isprime, true, sizeof(isprime));
    for (int i=2; i<maxn; i++) if (isprime[i]){
        for (int j=i; j<=maxn; j+=i)
            isprime[j]=false;
        primes[psize++]=i;
    }
}

long long solve(long long n){
    long long sum=1;
    for (int i=0; primes[i]<=n && i<psize; i++) if (n%primes[i]==0){
        long long asum=1;
        while (n%primes[i]==0) n/=primes[i], asum++;
        sum*=asum;
    }return sum+((n>1)?sum:0);
}

int main(void){
    initPrime();
    int T;
    long long n, m;

    scanf("%d", &T);
    for (int tcnt=1; tcnt<=T; tcnt++){
        scanf("%lld%lld", &n, &m);

        if (m*m>=n){
            printf("Case %d: 0\n", tcnt);
            continue;
        }

        long long ans=solve(n)/2;
        for (int i=1; i<m; i++)
            if (n%i==0) ans--;
        printf("Case %d: %lld\n", tcnt, ans);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
2300ms|5972kB|1059|C++|2018-05-15 23:28:44