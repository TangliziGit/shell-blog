题目链接：<https://cn.vjudge.net/problem/HDU-3065>

### 题意
跟上一道题是几乎一模一样，这次是统计关键词的出现次数
一个相当坑的地方，注意多组样例

### 思路
套模版
改insert方法，这次我们指定每个关键词的idx
改query方法，统计value_counter（话说最近几天在用pandas，value_counts确实方便）

### 提交过程
|||
:-|:-
WA*n|注意多组样例
WA|注意用128大小的分支，用26个同时判断待匹配串的话会WA？
AC|

### 代码
```cpp
#include <map>
#include <queue>
#include <cstdio>
#include <string>
#include <cstring>
using namespace std;
const int maxn=1000+20, maxw=50+20, maxl=2000000+20;
const int ACSize=maxn*maxw, maxitem=128;
char word[maxw], line[maxl];
map<int, string> tostr;
struct ACauto{
    int next[ACSize][maxitem], fail[ACSize], cnt[ACSize];
    int root, total;
    int newnode(void){
        for(int pos=0; pos<maxitem; pos++)
            next[total][pos]=-1;
        cnt[total]=0;
        return total++;
    }
    void init(void){
        total=0;
        root=newnode();
    }
    int getPos(char ch){
        return ch;
    }

    void insert(char buf[], int idx){
        int now=root;
        for(int i=0; buf[i]; i++){
            int pos=getPos(buf[i]);
            if(next[now][pos]==-1)
                next[now][pos]=newnode();
            now=next[now][pos];
        }
        cnt[now]=idx; //++itemCounter;
    }

    void build(void){
        queue<int> que;
        fail[root]=root;
        for(int i=0; i<maxitem; i++)
            if(next[root][i]==-1)
                next[root][i]=root;
            else{
                fail[next[root][i]]=root;
                que.push(next[root][i]);
            }

        while(!que.empty()){
            int now=que.front(); que.pop();

            for(int pos=0; pos<maxitem; pos++)
                if(next[now][pos]==-1)
                    next[now][pos]=next[fail[now]][pos];
                else{
                    fail[next[now][pos]]=next[fail[now]][pos];
                    que.push(next[now][pos]);
                }
        }
    }

    void query(char buf[], int counter[]){
        int now=root;
        for(int i=0; buf[i]; i++){
            int pos=getPos(buf[i]);
            // if (pos<0 || pos>=maxitem){pos=root; continue;}
            now=next[now][pos];
            for (int tmp=now; tmp!=root; tmp=fail[tmp]) if (cnt[tmp])
                counter[cnt[tmp]]++;
        }
    }
}AC;

int main(void){
    int m, n;

    while (scanf("%d", &n)==1 &&n){
        AC.init();
        for (int i=1; i<=n; i++){
            scanf("%s", word);
            AC.insert(word, i);
            tostr[i]=string(word);
        }AC.build();

        int counter[maxn]={0};
        scanf("%s", line);
        AC.query(line, counter);

        for (int i=1; i<=n; i++) if (counter[i])
            printf("%s: %d\n", tostr[i].c_str(), counter[i]);
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
234ms|18004kB|2417|C++|2018-08-02 17:39:24