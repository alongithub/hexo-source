---
title: 脚手架工具
date: 2020-08-27 15:49:53
tags: 脚手架
toc: true
---

## 脚手架工具

特定项目脚手架，比如
- creat-react-app
- vue-cli

通用脚手架工具
- Yeoman
- plop

### Yeoman 通用脚手架

```
yarn global add yo
yarn global add generator-node
```
我再安装时出现了yo不是内部命令的问题
将yarn添加到path 重新执行上述命令，可以通过
```
yarn global bin
```
查看yarn全局安装路径

创建生成器
```
yo node
```

```
? The name above already exists on npm, choose another? Yes
? Module Name along-yo  // 生成器名称
? Description test yeoman // 描述
? Project homepage url https://github.com/alongithub/along-yo // 访问地址
? Author's Name along // 作者
? Author's Email 1792108796@qq.com // 邮箱
? Author's Homepage https://github.com/alongithub // 作者主页
? Package keywords (comma to split) node,test,yeoman // 关键字
? Send coverage reports to coveralls No // 覆盖率
? Enter Node versions (comma separated)
```

已进入到相应目录使用 yo 指令生成项目，可是却在其他文件夹下生成了项目。
```
Just found a `.yo-rc.json` in a parent directory.
Setting the project root at: /Users/Pacos
```

找到 .yo-rc.json 文件，删除既可以解决。

### Yeoman Sub Generator

如果只需要生成项目结构的一部分，比如增加eslint，或者单独增加一个readme，可以使用yeoman 提供的sub generator 功能

比如使用 generator-node 提供的cli子集生成cli应用
```
yo node:cli
```

之后yo会重写package.json, 自动写入 bin, dependencies 信息,并创建cli基础结构
```json
"bin": "lib/cli.js",
  "dependencies": {
    "meow": "^3.7.0"
  }
```

```javascript
// 自动创建的cli   lib/cli.js
#!/usr/bin/env node
'use strict';
const meow = require('meow');
const yeomandemo = require('./');

const cli = meow(`
Usage
  $ yeomandemo [input]

Options
  --foo  Lorem ipsum. [Default: false]

Examples
  $ yeomandemo
  unicorns
  $ yeomandemo rainbows
  unicorns & rainbows
`);
```
之后先通过命令安装package中的依赖
```
yarn   
// 或者npm install
```

link到全局范围
```
yarn link
```

通过创建的项目名称即可在全局使用cli命令

```
    yeomandemo --help
```

<pre style="background: #000; color: #ccc">
C:\Users\admin\Desktop\yeomandemo>yeomandemo --help
  yodemo

  Usage
    $ yeomandemo [input]

  Options
    --foo  Lorem ipsum. [Default: false]

  Examples
    $ yeomandemo
    unicorns
    $ yeomandemo rainbows
    unicorns & rainbows
</pre>

### 以generator-webapp为例，创建一个webapp项目

安装对应的generator
````
yarn global add generator-webapp
````

执行generator
```
yo webapp
```

之后根据提示选择需要的依赖即可创建webapp项目，由于这个生成器存在一些c++模块所以安装时会比较慢

执行启动就可以看到界面了
```
yarn start
```
![image](/20200616191859687/20200617112953463.png)
![npm 镜像源](/20200616191859687/20200617111505906.png)

### 创建自己的generator

创建Generator项目需要遵循一定的结构
<pre style="background: #000; color: #ccc">
├ generators/ ·····································  生成器目录
|  ├ app/ ·········································  默认生成器目录
|  |  └ index.js ··································  默认生成器入口实现
|  └ component/ ···································  sub generator 目录
|     └ index.js ··································  sub generator 实现
└ package.json
</pre>

1. 创建生成器目录  generator-alongtest， 初始化项目, 安装 yeoman-generator模块
```
cd generator-alongtest
yarn init
yarn add yeoman-generator
```

2. 创建generator 规定的项目结构 ，app/index.js 中
```
// generator入口
const Generator = require('yeoman-generator');
module.exports = class extends Generator {
    writing() {
        // yeoman 在生成文件阶段自动调用此方法
        
        // 使用yeoman的fs方法在项目中创建一个temp.txt文件，文件内容是一个随机浮点数
        this.fs.write(
            this.destinationPath('temp.txt'),
            Math.random().toString()
        )
    }
}
```
3. 将自定义generator link到全局
```
yarn link
```
4. 新建一个项目文件夹，如 test，

```
cd test
yo alongtest
```
此时可以看到test文件夹自动生成了temp.txt文件
<pre style="background:#000;color:#ccc">
C:\Users\admin\Desktop\alontest>yo alongtest
   create temp.txt 
</pre>

### 接收用户输入并通过模板创建文件
1. app 下创建模板文件夹templates，和项目文件index.html,package.json
这里只用两个文件代表初始化项目中的所有文件

```
// app/templates/index.html
// 模板文件
// 内部通过EJ5 模板标记输出数据
// 其他的EJS 语法也支持
<html>
    <head>
        <title>
            <%= name %>
        </title>
    </head>
    <body>
         <%if (name) {%>
            project <%= name%>
        <%} else {%>
            no name
        <%}%>
    </body>
</html
```

```
// package.json
{
    "name": "<%= name%>",
    "version": "1.0.0",
    "main": "index.js",
    "license": "MIT",
    "dependencies": {
      "yeoman-generator": "^4.10.1"
    }
  }
```

2. 入口文件 app/index.js
```
// generator入口
const Generator = require('yeoman-generator');
module.exports = class extends Generator {
    // 获取用户输入
    prompting() {
        return this.prompt([
            {
                type: 'input',
                name: 'name',
                message: 'your project name',
                default: this.appname, // 自动取到了当前项目目录
            },
        ]).then(answer => {
            this.answer = answer;
        })
    }

    writing() {
        const filelist = ['index.html', 'package.json'];
        // yeoman 在生成文件阶段自动调用此方法
        // this.fs.write(
        //     this.destinationPath('temp.txt'),
        //     Math.random().toString()
        // )

        filelist.forEach(file => {
            // 通过模板引擎吸入文件到目标目录
            // 找到模板文件
            const tmpl = this.templatePath(file)
            // 输出目标路径
            const output = this.destinationPath(file);
            // 模板数据上下文
            const context = this.answer;


            this.fs.copyTpl(tmpl, output, context); 
        })
    }
}
```
3. 在新建项目中执行 
```
yo alongtest
```
此时命令行会询问信息，最终创建项目结构
<pre style="background:#000;color: #fff">
C:\Users\admin\Desktop\alontest>yo alongtest
? your project name along
 conflict index.html
? Overwrite index.html? overwrite
    force index.html
</pre>
生成的index.html 与 package.json
```html
<html>
    <head>
        <title>
            along
        </title>
    </head>
    <body>
            project along
    </body>
</html>
```

```json
{
    "name": "along",
    "version": "1.0.0",
    "main": "index.js",
    "license": "MIT",
    "dependencies": {
      "yeoman-generator": "^4.10.1"
    }
  }
```

可以看到yeomon通过模板填充的方式创建了初始项目文件

### 发布generator

1. 创建.gitignore， 提交到git

2. 发布到npm
`npm publish` 或者 `yarn publish`  
根据提示输入版本和用户名密码，发布成功  
如果设置过其他npm 镜像需要切换回npm 镜像，可以借助nrm
```
yarn global add nrm
nrm ls // 查看所有可用镜像
nrm use npm
```
3. 之后可以通过yarn global add generator-alongtest 安装 发布的生成器

### 小型脚手架工具 plop

用于集成到项目中生成项目中同类型的项目文件
1. 安装到项目依赖中
```
yarn add plop --dev
```
2. 创建入口问及那 plopfile.js

```
// plop 入口问及那

module.exports = plop => {
    plop.setGenerator('static', { // 模板名称
        description: 'create static component',
        prompts: [ // 询问用户输入
            {
                type: 'input',
                name: 'name',
                message: 'static component name',
            },
        ],
        actions: [ // 完成交互后执行的动作
            {
                type: 'add', // 添加文件
                path: 'src/{{name}}/index.html', // 创建后文件路径
                templateFile: 'plop-templates/static-components/index.hbs' // 模板文件路径
            },
            {
                type: 'add', // 添加文件
                path: 'src/{{name}}/css/index.css',
                templateFile: 'plop-templates/static-components/css/style.hbs'
            },
            {
                type: 'add', // 添加文件
                path: 'src/{{name}}/js/index.js',
                templateFile: 'plop-templates/static-components/js/index.hbs'
            },
        ]
    })
}
```

3. 创建模板文件

可以在根目录创建模板文件，模板文件目录没有严格要求，需要与入口文件中一致,模板文件后缀名未hbs

<pre style="background:#000;color: #ccc">
├ plop-templates/ ···············································  模板目录
|  └ static-components/ ·········································  静态组件目录
|     ├ css/ ····················································  css 模板文件夹
|     |  └ style.hbs ············································  css 模板
|     ├ js/ ·····················································  js 模板文件夹
|     |  └ index.hbs ············································  js 模板文件
|     └ index.hbs ···············································  html 模板文件
└ package.json
</pre>
```
// css/style.hbs
.{{name}} {
}
// index.hbs
<html>
    <head>
        <title>{{name}}</title>
    </head>
    <body class="{{name}}">
        {{name}} body
    </body>
</html>
```

4. 使用plop命令快速创建组件
```
yarn plop static
```
输入组件名 home  
<pre style="background:#000;color: #ccc">
$ C:\Users\admin\Desktop\plop-templates\node_modules\.bin\plop static
? static component name home
√  ++ \src\home\index.html
√  ++ \src\home\css\index.css
√  ++ \src\home\js\index.js
Done in 7.45s.
</pre>

可以看到自动创建的组件文件结构  
![image](/20200616191859687/20200617061312210.png)
```
// home/css/index.css
.home {   
}

// home/index.html
<html>
    <head>
        <title>home</title>
    </head>
    <body class="home">
        home body
    </body>
</html>
```

### 脚手架原理实现

脚手架的原理很简单，无非是将与定义的文件结构通过模板处理输出到目标文件，我们可以手动实现一个脚手架工具

1. 初始化项目  
创建文件夹`cli-source`  
`cd cli-source`  
初始化项目`yarn init`

2. 创建模板文件  
根目录下创建文件夹用于存放模板文件

```
// templates/index.html
<html>
    <head>
        <title><%=name%></title>
    </head>
    <body>
        
    </body>
</html>
// template/style.css
body{
    
}
```

3. 创建入口文件cli.js  
安装所需依赖

```
yarn add ejs
```
入口文件必须有标识
```javascript
// cli.js
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const inquirer = require('inquirer');
const ejs = require('ejs');

inquirer.prompt([
    {
        type: 'input',
        name: 'name',
        message: 'Project name?'
    }
])
.then(anwser => {

    const tml = path.join(__dirname, 'templates');

    // 目标目录
    const destDir = process.cwd();

    // 复制模板文件到目标路径

    fs.readdir(tml, (err, files) => {
        if (err) {
            throw err
        }
        files.forEach(file => {
            ejs.renderFile(path.join(tml, file), anwser, (err, result) => {
                if (err) throw err;

                fs.writeFileSync(path.join(destDir, file), result)
            })
        })
    })

})
```
4. 修改package.json
添加bin指定执行文件

```
"bin": "cli.js",
```
5. 使用和发布
可以通过`yarn link`link到全局使用，或者通过`yarn publish`发布到npm







