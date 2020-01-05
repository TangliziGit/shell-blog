题目链接：<https://cn.vjudge.net/problem/UVA-10200>

### 题意
给出一个公式$ m=n^2+n+41, n \in Z^+ $
现在$ a,b\in[0, 10000] $的范围内取n
问有几个m是素数

### 思路
不说了
关键是注意**除法精度问题**
当出现不得不使用除法时，一定要在除法的结果上加1e6，保证精度

### 代码
```cpp
#include <cstdio>
#include <cmath>
const double eps=1e-6;
int sum[int(1e4)+15];
bool isprime(const long long &i){
    long long n=i*i+i+41, size=sqrt(n)+1;
    for (int mod=2; mod!=n && mod<=size; mod++)
        if (n%mod==0) return false;
    return true;
}

void init(void){
    sum[0]=1;
    for (int i=0; i<=int(1e4); i++)
        if (isprime(i)) sum[i+1]=sum[i]+1;
        else sum[i+1]=sum[i];
}

int main(void){
    int a, b;
    init();

    while (scanf("%d%d", &a, &b)==2)
        printf("%.2f\n", 100*(sum[b+1]-sum[a])/(double)(b-a+1)+eps);

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
210ms|None|569|C++|2018-05-13 23:20:13