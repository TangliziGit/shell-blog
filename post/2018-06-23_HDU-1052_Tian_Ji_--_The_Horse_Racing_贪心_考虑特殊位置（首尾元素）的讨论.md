题目链接：<https://cn.vjudge.net/problem/HDU-1052>

### 题意
田忌赛马问题扩展版
给n匹马，马的能力可以相同
问得分最大多少

### 思路
贪心做得还是太少，一开始一点思虑都没有的
这里稍微总结一下如何打开思路吧
1. 从**特殊位置**开始考虑是否存在**某种必然性**，包括不限于序列首尾
2. 若讨论难以进行，试着**把这个讨论点展开，换个角度**（或者换个特殊位置）讨论

首先排序
其次的关键是讨论尾元素是否必胜或必败，思考贪心
在一个关键是双方尾元素相同时，展开考虑首元素是否必胜或必败，思考贪心
当首尾元素各相等时，用我们最慢马比齐王最快马，这里需要认真证明，但可能考虑不到证法（这里可能需要总结规律？）。。。

### 提交过程
|||
:-|:-
AC|没有思路，看得以前的代码AC的:(

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;

int main(void){
    int n, a[1020], b[1020];

    while (scanf("%d", &n)==1 && n){
        for (int i=0; i<n; i++) scanf("%d", &a[i]);
        for (int i=0; i<n; i++) scanf("%d", &b[i]);
        sort(a, a+n); sort(b, b+n);

        int head=0, last=n-1, alast=n-1, i=0, cnt=0;
        while (i<=alast){
            if (b[i]<a[head]){
                head++; cnt++; i++;
            }else if (b[i]>a[head]){
                head++; alast--; cnt--;
            }else if (b[i]==a[head]){
                if (b[alast]<a[last]){
                    alast--; last--; cnt++;
                }else if (b[alast]>a[last]){
                    alast--; head++; cnt--;
                }else{
                    if (a[head]<b[alast]) cnt--;
                    else if (a[head]>b[alast]) cnt++;
                    alast--; head++;
                }
            }
        }printf("%d\n", cnt*200);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
46ms|1596kB|970|G++|2018-06-23 11:35:55