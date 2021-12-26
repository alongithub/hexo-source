---
title: vue3语法
date: 2021-06-12 11:08:21
tags: [vue3.0, composition Api, JSX]
toc: true
description: vue3的语法介绍，结合组合API使用JSX
---

### 插槽



#### 后备内容

我们可能希望这个 插槽 内绝大多数情况下都渲染文本“Submit”。为了将“Submit”作为后备内容，我们可以将它放在 slot 标签内：

```jsx
<button type="submit">
  <slot>Submit</slot>
</button>
```

#### 具名插槽

有时我们需要多个插槽。例如对于一个带有如下模板的 `<base-layout>` 组件：

```jsx
<div class="container">
  <header>
    <!-- 我们希望把页头放这里 -->
  </header>
  <main>
    <!-- 我们希望把主要内容放这里 -->
  </main>
  <footer>
    <!-- 我们希望把页脚放这里 -->
  </footer>
</div>
```

对于这样的情况，`<slot>` 元素有一个特殊的 `attribute：name`。这个 `attribute` 可以用来定义额外的插槽：

```jsx
<div class="container">
  <header>
    <slot name="header"></slot>
  </header>
  <main>
    <slot></slot>
  </main>
  <footer>
    <slot name="footer"></slot>
  </footer>
</div>
```

一个不带 name 的 `<slot>` 出口会带有隐含的名字`“default”`。

在向具名插槽提供内容的时候，我们可以在一个 `<template>` 元素上使用 v-slot 指令，并以 v-slot 的参数的形式提供其名称：

```jsx
<base-layout>
  <template v-slot:header>
    <h1>Here might be a page title</h1>
  </template>

  <template v-slot:default>
    <p>A paragraph for the main content.</p>
    <p>And another one.</p>
  </template>

  <template v-slot:footer>
    <p>Here's some contact info</p>
  </template>
</base-layout>
```


#### 作用域插槽

有时让插槽内容能够访问子组件中才有的数据是很有用的。当一个组件被用来渲染一个项目数组时，这是一个常见的情况，我们希望能够自定义每个项目的渲染方式。

例如，我们有一个组件，包含 `todo-items` 的列表。

```jsx
app.component('todo-list', {
  data() {
    return {
      items: ['Feed a cat', 'Buy milk']
    }
  },
  template: `
    <ul>
      <li v-for="(item, index) in items">
        {{ item }}
      </li>
    </ul>
  `
})
```

要使 item 可用于父级提供的 slot 内容，我们可以添加一个 `<slot>` 元素并将其绑定为属性：

```jsx
<ul>
  <li v-for="( item, index ) in items">
    <slot :item="item"></slot>
  </li>
</ul>
```

绑定在 `<slot >` 元素上的 `attribute` 被称为插槽 `prop`。现在在父级作用域中，我们可以使用带值的 `v-slot` 来定义我们提供的插槽 `prop` 的名字：

```jsx
<todo-list>
  <template v-slot:default="slotProps">
    <i class="fas fa-check"></i>
    <span class="green">{{ slotProps.item }}</span>
  </template>
</todo-list>
```

#### 结构插槽prop
作用域插槽的内部工作原理是将你的插槽内容包括在一个传入单个参数的函数里,
这意味着 v-slot 的值实际上可以是任何能够作为函数定义中的参数的 JavaScript 表达式。你也可以使用 ES2015 解构来传入具体的插槽 prop，如下：
```jsx
<todo-list v-slot="{ item }">
  <i class="fas fa-check"></i>
  <span class="green">{{ item }}</span>
</todo-list>
```

这样可以使模板更简洁，尤其是在该插槽提供了多个 prop 的时候。它同样开启了 prop 重命名等其它可能，例如将 item 重命名为 todo：

```jsx
<todo-list v-slot="{ item: todo }">
  <i class="fas fa-check"></i>
  <span class="green">{{ todo }}</span>
</todo-list>
```

你甚至可以定义后备内容，用于插槽 prop 是 undefined 的情形

```jsx
<todo-list v-slot="{ item = 'Placeholder' }">
  <i class="fas fa-check"></i>
  <span class="green">{{ item }}</span>
</todo-list>
```

#### 具名插槽的缩写

跟 `v-on` 和 `v-bind` 一样，`v-slot` 也有缩写，即把参数之前的所有内容 `(v-slot:)` 替换为字符 `#`。例如 `v-slot:header` 可以被重写为 `#header`：

```html
<base-layout>
  <template #header>
    <h1>Here might be a page title</h1>
  </template>

  <template #default>
    <p>A paragraph for the main content.</p>
    <p>And another one.</p>
  </template>

  <template #footer>
    <p>Here's some contact info</p>
  </template>
</base-layout>
```

### 提供/注入

如果我们有这样的层次结构：

```
Root
└─ TodoList
   ├─ TodoItem
   └─ TodoListFooter
      ├─ ClearTodosButton
      └─ TodoListStatistics
```

如果要将 todo-items 的长度直接传递给 TodoListStatistics，我们将把这个属性向下传递到层次结构：`TodoList -> TodoListFooter -> TodoListStatistics`。通过 `provide/inject` 方法，我们可以直接执行以下操作：

```js
const app = Vue.createApp({})

app.component('todo-list', {
  data() {
    return {
      todos: ['Feed a cat', 'Buy tickets']
    }
  },
  provide: {
    user: 'John Doe'
  },
  template: `
    <div>
      {{ todos.length }}
      <!-- 模板的其余部分 -->
    </div>
  `
})

app.component('todo-list-statistics', {
  inject: ['user'],
  created() {
    console.log(`Injected property: ${this.user}`) // > 注入 property: John Doe
  }
})
```

但是，如果我们尝试在此处提供一些组件实例 property，则这将不起作用：

```js
app.component('todo-list', {
  data() {
    return {
      todos: ['Feed a cat', 'Buy tickets']
    }
  },
  provide: {
    todoLength: this.todos.length // 将会导致错误 'Cannot read property 'length' of undefined`
  },
  template: `
    ...
  `
})
```

要访问组件实例 property，我们需要将 provide 转换为返回对象的函数

```js
app.component('todo-list', {
  data() {
    return {
      todos: ['Feed a cat', 'Buy tickets']
    }
  },
  provide() {
    return {
      todoLength: this.todos.length
    }
  },
  template: `
    ...
  `
})
```

#### 处理响应式

在上面的例子中，如果我们更改了 todos 的列表，这个更改将不会反映在注入的 todoLength property 中。这是因为默认情况下，provide/inject 绑定不是被动绑定。我们可以通过将 ref property 或 reactive 对象传递给 provide 来更改此行为。在我们的例子中，如果我们想对祖先组件中的更改做出反应，我们需要为我们提供的 todoLength 分配一个组合式 API computed property：

```js
app.component('todo-list', {
  // ...
  provide() {
    return {
      todoLength: Vue.computed(() => this.todos.length)
    }
  }
})
```

### 动态组件

```jsx
<component :is="currentTabComponent"></component>
```

#### keep-alive

```jsx
<!-- 失活的组件将会被缓存！-->
<keep-alive>
  <component :is="currentTabComponent"></component>
</keep-alive>
```

### 强制更新

如果你发现自己需要在 Vue 中强制更新，在 99.99%的情况下，你在某个地方犯了错误。例如，你可能依赖于 Vue 响应性系统未跟踪的状态，例如，在组件创建之后添加了 data 属性。

但是，如果你已经排除了上述情况，并且发现自己处于这种非常罕见的情况下，必须手动强制更新，那么你可以使用 $forceUpdate。

#低级静态组件与 v-once

### 静态组件 v-once

在 Vue 中渲染纯 HTML 元素的速度非常快，但有时你可能有一个包含很多静态内容的组件。在这些情况下，可以通过向根元素添加 v-once 指令来确保只对其求值一次，然后进行缓存，如下所示：

```js
app.component('terms-of-service', {
  template: `
    <div v-once>
      <h1>Terms of Service</h1>
      ... a lot of static content ...
    </div>
  `
})
```

再次提醒，不要过度使用这种模式。虽然在极少数情况下需要渲染大量静态内容时很方便，但除非你注意到渲染速度——慢，否则就没有必要这样做—另外，这可能会在以后引起很多混乱。例如，假设另一个开发人员不熟悉 v-once 或者只是在模板中遗漏了它。他们可能会花上几个小时来弄清楚为什么模板没有正确更新。

### Mixin 混入

EX:
```js
const myMixin = {
  created() {
    this.hello()
  },
  methods: {
    hello() {
      console.log('hello from mixin!')
    }
  }
}

// define an app that uses this mixin
const app = Vue.createApp({
  mixins: [myMixin]
})

app.mount('#mixins-basic') // => "hello from mixin!"
```

#### 全局混入

```js
const app = Vue.createApp({
  myOption: 'hello!'
})

// 为自定义的选项 'myOption' 注入一个处理器。
app.mixin({
  created() {
    const myOption = this.$options.myOption
    if (myOption) {
      console.log(myOption)
    }
  }
})

app.mount('#mixins-global') // => "hello!"
```

### 自定义指令

#### 全局

```js
const app = Vue.createApp({})
// 注册一个全局自定义指令 `v-focus`
app.directive('focus', {
  // 当被绑定的元素插入到 DOM 中时……
  mounted(el) {
    // Focus the element
    el.focus()
  }
})
```

#### 局部注册

```js
directives: {
  focus: {
    // 指令的定义
    mounted(el) {
      el.focus()
    }
  }
}
```

### teleport

使用 `<teleport>`，并告诉 Vue “Teleport 这个 HTML 到该‘body’标签”。

```js
<teleport to="body">
    这将插入到body上
</teleport>
```

使用 `<teleport>`，并告诉 Vue “Teleport 这个 HTML 到‘#wrapper’标签”。

```js
<teleport to="#wrapper">
    这将插入到id wrapper 元素上上
</teleport>
```

### render函数

```js
export default {
    data() {
        return {
            blogTitle: 'title'
        }
    },
    render() {
        return Vue.h('h1', {}, this.blogTitle)
    }
}
```

#### h 函数

h() 函数是一个用于创建 vnode 的实用程序。也许可以更准确地将其命名为 createVNode()，但由于频繁使用和简洁，它被称为 h() 。它接受三个参数：
```js
// @returns {VNode}
h(
  // {String | Object | Function | null} tag
  // 一个 HTML 标签名、一个组件、一个异步组件，或者 null。
  // 使用 null 将会渲染一个注释。
  //
  // 必需的。
  'div',

  // {Object} props
  // 与 attribute、prop 和事件相对应的对象。
  // 我们会在模板中使用。
  //
  // 可选的。
  {},

  // {String | Array | Object} children
  // 子 VNodes, 使用 `h()` 构建,
  // 或使用字符串获取 "文本 Vnode" 或者
  // 有 slot 的对象。
  //
  // 可选的。
  [
    'Some text comes first.',
    h('h1', 'A headline'),
    h(MyComponent, {
      someProp: 'foobar'
    })
  ]
)

```

### JSX

[https://github.com/vuejs/jsx-next#installation](https://github.com/vuejs/jsx-next#installation)

```js
import AnchoredHeading from './AnchoredHeading.vue'

new Vue({
  el: '#demo',
  render() {
    return (
      <AnchoredHeading level={1}>
        <span>Hello</span> world!
      </AnchoredHeading>
    )
  }
})
```

#### install

Install the plugin with:

```
npm install @vue/babel-plugin-jsx -D
```
Then add the plugin to .babelrc:
```
{
  "plugins": ["@vue/babel-plugin-jsx"]
}
```

#### function

```js
const App = () => <div>Vue 3.0</div>;
```

#### render

```js
const App = {
  render() {
    return <div>Vue 3.0</div>;
  },
};
```

#### setup

```js
import { withModifiers, defineComponent } from "vue";

const App = defineComponent({
  setup() {
    const count = ref(0);

    const inc = () => {
      count.value++;
    };

    return () => (
      <div onClick={withModifiers(inc, ["self"])}>{count.value}</div>
    );
  },
});
```

#### fragment

```js

const App = () => (
  <>
    <span>I'm</span>
    <span>Fragment</span>
  </>
);
```

#### Attributes/props

```js
const App = () => <input type="email" />;
```

```js
const placeholderText = "email";
const App = () => <input type="email" placeholder={placeholderText} />;

```


#### v-show

```js
const App = {
  data() {
    return { visible: true };
  },
  render() {
    return <input v-show={this.visible} />;
  },
};
```

#### v-model

```js
<input v-model={val} />
```

#### v-models

```js
<A v-models={[[foo], [bar, "bar"]]} />
```

#### slot

```js
const A = (props, { slots }) => (
  <>
    <h1>{ slots.default ? slots.default() : 'foo' }</h1>
    <h2>{ slots.bar?.() }</h2>
  </>
);

const App = {
  setup() {
    const slots = {
      bar: () => <span>B</span>,
    };
    return () => (
      <A v-slots={slots}>
        <div>A</div>
      </A>
    );
  },
};

// or

const App = {
  setup() {
    const slots = {
      default: () => <div>A</div>,
      bar: () => <span>B</span>,
    };
    return () => <A v-slots={slots} />;
  },
};

// or you can use object slots when `enableObjectSlots` is not false.
const App = {
  setup() {
    return () => (
      <>
        <A>
          {{
            default: () => <div>A</div>,
            bar: () => <span>B</span>,
          }}
        </A>
        <B>{() => "foo"}</B>
      </>
    );
  },
};
```

### composition Api



#### ref/reactive

```js
import { ref } from 'vue'

const counter = ref(0)
```

#### 生命周期

```
beforeMount	onBeforeMount
mounted	onMounted
beforeUpdate	onBeforeUpdate
updated	onUpdated
beforeUnmount	onBeforeUnmount
unmounted	onUnmounted
errorCaptured	onErrorCaptured
renderTracked	onRenderTracked
renderTriggered	onRenderTriggered
```

```js
// src/components/UserRepositories.vue `setup` function
import { fetchUserRepositories } from '@/api/repositories'
import { ref, onMounted } from 'vue'

// in our component
setup (props) {
  const repositories = ref([])
  const getUserRepositories = async () => {
    repositories.value = await fetchUserRepositories(props.user)
  }

  onMounted(getUserRepositories) // on `mounted` call `getUserRepositories`

  return {
    repositories,
    getUserRepositories
  }
}
```

#### 监听watch

```js
import { ref, watch } from 'vue'

const counter = ref(0)
watch(counter, (newValue, oldValue) => {
  console.log('The new counter value is: ' + counter.value)
})
```

#### toRefs

```js
import { fetchUserRepositories } from '@/api/repositories'
import { ref, onMounted, watch, toRefs } from 'vue'

// 在我们组件中
setup (props) {
  // 使用 `toRefs` 创建对prop的 `user` property 的响应式引用
  const { user } = toRefs(props)

  const repositories = ref([])
  const getUserRepositories = async () => {
    // 更新 `prop.user` 到 `user.value` 访问引用值
    repositories.value = await fetchUserRepositories(user.value)
  }

  onMounted(getUserRepositories)

  // 在用户 prop 的响应式引用上设置一个侦听器
  watch(user, getUserRepositories)

  return {
    repositories,
    getUserRepositories
  }
}
```

#### computed

```js
import { ref, computed } from 'vue'

const counter = ref(0)
const twiceTheCounter = computed(() => counter.value * 2)

counter.value++
console.log(counter.value) // 1
console.log(twiceTheCounter.value) // 2
```

#### 提供/注入

```js
// provider
import { provide } from 'vue'
import MyMarker from './MyMarker.vue

export default {
  components: {
    MyMarker
  },
  setup() {
    provide('location', 'North Pole')
    provide('geolocation', {
      longitude: 90,
      latitude: 135
    })
  }
}

// inject
import { inject } from 'vue'

export default {
  setup() {
    const userLocation = inject('location', 'The Universe')
    const userGeolocation = inject('geolocation')

    return {
      userLocation,
      userGeolocation
    }
  }
}

```

##### 添加响应式

```js
import { provide, reactive, ref } from 'vue'
import MyMarker from './MyMarker.vue

export default {
  components: {
    MyMarker
  },
  setup() {
    const location = ref('North Pole')
    const geolocation = reactive({
      longitude: 90,
      latitude: 135
    })

    provide('location', location)
    provide('geolocation', geolocation)
  }
}
```

##### 修改响应式 property

有时我们需要在注入数据的组件内部更新注入的数据。在这种情况下，我们建议提供一个方法来负责改变响应式 property。

```js
// Provider
import { provide, reactive, ref } from 'vue'
import MyMarker from './MyMarker.vue

export default {
  components: {
    MyMarker
  },
  setup() {
    const location = ref('North Pole')
    const geolocation = reactive({
      longitude: 90,
      latitude: 135
    })

    const updateLocation = () => {
      location.value = 'South Pole'
    }

    provide('location', location)
    provide('geolocation', geolocation)
    provide('updateLocation', updateLocation)
  }
}

// inject
import { inject } from 'vue'

export default {
  setup() {
    const userLocation = inject('location', 'The Universe')
    const userGeolocation = inject('geolocation')
    const updateUserLocation = inject('updateLocation')

    return {
      userLocation,
      userGeolocation,
      updateUserLocation
    }
  }
}
```

##### 只读 readonly

```js
import { provide, reactive, readonly, ref } from 'vue'
import MyMarker from './MyMarker.vue

export default {
  components: {
    MyMarker
  },
  setup() {
    const location = ref('North Pole')
    const geolocation = reactive({
      longitude: 90,
      latitude: 135
    })

    const updateLocation = () => {
      location.value = 'South Pole'
    }

    provide('location', readonly(location))
    provide('geolocation', readonly(geolocation))
    provide('updateLocation', updateLocation)
  }
}
```

#### 使用JSX

```js
export default {
  setup() {
    const root = ref(null)

    // with JSX
    return () => <div ref={root} />
  }
}
```