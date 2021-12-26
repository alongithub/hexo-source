---
title: 手写Promise
date: 2020-09-23 16:15:13
tags: [
    Promise,
    Promise源码
]
description: 实现了Promise构造器，then方法链式调用，同一个Promise对象多个then方法，resolve、all静态方法。finaly、catch方法及链式调用
---


```js

const PENDING = 'pending';
const FULFILLED = 'fulfilled';
const REJECTED = 'rejected';

class MyPromise {
    // 保存实例状态
    status = PENDING;
    value = undefined; // 成功时的返回值
    reason = undefined; // 失败时的返回值
    successCallback = []; // 异步成功回调
    failCallback = []; // 异步失败回调
    // executor 执行器，promise创建实例时传入的回调函数
    constructor(executor) {
        // 捕获执行器中的错误
        try {
            executor(this.resolve, this.reject); // 执行器立即执行
        } catch(err) {
            this.reject(err);
        }
    }

    resolve = value => {
        // 状态更改后无法再次更改
        if (this.status !== PENDING) return;
        this.status = FULFILLED;
        // 保存成功后的值，方便then方法中拿到
        this.value = value;
        // 判断successCallback 成功回调是否存在，存在说明 resolve是异步任务执行后被调用的
        while (this.successCallback.length) {
            this.successCallback.shift()(); // 弹出数组首部函数
        }
    }

    reject = reason => {
        // 状态更改后无法再次更改
        if (this.status !== PENDING) return;
        this.status = REJECTED;
        // 保存失败的原因，方便then中拿到
        this.reason = reason;
        // failCallback 失败回调是否存在，存在说明 reject是异步任务执行后被调用的
        while (this.failCallback.length) {
            this.failCallback.shift()(); // 弹出数组首部函数
        }
    }

    then(successCallback, failCallback) {
        // then方法可以不传递回调函数，自动将promise返回结构向之后的then函数传递
        successCallback = successCallback ? successCallback : value => value;
        failCallback = failCallback ? failCallback : reason => {throw reason};

        // then 链式调用返回新的实例
        let thenPromise = new MyPromise((resolve, reject) => {
            // 判断状态
            if (this.status === FULFILLED) {
                // 因为同步执行时resolvePromise拿不到thenPromise，
                // 所以让这段代码在return thenPromise后执行
                setTimeout(() => {
                    // 捕获then中成功回调的错误
                    try{
                        let x = successCallback(this.value);
                        resolvePromise(thenPromise, x, resolve, reject);
                    } catch(err) {
                        reject(err); // 把错误信息传递给下一个then方法
                    }
                    
                }, 0)
            } else if (this.status === REJECTED) {
                setTimeout(() => {
                    // 捕获then中成功回调的错误
                    try{
                        let x = failCallback(this.reason);
                        resolvePromise(thenPromise, x, resolve, reject);
                    } catch(err) {
                        reject(err); // 把错误信息传递给下一个then方法
                    }
                    
                }, 0)
            } else {
                // 如果执行器中的rosolve或reject是异步执行的
                // then会立即执行，此时，将then中的两个参数保存到实例中
                this.successCallback.push(() => {
                    setTimeout(() => {
                        // 捕获then中成功回调的错误
                        try{
                            let x = successCallback(this.value);
                            resolvePromise(thenPromise, x, resolve, reject);
                        } catch(err) {
                            reject(err); // 把错误信息传递给下一个then方法
                        }
                        
                    }, 0)
                });
                this.failCallback.push(() => {
                    setTimeout(() => {
                        // 捕获then中成功回调的错误
                        try{
                            let x = failCallback(this.reason);
                            resolvePromise(thenPromise, x, resolve, reject);
                        } catch(err) {
                            reject(err); // 把错误信息传递给下一个then方法
                        }
                        
                    }, 0)
                });
            }
        })

        return thenPromise;
    }

    finally (callback) {
        // 无论promise状态是成功还是失败，都会调用finally的callback,并把promise返回结果继续向下传递
        return this.then(value => {
            // 如果finaly方法返回了promise, 之后的then方法会等待该promise执行结束
            return MyPromise.resolve( callback() ).then(() => value)
        }, reason => {
            return MyPromise.resolve( callback() ).then(() => {throw reason}) 
        })
    }

    catch(failCallback) {
        return this.then(undefined, failCallback);
    }

    // 静态方法
    static all (array) {
        let result = [];
        let index = 0;
        

        return new MyPromise((resolve, reject) => {
            function addData(key, value) {
                result[key] = value;
                index ++;

                if (index === array.length) {
                    resolve(result);
                }
            }

            // MyPromise.all(['a', 'b', new MyPromise(r => {r('p1')})])
            for (let i = 0; i < array.length; i ++) {
                let current = array[i];
                if (current instanceof MyPromise) {
                    // promise对象, 如果成功添加到结果中，如果失败直接reject
                    current.then((value) => {
                        addData(i, value)
                    }, reject)
                } else {
                    // 普通值, 直接放入返回结果中
                    addData(i, array[i])
                }
            }

            
        })
    }

    static resolve(value) {
        if (value instanceof MyPromise) return value;
        return new MyPromise(resolve => {
            resolve(value);
        })
    }
} 

function resolvePromise(thenPromise, x, resolve, reject) {
    // 如果then的回调返回了then函数返回的promise对象，报错
    // let p = promise.then(v => {return p})
    if (thenPromise === x) {
        return reject(new TypeError('Chaining cycle detected for promise #<MyPromise>'))
    }

    // promise.then(v => {return x});
    // 判断x的值是普通值还是promise对象
    // 如果是普通值，直接调用resolve
    // 如果是promise对象，查看promise对象的返回的结果
    // 再根据promise对象返回的结果决定用resolve 还是调用reject
    if(x instanceof MyPromise) {
        // promise对象 , 调用then查看回调状态
        // x.then(value => resolve(value), reason => reject(reason))
        x.then(resolve, reject);
    } else {
        resolve(x);
    }

}

module.exports = MyPromise;
```