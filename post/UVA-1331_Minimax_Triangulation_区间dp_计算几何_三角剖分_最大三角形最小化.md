题目链接：<https://cn.vjudge.net/problem/UVA-1331>

### 题意
给一个任意多边形，把它分为多个三角形。
求某方案中最大的三角形是各方案中最小的面积的三角形面积。

### 思路
学了三角剖分了，看到这题可以顺手写下状态，转移方程可以观察目标函数（单个三角形面积）得出。
$$ dp[i][j] = min(dp[i][j], max(Area[i][k][j], dp[i][k], dp[k][j]) ) $$
还有一个关键点，就是判断选定的三角形是否可行。
本题里如果选定的三角包含了某点，就算是不可行的。
具体图见[uva 1331 - Minimax Triangulation(dp) @JeraKrs](https://blog.csdn.net/keshuai19940722/article/details/25040479)

### 提交过程
|||
:-|:-
WA|修改double INF=1e9，还有一块向量的计算写错j和k

### 代码
```cpp
#include <cmath>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const int maxn=50+20;
const double eps=1e-8, INF=1e9;
struct Vector{
    double x, y;

    Vector(int x=0, int y=0):x(x), y(y) {}
    // no known conversion for argument 1 from 'Vector' to 'Vector&'
    Vector operator + (Vector p){return Vector(x+p.x, y+p.y);}
    Vector operator - (Vector p){return Vector(x-p.x, y-p.y);}
    Vector operator * (double k){return Vector(k*x, k*y);}
    Vector operator / (double k){return Vector(x/k, y/k);}
    bool operator < (Vector p) const{return (x==p.x)?(y<p.y):(x<p.x);}
    bool operator == (const Vector p) const{return fabs(x-p.x)<eps&&fabs(y-p.y)<eps;}
    double norm(void){return x*x+y*y;}
    double abs(void){return sqrt(norm());}
    double dot(Vector p){return x*p.x+y*p.y;}
    double cross(Vector p){return x*p.y-y*p.x;}
};

int x[maxn], y[maxn], n, T;
double data[maxn][maxn];
bool equal(double a, double b){
    return (a-b)<=eps && (b-a)<=eps;
}

double area(int i, int k, int j){
    Vector va(x[i]-x[j], y[i]-y[j]), vb(x[i]-x[k], y[i]-y[k]),
           vc(x[j]-x[k], y[j]-y[k]);
    double ans=abs(va.cross(vb));
    for (int idx=0; idx<n; idx++) if (idx!=i && idx!=k && idx!=j){
        double sum=0;
        Vector vec1(x[idx]-x[i], y[idx]-y[i]),
            vec2(x[idx]-x[j], y[idx]-y[j]);
        sum+=abs(vec1.cross(va));
        sum+=abs(vec1.cross(vb));
        sum+=abs(vec2.cross(vc));
        if (equal(sum, ans)) return INF;
    }return ans/2.0;
}

double dp(int i, int j){
    if (i+1==j) return 0;
    if (data[i][j]>0) return data[i][j];

    data[i][j]=INF;
    for (int k=i+1; k<=j-1; k++)
        data[i][j]=min(data[i][j], 
                max(area(i, k, j), max(dp(i, k), dp(k, j))));
    // printf("%d, %d: %.1f\n", i, j, data[i][j]);
    return data[i][j];
}

int main(void){
    scanf("%d", &T);
    while (T--){
        scanf("%d", &n);
        for (int i=0; i<n; i++) scanf("%d%d", &x[i], &y[i]);
        for (int i=0; i<n; i++)
            for (int j=0; j<n; j++) data[i][j]=-1;
        printf("%.1f\n", dp(0, n-1));

        // int i, k, j;
        // while (scanf("%d%d%d", &i, &k, &j)==3)
        //     printf("%.1f\n", area(i, k, j));
    }

    return 0;
}

```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
10ms|None|2245|C++ 5.3.0|2018-08-08 08:00:44