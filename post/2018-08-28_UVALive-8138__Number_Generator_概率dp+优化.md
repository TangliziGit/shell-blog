题目链接：<https://cn.vjudge.net/problem/UVALive-8138>

### 题意
有一个随机数生成器，输出1～n的整数。
现在已经输出了k个数，问再取几个数才能使取出的所有数的个数至少为2。
注意T<=1e5, \sum k<=1e5

### 思路
（听说存在公式？理论上说有了转移方程和边界，公式就是存在
概率dp，注意状态的选取。
设i为出现0次的数的个数，j为出现1次的数的个数。
$$
\begin{align*}
dp(i, j) &= \frac{i}{n}[dp(i-1, j+1)+1]+\frac{j}{n}[dp(i, j-1)+1]+\frac{n-i-j}{n}[dp(i, j)+1] \\ 
dp(i, j) &= \frac{i}{i+j}dp(i-1, j+1)+\frac{j}{i+j}dp(i, j-1)+\frac{n}{i+j}
\end{align*}
$$
$ dp(0, 0)=0 $
实际上，n是可以提出来的，这一点还请注意啊。

### 提交过程
|||
:-|:-
TLE|状态没选对，导致n没提出来
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
const int maxn=3e3+20;
const int INF=0x3f3f3f3f;
double data[maxn][maxn];
int n, k;
double dp(int i, int j){
    if (i==0 && j==0) return 0;
    if (data[i][j]>0) return data[i][j];

    data[i][j]=1;
    if (i>=1) data[i][j]+=i*dp(i-1, j+1);
    if (j>=1) data[i][j]+=j*dp(i, j-1);
    data[i][j]/=(double)(i+j);
    return data[i][j];
}

int main(void){
    int T, tmp;

    scanf("%d", &T);
    while (T--){
        scanf("%d%d", &n, &k);

        int vis[maxn]={0};
        for (int i=0; i<k; i++){
            scanf("%d", &tmp);
            vis[tmp]++;
        }

        int cnt_1=0, cnt_0=0;
        for (int i=1; i<=n; i++){
            if (vis[i]==1) cnt_1++;
            else if (vis[i]==0) cnt_0++;
        }

        printf("%.6f\n", n*dp(cnt_0, cnt_1));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
449ms|None|827|C++ 5.3.0|2018-08-28 13:23:33