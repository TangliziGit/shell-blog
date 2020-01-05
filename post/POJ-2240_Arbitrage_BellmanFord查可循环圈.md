题目链接：<https://cn.vjudge.net/problem/POJ-2240>

### 题意
套利(Arbitrage)就是通过不断兑换外币，使得自己钱变多的行为
给出一些汇率
问能不能套利

### 思路
马上想到bellman的判负圈
于是写完WA一发
问题在是否联通的问题上，我随便给Bellman喂了一个节点...
然后有连续WA了5次，问题在我把Yes打成了YES...

1. 图论题目一定要考虑连通性，至少是查负环时
2. 注意预处理
3. 以后再也别手打输出了，就算是天塌下来也别

### 代码
```cpp
#include <map>
#include <queue>
#include <vector>
#include <string>
#include <cstdio>
#include <cstring>
#include <iostream>
using namespace std;
const int maxn=35, INF=0x3f3f3f3f;
const double eps=1e-6;
struct Edge{
    int from, to;
    double rate;
};
map<string, int> words;
vector<Edge> edges;
vector<int> G[maxn+5];

inline void addEdge(int from, int to, double rate){
    edges.push_back((Edge){from, to, rate});
    G[from].push_back(edges.size()-1);
    // edges.push_back(Edge{to, from, 1/rate});
    // G[to].push_back(edges.size()-1);
}

inline bool equal(const double &a, const double &b){
    return ((a-b<=eps) && (b-a<=eps));
}

bool Bellman(int st, int n){
    double dist[maxn+5];
    bool inq[maxn+5]={false};
    int cnt[maxn+5]={0};
    queue<int> que;
    
    for (int i=0; i<=maxn; i++) dist[i]=0;//(double)INF;
    dist[st]=1.0; inq[st]=true;
    que.push(st);

    while (que.size()){
        int from=que.front(); que.pop();
        inq[from]=false;

        for (int i=0; i<G[from].size(); i++){
            Edge &e=edges[G[from][i]];
            int &to=e.to; double nrate=dist[from]*e.rate;

            if (dist[to]>nrate || equal(dist[to], nrate)) continue;
            dist[to]=nrate;

            if (inq[to]) continue;
            inq[to]=true;
            que.push(to);

            if (++cnt[to]>=n) return true;
        }
    }return false;
}

void init(void){
    for (int i=0; i<=maxn; i++) G[i].clear();
    edges.clear();
    words.clear();
}

int main(void){
    int n, m, cnt=1;
    double rate;
    string name, from, to;

    while (scanf("%d", &n)==1 && n){
        init();
        for (int i=1; i<=n; i++){
            cin >> name;
            words[name]=i;
        }
        cin >> m;

        for (int i=0; i<m; i++){
            cin >> from >> rate >> to;
            addEdge(words[from], words[to], rate);
        }

        bool flg=false;
        for (int i=1; i<=n; i++)
            if (Bellman(i, n)){
                printf("Case %d: Yes\n", cnt++);
                flg=true;
                break;
            }
        if (!flg) printf("Case %d: No\n", cnt++);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
954ms|800kB|2317|G++|2018-05-25 19:11:58