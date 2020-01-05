题目链接：<https://cn.vjudge.net/problem/HDU-1358>

### 题意
给一个字符串，对下标大于2的元素，问有几个最小循环节

### 思路
对每个元素求一下minloop，模一下就好

### 提交过程
|||
:-|:-
TLE|maxn没给够
AC|

### 代码
```cpp
#include <cstring>
#include <cstdio>
const int maxm=1e6+20;
char P[maxm];
int fail[maxm];
void getFail(int m){
	fail[0]=fail[1]=0;
	for (int i=1; i<m; i++){
		int j=fail[i];
		while (j && P[j]!=P[i]) j=fail[j];
		fail[i+1]=((P[i]==P[j])?j+1:0);
	}
}

int main(void){
	int len, kase=0;
	while (scanf("%d", &len)==1 && len){
		scanf("%s", P);
		getFail(len);

		printf("Test case #%d\n", ++kase);
		for (int i=2; i<=len; i++){
			int maxloop=i-fail[i];
			if (maxloop!=i && i%maxloop==0) printf("%d %d\n", i, i/maxloop);
		}printf("\n");
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
78ms|6100kB|625|G++|2018-08-02 10:46:24