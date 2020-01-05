题目链接：<https://cn.vjudge.net/problem/>

### 题意
找一个最小的正整数n
使得n!有a个零

### 思路
就是有几个因数10呗
考虑到10==2*5，也就是说找n!因数5有几个
数据量略大(N<=1e8)，打表之类的O(N)算法是直接不可以
分析到这里，可能的算法也就是二分了
找了找很久规律，发现可以有O(log5(n))的方法确定n!的因数5的个数
于是有二分

### 代码
```cpp
// binary search
// [f(m)<n, f(m)=n, f(m)>n]
// [l,      r,      r] (find min r)
// [l,      l,      r] (find max l)
//
// Attention:
// 1. make sure the initial value of l and r.
// 2. whlie (l<r-1).
// 3. l <= mid < r.
// 4. check if r(l) is the answer.

#include <cstdio>
long long find(long long n){
    long long ans=0;
    while (n){
        ans+=n/5; n/=5;
    }return ans;
}

long long search(long long n){
    long long l=1, r=5e8;
    while (l<r-1){
        long long mid=(r+l)/2, m=find(mid);
        if (m>=n) r=mid;
        else l=mid;
    }
    if (find(r)==n) return r;
    else return -1;
}

int main(void){
    int T; long long n;

    scanf("%d", &T);
    for (int cnt=1; cnt<=T; cnt++){
        scanf("%lld", &n);
        long long ans=search(n);
        if (ans>0) printf("Case %d: %lld\n", cnt, ans);
        else printf("Case %d: impossible\n", cnt);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
20ms|1088kB|896|C++|2018-05-17 18:18:26