<!-- vim-markdown-toc Marked -->

* [理解 std::mem::swap](#理解-std::mem::swap)
        * [总结](#总结)
        * [分析](#分析)
* [理解 core::iter::Range](#理解-core::iter::range)
        * [总结](#总结)
        * [分析](#分析)

<!-- vim-markdown-toc -->

记录一些rust学习过程中的细节。这些细节都是碎片式的，不容易整理成一个主题，所以暂时在notes标签下列出来。


# 理解 std::mem::swap

### 总结

`swap`表现为使用&mut来交换值，底层则使用裸指针和编译器内置的函数（本质llvm）实现，涉及了块优化（一次性转移4个8字节数据）、不消耗所有权的read、可能内存泄漏的write。



### 分析

它底层使用了编译器内置的函数，本质上是llvm提供的函数。

`std::mem::swap`与`std::mem::replace`的区别是replace会丢弃src的所有权。

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




# 理解 core::iter::Range

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

`std::mem::swap`与`std::mem::replace`的区别只是replace会丢弃src的所有权。

