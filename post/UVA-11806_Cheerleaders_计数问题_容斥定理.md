题目链接：<https://cn.vjudge.net/problem/UVA-11806>

### 题意
在一个mn的矩形网格里放k个石子，问有多少方法。
每个格子只能放一个石头，每个石头都要放，且第一行、最后一行、第一列和最后一列都有石子。

### 思路
设A为第一行格子、B为最后一行、C为第一列、D为最后一列。
很明显发现ABCD这个集合包含了重复元素，那么按照容斥定理可解。
注意：
1. 1000007 不是素数，不能递推算逆元，因为mod%i==0
2. 不要用乘法递推式算C，要用加法
3. 容斥的技巧，用cont计数总方案，_cont计数奇偶

### 提交过程
|||
:-|:-
WA×n|上面的注意注意一下
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=20+5, maxk=500+20;;
const long long mod=1000007; // is not a prime.
int n, m, k;
long long C[maxk][maxk];
void init(void){
    memset(C, 0, sizeof(C));
    C[0][0]=1;
    for (int i=1; i<maxk; i++){
        C[i][0]=C[i][i]=1;
        for (int j=1; j<i; j++)
            C[i][j]=(C[i-1][j-1]+C[i-1][j])%mod;
            // C[i][j]=(C[i][j-1]*(i-j+1)/j)%mod;
    }
}

int main(void){
    int T, kase=0;

    init();
    scanf("%d", &T);
    while (T--){
        scanf("%d%d%d", &n, &m, &k);

        long long ans=0;
        for (int cnt=0; cnt<16; cnt++){
            int _cnt=0, nn=n, mm=m;
            if (cnt&1) {nn--; _cnt++;}
            if (cnt&2) {nn--; _cnt++;}
            if (cnt&4) {mm--; _cnt++;}
            if (cnt&8) {mm--; _cnt++;}

            if (_cnt%2) ans=(ans+mod-C[nn*mm][k])%mod;
            else ans=(ans+C[nn*mm][k])%mod;
        }printf("Case %d: %lld\n", ++kase, ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|None|971|C++ 5.3.0|2018-09-05 17:33:47