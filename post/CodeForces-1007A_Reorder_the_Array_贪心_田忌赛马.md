题目链接：<https://cn.vjudge.net/problem/CodeForces-1007A>

### 题意
给个数组，元素的位置可以任意调换
问调换后的元素比此位置上的原元素大的元素个数最大多少

### 思路
一开始想了半天，最后想出来田忌赛马
田忌赛马经典题，一共5种可能性，详见[HDU-1052 Tian Ji -- The Horse Racing 贪心 考虑特殊位置（首尾元素）的讨论](https://www.cnblogs.com/tanglizi/p/9219030.html)

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;
int main(void){
    int n, a[100000+20], b[100000+20];

    scanf("%d", &n);
    for (int i=0; i<n; i++) scanf("%d", &a[i]), b[i]=a[i];
    sort(a, a+n); sort(b, b+n);

    int alast=n-1, head=0, last=n-1, i=0, cnt=0;
    while (i<=alast){
        if (b[i]<a[head]){
            head++; cnt++; i++;
        }else if (b[i]>a[head]){
            head++; alast--;
        }else if (b[i]==a[head]){
            if (b[alast]<a[last]){
                alast--; last--; cnt++;
            }else if (b[alast]>a[last]){
                alast--; head++;
            }else{
                if (a[head]<b[alast]);
                else if (a[head]>b[alast]) cnt++;
                alast--; head++;
            }
        }
    }printf("%d\n", cnt);

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
62ms|604kB|812|GNU G++ 5.1.0|2018-07-23 19:41:44