---
title: 搭建Vue SSR
date: 2020-09-27 15:24:58
toc: true
tags: [Vue ssr]
description: 搭建一个vue的ssr应用案例，并实现浏览器和服务端的同构，数据持久化
---

## 搭建VUE SSR

### 环境依赖安装
初始化项目`npm init`

安装依赖
```
npm install vue vue-server-renderer
```

### 服务端生成html文本
创建文件server.js
```
const Vue = require('vue');

const renderer = require('vue-server-renderer').createRenderer();

const app = new Vue({
    template: `<div id="app">
        <h1>{{ message }}</h1>
    </div>`,
    data: {
        message: 'vue ssr'
    }
})

renderer.renderToString(app, (err, html) => {
    if (err) throw err
    console.log(html);
})
```

node执行文件`server.js`
```
<div id="app" data-server-rendered="true"><h1>vue ssr</h1></div>
```

### html文本发送到浏览器，搭建web服务

安装express

```
npm install express
```
express 并配置路由

```js
const express = require('express');
const server = express();
server.get('/', (req, res) => {
    renderer.renderToString(app, (err, html) => {
        if (err) res.status(500).end('Internal Server Error')
        // 设置响应头避免乱码
        res.setHeader('Content-Type', 'text/html; charset=utf8')
        res.end(html);
    })
})

server.listen(3000, () => {
    console.log('server running at 3000')
})
```

启动项目，打开浏览器`localhost:3000`

{% asset_img 1.png %}


### 使用模板渲染html

创建`index-template.html`

```html

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title}}</title>
</head>
<body>
    <!--vue-ssr-outlet-->
</body>
</html>
```

注意这里的`<!--vue-ssr-outlet-->`是模板替换的标识, 不能有额外的空格，如果格式错误或者没有匹配到这个标识，会报`Content placeholder not found in template.`的错误

server.js中使用模板,`createRenderer`添加配置

```js
const fs = require('fs');
const renderer = require('vue-server-renderer').createRenderer({
    template: fs.readFileSync('./index-template.html', 'utf-8')
});
```

此后调用`renderer.renderToString`方法时会自动将参数vue实例渲染的内容添加到模板的指定位置中

模板中如果要传入数据可以通过给`renderer.renderToString(app, {title: 'vue ssr'}, fn)`添加第二个参数，传入数据，可以直接在模板中使用`{{key}}`来渲染字符串，使用`{{{key}}}`三层花括号的方式渲染为html标签

{% asset_img 2.png %}

### 同构

之前的代码服务端只能发送静态的html数据，对于双向绑定，点击事件等都无法生效，因为这些只能通过客户端处理才能生效。

创建目录`src`

#### 创建源代码文件

src/App.vue
```
<template>
    <div id='app'>
        <h1>{{message}}</h1>
        <input v-model="message"/>
        <p>
            <button @click="click">点击</button>
        </p>
    </div>
</template>
<script>
export default {
    name: 'App',
    components: {},
    data() {
        return {
            message: 'vue ssr'
        };
    },
    methods: {
        click: () => {
            console.log('点击')
        }
    },
    
}
</script>
```

src/app.js
```js
// 通用应用入口
import Vue from 'vue';
import App from './App.vue';

export function createApp() {
    const app = new Vue({
        render: h => h(App)
    })
    return {app}
}
```

src/entry-client.js
```js
// 客户端入口
import {createApp} from './app';

const {app} = createApp();

app.$mount('#app');
```

src/entry-server.js
```js
// 服务端入口
import {createApp} from './app';

export default content => {
    const {app} = createApp();

    // 服务端路由，数据预取

    return app;
}
```

#### 安装依赖

通过源代码文件不能直接在服务端和客户端执行，比如.vue文件，需要借助webpack打包

生产依赖
- `vue`
- `vue-server-renderer`vue 服务端渲染工具
- `express`
- `cross-env`npm区分环境变量

开发依赖
- `webpack` webpack核心包
- `webpack-cli`webpack命令行工具
- `webpack-merge` webpack配置合并
- `webpack-node-externals`排除webpack中的Node模块，在打包时排除掉例如fs等node模块
- `rimraf`基于node封装的跨平台rm -rf工具，可以借助命令行执行删除操作。这里用于打包前删除dist目录文件
- `friendly-errors-webpack-plugin`友好webpack错误提示
- `@babel/core @babel/plugin-transform-runtime @babel/preset-env babel-loader`
- `vue-loader vue-template-compiler`
- `file-loader` 处理字体资源
- `less less-loader`
- `css-loader`
- `url-loader` 处理图片资源

#### webpack配置

创建webpack配置文件

build/webpack.base.config.js

```js
const VueLoaderPlugin = require('vue-loader/lib/plugin');

const path = require('path');

const FriendlyErrorsWebpackPlugin = require('friendly-errors-webpack-plugin');

const resolve = file => path.resolve(__dirname, file);

const isProd = process.env.NODE_ENV === 'production';

module.exports = {
    mode: isProd ? 'production' : 'development',
    output: {
        path: resolve('../dist/'),
        publicPath: '/dist/',
        filename: '[name].[chunkhash].js',
    },
    resolve: {
        // 路径别名
        alias: {
            // @ 指向 src
            '@': resolve('../src/')
        },
        // 可以省略的扩展名
        // 当省略扩展名时。从前往后依次解析
        extensions: ['.js', '.vue', '.json'],
    },
    devtool: isProd ? 'source-map' : 'cheap-module-eval-source-map',
    module: {
        roles: [
            // 处理图片资源
            {
                test: /\.(png|jpg|gif)$/i,
                use: [
                    {
                        loader: 'url-loader',
                        options: {
                            limit: 8129,
                        }
                    }
                ]
            },
            // 处理字体资源
            {
                test: /\.(woff|woff2|eot|ttf|otf)$/,
                use: [
                    'file-loader'
                ]
            },

            // 处理.vue 资源
            {
                test: /\.vue$/,
                loader: 'vue-loader',
            },

            // 处理css
            // .css 文件，以及.vue中的<style>
            {
                test: /\.css$/,
                use: [
                    'vue-style-loader',
                    'css-loader',
                ]
            },

            // 处理less
            {
                test: /\.less$/,
                use: [
                    'vue-style-loader',
                    'css-loader',
                    'less-loader',
                ]
            }
        ]
    },
    plugins: [
        new VueLoaderPlugin(),
        new FriendlyErrorsWebpackPlugin(),
    ]
}
```

build/webpack.client.config.js

```js
const {merge} = require('webpack-merge');
const baseConfig = require('./webpack.base.config.js');
const VueSSRClientPlugin = require('vue-server-renderer/client-plugin');

module.exports = merge(baseConfig, {
    entry: {
        // 相对路径取决于执行打包命令的路径
        app: './src/entry-client.js' 
    },
    module: {
        rules: [
            // ES6 转 ES5，客户端单独处理，node端支持es6
            {
                test: /\.m?js$/,
                exclude: /(node_modules|bower_components)/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env'],
                        cacheDirectory: true,
                        plugins: ['@babel/plugin-transform-runtime']
                    }
                }
            }
        ]
    },


    // 将webpack运行时分离到一个引导chunk中
    // 以便可以在之后正确注入异步chunk
    optimization: {
        splitChunks: {
            name: "manifest",
            minChunks: Infinity,
        }
    },

    plugins: [
        // 在输出目录中生成 vue-ssr-client-manifest.json
        new VueSSRClientPlugin()
    ]
})
```

build/webpack.server.config.js

```js
const {merge} = require('webpack-merge');
const nodeExternals = require('webpack-node-externals');

const baseConfig = require('./webpack.base.config');

const VueSSRServerPlugin = require('vue-server-renderer/server-plugin');

module.exports = merge(baseConfig, {
    entry: './src/entry-server.js',
    // 允许webpack 以Node适用方式处理模块加载
    // 并且还会在编译Vue组件时，
    // 告知vue-loader ,输出面向服务器的代码（server-oriented code）
    target: 'node',
    output: {
        filename: 'server-bundle.js',
        // 配置server bundle 用Node风格(module.exports)导出模块（Node-style exports）
        libraryTarget: 'commonjs2'
    },
    // 不打包node_modules第三方包，保留require方式加载
    // 因为nodejs中一些node第三方包本身就是适用commonjs规范导入导出，在node环境不需要打包
    externals: [nodeExternals({
        // 白名单中资源蒸尝大包，第三方包中的css资源依然需要打包
        allowlist: [/\.css$/]
    })],

    plugins: [
        // 生成默认名称为vue-ssr-server-bundle.json的文件
        new VueSSRServerPlugin()
    ]
})
```

#### 配置打包命令

package.json

```json
{
    "scripts": {
        "build:client": "cross-env NODE_ENV=production webpack --config build/webpack.client.config.js",
        "build:server": "cross-env NODE_ENV=production webpack --config build/webpack.server.config.js",
        "build": "rimraf dist && npm run build:client && npm run build:server",
        "start": "cross-env NODE_ENV=production node server.js",
        "dev": "node server.js"
    }
}
```
##### 脚本测试

- 客户端打包
```
npm run build:client
```

项目中多出了`dist`目录

- 服务端打包

先删除dist目录

```
npm run build:server
```

服务端打包只生成了一个文件`vue-ssr-server-bundle.json`

- 双端打包

```
npm run build
```

#### 启动同构服务

修改server.js

```js
// 服务端打包生成的文件
const serverBundle = require('./dist/vue-ssr-server-bundle.json');
// 客户端打包生成的文件
const clientManifest = require('./dist/vue-ssr-client-manifest.json');
// render时vue实例实例的嵌套模板
const template = fs.readFileSync('./index-template.html', 'utf-8');
const renderer = require('vue-server-renderer').createBundleRenderer(serverBundle ,{
    template,
    clientManifest
});
```

客户端请求js资源，处理dist下文件可访问
```js
// 客户端请求js资源，处理dist下文件可访问
server.use('/dist', express.static('./dist'));
```

删除server.js中创建的vue实例，并修改路由`/`的内容

```js
server.get('/', (req, res) => {
    // renderer.renderToString(app, {title: 'vue ssr'}, (err, html) => {
    renderer.renderToString({title: 'vue ssr'}, (err, html) => {
        if (err) res.status(500).end('Internal Server Error')

        // 设置响应头避免乱码
        res.setHeader('Content-Type', 'text/html; charset=utf8')
        res.end(html);
    })
})
```

renderer.renderToString 不用再传入vue实例，他会自动从`vue-ssr-server-bundle.json`找到渲染内容

启动服务

```
npm run start
```

浏览器访问`localhost:3000`,可以看到输出了页面，并且v-model和click时间也生效了

{% asset_img 3.png %}

在同构应用中，服务端生成了静态html，客户端不会再次重新渲染，而是激活页面的交互效果，这是一种混合模式

> 在开发模式下，Vue 将推断客户端生成的虚拟 DOM 树 (virtual DOM tree)，是否与从服务器渲染的 DOM 结构 (DOM structure) 匹配。如果无法匹配，它将退出混合模式，丢弃现有的 DOM 并从头开始渲染。在生产模式下，此检测会被跳过，以避免性能损耗

[参考Vue SSR客户端激活](https://ssr.vuejs.org/zh/guide/hydration.html)

### 配置生产环境

安装chokidar,这个包封装了node中的fs.watch fs.watchFile,处理了其中的一些问题，用于监视文件的变化
```
npm install chokidar
```

安装webpack-dev-middleware, 用于在开发环境将打包结果保存在内存中，避免频繁的文件读写操作
```
npm install webpack-dev-middleware
```

安装[webpack-hot-middleware](https://github.com/webpack-contrib/webpack-hot-middleware)帮助我们自动在打包后刷新页面，热更新

```
npm install --save-dev webpack-hot-middleware
```

修改 server.js

```js
const Vue = require('vue');
const express = require('express');
const fs = require('fs');
const {createBundleRenderer} = require('vue-server-renderer');
const setupDevServer = require('./build/setup-dev-server');

const isProd = process.env.NODE_ENV === 'production';

// const renderer = require('vue-server-renderer').createRenderer({
//     template: fs.readFileSync('./index-template.html', 'utf-8')
// });

const server = express();

// 客户端请求js资源，处理dist下文件可访问
server.use('/dist', express.static('./dist'));

let renderer;
let onReady; // 用于保存开发模式renderer渲染器赋值状态
if (isProd) {
    // 服务端打包生成的文件
    const serverBundle = require('./dist/vue-ssr-server-bundle.json');
    // 客户端打包生成的文件
    const clientManifest = require('./dist/vue-ssr-client-manifest.json');
    // render时vue实例实例的嵌套模板
    const template = fs.readFileSync('./index-template.html', 'utf-8');
    renderer = createBundleRenderer(serverBundle, {
        template,
        clientManifest
    });
} else {
    // 开发模式 =》 监视打包构建 =》 重新生成renderer渲染器
    onReady = setupDevServer(server, (serverBundle, template, clientManifest) => {
        renderer = createBundleRenderer(serverBundle, {
            template,
            clientManifest
        });
    });
}

// const app = new Vue({
//     template: `<div id="app">
//         <h1>{{ message }}</h1>
//     </div>`,
//     data: {
//         message: 'vue ssr'
//     }
// })

const render = (req, res) => {
    // renderer.renderToString(app, {title: 'vue ssr'}, (err, html) => {
    renderer.renderToString({ title: 'vue ssr' }, (err, html) => {
        if (err) res.status(500).end('Internal Server Error')

        // 设置响应头避免乱码
        res.setHeader('Content-Type', 'text/html; charset=utf8')
        res.end(html);
    })
}

server.get('/', 
    isProd ? render : async (req, res) => {
        // 开发模式要在有了打包结果并且渲染器赋值完成才执行render
        console.log('等待 打包')
        await onReady;
        console.log('打包 done')
        render(req, res);
    }
)

server.listen(3000, () => {
    console.log('server running at 3000')
})
```

setup-dev-server.js
```js
const fs = require('fs');
const path = require('path');
const chokidar = require('chokidar');
const webpack = require('webpack');
const devMiddleware = require('webpack-dev-middleware');
const hotMiddleware = require('webpack-hot-middleware');

const resolve = file => path.resolve(__dirname, file);

module.exports = (server, callback) => {
    let ready; // 用于保存promise中的resolve函数
    const onReady = new Promise(r => ready = r);

    // 监视构建过程 -> 更新 Renderer
    let template;
    let serverBundle;
    let clientManifest;

    const update = () => {
        if (template && serverBundle && clientManifest) {
            ready();
            callback(serverBundle, template, clientManifest)
        }
    }

    // 监视构建 template -> 调用update -> 更新renderer渲染器
    const tempaltePath = path.resolve(__dirname, '../index-template.html');
    template = fs.readFileSync(tempaltePath, 'utf-8');
    chokidar.watch(tempaltePath).on('change', () => {
        // 当文件变化时
        template = fs.readFileSync(tempaltePath, 'utf-8');
        console.log('模板加载读取完成')
        update();
    })


    // 监视构建 serverBundle -> 调用update -> 更新renderer渲染器
    const serverConfig = require('./webpack.server.config');
    const serverCompiler = webpack(serverConfig);
    
    // webapck的编译器自带文件监视api,但是在开发环境使用会导致频繁的文件打包，文件读写，所以需要借助webpack-dev-middleware实现文件打包内容缓存在内存中
    // serverCompiler.watch({}, (err, status) => {
    //     if (err) throw err;
    //     if (status.hasErrors()) return;
    //     serverBundle = JSON.parse(
    //         fs.readFileSync(resolve('../dist/vue-ssr-server-bundle.json'), 'utf-8')
    //     );
    //     console.log(serverBundle);
    //     update();
    // })
    const serverDevMiddleware = devMiddleware(serverCompiler, {
        logLevel: 'silent' // 关闭日志输出，有friendlyErrorsWebpackPlugin 处理
    })
    // serverCompiler.hooks.done.tap添加打包后的回调函数，从而调用update函数，第一个参数'server'是我们定义的事件名字，没有固定意义
    serverCompiler.hooks.done.tap('server', () => {
        serverBundle = JSON.parse(
            // serverDevMiddleware.fileSystem 与 fs 类似，只不过是操作内存中的文件
            serverDevMiddleware.fileSystem.readFileSync(resolve('../dist/vue-ssr-server-bundle.json'), 'utf-8')
        );
        // console.log(serverBundle);
        console.log('服务端打包完成')
        update();
    })


    // 监视构建 clientManifest -> 调用update -> 更新renderer渲染器
    const clientConfig = require('./webpack.client.config');

    // 配置热更新
    clientConfig.plugins.push(new webpack.HotModuleReplacementPlugin());
    clientConfig.entry.app = [
        'webpack-hot-middleware/client?quiet=true&reload=true', // 和服务端交互处理热更新的客户端脚本， 不会刷新页面
        // ? 之后可附带参数，quiet 指热更新时控制台禁止输出热更新日志，（[HMR] bundle rebuilding[HMR] bundle rebuilt in 33ms这种）
        // reload 代表在热更新卡住时刷新界面
        // 更多使用参照 https://github.com/webpack-contrib/webpack-hot-middleware
        clientConfig.entry.app, // webpack中配置的原本的打包入口
    ];
    clientConfig.output.filename = '[name].js'; // 热更新模式下，确保文件名一致，如果在配置文件中配置了[chunkhash]等导致输出的文件名不一致，热更新编译时会报错Cannot use [chunkhash] or [contenthash] for chunk in '[name].[chunkhash].js' (use [hash] instead)


    const clientCompiler = webpack(clientConfig);
    const clientDevMiddleware = devMiddleware(clientCompiler, {
        publicPath: clientConfig.output.publicPath,
        logLevel: 'silent' // 关闭日志输出，有friendlyErrorsWebpackPlugin 处理
    })
    // clientCompiler.hooks.done.tap添加打包后的回调函数，从而调用update函数，第一个参数'client'是我们定义的事件名字，没有固定意义
    clientCompiler.hooks.done.tap('client', () => {
        clientManifest = JSON.parse(
            // clientDevMiddleware.fileSystem 与 fs 类似，只不过是操作内存中的文件
            clientDevMiddleware.fileSystem.readFileSync(resolve('../dist/vue-ssr-client-manifest.json'), 'utf-8')
        );
        // console.log(clientManifest);
        console.log('客户端打包完成')
        update();
    })

    // 配置热更新
    server.use(hotMiddleware(clientCompiler, {
        log: false, // 关闭本身的日志输出
    }));

    // 在server.js我们使用user static 处理dist下的文件为静态资源,但是开发环境中打包文件在内存中，没有实际的静态资源，所以回到值客户端不能激活
    // clientDevMiddleware 中间件提供了对内存中数据的访问，当客户端访问 /dist/下某个js文件时，会尝试返回内存中的文件数据
    server.use(clientDevMiddleware)

    return onReady;
}
```

到此为止，执行`npm run dev`,会帮我们启动一个开发服务，包含了客户端服务端同构、热更新的功能


### 配置路由

安装`vue-router`

```
npm i vue-router --save
```

创建三个路由相关的页面文件

src/pages/404.vue、src/pages/About.vue、src/pages/Home.vue
```js
// src/pages/404.vue
<template>
    <div class='page404'>404 Not Page</div>
</template>
<script>
export default {
    name: 'page404',
}
</script>
// src/pages/About.vue
<template>
    <div class='about'>关于</div>
</template>
<script>
export default {
    name: 'about',
}
</script>
// src/pages/Home.vue
<template>
    <div class='home'>首页</div>
</template>
<script>
export default {
    name: 'home',
}
</script>
```


server.js 稍作修改

```js

// render函数renderToString 中第一个参数填加请求路由req.url
const render = async (req, res) => {
    try {
        // renderer.renderToString(app, {title: 'vue ssr'}, (err, html) => {
        // renderToString 中第一个参数的url会在entry-server中通过context.url使用
        const html = await renderer.renderToString({ title: 'vue ssr', url: req.url })
        // 设置响应头避免乱码
        res.setHeader('Content-Type', 'text/html; charset=utf8')
        res.end(html);
    } catch(err) {
        res.status(500).end('Internal Server Error')
    }
}

// 服务端渲染不用对每一个路径都匹配路由，只需要通过*匹配所有路由，vuerouter中会对未匹配的路由返回404页面
server.get('*', 
    isProd ? render : async (req, res) => {
        // 开发模式要在有了打包结果并且渲染器赋值完成才执行render
        console.log('等待 打包')
        await onReady;
        console.log('打包 done')
        render(req, res);
    }
)
```

创建router/index.js
```js
import Vue from 'vue';
import VueRouter from 'vue-router';
import Home from '@/pages/Home';
import Page404 from '@/pages/404'; 

Vue.use(VueRouter);

// 类似于 createApp，我们也需要给每个请求一个新的 router 实例，所以文件导出一个 createRouter 函数
// 防止数据污染
export const createRouter = () => {
    const router = new VueRouter({
        mode: 'history', // 服务端不支持hash模式
        routes: [
            {
                path: '/',
                name: 'home',
                component: Home
            },
            {
                path: '/about',
                name: 'about',
                component: () => import('@/page/About')
            },
            {
                path: '*', // 上面的路由未匹配到时，可以通过*匹配到404页面
                name: 'page404',
                component: Page404
            }
        ]
    })
    return router;
}
```

重写src/entry-server.js

```js
import {createApp} from './app';
export default async context => {
    const {app, router} = createApp();

    router.push(context.url);

    await new Promise(router.onReady.bind(router));

    return app;
}
```
重写src/entry-client.js

```js
import {createApp} from './app';

const {app, router} = createApp();

router.onReady(() => {
    app.$mount('#app');
})
```

修改src/app.js,添加vue实例的路由
```js
import Vue from 'vue';
import App from './App.vue';
import {createRouter} from './router';

export function createApp() {
    const router = createRouter();
    const app = new Vue({
        router,
        render: h => h(App)
    })
    return {app, router}
}
```

修改src/App.vue,添加路由导航和出口

```js
<div id='app'>
    <ul>
        <li><router-link to="/">home</router-link></li>
        <li><router-link to="/about">about</router-link></li>
    </ul>
    <!-- 路由出口 -->
    <router-view/>
</div>
```

至此，`npm run dev`启动服务已经可以看到页面上的路由生效了，并且，首次加载之后，页面的跳转是通过客户端懒加载来实现的，这样我们的应用既可以实现更好的seo,又能给用户提供单页面应用极致的用户体验

{% asset_img router.png %}

更多参照[Vue SSR 路由和代码分割](https://ssr.vuejs.org/zh/guide/routing.html#%E4%BD%BF%E7%94%A8-vue-router-%E7%9A%84%E8%B7%AF%E7%94%B1)


### 配置不同界面的Head标签

之前我们通过index-template模板给所有页面配置了统一的模板，如果我们需要针对摸个路由配置不同的页面title，或者meta标签等，可以借助vue-meta

安装vue-meta
```
npm install vue-meta
```

在同一入口src/app.js中混入vue-meta

```js
import VueMeta from 'vue-meta';
Vue.use(VueMeta);
Vue.mixin({
    metaInfo: {
        titleTemplate: '%s - Vue SSR', // title 的模板，%s 会替换为标题
    }
})

```

修改src/entry-server.js

```js
export default async context => {
    const {app, router} = createApp();

    // 拿到混入的meta内容
    const meta = app.$meta();

    router.push(context.url);

    // 注入到context上下文中，这样在页面模板中就可以取到meta的内容了
    context.meta = meta;

    await new Promise(router.onReady.bind(router));

    return app;
}
```

为Home.vue、About.vue添加metaInfo属性

```js
// src/pages/Home.vue
export default {
    name: 'home',
    metaInfo: {

        title: '首页'
    }
}

// src/pages/About.vue
export default {
    name: 'about',
    metaInfo: {
        title: '关于'
    }
}
```

在模板中使用页面的metaInfo

index-template.html
```html
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    {{{ meta.inject().title.text() }}}
    {{{ meta.inject().meta.text() }}}
</head>
```

开启开发服务,访问`localhost:3000`

{% asset_img meta.png %}

更多`vue-meta`使用参照[vue-meta使用](https://vue-meta.nuxtjs.org/api/)


### 数据预取和状态管理

> 在服务器端渲染(SSR)期间，我们本质上是在渲染我们应用程序的"快照"，所以如果应用程序依赖于一些异步数据，那么在开始渲染过程之前，需要先预取和解析好这些数据。

>另一个需要关注的问题是在客户端，在挂载 (mount) 到客户端应用程序之前，需要获取到与服务器端应用程序完全相同的数据 - 否则，客户端应用程序会因为使用与服务器端应用程序不同的状态，然后导致混合失败。

> 为了解决这个问题，获取的数据需要位于视图组件之外，即放置在专门的数据预取存储容器(data store)或"状态容器(state container)）"中。首先，在服务器端，我们可以在渲染之前预取数据，并将数据填充到 store 中。此外，我们将在 HTML 中序列化(serialize)和内联预置(inline)状态。这样，在挂载(mount)到客户端应用程序之前，可以直接从 store 获取到内联预置(inline)状态。

这里实现一个文章列表的服务端预取与状态管理

安装 vuex, axios

```
npm install vuex axios --save
```

创建store
src/store/index.js

```js
import Vue from 'vue';
import Vuex from 'vuex';
import axios from 'axios';

Vue.use(Vuex);

export const createStore = () => {
    return new Vuex.Store({
        state: () => ({
            posts: []
        }),

        mutations: {
            setPosts (state, data) {
                state.posts = data;
            }
        },

        actions: {
            // 在服务端渲染期间务必让action返回一个Promise，服务端渲染时会等待数据返回
            async getPosts(context) {
                const {commit} = context;
                const {data} = await axios.get('https://cnodejs.org/api/v1/topics');
                commit('setPosts', data.data)
            }
        }
    })
}
```

给vue实例注册store
scr/app.js

```js
import {createStore} from './store';

export function createApp() {
    const router = createRouter();
    const store = createStore(); // 创建store
    const app = new Vue({
        router,
        store, // 注册store
        render: h => h(App)
    })
    return {app, router, store}
}

```

创建文章页面 并注册路由

src/pages/Posts.vue
```js
<template>
    <div class='posts'>
        <h1>posts list</h1>
        <ul>
            <li v-for="post in posts" :key="post.id">{{ post.title }}</li>
        </ul>
    </div>
</template>
<script>
import {mapState, mapActions} from 'vuex';

export default {
    name: 'Posts',
    metaInfo: {
        title: '文章'
    },
    data() {
        return {};
    },
    computed: {
        ...mapState(['posts']),
    },
    methods: {
        ...mapActions(['getPosts']),
    },
    // vue ssr 为服务端提供的特殊的生命周期函数
    serverPrefetch() {
        // 发起action 返回Promise
        return this.getPosts();
    }
    
}
</script>
```

这个时候，当我们访问posts路由的页面时，会看到页面渲染出了文章标题列表但是一闪而过，这是因为我们的store中的数据没有同步，服务端和客户端store同步的思路就是，服务端在模板context中保存数据，并将数据通过脚本的方式注入到客户端页面的`window.__INITIAL_STATE__`中，客户端会拿到这个数据并填充到客户端的store中

修改entry-server.js
```js
export default async context => {
    const {app, router, store} = createApp();

    const meta = app.$meta();

    router.push(context.url);

    context.meta = meta;

    await new Promise(router.onReady.bind(router));

    context.rendered = () => {
        // renderer 会把 content.state中的数据内联到页面模板中
        // 最终发送给客户端的页面中会包含一段脚本：window.__INITIAL_STATE__ = context.state;
        // 客户端就要把页面中的window.__INITIAL_STATE__ 取出来填充到客户端store中去
        context.state = store.state;
    }

    return app;
}
```

此时打开浏览器`/posts`页面，控制台打印查看插入的script数据标签

{% asset_img initialstate.png %}

接下来让客户端接管服务端的store

src/entry-client.js

```js
const {app, router, store} = createApp();

if (window.__INITIAL_STATE__) {
    store.replaceState(window.__INITIAL_STATE__);
}
```

这样客户端页面就会接管服务端的数据了

{% asset_img store.png %}

