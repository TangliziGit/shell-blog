题目链接：<https://cn.vjudge.net/problem/CodeForces-920E>

### 题意
给一个补图，问各个联通块有几个元素，升序排列
注意maxn=2e5, maxm=2e10

### 思路
数据量超大，这本来是并查集专题的一道题
如果用并查集的话，向上维护一个元素个数，但首先离线建图是个问题O(n^2)
这样考虑的话，bfs O(n)就是更好的选择
提交上去TLE，当时写题没仔细算复杂度，set查边+数组判重，加起来貌似O(nlogn+n），至于为什么用set查边，因为数组查边肯定空间太大
最后查了查题解，判重是链表删除元素，相当于真正的删除了，循环次数大大降低了
好么，厉害

### 提交过程
|||
:-|:-
CE|头文件
TLE1|set<pair<int, int>>存边
TLE2|改成set<long long>存边
WA1-3|忘了为啥WA了...
AC|

### 代码
```cpp
#include <set>
#include <queue>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=2e5+20;
int n, m, cnt, size[maxn], next[maxn], prev[maxn];
bool check[maxn];
set<long long> vis;
void del(int x){
	next[prev[x]]=next[x];
	prev[next[x]]=prev[x];
}

int bfs(int x){
	int ans=1;
	queue<int> que; que.push(x);
	check[x]=true; del(x);
	while (que.size()){
		int node=que.front(); que.pop();

		for (int i=next[0]; i<=n; i=next[i]) if (!check[i] && !vis.count((long long)i*maxn+node)){
			que.push(i);
			check[i]=true; del(i);
			ans++;
		}
	}return ans;
}

int main(void){
	int to, from;
	scanf("%d%d", &n, &m);
	for (int i=0; i<m; i++){
		scanf("%d%d", &to, &from);
		vis.insert((long long)to*maxn+from);
		vis.insert((long long)from*maxn+to);
	}
	for (int i=1; i<=n; i++) next[i]=i+1, prev[i]=i-1;
	next[0]=1; prev[n+1]=n;

	int cnt=0;
	for (int i=1; i<=n; i++) if (!check[i])
		size[cnt++]=bfs(i);
	sort(size, size+cnt);
	printf("%d\n", cnt);
	for (int i=0; i<cnt; i++) printf("%d%c", size[i], " \n"[i==cnt-1]);

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
343ms|16012kB|1067|GNU G++ 5.1.0|2018-07-23 17:51:00