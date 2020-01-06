题目链接：<https://cn.vjudge.net/problem/HDU-1023>

### 题意
卡特兰数的应用之一
求一个长度为n的序列通过栈后的结果序列有几种

### 思路
一开始不知道什么是卡特兰数，猜测是一个递推题
注意到在序列第i个元素入栈时，前几个元素都进过栈，就是通过栈的操作
设n个元素通过栈的结果序列个数为h[n]，则有：
$$ h_n=h_1h_{n-1}+h_2h_{n-2}+...+h_{n-1}h_1 $$
查了以后发现这是卡特兰数的规律，有通项：
$$ h_n=h_{n-1}\frac{4n-2}{n+1} $$  

考虑到又要写高精度算法，想写python，发现没有python，只能先学一下java好了...

### 代码
```java
// Main.java
import java.math.BigInteger;
import java.util.Scanner;

public class Main{
    public static void main(String[] args){
        Scanner cin=new Scanner(System.in);
        
        BigInteger[] num=new BigInteger[100+5];
        num[1]=new BigInteger("1");
        for (int i=2; i<=100; i++){
            Integer tmp1=4*i-2, tmp2=i+1;
            BigInteger a=new BigInteger(tmp1.toString());
            BigInteger b=new BigInteger(tmp2.toString());
            num[i]=num[i-1].multiply(a).divide(b);
        }
        while (cin.hasNext()){
            int n=cin.nextInt();
            System.out.println(num[n]);
        }
    }
}
```

Time|Memory|Length|Lang|Submitted
:-:|:-:|:-:|:-:|:-:
202ms|9892kB|632|Java|2018-02-09 19:18:25