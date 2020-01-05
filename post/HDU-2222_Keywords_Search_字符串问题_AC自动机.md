题目链接：<https://cn.vjudge.net/problem/HDU-2222>

### 题意
给一些关键词，和一个待查询的字符串
问这个字符串里包含多少种关键词

### 思路
AC自动机模版题咯
注意一般情况不需要修改build方法，就像kmp里的getfail一样
一般的题目就是改改insert，query

一开始写的模版总是有问题，懒得改了
直接找的kuangbin的模版[【原创】AC自动机小结](http://www.cnblogs.com/kuangbin/p/3164106.html)
注意数组和指针的效率差不了多少，此题同一个算法的指针形式(296ms)比数组(187ms)慢110ms

说实在的，数组写法就是优雅。
网上那些指针的看着就难受，明明是好好的逻辑，变量名都是pqrvtxy，搞的跟被混淆了一样。
改了两套没一个舒服的，真难受。

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include<iostream>
#include<cstdio>
#include<queue>
#include<cstring>
using namespace std;
const int ACSize=500000+20;
const int maxitem=26, maxn=1e4+20, maxword=50+20, maxl=1e6+20;
char word[maxword], line[maxl];
struct Trie{
    int next[ACSize][26], fail[ACSize], cnt[ACSize];
    int root, total;
    int newnode(void){
        for(int pos=0; pos<maxitem; pos++)
            next[total][pos]=-1;
        cnt[total]=0;
        return total++;
    }

    void init(){
        total=0;
        root=newnode();
    }

    void insert(char buf[]){
        int now=root;
        for(int i=0; buf[i]; i++){
            int pos=buf[i]-'a';
            if(next[now][pos]==-1)
                next[now][pos]=newnode();
            now=next[now][pos];
        }
        cnt[now]++;
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

    int query(char buf[]){
        int now=root, res=0;
        for(int i=0; buf[i]; i++){
            int pos=buf[i]-'a';
            now=next[now][pos];
            for (int tmp=now; tmp!=root && cnt[tmp]!=-1; tmp=fail[tmp]){
                res+=cnt[tmp];
                cnt[tmp]=-1;            // 注意此处，找到了就不要找第二次了，直接删除即可
            }
        }return res;
    }

    void debug(void){
        for(int i=0; i<total; i++){
            printf("id=%3d, fail=%3d, end=%3d  [", i, fail[i], cnt[i]);
            for(int j=0; j<maxitem; j++)
                printf("%2d", next[i][j]);
            printf("]\n");
        }
    }
}AC;

int main(void){
    int T, n;

    scanf("%d", &T);
    while (T--){
        AC.init();
        scanf("%d", &n);
        for (int i=0; i<n; i++){
            scanf("%s", word);
            AC.insert(word);
        }AC.build();

        scanf("%s", line);
        printf("%d\n", AC.query(line));
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
187ms|27744kB|2369|G++|2018-08-02 16:16:21