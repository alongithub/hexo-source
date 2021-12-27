---
title: jenkins安装
date: 2021-12-22 20:36:05
tags:
---

### 安装jdk

Jenkins是java语言开发的，因需要jdk环境

搜索`jdk`安装包
```
yum search java|grep jdk
```

下载，默认路径 /usr/lib/jvm/
```
yum install java
```

验证
```
java -version
```

### jenkins安装

按照官网的步骤安装

To use this repository, run the following command:

```
  sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
```

If you've previously imported the key from Jenkins, the rpm --import will fail because you already have a key. Please ignore that and move on.

```
  yum install epel-release # repository that provides 'daemonize'
  yum install java-11-openjdk-devel
  yum install jenkins
```

The rpm packages were signed using this key:

```
pub   rsa4096 2020-03-30 [SC] [expires: 2023-03-30]
      62A9756BFD780C377CF24BA8FCEF32E745F2C3D5
uid                      Jenkins Project
sub   rsa4096 2020-03-30 [E] [expires: 2023-03-30]
```

按照以上步骤安装时，如果提示无法连接，需要重新制作缓存,[Jenkins yum [Errno 256] No more mirrors to try 解决方法](https://blog.csdn.net/Alan_Wdd/article/details/116260084)
```
yum clean all
yum makecache
```


配置 jenkins 端口
```
vi /etc/sysconfig/jenkins
```

修改端口 ，
ps 需要检查端口占用情况 `netstat -anp|grep 9999`
防火墙端口状态查看 `firewall-cmd --zone=public --query-port=9999/tcp`
防火墙开启端口 `firewall-cmd --zone=public --add-port=端口号/tcp --permanent`
```
JENKINS_PORT="9999"
```

启动jenkins
```
service jenkins start/stop/restart
```

### 访问jenkins

访问服务器端口
会看到需要初始密码，初始密码在 /var/lib/jenkins/secrets/initialAdminPassword

选择 Install suggested plugins 安装默认插件

等待安装完成后，创建管理员账户

ok!


### 构建gitlab自动部署

[nodejs安装](https://www.cnblogs.com/niuben/p/12938501.html)

参照node 方式安装yarn 并设置全局依赖和缓存目录，并设置yarn 的软连接

安装git
```
yum install -y git
```

安装gitlab 相关插件 `gitlab hook plugin` , `gitlab plugin`
创建jenkins 任务

选择构建一个自由风格的软件项目
1. 源码培训hi git 地址和密钥
2. 构建触发器 选择  Build when a change is pushed to GitLab...
  - 勾选push event
3. 构建 中比那些shell 脚本
4. 保存

jenkins
系统配置 -> GitHub -> Github 服务器 -> 高级 -> 为 Github 指定另外一个 Hook URL -> 保存

gitlab 配置 webhooks

1. settings -> integrations 或者 settings -> webhooks
2. 填写 jenkins 的hooks url
3. 勾选 push events
4. 添加
5. 测试

如果 gitlab hooks 测试出现 403 问题
1. Configure Global Security -> 授权策略 -> Logged-in users can do anything （登录用户可以做任何事情） 点选 -> 匿名用户具有可读权限 点选
2. 去掉跨站点请求伪造 点选 放开
Manage Jenkins- >Configure Global Security -> CSRF Protection（跨站请求伪造保护）
3. 去掉Gitlab enable authentication 点选 放开
系统管理 -> 系统设置 -> Enable authentication for '/project' end-point
参考[Hook executed successfully but returned HTTP 403](https://www.cnblogs.com/chenglc/p/11174530.html)

### 彻底卸载Jenkins

如果Jenkins 安装失败需要重新安装，参考[彻底卸载Jenkins](https://blog.csdn.net/weixin_37194108/article/details/106055992)


