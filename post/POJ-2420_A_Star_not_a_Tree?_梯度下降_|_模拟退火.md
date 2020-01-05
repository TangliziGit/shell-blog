题目链接：<https://cn.vjudge.net/problem/POJ-2420>

### 题意
给出n个点，找一个点，使得这个点到其余所有点距离之和最小。

### 思路
一开始就在抖机灵考虑梯度下降，猜测是个凸优化问题，完全在抖机灵。
最后实在是没得其他思路了，看了看题解。
居然是模拟退火，而且写的貌似没有随机这个因素，完全是爬山法好吧？
梯度下降，复杂度O(60000n)

### 提交过程
|||
:-|:-
WA|偏导方程没给对
AC|其实maxEpoch没必要这么大，只要发现多次best值更新小于1即可退出循环

### 代码
```cpp
#include <cmath>
#include <cstdio>
#include <cstring>
#include <algorithm>
using namespace std;
const double learningRate=1.4, step=1;
const int maxEpoch=60000, maxn=100+20;
double nx[maxn], ny[maxn];
int n;
struct Point{
    double x, y;
    Point(double x, double y):x(x), y(y) {}
};
double getDis(int ax, int ay, int bx, int by){
    return sqrt((ax-bx)*(ax-bx)+(ay-by)*(ay-by));
}

double criter(Point p){
    double dis=0;
    for (int i=0; i<n; i++)
        dis+=getDis(p.x, p.y, nx[i], ny[i]);
    return dis;
}

double SGD(void){
    double x=0.5e4, y=0.5e4, best;
    for (int epoch=0; epoch<=maxEpoch; epoch++){
        double base=criter(Point(x, y));
        double dx=(criter(Point(x+step, y))-base)/step;
        double dy=(criter(Point(x, y+step))-base)/step;

        x-=dx*learningRate;
        y-=dy*learningRate;
        if (epoch==0) best=base;
        else best=min(best, base);

        // if ((epoch+1)%1000==0)
        //     printf("%.3f,%.3f %.3fbase %.3fbest\n", dx, dy, base, best);
    }return criter(Point(x, y));
}

int main(void){
    while (scanf("%d", &n)==1 && n){
        for (int i=0; i<n; i++) scanf("%lf%lf", &nx[i], &ny[i]);
        printf("%.0f\n", SGD());
    }

    return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
563ms|400kB|1221|G++|2018-08-09 04:36:51