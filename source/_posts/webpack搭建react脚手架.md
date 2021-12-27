---
title: webpack搭建react脚手架
date: 2020-09-23 16:15:13
tags: [
    webpack,
    react,
	ts,
	eslint
]
description: webpack继承react项目脚手架，集成ts，eslint规范制定
---

### 基础配置

#### 1. 安装webpack

初始化项目，初始化package.json

```
npm init -y
```

安装webpack包，webpack

```
npm install webpack webpack-cli -D
```

创建文件  src/index.js

```js
console.log('along');
```

创建文件  webpack.config.js

```js

const path = require('path');

module.exports = {
    mode: 'development',
    entry: './src/index.js',
    // 如果配置多页应用，需要这样配置
    // entry: {
    //     index: './src/index.js',
    //     home: './src/home.js'
    // },
    output: {
        // filename: '[name].[hash:8].js',
        // 如果配置多页应用必须这样配置
        filename: 'index.[hash:8].js',
        // 打包文件路径 该路径为绝对路径
        path: path.resolve(__dirname, 'build'),
        // 静态资源引用会统一加一个路径，比如加上cdn地址
        // publicPath: 'http://www.baidu.com',
        publicPath: ''
    },
    // 开发环境中使用devtool做源码映射
    // source-map  大而全 单独生成源码map文件, 标识凑无的列和行
    // eval-source-map 同上，但是产生单独的文件，将映射打包到打包后的js文件里
    // cheap-module-source-map  单独文件，不会映射列
    // cheap-module-eval-source-map 不产生文件，不映射列
    devtool: 'cheap-module-source-map',
    watch: true, // 监控代码变化实时打包,文件变化后自动打包
    watchOptions: {
        // 忽略监视node_modules中的文件
        ignored: /node_modules/,
        // aggregateTimeout: 500,  // 文件变化时防抖，500ms内没有再次变化再执行打包
    },
}
```



执行打包命令

```
npx webpack
```

可以看到 /build/index.js 打包后的结果,为了以后执行命令方便将命令写入package.json中

```json
{  
    ...  
    "scripts": {    
        "build": "webpack",  
    }  
    ...
}
```

之后打包执行命令

```
npm run build
```

#### 2. webpack-dev-server

webpack-dev-server 内部通过express实现静态资源服务，不会生成打包文件，而是在内存中打包。

```
npm install webpack-dev-server -D
```

package.js添加命令

```json
{  
	...  
	"scripts": {    
		...    
		"dev": "webpack-dev-server",  
	}  
	...
}
```

启动服务

```
npm run dev
```

打开服务地址可以看到自动生成了一个项目的文件服务

修改webpack-dev-server的配置，在webpack.config.js中添加

```js
{
	...
	devServer: {
        port: 8006,
        progress: true, // 打包进度
        // 静态服务文件夹,如果存在该文件夹，静态服务则会以此文件夹作为根路径
        contentBase: './build',
        open: true, // 打包完成后打开浏览器
        // 将错误信息输出到页面上显示
        overlay: {
            warnings: true,
            errors: true
        },
        // 跨域代理
        proxy: {
            // 将/api 开头的接口代理到目标地址，如果是所有请求可以填/
            '/api': {
                target: 'http://localhost:8089',
                // pathRewrite: {
                //     '/api': '',
                // }
            }
        }
    },
    ...
}
```

此时执行命令

```
npm run dev
```

如果contentBase中指定的文件夹存在，则会看到指定文件夹的文件服务，如果不存在，会看到  Cannot GET /

#### 3. 区分环境

实际打包时需要开发环境和生产环境，我们需要分别来配置两种环境

借助  webpack-merge  合并配置文件

借助  yargs-parser  获取脚本参数

```
npm install webpack-merge yargs-parser -D
```

创建两个文件,将webpack.config.js中的配置拆分到生产和开发环境的配置文件中

config/webpack.development.js

```js
module.exports = {
    devtool: 'cheap-module-source-map',
    devServer: {
        port: 8006,
        progress: true, // 打包进度
        // 静态服务文件夹,如果存在该文件夹，静态服务则会以此文件夹作为根路径
        contentBase: './build',
        open: true, // 打包完成后打开浏览器
        // 将错误信息输出到页面上显示
        overlay: {
            warnings: true,
            errors: true
        },
        // 跨域代理
        proxy: {
            // 将/api 开头的接口代理到目标地址，如果是所有请求可以填/
            '/api': {
                target: 'http://localhost:8089',
                // pathRewrite: {
                //     '/api': '',
                // }
            }
        }
    },
}
```

config/webpack.production.js

```js
module.exports = {
    watch: true, // 监控代码变化实时打包,文件变化后自动打包
    watchOptions: {
        // 忽略监视node_modules中的文件
        ignored: /node_modules/,
        // aggregateTimeout: 500,  // 文件变化时防抖，500ms内没有再次变化再执行打包
    },
}
```

webpack.config.js

```js

const path = require('path');
const argv = require('yargs-parser')(process.argv.slice(2)); // 获取参数
const {merge} = require('webpack-merge');
const _mode = argv.mode || 'development'; // 获取当前模式
const _isEnvDevelopment = _mode === 'development';
const _isEnvProduction = _mode === 'production';
const _mergeConfig = require(`./config/webpack.${_mode}.js`); // 引入对应的文件
const baseConfig = {
    mode: _mode ,
    entry: './src/index.js',
    output: {
        filename: 'index.[hash:8].js',
        // 打包文件路径 该路径为绝对路径
        path: path.resolve(__dirname, 'build'),
        // 静态资源引用会统一加一个路径，比如加上cdn地址
        // publicPath: 'http://www.baidu.com',
        publicPath: _isEnvDevelopment ? '/' : '/build/'
    },
}
module.exports = merge(_mergeConfig, baseConfig);
```

修改package.json

```json
 {
 	...
 	"scripts": {
        "dev": "webpack-dev-server --mode development",
        "build": "webpack --mode production"
      },
 	...
 }
```

#### 4.html-webpack-plugin、clean-webpack-plugin、copy-webpack-plugin

借助 html-webpack-plugin 可以自动将打包后的js文件插入到模板html中，clean-webpack-plugin   可以每次打包前删除之前的打包目录, copy-webpack-plugin 可以指定文件每次打包时复制一份到打包目录下。

```
npm install html-webpack-plugin clean-webpack-plugin copy-webpack-plugin -D
```

webpack.config.js 引入 html-webpack-plugin

```
const HtmlWebpackPlugin = require('html-webpack-plugin');
```

webpack.config.js 中插入配置项

```json
{    
    ...        
	plugins: [
        // 如果是多页应用，应当new多个HtmlWebpackPlugin实例，并分别指定template、filename、chunks
        new HtmlWebpackPlugin({
            // 模板html路径
            template: './public/index.html',
            filename: 'index.html', // 打包后的文件名称
            minify: _isEnvProduction ? { // 压缩html production 环境配置此项
                removeAttributeQuotes: true, // 去除双引号 
                collapseWhitespace: true, // 折叠空行
                hash: true, // 插入js在？后加一个hash戳，防止缓存，当然也可以每次生成js时在文件名引入hash
            } : {}
            //chunks: ['home'], // 指定html模板要引入的js文件，名字与入口中的文件名对应，一般在打包多页应用时会用到，默认没有该配置会引入所有入口文件
        }),
    ],
    ...
}
```

webpack.production.js  中引入  clean-webpack-plugin 和 copy-webpack-plugin

```js
const {CleanWebpackPlugin} = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
module.exports = {
    ...
    plugins: [
        new CleanWebpackPlugin(),
        // 每次打包将项目下的readme.txt文件复制到打包文件下
        new CopyWebpackPlugin([{
            from: 'readme.txt', // 把项目中的readme.txt每次打包复制到build文件下
            to: ''
        }]),
    ]
    ...
}
```

创建html模板文件  public/index.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>along-cli</title>
</head>
<body>
    <div id="root">no javascript</div>
</body>
</html>
```

创建readme.txt

```
这个文件用于测试，copy-webpack-plugin
```

修改  src/index.js  内容

```js
document.getElementById('root').innerHTML = "along";
```

执行命令

```
npm run dev
```

可以看到弹出的界面中along字样

#### 5.样式处理