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

首先指出 JS 是隐式动态弱类型。弱类型体现在隐式类型转换上（例子：JSFuck）。



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

> https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Equality_comparisons_and_sameness

ES2015 中有四种相等算法：

- **抽象相等比较**（`==`）
- **严格相等比较**（`===`）：用于 `Array.prototype.indexOf`, `Array.prototype.lastIndexOf`, 和 `case-matching`
- **同值零**（SameValueZero）： `%TypedArray%` 和 `ArrayBuffer `构造函数、`Map`和`Set`操作、`String.prototype.includes`
- **同值**（SameValue）：所有其他地方。



而 JS 暴露给用户的比较操作有：

- 抽象相等比较：执行**隐式类型转换**（注意这里仅仅是`==`的转换，其他运算符有其他方式）。
- 严格相等比较：不执行隐式类型转换（类型不同返回 false），仅在`Number`上有特殊规则。
  - 非`Number`类型时：当两个变量类型相同，且值相同时，相等。
  - 是`Number`类型时：`NaN`自身不相等，`+0 -0`相等，其他值相等。
- `Object.is`：在严格相等比较上，规定`NaN`自身相等，`-0 +0`不相等。



#### 抽象相等比较

除了`NaN`以外，满足等价关系（自反对称传递），

<table class="standard-table">
 <thead>
  <tr>
   <th scope="row"></th>
   <th colspan="7" scope="col" style="text-align: center;">被比较值 B</th>
  </tr>
 </thead>
 <tbody>
  <tr>
   <th scope="row"></th>
   <td></td>
   <td style="text-align: center;">Undefined</td>
   <td style="text-align: center;">Null</td>
   <td style="text-align: center;">Number</td>
   <td style="text-align: center;">String</td>
   <td style="text-align: center;">Boolean</td>
   <td style="text-align: center;">Object</td>
  </tr>
  <tr>
   <th colspan="1" rowspan="6" scope="row">被比较值 A</th>
   <td>Undefined</td>
   <td style="text-align: center;"><code>true</code></td>
   <td style="text-align: center;"><code>true</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>IsFalsy(B)</code></td>
  </tr>
  <tr>
   <td>Null</td>
   <td style="text-align: center;"><code>true</code></td>
   <td style="text-align: center;"><code>true</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>IsFalsy(B)</code></td>
  </tr>
  <tr>
   <td>Number</td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>A === B</code></td>
   <td style="text-align: center;"><code>A === ToNumber(B)</code></td>
   <td style="text-align: center;"><code>A=== ToNumber(B) </code></td>
   <td style="text-align: center;"><code>A== ToPrimitive(B)</code></td>
  </tr>
  <tr>
   <td>String</td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>ToNumber(A) === B</code></td>
   <td style="text-align: center;"><code>A === B</code></td>
   <td style="text-align: center;"><code>ToNumber(A) === ToNumber(B)</code></td>
   <td style="text-align: center;"><code>ToPrimitive(B) == A</code></td>
  </tr>
  <tr>
   <td>Boolean</td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>false</code></td>
   <td style="text-align: center;"><code>ToNumber(A) === B</code></td>
   <td style="text-align: center;"><code>ToNumber(A) === ToNumber(B)</code></td>
   <td style="text-align: center;"><code>A === B</code></td>
   <td style="text-align: center;">ToNumber(A) == ToPrimitive(B)</td>
  </tr>
  <tr>
   <td>Object</td>
   <td style="text-align: center;"><font face="Consolas, Liberation Mono, Courier, monospace">false</font></td>
   <td style="text-align: center;"><font face="Consolas, Liberation Mono, Courier, monospace">false</font></td>
   <td style="text-align: center;"><code>ToPrimitive(A) == B</code></td>
   <td style="text-align: center;"><code>ToPrimitive(A) == B</code></td>
   <td style="text-align: center;">ToPrimitive(A) == ToNumber(B)</td>
   <td style="text-align: center;">
    <p><code>A === B</code></p>
   </td>
  </tr>
 </tbody>
</table>
当`A == B`中，二者类型不同时，归纳一下：

1. `undefined`与`null`相等，其他值不等。
2. 接下来进行类型转换：
   - `Boolean`=>`Number`
   - `Object`=>`Number`/`String`（先执行`valueOf`，若不存在函数则再`toString`）
   - `String`=>`Number`（当对方是`Object`并转换为`String`时，不需要再转）
3. 进行**严格相等比较**。



![equality_triangle](/static/image/2021-01-27/equality_triangle.jpeg)

是时候来看看这张图了。

我们来解释一下为何如此。那么按照类型转换的规则：

1. 先给对象`[]`做个类型转换，由于`valueOf()`的值仍然是个对象，于是执行`toString`。
2. `[].toString() === ""`所以在抽象相等比较上，`[]`是完全可以看作空字符串。

于是剩下的`String`和`Number`之间的比较就会方便很多。




### 空值

这里讲的「空值」是指一些不包含任何数据的类型，因为他们被设计为特殊的含义，不需要携带数据。

- **`undefined`**：它是<u>全局对象</u>的一个**属性**，也是一个类型。用于描述未定义变量、未赋值的变量、无返回值的函数的返回值。

- **`null`**：它不是全局对象的一个**变量**。表示缺少的标识，指示变量未指向任何对象。

  - 所以`Null`是一个类型，`null`是这个类型的值，但本着初心`typeof null`则是`Object`。

- **`NaN`**：是`Number`类型下的一个<u>全局对象</u>的属性。通常是由计算或解析失败返回。

- **`void`**：它是一个运算符，对给定的表达式进行求值，然后返回 [`undefined`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/undefined)。作用是实现带有副作用的`undefined`。下面说一下它的应用。

  1. 立即执行的函数表达式：利用 `void` 运算符让 JavaScript 引擎把一个`function`关键字识别成函数表达式而不是函数声明。

     ```javascript
     void function iife() {
         // ...
     }();
     ```

  2. JavaScript URL：当用户点击一个以 `javascript:` URI 时，它会执行URI中的代码，然后用返回的值替换页面内容，除非返回的值是[`undefined`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/undefined)。

     ```javascript
     <a href="javascript:void(0);">
       这个链接点击之后不会做任何事情，如果去掉 void()，
       点击之后整个页面会被替换成一个字符 0。
     </a>
     <p> chrome中即使<a href="javascript:0;">也没变化，firefox中会变成一个字符串0 </p>
     <a href="javascript:void(document.body.style.backgroundColor='green');">
       点击这个链接会让页面背景变成绿色。
     </a>
     ```

  3. 在箭头函数中避免泄漏：因为单行的箭头函数会默认设定返回值，所以当你不需要返回值时，可以使用它。

     ```javascript
     button.onclick = () => void doSomething();
     // 当 doSomething 函数重构成可以返回值后，这里可以方式泄漏
     ```



## 语法特性



### 属性描述符

> https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty

对象里目前存在的属性描述符有两种主要形式：**数据描述符**和**存取描述符**。一个描述符只能是这两者其中之一；不能同时是两者。

- ***数据描述符***是一个具有值的属性，该值包括可写性等。
  - `value`：该属性对应的值。
  - `writable`：描述是否可写。
- ***存取描述符***是由 getter 函数和 setter 函数所描述的属性。
  - `get`：属性的 getter 函数，当访问该属性时，会调用此函数。该函数的返回值会被用作属性的值。
  - `set`：属性的 setter 函数，当属性值被修改时，会调用此函数。

它们还共享以下可选键值：

- `configurable`：描述该属性的描述符能否被改变。 
- `enumerable`：描述该属性是否可枚举。

关于默认初始值：

- 拥有布尔值的键 `configurable`、`enumerable` 和 `writable` 的默认值都是 `false`。
- 属性值和函数的键 `value`、`get` 和 `set` 字段的默认值为 `undefined`。



### 深浅拷贝

JS 本身不带深拷贝，如果想要使用深拷贝，请使用第三方库，如`lodash.cloneDeep`、`R.clone`。

JS 很多地方使用了浅拷贝，现在总结浅拷贝的一些方法：

- 直接赋值：注意直接赋值是复制了指针，相当于引用或者重命名。

- 解构赋值与展开运算符：对象或数组的浅拷贝。

- `Object.assign`：对象的第一层是深拷贝的，嵌套的更深层则是浅拷贝。



## 面向对象

> **JavaScript (** **JS** ) 是一种具有函数优先的轻量级，解释型或即时编译型的编程语言。
>
> JavaScript 是一种基于原型编程、多范式的动态脚本语言，并且支持面向对象、命令式和声明式（如函数式编程）风格。

注意 JS 不是一个经典的 OOP 语言，它仅是支持 OOP。而且直到 Node.js v14 为止，仍然没有默认支持将私有方法特性。至今浏览器平台和服务器平台也没有支持装饰器特性。



### 原型链

JS 用原型链来模拟了面向对象的子类型多态。

原型链中有三个概念：**构造函数**、**实例对象**、**原型**。



#### 构造函数

它为了提供一个便捷的对象构造方法，注意使用了`new`和`this`关键字：

```javascript
function Person(name) {
  this.name = name;
  this.greeting = function() {
    alert('Hi! I\'m ' + this.name + '.');
  };
}

const p = new Person("foo");
```

如何理解对象的构造过程？我们从`new`运算符来说：

**`new` 运算符**创建一个用户定义的对象类型的实例或具有构造函数的内置对象的实例。

**`new`** 关键字会进行如下的操作：

1. 创建一个空的简单JavaScript对象（即`{}`）；
2. 链接该对象（设置该对象的**constructor**）到另一个对象 ；
3. 将步骤1新创建的对象作为构造函数的`this`上下文 ；
4. 如果该函数没有返回对象，则返回`this`。



#### 原型

每个对象拥有一个**原型对象**，对象以其原型为模板，从原型继承方法和属性。原型对象也可能拥有原型，并从中继承方法和属性，一层一层、以此类推。这种关系被称为**原型链** (prototype chain)，它解释了为何一个对象会拥有定义在其他对象中的属性和方法。（每个实例访问属性的过程，都类似于<u>自动解引用</u>，一层层向上访问，直到找到合适的属性为止）

下面举一个例子：

![prototype_chain](/static/image/2021-01-16/prototype_chain.png)

```javascript
// 除了箭头函数以外，都可以作为构造函数
let Cons = function(){};
let Ins = new doSomething()

console.assert( Ins.__proto__ === Cons.prototype )
console.assert( Ins.__proto__.prototype === Object.prototype )
console.assert( Cons.__proto__ === Function.prototype )
```

**构造函数**：拥有prototype和[[Prototype]]

**原型对象**：拥有[[Prototype]]、constructor和自定义的属性；但注意Object.prototype.[[Prototype]]为null

**实例对象**：拥有[[Prototype]]



#### 原型链继承

了解了原型链的原理，那么就可以实现继承了。**原型链继承的步骤**：

1. 构造函数中使用父类的构造函数，作用于当前的`this`
2. 子类的原型关联父类的原型，使用`Object.create()`
3. 设置子类原型的构造函数、可继承的方法和属性。

```javascript
// Person
function Person(first, last, age, gender, interests) {
  this.name = { first, last };
  this.age = age;
  this.gender = gender;
  this.interests = interests;
}

Person.prototype.greeting = function() {
  alert('Hi! I\'m ' + this.name.first + '.');
};


// Teacher
function Teacher(first, last, age, gender, interests, subject) {
  // 1. call 指明了在运行这个函数时想对“this”指定的值 
  Person.call(this, first, last, age, gender, interests);

  this.subject = subject;
}

// 2. 关联原型
Teacher.prototype = Object.create(Person.prototype);
// 3. 设置构造函数、可继承的方法和属性
Teacher.prototype.constructor = Teacher;
Teacher.prototype.greeting = function() { /* */ }
Teacher.prototype.teacherID = /*  */;
```




### 顶层对象

顶层对象在浏览器环境指的是`window`，在Node中指的是`global`对象。

ES5 中顶层对象和全局变量是等价的，全局变量对编程者来说造成了很大的麻烦，因为一个疏忽就把变量泄露到了全局，全局变量的属性到处都是可读可写的，非常不流于模块化编程。

ES6为了完善这一点，同时为了保持兼容性，由`var`，**`function`定义全局变量依旧是顶层对象的属性**，另一方面规定，`let`、`const`、`class`的全局变量不属于顶层对象的属性。也就是说ES6开始，全局变量将逐渐与顶层对象的属性脱钩。

JavaScript 语言存在一个顶层对象，它提供全局环境（即全局作用域），所有代码都是在这个环境中运行。但是，顶层对象在各种实现里面是不统一的。

ES2020 在语言标准的层面，引入globalThis作为顶层对象。也就是说，任何环境下，globalThis都是存在的，都可以从它拿到顶层对象，指向全局环境下的this。

垫片库global-this模拟了这个提案，可以在所有环境拿到globalThis。



### this 的指向

> https://www.cnblogs.com/pssp/p/5216085.html

首先需要明确`function`、箭头函数、全局作用域下的`this`指向都不相同。

- **全局作用域**：`this`值顶层对象`window`或`global`。
- **箭头函数**：在创建时绑定外层<u>代码块</u>的`this`。
- **`function`**：**只有函数执行的时候才能确定this到底指向谁**，实际上this的最终指向的是那个调用它的对象。
  - 注意`function`是顶层对象的属性，直接调用`fn()`时，`this`指向顶层对象。

```javascript
const o1 = {
  name: "o1",
  fn1() {
    console.log(this);
  },
  fn2: () => {
    console.log(this);
  }
};

let o2 = Object.assign({}, o1);
o2.name = "o2";

o1.fn1();   // o1
o1.fn2();   // window
o2.fn1();   // o2
o2.fn2();   // window
```

```javascript
class Cls {
    attrFn = () => {
        console.log(this);
    }
    
    methodFn() {
        console.log(this);
    }
}

let o1 = new Cls();
let o2 = Object.assign({}, o1);
o1.name = "o1";
o2.name = "o2";

o1.attrFn();    // o1
o1.methodFn();  // o1
o2.attrFn();    // o1
o2.methodFn();  // TypeError: o2.methodFn is not a function
```





## 经典例子



### 数据双向绑定

```javascript
function bind(a, b, desc) {
    return new Proxy(a, {
        get: function(target, key) {
            console.log(`${desc} [get] ${key}`);
            return Reflect.get(target, key);
        },
        set: function(target, key, value) {
            console.log(`${desc} [set] ${key} => ${value}`);
            Reflect.set(b, key, value);
            return Reflect.set(target, key, value);
        },
        deleteProperty: function(target, key) {
            console.log(`${desc} [del] ${key}`);
            Reflect.deleteProperty(b, key);
            return Reflect.deleteProperty(target, key);
        },
    })
}

let [a, b] = [ {}, {} ];
[a, b] = [ bind(a, b, "A"), bind(b, a, "B") ];

a.name;
a.name = "Alice";
b.age = 18;
b.id = "0001"
delete b.id;

console.log(a);
console.log(b);

// A [get] name
// A [set] name => Alice
// B [set] age => 18
// B [set] id => 0001
// B [del] id
// { name: 'Alice', age: 18 }
// { name: 'Alice', age: 18 }
```



### 自动执行函数

```javascript
import axios from "axios";

function run(fn) {
    const gen = fn();

    return new Promise(resolve => {
        function next(data){
            const result = gen.next(data);
            if (result.done) { resolve(); return; }
            result.value.then(next);
        }

        next();
    });
}

function* main() {
    const rs = [
        yield axios.get("http://www.example.com/"),
        yield axios.get("http://www.baidu.com/"),
    ];

    rs
        .map(resp => resp.data.match(/<title>(.*)<\/title>/)[1])
        .forEach(title => console.log(title));
}

run(main)
    .then(_ => console.log("generator done"));

// 输出：
// Example Domain
// 百度一下，你就知道
// generator done
```



### 异步迭代器

```javascript
import axios from "axios";

async function* visit(urls) {
    for (const url of urls)
        yield await axios.get(url);
}

async function main() {
    const urls = [
        "http://www.baidu.com/",
        "http://www.example.com/",
    ];

    for await (const resp of visit(urls)) {
        const title = resp.data.match(/<title>(?<title>.*)<\/title>/)?.groups.title;
        console.log(title);
    }
}

main()
    .then(_ => console.log("done"));
```



### 单继承

```javascript
// ---------- Person ----------
function Person(name, age) {
    this.name = name;
    this.age = age;
}

Person.prototype.greeting = function() {
    return `Hi! ${this.age}-${this.name}`;
}


// ---------- Student ----------
function Student(name, age, id) {
    Person.call(this, name, age);
    this.id = id;
}

Student.prototype = Object.create(Person.prototype);
Student.prototype.constructor = Student;

const s = new Student("zhangsan", 12, "0001");
console.log(s.greeting());
// Hi! 12-zhangsan
```



```javascript
// ES6
class Person {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }

    greeting() {
        return `Hi ${this.age}-${this.name}`;
    }
}

class Student extends Person {
    constructor(name, age, id) {
        super(name, age);
        this.id = id;
    }

    greeting() {
        return `${super.greeting()}, and your id is ${this.id}`;
    }
}

const s = new Student("zhangsan", 12, "0001");
console.log(s.greeting());
// Hi 12-zhangsan, and your id is 0001
```



### 多继承

```javascript
import yaml from 'js-yaml';

function mix(...classes) {
    function copy(target, source) {
      for (let key of Reflect.ownKeys(source)) {
        if ( key !== 'constructor'
          && key !== 'prototype'
          && key !== 'name'
        ) {
          let desc = Object.getOwnPropertyDescriptor(source, key);
          Object.defineProperty(target, key, desc);
        }
      }
    }

    const result = class {
        constructor() {
            // 拷贝实例属性
            for (const cls of classes) {
                copy(this, new cls());
            }
        }
    }

    // 拷贝静态属性和原型
    for (const cls of classes) {
        copy(result, cls);
        copy(result.prototype, cls.prototype);
    }

    return result;
}


// ---------- demo ----------

class Jsonify {
    toJson() {
        const o = Object.assign(this, {toJSON: undefined});
        return JSON.stringify(o);
    }
}

class Yamlify {
    toYaml() {
        return yaml.dump(this);
    }
}

class Text extends mix(Jsonify, Yamlify) {
    constructor(content, option = {
        writable: false,
        trim: true,
    }) {
        super();
        this.option = option;
        this.content = ( option.trim ? content.trim() : content);
    }
}

const text = new Text("This is a sentence.");
console.log(text.toYaml());
console.log(text.toJson());

// option:
//   writable: false
//   trim: true
// content: This is a sentence.
// 
// {"option":{"writable":false,"trim":true},"content":"This is a sentence."}
```

