---
title: vue全家桶+ts+eslint项目搭建
date: 2020-10-29 09:32:03
tags: [vue项目]
toc: true,
description: vue + vuex + vue-router + TypeScript + ESLint + Git + sass + 身份认证 + 权限系统
---

## 初始化

### 安装脚手架工具
安装@vue-cli

我这里用的是@vue-cli v4.5.8

```
npm install @vue-cli -g
```


### 初始化项目

执行
```
vue create boss
```


选择一个预设，这里选第三个手动配置选项
```
? Please pick a preset:
  Default ([Vue 2] babel, eslint)
  Default (Vue 3 Preview) ([Vue 3] babel, eslint)
> Manually select features  手动配置选项  
```

选择需要的功能到项目中
```
? Check the features needed for your project:
 ( ) Choose Vue version  选择vue版本不勾选默认vue2
 (*) Babel
 (*) TypeScript
 ( ) Progressive Web App (PWA) Support
 (*) Router
 (*) Vuex
 (*) CSS Pre-processors
>(*) Linter / Formatter
 ( ) Unit Testing
 ( ) E2E Testing   
```

是否使用 class 风格，建议勾选
```
Use class-style component syntax? (Y/n) y  
```

手否使用ts只编译类型相关部分，babel编译常规js部分，建议勾选
```
Use Babel alongside TypeScript (required for modern mode, auto-detected polyfills, transpiling JSX)? (Y/n) y
```

是否使用history模式，这里建议no,history更美观但是兼容性比hash模式差一些
```
Use history mode for router? (Requires proper server setup for index fallback in production) (Y/n) n 
```

选择css预处理器，如果使用sass建议选择第一项，dart-sass性能更好,这个根据个人需要选择
```
Pick a CSS pre-processor (PostCSS, Autoprefixer and CSS Modules are supported by default): (Use arrow keys)
> Sass/SCSS (with dart-sass)
  Sass/SCSS (with node-sass)
  Less
  Stylus  
```

选择代码校验规则,我这里选用Standard代码风格
```
Pick a linter / formatter config:
  ESLint with error prevention only
  ESLint + Airbnb config
> ESLint + Standard config
  ESLint + Prettier
  TSLint (deprecated) 
```

选择触发代码校验的时机,第一项是在保存代码时，第二项是自动修正和代码提交时，这里全选
```
 Pick additional lint features:
 (*) Lint on save
>(*) Lint and fix on commit 
```

babel,eslint,配置信息单独存放到自己的配置文件中，方便以后的修改
```
Where do you prefer placing config for Babel, ESLint, etc.? (Use arrow keys)
> In dedicated config files
  In package.json   
```

是否保存当前配置方便下次快速生成项目，这里不需要
```
 Save this as a preset for future projects? (y/N) n
```

接下来会开始安装依赖和创建项目

### 启动项目

进入项目并启动
```
npm run serve
```

## 初始化文件调整

### scr/app.vue

删除不必要的内容
```js
<template>
  <div id="app">
    <router-view/>
  </div>
</template>

<style lang="scss">
</style>
```

### src/router/index.ts

清空路由规则
```js
import Vue from 'vue'
import VueRouter, { RouteConfig } from 'vue-router'

Vue.use(VueRouter)

const routes: Array<RouteConfig> = [
]

const router = new VueRouter({
  routes
})

export default router
```

### src/views, src/components, src/assets

删除目录下的文件

### 创建目录

src/utils 工具模块

src/styles 全局相关样式

src/services 存储接口API函数

## 使用TS

### 安装

如果项目在vuecli初始创建时没有选用Ts,可以使用 @vue/cli 安装 TypeScript 插件：

```
vue add @vue/typescript
```

### 开始类型推断的用法

Options Api 不会提供类型提示，如果需要使用类型推断，需要使用 extend、component或者class 写法

要想提供ts支持，需要在script标签添加lang="ts"

```
<script lang="ts"></script>
```

> 要让 TypeScript 正确推断 Vue 组件选项中的类型，您需要使用 Vue.component 或 Vue.extend 定义组件：

```html
<script lang="ts">
    import Vue from 'vue'
    const Component = Vue.extend({
    // 类型推断已启用
    })

    const Component = {
    // 这里不会有类型推断，
    // 因为 TypeScript 不能确认这是 Vue 组件的选项
    }
</script>
```

> 如果您在声明组件时更喜欢基于类的 API，则可以使用官方维护的 vue-class-component 装饰器：

- 引入装饰器Component
- 通过@Component包装导出的类

```html
<script lang="ts">
    import Vue from 'vue'
    import Component from 'vue-class-component'

    // @Component 修饰符注明了此类为一个 Vue 组件
    @Component({
    // 所有的组件选项都可以放在这里
    template: '<button @click="onClick">Click!</button>'
    })
    export default class MyComponent extends Vue {
    // 初始数据可以直接声明为实例的 property
    message: string = 'Hello!'

    // 组件方法也可以直接声明为实例的方法
    onClick (): void {
        window.alert(this.message)
    }
    }
</script>
```

## 使用ESLINT

自定义规范

.eslintrc.js中可以自定义规则

我这里追加了规则

{% asset_img 1.png %}

[更多规则参照这里](https://eslint.bootcss.com/docs/rules/)
[Ts相关规则参照这里](https://github.com/typescript-eslint/typescript-eslint/tree/master/packages/eslint-plugin)
[Vue相关规则参照这里](https://eslint.vuejs.org/rules/)

可以根据团队和个人喜好自行配置，修改.eslintrc.js需要重启服务，如果重启不生效手动删除node_modules/.cache再启动

*有时候一些配置会与vscode默认的格式化格式不一致，此时需要修改vscode的配置，或者修改eslint配合

比如这里我用的规则设置了tab缩进，但是当使用vscode的alt+shift+f自动格式化时，vscode会将缩进替换成空格

此时可以打开设置，搜索indent，找到Vetur › Format › Options: Use Tabs项，选中

{% asset_img altf.png %}

## Element UI 组件库

### 安装

```
npm i element-ui -S
```

### 引入

引入方式可以全部引入也可按需引入，这里我配置完整引入，按需引入方式参照[这里](https://element.eleme.cn/#/zh-CN/component/quickstart)


在 main.js 中写入以下内容：
```js
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';

Vue.use(ElementUI);
```

## style 样式

### style文件夹

>src/styles 
>├── index.scss # 全局样式（在入口模块被加载生效），引入其他样式文件（比如下方的样式文件以及element的样式等）并在main中引入 
>├── mixin.scss # 公共的 mixin 混入（可以把重复的样式封装为 mixin 混入到复用的地方） 
>├── reset.scss # 重置基础样式 
>└── variables.scss # 公共样式变量

### 全局样式变量

比如我在 variables.scss中定义样式变量

```scss
$primary-color: #40586F; 
$success-color: #51cf66; 
$warning-color: #fcc419; 
$danger-color: #ff6b6b; 
$info-color: #868e96; // #22b8cf; 
$body-bg: #E9EEF3; // #f5f5f9; 
$sidebar-bg: #F8F9FB; 
$navbar-bg: #F8F9FB; 
$font-family: system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
```

创建 vue.config.js

```js
module.exports = {
    css: {
        loaderOptions: {
            scss: {
                // scss 加载是自动注入这行代码
                prependData: '@import "~@/styles/variables.scss";'
            }
        }
    }
}
```

修改vue.config.js需要重启项目

之后再任意文件中就可以使用variables中的样式变量了

比如我在App.vue中直接使用样式变量，而不需要引入变量所在的文件

{% asset_img scss.png %}

## 代理

开发过程中用于代理后台接口，处理跨域问题

通过配置vue.config.js来处理

```js
module.exports = {
    ...
    devServer: {
        proxy: {
            '/front': {
                target: 'http://a.com',
                // ws: true, // 意思是转发websorket
                changeOrigin: true // 设置请求头中的 host 为 target，防止后端反向代理服务器无法 识别 
            },
            '/user': {
                target: 'http://b.com',
                changeOrigin: true
            }
        }
    }
}
```
## 请求模块封装

安装axios
```
npm install axios -S
```

src/utils/request.ts

```ts
import axios from "axios";
const request = axios.create({

});

export default request;
```

// 待补充

## 路由

### 创建文件目录

在src/views中创建文件

src/views/home/index.vue 主页
src/views/user/index.vue 用户管理
src/views/role/index.vue 角色管理
src/views/login/index.vue 登录界面
src/views/error-page/404.vue 404界面

### 配置路由规则


src/router/index.ts
```js
const routes: Array<RouteConfig> = [
	{
		path: '/',
		name: 'home',
		// 懒加载模块，单独打包，webpackChunkName 可以手动配置打包后的文件名字，方便调试
		component: () => import(/* webpackChunkName: 'home' */ '@/views/home/index.vue')
	},
	{
		path: '/login',
		name: 'login',
		component: () => import(/* webpackChunkName: 'login' */ '@/views/login/index.vue')
	},
	{
		path: '/role',
		name: 'role',
		component: () => import(/* webpackChunkName: 'role' */ '@/views/role/index.vue')
	},
	{
		path: '/user',
		name: 'user',
		component: () => import(/* webpackChunkName: 'user' */ '@/views/user/index.vue')
	},
	{
		path: '*',
		name: '404',
		component: () => import((/* webpackChunkName: '404' */ '@/views/error-page/404.vue')
	}
];
```

## 界面布局

