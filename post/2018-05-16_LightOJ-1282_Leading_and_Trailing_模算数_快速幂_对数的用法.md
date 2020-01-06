题目链接：<https://cn.vjudge.net/problem/LightOJ-1282>

### 题意
给出两个正整数n(2 ≤ n < 231), k(1 ≤ k ≤ 1e7)
计算n^k的前三位，末三位

### 思路
首先末三位很好算，这里就只需模算数+快速幂

然后考虑前三位的算法，这里主要问题是数据溢出（pow(n, k)计算不可行）
那么考虑把n换成浮点数，同时除掉10^m，再去pow(n, k)
我们可以通过$ 1\leq (\frac{n}{10^m})^k \leq 1000 $大概估计范围
但是这里主要有个问题，就是在n很小而k很大时m不好取，计算结果很可能是inf或者0

换一个方法，我们设 $ a\in Z, b\in R, b<1 $
那么必然有 $ n^k==10^{a+b} $ ，其中10^a是一个控制位数的因子，而10^b才是数字的主要信息
数字的前三位可以表示为 $ \lfloor 10^{b+2} \rfloor $ 
注意不要总以为出现精度问题手贱加个eps！

### 代码
写了两种快速幂，一种递归一种循环，原理都一样
```cpp
#include <cstdio>
#include <cmath>
const double eps=1e-6;
int getPre(int n, int k){
// attention eps shouldn't appear!
    double idx=(k*log10(n))-(int)(k*log10(n));//+2+eps;
    return pow(10, idx)*100;
}

int getPost(int n, int k){
    int num=n%1000, ans=1;
    for (int i=0; 1<<i <=k; i++){
        if (k & 1<<i) ans=(ans*(num%1000))%1000;
        num=((long long)num*num)%1000;
    }return ans;
}

int quikPow(int n, int k){
    if (k==0) return 1;
    if (k==1) return n%1000;

    long long tmp=quikPow(n, k/2);
    tmp=(tmp*tmp)%1000;
    if (k%2) tmp=(tmp*n)%1000;
    return tmp;
}

int main(void){
    int T, n, k;

    scanf("%d", &T);
    for (int cnt=1; cnt<=T; cnt++){
        scanf("%d %d", &n, &k);
        int pre=getPre(n, k), post=getPost(n, k);
        printf("Case %d: %03d %03d\n", cnt, pre, post);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|1328kB|844|C++|2018-05-16 08:09:54