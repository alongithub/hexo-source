---
title: javascript面试题
date: 2020-08-27 14:51:18
toc: true
description: js,es6面试题整理
tags: 
    - 面试题
    - javascript
---

## javascript

### this 指向

#### 按顺序写出控制台打印结果
（2020 碧桂园）
```js
var User = {
    count:1,
    action:{
        getCount:function () {
            return this.count
        }
    }
}

var getCount = User.action.getCount;

setTimeout(() => {
    console.log("result 1",User.action.getCount())
})
console.log("result 2",getCount())
```

```js
// result 2, undefined
// result 1, undefined
```
## ES6

### Proxy

#### 基于es6的proxy方法设计一个属性拦截读取操作

要求实现去访问目标对象example中不存在的属性时，抛出错误：Property “$(property)” does not exist （2018 今日头条）

```js
// 案例代码
const man = {
    name:'jscoder',
    age:22
}
//补全代码
const proxy = new Proxy(...)
proxy.name   // "jscoder"
proxy.age     // 22
proxy.location   // Property "$(property)" does not exist
```

```js
// 答案
const proxy = new Proxy(man, {
    get(target, property) {
        return property in target ? target[property] : console.error(`Property "${property}" does not exist`);
    },
})
```