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


### 构建

[nodejs安装](https://www.cnblogs.com/niuben/p/12938501.html)

