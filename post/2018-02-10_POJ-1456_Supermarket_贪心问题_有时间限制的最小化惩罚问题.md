题目链接：<https://cn.vjudge.net/problem/POJ-1456>

此题与[HDU-1789](http://www.cnblogs.com/tanglizi/p/8437181.html)完全是一道题
### 题意
有N件商品，分别给出商品的价值和销售的最后期限，只要在最后日期之前销售处，就能得到相应的利润，并且销售该商品需要1天时间。
问销售的最大利润。

### 思路
详见[HDU-1789](http://www.cnblogs.com/tanglizi/p/8437181.html)

### 代码
注意题中n可为0
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
struct Product{
    int time, value;
    Product(void){}
    bool operator < (const Product &a) const{
        return value>a.value;
    }
};

int main(void){
    int n;

    while (scanf("%d", &n)==1){
        Product pdt[int(1e4)+5];
        for (int i=0; i<n; i++)
            scanf("%d%d", &pdt[i].value, &pdt[i].time);
        sort(pdt, pdt+n);

        int vis[int(1e4)+5]={0}, sum=0;
        for (int i=0; i<n; i++){
            int t=pdt[i].time;
            while (t>=1 && vis[t]) t--;
            if (t) {sum+=pdt[i].value; vis[t]=1;}
        }printf("%d\n", sum);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
157ms|440kB|658|G++|2018-02-09 00:53:41