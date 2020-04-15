# Learning NodeJS

## some skill & tools

1. `ack` 查找代码, 替代`grep -rn`  
2. `zeal` 文档支持  
3. `lsof -i:1080 | xargs killall` 杀死端口下进程  
4. `bluebrid` 提供性能最好的`Promise/a+`模块, 功能丰富, 兼容原声`Promise`


## CommonJS

1. `CommonJS` 是一套编写模块的规范  
2. `npm` 管理 `CommonJS` 规范下的模块  
3. 回调的风格是`error-first callback`
4. `module.exports` 才是真正的接口，`exports` 只不过是它的一个辅助工具  
5. 如果`module.exports`已经具备一些属性和方法，那么`exports`收集来的信息将被忽略  

## 异步

1. `Promise`易于链式操作, `await`易于组合操作.  

### Promise

0. `Promise/A+`规范，也就是实际上的业内推行的规范。es6也是采用的这种规范. 
1. `Promise`核心：将`callback`里的结果延后到`then`函数里处理或交给全局异常`catch`处理  
2. 可将嵌套式回调函数(异步)转变为链式, 避免因NodeJS的完全异步产生的`callback hell`  
3. `Promise.prototype.then`方法返回一个新的`Promise`, 其`resolve`函数的参数是`then`的函数的返回值.
4. `then` 方法所有的默认参数为`x => x`, `Promise`链呈现一个菱形执行链  
5. `Promise`一旦创建, 其函数就开始异步执行(非惰性求值)  
5. `Promise` 的api封装, 一般用法和链式用法:
```javascript
// API封装
function readFile(filename) {
    return new Promise((resolve, reject) => {
        fs.readFile(filename, (err, data) => {
            // do something
            if (err) 
                reject(err);
            else
                resolve(data.toString());
        });
    })
};

// 一般用法
readFile('hello.txt').then(data => {
    console.log(data);
}).catch(err => {
    console.log(err);
});


// 链式用法
function writeFile(filename, data) {
    return new Promise((resolve, reject) => {
        fs.writeFile(..., (err, file) => {
            file.write(...);

            if (err) 
                reject(err);
            else
                resolve(data.toString());
        });
    });
}

function log(data) {
    return new Promise((resolve, reject) => {
        console.log(data);
        resolve(data);
    });
}

readFile('hello.txt')
    .then(log)
    .then(data => {
        return writeFile('word.txt', data).then(log);
    })
    .catch(err => {
        console.log(err);
    });
```

6. 其他方法`Promise.all`, `Promise.race`二者的`Promise`参数为并行的.  

### async & await

![](https://pic1.zhimg.com/v2-be8f674422c9f30ffeaee88477ad2c84_r.jpg)

1. `async`将函数返回值包装成`Promise`对象, `await` 作用于`Promise`上, 等待异步的返回.  
2. 当`await`发生时, `Promise`的拒绝状态由`try-catch`捕获.  
3. 由于`Promise`创建后立即异步执行, 以下例子可以提升速度:
```javascript
const sleep = (time) => {
    return new Promise((resolve, reject) => {
        setTimeout(() => resolve("done"), time);
    });
};

// slow
async function timeTest() {
  await sleep(3000);
  await sleep(3000);
  await sleep(3000);
}

// fast
async function timeTest() {
  const sleep1 = sleep(3000);
  const sleep2 = sleep(3000);
  const sleep3 = sleep(3000);

  await sleep1;
  await sleep2;
  await sleep3;
}
```
4. 注意`await`只能在`async`函数中执行, 一下代码提供一种执行思路:
```javascript
(async () => {
    // ...
})()
```

## 面向对象编程
<https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Classes>
<https://segmentfault.com/a/1190000015565616>

### ES5与ES6实现继承的原理

组合继承，即借用构造函数与原型链继承结合

### 其他语言如何实现继承？

TODO：python, jvm based, c++
