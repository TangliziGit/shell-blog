题目链接：<https://cn.vjudge.net/problem/POJ-1743>

### 题意
给一串整数，问最长不可重叠最长重复子串有多长
注意这里匹配的意思是匹配串的所有元素可以减去或者加上某个值
例： 34 30 26 22 18 82 78 74 70 66
后5个整数的串可以匹配前5个数

### 思路
LCP问题（最长公共前缀）
两个思路
1. 后缀数组
对height数组二分长度，找到height大于len且两字符串起点差值大于len的情况下，len最大值
2. 哈希+二分
二分长度，哈希值比较字符串找到当前len下符合要求子串即可

这题我用的第二个思路
首先差分一下，然后二分长度，用哈希的方法比较两个字符串O(1)
总复杂度O(nlog)（初始化O(n)+二分O(1*n*logn)）
刚从蓝书看来的，然而本题对hash表要求很高（能够处理unsigned long long大小键值）
那个简洁的HashMap还是要改改

具体写下好了
首先构建一个H数组，具体的
$$ H[i]= \sum S[i] base^{n-i-1} $$
对一个以i为起点，len为长度的字符串，他的Hash值：
$$ Hash(i, len)=H[i]-H[i+len] base^len $$
然后O(n)的字符串比较复杂度降到O(1)
这里可能会撞hash，所以保险一点咱还得再直接判断是否相同

### 提交过程
|||
:-|:-
WA*n|
TLE*n|
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=2e4+20;
const int HASH = 10007;
const int MAXN = 20010;
const unsigned long long hashBase=13331;
struct HASHMAP{
    int head[HASH],next[MAXN],size;
    unsigned long long state[MAXN];
    int f[MAXN];
    void init(){
        size = 0;
        memset(head,-1,sizeof(head));
    }

    int insert(unsigned long long val,int _id){
        int h = val%HASH;
        for(int i = head[h]; i != -1;i = next[i])
            if(val == state[i]) return f[i];
        f[size] = _id;
        state[size] = val;
        next[size] = head[h];
        head[h] = size++;
        return f[size-1];
    }
}hash;
unsigned long long hashBasePow[maxn], H[maxn];
int str[maxn], n;

bool judge(int len){
    hash.init();// hash.clear();
    for(int i=0; i<n-len; i++){
        unsigned long long key=H[i]-H[i+len]*hashBasePow[len];
        if (hash.insert(key, i)<i-len) return true;
    }return false;
}

int solve(void){
    int ans=0;
    int l=4, r=n-1;
    while(l<=r){
        int mid=l+(r-l)/2;
        if(judge(mid)) ans=mid, l=mid+1;
        else r=mid-1;
    }
    if(ans<4) ans=-1;
    return ans+1;
}

int main(){
    hashBasePow[0]=1;
    for(int i=1; i<maxn; i++)
        hashBasePow[i]=hashBasePow[i-1]*hashBase;
    while(scanf("%d", &n)==1 && n){
        for (int i=0; i<n; i++) scanf("%d", &str[i]);
        for (int i=0; i<n-1; i++) str[i]-=str[i+1];

        H[n-1]=str[n-1];
        for (int i=n-2; i>=0; i--)
            H[i]=H[i+1]*hashBase+str[i];
        printf("%d\n", solve());
    }
    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
547ms|1080kB|1557|G++|2018-08-03 15:26:17