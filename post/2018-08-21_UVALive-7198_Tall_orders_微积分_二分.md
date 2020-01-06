题目链接：<https://cn.vjudge.net/problem/UVALive-7198>

### 题意
有悬链线方程$ f(x)=a \cdot cosh(\frac{s}{a}) $，
现有两个电线杆高p，水平距离d，上有电线。
这两个电线杆之间要通火车，这要求电线曲线最低点要离地面高4.2m。
给出p, d问电线长度L最长多少？

### 思路
简单积分题。
首先当然把参数a求出来，这里参数a只能是规定曲线的宽窄（很多人觉得a就是地面距最低点的距离，然而这俩没关系）。
有这样的方程：$ 4.2=p+a-a \cdot cosh(\frac{d}{2a}) $
有了这个方程就可以求a了，为了方便求a，我们可以研究一下函数关于a的单调性。
直接输出值看看得是单调就完事了，但是为了严谨，比赛结束求一下还是好的。
单调函数，这个a二分就好了。

电线长度就只能积分求解：
$$
\begin{aligned}
& 2\int^{\frac{d}{2}}_{0} \sqrt{dx^2+dy^2} \\
& =2\int^{\frac{d}{2}}_{0} \sqrt{1+(\frac{dy}{dx})^2} dx\\
& =\int^{\frac{d}{2}}_{0} \sqrt{4+(e^{\frac{x}{a}}-e^{-\frac{x}{a}})^2} dx\\ 
& =\int^{\frac{d}{2}}_{0} e^{-\frac{x}{a}} \sqrt{e^{\frac{4x}{a}}+2e^{\frac{2x}{a}}+1} dx \\
& =\int^{\frac{d}{2}}_{0} e^{\frac{x}{a}}+e^{-\frac{x}{a}} dx \\
& =a(e^{\frac{d}{2a}}-e^{-\frac{d}{2a}})
\end{aligned}
$$
其中最后一步猜都可以猜出来，高中生水平做这个应该没有大问题。
（当年高二手推悬链线方程-_-，学校里写的研究报告到现在还没有进行评奖...）

### 提交过程
|||
:-|:-
WA|注意向下取整
AC|

### 代码
```cpp
#include <cmath>
#include <cstdio>
#include <cstring>
const double eps2=1e-6, eps=1e-8;
double p, d;
bool equal(double a, double b){
	return (a-b)<eps && (b-a)<eps;
}

double func(double a){
	return a+p-a*cosh(d/(2*a));
}

double func2(double a){
	return a*(exp(d/(2*a))-exp(-1*d/(2*a)));
}

double solve(void){
	double l=1, r=1e4;

	while (l<r){
		double mid=(l+r)/2;
		if (func(mid)<4.2) l=mid;
		else r=mid;

		if (r-l<eps2) return r;
	}
}

int main(void){
	while (scanf("%lf", &p)==1){
		if (equal(p, -1)) break;
		scanf("%lf", &d);

		double a=solve();
		printf("%0.3lf\n", floor((func2(a)*1000))/(double)1000);
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
None|None|835|C++ 5.3.0|2018-08-20 03:38:48