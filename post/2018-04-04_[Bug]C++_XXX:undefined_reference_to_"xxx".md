昨天写了个广义表，写完后用clang++编译，结果给我报了一个这样的错
```bash
tanglizi@archlinux ~/Code/cpp/DS/genlist $ clang++ main.cpp genlist.cpp -o main

/tmp/main-9e993f.o: In function `GenList<long>::GenList(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)':
main.cpp:(.text._ZN7GenListIlEC2ERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE[_ZN7GenListIlEC2ERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE]+0x19): undefined reference to `GenList<long>::update(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> > const&)'
clang-5.0: error: linker command failed with exit code 1 (use -v to see invocation)
```
可以看出是**连接器找不到函数的实现**
这就很难受了，明明是常见的类，咋就编译不过

这是我的文件（简略写了）
```cpp
// main.cpp
#include "genlist.h"
#include <string>
using namespace std;

int main(void){
    GenList<long> list(string("(1, 2, (3, 4), ())"));     //关键在这，连接器找不到构造函数的实现

    return 0;
}
```
```cpp
// genlist.h
#ifndef _GENLIST_H_
#define _GENLIST_H_

#include "genlistnode.h"
#include <iostream>
#include <string>
using namespace std;

template <class T>
class GenList{
public:
    GenList(const string &input){update(input)};    //看这里
    ...
private:
    ...
};

#endif // _GENLIST_H_
```
```cpp
// genlist.cpp
#include "genlist.h"

template <class T>
void GenList<T>::update(const string &input){    // 实现在这里
    if (input[0]=='('){
        int idx=1;
        head=createGenList(input, idx);
    }else
        throw "Expresion Error!";
}
```
该实现的都实现了，就是编译不过

最后发现当我**把模板去掉后，就可以编译通过了**
这是为啥？
因为编译器在编译的时候，按需要把模板类换成一般类来编译
然而g++不允许把模板类定义和模板类方法实现分离编译，最后就是连接器报错undefined reference
解决方法就是**将模板类和方法实现放在同一个头文件里编译**
好气