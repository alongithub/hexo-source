---
title: centOs 服务器部署
date: 2020-11-11 15:42:02
tags: [centOS]
toc: true
---

### 安装node

#### 安装 nvm
安装nvm，执行一下命另下载安装nvm并注册到bash，可以在命令行使用

```
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
```

bash 修改后需要exit重新连接

```
nvm --version
```

#### 安装 node

借助nvm安装node最新版本

```
nvm install --lts
```


安装 pm2

```
npm i -g pm2
```

查看pm2 启动日志

```
pm2 log
```