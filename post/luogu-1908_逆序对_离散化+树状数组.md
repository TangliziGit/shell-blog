题目链接：<https://www.luogu.org/problem/show?pid=P1908>

### 题意
简单的求逆序对

### 思路
用树状数组来做逆序对
对于过大的数字来讲，用离散化处理即可
比赛的时候没有想到离散化啊，笨
还有一点，如果有重复数字出现的话，可以考虑用一个vis数组存下对应元素出现的次数，计数时减掉就好

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
#define lowbit(x) ((x)&(-x))
using namespace std;
const int maxn=40000;
struct Item{
    int val, id;
    bool operator < (const Item &a) const{
        return val>a.val;
    }
}item[maxn+5];
int n, vis[maxn], tree[maxn+5];
int sum(int x){
    int ans=0;
    for (int i=x; i>0; i-=lowbit(i))
        ans+=tree[i];
    return ans;
}

void add(int x, int val){
    for (int i=x; i<=n; i+=lowbit(i))
        tree[i]+=val;
}

int main(void){
    scanf("%d", &n);
    for (int i=0; i<n; i++){
        scanf("%d", &item[i].val);
        item[i].id=i+1;
    }
    sort(item, item+n);

    int ans=0;
    for (int i=0; i<n; i++){
        ans+=sum(item[i].id);
        add(item[i].id, 1);
    }printf("%d\n", ans);

    return 0;
}

```

Time|Memory
:-:|:-:
112ms|2273KB