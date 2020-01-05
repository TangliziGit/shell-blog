题目链接：<https://cn.vjudge.net/problem/HDU-3038>

### 题意
有一个包含n个整型数字的序列
现给出一些陈述表示第A个数到第B个数的加和S（即sigma）
其中有些陈述是对的，有些是错的（在不能判断出对错的情况下，此陈述保证是对的）
问一共有几个错的陈述

### 思路
还是没有思路，原来有一个前缀和的想法，马上又被自己否定了
所以经验告诉我，以后有思路了一定要在草稿本上画一画，捋一捋思路
思路是通过一个并查集来实现区间和，即node[a].pre和a之间的值是node[a].val

现在考虑如何合并新的线段和
我们首先要找到需要合并的两个区间的所有端点
int left=find(a), right=find(b);
之后只需要把这两个区间中的任意一个端点连在另一个区间的端点上，注意还要把操作的端点值更新一下

然后考虑如何进行查询
查询只能在根节点相同的情况下进行，区间和也就是node[b].val-node[a].val

推广一下就知道有可加可减性的问题，就可以用这个算法

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=200000+5;
struct Node{
    int pre, val;
    Node(int pre=0, int val=0):
        pre(pre), val(val) {}
}node[maxn];
int n, m;
int find(int x){
    if (node[x].pre==x) return x;
    int root=find(node[x].pre);
    node[x].val+=node[node[x].pre].val;
    return node[x].pre=root;
}

int main(void){
    while (scanf("%d%d", &n, &m)==2 && n){
        int a, b, val, cnt=0;
        for (int i=0; i<=n; i++) node[i]=Node(i, 0);
        while (m--){
            scanf("%d%d%d", &a, &b, &val); a--;
            int left=find(a), right=find(b);
            if (left!=right){
                node[right].pre=left;
                node[right].val=node[a].val-node[b].val+val;
            }else if (node[b].val-node[a].val!=val) cnt++;
        }printf("%d\n", cnt);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
62ms|3072kB|830|G++|2018-03-22 18:09:55

<br />
> 18-03-23 Update：更新思路