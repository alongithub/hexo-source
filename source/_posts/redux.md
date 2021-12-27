---
title: redux
date: 2021-01-14 15:16:30
tags: redux
toc: true
description: redux 的基本使用和一些常用库，另外包含了redux createStore、enhancer、applyMiddleware、bindActionCreators、combineReducers等函数实现原理
---

###  redux

#### bindActionCreators更优雅地创建mapDispatchToProps 函数

编写好 `actionCreator `文件

```react
export const onAdd = (num) => {
    return {
        type: ADDNUM,
        num,
    }
}

export const onDelete = (num) => {
    return {
        type: DELETENUM,
        num,
    }
}
```

引入 `bindActionCreators`和 `actionCreator.js`中的所有方法

```react
import {bindActionCreators} from 'redux';
import * as actionCreators from './redux/action';
```

通过`bindActiionCreators` 生成`mapDispatchToProps`的返回值

```react
const mapDispatchToProps = dispatch => bindActionCreators(actionCreators, dispatch);

export default connect(null, mapDispatchToProps)(Conmponent); 
```

这样就可以直接在组建`Component`中使用`actionCreator.js`中定义的同名方法啦

```react
function ({onAdd, onDelete}) {
	return ...
}
```



#### redux 定义中间件

1、定义一个中间件需要创建一个函数,满足下面的格式，其中最外层store可以去到**getState** 、**dispatch**方法

```react
export default store => next => action => {}
```

这里我定义一个打印日志的中间件

```react
export default store => next => action => {
	console.log(action);
	next(action); // 传递给下一个中间件或者reducer
}
```

2、注册中间件,通过`applyMiddleware`注册中间件,多个中间件可以依次传入，中间件执行顺序与注册顺序相同

```react
import {createStore, applyMiddleware} from 'redux';
import logMiddleWare from './middlewares/logMiddleWare';

export default createStore(reducer, applyMiddleware(
	logMiddleWare // 如果有多个中间件 middleware1, middleware2, ...
));
```

如果项目中使用了**redux-devtools-extension**，可以这样写

```react
import {composeWithDevTools} from 'redux-devtools-extension'; // 用于开发环境浏览器插件调试
export default createStore(reducer, composeWithDevTools(applyMiddleware(logMiddleWare)));
```

3、定义一个处理异步的中间件(redux-thunk 机制)

上述代码中的**actionCreators.js**编写的**action**都是返回一个对象，包含了**action**的类型和数据，如果要编写一个异步的**action**怎么办呢

我们可以编写一个中间件，在接收**actionCreator**的返回值是判断返回值**action**得类型，如果是普通的携带**type**的对象，就直接放行。如果类型是一个函数，我们就认为他是一个异步动作，执行这个函数并将**dispatch**函数传递给它，将执行权交给这个异步函数，由他来决定派发下一个**actionCreator**的时机

我们在**actionCreators.js**中编写一个异步的**actionCreator**,它返回一个函数，并且在这个函数中异步的调用了其他的**actionCreator**

```react
export const onAdd = (num) => {
    return {
        type: ADDNUM,
        num,
    }
}

// 异步函数返回一个函数，派发了其他的actionCreator
export const onAdd_async = (num) => {
    return (dispatch) => {
        setTimeout(() => {
           dispatch(
               onAdd(num)
           ) 
        }, 5000)
        
    }
}
```

接下来定义一个中间件，用来处理异步的**action**

```react
export default store => next => action => {
	if (typeof action === 'function') {
        action(store.dispatch);
        return;
    }
    // 正常的情况（action是一个对象）直接放行
	next(action); // 传递给下一个中间件或者reducer
}
```

之后在**creatStore**时注册这个异步中间件就可以了

#### redux-saga

**redux-saga**允许我们将异步**actionCreator**单独抽离出来，方便我们统一维护

1、编写**saga**抽离的函数文件 ,**post.saga.js**

```javascript
import {takeEvery, put} from 'redux-saga/effects';

function* async_add (action) {
	const result = yield axios.get('/api/add', {num:action.num});
   	if (result.code === 1) {
		yield put(add_num_success(num:action.num)); // put相当于dispatch，通过put执行普通的action给reducer
    }
}

// saga要求默认导出generator函数
export default funciton* postSaga() {
	yield takeEvery(ASYNC_ADDNUM, async_add)
}
```



2、安装引入启用并注册 **redux-saga**

```react
import createSagaMiddleware from 'redux-saga';
import postSaga form './store/saga/post.saga.js'; // 引入编写的saga文件

const sagaMiddleware = createSagaMiddleware();

...
export default createStore(reducer, applyMiddleware(sagaMiddleware))

sagaMiddleware.run(postSaga); // 启用saga
```

3、拆分saga文件

实际工作中我们需要把异步拆分到多个**saga**文件中，便于维护。因此这里再编写一个**saga**文件**logout.saga.js**

```react
import {takeEvery, put, delay} from 'redux-saga/effects';

function* async_logout () {
	yield delay(2000); 
	yield put(logout());
}

// saga要求默认导出generator函数
export default funciton* logoutSaga() {
	yield takeEvery(LOGOUT, async_logout)
}
```

在一个统一的入口**saga**文件**root.saga.js**中合并并导出**saga**

```react
import {all} from 'redux-saga/effects';

import postSaga from './post.saga.js';
import logoutSaga from './logout.saga.js';

export default function* rootSaga() {
	yield all([
		postSaga(),
		logoutSaga()
	])
}
```

接下来再注册**saga**时只需要注册**rootSaga**

```react
import rootSaga form './store/saga/root.saga.js';

...
sagaMiddleware.run(rootSaga); // 启用saga
```

#### redux-actions

**redux** 流程存在大量样板代码，比如**actionType**的抽离,**redux-actions**可以帮助我们简化代码

1、创建**actionCreator**函数

```react
import {createAction} from 'redux-actions';

export const onAdd = createAction('add num');
```

2、创建**reducer**函数

```react
import {handleActions as createReducer} from 'redux-actions';
import {onAdd} from './actionCreator.js';

const initState = {num: 0}

const handleAdd => (state, action) => ({
	// 组件传递的参数，会添加到action.payload中
    num: state.num + action.payload
})

export default createReducer({
	[onAdd]: handleAdd
}, initState);
```



3、在组件中使用

```react
function Add({onAdd}) {
	return <div>
		<button onClick={() => onAdd(5)}>添加</button>
	</div>
}
```

#### redux-actions 结合 redux-saga使用示例

为了防止你看到这里感到混乱，不如来一个案例，看看**actions** 和 **saga** 如何配合**redux**完成工作流

现在我们要实现一个获取商品列表并展示的功能，我们来定义一下文件结构

```
src/products/          
---- redux/
---- ---- saga/
---- ---- actionCreator/
---- ---- reducer/
---- index.js
root.saga.js
store.js
index.js
```

1、首先我们来编写**actionsCreator/actionsCreator.js**

```react
import {createAction} from 'redux-actions';

export const loadProducts = createAction('load products from server');
export const setProducts = createAction('set local Products');
```

2、接下来创建**reducer**和**saga**，我们需要把普通的**actionCreator**和异步**actionCreator**分别交给**reducer/index.js** 和 **saga/index.js**下的文件来处理

**setProducts** 是设置本地的**store**中的数据，因此在**reducer/index.js**中处理

```react
import {handleActions as createReducer} from 'redux-actions';
import {setProducts} from '../actionCreator/actionsCreator.js';

const initState = []

const handleSetProducts => (state, action) => action.payload; // payload中存储了actionCreator被调用时的传参

export default createReducer({
	[setProducts]: handleSetProducts
}, initState);
```

**saga**中处理异步

```react
import {takeEvery, put} from 'redux-saga/effects';
import {setProducts, loadProducts} from '../actionCreator/actionsCreator.js';

function* async_loadProduct () {
	const result = yield axios.get('/getProduct'); // 返回 商品数组 
	yield put(setProducts(result.data));
}

// saga要求默认导出generator函数
export default funciton* productSaga() {
	yield takeEvery(loadProducts, async_loadProduct)
}
```

3、在**root.saga.js**中集中引入**saga**

```react
import {all} from 'redux-saga/effects';
import productSaga from './products/redux/saga'; // 引入商品的异步action saga

export default function* rootSaga() {
	yield all([
		productSaga(),
	])
}
```

4、**store.js**中注册**store**,启用**saga**

```react
import {createStore, combineReducers, applyMiddleware} from 'redux';
import createSagaMiddleware from 'redux-saga';
import rootSaga form './root.saga.js';
import productReducer from './src/products/redux/reducer';

const sagaMiddleware = createSagaMiddleware();

const reducer = combineReducers({
	products: productReducer
});

export default createStore(reducer, applyMiddleware(sagaMiddleware))

sagaMiddleware.run(rootSaga); // 启用saga
```

5、**react**入口文件中**index.js**引入**store**

```react
import React from 'react';
import ReactDom from 'react-dom';
import {Provider} from 'react-redux';
import store from './store.js';
import App from './'; // 这里引入你的的app入口

ReactDom.render(
    <Provider store={store}>
    	<App/>
    </Provider>,
    document.getElementById('root'),
);
```



6、商品模块的组件**products/index.js**中触发**actionCreator**

```react
import React, {useEffect} from 'react';
import {bindActionCreators} from 'redux';
import * as actionCreators from './redux/actionCreator/actionCreator';

const Product = ({loadProducts, products}) => {
	useEffect(() => {
		loadProducts(); // 组件加载时获取商品列表
	}, [])

	return products.map(l => ...);
}

const mapStateToProps = state => ({
	products: state.product
})
const mapDispatchToProps = dispatch => bindActionCreators(actionCreators, dispatch);
export default connect(mapStateToProps, mapDispatchToProps)(Product); 
```

ok！！ 这样这个商品组件就能成功的运行了

#### redux 原理

##### createStore

**redux**的原理其实就是一个观察者模式，创建好**store**之后通过**subscribe**注册观察者，我们先来实现一下**createStroe**的主要逻辑

**createStore**可以接收三个参数，分别是**reducer**，**preloadState**，**enhancer**，**preloadState**代表默认的**store**数据，通常我们不使用他，**enhancer**代表功能拓展。第二个参数可以省略直接传第三个参数

**createStore**的返回值需要有三个函数，**getState**， **dispatch**， 以及**subscribe**

先不考虑**enhancer**这个参数

```react
function createStore(reducer, preloadState) {
    // 检查参数类型
    if (typeof reducer !== 'function') throw new Error('reducer must be function')
    
    
    // 内部维护一个state
    let currentState = preloadState;
    
    function getState() {
        return currentState;
    }
    
    // 保存所有的观察者，当state变化执行所有的观察者
    let listeners = [];
    
    // 修改数据并通知所有观察者
    function dispatch(action) {
        // 判断action是否是{}对象，排除数组，null等
        if(!isPlainObject(action)) {
            throw new Error('action.__proto__ mast be Object.proptoType')
        }
        // 判断是否有type
        if (typeof action.type === 'undefined') throw new Error('action对象中必须要有type属性')
        currentState = reducer(currentState, action);
        listeners.forEach(l => {
            l();
        })
        
    }
    // 添加观察者
    function discribe(listener) {
        listeners.push(listener);
    }
    
    return {
        getState,
        dispatch,
        subscribe
    }
}

// 辅助方法，由于判断入参是否是一个 {}类型的对象，用于排除基本数据类型，以及数组、Fuction以及其他对象类型。
function isPlainObject (obj) {
    if (typeof obj !== 'object' || obj === null) return false;
    var proto = obj;
    // 就是判断入参的原型链是不是直接指向Object的原型
    while(Object.getPrototypeOf(proto) !== null) {
        proto = Object.getPrototypeOf(proto);
    }
    
    return Object.getPrototypeOf(obj) === proto
}
```

##### enhancer

接下来我们来实现下**enhancer**参数，**enhancer**在英文中是增强的意思，**redux**允许用户传入这个参数来创建增强的**store**

```react
function createStore(reducer, preloadState, enhancer) {
    // 检查reducer类型
    ...
    let currentState = preloadState;
    let listeners = [];
    /* ***enhancer 部分实现*** */
    // 检查enhancer的参数类型
	if (typeof enhancer !== 'undefined') {
        if (typeof enhancer !== 'function') throw new Error('enhancer munst be function');
        // 执行enhancer并传递给createStore, enhancer执行后需要返回一个函数，接收reducer，preloadState
        return enhancer(createStore)(reducer, preloadState)
    }
    /* *** */
    function getState() {...}
    function dispatch(action) {...}
    function discribe(listener) {...}
    
     return {
        getState,
        dispatch,
        subscribe
    }
}
```

当我们传入了合法的**enhancer**时，**createStore**方法会将控制权完全交给**enhancer**，由**enhancer**来调用自己创建增强的**store**

**enhancer**接收**createStore**,并返回一个新的函数，接收**reducer**，**preloadState**，最终返回一个增强的**store**

```react
// 我们来定义一个enhancer函数，实现类似redux-thunk的处理异步的功能
function enhancer(createStore) {
    return function (reducer, preloadState) {
        // enhancer 来调用createStore创建一个常规的store
        var store = createStore(reducer, preloadState);
        
        // 增强原有的dispatch
        var dispatch = store.dispatch;
        function _dispatch (action) {
            // 这里就可以实现具体的增强功能了，我们在这里模拟一个类似redux-thunk的功能
            if(typeof aciton === 'function') {
                return action(dispatch);
            }
            dispatch(dispatch);
        }
        
        return {
            ...store,
            dispatch: _dispatch
        }
    }
}
```

这样我们在调用**createStore**时传入定义的**enhancer**函数就可以实现类型**redux-thunk**的功能了

##### applyMiddleware

了解了**enhancer**的原理，我们来看下**applyMiddleware**这个增强器是怎么实现中间件的注册的

通过刚刚我们自定义**enhancer**函数我们了解到，**enhancer**需要接收一个参数**createStroe**，并返回一个接收**reducer**和**preloadState**的函数，最终返回一个增强的**store**

先来看下我们在使用**redux**的**applyMiddleware**时是怎么作为参数传递给**createStroe**的

```react
export default createStore(Reducer, applyMiddleware(logMiddleWare));
```

**applyMiddleware**函数在作为**createStore**的参数时，传入的是**applyMiddleware**的调用，并在他调用时传入了若干中间件，因此，**applyMiddleware**需要在执行后返回一个真正的**enhancer**函数

知道了这一点，再看下之前我们写的自定义中间件的格式，**applyMiddleware**函数的参数需要满足三层函数的格式

```react
function logger(store) {
	return function(next) {
		return function(action) {
			
			...中间件的内容
			next(action); // 执行下一个中间件
		}
	}
}
```

也就是说，**applyMiddleware**在增强**dispatch**函数时，需要依次执行中间件，并依次传递**store**、**next**、**action**这几个参数，**store**是**createStroe**创建的store，**action**是**actionCreator**的返回值，那么**next**是什么呢。

当还存在下一个中间件时，**next**就是下一个中间件。当不存在下一个中间件时，**next**就是**store**的**dispatch**函数

ok,来实现下**applyMiddleware**的代码

```react
function applyMiddleware(...middlewares) {
	return function(createStore) {
        return function (reducer, preloadState) {
            var store = createStore(reducer, preloadState);
			const middlewareApi = {
                getState: store.getState,
                dispatch: store.dispatch
            }
            
           	// 先将中间件执行一遍，依次拿到第二层函数
            const chain = middlewares.map(middleware => middleware(store))
            
            var dispatch = store.dispatch;
            // 将chain中的函数的返回值（第三层函数）依次作为上一个函数（第二层函数）的参数执行,最后一个中间件传递dispatch函数
            vr next = compose(...chain)(dispatch);

            return {
                ...store,
                dispatch: next
            }
		}
    } 
}

function compose() {
    var funcs = [...arguments];
    return function (dispatch) {
        let next = dispatch;
        for (let i = funcs.length - 1; i >= 0 ; i --) {
            next = funcs[i](next);
        }
        return next;
    }
}
```

在**applyMiddleware**的实现中，首先依次执行了所有中间件，并将所有的第二层函数保存到数组中。接下来，我们需要逆序执行第二层函数，将第二层函数返回的第三层函数作为上一个函数的参数**next**。

最终会返回第一个中间件的第三层参数。当这个函数被执行时，会依次执行后续中间件的第三层函数，并在最后一个中间件的第三层函数中执行**dispatch**函数。当然，你可以在任意一个中间件中阻止中间件向后执行，并**dispatch**新的**action**（我们上边自定中间件模拟的**redux-thunk**就是这么做的）

##### bindActionCreators

**bindActionCreators** 函数可以帮我们方便地结合**connect**给组件添加 用于派发**action**的函数

先来再看一下这个函数的使用

```react
import {bindActionCreators} from 'redux';
import * as actionCreators from './redux/action';

const mapDispatchToProps = dispatch => bindActionCreators(actionCreators, dispatch);

export default connect(null, mapDispatchToProps)(Conmponent); 
```

**bindActionCreators** 通过接收一个包含所有**actionCreator**的对象和**dispatch**函数，返回一个函数接收**dispatch**，并返回包含派发**action**函数的对象,这样说有点难理解，来看下边的转换关系。

```react
actionCreators = {
	onAdd: (arg) => {},
	onDelete: (arg) => {},
}

----------------- 最终返回 ===> ---------------------

(dispatch) => ({
	onAdd: (arg) => {
		dispatch( actionCreators.onAdd(arg) )
	},
	onDelete: (arg) => {
		dispatch( actionCreators.onDelete(arg) )
	}
})
```

看到这里基本就知道原理了，我们来实现以下代码

```react
function bindActionCreators (actionCreators, dispatch) {
	var mapDispatchToProps = {};
    for (let key in actionCreators) {
        mapDispatchToProps[key] = (...args) => {
            dispatch(actionCreators[key](...args));
        }
        
    }
    return mapDispatchToProps;
}
```

##### combineReducers

**combineReducers**允许我们将一个个小的**reduer**组合成一个**reducer**，下面我们看下这个函数的调用以及我们所期待的返回结果

```react
const reducer = combinReducers({
	product: (state, action) => { ... },
	...
});

----------------- 最终返回一个reducer函数 ====> ---------------------

(state, action) => {
	...
}
```

可以看出， **combineReducers** 最终需要返回一个新的 **reducer**函数，这个函数需要接收**action**并返回一个新的合并的**store**。

```react
const combineReducers = (reducers) => {
	// 检查reducers下每个字段值得类型，必须都是函数
	const reducerKeys = Object.keys(reducers);
	for (let key of reducerKeys) {
		if (typeof reducers[key] !== 'function') throw new Error('reducer must be a function');
 	}
	// 依次调用reducer，并将每个reducer的返回值返回到新的state中对应的部分
	return function (state, action) {
		const nextState = {};
		
		for (let key of reducerKeys) {
			const reducer = reducers[key];
            const oldState = state[key];
            nextState[key] = reducer(oldState, action);
		}
		
		return nextState;
	}
}
```

**combineReducers**的原理就是当执行一个**action**时，依次执行每个小的**reducer**，并将所有结果合并到一个大的**state**对象中

