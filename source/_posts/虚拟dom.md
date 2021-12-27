---
title: vue虚拟dom
date: 2020-08-27 16:01:16
tags: 
    - vue
    - 虚拟dom
---

## 虚拟dom

- 避免直接操作dom，提高开发效率
- 作为中间层实现跨平台
- 复杂视图提高性能


### h函数

h函数，内部会调用createElement，在core/vdom/create-element.js中定义

createElement接收多个参数，在调用时可以传递不同类型的参数，因此createElement函数做的事情就是判断用户传递的参数类型，并处理整合参数，传递给_createElement

```js
export function createElement (
  context: Component,
  tag: any,
  data: any,
  children: any,
  normalizationType: any,
  alwaysNormalize: boolean
): VNode | Array<VNode> {
    // 如果data是数组或者字符串
  if (Array.isArray(data) || isPrimitive(data)) {
    normalizationType = children
    children = data
    data = undefined
  }
  // 如果使用户传入render函数，alwaysNormalize = true
  if (isTrue(alwaysNormalize)) {
    normalizationType = ALWAYS_NORMALIZE
  }
  return _createElement(context, tag, data, children, normalizationType)
}
```

_createElement中返回VNode

1. 首先判断data存在且存在__ob__属性,警告并返回空VNode
2. 接下来判断data存在且有is属性，将data.is赋值给tag（is用于动态的绑定组件<component v-bind:is="Com"/>）
3. 接下来判断tag如果不存在(相当于给is指令设置了false)，返回空VNode
4. 如果data属性有key且key不是原始值，发出警告
5. 接下来处理插槽
6. 然后判断normalizationType是2，代表用户传递的render函数，此时借助normalizeChildren对children进行处理，并赋值给children
   - 判断如果children是原始值
     - 通过createTextVNode创建文本节点并作为数组第一项返回这个数组（处理数组方便后期统一childrend的类型）
   - 如果children不是原始值，判断children是否是数组
     - 是，通过normalizeArrayChildren处理数组并返回,这个函数作用是如果children项也是数组，递归调用处理成一维数组
     - 否，返回undefined
7. 判断normalizationType是1，调用simpleMormalizeChildren处理数组并赋值给children，将children处理成一维数组
8. tag如果是字符串
   - 是字符串判断tag是否是html标签，创建VNode
   - 如果是自定义组件，从context.$options.components中找到组件，并通过createComponent创建组件的VNode
   - 以上都不满足，说明tag是自定义标签，创建一个VNode对象
9. tag不是字符串说明是组件，通过createComponent创建组件VNode
10. 接下来判断之前穿件vnode是否是数组
    - 是，直接返回vnode
    - 否则，判断vnode是不是存在，存在的话，对vnode进行简单处理
    - 以上都不满足，返回空VNode
  
### update

vm._update方法接收通过vm._render创建好的VNode对象，_update方法内部调用了vm.__patch__方法

_update原理，获取vm实例上的_vnode,如果_vnode存在，说明不是首次渲染，通过__patch__对比新旧vnode；如果_vnode不存在会将vm.$el作为第一个参数传入，__patch__内部会将真实dom处理成vnode。最中__patch__返回一个真实dom,保存到vm.$el上

### __patch__

__patch__函数是通过createPatchFunction函数返回，createPatchFunction接收一个对象，返回一个patch函数

```js
createPatchFunction({
    nodeOps, // 定义dom操作的函数
    modules // 模块集合attrs,klass,events,domProps,style,transition     指令，ref
})
```

1. 将模块的钩子函数都保存到cbs数组中
2. 返回一个patch函数
   - 判断新的VNode如果不存在，判断老VNode存在，执行Destory钩子函数
   - 定义新插入vnode节点的队列
   - 老vnode不存在（$mount方法调用没有传递挂载位置时）,创建节点到内存中
   - 老vnode存在
       - 如果oldVnode.nodeType不存在，并且oldVnode和newVnode是sameVnode，通过patchVnode更新
       - 如果上一条件不成立
           - 判断是否存在oldVnode.nodeType,如果存在说明是首次渲染,通过emptyNodeAt返回值赋值给oldVnode.elm,将真实dom转换成虚拟dom
       - 获取oldelm,获取parentElm
       - 通过createElm,将newvnode转换成dom，挂载到parentElm上,插入到oldElm之前，并把newVnode记录到insertedVnodeQueue
       - 判断parentEle是否存在，存在的话通过removeVnodes删除oldVnode并触发钩子函数
       - 如果parentEle不存在，且oldVnode存在tag属性，触发destroy钩子
   - 如果挂载到了dom上触发insertedVnodeQueue队列中的所有insert钩子
