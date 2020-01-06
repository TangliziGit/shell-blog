题目链接：<https://cn.vjudge.net/problem/HDU-1789>

### 题意
小明有一大堆作业没写，且做一个作业就要花一天时间
给出所有作业的时间限制，和不写作业后要扣的分数
问如何安排作业，使被扣分最少

### 思路
因为有日期这个规定，所以可以提前写作业

有一个思路，复杂度是O(n^2)
就是先算得ｎ天内的最小扣分的安排，然后在n+1天时用第n+1天期限的作业更新一边最小扣分安排
考虑时间1000ms规模1000个数据，O(n^2)太冒险，所以考虑贪心

贪心思路O(n)
为了让扣分最少，那么首先按照分数由大到小排序
从头开始，贪心的把第n个作业拖到允许的最后一天做
如果最后一天有作业，那么就提前一天做（有点像hash表的解决冲突）

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
struct Work{
    int date, score;
    Work(int date=0, int score=0):
        date(date),score(score) {}
    bool operator < (const Work &a) const{
        return score>a.score;
    }
};

int main(void){
    int T, n;
    
    scanf("%d", &T);
    while (T--){
        scanf("%d", &n);
        Work works[1000+5];
        for (int i=0; i<n; i++) scanf("%d", &works[i].date);
        for (int i=0; i<n; i++) scanf("%d", &works[i].score);
        sort(works, works+n);

        int vis[1000+5]={0}, sum=0;
        for (int i=0; i<n; i++){
            int date=(works[i].date<=1000)?works[i].date:1000;
            while (date>=1 && vis[date]) date--;
            if (date) vis[date]=1;
            else sum+=works[i].score;
        }printf("%d\n", sum);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
31ms|1516kB|834|G++|2018-02-08 21:29:05