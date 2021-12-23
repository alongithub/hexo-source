---
title: JS异步编程
date: 2020-08-26 17:29:44
description: js异步编程概述
# toc: true
tags: 
    - notes
    - javascript 
    - 异步编程
---

javascript最初设计为了实现页面的交互操作，为了避免不同线程同时处理dom导致无法判断以那个结果为准，所以不得不采用单线程模式工作，

- 同步模式与异步模式
- 事件循环与消息队列
- 异步编程方式
- Promise异步方案、宏任务/微任务
- Generator异步方案、Async/Await语法糖

### 同步模式，排队执行
js通过调用栈执行函数语句，正在执行的操作会入栈，操作完成后出栈
耗时操作会阻塞后边函数的执行

### 异步模式
开始执行后，js现成遇到异步操作会将异步操作放入异步调用线程（web APIs），之后立即开始下一个任务。
异步调用线程会在异步执行完成后，将回调函数压入消息队列中
在js主线程的函数栈操作完毕后，Event Loop 会循环将回调函数取出回调函数交给主线程执行

{% asset_img yibu.png %}
运行环境提供的API是以同步或者异步模式的方式工作的，比如console.log()会在主线程同步执行，当执行setTimeout时会交给异步线程去处理。

### 回调函数-异步编程方案的根基
回调函数
事件机制
发布订阅

### Promise
三种状态
Pending、Fulfilled、Rejected。
Promise执行完成后的状态不可被改变

```js
const promise = new Promise(function(resolve, reject) {
    // resolve 和 reject 函数只能执行一个
    resolve(100);

    // reject(new Error('promise rejected'));
})

promise.then(function(res) {
    console.log(res);
}, function(res) {
    console.log(res)
})
```
#### 链式调用
Promise then方法会返回一个新的Promise对象

```js
const promise = new Promise((resolve, reject) => {
    resolve(123);
})

const promise2 = promise.then(res => {
    console.log(res);
})
console.log(promise === promise2); // false
```

前面then方法回调函数的返回值会作为后面then 方法回调的参数
后面的then方法实际上是为上一个then方法返回的promise注册回调

```js
new Promise((resolve, reject) => {
    resolve(123)
}).then(res => {
    console.log(res); // 123
}).then(res => {
    console.log(res); // undefined  // 上一个函数没有返回一个新的Promise或者数值，所以res是undefined
    return new Promise((resolve, reject) => {
        resolve('上个then中返回的Promse结果')
    })
}).then(res => {
    console.log(res); // 上个then中返回的Promse结果  // 如果上个then函数返回了新的Promise， 相当于执行返回的Promise的then（）函数
})
```

#### 异常处理

如果promise执行中遇到了抛出异常，就会执行 onRejectd 函数

```js
new Promise((resolve, reject) => {
    throw new Error('手动抛出异常');
    resolve(123)
}).then(res => {
    console.log(res); // undefined  // 上一个函数没有返回一个新的Promise或者数值，所以res是undefined  
}, err => {
    console.log(err);
})


// Error: 手动抛出异常
```

上面的方式可以写成在最后添加catch方法的方式，在promise中异常会通过他很方法向后传递，因此在最后添加catch（）方法可以捕获整个链式过程中抛出的异常，相当于为整个Promise链条注册的失败回调

```js
new Promise((resolve, reject) => {
    throw new Error('手动抛出异常');
    resolve(123)
}).then(res => {
    console.log(res); // undefined  // 上一个函数没有返回一个新的Promise或者数值，所以res是undefined  
}).catch(err => {
    console.log(err);
})

// 相当于 
new Promise((resolve, reject) => {
    throw new Error('手动抛出异常');
    resolve(123)
}).then(res => {
    console.log(res); // undefined  // 上一个函数没有返回一个新的Promise或者数值，所以res是undefined  
}).then(undefined, err => {
    console.log(err);
})
```

当然也可以在全局为出现异常的Promise 添加异常处理，不过这种方式不推荐，因改为每一个promise添加特定的异常处理
浏览器环境

{% asset_img 2.png %}

node环境

{% asset_img 3.png %}

#### 静态方法
Promise.resolve()        快速地把一个值转化为Promise对象

```js
Promise.resolve(true)
// Promise { true }

// 如果接受一个Promise对象，则会返回该Promise对象
const promise = new Promise(resolve => {
    resolve(1);
})
Promise.resolve(promise) === promise
// true

// 实现 thenable 接口
Promise.resolve({
    then: function(onResolve, onReject) {
        onResolve('thenable');
    }
}).then(res => {
    console.log(res);
})
```

Promise.reject()     返回一个失败地Promise对象

#### Promise 并行执行 
 - Promise.all()
多个Promise 合并为一个Promise，会在下个then方法传递给回调函数 结果数组，需要注意all方法中地任意一个Promise执行了reject（）方法或者抛出异常，会导致触发整个Promise.all返回的Promise对象执行onReject回调

```js
  
const p1 = new Promise(resolve => {
    setTimeout(() => {
        resolve(1000)
    }, 1000)
})

const p2 = new Promise(resolve => {
    setTimeout(() => {
        resolve(5000)
            }, 5000)
})

Promise.all([p1, p2]).then(values => {
    console.log(values);
})

// [ 1000, 5000 ]   // 5 s 后
```

- Promise.race();
Promise.race()方法同样会合并多个Promise，与all()不同的是，race方法会等待第一个完成的任务，并向后传递第一个执行完成的任务的结果

```js
  const p1 = new Promise(resolve => {
    setTimeout(() => {
        resolve(1000)
    }, 1000)
})

const p2 = new Promise(resolve => {
    setTimeout(() => {
        resolve(5000)
    }, 5000)
})

Promise.race([p1, p2]).then(res => {
    console.log(res);
})

// 1000   // 1 s 后
```

#### 微任务，promise执行顺序
promise（除此之外还有MutationObserver对象，node中的process.nextTick）的回调会作为微任务执行，微任务会在当前任务执行结束后立即执行，不会在消息队列的队尾排队
类似setTimeout 等大部分异步调用都会作为宏任务 执行

```js
console.log('code start');

setTimeout(() => {
    console.log('setTimeout')
}, 0)

Promise.resolve('Promise').then(res => {
    console.log(res);
})

console.log('code end');

// code start
// code end
// Promise
// setTimeout
```

### Generator异步方案

生成器函数的调用会返回生成器对象而不是立即执行函数内容，只有调用生成器对象的next()方法函数才会开始执行
