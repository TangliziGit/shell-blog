题目链接：<https://cn.vjudge.net/problem/ZOJ-3261>

### 题意
有n个星星，之间有m条边
现一边询问与x星连通的最大星的编号，一边拆开一些边

### 思路
一开始是真不会，甚至想用dfs模拟
最后查了一下，这个题原来是要离线操作，**拆边就变为合并**
这很为难哈哈，本以为有个什么更好的数据结构（动态树？）
存边我们用一个set&lt;int&gt;来存一个数字即可（bfs这类写多了就很容易考虑到**压缩数据**）
还有一个重要的点，就是并查集的join可以用来**维护一个最大（小）数据**作为跟节点的值

### 代码
```cpp
#include <set>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=10000, maxq=50000;
struct IdxMap{
    int val, idx;
    IdxMap(int val=0, int idx=0):
        val(val), idx(idx) {}
    bool operator < (const IdxMap &a) const{
        if (val!=a.val) return val>a.val;
        return idx<a.idx;
    }
}imap[maxn+5];
struct Operate{
    // true for destory(add)
    bool ifadd; int a, b;
    Operate(bool ifadd=false, int a=-1, int b=-1):
        ifadd(ifadd), a(a), b(b) {}
}operate[maxq+5];
struct Node{
    int pre, data;// rank, data;
    Node(int pre=0, int data=0):// int rank=0, int data=0):
        pre(pre), data(data) {}// rank(rank), data(data) {}
}node[maxn+5];
int n, m, q, asize=0, ans[maxq+5];
set<int> edge;      // smeller proir

int find(int x){
    return (node[x].pre==x)?x:(node[x].pre=find(node[x].pre));
}

void join(int a, int b){
    a=find(a); b=find(b);
    if (a==b) return;
    // if (node[a].rank==node[b].rank) node[a].rank++;
    if (node[a].data>=node[b].data) node[b].pre=a;
    else node[a].pre=b;
}

inline int getcode(const int &a, const int &b){
    if (a<b) return a*maxn+b;
    return b*maxn+a;
}

int findBiggest(int x){
    // int &val=node[x].data;
    // for (int i=0; i<n; i++){
    //     if (val>=imap[i].val) return -1;
    //     if (find(x)==find(imap[i].idx)) return imap[i].idx;
    // }return -1;
    int root=find(x);
    if (node[root].data>node[x].data) return root;
    return -1;
}

int main(void){
    int first=true;
    while(scanf("%d", &n)==1 && n){
        edge.clear();
        asize=0;

        for (int i=0, tmp; i<n; i++){
            scanf("%d", &tmp);
            imap[i]=IdxMap(tmp, i);
            node[i]=Node(i, tmp);
        }sort(imap, imap+n);
        scanf("%d", &m);
        for (int i=0, a, b; i<m; i++){
            scanf("%d%d", &a, &b);
            edge.insert(getcode(a, b));
        }

        char str[25];
        scanf("%d", &q);
        for (int i=0, a, b; i<q; i++){
            scanf("%s", str);
            if (str[0]=='d'){
                scanf("%d%d", &a, &b);
                operate[i]=Operate(true, a, b);
                edge.erase(getcode(a, b));
            }else if (str[0]=='q'){
                scanf("%d", &a);
                operate[i]=Operate(false, a, -1);
            }
        }

        for (set<int>::iterator it=edge.begin(); it!=edge.end(); it++)
            join((*it)/maxn, (*it)%maxn);

        for (int i=q-1; i>=0; i--){
            if (operate[i].ifadd) join(operate[i].a, operate[i].b);
            else ans[asize++]=findBiggest(operate[i].a);
        }
        if (!first) printf("\n");
        else first=false;
        for (int i=asize-1; i>=0; i--) printf("%d\n", ans[i]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
260ms|2124kB|2764|C++ (g++ 4.7.2)|2018-03-20 23:26:36

<br />
> 18-03-21 Update：并查集维护最值