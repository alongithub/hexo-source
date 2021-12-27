---
title: javascript 基础梳理
date: 2020-08-27 14:51:18
toc: true
description: js,es6面试题整理
tags: 
    - 面试题
    - javascript
---

## javascript

### 原型链继承

构造函数Person以及实例对象person在原型链上的关系，如图所示

{% asset_img prototype.png %}

每一个JavaScript对象(null除外)在创建的时候就会与之关联另一个对象，这个对象就是我们所说的原型，每一个对象都会从原型"继承"属性，实例对象可通过__proto__访问到对象的原型，这个原型指向构造函数的prototype。

每个原型都有一个 constructor 属性指向关联的构造函数

当读取实例的属性时，如果找不到，就会查找与对象关联的原型中的属性，如果还查不到，就去找原型的原型，一直找到最顶层为止

构造函数的constructor 指向 Function 构造器。

Function的原型指向Function.prototype

Function 的构造函数指向自己 Function.constructor === Function.__proto__.constructor === Function

构造函数、对象、原型之间的关系参考

{% asset_img 原型链继承.png %}

[js实现类的继承](https://www.cnblogs.com/yangdaren/p/10759868.html)

### 词法作用域

JavaScript 采用词法作用域(lexical scoping)，也就是静态作用域。因为 JavaScript 采用的是词法作用域，函数的作用域在函数定义的时候就决定了。

```js
var value = 1;

function foo() {
    console.log(value);
}

function bar() {
    var value = 2;
    foo();
}

bar();

// 1
```

```js
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f();
}
checkscope();
// local scope
```

```js
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f;
}
checkscope()();
// local scope
```

JavaScript 函数的执行用到了作用域链，这个作用域链是在函数定义的时候创建的

### 执行上下文

#### 执行上下文栈（函数调用栈）

JavaScript 引擎创建了执行上下文栈（Execution context stack，ECS）来管理执行上下文

为了模拟执行上下文栈的行为，让我们定义执行上下文栈是一个数组：
```js
ECStack = [];
```

初始化的时候首先就会向执行上下文栈压入一个全局执行上下文，我们用 globalContext 表示它，并且只有当整个应用程序结束的时候，ECStack 才会被清空，所以程序结束之前， ECStack 最底部永远有个 globalContext：

```js
ECStack = [
    globalContext
];
```

以下方两段代码为例

```js
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f();
}
checkscope();

// ECStack.push(<checkscope> functionContext);
// ECStack.push(<f> functionContext);
// ECStack.pop();
// ECStack.pop();
```

```js
var scope = "global scope";
function checkscope(){
    var scope = "local scope";
    function f(){
        return scope;
    }
    return f;
}
checkscope()();

// ECStack.push(<checkscope> functionContext);
// ECStack.pop();
// ECStack.push(<f> functionContext);
// ECStack.pop();
```

#### 全局上下文和函数上下文的变量对象

程序初始化时引擎会在执行上下文栈创建全局上下文globalContext,函数调用时会创建函数上下文functionContext

执行上下文包含三个部分
- 变量对象（variable object, VO）
- 作用域链（scope chain）
- this


- 全局上下文变量对象就是全局对象
- 函数上下文的变量对象
以下方函数代码为例
```js
function foo(a) {
  var b = 2;
  function c() {}
  var d = function() {};

  b = 3;

}

foo(1);
```

函数创建时先初始化变量对象，只包含arguments
进入函数上下文时，再在变量对象上添加形参、函数声明、变量声明等

```js
AO = {
    arguments: {
        0: 1,
        length: 1
    },
    a: 1,
    b: undefined,
    c: reference to function c(){},
    d: undefined
}
```

在代码执行阶段，会再次修改变量对象的属性值

```js
AO = {
    arguments: {
        0: 1,
        length: 1
    },
    a: 1,
    b: 3,
    c: reference to function c(){},
    d: reference to FunctionExpression "d"
}
```

参考[javascript深入之变量对象](https://github.com/mqyqingfeng/Blog/issues/5)

##### 函数执行上下文，写出打印结果

```js
function foo() {
    console.log(a);
    a = 1;
}

foo(); // ???

function bar() {
    a = 1;
    console.log(a);
}
bar(); // ???
```
第一段会报错：Uncaught ReferenceError: a is not defined。

第二段会打印：1。

这是因为函数中的 "a" 并没有通过 var 关键字声明，所有不会被存放在 AO 中。

第一段执行 console 的时候， AO 的值是：
```js
AO = {
    arguments: {
        length: 0
    }
}
```
没有 a 的值，然后就会到全局去找，全局也没有，所以会报错。

当第二段执行 console 的时候，全局对象已经被赋予了 a 属性，这时候就可以从全局找到 a 的值，所以会打印 1。

##### 函数执行上下文，写出打印结果2

```js
console.log(foo);

function foo(){
    console.log("foo");
}

var foo = 1;
```
会打印函数，而不是 undefined 。

这是因为在进入执行上下文时，首先会处理函数声明，其次会处理变量声明，如果如果变量名称跟已经声明的形式参数或函数相同，则变量声明不会干扰已经存在的这类属性。

`function foo()` 与 `var foo = 1`顺序改变也一样

#### 作用域链

当查找变量的时候，会先从当前上下文的变量对象中查找，如果没有找到，就会从父级(词法层面上的父级)执行上下文的变量对象中查找，一直找到全局上下文的变量对象，也就是全局对象。这样由多个执行上下文的变量对象构成的链表就叫做作用域链。


> 使用Function构造器生成的函数，并不会在创建它们的上下文中创建闭包；它们一般在全局作用域中被创建。当运行这些函数的时候，它们只能访问自己的本地变量和全局变量，不能访问Function构造器被调用生成的上下文的作用域。这和使用带有函数表达式代码的 eval 不同。

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

### 防抖和节流
防抖动是将多次执行变为最后一次执行，节流是将多次执行变成每隔一段时间执行。
#### 说一下防抖函数的应用场景，并简单说下实现方式 
（滴滴）

防抖动是将多次执行变为最后一次执行，只在特定的时间内没有触发执行条件才执行一次代码
1、应用场景，输入框模糊搜索功能，点赞取消点赞等功能
2、实现方式，每次触发事件时设置一个延时器，并且取消之前的延时器
```js
function debounce(fn) {
  let timeout = null; 
  return function() {
    clearTimeout(timeout); // 每当触发的时候把前一个 setTimeout清除
    timeout = setTimeout(() => {
      fn.apply(this, arguments);
    }, 500);
  };
}

function sayHi() {
  console.log("搜索到相关内容");
}

var inp = document.getElementById("inp");
inp.addEventListener("input", debounce(sayHi)); // 防抖
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

## 性能优化
### 垃圾回收 GC
#### 说一下v8的垃圾回收机制

v8内存设有上先，采用分代回收的思想，内存分为新生代和老生代，小空间用于存储新生代对象（32M|16M),新生代存放存活时间较短的对象（如局部作用域变量）
{% asset_img v8.png %}
- 新生代对象回收，新生代中用 Scavenge 算法来处理
    - 通过标记整理和复制算法实现
    - 新生代内存会等分为两个空间，使用状态空间称为From，空闲空间称为To空间，From空间用于存储活动对象。
    - 当对象区域快被写满时，就需要执行一次垃圾清理操作。对From空间执行标记，之后会把存活对象复制到To空间，并有序排列起来
    - 接下来两个空间角色互换，直接释放掉原来的From空间

- 一轮GC操作之后还存活的对象会晋升到老生代内存中，如果To空间使用率超过25%，新生代的对象也会晋升到老生代内存中(老生代对象回收，64位 1.4G 32 位 700M),老生代会存储 全局变量下的对象，一部分闭包中的数据
    - 老生代中采用 标记清除、标记整理、增量标记算法
    - 通过标记清除完成垃圾空间的回收
    - 采用标记整理进行空间优化，老生代不足以存储即将存储的对象，会触发标记整理操作
    - 采用增量标记进行效率优化，GC操作会阻塞程序的执行，增量标记将整个标记过程拆分开来，每一个片段与程序执行交替进行。最后阻塞程序执行清除操作

{% asset_img old.png %}

## 浏览器

### 浏览器从输入url到页面展示，这中间发生了什么

1、用户输入内容，浏览器会判断用户输入是搜索内容还是url
- 如果是关键字，浏览器根据搜索引擎，合成携带关键字的url
- 如果是url，浏览器会拼接上协议，合成完整的url
- 在这之前，浏览器会判断当前页的beforeunload事件，判断是否组织页面跳转
  
2、通过url请求资源，浏览器进程通过（IPC）把url发送给网络进程，网络进程发起请求
首先网络进程会判断本地缓存是否缓存了该资源，如果有直接返回给浏览器进程，如果没有该资源，进入网络请求流程
- 通过DNS解析获取IP地址，如果是https,还需要建立TLS连接
- 通过IP与服务器建立TCP连接，建立连接后，浏览器会构建请求行请求头等信息，并把cookie相关信息添加到请求头中，然后发送给服务器
- 服务器根据请求信息生成响应数据（响应行，响应头，响应题），并发送给网络进程
- 网络进程拿到响应数据后，会判断响应行的响应状态，如果是301或302，说明服务器需要浏览器重定向到其他 URL。这时网络进程会从响应头的 Location 字段里面读取重定向的地址，然后再发起新的 HTTP 或者 HTTPS 请求，重新开始网络请求流程
- 如果响应行状态是200，浏览器会判断响应头的Content-type,如果是下载类型数据，提交给浏览器的下载管理器，同时该 URL 请求的导航流程就此结束，如果是text/html,浏览器会继续执行导航流程，准备渲染进程
  
3、浏览器将网络进程接收到的html数据提交给渲染进程
- 首先当浏览器进程接收到网络进程的响应头数据之后，便向渲染进程发起“提交文档”的消息；
- 渲染进程接收到“提交文档”的消息后，会和网络进程建立传输数据的“管道”；
- 等文档数据传输完成之后，渲染进程会返回“确认提交”的消息给浏览器进程；
- 浏览器进程在收到“确认提交”的消息后，会更新浏览器界面状态，包括了安全状态、地址栏的 URL、前进后退的历史状态，并更新 Web 页面。
  
4、进入渲染流程，展示页面内容

### 浏览器渲染流程
渲染流程就是讲javascript、html、css经过渲染模块的处理，最终输出为屏幕上的像素

1、构建DOM树，渲染进程将 HTML 内容转换为能够读懂的 DOM 树结构

2、样式计算（Recalculate Style）
 -  处理样式表内容为浏览器可理解的结构stylesheets
 -  标准化样式表中的属性值，比如blod，red，2em等属性值
 -  根据继承和层叠规则计算DOM节点的样式  

3、布局阶段，计算出 DOM 树中可见元素的几何位置
- 创建布局树（不包含head标签和display：none等不可见元素）
- 布局计算，计算布局树节点的布局信息

4、分层，为特定的节点生成专用的图层，并生成一棵对应的图层树（LayerTree）
 - 明确定位属性的元素、定义透明属性的元素、使用 CSS 滤镜的元素等，都拥有层叠上下文属性
 - 需要剪裁（clip）的地方也会被创建为图层
  
5、图层绘制（Paint）为每个图层生成绘制指令列表，图层的绘制拆分成很多小的绘制指令，然后再把这些指令按照顺序组成一个待绘制列表

6、图块与栅格化（raster）
主线程将图层绘制列表提交给渲染进程合成线程，合成线程会将图层划分为图块。并按照视口附近的图块来优先生成位图（栅格化）
- 栅格化的过程在渲染进程维护的栅格化线程池中进行
- 栅格化线程池中的线程通常借助GPU生成位图（快速栅格化）

7、合成和显示
- 图块光栅化之后，合成线程生成DrawQuad命令，通知浏览器将页面绘制到内存中，生成页面，并展示到屏幕上
  

{% asset_img raster.png %}
{% asset_img raster2.png %}
