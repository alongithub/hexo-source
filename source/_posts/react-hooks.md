---
title: react-hooks
date: 2021-01-20 15:19:47
tags: hooks
hoc: true
description: react hooks 常见用法，自定义hooks方式，以及useState、useEffect、useReducer实现原理
---

### react hooks

#### userState

**useState** 在使用声明时可以传一个函数，这个函数可以用于动态的给 **useState** 附初始值，而函数中的代码又只会执行一次。

```js
// 通过这种方式也可以动态的附初始值，但是函数组件在每次调用的时候都会计算一次初始值，这无疑是浪费性能的
function Demo (props) {
	const num = props.num * 100;
	const [count, setCount] = useState(num);
}

// 通过useState附初始值动态设置初始数值
function Demo (props) {
	const [count, setCount] = useState(() => {
		return props.num * 100;
	})
}
```

##### 设置状态值得函数使用细节
**useState**结构的第二的参数是设置值的函数，这个函数可以接受值，也可以接收一个函数。如上面的 **setCount** 在调用时可以传入一个函数，这个函数接收一个形参 ，代表当前值，函数返回要更改的值

```js
setCount(123); // 直接设置数值

// 拿到原始值并返回新值
setCount((count) => {
	return count + 1;
})
```

上面提到的 **setCount** 函数是异步的，比如下面的例子，返回的结果是1

```js
const [count, setCount] = setState(1);


function handle() {
	setCount(count => count + 1);
	console.log(count);
}
```
上边的代码中当 **handle**函数被调用时， **setCount** 会修改 **count** 的值，但是由于 **set** 函数是异步执行的，所以 打印的 **count** 值 任然为1

为了解决这个问题，可以将打印结果的代码放到 **setCount**传入的函数中

```js
funtion handle() {
	setCount(count => {
		const newcount = count + 1;
		console.log(newcount);
		return newcount;
	})
}
```


#### useReducer

**useReducer** 类似 **redux** , 用于统一管理状态

```js
function reducer(state, action) {
	switch(action.type) {
		case 'increment': return state + 1;
		default: return state;
	}
}

function Num () {
	const [count, dispatcn] = useReducer(reducer, 0); // 第一个参数是reducer处理函数，第二个是初始值

	return <button onClick={() => {
		dispatch({type: 'increment'});
	}}>{count}</button>
}
```


#### useContext

用户跨组件跨层级传递数据

```js
// 在上层组件中
import {React, createContext, useContext} from 'react';

const context = createContext()

function App() {
	return <context.Provider value={100}>
		<Foo/>
	</context.Provider>
}

// 子孙组件
// 在useContext 之前的写法
function Foo () {
	return <context.Consumer>
		{
			// 通过context.Consumer包裹 的 函数会接受一个形参，这个形参就是外层传入的value的值
			value => {
				return <div>{value}</div>
			}
		}
	</context.Consumer>
}


// 下面是使用useContext之后的写法
function Foo () {
	const value = useContext(context); // 传入上层生成的content
	return <div>
		{value}
	</div>
}
```

#### useEffect 处理副作用


**useEffect** 注意卸载时的细节

```js
// 这种写法只有在App被卸载时才会打印 “卸载”
function App() {
	useEffect(() => {
		return () => {
			console.log('卸载')
		}
	}, [])

	return ...
}

// 这种写法只要函数组件执行（比如state改变，props改变，父组件更新等）就会打印“卸载”
function App() {
	useEffect(() => {
		return () => {
			console.log('卸载')
		}
	})

	return ...
}

```

##### useEffect 相比生命周期函数的优点

- **useEffect**由于可以多次调用，因此可以按照用途把代码进行分类
- 简化重复代码，使组件内部代码更清晰。比如常常 **componentDidmount** 和 **componentDidUpdate** 会执行一些相同的逻辑

##### useEffect 第二个参数

**useEffect** 第二个参数可以不传也可以传数组，空数组代表只在挂载时执行一次，如果数组中有值，则会在第一次和人一个数组项发生改变时执行

##### useEffect 处理异步

**useEffect** 如果写成 **async** 函数，执行会报错，因为 **useEffect** 只能返回一个函数，这个函数用于 组件卸载时使用，或者不返回内容。而 **async** 函数会返回一个 **promise** 这是 **useEffect** 中不被允许的

我们可以这样来写

```js
useEffect(() => {
	(async () => {
		const {data} = await axios.get();
		setData(data);
	})()
}, [])

// 或者
useEffect(() => {
	axios.get().then(data => {
		setData(data.data);
	});
}, [])

// 或者
const getData = async () => {
	const {data} = await axios.get();
	setData(data);
}
useEffect(() => {
	getData();
}, [])

// ...
```

#### useMemo

类似于 **Vue** 中的计算属性，可以根据某个值得变化计算新值
**useMemo** 会缓存计算结果，如果监测值没有变化，组件重新渲染也不会重新计算

```js
const reuslt = useMemo(() => {
	return count * 2;
}, [count])
```

#### React.memo

用于函数组件的性能优化，如果组建中数据没有发生变化，阻止组件更新，类似类组件使用的 **PureComponent**

**React.memo** 是一个高阶组件（HOC， 高阶组件用于共享代码，逻辑复用）

```javascript
const MemoCon = React.memo((props) => {
	return <div>{props.name}</div>
})

// 使用 <MemoCon>时 只要name不变就不会重新渲染
```

**memo** 也可以通过传递第二个参数，来进行深度比较

```javascript
function Name(props) {
	return <div>{props.obj.name}</div>
}

const MemoCon = React.memo(Name, (preProps, newProps) => {
	if (preProps.name === newProps.name) {
		return true; // 返回 true 代表不用更新
	}

	return false; // 返回false 代表需要更新
})
```

#### useCallback()

用于函数组件的性能优化，可以缓存函数，使组件重新渲染时获得相同的函数实例

```react
function Counter() {
	const test = useCallback(() => {console.log('test')}, []);
	return <MemoTest test={test}/>
}
```

在上面的例子中，如果**test**不使用**useCallback**包装，会导致组件render时，每次给 **MemoTest** 的 **test** 都是一个新的函数实例，从而导致 **memo** 没有发挥作用

#### useRef()

##### **useRef** 用于获取 **DOM** 对象

```javascript
function App() {
	const ref = useRef();
	
	// 可以通过 ref.current 获取到对应的dom元素
	const change = () => {
		console.log(ref.current.value);
	}
	
	return <input ref={ref} onChange={change}/>
}
```

##### 用于保存数据

比如可以用于保存 唯一实例，在state改变后仍然可以拿到之前的实例

这里以一个计时器的功能为例，点击按钮清除计时器

```react
function App () {
	const timer = useRef(null);
		
	useEffect(() => {
		timer.current = setInterval(..)
	}, [])
	
	return <button onClick={() => {
		cleatInterval(timer.current)
	}}>清除计时器</button>
}
```

### 自定义 Hook

- 用于函数组件封装共享逻辑

- 自定义Hook是一个函数，以use开头

- 自定义Hook就是逻辑和内置Hook的组合

这里以实现一个时钟为例，演示 自定义 **Hook** 的逻辑复用方式

```react
// 自定义时钟 hook
function useTime() {
	const [time, setTime] = useState('')
	useEffect(() => {
		const timer = setInterval(() => {
			const date = new Date();
			setTime(`${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`)
		}, 1000);
		return () => {
			clearInterval(timer);
		}
	}, [])

	return time;
}

function App() {
    // 直接使用hook， 并接受返回值
	const time = useTime();
	
	return <div>
		{time}
	</div>
}
```

再以一个表单为例，抽离双向绑定的逻辑

```react
function useInput(initialValue) {
	const [value, setValue] = useState(initialValue);
	return {
		value,
		onChange: e => setValue(e.target.value)
	}
}

function App() {
	const username = useInput('along');
	const password = useInput('123456');

	const submit = e => {
		e.preventDefault();
		console.log(username.value, password.value);
	}
	return <form onSubmit={submit}>
		<input type="text" {...username}/>
		<input type="password" {...password}/>
		<input type="submit"/>
	</form>
}
```

### React-router-dom 提供的路由钩子函数

```react

ReactDOM.render(
  <BrowserRouter>
    <Link to="/home">首页</Link>
    <Link to="/test/1">代码联系</Link>
    <Route path="/home" component={Home} />
    <Route path="/test/:appid" component={App} />
  </BrowserRouter>,
  document.getElementById('root')
);

<Link>
```

当时用 **react-router-dom** 定义路由时，每个路由模块内部的 **props** 会 自动注入 **history ** **location** **match** 几个属性，用于获得当前组件的路由相关的信息。我们可以直接通过**props**拿到对应的属性，不过，如果组件有多层嵌套，比如 **App** 组件中使用了 **<Test/>** 组件 ，在 **Test** 组件中如果要取到 路由相关的信息，需要 **App** 将 **props** 向下传递，在组建嵌套较深时我们需要逐层传递无疑会非常麻烦。

因此 **react-router-dom** 为我们提供了几个 内置 **hook** ，方便我们在组件中拿到 路由相关的参数，而不必考虑 组件嵌套的层级

- **useHistory** 获取 props 中的 history 对象

- **useLocation** 获取 props 中的 location 对象

- **useRouteMatch** 获取 props 中的 match 对象

- **useParams** 获取 props 中的 match 属性下的 params 对象

```react
<Route path="/test" component={App} />

// 不适用 路由 相关 hook, 路由相关的属性需要逐层传递
function Test(props) {
    return props.history
}
function App(porps) {
	return <div><Test history={props.history}/></div>
}

// 使用 路由 hook， 可以直接拿到路由参数
function Test() {
    const history = useHistory();
    return history
}
function App() {
	return <div><Test/></div>
}
```

### react hooks 实现原理

#### useState

实现一个简易的 **useState**

```react
let state = []; // 用于保存所有useState 的 value 值
let setters = []; // 用于保存 所有 useState 的 setter ， 即useState 返回数组的 第二项
let stateIndex = 0; // 用于 记录当前 value 和 setter 的 索引。

// 用于创建一个 闭包的 setter ， 来修改对应索引的 state 数组中的值
const createSetter = (stateIndex) => {
	return (value) => {
		state[stateIndex] = value;
		render();
	}
}

// useState 实现， 接收一个默认值，在首次调用时 设置value 为默认值， 从第二次开始从 state 数组中取
function useState(initialState) {
    // 当 索引 能在 state 数组中取到值时， 返回 state 数组中对应的值，否则返回 传入的默认值
	state[stateIndex] = stateIndex < state.length ? state[stateIndex] : initialState;
    // 创建setter 并 保存到 setters 数组的对应位置
	setters.push(createSetter(stateIndex));
    // 取到对应的 value 和 setter
	const value = state[stateIndex];
	const setter = setters[stateIndex];
    // 索引指针向后移以为，待下一个 useState 使用
	stateIndex ++;
	return [value, setter];
}

// 当 useState 的 setter 被执行时调用，重新渲染 整个应用，并 将 索引 内置
function render() {
	stateIndex = 0;
	ReactDOM.render(<App />, document.getElementById('root'));
}

// 程序入口
function App() {
	const [count, setCount] = useState(0);
	const [name, setName] = useState('along');
	return <div>
		<div>{count}<button onClick={() => {setCount(count + 1)}}>加</button></div>
		<div>{name}<button onClick={() => {setName('文龙')}}>改名</button></div>
		
	</div>
}

// 首次渲染
ReactDOM.render(
  <App/>,
  document.getElementById('root')
);
```

由上面的实现代码可以看出，useState的顺序很重要，如果**useState** 顺序发生了改变，会导致取值出现问题 【ps：这里只是演示 useState的实现原理，上述代码在一些场景会有问题】

#### useEffect

接着上面 **useState** 的代码，来实现一下 **useEffect**

```react
let preDepsArr = []; // 定义一个全局变量用来保存上一次 useEffect 的依赖数组， 如果 useEffect 没有传递第二个参数，则不会在这里保存
let effectIndex = 0; // 类似于 useState 的 stateIndex, 用于记录 当前 useEffect 的索引。

// render函数中要额外重置一下 effectIndex
function render() {
	stateIndex = 0;
	effectIndex = 0;
	ReactDOM.render(<Root/>, document.getElementById('root'));
}

function useEffect(callback, depsArr) {
	if (Object.prototype.toString.call(callback) !== '[object Function]') throw new Error('第一个参数需要是函数');

	// 如果没有传递第二个参数，直接调用callback执行
	if (typeof depsArr === 'undefined') {
		callback();
	} else {
		if (Object.prototype.toString.call(depsArr) !== '[object Array]') throw new Error('第二个参数要么不传，要么必须是数组');

		// 拿到上一次的依赖，第一次执行时肯定没有这个依赖值
		let preDeps = preDepsArr[effectIndex];

		// 定义一个变量，用于表示依赖是否发生过变化
		// 如果 上一次的依赖不存在，说明发生了变化，直接赋值 hasChange 为 true
		// 如果 上一次的依赖  存在，比对新旧依赖数组的每一项，如果有一项发生改变，赋值 hasChange 为 true
		let hasChange = preDeps 
			? depsArr.every((dep, index) => dep === preDeps[index]) === false 
			: true;

		// 如果发生了改变，执行回调函，并将新的依赖数组替换掉原来的依赖数组
		if (hasChange) {
			callback();
			preDepsArr[effectIndex] = depsArr;
		}
		effectIndex ++;
	}

}

function App() {
	const [count, setCount] = useState(0);
	const [name, setName] = useState('along');
	
	useEffect(() => {
		console.log('count改变了')
	}, [count])
	
	useEffect(() => {
		console.log('name改变了')
	}, [name])
	
	return <>
		<button onClick={() => {setCount(count + 1)}}>{count}</button>
		<button onClick={() => {setName('阿龙')}}>{name}</button>
	</>
}
```

这里并没有实现 useEffect 回调函数有返回值的情况

#### useReducer

**useReducer** 原理非常简单，它实际上是 **useState** 和 **redux** 设计思想的结合

```react
function useReducer(reducer, initialState) {
	const [state, setState] = useState(initialState); // 内部使用 useState 保存状态
	const dispatch = (action) => {
		setState(reducer(state, action));
	}

	return [state, dispatch];
}

function App() {
	function reducer(state, action) {
		switch(action.type) {
			case 'incre': return state + 1;
			case 'decre': return state - 1; 
			default: return state;
		}
	}
	const [num, dispatch] = useReducer(reducer, 0);

	return <>
		<button onClick={() => {dispatch({type: 'incre'})}}>{num}</button>
	</>
}
```

