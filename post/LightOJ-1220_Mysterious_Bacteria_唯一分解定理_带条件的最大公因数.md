题目链接：<https://cn.vjudge.net/problem/LightOJ-1220>

### 题意
给x=y^p，问p最大多少
注意x可能负数

### 思路
唯一分解定理，求各素因数指数的GCD
注意负数的情况，gcd一定要是奇数，这样就是最大奇GCD
只需每次求gcd后除2即可

### 提交过程
|||
:-|:-
WA*2|负数问题
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e5+20;
int factors[100][2], fsize, primes[maxn/10], psize;
bool isprime[maxn];
void initPrimes(void){
	memset(isprime, true, sizeof(isprime));
	isprime[0]=isprime[1]=false;
	for (int i=2; i<=maxn; i++){
		if(isprime[i]) primes[psize++]=i;
		for (int j=0; j<psize && i*primes[j]<=maxn; j++){
			isprime[primes[j]*i]=false;
			if (i%primes[j]==0) break;
		}
	}
}

void getFactors(long long n){
	fsize=0;
	// size of isprime can be sqrt(maxn)
	for (int i=0; i<psize && primes[i]*primes[i]<=n; i++){
		if (n%primes[i]==0){
			factors[fsize][0]=primes[i];
			factors[fsize][1]=0;
			while (n%primes[i]==0) factors[fsize][1]++, n/=primes[i];
			fsize++;
		}
	}
	if (n>1){
		factors[fsize][0]=n;
		factors[fsize++][1]=1;
	}
}

long long gcd(long long a, long long b){
	return (b==0)?a:gcd(b, a%b);
}

int main(void){
	int T, kase=0;

	initPrimes();
	scanf("%d", &T);
	while (T--){
		long long num;
		bool neg=false;

		scanf("%lld", &num);
		if (num<0) num=-num, neg=true;
		getFactors(num);

		long long exp=factors[0][1];
		if (neg) while (exp && exp%2==0) exp/=2;
		for (int i=1; i<fsize; i++){
			exp=gcd(exp, factors[i][1]);
			if (neg) while (exp && exp%2==0) exp/=2;
		}
		printf("Case %d: %lld\n", ++kase, exp);
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
|1224kB|1324|C++|2018-07-30 18:00:17