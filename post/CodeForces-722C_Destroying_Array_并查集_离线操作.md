题目链接：<https://cn.vjudge.net/problem/CodeForces-722C>

### 题意
给个数组，每次删除一个元素，删除的元素作为一个隔断，问每次删除后该元素左右两边最大连续和

### 思路
这个题的思路马上就想到的时候，别人直接抢答，还是比较厉害的人了
离线操作，删除变成添加，添加时注意左右两边元素的最大值即可

### 提交过程
|||
:-|:-
WA|忘了为什么WA了
AC|

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
const int maxn=1e5+20, INF=0x3f3f3f3f;
long long n, nums[maxn], oper[maxn], out[maxn];
bool vis[maxn], flg;
struct Node{
	int pre; long long sum;
	Node(int pre=0, long long sum=0):
		pre(pre), sum(sum) {}
}nodes[maxn];

int find(int x){
	if (x==nodes[x].pre) return x;
	nodes[nodes[x].pre].sum+=nodes[x].sum;
	nodes[x].sum=0;
	return nodes[x].pre=find(nodes[x].pre);
}

void join(int a, int b){
	a=find(a); b=find(b);
	if (a==b) return;
	nodes[a].pre=b;
}

int main(void){
	scanf("%d", &n);
	for (int i=1; i<=n; i++) nodes[i]=Node(i, 0);
	for (int i=1; i<=n; i++) scanf("%lld", &nums[i]);
	for (int i=1; i<=n; i++) scanf("%lld", &oper[i]);
	for (int i=n; i>=1; i--){
		int idx=oper[i];
		nodes[idx]=Node(idx, nums[idx]);
		vis[idx]=true; out[i-1]=max(nums[idx], out[i]);
		if (idx-1>=1 && vis[idx-1]){
			join(idx-1, idx); // find(idx-1);
			out[i-1]=max(out[i-1], nodes[find(idx-1)].sum);
		}if (idx+1<=n && vis[idx+1]){
			join(idx, idx+1); find(idx);
			out[i-1]=max(out[i-1], nodes[find(idx+1)].sum);
		}
	}
	for (int i=1; i<=n; i++) printf("%lld\n", out[i]);

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-: