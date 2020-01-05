题目链接：<https://cn.vjudge.net/problem/HDU-1034>

水题

### 代码

```cpp
#include <cstdio>
#include <algorithm>
int n;
long long stu[10000+5], max, min;
int func(void){
	int tmp[2]={stu[0]/=2, 0};
	
	for (int i=0; i<n; i++){
		tmp[1]=stu[i+1]/=2;
		stu[(i+1)%n]+=tmp[0];
		tmp[0]=tmp[1];
		
		if (stu[(i+1)%n]%2) stu[(i+1)%n]+=1;
		if (i==0) max=min=stu[(i+1)%n];
		max=std::max(stu[(i+1)%n], max);
		min=std::min(stu[(i+1)%n], min);
	}
	return min!=max;
}

int main(void){
	while (scanf("%d", &n)==1 && n){
		for (int i=0; i<n; i++){
			scanf("%d", &stu[i]);
			if (i==0) {min=max=stu[i];}
			max=std::max(stu[i], max);
			min=std::min(stu[i], min);
		}
		int cnt=0;
		if (min!=max) while (func()) cnt++;
		printf("%d %d\n", cnt+1, max);
	}

	return 0;
}
```