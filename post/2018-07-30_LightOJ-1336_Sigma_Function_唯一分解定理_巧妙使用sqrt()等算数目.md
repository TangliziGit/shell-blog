题目链接：<https://cn.vjudge.net/problem/LightOJ-1336>

### 题意
给出一个区间[1, n]，求区间内所有数中因数之和为偶数的数目

### 思路
第二次写这个题
首先想到唯一分解定理
$$
s=p_1^{n_1}*p_2^{n_2}...p_m^{n_m}
$$
$$
ans=\prod \sum p_i^j
$$
其中ans为所有因子之和
明显的，若ans为偶数，则所有 $ \sum p_i^j $为偶数
又$ \sum_{1 \to j} p_i^j $应为奇数(上式减1)，则所有p为奇数且n为奇数
所以这里可以对一个数进行判断了，然而maxn=1e12，一个一个算绝对超时

这时看了看上次代码，发现了个sqrt()
立马明白sqrt(n)的另一个意思：1~n之间有几个平方数，平方数对应着n全为偶数
于是公式就直接出现
ans=n-sqrt(n)-sqrt(n/2)

### 提交过程
|||
:-|:-
WA|忘了long long 数据范围
AC|

### 代码
```cpp
#include <cstdio>
#include <cmath>
const double eps=1e-8;

int main(void){
	int T, kase=0;
	long long n;

	scanf("%d", &T);
	while (T--){
		scanf("%lld", &n);
		// sqrt(n) == the count of numbers which can be sqrted with 2^2k from 1 to n.
		// sqrt(n) == the count of numbers which can be sqrted with 2^2k+1 from 1 to n.
		n-=(long long)(sqrt(n)+eps)+(long long)(sqrt(n/2)+eps);
		printf("Case %d: %lld\n", ++kase, n);
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|1100kB|435|C++2018-07-30 17:13:41