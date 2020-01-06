题目链接：<https://cn.vjudge.net/problem/POJ-2823>

### 题意
给一个序列和一个窗口，问在序列上的窗口不断移动的过程中，最大最小值分别是多少。

### 思路
单调队列裸题

### 提交过程
|||
:-|:-
TLE*n|不知道为什么超时，换成C++编译器就过了
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=1e6+20;
struct Node{
    int num, time;
    Node(int num=0, int time=-1):num(num), time(time){}
}list[maxn];
int num[maxn], len, size, front, tail;
void minInsert(Node node){
    while (front<tail && node.time-len >= list[front].time)
        front++;
    while (front<tail && list[tail-1].num >= node.num)
        tail--;
    list[tail++]=node;
}
void minKeeper(void){
    for (int i=0; i<len; i++) minInsert(Node(num[i], i));
    for (int i=len-1; i<size; i++){
        minInsert(Node(num[i], i));
        printf("%d%c", list[front].num, " \n"[i==size-1]);
    }
}

void maxInsert(Node node){
    while (front<tail && node.time-len >= list[front].time)
        front++;
    while (front<tail && list[tail-1].num <= node.num)
        tail--;
    list[tail++]=node;
}
void maxKeeper(void){
    for (int i=0; i<len; i++) maxInsert(Node(num[i], i));
    for (int i=len-1; i<size; i++){
        maxInsert(Node(num[i], i));
        printf("%d%c", list[front].num, " \n"[i==size-1]);
    }
}

int main(void){
    int n;

    scanf("%d%d", &size, &len);
    for (int i=0; i<size; i++) scanf("%d", &num[i]);
    front=tail=0; minKeeper();
    front=tail=0; maxKeeper();

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
5579ms|11904kB|1232|C++|2018-08-09 02:49:09