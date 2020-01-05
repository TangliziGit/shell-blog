题目链接：<https://cn.vjudge.net/problem/HDU-5025>

### 题意
救唐僧，路上有m(<=9)把钥匙，最多5条蛇和一个唐僧。
目标是前往唐僧的地方，用全部钥匙打开全部的锁，来就唐僧。
钥匙必须要按顺序拿，只有拿过第三个钥匙才可以拿第四个钥匙。
蛇必须得打一个单位时间，打过的蛇就不要再打了。
问最少多长时间可以救出唐僧？没的救输出-1。

### 思路
又是状压搜索，注意细节即可。
二进制存打过的蛇的集合，注意有可能step大的在队前，所以咱得用优先队列。
如果用普通队列，还得注意vis数组的问题，有可能较大的元素在相同状态上打下标记，
这里就像队列dijkstra一样操作即可，改为int类型记录step。

### 提交过程
|||
:-|:-
MLE|数组大小写错了，注意<<的低优先级
WA|注意打过的蛇就不要再打了，被打怕了好么

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <queue>
using namespace std;
const int maxn=100+2, dir[4][2]={1,0, 0,1, -1,0, 0,-1}, INF=0x3f3f3f3f;
struct State{
	int x, y, step;
	char keys, snake;
	State(int x=0, int y=0, int step=0, char keys=0, char snake=0):
		x(x), y(y), step(step), snake(snake), keys(keys) {}
	bool operator < (const State &a) const{
		return step>a.step;
	}
};
bool vis[maxn][maxn][10+2][(1<<5)+1]; // attend this!!!!!
char map[maxn][maxn];
int n, m;

int bfs(int sx, int sy){
	priority_queue<State> que;
	que.push(State(sx, sy, 0, 0, 0));
	vis[sy][sx][0][0]=true;

	while (que.size()){
		State st=que.top(); que.pop();

		for (int i=0; i<4; i++){
			int xx=st.x+dir[i][0], yy=st.y+dir[i][1];
			char snake=st.snake, keys=st.keys;
			int step=st.step+1;

			if (xx<0 || yy<0 || xx>=n || yy>=n) continue;
			if (map[yy][xx]=='#') continue;
			else if (map[yy][xx]<0){
				int sid=(map[yy][xx]*-1)-1;
				if (!(snake & (1<<sid))) step++;
				snake|=(1<<sid);
			}else if (map[yy][xx]<='9' && map[yy][xx]>='1'){
				int kid=map[yy][xx]-'1';
				if (keys==kid) keys++;
			}else if (map[yy][xx]=='T'){
				if (keys==m) return step;
			}

			if (vis[yy][xx][keys][snake]) continue;
			vis[yy][xx][keys][snake]=true;
			que.push(State(xx, yy, step, keys, snake));
		}
	}
	return -1;
}

int main(void){
	while (scanf("%d%d", &n, &m)==2 && n){
		int sx, sy, sid=-1;
		for (int y=0; y<n; y++){
			scanf("%s", map[y]);
			for (int x=0; x<n; x++)
				if (map[y][x]=='K') sx=x, sy=y, map[y][x]='.';
				else if (map[y][x]=='S') map[y][x]=sid--;
		}

		memset(vis, false, sizeof(vis));
		int ans=bfs(sx, sy);
		if (ans<0) printf("impossible\n");
		else printf("%d\n", ans);
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
468ms|5856kB|1700|C++|2018-08-15 00:27:41|