题目链接：<https://cn.vjudge.net/problem/HDU-1083>

### 题意
有一些学生，有一些课程
给出哪些学生可以学哪些课程，每个学生可以选多课，但只能做一个课程的代表
问所有课能否全部都有代表？

### 思路
二分图最大匹配问题
一个学生只能匹配一个课程，那么X部是学生，Y部是课程
求最大匹配即可
注意
1. 二分图复杂度O(E*V)
2. 邻接矩阵里G[a][b]， a属于X部，b属于Y部，这是俩图所以ab节点的id可以相同
3. 初始化match和vis

### 提交过程
|||
:-|:-
AC|模版题

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=300+20, maxp=100+20;
bool G[maxp][maxn], vis[maxn];
int match[maxn], n, p;
bool dfs(int u){
	for (int i=1; i<=n; i++) if (!vis[i] && G[u][i]){
		vis[i]=true;
		if (match[i]==-1 || dfs(match[i])){
			match[i]=u;
			return true;
		}
	}return false;
}

int solve(void){
	int ans=0;
	memset(match, -1, sizeof(match));
	for (int i=1; i<=p; i++){
		memset(vis, false, sizeof(vis));
		if (dfs(i)) ans++;
	}return ans;
}

int main(void){
	int T;
	scanf("%d", &T);
	while (T--){
		scanf("%d%d", &p, &n);
		memset(G, false, sizeof(G));
		for (int i=1, size; i<=p; i++){
			scanf("%d", &size);
			for (int j=0, tmp; j<size; j++){
				scanf("%d", &tmp);
				G[i][tmp]=true;
			}
		}
		if (solve()==p) printf("YES\n");
		else printf("NO\n");
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
265ms|1248kB|839|G++|2018-07-26 13:18:47