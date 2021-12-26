---
title: npm安装过程
date: 2021-01-21 20:09:37
tags:
---

以安装gulp-imagemin为例

请求一个接口 https://registry.npmjs.com/gulp 你的镜像地址 + 项目名

这个接口会返回json数据

下载某个npm模块后，回家压倒node_modules中，检查木块的package.json 的 scripts ，是否有 install 和 postinstall， 这两个会自动执行