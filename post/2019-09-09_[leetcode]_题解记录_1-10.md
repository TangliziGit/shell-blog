博客园markdown太烂, 题解详见<https://github.com/TangliziGit/leetcode/blob/master/solution/1-10.md>
# Leetcode Solution 0~10

> marks:  
> @: hard to get a direct solution  
> %: need optimization  

### 好题
@@@@@ 4. Median of Two Sorted Arrays [Hard]  
% 5. Longest Palindromic Substring [Medium]  
@ 10. Regular Expression Matching [Hard]  

### 总结
1. map用法: put, get, containsKey, remove
2. 声明数组new int[]{1, 2};
3. 异常情况还需要返回值的话, 抛IllegalArgumentException
1. Set的用法: add, contains, remove
2. 数组填充: Arrays.fill(arr, -1);
1. java中有int的最大值, Integer.MAX_VALUE
2. int+String的形式可以进行运算, 因为自动装箱(auto-boxing)
1. StringBuilder用法: append, toString
1. 反转字符串需要StringBuilder.reverse()
1. 利用java对象默认值是null, 可以避免初始化
2. 事实上java基本类型中的数值默认值都是0, char的默认值是'\u0000'是空字符


<hr>
<details>
<summary>1. Two Sum [Easy]</summary>

## 1. Two Sum [Easy] 

###  思路
水题

### 要点
1. map用法: put, get, containsKey, remove
2. 声明数组new int[]{1, 2};
3. 异常情况还需要返回值的话, 抛IllegalArgumentException

### 代码

```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map=new HashMap();
        
        for (int i=0; i<nums.length; i++){
            int tmp=target-nums[i];
            if (map.containsKey(tmp)){
                int idx=map.get(tmp);
                if (i!=idx) return new int[]{idx, i};
            }map.put(nums[i], i);
        }
        throw new IllegalArgumentException();
    }
}
```  


</details>




<details>
<summary>2. Add Two Numbers [Medium]  </summary>

## 2. Add Two Numbers [Medium]

###  思路
水题

### 要点
无

### 代码

```java
class Solution {
    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        ListNode head=null, tail=null, prev=null;
        int tmp=0;
        while (l1!=null || l2!=null || tmp!=0){
            int val=(tmp+ 
                 ((l1!=null)?l1.val:0) + 
                 ((l2!=null)?l2.val:0)
            );
            tail=new ListNode(val%10);
            tmp=val/10;
            
            if (prev==null) head=tail;
            if (prev!=null) prev.next=tail;
            prev=tail;
            if (l1!=null) l1=l1.next;
            if (l2!=null) l2=l2.next;
        }
        
        return head;
    }
    
}
```
</details>




<details>
<summary>3. Longest Substring Without Repeating Characters [Medium]</summary>

##  3. Longest Substring Without Repeating Characters [Medium]
###  思路
双指针

### 要点
1. Set的用法: add, contains, remove
2. 数组填充: Arrays.fill(arr, -1);

### 代码

```java
class Solution {
    public int lengthOfLongestSubstring(String s) {
        int[] map=new int[128];
        int pre=0, pos=0, maxlen=0, len=s.length();
        
        Arrays.fill(map, -1);
        for (int i=0; i<len; i++){
            char ch=s.charAt(i);
            if (map[ch]>=pos) pos=map[ch]+1;
            map[ch]=i;
            
            pre++;
            maxlen=Math.max(maxlen, pre-pos);
        }return maxlen;
    }
}

```
</details>




<details>
<summary>4. Median of Two Sorted Arrays [Hard] </summary>

## @@@@@ 4. Median of Two Sorted Arrays [Hard] 
###  思路
非常好的一道题

1. 第一个思路是二分中位数, 同时树状数组查小于此数的数字个数, 当等于(n+m)/2时就是中位数, 这样O(log^2(n+m))
但想到没有给数据范围, 于是树状数组不太好直接存数, 得离散化然后存, 不然数组可能开不下

2. 第二个思路是二分中位数, 同时二分两个数组查小于此数的数字个数, 当等于(n+m)/2时就是中位数, 这样O(log(n+m)(log(n)+log(m)))
优点是不用离散化, 但同时复杂度更差了

3. **题解思路**:
  - 首先考虑寻找第k个数的算法, 那么中位数就是他俩除二
  - 其次考虑每次寻找各序列中aMid=a[i+k/2-1]这个数
    若aMid<bMid, 说明a中[0, aMid]和[bMid, m-1]之间是没有第k值的
    显然可以分治

### 要点
1. java中有int的最大值, Integer.MAX_VALUE
2. int+String的形式可以进行运算, 因为自动装箱(auto-boxing)

### 代码

```java
class Solution {
    private int[] a, b;
    
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        this.a=nums1; this.b=nums2;
        int n=nums1.length, m=nums2.length;
        
        if (n==0 && m==0) return 0;
        int left=findKth(0, 0, (n+m-1)/2+1), right=findKth(0, 0, (n+m)/2+1);
        return (left+right)/(double)2;
    }
    
    public int findKth(int ai, int bi, int k){
        if (bi>=b.length) return a[ai+k-1];
        if (ai>=a.length) return b[bi+k-1];
        if (k==1) return Math.min(a[ai], b[bi]);
        
        int aMid=Integer.MAX_VALUE, bMid=Integer.MAX_VALUE;
        if (ai+k/2-1<a.length) aMid=a[ai+k/2-1];
        if (bi+k/2-1<b.length) bMid=b[bi+k/2-1];
        
        if (aMid<bMid)
            return findKth(ai+k/2, bi, k-k/2);
        else return findKth(ai, bi+k/2, k-k/2);
    }
}
```


</details>




<details>
<summary> 5. Longest Palindromic Substring [Medium] </summary>

##  % 5. Longest Palindromic Substring [Medium]
###  思路
manacher模板

### 要点
1. 注意 s==null || s.length()==0
2. manacher O(n)

### 代码

O(n^2) version
```java
class Solution {
    public String longestPalindrome(String s) {
        if (s==null || s.length()==0) return "";
        int start=0, end=0;
        for (int i=0; i<s.length(); i++){
            int len=Math.max(
                check(i, i, s),
                check(i, i+1, s)
            );
            
            if (end-start<len){
                start=i-(len-1)/2;
                end=i+len/2;
            }
        }
        
        return s.substring(start, end+1);
    }
    
    private int check(int i, int j, String s){
        while (i>=0 && j<s.length() && s.charAt(i)==s.charAt(j)){
            i--; j++;
        }return j-i-1;
    }
}
```

O(n) version
```java
class Solution {
    private char[] str;
    public String longestPalindrome(String s) {
        if (s==null || s.length()==0) return "";
        return manacher(s);
    }
    
    public String manacher(String s){
        str=new char[2*s.length()+5];
        str[0]='#';
        for (int i=0; i<s.length(); i++){
            str[(i<<1)+1]=s.charAt(i);
            str[(i<<1)+2]='#';
        }
        
        int n=2*s.length()+1;
        int mr=-1, mid=-1, maxRad=0, maxRadIdx=0;
        int[] rad=new int[str.length];
        for (int i=0; i<str.length; i++){
            if (mr>i) rad[i]=Math.min(rad[2*mid-i], mr-i);
            else rad[i]=1;
            
            while (i-rad[i]>=0 && i+rad[i]<n && str[i+rad[i]]==str[i-rad[i]]) rad[i]++;
            if (rad[i]+i>mr){
                mr=rad[i]+i; mid=i;
            }
            if (maxRad<rad[i]){
                maxRad=rad[i]; maxRadIdx=i;
            }
        }
        
        if (maxRadIdx%2==1)
            return s.substring(maxRadIdx/2-(maxRad/2-1), maxRadIdx/2+(maxRad/2-1)+1);
        else return s.substring((maxRadIdx/2-1)-(maxRad/2-1), maxRadIdx/2+(maxRad/2-1)+1);
    }
}
```

</details>




<details>
<summary>6. ZigZag Conversion [Medium] </summary>

##  6. ZigZag Conversion [Medium]
###  思路
找规律模拟即可

### 要点
1. StringBuilder用法: append, toString

### 代码

```java
class Solution {
    public String convert(String s, int numRows) {
        StringBuilder ans=new StringBuilder("");
        int len=s.length();
        if (numRows==1) return s;
        
        for (int x=0; x<len; x+=2*numRows-2)
            ans.append(s.charAt(x));
        for (int y=1; y<numRows-1; y++)
            for (int x=0; x+y<len; x+=2*numRows-2){
                ans.append(s.charAt(x+y));
                if (x+y +2*numRows-2-2*y<len)
                    ans.append(s.charAt(x+y +2*numRows-2-2*y));
            }
        for (int x=numRows-1; x<len; x+=2*numRows-2)
            ans.append(s.charAt(x));
        
        return ans.toString();
    }
}
```

</details>




<details>
<summary>7. Reverse Integer [Easy] </summary>

##  7. Reverse Integer [Easy]
###  思路
水题

### 要点

### 代码

```java
class Solution {
    public int reverse(int x) {
        if (x<0) return -1*solve(-1*x);
        return solve(x);
    }
    
    private int solve(int x){
        long res=0;
        while (x!=0){
            res=res*10+x%10;
            x/=10;
        }
        if (res<-(long)1<<31 || res>=(long)1<<31) return 0;
        return (int)res;
    }
}

```


</details>




<details>
<summary> 8.String to Integer (atoi)[Medium]</summary>

##   % 8.String to Integer (atoi)[Medium]
###  思路
垃圾模拟题

### 要点
考虑正则匹配

### 代码

```java
class Solution {
    public int myAtoi(String str) {
        int sign=1, i=0, ans=0;
        str = str.trim();
        if (str.isEmpty()) return 0;
        else if (str.charAt(i)=='+') i++;
        else if (str.charAt(i)=='-') {i++; sign=-1;}

        while (i<str.length() && Character.isDigit(str.charAt(i))) {
            int ch=str.charAt(i)-'0';
            if (ans>(Integer.MAX_VALUE-ch)/10)
                return sign>0?Integer.MAX_VALUE:Integer.MIN_VALUE;
            ans=ans*10+ch;
            i++;
        }
        return sign*ans;
    }
}
```

</details>




<details>
<summary> 9. Palindrome Number [Easy]</summary>

##  9. Palindrome Number [Easy]
###  思路
水题

### 要点
1. 反转字符串需要StringBuilder.reverse()

### 代码

```java
class Solution {
    public boolean isPalindrome(int x) {
        StringBuilder ori=new StringBuilder(String.valueOf(x));
        ori.reverse();
        return ori.toString().equals(String.valueOf(x));
    }
}
```

</details>




<details>
<summary>10. Regular Expression Matching [Hard]</summary>

## @ 10. Regular Expression Matching [Hard]
###  思路
有点类似正则匹配的图, 画一个类似nfa一样的自动机可以发现是个dp, 模板串的状态用j表示, 那么待匹配串状态用i

### 要点
1. 利用java对象默认值是null, 可以避免初始化
2. 事实上java基本类型中的数值默认值都是0, char的默认值是'\u0000'是空字符

### 代码

```java
class Solution {
    enum Result{
        TRUE, FALSE
    }
    
    private Result[][] res;
    private String s, p;
    public boolean isMatch(String s, String p) {
        this.s=s; this.p=p;
        res=new Result[s.length()+1][p.length()+1];
        
        return dp(0, 0);
    }
    
    private boolean dp(int i, int j){
        if (j==p.length()) return i==s.length();
        if (res[i][j]!=null) return res[i][j]==Result.TRUE;
        
        boolean match=(
            i<s.length() &&
            (s.charAt(i)==p.charAt(j) || p.charAt(j)=='.')
        ), tmp;
        if (p.length()>j+1 && p.charAt(j+1)=='*')
            tmp=(dp(i, j+2) || (match && dp(i+1, j)));
        else
            tmp=(match && dp(i+1, j+1));
        
        res[i][j]=tmp?Result.TRUE:Result.FALSE;
        return tmp;
    }
}
```

</details>