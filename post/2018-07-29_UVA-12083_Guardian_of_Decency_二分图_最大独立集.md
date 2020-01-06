题目链接：<https://cn.vjudge.net/problem/UVA-12083>

### 题意
学校组织去郊游，选择最多人数，使得任意两个人之间不能谈恋爱
不恋爱条件是高差大于40、同性、喜欢的音乐风格不同、喜欢的运动相同中的任意一个

### 思路
二分图最大独立集，集合内任两节点间没有边
最大独立集节点数=总结点数-最大匹配
模版题咯

### 提交过程
|||
:-|:-
CE1|选错语言
CE2|string头文件忘写
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <string>
#include <algorithm>
using namespace std;
const int maxn=500+20;
struct Person{
	int hei;
	bool male;
	string music, sport;
}person[2][maxn];
bool G[maxn][maxn], vis[maxn];
int match[maxn], n, m;
bool dfs(int u){
	for (int i=0; i<m; i++) if (!vis[i] && G[u][i]){
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
	for (int i=0; i<n; i++){
		memset(vis, false, sizeof(vis));
		if (dfs(i)) ans++;
	}return ans;
}

int main(void){
	int T, size;
	char music[100], sport[100], sex[5];
	int hei;

	scanf("%d", &T);
	while (T--){
		n=m=0;
		scanf("%d", &size);
		for (int i=0; i<size; i++){
			scanf("%d%s%s%s", &hei, sex, music, sport);
			if (sex[0]=='M') person[0][n++]=Person{hei, 1, string(music), string(sport)};
			else person[1][m++]=Person{hei, 0, string(music), string(sport)};
		}

		memset(G, false, sizeof(G));
		for (int i=0; i<n; i++)
			for (int j=0; j<m; j++){
				Person &male=person[0][i], &female=person[1][j];
				if (abs(male.hei-female.hei)<=40 && male.music==female.music && male.sport!=female.sport)
					G[i][j]=true;
			}
		printf("%d\n", n+m-solve());
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
40ms||1265|C++11 5.3.0|2018-07-26 14:06:14