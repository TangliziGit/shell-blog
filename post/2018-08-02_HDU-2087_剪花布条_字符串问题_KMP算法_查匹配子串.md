题目链接：<https://cn.vjudge.net/problem/HDU-2087>

### 题意
中文题咯
一块花布条，里面有些图案，另有一块直接可用的小饰条，里面也有一些图案。对于给定的花布条和小饰条，计算一下能从花布条中尽可能剪出几块小饰条来呢？ 

### 思路
裸题咯，就是贴一下模版，等下好整理

### 提交过程
|||
:-|:-
AC|注意maxn大小

### 代码
```cpp
#include <cstring>
#include <cstdio>
const int maxn=1e6+20, maxm=1e4+20;
char P[maxm], T[maxn];
int fail[maxm];
void getFail(int m){
	fail[0]=fail[1]=0;
	for (int i=1; i<m; i++){
		int j=fail[i];
		while (j && P[j]!=P[i]) j=fail[j];
		fail[i+1]=((P[i]==P[j])?j+1:0);
	}
}

int count(int n, int m){
	int cnt=0;
	getFail(m);
	for (int i=0, j=0; i<n; i++){
		while (j && T[i]!=P[j]) j=fail[j];
		if (P[j]==T[i]) j++;
		if (j==m){
			cnt++; j=0;
		}
	}return cnt;
}

int main(void){
	while (scanf("%s", T)==1 && T[0]!='#'){
		scanf("%s", P);
		printf("%d\n", count(strlen(T), strlen(P)));
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
15ms|1216kB|601|G++|2018-08-02 09:59:51