题目链接：<https://cn.vjudge.net/problem/HDU-4055>

### 题意
给一个序列相邻元素各个上升下降情况（'I'上升'D'下降'?'随便），问有几种满足的排列。
例：ID
答：2 (231和132)

### 思路
第一次看这题，思路是没得。
又是最后讲题才知道咋写。
直接给方程了：
dp[i][j]表示满足以j为结尾的，长度为i的排列方案数。
str[i]=='I': dp[i][j]=sum(dp[i-1][k]) (1<=k<=j-1)
str[i]=='D': dp[i][j]=sum(dp[i-1][k]) (j<=k<=i)
str[i]=='?': dp[i][j]=sum(dp[i-1][k]) (1<=k<=i)
这里的I一定是没问题，D为啥是个这？
可以想像D的意思是在一个序列末尾插入一个大小为j元素，
这样的话，前面所有大于等于j的元素应该被加一才能满足是一个排列。
那么'?'亦然。

### 提交过程
|||
:-|:-
WA×2|注意取模，正数也得加模取模，因为可能溢出？
AC|注意边界dp[1][1]=1, 没用滚动数组2152ms
AC|滚动数组1591ms, 省去了时间上的指针操作和空间

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=1e3+20;
const long long mod=1000000007;
long long dp[maxn];
char str[maxn];

int main(void){
    while (scanf("%s", str)==1){
        int len=strlen(str);
        memset(dp, 0, sizeof(dp));
        // for (int i=1; i<=len; i++) dp[0][i]=1;
        dp[1]=1;

        for (int i=1; i<=len; i++){
            long long sum[maxn];
            sum[0]=0;
            for (int j=1; j<=i; j++) sum[j]=(sum[j-1]+dp[j])%mod;

            for (int j=1; j<=i+1; j++){
                dp[j]=0;
                if (str[i-1]!='I') dp[j]=(dp[j]+sum[i]-sum[j-1])%mod;
                if (str[i-1]!='D') dp[j]=(dp[j]+sum[j-1]-sum[0])%mod;
            }
        }
        
        long long sum=0;
        for (int i=1; i<=len+1; i++)
            sum=(sum+dp[i])%mod;
        printf("%lld\n", (sum+mod)%mod);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1591ms|1224kB|865|G++|2018-08-13 09:19:28