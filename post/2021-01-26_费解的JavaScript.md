# 费解的 JavaScript

这里总结了一些在本人学习 JS 过程中的一些费解的特性和机制，并不是说理解起来很难，而是很多博客一知半解搁这胡然，导致本人总是思路上走弯路。但本文的主要目的仍然是便于自己理解和复习。



## 异步编程



### 事件循环

> https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/EventLoop

JavaScript 的事件循环模型与许多其他语言不同的一个非常有趣的特性是，它永不阻塞。这依托了事件循环的设计。

需要注意的是，在事件循环下，零延迟并不意味着回调会立即执行，这导致它不适合做任何实时操作。例如以 0 为第二参数调用 `setTimeout` 并不表示在 0 毫秒后就立即调用回调函数。

JS 存在两种平台，即浏览器和服务器平台。接下来从这两个平台来讲事件循环，并说明二者的差异。

首先要定义一些基本知识：

1. **宏任务与微任务**：事件循环中的异步队列有两种，即宏任务队列和微任务队列。两者的区别在于任务执行的顺序不同。
   - 常见的**宏任务**：`setTimeout`、\<script\>、IO操作等。
   - 常见的**微任务**：`process.nextTick`(Node.js)、`Promise.prototype.then`、`MutationObserver`(H5) 



#### 浏览器平台

> https://zhuanlan.zhihu.com/p/54882306

浏览器内核是多线程，在内核控制下各线程相互配合以保持同步，一个浏览器通常由以下常驻线程组成：

- GUI 渲染线程
- JavaScript 引擎线程
- 定时触发器线程
- 事件触发线程
- 异步 http 请求线程

注意，在浏览器的事件循环中，**宏任务队列可以有多个，而微任务队列只有一个**。

接下来讲事件循环的过程：

![browser_event_loop](/static/image/2021-01-26/browser_event_loop.jpeg)

![browser_event_loop_process](/static/image/2021-01-26/browser_event_loop_process.jpeg)

0. 全局上下文（script 标签）被推入执行栈，同步代码执行。在这个过程中，代码将产生新的  macro-task 与 micro-task，它们会分别被推入各自的任务队列里。

1. 全局上下文的**同步代码**执行完了，script 脚本会被移出 macro  队列，这个过程本质上是队列的 macro-task 的执行和出队的过程。
2. 接下来处理 micro-task。但需要注意的是：当 macro-task 出队时，任务是**一个一个**执行的；而 micro-task 出队时，任务是**一队一队**执行的。因此，我们处理 micro 队列这一步，会逐个执行队列中的任务并把它出队，直到队列被清空。
3. 渲染界面。
4. 处理 Web Worker 任务。



#### 服务器平台

> https://fourstacks.codes/node/

这里的服务器平台特指 Node.js，排除 deno 的原因是它的资料太少。

Node.js 采用 V8 作为 js 的解析引擎，而 I/O 处理方面使用了自己设计的 libuv，libuv 是一个基于事件驱动的跨平台抽象层，封装了不同操作系统一些底层特性，对外提供统一的 API，事件循环机制也是它里面的实现。



![node_system](/static/image/2021-01-26/node_system.png)

**Node.js 的运行机制**如下:

- V8 引擎解析 JavaScript 脚本。
- 解析后的代码，调用 Node API。
- libuv 库负责 Node API 的执行。它将不同的任务分配给不同的线程，形成一个 Event Loop（事件循环），以异步的方式将任务的执行结果返回给 V8 引擎。
- V8 引擎再将结果返回给用户。



![node_event_loop](/static/image/2021-01-26/node_event_loop.png)

libuv 引擎中的事件循环分为**六个阶段**：

- **Timers阶段**：任何过期的计时器回调都会在事件循环的这个阶段中运行。

- Pending阶段（I/O callbacks）：一些系统上的回调发生在本阶段执行，处理一些上一轮循环中的少数未执行的 I/O 回调。

- Idle和Prepare阶段：仅 node 内部使用。

- **Poll阶段**：此阶段执行I/O回调，如果无I/O之外的任何其他事件，则<u>会阻塞</u>并等待I/O操作完成，然后立即执行这些操作的回调。
  
- **Check阶段**：只有`setImmediate()`回调会在该阶段中执行。
  
- Close阶段：如果某个套接字或句柄突然关闭，则会执行此阶段，这种情况下会触发其close事件。 



注意，在这里**每个阶段会有一个宏任务队列，每个宏任务队列会有一个对应的微任务队列**。

执行的顺序上，每个宏任务队列的回调函数全部执行完后，则开始微任务的执行。直到每个队列都为空，则事件循环结束。

这里是一个例子，展示了完整的流程：

```javascript
import fs from 'fs';
import { setImmediate } from 'timers';

const interval = setInterval(() => {
    console.log('[timer]');
    Promise.resolve()
        .then(() => console.log('[timer](mirco)'));

    setImmediate(() => {
        console.log('[check]');
        Promise.resolve()
            .then(() => console.log('[check](mirco)'));
    });
}, 0);

fs.readFile('url.txt',() => {
    console.log('[poll]');
    Promise.resolve()
        .then(() => console.log('[poll](mirco)'));
    clearInterval(interval);
});

Promise.resolve()
    .then(() => console.log('[mainline](mirco)'));
console.log('[mainline]');
```

```
[mainline]
[mainline](mirco)
[timer]
[timer](mirco)
[check]
[check](mirco)
[timer]
[timer](mirco)
[check]
[check](mirco)
[poll]
[poll](mirco)
```



#### 平台间的差异

> https://zhuanlan.zhihu.com/p/54882306

- 浏览器环境下，microtask 的任务队列是每个 macrotask 执行完之后执行。

- 而在 Node.js 中，microtask 会在事件循环的各个阶段之间执行，也就是一个阶段执行完毕，就会去执行 microtask 队列的任务。

![browser_node_diff](/static/image/2021-01-26/browser_node_diff.jpeg)

接下我们通过一个例子来说明两者区别：

```js
setTimeout(()=>{
    console.log('timer1')
    Promise.resolve().then(function() {
        console.log('promise1')
    })
}, 0)
setTimeout(()=>{
    console.log('timer2')
    Promise.resolve().then(function() {
        console.log('promise2')
    })
}, 0)
```

浏览器端运行结果：`timer1 => promise1 => timer2 => promise2`

Node 端运行结果：`timer1 => timer2 => promise1 => promise2`



### Promise & Monad



#### Monad

首先解释一下 Monad，它是来自范畴论的概念。后来引入进函数式编程语言，并渐渐渗透到其他主流语言中。

从离散数学的方式讲，Monad 是自函子范畴上的含幺半群。并不打算讲这个理论上的概念。

用 Haskell 的定义来看：

```haskell
class Monad m where
  return :: a -> m a
  (>>=) :: forall a b . m a -> (a -> m b) -> m b
```

其实它只是由一个 `flatMap` 构成的一种类型。

在我们写代码时，常见的 Monad 有 Scala的`Maybe`、Rust 的`Option`和`Result`、JS 的`Promise`等，甚至支持`flatMap`的数组也是 Monad。

编程语言引入 Monad 的目的是什么？

1. 消除 IO 的副作用，将 IO 的影响控制在 Monad 的范围内。请注意，除了`flatMap`外，没有任何操作可以从 Monad 包裹中获得数据。

2. 会少写很多逻辑判断语句。此处比较 Rust 和 Go 处理错误的不同。

   举一个例子，从文本中获得url，并获得url的内容，进行HTML解析，获得网页的 title，如果失败则也返回”error occured“。

   ```Rust
   fn get_title(filename: String) -> Result<String, String> {
       read_file(filename)?
       	.and_then(get_page)?
       	.and_then(parse)?
       	.and_then(regex_get_title)?
       	.or(Ok("error occured"))
   }
   ```

   如果翻译成 Go 的话：

   ```go
   func GetTitle(filename string) (err error, title string) {
       var url
       if err, url = readFile(filename); err {
           return MyError{"error occured"}, nil
       } 
       
       var page
       if err, page = getPage(url); err {
           return MyError{"error occured"}, nil
       }
       
       var content
       if err, content = parse(page); err {
           return MyError{"error occured"}, nil
       }
       
       if err, title = regexGetTitle(page); err {
           return MyError{"error occured"}, nil
       }
       
       return nil, title
   }
   ```

   

#### Promise

Promise 是异步编程的一种解决方案，解决了回调函数的回调地狱问题。下面是它的一些特点：

- 对象的状态不受外界影响。Promise对象代表一个异步操作，有三种状态：pending（进行中）、fulfilled（已成功）和rejected（已失败）。

- 一旦状态改变，就不会再变，任何时候都可以再得到这个结果。这时就称为 resolved（已定型）。

它的一些缺陷：

1. 无法中途取消Promise。
2. 处于pending状态时，无法得知目前进展到哪一个阶段。
3. 将 IO 副作用包装起来，不便于错误处理。
4. 样板代码较多。



### 半协程与异步



#### 半协程

在讨论半协程之前，先讲一下什么是协程。

**协程**（coroutine）是一种程序运行的方式，可以理解成“协作的线程”或“协作的函数”。

1. 同时存在多个函数栈，但只有其中一个在运行；

2. 协程拥有线程一样的生存周期状态。多个协程之间的执行权，由协程根据代码自主分配，从而切换不同协程持有的函数栈。

协程的要点在于**执行权的唯一性和函数栈的自主切换**，这就明显区别与多进程和多线程的运行方式。

由于协程避免了线程切换的开销，从而提高了并行效率。于是 ES6 提供了一种**半协程**的实现，即 Generator。“半协程”（semi-coroutine），意思是只有 Generator 函数的调用者，才能将程序的执行权还给 Generator 函数。如果是完全执行的协程，任何函数都可以让暂停的协程继续执行。



#### 异步

接下来再明确一下**异步**的含义。

1. **调用双方的角度**：异步是指，在调用函数或执行任务后，调用者不会立刻得到结果的现象。结果是通过**被调用者向调用者通知或回调的方式**来获取。

2. **执行任务的角度**：实际上一个更舒服的表述是，任务不是连续进行的，可以理解成该任务被人为分成两段，**先执行第一段，然后转而执行其他任务，等做好了准备（相关的外部的IO或计算完成），再回过头执行第二段**。



#### 结合

我们首先比较二者：

- 协程：函数栈的自主切换、执行权的唯一性。
- 异步：任务的拆分执行、等待的同时执行其他操作。

通过比较，我们发现<u>可以通过协程的程序运行方式来描述异步的任务执行方式</u>。包含异步操作的任务，前半段由协程正常执行。当执行到异步任务后，则提交一个异步任务给事件循环，并切换函数栈执行其他操作。当事件循环检测到异步操作完成后，在回调函数中通过协程切换回原来的任务，继续执行。

这就是通过半协程的方式来描述包含异步操作的任务。半协程并非唯一方式，还有最基础的回调函数、Promise、订阅发布、流等模型，它们都能描述含异步任务。

相对原有的回调函数和 Promise 方案，半协程方式则解决了回调地狱和 Promise 的问题。并非在说 Generator 半协程方式完美无缺，只是在当前的方案中，它的缺点是可以忽略的。

说到缺点，由于 Generator 的语义不明显（生成器为什么能用来描述异步，哪怕是老手也会解释不清），同时也将 IO 的副作用扩散开了（这里对比的是 Monad 本质下的 Promise，你也可以比较 Rust 和 GO 的错误处理）。

不过 ES6 引入`async`函数，它解决了语义的问题，而副作用扩散仍然存在。



## 类型系统

JS 中有 7 种类型（除了`BigInt`），`undefined`、`null`、`Boolean`、`Number`、`String`、`Object`、`Symbol`。

然后需要明确**值类型**和**引用类型**：

- **值类型**：包括除了`Object`外的基本类型，它们是在栈上按值访问。
- **引用类型**：`Object`，它需要引用访问。



### 类型检查

首先指出 JS 是隐式动态弱类型。



#### 静态与动态类型

是指类型检查在什么时间进行，这分为静态和动态。

- **动态类型**：运行时类型检查；
- **静态类型**：编译期类型检查。



#### 强弱类型

> https://zh.wikipedia.org/wiki/%E5%BC%B7%E5%BC%B1%E5%9E%8B%E5%88%A5

关于强弱类型则是众说纷纭，以至于难以区分二者。这里只能是引用 wiki 并讲个大概。

- **强类型**：在编译或解释时具有更严格的类型规则，这些规则大多影响变量赋值、函数返回值、过程参数和函数调用。
- **弱类型**：它的类型规则比较宽松，<u>可能会产生不可预测甚至错误的结果</u>，或者可能会在运行时执行<u>隐式类型转换</u>。



#### 显式与隐式类型

这部分则是描述变量或形参声明时是否应该给出类型。

- **显式类型**：给出具体类型；
- **隐式类型**：具有类型推导，有时推导的结果比较宽泛而不够确切，于是会有默认的类型作为替换。



### 多态

> https://en.wikipedia.org/wiki/Polymorphism_(computer_science)

JS 的多态是指动态多态，具体而言是具有子类型多态。（由于函数重载可以手动实现，那么也可以认为它具有特定多态？）



#### 多态类型

> https://zh.wikipedia.org/wiki/%E5%A4%9A%E5%9E%8B_(%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%A7%91%E5%AD%A6)

- **临时多态性**：为任意一组单独指定的类型定义一个公共接口。
- **参数多态性**：一种或多种类型不是通过名称指定，而是通过可以表示任何类型的抽象符号指定的。
- **子类型多态**：当名称表示由某个共同的超类关联的许多不同类的实例时。



##### 特定多态

**特定多态**（Ad-hoc Polymorphism），也叫特设多态。它是描述函数的多态，**特定多态的函数有多个不同的实现，根据实参来调用相应版本的函数。**

常见的特定多态有：**函数重载**、**运算符重载**、Rust 中的 **Trait** （函数的实现或者覆写）等。



##### 参数多态

**参数多态**是指声明与定义函数、复合类型、变量时不指定其具体的类型，而**把某些部分的类型作为参数使用，使得该定义对各种具体类型都适用。**还有限定的参数多态，用于限定参数表意，如 Java 中`class A <T extends Y>`。

常见的参数多态有：**泛型函数**、**泛型参数**等。



##### 子类型多态

**子类型多态**是指，子类型可以根据里氏替换规则，替换另一种相关的数据类型（超类型，或者父类）。也就是说，针对超类型元素进行操作的子程序、函数等程序元素，也可以操作相应的子类型。

在 OOP 中，多态一般仅指这里所说的「**子类型多态**」，而「**参数多态**」则一般被称作泛型。

注意，**函数覆写**是子类型多态的体现，而非**特定多态**。



##### 举例

|            | 特定多态     | 参数多态 | 子类型多态 |
| ---------- | ------------ | -------- | ---------- |
| C++        | √            | √        | √          |
| Java       | √            | √        | √          |
| Rust       | √            | √        |            |
| JavaScript | (原生不支持) |          | √          |



#### 静态与动态多态

首先可以通过编译运行时来区分多态，包括静态和动态。他们分别称为**静态分发**和**动态分发**，因此相应的多态形式也称为**静态多态**和**动态多态**。

 

##### 静态多态

静态多态执行速度更快，因为没有动态分配开销，但是需要其他编译器支持。 此外，静态多态性允许编译器（尤其是用于优化），源代码分析工具和人工阅读器（程序员）进行更大的静态分析。

静态多态性通常出现在临时多态性和参数多态性中，而动态多态性通常是子类型多态性。 但是，可以通过更复杂地使用模板元编程（即奇怪的重复模板模式）来通过子类型化实现静态多态性。

 

##### 动态多态

动态多态性更灵活但更慢-例如，动态多态性允许进行鸭子输入，而动态链接库可能在不知道其完整类型的情况下对对象进行操作。

通过库公开多态时，动态库无法实现静态多态，因为在构建共享库时无法知道参数的类型。 虽然像C ++和Rust这样的语言都使用单态化的模板，但是Swift编程语言在默认情况下广泛使用动态分派为这些库构建应用程序二进制接口。  结果，可以为减少系统大小而共享更多代码，但代价是运行时开销。



### 协变与逆变

> https://www.stephanboyer.com/post/132/what-are-covariance-and-contravariance
>
> https://zh.wikipedia.org/zh-hans/%E5%8D%8F%E5%8F%98%E4%B8%8E%E9%80%86%E5%8F%98

尽管 JS 不是静态类型语言，但是因为 JS 拥有 OOP 的能力（指子类型多态），所以这里还是要提一下协变逆变。

我们先从一个例子来理解协变逆变。

我们讲`Greyhound ≼ Dog ≼ Animal`，是指灰狗是狗的一个子类型，而狗又是动物的子类型。那么我这个时候问，`List<Dog> ≼  List<Animal>`正确么？或者抽象一下，当`A ≼ B`时，`List<A> ≼ List<B>`是否总是成立？或者是`List<B> ≼ List<A>`？或者实际上二者并无关系？答案放在最后再说。

接下来我要引入协变和逆变的概念了。



#### 变型

首先，所谓的**变型**（variance）是指如何根据组成类型之间的子类型关系，来确定更复杂的类型之间（例如`Cat`列表之于`Animal`列表，回传`Cat`的函数之于回传`Animal`的函数...等等）的子类型关系。

而在一门程式设计语言的**类型系统**中，一个类型规则或者类型构造器是： 

- **协变**（covariant）：如果它保持了子类型偏序关系`≼`。
- **逆变**（contravariant）：如果它逆转了子型别序关系。
- **不变**（invariant）：如果上述两种均不适用。



#### 举例：不可变的类型

好了，现在我们先放下之前的`List`，来讨论另一个更简单的问题。

请问以下哪种类型是 `Dog → Dog` 的子类型呢？先自个想想，再看后文的提示。

1. `Greyhound → Greyhound`
2. `Greyhound → Animal`
3. `Animal → Animal`
4. `Animal → Greyhound`

为了提供一种思路，我需要先提示一下，该子类型能够接受所有父类的可以接受参数，从而输出父类能够输出的任意一种输出（即不能输出一个更大范围的值）。这样答案自然就是最后一种。

抽象一点来讲，函数的参数类型是逆变的，但返回值是协变的。



#### 举例：可变的类型

现在再来判断，`List<Dog> ≼ List<Animal>`是正确的么？

现在来一个经典的高中操作，分类讨论。

- 当`List`不可变，那么是显然成立。
- 当`List`可变，那么它其实是不安全的。<br>当你需要一个`List<Animal>`，但实际上你获得了`List<Dog>`，自认为这很正确。但是当你向这个`List<Animal>`中插入一个`Cat`时，你估计会恍然大悟：手里的`List<Dog>`不能塞`Cat`。<br>这个时候，我们说这二者之间是**不变**（invariant）的。



#### 应用

协变逆变来回说，其实就是一个子类型多态的问题，即对某个变型来讨论，变形后 A 还是不是 B 的子类型。

这里用 TS 来演示（因为有静态类型方便观察）。注意，这里使用了参数多态（即泛型），JS 是不支持参数多态的，但是你可以自行定义`ComparatorAnimal`类。目的只是为了便于理解。

```typescript
interface Animal { ... }
interface Dog extends Animal { ... }
interface Cat extends Animal { ... }

// -------------------- 逆变 --------------------
interface Comparator<T> {
    compare: (a: T, b: T) => number;
}

const animalComparator: Comparator<Animal>;
const dogComparator: Comparator<Dog>;

animalComparator = dogComparator;   // 错误，因为函数参数是逆变的
dogComparator = animalComparator;   // 正确

// -------------------- 协变 --------------------
interface Factory<T> {
    create: () => T;
}

const animalFactory: Factory<Animal>;
const dogFactory: Factory<Dog>;

animalFactory = dogFactory;   // 正确，因为函数返回值是协变的
dogFactory = animalFactory;   // 错误
```

然后是一个 Java 的例子，用于演示泛型上的协变逆变。

注意，因为`List`在逻辑上是不变的（但由于历史原因 Java 认为是协变），这里使用`List<? extends T>`来强制告诉编译器，它是协变的。反之亦然。

但是，这样的协变逆变带来了很多问题。于是提出了**producer-extends, consumer-super（PECS）**的口诀（pecs /peks/，胸肌的意思），即产出用`extends`，接受用`super`。

我们再进一步，刚才讲到参数是逆变，返回值是协变的。而使用`List<? extends T>`等协变的变型数据结构，它的数据对应的函数变型部分也应该是协变的才对，不然无法作用。

下面就是例子了。提示：`<? extends T>`可以接受任何继承 T 的类型。取个极端一点的例子，`<? extends T>`这个类型可以是最小的子类（联想偏序关系的最小值，它是唯一的），那么它无法接受任何`add`输入。

```java
public class Main {
    public static void main(String[] args) {
        List<? extends Animal> list = new ArrayList<Dog>();
        
        // add :: <? extends Animal> -> void
        list.add(new Greyhound()); // 错误
        list.add(new Dog());       // 错误
        list.add(new Animal());    // 错误
        list.add(new Object());    // 错误
        
        // get :: Integer -> <? extends Animal>
        Greyhound g = list.get(0); // 错误
        Dog dog = list.get(0);     // 错误
        Animal ani = list.get(0);
        Object obj = list.get(0);
    }
}

public class Main {
    public static void main(String[] args) {
        List<? super Dog> list = new ArrayList<Animal>();
        
        // add :: <? super Dog> -> void
        list.add(new Greyhound());
        list.add(new Dog());
        list.add(new Animal());    // 错误
        list.add(new Object());    // 错误
                
        // get :: Integer -> <? super Dog>
        Greyhound g = list.get(0); // 错误
        Dog dog = list.get(0);     // 错误
        Animal ani = list.get(0);  // 错误
        Object obj = list.get(0);  // 错误
    }
}
```







### 等价关系



### 空值





## 语法特性



### 属性描述符



### 浅拷贝



## 面向对象



### 原型链



### 顶层对象



### this 的指向



### 内部属性



## 实例



### 数据双向绑定



### 多继承



### 自动执行函数

