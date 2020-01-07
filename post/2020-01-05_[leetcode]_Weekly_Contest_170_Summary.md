
<!-- vim-markdown-toc Marked -->

* [Leetcode Solution](#leetcode-solution)
        * [总结](#总结)
    * [5303. Decrypt String from Alphabet to Integer Mapping](#5303.-decrypt-string-from-alphabet-to-integer-mapping)
        * [思路](#思路)
        * [要点](#要点)
        * [代码](#代码)
    * [5304. XOR Queries of a Subarray](#5304.-xor-queries-of-a-subarray)
        * [思路](#思路)
        * [要点](#要点)
        * [代码](#代码)
    * [5305. Get Watched Videos by Your Friends](#5305.-get-watched-videos-by-your-friends)
        * [思路](#思路)
        * [要点](#要点)
        * [代码](#代码)

<!-- vim-markdown-toc -->

# Leetcode Solution
久违的空闲周末, 久违的周赛
昨天晚上把键盘ESC和Caps互相映射了一下, 导致今天打码卡手, 烦

### 总结
0. 用java做周赛的话, 就有点太慢了, 两部分原因: 记不住; 语法罗嗦
以后写代码多记忆一下; 试试scala
1. PriorityQueue用法, 最好自己写个Pair:
```java
PriorityQueue<Pair> que = new PriorityQueue<>();
que.poll();
que.add();

static class Pair {
    @Override
    public int compareTo(Pair p) {
        return Integer.compare(x, p.x);
    }
} 
```

2. 以后所有的排序就按stream+方法/lambda的方式吧
```
map.entrySet().stream()
    .sorted(this::compare)
    .map(Map.Entry::getKey)
    .collect(Collectors.toList());
```

3. 多用用`map.computeIfAbsent`, `map.computeIfPresent`方法

<hr>

<details>
<summary>5303. Decrypt String from Alphabet to Integer Mapping</summary>

## 5303. Decrypt String from Alphabet to Integer Mapping
###  思路
水题不写思路了

### 要点
无

### 代码

```java
class Solution {
    public String freqAlphabets(String s) {
        StringBuilder builder = new StringBuilder();

        for (int i=0; i<s.length(); i++) {
            if (i+2 >= s.length()) 
                builder.append((char)(s.charAt(i)-'1'+'a'));
            else {
                if (s.charAt(i+2)=='#') {
                    builder.append((char)((s.charAt(i)-'0')*10+s.charAt(i+1)-'1'+'a'));
                    i += 2;
                } else 
                    builder.append((char)(s.charAt(i)-'1'+'a'));
            }
        }
        return builder.toString();
    }
}
```

</details>



<details>
<summary>5304. XOR Queries of a Subarray</summary>

## 5304. XOR Queries of a Subarray
###  思路
异或前缀和

### 要点
注意处理下标越界两种方式: 条件判断, 重定义数组大小
简单思考一下就行, 拿不准就条件判断, 免得浪费时间.

### 代码

```java
class Solution {
    public int[] xorQueries(int[] arr, int[][] queries) {
        int[] sum = new int[arr.length+1];
        
        sum[1] = arr[0];
        for (int i=2; i<=arr.length; i++) {
            sum[i] = sum[i-1] ^ arr[i-1];
            System.out.println(sum[i]);
        }
        
        int size = 0;
        int[] ans = new int[queries.length];
        for (int[] q: queries) 
            ans[size++] = sum[q[1]+1] ^ sum[q[0]];
        return ans;
    }
}
```

</details>



<details>
<summary>5305. Get Watched Videos by Your Friends</summary>

## 5305. Get Watched Videos by Your Friends
###  思路
脑子卡壳, 首先想了个错的dfs思路, 然后WA, 最后还是安心写最短路了-_-
dijkstra按id求个最短路dist[], 然后Map记录, 最后排序就行.
其实还是个水题, 但是java写起来很卡手, 有些类记不起来, 得练练.

### 要点
1. PriorityQueue用法, 最好自己写个Pair:
```java
PriorityQueue<Pair> que = new PriorityQueue<>();
que.poll();
que.add();

static class Pair {
    @Override
    public int compareTo(Pair p) {
        return Integer.compare(x, p.x);
    }
} 
```

2. 以后所有的排序就按stream+方法/lambda的方式吧
```
map.entrySet().stream()
    .sorted(this::compare)
    .map(Map.Entry::getKey)
    .collect(Collectors.toList());
```

3. 多用用`map.computeIfAbsent`, `map.computeIfPresent`方法

### 代码

```java
class Solution {
    
    private int[][] next;
    private List<List<String>> elem;

    public List<String> watchedVideosByFriends(List<List<String>> watchedVideos, int[][] friends, int id, int level) {
        this.next = friends;
        this.elem = watchedVideos;
        Map<String, Integer> map = new HashMap<>();
        int[] dis = new int[next.length];

        dij(id, dis);
        for (int i = 0; i<next.length; i++)
            if (dis[i] == level) merge(map, i);

        return map.entrySet().stream()
                .sorted(this::compare)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private void merge(Map<String, Integer> map, int id) {
        for (String s: elem.get(id)) {
            map.computeIfAbsent(s, x -> 0);
            map.computeIfPresent(s, (k, v) -> v+1);
        }
    }

    private int compare(Map.Entry<String, Integer> x, Map.Entry<String, Integer> y) {
        Integer xv = x.getValue(), yv = y.getValue();
        if (xv.equals(yv)) return x.getKey().compareTo(y.getKey());
        return xv.compareTo(yv);
    }

    private void dij(int start, int[] dis) {
        PriorityQueue<Pair> que = new PriorityQueue<>();

        Arrays.fill(dis, Integer.MAX_VALUE);
        dis[start] = 0;
        que.add(new Pair(start, 0));

        while (!que.isEmpty()) {
            Pair from = que.poll();

            if (from.second != dis[from.first]) continue;
            // System.out.println(from.first + ", " + from.second);
            for (int to: next[from.first]) {
                if (dis[to] < dis[from.first] + 1) continue;
                dis[to] = dis[from.first] + 1;

                que.add(new Pair(to, dis[to]));
            }
        }
    }

    static class Pair implements Comparable<Pair> {
        public int first, second;
        public Pair(int first, int second) {
            this.first = first;
            this.second = second;
        }

        @Override
        public int compareTo(Pair o) {
            return Integer.compare(second, o.second);
        }
    }
}

```

</details>
