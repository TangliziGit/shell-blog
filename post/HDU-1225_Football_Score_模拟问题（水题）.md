题目链接：<https://cn.vjudge.net/problem/HDU-1225>

水题

### 代码
```cpp
#include <algorithm>
#include <string>
#include <cstdio>
#include <map>
using namespace std;
struct Team{
	int score[3];
	string name;
	Team(string name="", int s1=0, int s2=0, int s3=0):name(name) {
		score[0]=s1; score[1]=s2; score[2]=s3;
	}
	bool operator < (const Team &a) const{
		if (score[0]!=a.score[0]) return score[0]>a.score[0];
		if (score[1]!=a.score[1]) return score[1]>a.score[1];
		if (score[2]!=a.score[2]) return score[2]>a.score[2];
		return name<a.name;
	}
}arr[1000+5];

int main(void){
	int n;
	while (scanf("%d", &n)==1 && n){
		map<string, int> getidx;
		int size=0, end=n*(n-1), scores[2][3], s[2];
		char teamname[2][1000];
		for (int i=0; i<end; i++){
			scanf("%s%*s%s%d:%d", teamname[0], teamname[1], &s[0], &s[1]);
			
			
			if (s[0]==s[1]) scores[0][0]=scores[1][0]=1;
			else if (s[0]>s[1]) scores[0][0]=3, scores[1][0]=0;
			else scores[0][0]=0, scores[1][0]=3;
			scores[0][1]=s[0]-s[1]; scores[0][2]=s[0];
			scores[1][1]=s[1]-s[0]; scores[1][2]=s[1];
			
			for (int i=0; i<2; i++){
				if (!getidx.count(teamname[i])){
					getidx[teamname[i]]=size++;
					arr[getidx[teamname[i]]]=Team(teamname[i], scores[i][0], scores[i][1], scores[i][2]);
				}else for (int j=0; j<3; j++)
					arr[getidx[teamname[i]]].score[j]+=scores[i][j];
			}
		}
		sort(arr, arr+size);
		for (int i=0; i<size; i++)
			printf("%s %d\n", arr[i].name.c_str(), arr[i].score[0]);
		printf("\n");
	}

	return 0;
}
```