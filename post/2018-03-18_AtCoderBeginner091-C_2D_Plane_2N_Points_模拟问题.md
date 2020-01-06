题目链接：<https://abc091.contest.atcoder.jp/tasks/arc092_a>

### 题意
On a two-dimensional plane, there are N red points and N blue points. The coordinates of the i-th red point are (ai,bi), and the coordinates of the i-th blue point are (ci,di).
A red point and a blue point can form a friendly pair when, the x-coordinate of the red point is smaller than that of the blue point, and the y-coordinate of the red point is also smaller than that of the blue point.
At most how many friendly pairs can you form? Note that a point cannot belong to multiple pairs.

### 思路
简单模拟
注意顺序，考虑下面的数据
2
1 2
3 1
2 4
4 3

### 代码
```cpp
    #include <cstdio>
    #include <cstring>
    #include <algorithm>
    using namespace std;
    const int maxn=200;
    struct Point{
        int x, y;
        Point(int x=0, int y=0):x(x), y(y) {}
        bool operator < (const Point &a) const{
            return y<a.y;
        }
    }point[maxn+5];
    int n;
    bool map[maxn+5][maxn+5];
     
    int main(void){
        scanf("%d", &n);
        for (int i=0, a, b; i<n; i++){
            scanf("%d%d", &a, &b);
            map[b][a]=true;
        }
     
        int cnt=0;
        for (int i=0, a, b; i<n; i++){
            scanf("%d%d", &a, &b);
            point[i]=Point(a, b);
        }sort(point, point+n);
        for (int i=0; i<n; i++){
            int a=point[i].x, b=point[i].y;
            bool ifbreak=false;
            for (int x=a-1; x>=0; x--){
                for (int y=b-1; y>=0; y--)
                    if (map[y][x]) {cnt++; map[y][x]=false; ifbreak=true; break;}
                if (ifbreak) break;
            }
        }printf("%d\n", cnt);
     
        return 0;
    }
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
1 ms|256KB|937 Byte|C++14 (GCC 5.4.1)|2018/03/17 21:21:32