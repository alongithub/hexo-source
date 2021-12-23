---
title: gitlab搭建
date: 2021-12-14 15:01:25
tags: [centos, gitlab]
toc: true
---

## gitlab代码仓库搭建

### 环境安装

1. 安装ssh
```
sudo yum install -y curl policycoreutils-pythonopenssh-server
```

2. 将SSH服务设置成开机自启动

```
sudo systemctl enable sshd
```

3. 启动SSH服务
```
sudo systemctl start sshd
```

4. 安装开启防火墙,如果已经安装了防火墙并且已经在运行状态跳过此步骤
```
yum install firewalld systemd -y

service firewalld  start
// 或者
systemctl start firewalld
```

5. 添加http服务到firewalld,pemmanent表示永久生效，若不加--permanent系统下次启动后就会失效。

```
sudo firewall-cmd --permanent --add-service=http
```

6. 重启防火墙
```
sudo systemctl reload firewalld
```

7. 安装Postfix以发送通知邮件
```
sudo yum install postfix
```

8. 将postfix服务设置成开机自启动

```
sudo systemctl enable postfix
```

9. 启动postfix

```
sudo systemctl start postfix
```

10. wget 用于从外网上下载插件  `wget -V` 查看版本，已安装掠过
```
yum -y install wget
```

11. 安装vim编辑器, 系统一般会安装，可略过
```
yum -y install vim
```

### 安装gitlab

1. 添加gitlab镜像
镜像需要跟自己的centos版本对应
```
// centos 7
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-10.0.0-ce.0.el7.x86_64.rpm
// centos 8
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el8/gitlab-ce-12.10.1-ce.0.el8.x86_64.rpm
```

2. 安装gitlab
```
// centos 7
rpm -i gitlab-ce-10.0.0-ce.0.el7.x86_64.rpm
// centos 8
rpm -i gitlab-ce-12.10.1-ce.0.el8.x86_64.rpm

```
如提示缺少相应的python依赖，手动安装即可：
```
yum install policycoreutils-python
```

3. 修改gitlab配置文件指定服务器ip和自定义端口
```
vi  /etc/gitlab/gitlab.rb
```
修改 GitLab Url 模块下的 external_url
```
external_url 'http://ip:prot'
```
注意 port 端口不能被占用, 如果netstat 未安装 `yum -y install net-tools`
```
netstat  -anp|grep   端口号
```
防火墙添加开放端口：
```
firewall-cmd --zone=public --add-port=端口号/tcp --permanent
// success
```
重新载入
```
firewall-cmd --reload
//success
```
查看防火墙端口状态
```
firewall-cmd --zone=public --query-port=9999/tcp
//yes
```

4. 重启动gitlab
首次等待时间会较长
```
gitlab-ctl reconfigure
```
重启
```
gitlab-ctl restart
```




>原文地址 https://blog.csdn.net/ainixiya/article/details/103782511




