博客园markdown太烂, 题解详情<https://github.com/TangliziGit/leetcode/blob/master/solution/11-20.md>

# Leetcode Solution 11~20

> marks:  
> @: hard to get a direct solution  
> %: need optimization  

### 好题
%%% 11. Container With Most Water[Medium]  
%%%%% 15. 3Sum[Medium]  
%%% 16. 3Sum Closest [Medium]  
% 18. 4Sum [Medium]  


### 总结
1. 初始化Stream: Stream.of(), Stream.iterate(0, x->x+1).limit(max)
2. map: mapToInt(x -> ...), ...
3. filter: filter(x -> ...)
4. ending: reduce(Integer::min), findFirst()
5. process: getAsInt(), orElse()
1. **排序两边夹原理**  
设z=x+y;  
 if (z>tar) y<-; else x->;  
作用：O(n)二元找x+y==z相等（一元找x==z相等用二分）  
2. HashSet, HashMap 耗时严重 n次O(1)多花300ms
1. 数组排序: Arrays.sort(nums)
1. LinkedList方法: add
2. 初始化List<X>: Arrays.asList(X, X, X, ...)
1. Stack用法: push(), peek(), pop(), isEmpty()
1. int[] to List<int>:
  ```java
    Arrays.sort(arr);
    Arrays.stream(arr).boxed().collect(Collectors.toList());
  ```


<hr>

<details>
<summary>11. Container With Most Water[Medium]</summary>

## %%% 11. Container With Most Water[Medium]
###  思路
1. O(n^2)
2. 树状数组从后向前区间更新最高高度（覆盖），然后从前遍历；再反向计算，取最大值 O(nlogn)
3. 二叉搜索树 O(nlogn)
4. 双指针,两边夹 O(n)  
  首先考虑一个解[i,j], 我们需要确定这个范围内解的最大值  
  在范围减小时, 要使解更大, 唯一的优势就是墙壁高度  
  所以每次更新时, 贪心的保护最高墙壁  
  暂时只能这样解释了...  

### 要点
无

### 代码

```java
class Solution {
    public int maxArea(int[] height) {
        int l=0, r=height.length-1, ans=0;
        while (l<r){
            int area=Math.min(height[l], height[r])*(r-l);
            ans=Math.max(ans, area);
            if (height[l]<height[r]) l++;
            else r--;
        }return ans;
    }
}
```

</details>


<details>
<summary>12. Integer to Roman[Medium]</summary>

## 12. Integer to Roman[Medium]
###  思路
水题, 注意题意

### 要点
无

### 代码

```java
class Solution {
    private static String ans[]=new String[(int)4e3];
    private static Integer[] value={
        1, 4, 5, 9, 10,
        40, 50, 90, 100,
        400, 500, 900, 1000};
    private static String[] expr={
        "I", "IV", "V", "IX", "X",
        "XL", "L", "XC", "C",
        "CD", "D", "CM", "M"};
    
    public String intToRoman(int num) {
        return solve(num, value.length-1);
    }

    public String solve(int n, int ptr){
        if (ptr==-1) return "";
        if (ans[n]!=null) return ans[n];
        ans[n]=repeat(expr[ptr], n/value[ptr])+
            solve(n%value[ptr], ptr-1);
        return ans[n];
    }
    
    public String repeat(String s, int n){
        return new String(new char[n]).replace("\0", s);
    }
}
```

</details>


<details>
<summary>13. Roman to Integer [Easy]</summary>

## 13. Roman to Integer [Easy]
###  思路
水题, 注意题意

### 要点
无

### 代码

```java
class Solution {
    private static Map<Character, Integer> map=new HashMap();
    
    static{
        map.put('I', 1);
        map.put('V', 5);
        map.put('X', 10);
        map.put('L', 50);
        map.put('C', 100);
        map.put('D', 500);
        map.put('M', 1000);
    };
    
    public int romanToInt(String s) {
        int ans=0, len=s.length();
        for (int i=0; i<len; i++)
            if (i+1<len && map.get(s.charAt(i))<map.get(s.charAt(i+1)))
                ans-=map.get(s.charAt(i));
            else 
                ans+=map.get(s.charAt(i));
        return ans;
    }
}
```

</details>


<details>
<summary>14. Longest Common Prefix [Easy]</summary>

## 14. Longest Common Prefix [Easy]
###  思路
水题  
刚好用来写Stream

### 要点
1. 初始化Stream: Stream.of(), Stream.iterate(0, x->x+1).limit(max)
2. map: mapToInt(x -> ...), ...
3. filter: filter(x -> ...)
4. ending: reduce(Integer::min), findFirst()
5. process: getAsInt(), orElse()

### 代码

```java
// Stream version
// 47ms, 38MB
class Solution {
    public String longestCommonPrefix(String[] strs) {
        if (strs==null || strs.length==0) return "";
        int minlen=Stream.of(strs)
            .mapToInt(x -> x.length())
            .reduce(Integer::min)
            .getAsInt();
        int idx=Stream.iterate(0, x -> x+1).limit(0+minlen)
            .filter(x -> check(strs, x))
            .findFirst()
            .orElse(minlen);
        
        return strs[0].substring(0, idx);
    }
    
    public boolean check(String[] strs, int idx){
        return Stream.of(strs)
            .anyMatch(x -> x.charAt(idx)!=strs[0].charAt(idx));
    }
}

// Original
// 4ms, 39MB
class OriginalSolution {
    public String longestCommonPrefix(String[] strs) {
        if (strs==null || strs.length==0) return "";
        int idx=0, minlen=strs[0].length();
        for (String str: strs)
            minlen=Math.min(minlen, str.length());
        for (;idx<minlen; idx++)
            if (check(strs, idx)) break;
        return strs[0].substring(0, idx);
    }
    
    public boolean check(String[] strs, int idx){
        for (String str: strs)
            if (str.charAt(idx)!=strs[0].charAt(idx))
                return true;
        return false;
    }
}
```

</details>


<details>
<summary>15. 3Sum[Medium]</summary>

## %%%%% 15. 3Sum[Medium]
###  思路
1. O(n^3)
2. O(n^2logn): for^2 + binarySearch
3. O(n^2+nlogn+n) with a big constant:  
     取得两项和的map，然后遍历，最后去重  
4. O(n^2+nlogn+2n) with a small constant:  
     排序，得一个元素的对应下标map，若重复取最后  
     for^2 查找，插入HashSet  
5. O(n^2) with a smaller constant:  
     for x: 两边夹找y+z==-x  
     
### 要点
1. **排序两边夹原理**
设z=x+y;
 if (z>tar) y<-; else x->;
作用：O(n)二元找x+y==z相等（一元找x==z相等用二分）

2. HashSet, HashMap 耗时严重 n次O(1)多花300ms

### 代码

O(n^3) version
```java
class Solution{
    public List<List<Integer>> threeSum(int[] nums) {
        LinkedList<List<Integer>> ans=new LinkedList();
        
        Arrays.sort(nums);
        for (int i=0; i<nums.length; i++)
            if (i==0 || nums[i]!=nums[i-1]){
                int l=i+1, r=nums.length-1;
                while (l<r){
                    int sum=nums[l]+nums[r];
                    if (sum==-nums[i]){
                        ans.add(Arrays.asList(nums[i], nums[l], nums[r]));
                        while (l<r && nums[l]==nums[l+1]) l++;
                        while (l<r && nums[r]==nums[r-1]) r--;
                    }
                    if (sum>-nums[i]) r--;
                    else l++;
                }
            }
        return ans;
    } 
}
```

O(n^2+nlogn+n) with a small constant
```java
class Solution{
    public List<List<Integer>> threeSum(int[] nums) {
        Map<Integer, Integer> map=new HashMap();
        Set<List<Integer>> set=new HashSet();
        LinkedList<List<Integer>> ans=new LinkedList();
        
        Arrays.sort(nums);
        // if duplicated, use the last one
        for (int i=0; i<nums.length; i++)
            map.put(nums[i], i);
        
        for (int i=0; i<nums.length; i++)
            for (int j=i+1; j<nums.length; j++){
                int sum=nums[i]+nums[j];
                if (!map.containsKey(-sum)) continue;
                if (map.get(-sum)<=j) continue;
                set.add(Arrays.asList(nums[i], nums[j], nums[map.get(-sum)]));
            }
        
        for (List list: set)
            ans.add(list);
        return ans;
    }
}
```

O(n^2+nlogn) solution
```java
class Solution {
    
    public List<List<Integer>> threeSum(int[] nums) {
        Map<Integer, List<Pair>> map=new HashMap();
        Set<List<Integer>> set=new HashSet();
        ArrayList<List<Integer>> ans=new ArrayList();
        
        Arrays.sort(nums);
        for (int i=0; i<nums.length; i++){
            for (int j=i+1; j<nums.length; j++){
                int sum=nums[i]+nums[j];
                if (!map.containsKey(sum))
                    map.put(sum, new LinkedList<Pair>());       // O(1)
                
                List<Pair> list=map.get(sum);                   // O(1)
                list.add(new Pair(i, j));                       // O(1)?
            }
        }
        
        for (int i=0; i<nums.length; i++){
            if (!map.containsKey(-nums[i])) continue;
            for (Pair pair: map.get(-nums[i]))
                if (i>pair.y && i!=pair.x && i!=pair.y){
                    set.add(Arrays.asList(nums[pair.x], nums[pair.y], nums[i]));
                }
        }
        
        
        for (List<Integer> list: set)
            ans.add(list);
        
        return ans;
    }
    
    static class Pair{
        final int x, y;
        Pair(int x, int y){
            this.x=x;
            this.y=y;
        }
    }
}
```

</details>


<details>
<summary>16. 3Sum Closest [Medium]</summary>

## %%% 16. 3Sum Closest [Medium]
###  思路
1. O(n^3)
2. O(n^2logn) 二分
3. O(n^2) 双指针, 两边夹求最近, 因为这三道题都是双指针, 所以有点会用了

### 要点
1. 数组排序: Arrays.sort(nums)

### 代码

```java
class Solution {
    public int threeSumClosest(int[] nums, int target) {
        int ans=nums[0]+nums[1]+nums[2];
        Arrays.sort(nums);
        for (int i=0; i<nums.length; i++){
            int l=i+1, r=nums.length-1;
            while (l<r){
                int sum=nums[i]+nums[l]+nums[r];
                if (Math.abs(sum-target)<Math.abs(ans-target))
                    ans=sum;
                if (sum<target) l++;
                else r--;
            }
        }return ans;
    }
}
```

</details>


<details>
<summary>17. Letter Combinations of a Phone Number [Medium]</summary>

## 17. Letter Combinations of a Phone Number [Medium]
###  思路
水题, 递归

### 要点
1. LinkedList方法: add
2. 初始化List<X>: Arrays.asList(X, X, X, ...)

### 代码

```java
class Solution {
    private String template="abcdefghijklmnopqrstuvwxyz";
    
    public List<String> letterCombinations(String digits) {
        if (digits.equals("")) return new ArrayList<String>();
        return solve(digits, 0);
    }
    
    private List<String> solve(String digits, int ptr){
        if (ptr==digits.length()) return Arrays.asList("");
        List<String> tmp=solve(digits, ptr+1), ans=new LinkedList();
        int num=digits.charAt(ptr)-'2', n=(num+2==9||num+2==7)?4:3;
        int offset=(num+2==9||num+2==8)?1:0;
        for (String str: tmp){
            for (int i=offset; i<n+offset; i++)
                ans.add(template.charAt(i+num*3)+str);
        }return ans;
    }
}
```

</details>


<details>
<summary>18. 4Sum [Medium]</summary>

## % 18. 4Sum [Medium]
###  思路
1. O(n^2+nlogn) with big constant:  
     map+set  
2. O(n^3) with optimization:  
     for^2 双指针, 两边夹, 主要考虑一下双指针解法  

### 要点
1. int[] to List<int>:
  ```java
    Arrays.sort(arr);
    Arrays.stream(arr).boxed().collect(Collectors.toList());
  ```

### 代码

```java
class Solution {
    public List<List<Integer>> fourSum(int[] nums, int target) {
        int n=nums.length, size=0;
        int[] pre=new int[n*(n-1)/2];
        int[] pos=new int[n*(n-1)/2];
        Map<Integer, List<Integer>> map=new HashMap();
        Set<List<Integer>> set=new HashSet();
        LinkedList<List<Integer>> ans=new LinkedList();
        
        for (int i=0; i<n; i++)
            for (int j=i+1; j<n; j++){
                int sum=nums[i]+nums[j];
                pre[size]=i;
                pos[size++]=j;
                
                if (!map.containsKey(sum))
                    map.put(sum, new LinkedList());
                map.get(sum).add(size-1);
            }
        
        for (int i=0; i<n; i++)
            for (int j=i+1; j<n; j++){
                int rest=target-nums[i]-nums[j];
                if (!map.containsKey(rest)) continue;
                for (Integer ptr: map.get(rest))
                    if (i!=pre[ptr] && i!=pos[ptr] &&
                        j!=pre[ptr] && j!=pos[ptr]){
                        int[] l={nums[i], nums[j], nums[pre[ptr]], nums[pos[ptr]]};
                        Arrays.sort(l);
                        set.add(Arrays
                                .stream(l)
                                .boxed()
                                .collect(Collectors.toList()));
                    }
            }
        
        
        for (List<Integer> list: set)
            ans.add(list);
        
        return ans;
    }
}
```

</details>


<details>
<summary>19. Remove Nth Node From End of List [Medium]</summary>

## 19. Remove Nth Node From End of List [Medium]
###  思路
水题  
优化:  
  可以在第一个指针走了n个元素后, 在起一个指针, 等第一个结束了之后, 删除后一个指针的元素.  
  然而对复杂度没有提升, 而且有人说这是个很好的优化, 我说简直扯淡好吧  
  
### 要点
无

### 代码

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 *     int val;
 *     ListNode next;
 *     ListNode(int x) { val = x; }
 * }
 */
class Solution {
    public ListNode removeNthFromEnd(ListNode head, int n) {
        int len=0;
        ListNode tmp=head;
        
        while (tmp!=null){
            len++;
            tmp=tmp.next;
        }

        if (n==len) return head.next;
        
        tmp=head;
        for (int i=0; i<len-n-1; i++)
            tmp=tmp.next;
        tmp.next=tmp.next.next;
        
        return head;
    }
}
```

</details>

<details>
<summary>20. Valid Parentheses [Easy]</summary>

## 20. Valid Parentheses [Easy]
###  思路
水题, 栈

### 要点
1. Stack用法: push(), peek(), pop(), isEmpty()

### 代码

```java
class Solution {
    private static Map<Character, Character> map=new HashMap();
    static{
        map.put('(', ')');
        map.put('{', '}');
        map.put('[', ']');
    }
    
    public boolean isValid(String s) {
        Stack<Character> sta=new Stack();
        int len=s.length();
        
        for (int i=0; i<len; i++){
            if (map.containsKey(s.charAt(i))) sta.push(s.charAt(i));
            else{
                if (!sta.isEmpty() && s.charAt(i)==map.get(sta.peek())) sta.pop();
                else return false;
            }
        }
        
        if (sta.isEmpty())
            return true;
        return false;
    }
}
```

</details>