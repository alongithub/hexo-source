---
title: vue模板编译
date: 2020-08-27 16:02:30
tags: 
  - vue
  - 模板编译
---

### 模板编译过程

在$.mount方法中，会首先判断用户是有传入render函数，如果没有传入会判断选项中是否有template，如果没有template会根据el属性找到outerHTML 作为模板，并赋值给template，接下来会通过compileToFunctions把template转换成render函数

模板编译生成的render函数实例

```html
<div id="app">
    <h1>Vue<span>模板编译过程</span></h1>
    <p>{{msg}}</p>
    <comp @myclick="handler"></comp>
</div>
<script>
    Vue.component('comp', {
        template: '<div>a comp</div>'
    })
    const vm = new Vue({
        el: '#app',
        data: {
            msg: 'hello compiler'
        },
        methods: {
            handler() {
                console.log('test')
            }
        }
    })
</script>
```

```js
// vm.$options.render
(function anonymous() {
    with(this) {
        return _c(
            "div",
            {attrs: {id: "app"}},
            [
                _m(0),
                _v(" "),
                _c("p", [_v(_s(msg))]),
                _v(" "),
                _c("comp", {on: {myclick: handler}})
            ],
            1
        )
    }
})
```

_m 用来处理静态内容，没有差值表达式和指令的内容
_v(" ") 空白文本节点，对应h1和p标签之间的空白节点
_s toString函数
_c 生成组件对应的VNode

- 在$mount函数总，会调用compileToFunctions返回render、staticRenderFns两个方法，并记录到options上。
- compoleToFunctions是通过createCompiler函数返回的
- createCompiler是通过createCompilerCreator函数返回，这个函数接收baseCompile函数作为参数,
  - baseCompile中将模板转换成ast抽象语法树
  - 通过optimize优化抽象语法树
  - 通过generate把抽象语法树转换成字符串形式的js代码