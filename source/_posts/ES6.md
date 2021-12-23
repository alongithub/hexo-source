---
layout: article
title: ES6
description: ES6 + 整理
toc: true
date: 2020-08-26 11:49:51
tags: [notes, javascript, es6]
    
---
## ES2015

### let块级作用域

### const
只读的let，不可以修改内存地址

### let,var,const 三者的区别
var声明的变量不存在块级作用域，并且存在变量提升，在变量声明之前使用可以取到一个undefined的值。
在最外层作用域生命的var变量会挂载到全局对象上
let和const声明的变量存在块级作用域，不会挂在到全局对象上。在声明之前使用会报错。let变量值可以随意赋值，const的值不允许改变，因此const在定义时必须初始化

``` javascript
var a = 'vara';
console.log('window.a: ', window.a); // vara

let b = 'letb';
console.log('window.b: ', window.b); // undefined

function bar() {
    c = 'bar_c';
    var d = 'bar_d';
    function foo() {
        e = 'foo_e';
        var f = 'foo_f';
    }
    foo();
    console.log('e: ', e); // foo_e
    console.log('window.e: ', window.e) // foo_e
    console.log('f: ', f); // test.html:24 Uncaught ReferenceError: f is not defined

}
bar()
console.log('window.c: ', window.c); // bar_c
console.log('c: ', c); // bar_C
console.log('window.d: ', window.d); // undefined
// console.log('d: ', d); // Uncaught ReferenceError: d is not defined
console.log('e: ', e); // foo_e
```

### 数组的解构

```js
const arr = [1, 2, 3]
const [a, b, c] = arr;
// a = 1
// b = 2
// c = 3

const [a, ...b] = arr;
// a = 1
// b = [2, 3]

// 解构时附默认值
const [a, b, c, d = 4] = arr;
// d = 4

const path = '2020/12/20';
const [, month] = path.split('/');
// month = 12
```

### 对象的解构
类似数组解构，除此之外，可以在解构时重命名
```js
const obj = {name: 'along'}
const {name: newName} = obj;
// newName = along

// 解构同时赋默认值
const {age: newAge = 24};
// newAge = 24;

// 简化代码
const {log} = console;
```
### 模板字符串

```js
const str = `
    可以支持换行
    可以支持插值，使用表达式
    ${name}
    ${1+1}
`   

// 模板字符标签函数
// 该用法会返回字符串数组和所有的插入值
console.log`hello ${'along'} age ${23}`
// ['hello ', ' age '], 'along', 23
alert``hello ${'along'} age ${23}`
// ['hello ', ' age '] 
```

### 字符串拓展方法

```js
const str = 'hello along'
includes('alo') // true

stratsWith('he') // true

endsWith('along') // true

```
### 参数默认值
```js
function add1(a = 2) {
   return a + 1 
}

add1() // 3
```

### 剩余参数

```js
function add(...args) {
    console.log(args);
}
add(1, 2, 3);
// [1, 2, 3]
```

### 展开数组 Spread
```js
const arr = [1, 2, 3];
// console.log.apply(console, arr)
console.log(...arr);
// 1 2 3
```

### 箭头函数
```js
// 简化代码
const add1 = num => num + 1;

// this指向
const name = 'along';
const people = {
    name: 'peoplename',
    fn: function() {
        console.log(this.name);
    },
    fn2: () => {
        console.log(this.name);
    }
}

people.fn(); // peoplename
people.fn2(); // ""  fn2 中的 this 指向 window 而不是 全局作用域的name
 ```

需要注意的是，箭头含数arguments 指向的对象并不是当前函数所属的argments，而是上级函数的arguments
```js
function a() {
    console.log(arguments);
    return () => {
        console.log(arguments);
    }
}

a(1,2)()

// [Arguments] { '0': 1, '1': 2 }
// [Arguments] { '0': 1, '1': 2 }
```

### 对象字面量 增强
```js
// 对象属性值简略写法
const name = 'along';
const obj = {
    name,
    // 函数的简写，注意这种方式同 
    // fn: function() {console.log(this.name)}
    // 其中的this取决于它的调用者
    fn() {
        console.log(this.name); 
    },
    // 计算属性名
    [1+2]: 3
}
```

### 对象扩展方法
#### object.assign
object.assign 将源对象中的属性复制到目标对象中  
```js 
const source1 = {
    a: 1,
}
const source2 = {
    b: 2,
    c: 3,
}
const target = {b: 4}
const res = Object.assign(target, source1, source2);
res === target // true  
```
将对象传给函数进行属性操作时，为了避免对原对象修改，在函数内部复制新的对象
```js
const obj = {name: 'along'};
function fn(tar) {
    // 参数是对象时tar是一个引用地址，指向参数的对象地址
    // 直接操作tar会改变参数的属性
    // tar.name = 'new along';
    
    const newobj = Object.assign({}, tar);
    newobj.name = 'new along';
    console.log(newobj);
    
}

fn(obj); // {name: 'new along'}
console.log(obj); // {name: 'along'}
```

可以通过Object.assign()为对象参数设置默认值、
```js
function fn(option) {
    const defaultparams = {
        page: 1,
        pagesize: 10,
        method: 'get',
    }
    const params = Object.assign({}, option, defaultparams);
    console.log(params);
}

const option = {
    method: 'post',
    url: 'localhost:8080',
}

fn(option)
```

#### Object.is()
判断两个值是否相等 
```js
0 == false // true
0 === false // false
+0 === -0 // true
NaN === NaN // false

Object.is(+0, -0); // false   
Object.is(NaN, NaN); // true
```
### Proxy 代理

```js
const person = {
    name: 'along',
    age: 20,
}

const personProxy = new Proxy(person, {
    get(target, property) {
        console.log(target, property);
        return property in target ? target[property] : '-';
    },
    set(target, property, value) {
        if (property === 'age') {
            if (!Number.isInteger(value)) {
                throw new TypeError(`age must be a number but ${value} [${typeof value}]`);
            }
        }   
        target[property] = value;
    },
})
console.log(personProxy.name);
// { name: 'along', age: 20 } name
// along
console.log(personProxy.bb);
// { name: 'along', age: 20 } bb
// -
personProxy.age = '20'
// throw new TypeError(`age must be a number but ${value} [${typeof value}]`);
// ^
// TypeError: age must be a number but 20 [string]
```

vue 3.0 开始使用proxy 实现内部数据的相应

#### Proxy 与 Object.defineProperty 比较

defineProperty  只能监视对象的读取和写入 Proxy 可以监视一些 defineProperty  监视不到的行为
```js
const person = {
    name: 'along',
    age: 20,
}
const personProxy = new Proxy(person, {
     deleteProperty(target, property) {
         console.log('delete', property);
         delete target[property];
    }
})

delete personProxy.name;
console.log(personProxy);
// delete name
// { age: 20 }
```

除了删除操作之外，可操作的行为见下表

{% asset_img clipboard.png %}

#### 借助Proxy监视数组操作

```js
const list = []

const listProxy = new Proxy(list, {
    set(target, property, value) {
        console.log(target, property, value); 
        target[property] = value;
        return true; // 需要返回true表示操作成功
    },
    deleteProperty(target, property) {
         console.log('delete', property);
         delete target[property];
         return true; // 需要返回true表示操作成功
    }
})
listProxy.push(1); // push 操作会至少触发两次set
// [] 0 1
// [ 1 ] length 1
listProxy.push(2);
// [ 1 ] 1 2
// [ 1, 2 ] length 2
listProxy.push(3);
// [ 1, 2 ] 2 3
// [ 1, 2, 3 ] length 3
listProxy.push(4);
// [ 1, 2, 3 ] 3 4
// [ 1, 2, 3, 4 ] length 4

// 这里执行到shift时，会首先出发三次set，讲数组最后的三个元素前移，
// 然后触发删除操作
// 最后再次触发 set 的操作修改length
listProxy.shift(); 
// [ 1, 2, 3, 4 ] 0 2
// [ 2, 2, 3, 4 ] 1 3
// [ 2, 3, 3, 4 ] 2 4
// delete 3
// [ 2, 3, 4, <1 empty item> ] length 3
```
#### Proxy 以非侵入的方式监管对象读写
defineProperty 需要通过监听特定的属性，如

```js
const person = {name: 'along'};
Object.defineProperty(person, 'name', {
    get() {
        console.log('get');
        return person._name;
    },
    set(value) {
        console.log('name 被修改');
        person._name = value;
    }
})
console.log(person.name);
// undefined
person.name = 'along';
// name 被修改
console.log(person)
// { name: [Getter/Setter], _name: 'along' }
console.log(person.name)
// get
// along
```

从以上代码可以看出，defineProperty方式会修改被监控的对象本身，读取写入操作需要借助辅助内存空间来保存真实值

### Reflect 

静态类，不能用new操作符
Reflect 内部封装了一系列对对象的底层操作
Reflect 成员方法就是Proxy处理对象的默认实现

```js
 const person = {
    name: 'along',
    age: 23,
}

const personProxy = new Proxy(person, {
    // 在不设置 get 方法时，相当于返回 Reflect.get(target, property);
    get (target, property) {
        console.log('get');
        return Reflect.get(target, property);
    }
})

console.log(personProxy.name)
```

#### 统一操作对象的API

```js
const person = {
    name: 'along',
    age: 24,
}

(Reflect.has(person, 'name')
// true  相当于  'name' in person
Reflect.deleteProperty(person, 'name')
// 相当于 delete person['name'] | delete person.name
Reflect.ownKeys(person);
// ['name', 'age']  相当于  person.keys();
```

### class 类

```js
class Person {
    constructor(name) {
        this.name = name;
    }
    
    say () {
        console.log(`${this.name} say`);
    }
}

const person = new Person('along');
person.say();
// along say
```

#### 静态成员  

- 实例方法（通过实例调用）实例方法中的this指向实例
- 静态方法（通过类本身调用）静态方法中的this指向类本身

#### static关键字

```js
class Person {
    constructor(name) {
        this.name = name;
    }

    say () {
        console.log(this)
        console.log(`${this.name} say`);
    }
    
    static create (name) {
        console.log(this)
        return new Person(name);
    }
}

const person = Person.create('along');
// [Function: Person]
person.say();
// Person { name: 'along' }
// along say
```

### 继承 extends
```js
class Person {
    constructor(name) {
        this.name = name;
    }

    say () {
        console.log(this)
        console.log(`${this.name} say`);
    }
    
    static create (name) {
        console.log(this)
        return new Person(name);
        // return new this(name); 可以使用new this , 
    }
}

class Student extends Person {
    constructor(name, schoolname){
        super(name);
        this.schoolname = schoolname;
    }

    welcome() {
        super.say();
        console.log(`from ${this.schoolname}`);
    }
}

const along = new Student('along', '黑科技');
along.welcome()
// Student { name: 'along', schoolname: '黑科技' }
// along say
// from 黑科技
console.log(Student.create('along'));
// [Function: Student]                  Student继承的Person的静态方法，this指向Student类
// Person { name: 'along' }            
```

### Set数据结构

不重复元素的集合
```js
const s = new Set();
s.add(1).add(2).add(2);
console.log(s);
// Set { 1, 2}

// 遍历 不能用 for in, 不能用下标取值
for(let i of s) {
    console.log(i);
}
// 或者 forEach
s.forEach(l => {
    console.log(l);
})

// 获取 Set 长度
console.log('size', s.size);
// size 2

// 判断是否存在某个元素
console.log(s.has(100));
// false

// 删除某个元素，删除成功返回true，失败即本来不存在返回false
console.log(s.delete(3));
// false

// 清空
s.clear();

// 数组去重
const arr = [1,2,3,4,2,3];
const result = Array.from(new Set(arr)); // [...new Set(arr)]

console.log(result);
// [1,2,3,4]
```

### Map 数据结构，映射两个任意类型数据之间的关系

可以使用任何数据作为键，普通对象只能用字符串作为键

```js
const along = {name: 'along'};
const map = new Map();

map.set(along, 25);
console.log(map)
// Map { { name: 'along' } => 25 }
console.log(map.get(along))
// 25
map.has(along); // 查看是否存在键  返回true
map.delete(along); // 返回删除结果
// true
map.clear() // 清空

// 遍历 forEach 获取 for of 
map.forEach((value, key) => {
    console.log(value, key)
})
for (let [key, value] of map){
    console.log(key, value);
}
```

### Symbol  第七个数据类型，(esmascript 2017 第八个数据类型BigInt)
可以避免属性名冲突，为对象定义独一无二的属性名

```js
Symbol() === Symbol() // false 
typeof Symbol(); // symbol
const obj = {[Symbol()]: 123};
console.log(obj);
// { [Symbol()]: 123 }
```

用于模拟对象私有成员,在对象内部由于缓存了Symbol的索引，可以对Symbol属性进行操作，在对象外部由于拿不到Symbol的索引所以无法对属性访问

```js
const name = Symbol();

const person = {
    [name]: 'along',
    say() {
        console.log(this[name]);
    }
}


```

全局使用相同的Symbol时,可以通过Symbol.for() 传入字符串，Symbol内部维护了字符串和Symbol的对应关系。

```js
const s1 = Symbol.for('foo'); // 相当于  const s1 = Symbol(); // const s2 = s1;
const s2 = Symbol.for('foo');
console.log(s1 === s2)
// true

const strtrue = Symbol('true');
const booltrue = Symbol(true);
strtrue === booltrue // true;
```

Symbol内置常量
```js
const obj = {
    [Symbol.toStringTag]: 'along',
}
console.log(obj.toString())
// [object along]

```

获取Symbol属性
```js
// Symbol 属性通过    for in ，Object.keys(), JSON.stringify(), 都会被忽略
// 可以通过  getOwnPropertySymbols 获取Symbol的keys
const obj = {
    [Symbol('name')]: 'along',
}
console.log(Object.getOwnPropertySymbols(obj));
// [ Symbol(name) ]
```

### for of 循环，
可以作为遍历所有数据结构的统一方式

```js
const arr = [1,2,3];
for (let item of arr) {
    console.log(item);
    if (item === 2) break;
}

// for of 循环可以通过 break 跳出循环  ， forEach  map 等方式无法跳出循环， 需要跳出循环需要通过arr.some，arr.every方法
```

Map对象通过for of 遍历返回数组，第一个值是键，第二个值是值

```js
const map = new Map();
map.set({name: 'along'}, 25);
map.set('school', '黑科');

for (let [key, value] of map) {
    console.log(key, value)
}

// { name: 'along' } 25
// school 黑科
```

通过for of 遍历对象， 会发现报错

```js
const person = {
    name: 'along',
    age: 24,
}

for (let value of person) {
    console.log(value);
}

// TypeError: person is not iterable
```


通过浏览器控制台打印数组、Set、 Map 等对象会发现，他们的原型上都存在 [Symbol(Symbol.iterator)]属性

{% asset_img iterator.png %}

通过调用iterator查看结果，这里以数组为例

```js
const iterator = [1, 2, 3][Symbol.iterator]();

console.log(iterator.next());
// { value: 1, done: false }
console.log(iterator.next());
// { value: 2, done: false }
console.log(iterator.next());
// { value: 3, done: false }
console.log(iterator.next());
// { value: undefined, done: true }

```
实现可迭代接口 iterable

```js
const iterable = function () {

    const keys = Object.keys(this);
    let index = 0;
    const self = this;

    return {
        // iterator
        next: function () {
            // iterationResult
            const iterationResult = {
                value: keys[index],
                done: index >= keys.length,
            }
            index ++;
            return iterationResult;
        }
    }
}

const person = {
    name: 'along',
    age: 25,
    // 实现iterable 接口
    [Symbol.iterator]: iterable
}

for (let value of person) {
    console.log(value);
}
```

#### 迭代器模式 让用户通过特定的接口访问容器的数据，不需要了解容器内部的数据结构。

```js
// a.js
const todos = {
    life: ['工作', '坐公交'],
    learn: ['ES6', 'typescript'],

    [Symbol.iterator]: function () {

        const keys = [].concat(this.life, this.learn);
        let index = 0;

        return {
            next: function () {
                const iterationResult = {
                    value: keys[index],
                    done: index >= keys.length,
                }
                index ++;
                return iterationResult;
            }
        }
    }
}
// b.js
for (let value of todos) {
    console.log(value);
}

```

### 生成器 Generator

解决异步函数嵌套问题，从而提供更好的异步编程解决方案

```js
// 生成器函数
function * fn () {
    console.log('along');
    return 100;
}
const gen = fn();
console.log(gen);
// Object [Generator] {}

console.log(gen.next())
// along
// { value: 100, done: true }
```
生成器函数可以自动返回一个生成器对象，生成器函数内部的逻辑会惰性执行

```js
function * fn () {
    console.log('11');
    yield 100;
    console.log('22');
    yield 200;
}
const gen = fn();
console.log(gen.next())
// 11
// { value: 100, done: false }
console.log(gen.next())
// 22
// { value: 200, done: false }
console.log(gen.next())
// { value: undefined, done: true }
```

#### 生成器应用

```js
// 发号器
function * fn () {
    let id = 1;
    while(true) {
        yield id ++;
    }
}
const gen = fn();
console.log(gen.next())
console.log(gen.next())
console.log(gen.next())

```

使用生成器简化迭代器

```js
// a.js
const todos = {
    life: ['工作', '坐公交'],
    learn: ['ES6', 'typescript'],

    // [Symbol.iterator]: function () {

    //     const keys = [].concat(this.life, this.learn);
    //     let index = 0;

    //     return {
    //         next: function () {
    //             const iterationResult = {
    //                 value: keys[index],
    //                 done: index >= keys.length,
    //             }
    //             index ++;
    //             return iterationResult;
    //         }
    //     }
    // },
    [Symbol.iterator]: function * () {

        const keys = [].concat(this.life, this.learn);
        for (let item of keys) {
            yield item;
        }

    }
}
// b.js
for (let value of todos) {
    console.log(value);
}
```

## ES2016
### 数组方法includs

在ES2016之前需要通过indexOf 返回的下表来判断，但是这种方式也存在一些问题，比如不能查找数组中的NaN

```js
const arr = ['foo', 1, NaN, false];

arr.indexOf('foo');
// 0
arr.indexOf('b');
// -1
arr.indexOf(NaN);
// -1

arr.includes('foo');
// true
arr.includes(NaN);
// true
```

### 指数运算符

```js
Math.pow(2, 10);
// 1024
2 ** 10;
// 1024
```

## ES2017

Object.values 返回对象的值数组
Object.entries 返回对象键值对数组
Object.getOwnPropertyDescriptors 获取属性描述符，可以通过拷贝属性描述符拷贝getter、setter
padEnd 、 padStart  使用指定字符串填充字符串使其达到目标长度
参数列表尾逗号， 便于代码修改时参数扩充
Async/Await  Promise语法糖

```js
const person = {
    name: 'along',
    age: '24',
    [Symbol()]: 123,
}
Object.values(person);
// [ 'along', '24' ]

Object.entries(person)
// [ [ 'name', 'along' ], [ 'age', '24' ] ]

Object.entries([1,2,3]);
// [ [ '0', 1 ], [ '1', 2 ], [ '2', 3 ] ]

const description = Object.getOwnPropertyDescriptors(person);
// {
//   name: {
//     value: 'along',
//     writable: true,
//     enumerable: true,
//     configurable: true
//   },
//   age: { value: '24', writable: true, enumerable: true, configurable: true },
//   [Symbol()]: { value: 123, writable: true, enumerable: true, configurable: true }
// }

// 填充字符串
for (let [key, value] of Object.entries(person)) {
    console.log(`${key.padEnd(16, '-')}|${value.padStart(10, '-')}`)
}
// name------------|-----along
// age-------------|--------24

// 参数列表尾逗号
function fn(
    name,
    age,
) {}

```