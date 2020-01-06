题目链接：<https://cn.vjudge.net/problem/POJ-2236>

### 题意
灾区断网，欲修理之
现给各机器坐标和正常信号的连接距离
一边修电脑，一边问某两个电脑之间能否正常链接

### 思路
并查集入门题目
当修电脑的同时，把此电脑加入可链接的电脑集合
当询问时，输出电脑的根节点即可

### 代码
```cpp
// why runtime error?
// because parent can't be nagetive in find();
#include <cstdio>
#include <cmath>
const int MAX=int(1e3);
struct Node{
    int parent, rank;
    Node(int parent=-1, int rank=0):
        parent(parent),rank(rank) {}
}node[MAX+5];
int px[MAX+5], py[MAX+5], vec[MAX+5];
int find(int x){
    return (x==node[x].parent)?x:(node[x].parent=find(node[x].parent));
}

void join(int a, int b){
    a=find(a); b=find(b);
    if (a==b) return;
    if (node[a].rank==node[b].rank) node[a].rank++;
    if (node[a].rank>node[b].rank) node[b].parent=a;
    else node[a].parent=b;
}

inline bool graph(int a, int b, int mdis){
    int dis=(px[a]-px[b])*(px[a]-px[b])+(py[a]-py[b])*(py[a]-py[b]);
    if (dis>mdis*mdis) return false;
    return true; 
}

int main(void){
    int n, dis, size=0, oper[2];
    char ch[5];

    scanf("%d%d", &n, &dis);
    for (int i=1; i<=n; i++) scanf("%d%d", &px[i], &py[i]);

    while (scanf("%s%d", ch, &oper[0])==2){
        if (ch[0]=='O' && node[oper[0]].rank==0){
            node[oper[0]]=Node(oper[0], 1);
            for (int i=0; i<size; i++)
                if (graph(oper[0], vec[i], (double)dis)) join(oper[0], vec[i]);
            vec[size++]=oper[0];
        }else if (ch[0]=='S'){
            scanf("%d", &oper[1]);
            if (node[oper[0]].parent<0 || node[oper[1]].parent<0) printf("FAIL\n");
            else if (find(oper[0])==find(oper[1])) printf("SUCCESS\n");
            else printf("FAIL\n");
        }
    }


    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1094ms|164kB|1496|C++|2018-02-16 14:41:06


Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
3016ms|372kB|1496|G++|2018-02-16 14:28:29

顺便注意一下C++和G++编译出的效率区别
很明显的差别，一直用G++编译感觉很难受，憋屈
有机会区别一下二者，写个随笔