题目链接：<https://cn.vjudge.net/problem/HDU-2045>

找规律

### 代码
```cpp
#include <cstdio>
long long num[51][2];
int n;

int main(void){
	num[0][0]=2; num[0][1]=0;
	for (int i=0; i<50; i++){
		num[i+1][0]+=num[i][0]+num[i][1]*2;
		num[i+1][1]+=num[i][0];
	}
	
	while (scanf("%d", &n)==1 && n){
		if (n>=3) printf("%lld\n", 3*(num[n-3][0]+2*num[n-3][1]));
		else printf("%d\n", (n==2)?6:3);
	}

	return 0;
}
```


Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1504kB|333|G++|2018-01-17 13:39:25