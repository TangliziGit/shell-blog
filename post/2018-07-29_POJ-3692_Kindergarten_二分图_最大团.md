题目链接：<https://cn.vjudge.net/problem/POJ-3692>

### 题意
幼儿园做游戏，要求每两人互相认识
求最多人数

### 思路
想了半天想不出，当时刚写完动态数据可视化，可能脑子不得劲
查了查百度，才有点意思
最大团，集合内每个节点之间存在边
最大团=补图的最大独立集

可以这样想啊
最大独立集是任两节点没有边
补图的最大独立集是任两节点没有补边->有联系

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=200+20;
bool G[maxn][maxn], vis[maxn];
int match[maxn], n, m, size;
bool dfs(int x){
	for (int i=1; i<=m; i++) if (!vis[i] && G[x][i]){
		vis[i]=true;
		if (match[i]==-1 || dfs(match[i])){
			match[i]=x;
			return true;
		}
	}return false;
}

int solve(void){
	int ans=0;
	memset(match, -1, sizeof(match));
	for (int i=1; i<=n; i++){
		memset(vis, false, sizeof(vis));
		if (dfs(i)) ans++;
	}return ans;
}

int main(void){
	int cnt=0, a, b;
	while (scanf("%d%d%d", &n, &m, &size)==3 && n){
		memset(G, true, sizeof(G));
		for (int i=0; i<size; i++){
			scanf("%d%d", &a, &b);
			G[a][b]=false;
		}printf("Case %d: %d\n", ++cnt, n+m-solve());
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
125ms|404kB|752|G++|2018-07-27 17:07:09