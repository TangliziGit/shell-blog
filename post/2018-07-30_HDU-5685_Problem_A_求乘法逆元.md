题目链接：<https://cn.vjudge.net/problem/HDU-5685>

### 题意
给一个字符串S和一个哈希算法 $ H(s)=\prod_{i=1}^{i\leq len(s)}(S_{i}-28)\ (mod\ 9973) $
问[a, b]之间的字符串的哈希值

### 思路
维护一个前缀乘积prev，要求[a, b]的hash，只要(prev[b]*inv(prev[a-1]))%mod即可
求逆元kuangbin总结：找不到了怎么回事

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=1e5+20, mod=9973;
char str[maxn];
int prev[maxn], n, len;
int exgcd(int a, int b, int &x, int &y){
	if (b==0){x=1; y=0; return a;}
	int gcd=exgcd(b, a%b, y, x);
	y-=(a/b)*x;
	return gcd;
}

int inv(int a, int p){
	int x, y, gcd=exgcd(a, p, x, y);
	if (gcd==1) return (x%p+p)%p;
	return -1;
}

int main(void){
	while (scanf("%d", &n)==1 && n){
		scanf("%s", str+1);
		len=strlen(str+1);

		prev[0]=1;
		for (int i=1; i<=len; i++)
			prev[i]=(prev[i-1]*(str[i]-28))%mod;
		
		int a, b;
		while (n--){
			scanf("%d%d", &a, &b);
			printf("%d\n", (prev[b]*inv(prev[a-1], mod))%mod);
		}
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
109ms|1700kB|651|G++|2018-07-30 20:04:51