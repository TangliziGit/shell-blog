# Learning NodeJS

## some skill & tools

1. `ack` 查找代码, 替代`grep -rn`  
2. `zeal` 文档支持  
3. `lsof -i:1080 | xargs killall` 杀死端口下进程  

## module & frameworks

1. `bluebrid` 提供性能最好的`Promise/a+`模块, 功能丰富, 兼容原声`Promise`


## CommonJS

1. `CommonJS` 是一套编写模块的规范  
2. `npm` 管理 `CommonJS` 规范下的模块  
3. 回调的风格是`error-first callback`
4. `module.exports` 才是真正的接口，`exports` 只不过是它的一个辅助工具  
5. 如果`module.exports`已经具备一些属性和方法，那么`exports`收集来的信息将被忽略  

## 异步

### Promise

0. `Promise/A+`规范，也就是实际上的业内推行的规范。es6也是采用的这种规范. 
1. `Promise`核心：将`callback`里的结果延后到`then`函数里处理或交给全局异常`catch`处理  
2. 可将嵌套式回调函数(异步)转变为链式, 避免因NodeJS的完全异步产生的`callback hell`  
3. `Promise.prototype.then`方法返回一个新的`Promise`, 其`resolve`函数的参数是`then`的函数的返回值.
4. `then` 方法所有的默认参数为`x => x`, `Promise`链呈现一个菱形执行链  
5. `Promise` 的api封装, 一般用法和链式用法:
```
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
