---
title: webpack
date: 2020-08-27 15:57:56
tags: webpack
toc: true
description: webpack 的基本配置和使用
---

## WEBPACK

### 模块化问题

- 兼容问题：  ES6 => ES5
- 模块文件多，网络请求频繁：  打包多个模块到一起
- 所有的前端资源都需要模块化：  打包不同类型文件

### 打包工具

- webpack 
    - 模块打包 Module bundler
    - 模块加载 loader
    - 代码拆分 Code Splitting
    - 资源模块 Asset Module

#### 安装

```
yarn add webpack webpack-cli --dev
```

#### 配置文件

webpack 4 支持零配置打包，可以通过index.html中引入的script找到所有相关文件并打包

也可以通过修改配置自定义

创建 webpack.config.js 文件

```
const path = require('path');

module.exports = {
    mode: 'none',
    entry: './src/index.js', // 相对路径不能省略 ./
    output: {
        filename: 'bundle.js',
        path: path.join(__dirname, 'output'), // 指定输出文件路径，必须是一个绝对路径
    }
}
```

#### webpack 原理

#### webpack 资源加载 Loader

webpack 加载资源的方式

- 遵循ES Modules 标准的import声明
- 遵循CommonJS标准的require函数
- 遵循AMD标准的define函数和require函数

- 样式代码中的@import指令和url函数
- HTML代码中图片标签的src属性

loader 加载器类型大致分为三类
- 编译转换类
- 文件操作类型  比如文件拷贝
- 代码检查类   eslint


每一种资源都需要特定的加载器来加载。

通过webpack 配置文件中的 module.rules 来配置


```
module: {
    rules: [
        {test: /.css$/, use: 'css-loader'}
    ]
}
```

##### 处理css 

`['style-loader','css-loader']`

##### 文件资源加载, 图片字体

`['file-loader']` file-loader 会在打包时将目标复制到输出文件夹，并将输出模块的路径作为返回值返回

`['url-loader']` url-loader 采用Data urls 协议，（url直接表示文件内容），将文件转换成base64 直接写到代码中

最好的方式是较小的资源使用url-loader 转换，较大的文件使用file-loader 拷贝

```
 {
    test: /\.(png|jpg|jpeg|gif)$/,
    use: {
        loader: 'url-loader',
        options: {
            esModule: false,
            limit: 10 * 1024,
            // outputPath: 'images/',
            // name: '[name].[hash:5].[ext]',
            // publicPath: '', // 可以写cdn地址
        }
    }
}
```

##### 编译 ES6

`yarn add babel-loader @babel/core @babel/preset-env --dev`

配置 规则

```
rules: [
    {
        test: /\.js$/,
        use: {
            loader: 'babel-loader',
            options: {
                presets: ['@babel/preset-env']
            }
        }',
    }
]
```

#### 自定义 loader

实现一个md转html的loader

```javascript
const marked = require('marked');

// 参数 source 就是读取到的文件文本
module.exports = source => {
    const html = marked(source);

    // loader管道的最后一个loader必须要分会一段js脚本文本
    return `module.exports = ${JSON.stringify(html)}`
}

```


#### 插件机制

通过配置webpack的plugins数组配置插件

##### 自动清除输出目录

clean-webpack-plugin

```
const {CleanWebpackPlugin} = require('clean-webpack-plugin');

module.exports = {
    plugins: [
        new CleanWebpackPlugin(),
    ]
}
```

##### 自动生成html html-webpack-plugin

```
const HtmlWebpakPlugin = require('html-webpack-plugin')

module.exports = {
    plugins: [
        new HtmlWebpakPlugin({
            title: 'vue-app', 
            url: '/', // 自定义参数
            template: './public/index.html', 
            filename: 'index.html',
        }),
    ]
}

```

##### 复制文件  copy-webpack-plugin

```
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
    plugins: [
        new CopyWebpackPlugin({
            patterns: [
                {
                    from: 'public/favicon.ico',
                    to: ''
                },
            ],
        }),
    ]
}
```

#### 插件实现原理

通过钩子机制实现

插件必须是一个函数或者包含apply 方法的对象

一般都会定义一个类型，通过实例来实现



``` javascript

// 实现一个去处打包后文件注释的方法
class MyPlugin {
    // apply 方法会在webpack启动时被调用
    apply (compiler){
        console.log('webpack 启动 ');


        // emit 钩子在webpack准备往目标目录输出文件时执行,
        // 第一个参数是插件名称， 第二个参数函数的参数是打包过程的上下文
        compiler.hooks.emit.tap('MyPlugin', compilation => {
            // 获取即将写入的资源信息
            const assets = compilation.assets
            for (let key in assets) {
                // key 就是 资源文件名称

                if (key.endsWith('.js')){
                    // 这里只处理js文件
                    // source方法返回文件文本内容
                    const value = compilation.assets[key].source();
                    // 通过正则替换掉注释信息
                    const withoutComments = contents.replace(/\/\*\*+\*\//g, '');
                    compilation.assets[key] = {
                        source: () => withoutComments,
                        size: () => withoutComments.length, // 返回内容方法，必须
                    }
                }

                
            } 
        })
    }
}
```

#### webpack-dev-server

```
devServer: {
    historyApiFallback: true, //historyApiFallback设置为true那么所有的路径都执行index.html。
    overlay: true, // 将错误显示在html之上
    port: 8080,
    progress: true,
    contentBase: './dist',
    open: false,
    hot: true,
    disableHostCheck: true,  // 没有这项ie 会重复报错，
    historyApiFallback: true,
},
```

#### 热更新


#### treeShaking

去除未引用代码

treeShaking会在生产环境下自动开启，其他环境下可以通过配置usedExports和minimize来手动开启treeShaking

```
optimization: {
    usedExports: true,
    minimize: true,
}
```



