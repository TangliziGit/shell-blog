题目链接：<https://cn.vjudge.net/problem/POJ-2752>

### 题意
给一个字符串，求前缀串跟后缀串相同的前缀串的个数
例：alala
输出：a, ala, alala

### 思路
仔细想想，fail[len]的返回值其实就是匹配成功的最大后缀串
得到这个后缀串后，比这个串更小的串一定还是被包含在这个新的后缀串中
迭代即可

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstring>
#include <cstdio>
const int maxm=4e5+20;
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
	int len, ans[maxm], kase=0;
	while (scanf("%s", P)==1 && !(P[0]=='.' && !P[1])){
		getFail(len=strlen(P));

		int size=len, ptr=1; ans[0]=len;
		while (size>0)
			ans[ptr++]=(size=fail[size]);
		for (int i=ptr-2; i>=0; i--)
			printf("%d%c", ans[i], "\n "[!!i]);
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
485ms|3840kB|547|G++|2018-08-02 11:27:13