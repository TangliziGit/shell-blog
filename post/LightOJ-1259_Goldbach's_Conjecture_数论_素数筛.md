题目链接：<https://cn.vjudge.net/problem/LightOJ-1259>

### 题意
给一个整数n，问有多少对素数a和b，使得a+b=n

### 思路
素数筛
埃氏筛O(nloglogn)，这个完全够用，当n=3.5e7时将近一秒（1e8次操作）
欧拉筛O(n)
考虑数论专题过完了就写个模版专题

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
using namespace std;
const int maxn=1e7+20, maxp=7e5;
bool isprime[maxn];
int prime[maxp], psize=0;
void getPrimes(void){
	memset(isprime, true, sizeof(isprime));
	isprime[0]=isprime[1]=false;
	for (int i=2; i<=maxn; i++) if (isprime[i]){
		for (int j=i*2; j<=maxn; j+=i)
			isprime[j]=false;
		prime[psize++]=i;
	}
}

int main(void){
	int n, T, kase=0;

	getPrimes();
	scanf("%d", &T);
	while (T--){
		int cnt=0;
		scanf("%d", &n);
		for (int i=0; i<psize && prime[i]<=n/2; i++)
			if (isprime[n-prime[i]]) cnt++;
		printf("Case %d: %d\n", ++kase, cnt);
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
356ms|13588kB|608|C++|2018-07-30 13:18:25