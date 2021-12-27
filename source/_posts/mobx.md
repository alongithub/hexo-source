---
title: mobx
date: 2021-01-14 15:16:30
tags: mobx
toc: true
---

###  mobx

#### 准备

mobx需要项目支持装饰器语法，在**create-react-app**项目中，进行下面的操作

方式一:

      1. npm run eject
      2. npm install @babel/plugin-proposal-decorators
      3. package.json
    
        "babel": {
            "plugins": [
                [
                    "@babel/plugin-proposal-decorators",
                    {
                        "legacy": true
                    }
                ]
            ]
        }

  方式二:

      1. npm install react-app-rewired @babel/plugin-proposal-decorators customize-cra
    
      2. 在项目根目录下创建 config-overrides.js
    
          const { override, addDecoratorsLegacy } = require("customize-cra");
    
          module.exports = override(addDecoratorsLegacy());
      
      3. package.json
    
          "scripts": {
              "start": "react-app-rewired start",
              "build": "react-app-rewired build",
              "test": "react-app-rewired test",
          }

解决vscode编辑器关于装饰器语法的警告

  "javascript.implicitProjectConfig.experimentalDecorators": true

#### 安装

```
npm i mobx mobx-react
```

#### 上手使用

这里通过一个简易的商品列表的功能，来演示**mobx**的使用

首先需要创建一下文件结构

```
src/
---- product/
	 ---- store/
	      ---- mobx.js
	 ---- index.js
---- index.js
```

我们在**mobx.js中**创建一个**store** 

```javascript
import {observable, action, computed } from 'mobx';

class Product {
	// 通过observable修饰后的变量修改后才能被监听到
	@observable list = ['商品1'];
	@observable isPicking = false;

	// 计算属性，当依赖项改变时重新计算计算属性值，需要加 get
	@computed get totalNo () {
		const temp = this.list.filter(l => !l.isEat)
		return {
			num: temp.length,
			weight: temp.reduce((total, l) => {return total + l.weight}, 0),
			list: temp,
		}
	}
	@computed get totalEat () {
		const temp = this.list.filter(l => l.isEat)
		return {
			num: temp.length,
			weight: temp.reduce((total, l) => {return total + l.weight}, 0),
			list: temp,
		}
	}

	// 修饰用于修改属性值得方法，.bound 修饰才能保证this指向正确
	@action.bound eat = (code) => {
		this.list.find(l => l.code === code).isEat = true;
	}

	@action.bound addList = (name) => {

		this.list.push({
			code: this.code ++,
			weight: parseInt(Math.random() * 500)
		});
	}
}

// 实例并导出
const product = new Product();

export default product;
```

创建好的**store**需要在全局引入，并放入容器中方便子组件获取

```javascript
import {Provider} from 'mobx-react';
import product from './product/store/mobx';

ReactDOM.render(
  <Provider product={product}>
    <App />
  </Provider>,
  document.getElementById('root')
);
```

接下来我们在组件中尝试使用它

````javascript
import React from 'react';
import { inject, observer } from 'mobx-react';

@inject('product') // 注入product这个store
@observer  // 当数据改变时会响应式通知组件更新
class App extends React.Component {
	const { list, addList, totalNo, totalEat, eat } = this.props.product;
		return (
			<div className="App">
				<h2>苹果篮子</h2>
				<hr/>
				<div className="total">
					<div className="hastotal">
						<div>当前</div>
						<div>{totalNo.num}个苹果，{totalNo.weight}克</div>
					</div>
					<div className="nototal">
						<div>已吃掉</div>
						<div>{totalEat.num}个苹果，{totalEat.weight}克</div>

					</div>
				</div>
				{totalNo.list.map(l => {
					return <div className="appleitem">
						<div className="button">
							<button onClick={() => {eat(l.code)}}>吃掉</button>
						</div>
						<div className="appleImage">
							<img src={apple} />
						</div>
						<div className="title">
							红苹果 - {l.code}号
						</div>
						<div className="wiehgt">
							{l.weight}克
						</div>

					</div>
				})}
				<p className="pickWrapper">
					<button className="pick" onClick={() => {
						this.props.product.addList('商品')
					}}>添加一个商品</button>
				</p>

			</div>
		);
	}
}

export default App;
````

这样就可以看到**list**数据在页面中展示了