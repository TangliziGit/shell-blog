题目链接：<https://cn.vjudge.net/problem/HDU-1035>

水题

### 代码
```cpp
#include <cstdio>
#include <map>
int height, width, sp, dir[4][2]={1, 0, 0, -1, -1, 0, 0, 1};
std::map<char, int> todir;
char map[15][15];
int solve(int x, int y, int step, int vis[][15], int &loop){
	if (x<0 || y<0 || x>=width || y>=height) {loop=0; return step;}
	if (vis[y][x]) {loop=step-vis[y][x]; return step-loop;}
	
	vis[y][x]=step;
	return solve(x+dir[todir[map[y][x]]][0], y+dir[todir[map[y][x]]][1], step+1, vis, loop);
}

int main(void){
	todir['E']=0; todir['N']=1;
	todir['W']=2; todir['S']=3;
	while (scanf("%d%d", &height, &width)==2 && height){
		scanf("%d", &sp);
		for (int y=0; y<height; y++) scanf("%s", map[y]);
		
		int vis[15][15]={0}, loop, cnt=solve(sp-1, 0, 1, vis, loop);
		if (!loop) printf("%d step(s) to exit\n", cnt-1);
		else printf("%d step(s) before a loop of %d step(s)\n", cnt-1, loop);
	}
	
	return 0;
}
```