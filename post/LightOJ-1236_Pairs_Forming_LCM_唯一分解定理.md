题目链接：<https://cn.vjudge.net/problem/LightOJ-1236>

### 题意
给一整数n，求有多少对a和b(a<=b)，使lcm(a, b)=n
注意数据范围n<=10^14

### 思路
唯一分解定理
要注意的是条件a<=b，这就是说，在不要求大小关系的情况下
ans包括a<b，a>b和a==b的情形，最终答案就是(ans+1)/2
注意数据范围，求因数时使用1e7的素数即可，剩余的未被分解的数一定是大素数
首先求一下素数加速求因数，其次注意prime*prime<=n是另一优化

### 提交过程
|||
:-|:-
TLE1|没注意数据范围，用了没有优化的getFactors
WA*n|模版有问题，一直在尝试优化
WA|注意ans*=factors[i][0]*2+1;
TLE2|第二个prime*prime<=n的优化没做
WA|注意long long范围
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e7+20;
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

long long solve(long long n){
	long long ans=1;
	getFactors(n);
	for (int i=0; i<fsize; i++)
		ans*=factors[i][1]*2+1;
	return (ans+1)/2;
}

int main(void){
	int T, kase=0;
	long long n;

	initPrimes();
	scanf("%d", &T);
	while (T--){
		scanf("%lld", &n);
		printf("Case %d: %lld\n", ++kase, solve(n));
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
540ms|14760kB|1096|C++|2018-07-30 15:45:20