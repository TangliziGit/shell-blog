
<!-- vim-markdown-toc GitLab -->

* [Rust 细节](#rust-细节)
    * [理解 std::mem::swap](#理解-stdmemswap)
        * [总结](#总结)
        * [分析](#分析)
    * [理解 core::iter::Range](#理解-coreiterrange)
        * [总结](#总结-1)
        * [分析](#分析-1)
    * [理解 std::mem::take](#理解-stdmemtake)
        * [总结](#总结-2)
        * [分析](#分析-2)
    * [理解 `？`错误处理](#理解-错误处理)
        * [总结](#总结-3)
        * [分析](#分析-3)
    * [理解`flatten`](#理解flatten)
        * [总结](#总结-4)
        * [分析](#分析-4)
        * [举例](#举例)
    * [如何构建更好的 Rust CLI 应用](#如何构建更好的-rust-cli-应用)
    * [关于错误处理的设计](#关于错误处理的设计)
        * [如何自定义`Error`](#如何自定义error)
        * [如何使用`failure`第三方库](#如何使用failure第三方库)
    * [常用框架](#常用框架)
* [参考资料](#参考资料)

<!-- vim-markdown-toc -->


# Rust 细节

记录一些rust学习过程中的细节。这些细节都是碎片式的，不容易整理成一个主题，所以暂时在notes标签下列出来。


## 理解 std::mem::swap

### 总结

`swap`表现为使用&mut来交换值，底层则使用裸指针和编译器内置的函数（本质llvm）实现，涉及了块优化（一次性转移4个8字节数据）、不消耗所有权的read、可能内存泄漏的write。



### 分析

它底层使用了编译器内置的函数，本质上是llvm提供的函数。

`std::mem::swap`与`std::mem::replace`的区别只是replace会返回目标的所有权。

下面是`swap`的源码：
```rust
#[inline]
#[stable(feature = "rust1", since = "1.0.0")]
pub fn swap<T>(x: &mut T, y: &mut T) {
    // SAFETY: the raw pointers have been created from safe mutable references satisfying all the
    // constraints on `ptr::swap_nonoverlapping_one`
    unsafe {
        ptr::swap_nonoverlapping_one(x, y);
    }
}

// 这里提到block optimization，当它较小时进行copy，较大时进行swap
// 不过现在先看copy
#[inline]
pub(crate) unsafe fn swap_nonoverlapping_one<T>(x: *mut T, y: *mut T) {
    // For types smaller than the block optimization below,
    // just swap directly to avoid pessimizing codegen.
    if mem::size_of::<T>() < 32 {
        let z = read(x);
        copy_nonoverlapping(y, x, 1);
        write(y, z);
    } else {
        swap_nonoverlapping(x, y, 1);
    }
}

// rust-intrinsic 包装了编译器内置的函数，就像i32是内置的类型一样。这样可以提供很多有用的元信息便于编译器做优化,目前大部分rustc的内置函数调用的是llvm的编译内置函数。比如这个就是调用的llvm.memcpy。
#[doc(alias = "memcpy")]
#[stable(feature = "rust1", since = "1.0.0")]
#[inline]
pub unsafe fn copy_nonoverlapping<T>(src: *const T, dst: *mut T, count: usize) {
    extern "rust-intrinsic" {
        fn copy_nonoverlapping<T>(src: *const T, dst: *mut T, count: usize);
    }

    debug_assert!(is_aligned_and_not_null(src), "attempt to copy from unaligned or null pointer");
    debug_assert!(is_aligned_and_not_null(dst), "attempt to copy to unaligned or null pointer");
    debug_assert!(is_nonoverlapping(src, dst, count), "attempt to copy to overlapping memory");
    copy_nonoverlapping(src, dst, count)
}
```

这里再看`read`和`write`：
```rust
// 读取值，但不消耗所有权
#[inline]
#[stable(feature = "rust1", since = "1.0.0")]
pub unsafe fn read<T>(src: *const T) -> T {
    // `copy_nonoverlapping` takes care of debug_assert.
    let mut tmp = MaybeUninit::<T>::uninit();
    copy_nonoverlapping(src, tmp.as_mut_ptr(), 1);
    tmp.assume_init()
}

// 写入值，消耗src所有权，同时不drop两个值。即手动内存泄漏。
// 所以最好在初始化一个未初始化的内存，或者覆盖一个被read过的内存时使用。
#[inline]
#[stable(feature = "ptr_unaligned", since = "1.17.0")]
pub unsafe fn write_unaligned<T>(dst: *mut T, src: T) {
    // `copy_nonoverlapping` takes care of debug_assert.
    copy_nonoverlapping(&src as *const T as *const u8, dst as *mut u8, mem::size_of::<T>());
    mem::forget(src);
}

```

接下来是块优化，总结就是一次性转移4个8字节大小的块。
```rust
#[inline]
unsafe fn swap_nonoverlapping_bytes(x: *mut u8, y: *mut u8, len: usize) {
    // The approach here is to utilize simd to swap x & y efficiently. Testing reveals
    // that swapping either 32 bytes or 64 bytes at a time is most efficient for Intel
    // Haswell E processors. LLVM is more able to optimize if we give a struct a
    // #[repr(simd)], even if we don't actually use this struct directly.
    //
    // FIXME repr(simd) broken on emscripten and redox
    #[cfg_attr(not(any(target_os = "emscripten", target_os = "redox")), repr(simd))]
    struct Block(u64, u64, u64, u64);
    struct UnalignedBlock(u64, u64, u64, u64);

    let block_size = mem::size_of::<Block>();

    // Loop through x & y, copying them `Block` at a time
    // The optimizer should unroll the loop fully for most types
    // N.B. We can't use a for loop as the `range` impl calls `mem::swap` recursively
    let mut i = 0;
    while i + block_size <= len {
        // Create some uninitialized memory as scratch space
        // Declaring `t` here avoids aligning the stack when this loop is unused
        let mut t = mem::MaybeUninit::<Block>::uninit();
        let t = t.as_mut_ptr() as *mut u8;
        let x = x.add(i);
        let y = y.add(i);

        // Swap a block of bytes of x & y, using t as a temporary buffer
        // This should be optimized into efficient SIMD operations where available
        copy_nonoverlapping(x, t, block_size);
        copy_nonoverlapping(y, x, block_size);
        copy_nonoverlapping(t, y, block_size);
        i += block_size;
    }

    if i < len {
        // Swap any remaining bytes
        let mut t = mem::MaybeUninit::<UnalignedBlock>::uninit();
        let rem = len - i;

        let t = t.as_mut_ptr() as *mut u8;
        let x = x.add(i);
        let y = y.add(i);

        copy_nonoverlapping(x, t, rem);
        copy_nonoverlapping(y, x, rem);
        copy_nonoverlapping(t, y, rem);
    }
```

接下来就是llvm的内容了，这里的extern源码见<https://github.com/rust-lang/rust/tree/master/compiler/rustc_codegen_llvm>

llvm见<https://www.llvm.org/docs/LangRef.html>




## 理解 core::iter::Range

### 总结

Range实现了Iterator，它首先检查并获得后继，然后通过`swap`写入。



### 分析

使用 for-loop 就可以知道，Range是一个迭代器。

注意 for-loop 可以看成是一个 loop match option 三者组成的语法糖。

其next函数是这样：

```rust
#[inline]
fn next(&mut self) -> Option<A> {
    if self.start < self.end {
        // SAFETY: just checked precondition
        // We use the unchecked version here, because
        // this helps LLVM vectorize loops for some ranges
        // that don't get vectorized otherwise.
        let n = unsafe { Step::forward_unchecked(self.start.clone(), 1) };
        Some(mem::replace(&mut self.start, n))
    } else {
        None
    }
}
```

注意`Step::forward_unchecked`底层是使用llvm提供的函数检查后继是否存在，不存在即`panic`（由`Option::expect`触发）。这个没什么好说的。

重要的是`mem::replace`，它的实现如下，调用了`swap`：
```rust
#[inline]
#[stable(feature = "rust1", since = "1.0.0")]
#[must_use = "if you don't need the old value, you can just assign the new value directly"]
pub fn replace<T>(dest: &mut T, mut src: T) -> T {
    swap(dest, &mut src);
    src
}
```

`std::mem::swap`与`std::mem::replace`的区别只是replace会返回目标的所有权。



## 理解 std::mem::take

### 总结

只是用default值来与原来的内容做`replace`，移动原值的所有权。
常用于从`&mut Option`中取所有权。
不使用`take`的话，会存在`cannot move out of 'foo' which is behind a mutable reference`错误。
同时注意，如果使用`take`意味着原位置将变为`default`。
所以当数据结构不需要这个值时，`take`才适用。
比如链表删除节点。



### 分析

源码如下：
```rust
#[inline]
#[stable(feature = "mem_take", since = "1.40.0")]
pub fn take<T: Default>(dest: &mut T) -> T {
    replace(dest, T::default())
}
```



## 理解 `？`错误处理

### 总结
是`try!`的一个语法糖，内部通过match来返回正常值、return错误。



### 分析

```rust
#[macro_export]
#[stable(feature = "rust1", since = "1.0.0")]
#[rustc_deprecated(since = "1.39.0", reason = "use the `?` operator instead")]
#[doc(alias = "?")]
macro_rules! r#try {
    ($expr:expr) => {
        match $expr {
            $crate::result::Result::Ok(val) => val,
            $crate::result::Result::Err(err) => {
                return $crate::result::Result::Err($crate::convert::From::from(err));
            }
        }
    };
    ($expr:expr,) => {
        $crate::r#try!($expr)
    };
}
```



## 理解`flatten`

### 总结

`Flatten`调用并返回内容的`into_iter`。

### 分析

首先来看`Flatten`trait，它包含了一个`FlattenCompat`。
注意！此处的`Item`必须实现`IntoIterator`，也就是只有`IntoIterator`作为`Item`才可以满足`Flatten`。

```rust
impl<I: Iterator<Item: IntoIterator>> Flatten<I> {
    pub(in super::super) fn new(iter: I) -> Flatten<I> {
        Flatten { inner: FlattenCompat::new(iter) }
    }
}

#[inline]
fn next(&mut self) -> Option<U::Item> {
    self.inner.next()
}
```

接下来看`FlattenCompat`，它包含了`Fuse`。
`Fuse`是熔断迭代器，当首次遇到`None`时，之后的内容就一直是`None`了。

```rust
impl<I, U> FlattenCompat<I, U>
where
    I: Iterator,
{
    fn new(iter: I) -> FlattenCompat<I, U> {
        FlattenCompat { iter: iter.fuse(), frontiter: None, backiter: None }
    }
}

#[inline]
fn next(&mut self) -> Option<U::Item> {
    loop {
        if let Some(ref mut inner) = self.frontiter {
            match inner.next() {
                None => self.frontiter = None,
                elt @ Some(_) => return elt,
            }
        }
        match self.iter.next() {
            None => return self.backiter.as_mut()?.next(),
            Some(inner) => self.frontiter = Some(inner.into_iter()),
        }
    }
}
```

那么事实上，`Flatten`只是调用了`Item`的`into_iter`，同时再做`Option`解构，将所有`Some`内容返回。

### 举例

```rust
let xs = (0..10)
    .map(|x| {
        if x % 2 == 0 {
            Ok(x)
        } else {
            Err("xxx")
        }
    })
    .flatten()
    .collect::<Vec<i32>>();

println!("{:?}", xs);
```

我们分析一下:
1. `flatten`操作调用`Result`的`into_iter`
2. `Result`的`IntoIterator`如下：
    ```rust
    #[inline]
    fn into_iter(self) -> IntoIter<T> {
        IntoIter { inner: self.ok() }
    }
    ```
    实际得到内容为`Ok`的`IntoIterator<Option<i32>>`
3. `inner.next()`并解构，得到`i32`
4. 输出所有偶数

简单分析的话（`Flatten`调用并返回内容的`into_iter`）：
那么`Result`的`IntoIterator`返回了`Ok`的`Option<T>`，这个值直接作为`Flatten`迭代器的返回值。
那么通过`collect`，结果就是所有`Ok`的内容。



## 如何构建更好的 Rust CLI 应用

好的CLI应用应该包括：
1. 参数获取: `clap`
2. 配置文件: `dotenv`
3. 环境变量: `env::vars()` `env::var_os()`是应用间调用的一个方法，如`Cargo`和`rustc`
4. 错误处理: 见下文，同时主函数应只接受参数，同时接受内部的`Result`使用`process::exit(1)`退出
5. 杂项：错误输出`eprintln`，退出码`process::exit`

另外每个实际项目都应该编写rust文档，<https://rust-lang.github.io/api-guidelines/documentation.html>这里提供了编写更好文档的一些要求。



## 关于错误处理的设计

- 如果你在写短小的演示代码（比如算法题目）：  
使用`unwrap`和`except`处理错误

- 如果你在写一个简单的程序（且不怕别人接手的时候感到难受）：  
使用`Box<dyn Error>`或`Box<dyn Error + Send + Sync>`。  
另一个省事的选择是使用`anyhow::Error`，他会自动打印backtrace。  

- 如果你在写一个正式的项目：  
  定义自己的`Error`，并实现`Error` trait 和 `From` trait。  
  同时在`Option`和`Result`上使用组合子和`?`操作符。  
  常用的组合子包括：`map`, `and_then`, `unwrap_or`, `unwrap_or_else`, `ok_or`用于`Option`转`Result`.

  

### 如何自定义`Error`

1. 使用`enum`  
    可以存各种其他库的错误类型
2. 实现`Error: Debug + Display` trait 中的`description`和`cause ` 
    前者便于展示错误原因，后者用于检查错误链  
    （同时`Error`可以被装入`Box<dyn Error>`中，不过在自己的库中，`Result<_, MyError>`更为常见  
3. 实现`From<OtherError>` trait   
    便于错误向上转换到我们的错误类型  
    注意`try!`中的模式匹配，显式的使用`From::from`来转换`Error`  



### 如何使用`failure`第三方库

化简一下第三方库文档，便于记忆使用
1. 原型或不需要错误链的情况  
    使用`Rusult<(), failure::Error>`和`format_err!()`
    前者可以转换`impl Fail`对象，后者直接返回字符串错误
2. 大型项目或需要错误链情况  
    自定义`Error`和`ErrorKind`
    例：
    ```rust
    #[derive(Debug)]
    struct MyError {
        inner: Context<MyErrorKind>,
    }

    #[derive(Copy, Clone, Eq, PartialEq, Debug, Fail)]
    enum MyErrorKind {
        #[fail(display = "A contextual error message.")]
        OneVariant,
    }

    // 样板代码
    impl Fail for MyError {
        fn cause(&self) -> Option<&Fail> {
            self.inner.cause()
        }

        fn backtrace(&self) -> Option<&Backtrace> {
            self.inner.backtrace()
        }
    }

    impl Display for MyError {
        fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
            Display::fmt(&self.inner, f)
        }
    }

    // 样板代码
    impl MyError {
        pub fn kind(&self) -> MyErrorKind {
            *self.inner.get_context()
        }
    }

    impl From<MyErrorKind> for MyError {
        fn from(kind: MyErrorKind) -> MyError {
            MyError { inner: Context::new(kind) }
        }
    }

    impl From<Context<MyErrorKind>> for MyError {
        fn from(inner: Context<MyErrorKind>) -> MyError {
            MyError { inner: inner }
        }
    }
    ```


## 常用框架

- `clap`：CLI参数读取
- `serde`：序列化 & 反序列化
- ~~`Rayon`：简单易用的并行计算库~~
- ~~`Crossbeam`：扩展标准库功能的并发库~~
- ~~`Tokio`：Actor模型库~~



# 参考资料

- [Write a Good CLI Program](https://qiita.com/tigercosmos/items/678f39b1209e60843cc3)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [rust-lang-nursery](https://github.com/rust-lang-nursery)
- [Error Handling in Rust](https://blog.burntsushi.net/rust-error-handling/)

