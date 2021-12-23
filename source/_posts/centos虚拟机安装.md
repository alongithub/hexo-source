---
title: centos虚拟机安装
date: 2021-12-14 15:02:26
tags: [centos, 虚拟机]
toc: true
---

## centos 虚拟机安装

### 下载镜像并创建虚拟机

略

### centos 安装

1. 打开虚拟机，上下选择键选择 install CentOS

2. 安装完成后会提示选择语言，点继续

3. 之后会发现 begin installation 无法点击，此时选择 installation destination

   {% asset_img image-20211214151819195.png %}

4. 选择 i will configure partitioning , 点击 done

5. 点击左下角 + 号

   - 选择 /boot , 分配1024M 空间

   - 选择 swap , 分配4096M 空间

   - 选择 / , 直接点击 add mount point, 自动将剩余的空间分配到根目录

   - 点击 done

     {% asset_img image-20211214152211656.png %}

   - 点击 accept changes

6. 点击 begin install

7. 设置 root password， 点击两次done

8. 等待安装结束后，点击 reboot



### 网络设置

1.  查看VMware 虚拟网络配置

   点击虚拟机的编辑 -> 虚拟机网络编辑器 -> 选择 VMnet8 NET 模式
   查看 子网ip、子网掩码、网关ip

   {% asset_img image-20211214153040179.png %}

   查看 起止 ip 区间

   {% asset_img image-20211214153632288.png %}

2.  修改网络配置
    cd /etc/sysconfig/network-scripts/目录下

    vi ifcfg-ens32  (这个文件每个人可能都不一样，是系统随机命名的，但都是ifcfg-enxxx这种格式)

    修改 BOOTPROTO 和 ONBOOT 字段，并追加内容如图

  {% asset_img image-20211214154752201.png %}
3. 重启网卡服务 service network restart

   {% asset_img 20200406221633148.png %}

4. ping baidu.com 检查网络状态

