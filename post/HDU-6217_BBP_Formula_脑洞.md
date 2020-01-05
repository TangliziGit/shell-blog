题目链接：<https://cn.vjudge.net/problem/HDU-6217>

### 题意
已知：
$$ \pi = \sum_{k=0}^{\infty }\frac{1}{16^{k}}(\frac{4}{8k+1}-\frac{2}{8k+4}-\frac{1}{8k+5}-\frac{1}{8k+6}) $$
求pi的16进制下小数点后第n位是多少。
n<=1e5

### 思路
要算pi的第n位，首先把pi向前移n位，则个位上就是要求的数。
但是我们很快发现难以计算这个个位数（乘法逆元可能不存在，精度也有问题）。
然而通过脑洞，我们可以去算第一位小数，然后乘以16取个位即可。

### 提交过程
|||
:-|:-
AC|可惜场上没想出来

### 代码
```cpp
#include <cstdio>
#include <cstring>
double powmod(int idx, int mod){
    long long tmp=16, res=1;
    for (int i=0; (1<<i)<=idx; i++){
        if (idx&(1<<i)) res=(res*tmp)%mod;
        tmp=(tmp*tmp)%mod;
    }
    return res/(double)mod;
}

int solve(int n){
    double res=0;
    n--;
    for (int i=0; i<=n; i++){
        res+=4*powmod(n-i, 8*i+1)-2*powmod(n-i, 8*i+4)
            -powmod(n-i, 8*i+5)-powmod(n-i, 8*i+6);
        if (res<0) res+=1;
    }
    res*=16;
    return ((int)res)%16;
}

int main(void){
    int T, n, kase=0;
    char hex[20]="0123456789ABCDEF";

    scanf("%d", &T);
    while (T--){
        scanf("%d", &n);
        printf("Case #%d: %d %c\n", ++kase, n, hex[solve(n)]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
4180ms|1204kB|725|G++|2018-08-30 18:47:46