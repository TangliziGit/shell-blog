题目链接：<https://cn.vjudge.net/problem/HDU-1032>

水题

### 代码

```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
const int MAX=8388608;
int num[MAX], a, b;
int solve(int n){
	if (n<MAX && num[n]) return num[n];
	if (n==1) return 1;

	if (n%2) return (n<MAX)?(num[n]=solve(3*n+1)+1):(solve(3*n+1)+1);
	else return (n<MAX)?(num[n]=solve(n/2)+1):(solve(n/2)+1);
}

int main(void){
	while (scanf("%d%d", &a, &b)==2){
		int ans=1;
		for (int i=min(a, b); i<=max(a, b); i++) ans=max(ans, solve(i));
		printf("%d %d %d\n", a, b, ans);
	}

	return 0;
}
```