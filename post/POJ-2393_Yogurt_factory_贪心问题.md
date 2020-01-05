题目链接：<https://cn.vjudge.net/problem/POJ-2393>

### 题意
有一个生产酸奶的工厂，还有一个酸奶放在其中不会坏的储存室
每一单元酸奶存放价格为每周s元，在接下来的N周时间里，在第i周生产1单元的酸奶需要花费ci，然后奶牛在第i周会交付顾客yi的酸奶
求最小花费

### 思路
多生产的酸奶可以放在下周来卖，其实可以看作提前生产下周酸奶的成本会增加s元
维护一个最小的价格即可

### 代码
```cpp
#include <cstdio>

int main(void){
    int n, s;

    while (scanf("%d%d", &n, &s)==2){
        long long ans=0;
        for (int i=0, c, y, min; i<n; i++){
            scanf("%d%d", &c, &y);
            if (!i) min=c;
            else if (min>c) min=c;
            ans+=min*y; min+=s;
        }printf("%lld\n", ans);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
16ms|356kB|340|G++|2018-02-09 11:21:45