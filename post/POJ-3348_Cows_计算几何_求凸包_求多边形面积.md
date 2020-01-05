题目链接：<https://cn.vjudge.net/problem/POJ-3348>

### 题意
啊模版题啊
求凸包的面积，除50即可

### 思路
求凸包的面积，除50即可

### 提交过程
|||
:-|:-
AC|

### 代码
```cpp
#include <cmath>
#include <cstdio>
#include <vector>
#include <algorithm>
using namespace std;
const double eps=1e-10;
struct Point{
	double x, y;

	Point(int x=0, int y=0):x(x), y(y) {}
	// no known conversion for argument 1 from 'Point' to 'Point&'
	Point operator + (Point p){return Point(x+p.x, y+p.y);}
	Point operator - (Point p){return Point(x-p.x, y-p.y);}
	Point operator * (double k){return Point(k*x, k*y);}
	Point operator / (double k){return Point(x/k, y/k);}
	bool operator < (Point p) const{return (x==p.x)?(y<p.y):(x<p.x);}	// need eps?
	bool operator == (const Point p) const{return fabs(x-p.x)<eps&&fabs(y-p.y)<eps;}
	double norm(void){return x*x+y*y;}
	double abs(void){return sqrt(norm());}
	double dot(Point p){return x*p.x+y*p.y;}		// cos
	double cross(Point p){return x*p.y-y*p.x;}		// sin
};
struct Segment{Point p1, p2;};
struct Circle{Point o; double rad;};
typedef Point Vector;
typedef vector<Point> Polygon;
typedef Segment Line;

int ccw(Point p0, Point p1, Point p2){
	Vector v1=p1-p0, v2=p2-p0;
	if (v1.cross(v2)>eps) return 1;			// anti-clockwise
	if (v1.cross(v2)<-eps) return -1;		// clockwise
	if (v1.dot(v2)<0) return 2;
	if (v1.norm()<v2.norm()) return -2;
	return 0;
}

Point project(Segment s, Point p){
	Vector base=s.p2-s.p1;
	double k=(p-s.p1).cross(base)/base.norm();
	return s.p1+base*k;
}

Point reflect(Segment s, Point &p){
	return p+(project(s, p)-p)*2;
}

double lineDist(Line l, Point p){
	return abs((l.p2-l.p1).cross(p-l.p1)/(l.p2-l.p1).abs());
}

double SegDist(Segment s, Point p){
	if ((s.p2-s.p1).dot(p-s.p1)<0) return Point(p-s.p1).abs();
	if ((s.p1-s.p2).dot(p-s.p2)<0) return Point(p-s.p2).abs();
	return abs((s.p2-s.p1).cross(p-s.p1)/(s.p2-s.p1).abs());
}

bool intersect(Point p1, Point p2, Point p3, Point p4){
	return ccw(p1, p2, p3)*ccw(p1, p2, p4)<=0 &&
			ccw(p3, p4, p1)*ccw(p3, p4, p2)<=0;
}

Point getCrossPoint(Segment s1, Segment s2){
	Vector base=s2.p2-s2.p1;
	double d1=abs(base.cross(s1.p1-s2.p1));
	double d2=abs(base.cross(s1.p2-s2.p1));
	double t=d1/(d1+d2);
	return s1.p1+(s1.p2-s1.p1)*t;
}

double area(Polygon poly){
	double res=0; long long size=poly.size();
	for (int i=0; i<poly.size(); i++)
		res+=poly[i].cross(poly[(i+1)%size]);
	return abs(res/2);
}

int contain(Polygon poly, Point p){
	int n=poly.size();
	bool flg=false;
	for (int i=0; i<n; i++){
		Point a=poly[i]-p, b=poly[(i+1)%n]-p;
		if (ccw(poly[i], poly[(i+1)%n], p)==0) return 1;	// 1 means on the polygon.
		if (a.y>b.y) swap(a, b);
		if (a.y<0 && b.y>0 && a.cross(b)>0) flg=!flg;
	}return flg?2:0;										// 2 fo inner, 0 for outer.
}

Polygon convexHull(Polygon poly){
	if (poly.size()<3) return poly;
	Polygon upper, lower;
	sort(poly.begin(), poly.end());
	upper.push_back(poly[0]); upper.push_back(poly[1]);
	lower.push_back(poly[poly.size()-1]); lower.push_back(poly[poly.size()-2]);
	for (int i=2; i<poly.size(); i++){
		for (int n=upper.size()-1; n>=1 && ccw(upper[n-1], upper[n], poly[i])!=-1; n--)
			upper.pop_back();
		upper.push_back(poly[i]);
	}
	for (int i=poly.size()-3; i>=0; i--){
		for (int n=lower.size()-1; n>=1 && ccw(lower[n-1], lower[n], poly[i])!=-1; n--)
			lower.pop_back();
		lower.push_back(poly[i]);
	}
	for (int i=1; i<lower.size(); i++)
		upper.push_back(lower[i]);
	return upper;
}

int main(void){
	int n;
	double x, y;

	while (scanf("%d", &n)==1 && n){
		Polygon poly, hull;
		for (int i=0; i<n; i++){
			scanf("%lf%lf", &x, &y);
			poly.push_back(Point(x, y));
		}
		printf("%d\n", (long long)area(convexHull(poly))/50);
	}

	return 0;
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
608kB|3526|G++|2018-08-01 17:22:02