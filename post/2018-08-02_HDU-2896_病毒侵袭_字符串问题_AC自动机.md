题目链接：<https://cn.vjudge.net/problem/HDU-2896>

### 题意
中文题
给一些关键词和一个字符串，问字符串里包括了那几种关键词

### 思路
直接套模版
改insert方法，维护一个itemCounter，给关键词计数
改query方法，统计counter即可

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
const int ACSize=1e5+20, maxitem=128;
const int maxn=500+20, maxm=1e2+20, maxw=200+20, maxl=1e4+20;
char word[maxw], line[maxl];
struct ACauto{
    int next[ACSize][maxitem], fail[ACSize], cnt[ACSize];
    int root, total, itemCounter;
    int newnode(void){
        for(int pos=0; pos<maxitem; pos++)
            next[total][pos]=-1;
        cnt[total]=0;
        return total++;
    }
    void init(void){
        itemCounter=total=0;
        root=newnode();
    }
    int getPos(char ch){
        return ch;
    }

    void insert(char buf[]){
        int now=root;
        for(int i=0; buf[i]; i++){
            int pos=getPos(buf[i]);
            if(next[now][pos]==-1)
                next[now][pos]=newnode();
            now=next[now][pos];
        }
        cnt[now]=++itemCounter;
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

    int query(char buf[], bool counter[]){
        int now=root; bool res=false;
        for(int i=0; buf[i]; i++){
            int pos=getPos(buf[i]);
            now=next[now][pos];
            for (int tmp=now; tmp!=root; tmp=fail[tmp]) if (cnt[tmp])
                res=counter[cnt[tmp]]=true;
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
    int n, m;

    AC.init();
    scanf("%d", &n);
    for (int i=0; i<n; i++){
        scanf("%s", word);
        AC.insert(word);
    }AC.build();

    int total=0;
    scanf("%d", &m);
    for (int kase=1; kase<=m; kase++){
        bool counter[maxn]={false};
        scanf("%s", line);
        if (AC.query(line, counter)){
            printf("web %d:", kase);
            for (int i=1; i<maxn; i++) if (counter[i])
                printf(" %d", i);
            printf("\n");
            total++;
        }
    }printf("total: %d\n", total);

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
202ms|30160kB|2733|G++|2018-08-02 16:45:33