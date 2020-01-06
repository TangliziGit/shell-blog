题目链接：<https://cn.vjudge.net/problem/UVA-12186>

### 题意
给出n, T和一棵树，树上每个节点需要选择T%个直属子节点。
问根节点一共需要选择几个节点。

### 思路
思路很明显，直接写了。
$$ dp[i]=\sum_{j \in Child(i)} minsort(dp[j]).head( \lceil kT/100 \rceil ) $$
需要非常注意的一点是复杂度问题。
发现还挺复杂，我们假设每个节点有k个直属子节点。
对于根节点，排序是这样的复杂度O(nlogn)；
对第一个子节点，复杂度是这样O( nlog(n/k) )；
那么最终的复杂度居然是O(nlog(n!)/k^h)？（其中h是树的层数）
差不多是O(nlog(n-1)!)？嗯？
等等，明天再分析这个吧，肯定不对啊。

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <vector>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=1e5+20;
vector<int> stuff[maxn];
int n, T, tmp;
int dp(int x){
    if (stuff[x].size()==0) return 1;

    int len=stuff[x].size(), ans=0, size=(len*T-1)/100+1;    // upper divide
    vector<int> tmp;
    for (int i=0; i<len; i++)
        tmp.push_back(dp(stuff[x][i]));
    sort(tmp.begin(), tmp.end());

    for (int i=0; i<size; i++)
        ans+=tmp[i];
    return ans;
}

int main(void){
    while (scanf("%d%d", &n, &T)==2 && n){
        for (int i=0; i<maxn; i++)
            stuff[i].clear();
        for (int i=1; i<=n; i++){
            scanf("%d", &tmp);
            stuff[tmp].push_back(i);
        }

        printf("%d\n", dp(0));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
110ms|None|779|C++ 5.3.0|2018-08-08 08:32:12