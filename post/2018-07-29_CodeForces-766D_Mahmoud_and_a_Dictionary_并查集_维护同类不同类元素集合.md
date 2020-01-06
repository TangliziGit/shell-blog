题目链接：<https://cn.vjudge.net/problem/CodeForces-766D>

### 题意
写词典，有些词是同义词，有些是反义词，还有没关系的词
首先输入两个词，需要判断是同义还是是反义，若没关系就按操作归为同义或反义

### 思路
经典并查集的动物园问题
维护两个并查集，find(a)表示a的同类代表元，find(a+maxn)表示异类代表元
find(a)==find(b) && find(a+maxn)==find(b+maxn) 就是说ab同类
find(a+maxn)==find(b) && find(a)==find(b+maxn) 就是说ab异类
其他就是没关系，需要合并

### 提交过程
|||
:-|:-
WA|输出问题，NO写成ON，老毛病
AC|

### 代码
```cpp
#include <map>
#include <cstdio>
#include <string>
#include <cstring>
using namespace std;
const int maxn=1e5+20;
int pre[maxn*2];
map<string, int> toid;

int find(int x){
	return (x==pre[x])?x:(pre[x]=find(pre[x]));
}

int join(int a, int b){
	a=find(a); b=find(b);
	if (a!=b) pre[a]=b;
}

int main(void){
	int n, m, q;
	char str[100], bstr[100];

	while (scanf("%d%d%d", &n, &m, &q)==3 && n){
		toid.clear();
		for (int i=1; i<=n; i++){
			scanf("%s", str);
			toid[string(str)]=i;
		}

		int arg, a, b;
		for (int i=1; i<=maxn*2; i++) pre[i]=i;
		for (int i=0; i<m; i++){
			scanf("%d%s%s", &arg, str, bstr);
			a=toid[string(str)];
			b=toid[string(bstr)];

			if (find(a)==find(b) && find(a+maxn)==find(b+maxn)){
				if (arg==1) printf("YES\n");
				else printf("NO\n");
			}else if (find(a)==find(b+maxn) && find(a+maxn)==find(b)){
				if (arg==2) printf("YES\n");
				else printf("NO\n");
			}else{
				printf("YES\n");
				if (arg==1) {join(a, b); join(a+maxn, b+maxn);}
				else {join(a, b+maxn); join(a+maxn, b);}
			}
		}

		while (q--){
			scanf("%s%s", str, bstr);
			a=toid[string(str)];
			b=toid[string(bstr)];

			if (find(a)==find(b) && find(a+maxn)==find(b+maxn)){
				printf("1\n");
			}else if (find(a)==find(b+maxn) && find(a+maxn)==find(b)){
				printf("2\n");
			}else printf("3\n");
		}
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
732ms|8380kB|1328|GNU G++ 5.1.0|2018-07-28 14:45:06