题目链接：<https://cn.vjudge.net/problem/UVALive-8078>

### 题意
括号序列T是这样定义的：
1. T是个空的
2. T是(T), {T}, <T> 或者 [T]
3. T是两个T组成的，比如()()就是一个T
  
现在给一个n个字符长的串，问以每个字符为左端点的最长括号序列是多长。

### 思路
显然对i这个地方可以讨论一下：
如果i是个右括号，答案是0。
如果i是个左括号：
如果以i+1为起点的最长串后边的字符与左括号匹配，答案是加上这个字符后边的最长串。
如果不匹配，答案是0。
细节上注意不要越界即可，边界是dp[strlen]=0

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=2e5;
char str[maxn];
int sign[300], ans[maxn];

int main(void){
    int T, kase=0;

    sign['(']=1;
    sign['{']=2;
    sign['[']=3;
    sign['<']=4;
    sign[')']=-1;
    sign['}']=-2;
    sign[']']=-3;
    sign['>']=-4;
    scanf("%d", &T);
    while (T--){
        scanf("%s", str);

        memset(ans, 0, sizeof(ans));
        int len=strlen(str);
        for (int i=len; i>=0; i--){
            int elem=sign[str[i]];
            
            if (elem<0) ans[i]=0;
            else{
                if (i+1<len && sign[str[i+1]]==elem*-1) ans[i]=2+ans[i+2];
                else if (i+1<len){
                    int nxt=sign[str[ans[i+1]+i+1]];
                    // printf("%d %d --\n", nxt, elem);
                    if (nxt==elem*-1) ans[i]=ans[i+1]+2+ans[i+ans[i+1]+2];
                    else ans[i]=0;
                }else if (i+1>=len) ans[i]=0;
            }
        }

        printf("Case %d:\n", ++kase);
        for (int i=0; i<len; i++)
            printf("%d\n", ans[i]);
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
49ms|None|1116|C++ 5.3.0|2018-08-24 11:28:32