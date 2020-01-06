题目链接：<https://cn.vjudge.net/problem/POJ-2785>

### 题意
给出四组数，每组有n个数
现从每组数中取一个数作为a,b,c,d
问有几组这样的a+b+c+d=0

### 思路
首先把第一组和第二组的和添加在hash表里
再枚举三组四组的和，查找即可

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int hashSize=int(4e5), idxSize=int(1.6e7);
struct Data{
    int value, next, cnt;
    Data(int value=0, int next=-1, int cnt=0):
        value(value),next(next),cnt(cnt) {}
}data[idxSize];
int head[hashSize];
struct Hash{
    int size;
    Hash(void):size(0) {
        memset(head, -1, sizeof(head));
    }

    int hash(int num){
        return (num+hashSize)%hashSize;
    }
    int find(int num){
        int key=hash(num);
        for (int i=head[key]; i!=-1; i=data[i].next)
            if (data[i].value==num) return data[i].cnt;
        return 0;
    }
    int insert(int num){
        int key=hash(num);
        for (int i=head[key]; i!=-1; i=data[i].next)
            if (data[i].value==num) {data[i].cnt++; return i;}
        data[size]=Data(num, head[key], 1);
        return head[key]=size++;
    }
};
int n;

int main(void){
    while (scanf("%d", &n)==1){
        int tmp[4000+5][4];
        for (int i=0; i<n; i++)
            scanf("%d%d%d%d", &tmp[i][0], &tmp[i][1], &tmp[i][2], &tmp[i][3]);

        Hash hash;
        for (int i=0; i<n; i++)
            for (int j=0; j<n; j++)
                hash.insert(tmp[i][2]+tmp[j][3]);

        int ans=0;
        for (int i=0; i<n; i++)
            for (int j=0; j<n; j++) ans+=hash.find(-tmp[i][0]-tmp[j][1]);
        printf("%d\n", ans);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
6110ms|189996kB|1368|G++|2018-02-16 05:45:12