---
title: npm发布cli
date: 2021-12-31 17:30:33
tags:
---


编写发布一个简易的cli并发布到npm，类似vue-cli、create-react-app可以快速搭建项目，整体的实现思路就是通过交互命令拉取git上的脚手架

### git上传搭建好的项目

我发布了两个脚手架地址为
    es6
    https://github.com/alongithub/along-react-app.git
    typescript
    https://github.com/alongithub/along-react-ts.git
### cli项目

npm init -y
package.json    文件中添加

"bin": {
    "alongcli": "bin/alongcli"
 },
安装需要的依赖
```
npm install figlet @darkobits/lolcatjs commander inquirer shelljs download-git-repo ora --save-dev
```
创建文件   bin/alongcli    (一个没有后缀名的文件)
```
// figlet \ printer 用于增加输出文字效果
const figlet = require('figlet'); // asc码
const Printer = require('@darkobits/lolcatjs'); // 文字色渐
// 用于区分用户输入命令参数信息
const program = require('commander');
// 用于用户的询问交互，比如语言的选择，项目名输入等
const inquirer = require('inquirer');
const shell = require('shelljs'); // 用于执行shell命令
// 用于拉取git项目
const downloadgit = require('download-git-repo');
const ora = require('ora'); // loading 效果包

// alongcli -v 查看版本
const version = '1.0.1';
program.version(Printer.default.fromString(version), "-v,--version");
program.parse(process.argv);

const bindHandler = {
  init(params) {
    inquirer.prompt([
      {
        type: 'text',
        name: 'projectname',
        message: '请输入要创建的项目名',
      },
      {
        type: 'list',
        name: 'jstype',
        message: '选择脚手架',
        choices: [
          '√ along-react-app ES6', '√ along-react-ts TypeScript',
        ],
      },
    ]).then(answer => {
      const _dirname = answer.projectname;
      if (_dirname) {
        const spinner = ora('正在创建项目');
        spinner.start();
        const _path = shell.pwd().stdout;
        console.log(_path);
        const _projectPath = `${_path}/${_dirname}`;
        console.log(_projectPath);
        shell.cd(_path);
        shell.rm('-rf', _projectPath);
        shell.mkdir(_dirname);
        const templateUrl = answer.jstype === '√ along-react-app ES6' ? 'direct:https://github.com/alongithub/along-react-app.git' : 'direct:https://github.com/alongithub/along-react-ts.git';

        // const templateUrl = 'direct:https://github.com/alongithub/along-react-app.git';

        downloadgit(templateUrl, _projectPath,  {clone: true}, (err) => {
          spinner.stop();
          if (err) {
            console.log(chalk.red('error:'));
            // console.log(err);
          } else {
            const txt = figlet.textSync('along-cli\nV 1.0.1');
            console.log(Printer.default.fromString(txt));
            shell.sed("-i", "along-react-app",_dirname,_projectPath+"/package.json");
          }
        })

      }
    })
  },
}

program.usage("<cmd> [env]")
    .arguments('<cmd> [env]')
    .action(function (cmd, otherParams) {
        // 输出用户输入的内容 cmd 是用户输入的第一个参数 otherParams 是第二个参数
        const handler = bindHandler[cmd];
        if (handler) {
            handler(otherParams);
        } else {
            console.log(chalk.yellow('暂未实现') + chalk.red(cmd) + chalk.blue('...'));
        }
    })
program.parse(process.argv);
```

### 发布
        npm注册账号

        在cli项目中

npm login
npm publis


发布成功后邮箱会收到邮件，我现在发布的脚手架叫alongcli ，可以在npm搜索并查看使用方法。



全局安装
npm install alongcli -g
创建项目
alongcli init
// 或者
along-cli init

启动项目
npm run dev
// 或者
npm run build
node server.js
        访问地址

http://localhost:8006/along/demo