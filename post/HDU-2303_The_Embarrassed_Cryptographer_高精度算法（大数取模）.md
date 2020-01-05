题目链接：<https://cn.vjudge.net/problem/HDU-2303>

### 题意
给一个大数K，和一个整数L，其中K是两个素数的乘积
问K的是否存在小于L的素数因子

### 思路
枚举素数，大数取模即可
注意大数取模代码，一开始没想到，看了别人的代码才感觉厉害

### 代码
```cpp
#include <cstring>
#include <cstdio>
const int MAX=int(1e6);
char a[100+5];
int b, psize=0, primes[MAX+5];
void init(void){
    int isprime[MAX+5];
    memset(isprime, -1, sizeof(isprime));
    for (int i=2; i<=MAX; i++){
        if (isprime[i]){
            primes[psize++]=i;
            for (int k=2*i; k<=MAX; k+=i)
                isprime[k]=0;
        }
    }
}

inline int mod(const int &idx, const int &length){
    int ans=0;
    for (int i=0; i<length; i++)
        ans=(ans*10+a[i]-'0')%primes[idx];
    return ans;
}

int main(void){
    init();
    while (scanf("%s%d", a, &b)==2 && b){
        int length=strlen(a), flag=0;
        for (int idx=0; idx<psize && primes[idx]<b; idx++)
            if (!mod(idx, length)) {
                printf("BAD %d\n", primes[idx]);
                flag=1; break;
            }
        if (!flag) printf("GOOD\n");
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1060ms|5736kB|888|G++|2018-02-08 13:54:43