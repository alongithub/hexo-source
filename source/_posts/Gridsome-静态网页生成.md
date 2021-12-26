---
title: 静态网页生成[gridsome]
date: 2020-09-29 15:21:00
tags: [Gridsome]
toc: true
description: 静态站点生成是服务端渲染提前获取数据并预渲染对应的界面，用户拿到服务端预渲染页面后，接下来的交互完全基于客户端的SPA应用，从而使用户体验达到极致
---

## 静态网站

### 什么是静态网站

- 静态网站是使用一系列模板数据及配置生成静态html文件及相关资源的工具
- 这个功能也叫作预渲染
- 生成的网站不需要类似PHP这样的服务器
- 只需要放在web server或者cdn上就可以



### 静态网站的优点

- 不需要专业服务器，服务器成本低，只需要能托管静态文件的空间
- 响应快速，不经过后台处理，只传输内容
- 安全性更高

### 常见静态网站生成器（JAMStack Javascript Api Markup stack）

- jekyll(ruby)
- hexo(node)
- hugo(golang)
- gatsby(node/react)
- gridsome(node/vue)
- next,nuxt也能用于生成静态网站，不过更多的被认为是ssr框架

###  不适用场景

- 不适合大量路由的应用
- 不适合大量动态交互的应用，比如后台管理

## Gridsome

- GitHub 仓库：https://github.com/gridsome/gridsome
- 官网：https://gridsome.org/

### 起步

```
npm install -g @gridsome/cli
```

直接使用`gridsome create 项目名`创建项目会失败，因为geidsom依赖了[sharp](https://github.com/lovell/sharp)（用于处理图片）第三方模块，包含c++文件，另外sharp依赖libvips，这个模块很大容易下载失败。所以需要处理这个问题

关于解决libvips的网络问题可以参照[这里](https://sharp.pixelplumbing.com/install#chinese-mirror),libvips官网提供了国内的镜像

这里我们使用两个命令配置下镜像源

```
npm config set sharp_binary_host "https://npm.taobao.org/mirrors/sharp"

npm config set sharp_libvips_binary_host "https://npm.taobao.org/mirrors/sharp-libvips"
```

关于编译c++扩展包可以借助`node-gyp`模块

```
npm install node-gyp -g
```

安装了node-gyp之后不能直接使用，windows环境下需要安装python，另外需要安装windows-build-tools
安装时需要使用管理员命令行才能成功
```
npm install --global --production windows-build-tools
```

创建项目

```
gridsome create gridsome-site
```

启动项目
```
npm run develop
```

此时会在默认8080端口访问gridsome创建的默认应用

### 预渲染

在创建项目的src/pages中可以看到默认生成的两个路由组件，执行打包`npm run build`查看生成的路由静态页面

可以看到项目中生成了dist目录，保存了所有的静态页面，dist目录下的项目可以直接放在静态web服务上访问

这样生成的网站首次访问时属于服务端渲染（这个过程保存结果在静态资源里，称为预渲染）。到达客户端之后，用户拿到的是一个SPA的应用。

### 项目配置

gridsome.config.js 是项目的配置信息，比如标题`siteName`、路径前缀`pathPrefix`等，可以参照[gridsome配置](https://gridsome.org/docs/config/)

### pages路由规则

pages目录下保存着项目的路由文件，默认会根据文件系统自动生成路由
#### 文件系统路由生成的规则


- src/pages/Index.vue -> /
- src/pages/AboutUs.vue -> /about-us/
- src/pages/about/Vision.vue -> /about/vision/
- src/pages/blog/Index.vue -> /blog/

#### 基于文件系统的动态路由

- src/pages/user/[id].vue -> /user/:id.
- src/pages/user/[id]/settings.vue -> /user/:id/settings.

在组建中通过`$route.params.id`获取动态路由的参数

Ex: 
```js
<template>
    <div class='user-page'>
        {{ $route.params.id }}
    </div>
</template>
```

#### api编程方式生成路由

有时候需要通过api编程方式创建组件

在gridsome.server.js中
```js
api.createPages(({ createPage }) => {
    createPage({
      path: '/my-page',
      component: './src/templates/MyPage.vue'
    })
})
```

在src/templates中创建MyPage.vue

```js
<template>
    <div class='my-page'>My Page</div>
</template>
```

修改了`gridsome.server.js`需要使用`npm run develop` 重新启动服务

启动成功后访问/my-page查看刚才创建的页面

#### api编程方式动态路由

```js
api.createPages(({ createPage }) => {
    createPage({
      path: '/article/:id(\\d+)',  // () 中是使用正则表达式对id做的限定，这里代表id必须为数字,如果不匹配会404
      component: './src/templates/Article.vue'
    })
})
```
./src/templates/Article.vue
```js
<template>
    <div class='article'>
        {{$route.params.id}}
    </div>
</template>
```

同样修改gridsome.server.js后需要重启

### 页面head内容

使用metaInfo配置页面head中的内容，包括title，meta等
```js
export default {
  metaInfo: {
    title: 'About us'
  }
}
```

### 404页面

自定义404页面只需要在src/pages下创建404.vue即可

### 集合

集合用于承载接口的数据，结合模板预渲染成一个一个的页面，更多参展[集合](https://gridsome.org/docs/collections/)

#### 数据预取，保存到集合中
安装`axios`

```
npm i axios 
```

gridsome.server.js

```js
api.loadSource(async (actions) => {
    // Use the Data Store API here: https://gridsome.org/docs/data-store-api/
    
    const collection = actions.addCollection('Post') // 集合名称

    const { data } = await axios.get('https://jsonplaceholder.typicode.com/posts')

    for (const item of data) {
        collection.addNode({
            id: item.id,
            title: item.title,
            content: item.body
        })
    }
    
})
```

这样，集合就预取保存了接口的数据，接线来得问题是如何在页面中获取这个数据

集合会将数据保存到GraphQL中，上述代码中通过`actions.addCollection('Post')`我们添加了集合并命名为`Post`，此时在GraphQL中

- `post` 获取单条数据 通过 `id`
- `allPost` 获取数据列表

我们可以通过访问启动项目是给出的页面查看GraphQL内容

{% asset_img 1.png %}

访问 `http://localhost:8080/___explore`

{% asset_img 2.png %}

点击docs可以查看所有内容
尝试查询一条数据，

```
query{
  post (id: 1) {
    id
    title
  }
}
```

{% asset_img 3.png %}

关于GraphQL内容参考[GraphQL官网](https://graphql.cn/)

#### 页面获取GraphQL中的数据

[Querying data页面获取数据参考地址](https://gridsome.org/docs/querying-data/)

> You can query data from the GraphQL data layer into any Page, Template or Component. Queries are added with a <page-query> or <static-query> block in Vue Components.
> - Use <page-query> in Pages & Templates.
> - Use <static-query> in Components.

- 在templates或Pages中的组件通过`<page-query>`
- 在component中使用`<static-query>`

接下来尝试使用数据并预渲染界面

创建src/pages/Posts.vue

```js
<template>
    <Layout>
        <div class='posts'>
            <h1>Posts</h1>
            <ul>
                <li v-for="edge in $page.posts.edges" :key="edge.node.id">
                    <g-link to="/">{{edge.node.title}}</g-link>
                </li>
            </ul>
        </div>
    </Layout>
</template>


<page-query>
query {
  posts: allPost {
    edges {
      node {
        id
        title
      }
    }
  }
}
</page-query>

```

此时可以访问到静态化的posts页面

{% asset_img 4.png %}

#### 静态或文章详情页面

- 配置gridsome.config.js,指定模板和路由规则

```js
module.exports = {
  ...
  templates: {
    // Post 是集合名称
    Post: [{
      path: '/posts/:id', // 这里动态路由的id就是我们数据中心的唯一字段，不能随便写
      component: './src/templates/Post.vue',
    }]
  }
}
```

- 修改文章列表的链接

之前在posts.vue中文章链接修改

```js
// <g-link to="/">{{edge.node.title}}</g-link>
// edge.node.path是我们配置gridsome.config.js之后回为列表数据添加path属性
<g-link :to="edge.node.path">{{edge.node.title}}</g-link>
```

- 创建模板sre/templates/Page.vue

```js
<template>
    <Layout>
        <div class='post'>
            <h1>{{ $page.post.title }}</h1>
            <div>
                {{ $page.post.content }}
            </div>
            
        </div>
    </Layout>
    
</template>

<page-query>
query ($id: ID!){
  post (id: $id) {
    id
    title
    content
  }
}
</page-query>

<script>
export default {
    name: 'PostPage',
    // 这种写法无法访问 $page中的数据
    // metaInfo: {
    //     title: $page.post.title
    // }
    metaInfo() {
        return {
            title: this.$page.post.title 
        }
    }
}
</script>
```

`query ($id: ID!)` 中传入了变量`$id`, 变量类型是`ID`(这个类型可以通过docs里查看),`!`代表不能为空

接下来执行打包 

```
npm run build
```

通过打包后的dist目录可以看到项目中每篇文章都做了静态化处理

{% asset_img 5.png %}


#### 处理分页

处理分页很简单，gridsome提供了Pager组件，引入并提供 需要的属性即可
在列表页查询列表时需要传递page相关的参数，每页条数，以及当前页

src/page/Posts.vue

```js
<template>
    <Layout>
        <div class='posts'>
            <h1>Posts</h1>
            <ul>
                <li v-for="edge in $page.posts.edges" :key="edge.node.id">
                    <!-- edge.node.path是自动生成的属性，可以跳转到详情页 -->
                    <g-link :to="edge.node.path">{{edge.node.title}}</g-link>
                </li>
            </ul>
            <!-- 使用pager组件 -->
            <pager :info="$page.posts.pageInfo"/>
        </div>
    </Layout>
</template>
<page-query>
# 接收url上的参数，设置每页条数和当前页码
query ($page: Int){
  posts: allPost (perPage: 10, page: $page) @paginate {
    pageInfo {
      totalPages
      currentPage
    }
    edges {
      node {
        id
        title
      }
    }
  }
}
</page-query>

<script>
// 引入Pager
import {Pager} from 'gridsome';

export default {
    // 注册
    components: {Pager},
    ...
}
```

打开网页查看，点击第二页，可以看到路由变化为`localhost:8080/posts/2/`

{% asset_img 6.png %}

至于paper的样式自定义即可

