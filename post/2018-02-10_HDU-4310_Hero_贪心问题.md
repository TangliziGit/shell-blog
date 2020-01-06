题目链接：<https://cn.vjudge.net/problem/HDU-4310>

### 题意
打dota，队友太菜，局势变成1vN。还好你开了挂，hp无限大（攻击却只有一点每秒-_-）。
但是你并不想被A太多下，所以问题来了
给出对面的血量和每秒输出大小
问怎么安排，使得打败所有人后掉血最少

### 思路
首先可以想到我们必须一个一个打，这样所有人的总输出时间最少
因为如果打A一下，B一下，AB总输出肯定更大
其次考虑1v2的情况，因为1vN同理可得


现有ab两敌人
先打a的总输出为
$$ DPS_a*HP_a + DPS_b*(HP_a+HP_b) $$
先打b的总输出为
$$ DPS_b*HP_b + DPS_a*(HP_a+HP_b) $$
差别就在 $$DPS_b*HP_a ,  DPS_a*HP_b $$

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
struct Hero{
    int hp, dps;
    Hero(int hp=0, int dps=0):hp(hp),dps(dps) {}
    bool operator < (const Hero &a) const{
        return dps*a.hp>a.dps*hp;
    }
}heroes[25];

int main(void){
    int n;
    while (scanf("%d", &n)==1 && n){
        for (int i=0; i<n; i++)
            scanf("%d%d", &heroes[i].dps, &heroes[i].hp);
        sort(heroes, heroes+n);
        
        int sum=0, time=0;
        for (int i=0; i<n; i++){
            time+=heroes[i].hp;
            sum+=heroes[i].dps*time;
        }printf("%d\n", sum);
    }

    return 0;        
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|1512kB|621|G++|2018-02-08 21:55:55