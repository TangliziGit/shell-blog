题目链接：<https://cn.vjudge.net/problem/HDU-1257>

### 题意
中文题咯中文题咯

某国为了防御敌国的导弹袭击,发展出一种导弹拦截系统.但是这种导弹拦截系统有一个缺陷:虽然它的第一发炮弹能够到达任意的高度,但是以后每一发炮弹都不能超过前一发的高度.某天,雷达捕捉到敌国的导弹来袭.由于该系统还在试用阶段,所以只有一套系统,因此有可能不能拦截所有的导弹.
怎么办呢?多搞几套系统呗!你说说倒蛮容易,成本呢?成本是个大问题啊.所以俺就到这里来求救了,请帮助计算一下最少需要多少套拦截系统. 

### 思路
本来是想每次取最长不上升子序列，求这样的序列个数即可
发现复杂度O(n^2logn)，然后又发现数据范围没给...直接虚了
最后查到取最长上升子序列的长度即可。。。
然后就有了标题的问题
**最长上升子序列的长度==最长不上升子序列的个数？**

### 提交过程
|||
:-|:-
AC|查题解的

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;

int main(void){
    int n, hei[int(1e5)+5];
    
    while (scanf("%d", &n)==1 && n){
        for (int i=0; i<n; i++) scanf("%d", &hei[i]);

        int last[int(1e5)+5], size=0, ans=1; last[size++]=hei[0];
        for (int i=1; i<n; i++){
            if (last[size-1]<hei[i]){
                last[size++]=hei[i];
                ans++;
            }else{
                int idx=lower_bound(last, last+size, hei[i])-last;
                last[idx]=hei[i];
            }
        }printf("%d\n", ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
31ms|2360kB|586|G++|2018-06-22 20:10:54