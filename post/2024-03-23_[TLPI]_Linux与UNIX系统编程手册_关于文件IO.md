# Chapter 4. 文件 I/O之通用的 I/O 模型

文件描述符用以表示所有类型的已打开文件：管道、FIFO、socket、终端、设备和普通文件
4个主要的系统调用：

```
int fd 		= open(path, flags, mode)	// fd: 总是非负整数；mode：当open创建文件时设定的权限
ssize_t n 	= read(fd, buf, count)		// 无字节读出时，返回0；出现错误时，返回-1
ssize_t n 	= write(fd, buf, count)
int status 	= close(fd)
off_t off	= lseek(fd, offset, whence)
int 		= ioctl(fd, request, ...)	// 为具体设备执行某种操作
```

通用IO：使用 4 个同样的系统调用可以对所有类型的文件执行 I/O 操作，包括/dev/tty、/dev/pts/1等。
  - 但需要确保这种设备驱动程序实现了IO调用集。
打开文件：open
  - 早期Unix使用012代表只读、只写和读写，大多数现代OS兼容这种模式。所以O_RDWR 并不等同于 O_RDONLY | O_WRONLY，后者属于逻辑错误。
  - **新建文件的访问权限不仅仅依赖于参数 mode，而且受到进程的 umask 值和(可能存在的)父目录的默认访问控制列表(17.6 节)影响。**
  - SUSv3 规定,如果调用 open()成功，必须保证其返回值为进程未用文件描述符中数值最小者。
关于打开文件的flag
  - ![2023-11-24_11-56.png](../assets/2023-11-24_11-56_1700798221300_0.png)
  - flags由三部分组成：文件访问模式、文件创建模式、文件状态标志（追加写、同步写、非阻塞、...）。
  	- 文件访问模式标志：O_RDONLY、O_WRONLY 和 O_RDWR，能够被检索
  	- 文件创建模式：仅用于创建文件时起效。不能检索，也无法修改。因为没有意义。
  	- 文件状态标志：可以检索和修改
  - `/proc/<pid>/fdinfo/`目录下的文件记录了该进程的已打开文件描述符，记录了偏移量、文件状态标志和mnt_id。可参考man 5 proc
  - O_ASYNC：当可以实施IO操作时，内核发送信号通知，称为信号驱动IO。Linux里open使用它是没有作用的。
  - O_CREAT：必须指定mode，否则会使用栈上的垃圾值。
  - O_SYNC：每次write做fsync。O_DSYNC与之类似，仅当文件属性更新时再fsync。O_RSYNC是指read等待所有写操作完成，Linux上与O_SYNC是一致的实现。
  - O_EXCL：如果创建文件时该文件存在，那么open失败。在实现文件锁时可以保证检查存在和创建文件的原子性。
  - **O_NOATIME：Linux的非标准扩展。**该标志的使用**能够显著减少磁盘的活动量**,省却了既要读取文件内容,又要更新文件 i-node 结构中最近访问时间的繁琐,进而节省了磁头在磁盘上的反复寻道时间。实测BUF_SIZE==1024，SSD上大概有3%的读速度提升。
读数据：read
  - `sszie_t`是一个神奇的类型，能存储[-1, SSZIE_MAX]范围的数据。
  - 什么时候read / write返回值不等于count参数？对普通文件可能读到文件末尾，对其他文件看实现差异，如管道、FIFO、socket 或者终端。对于终端，读到回车即结束。
写数据：write
  - 对磁盘文件来说,造成“部分写”的原因可能是由于磁盘已满,或是因为进程资源对文件大小的限制
关闭文件：close
  - 当进程终止，自动回收fd。
  - 能够捕获的错误有：企关闭一个未打开的文件描述符，或者double-close，也能捕获特定文件系统在关闭操作中诊断出的错误条件。如NFS提交失败将做为close的失败原因。
设置文件偏移量：lseek
  - whence有三种基点：指代从头开始、从当前开始、从尾部开始。
  - lseek()调用只是调整内核中与文件描述符相关的文件偏移量记录,并没有引起对任何物理设备的访问。
  - lseek()并不适用于所有类型的文件。错误是ESPIPE
    id:: 6558eb9f-9679-4a53-92b3-e099bee3979d
空洞文件：hole file
  - 参考：[Linux空洞文件](https://banbanpeppa.github.io/2019/08/21/linux/holefile/https://banbanpeppa.github.io/2019/08/21/linux/holefile/)
  - lseek在尾部之后write / read会怎么样？read()调用将返回 0,表示文件结尾。write()函数可以在文件结尾后的任意位置写入数据。这被称为文件空洞，读取内容将是0。文件空洞可能会占用更少的磁盘空间。
  - 写入的空洞文件不会占用物理磁盘空间，读出的逻辑大小不变。系统并未fallocate长度。
问题：
  - 错误处理最佳实践？
  	- 对被调函数做特定的检验，例如对open、lseek做-1检查。当错误被发现，则检查errno即可。
  	- 对close而言，它会首先删除打开文件描述符。可以理解其返回的错误码仅用于通知。如果使用stdio库函数，推荐做法是先fflush再fclose，fflush是可以重试的。
  - ssize_t是怎么存储和表达的？
  - EOF是read的errno么？什么时候会出现？
  	- 不是，是libc的stdio定义的标志，用于getc之类函数返回值判断文件结尾。
  - 空洞文件在内核中如何实现？

# Chapter 5. 深入探究文件 I/O

本章系统调用:
```
int fcntl(int fd, int cmd, ...);
int dup(int old_fd);
int dup2(int old_fd, int new_fd);
int dup3(int old_fd, int new_fd, int flags);

ssize_t pread  (int fd,       void *buf, size_t count, off_t offset);
ssize_t pwrite (int fd, const void *buf, size_t count, off_t offset);
ssize_t readv  (int fd, const struct iovec *iov, int iovcount);
ssize_t writev (int fd, const struct iovec *iov, int iovcount);
ssize_t preadv (int fd, const struct iovec *iov, int iovcount, off_t offset);
ssize_t pwritev(int fd, const struct iovec *iov, int iovcount, off_t offset);

int truncate (const char *path, off_t length);
int ftruncate(int fd, 			off_t length);

// 以下不是系统调用
int mkstemp(char *template);
FILE *tmpfile();
```

系统调用的原子性
  - 所有系统调用都是以原子操作方式执行。（相当于对竞争资源上锁）
  - 例子：open with O_EXCL，write with O_APPEND
  - 有些文件系统(例如 NFS)不支持 O_APPEND 标志。内核会选择lseek+write的方式，做非原子调用，可能导致文件脏写（即写入被覆盖）。
**内核管理打开文件的方式：内核维护的三个结构**
  - ![2023-11-24_12-14.png](../assets/2023-11-24_12-14_1700799300884_0.png)
  - 进程级的^^文件描述符表^^：目前仅维护close-on-exec标志、文件指针
  - 系统级的^^打开文件表^^：维护offset、文件状态标志、inode指针
  - 文件系统的 i-node 表：维护文件基本属性
  - 一些特例：
  	- 同一进程的不同fd指向同一打开文件：dup和dup2可以产生
  	- 不同进程的同一fd指向同一打开文件：fork可以产生
  	- 不同进程的不同fd指向不同打开文件：open可以产生
  - 总结：只要共享一个打开文件表项，就会共享offset，会感应到其他线程或进程在操作。
文件控制：fcntl
  - F_GETFL：获取文件访问模式，文件状态标志
  - F_SETFL：仅设置文件状态标志，其他会被忽略。一些fd不是通过open开启的，所以存在仅能用fcntl的场景。
  - F_DUPFD：可以替换dup和dup2的调用。
  - F_DUPFD_CLOEXEC：可以替换dup3的调用。
复制fd：dup & dup2 & dup3
  - dup：意义在与复制出的两个fd共享同一个打开文件，即共享offset和文件状态。
  - dup2：会先close old_fd，再替换新的fd上去。一定小心close的错误会被忽略掉，最佳实践是先close再dup2。
  - dup3：在创建文件时添加状态标识，仅支持O_CLOEXEC，也就是进程级别的那个。
带偏移量的读写：pread & pwrite
  - 指定在文件头开始的偏移量上做IO，不修改当前打开文件表中的偏移量。**与lseek+read相比，pread系列减少一次系统调用次数，虽然IO时间才是真正的瓶颈。**
Scatter-Gather I/O: readv & writev
  - 注：「若因 iovcnt 参数值过大而失败，glibc外壳函数将拷贝数据，一次执行 read()或 write()调用」在glibc 2.20之后就会直接调用syscall，不做这种隐式开销的动作。
  - 这两个系统调用会放回实际读写长度，用户需要按iov的顺序，对读写边界做匹配。
截断文件：truncate & ftruncate
  - 若文件大小小于参数 length,调用将在文件尾部添加一系列空字节（可造成文件空洞）
  - truncate：需要整个路径都有x权限，且文件本身可写
  - ftruncate：需文件可写，且不修改偏移量
大文件IO：LFS系列
  - 为了解决32位体系架构中支持大于2^31-1次方字节存储设备的IO。（因为off_t是long类型只有4字节）64位则不需要用这些调用。（64位下数据类型变大的只有：指针、long、unsigned long从4变8）
  - 这些系统调用仅仅在原有名称后面带64，如lseek64(x, x, off64_t)。
  - 编译时只用开启_FILE_OFFSET_BITS为64，所有相关的 32 位函数和数据类型将自动转换为 64 位版本，例如,实际会将 open()转换为 open64(),数据类型 off_t 的长度也将转而定义为 64 位。几乎无需修改源码。
`/dev/fd`目录
  - **对于每个进程,内核都提供有一个特殊的虚拟目录/dev/fd（实际上是一个符号链接,链接到 Linux 所专有的/proc/self/fd 目录）**。例如`/dev/fd/0`相当于标准输入。
  - 打开/dev/fd 目录中的一个文件等同于复制相应的文件描述符
  - 这个机制在shell里比较有效，例如我需要将pipe作为某个输入文件参数：`ls | diff /dev/fd/0 other`
临时文件：mkstemp & tmpfile
  - 前者需要转递带`XXXXXX`的模板字符串，返回`O_RDWD | O_CREAT | O_EXCL`的fd。后者直接返回FILE stream。这两个都只是glibc提供的函数。
  - 前者为了防止有其他进程再次打开fd，通常用户会直接unlink掉再使用。后者内部会直接unlink。
问题：
  - 线程A打开一个fd，线程B之后删除它。那么线程A可以读到文件么？ls可以看到文件么？
  	- 可以，因为inode没有实际删除。当没有open时才删除。
  	- ls看不到
  - 线程A把一个fd传给线程B，线程B可以读数据么？存在并发问题么？会从哪里开始读数据？进程呢？（fork可以产生）
  	- 不会，所有syscall都是原子性。只要注意是乱序即可。因为共享同一个进程的fd表。
  	- 进程fork产生的两个相同fd，也是可以做到相同的事情。因为共享同一个打开文件项，共享offset。但是注意不共享close-on-exec
  - 为什么系统调用是原子性的？各个进程执行汇编的syscall进入内核态可以视为一次函数调用么？进程间有锁保护？
  	- 我认为应该理解成这些syscall内部是对竞争资源上锁，保证用户使用上都是原子的。

# Chapter 13. 文件 I/O 缓冲

TODO

