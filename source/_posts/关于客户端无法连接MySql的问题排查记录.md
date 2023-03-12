---
title: 关于客户端无法连接MySql的问题排查记录
tags:
  - Mysql
categories:
  - Mysql
abbrlink: 2562236451
date: 2023-03-10 00:18:02
---

前段时间部署了一个.net6的demo到centos上，因为怕麻烦所以直接使用的`宝塔面板`安装的数据库、`nginx`这些软件，虽然low，但是简单易用🤣本来也用着好好的，但是突然有一天在调试demo时发现连不上数据库了，以为代码有问题，结果换成Workbench竟然也连不上！明明啥都没动，不知怎么突然出来这么一个问题。。今天有空，google到解决方案后特地记录下，水一篇~

<!-- more -->

## 现象

* 无法使用代码、客户端连接数据库；
* 在服务器可以使用`mysql`进入控制台查询数据；
* 本地、云上防火墙都已放开端口`3306`；
* 重启mysql服务、数据库也没用；
* 使用`ps aux|grep mysql`看到mysql进程启动参数显示指定了端口：` --port=3306`；
* 使用`netstat -antp|grep 3306`发现没用任何进程监听`3306`端口；

## 分析

我碰到的问题别人一定碰到过，之所以google不到解决方案是因为搜索词不对！

从上面的现象可以看到防火墙没问题，mysql本身也正常跑着，问题就在为什么跑起来了但是没有`3306`的端口呢？结果一搜`mysql启动后没有监听任何端口`，立马就找到[结果](https://blog.csdn.net/weixin_43671497/article/details/84931578)了！

## 解决方案

我这里的原因是启用了`skip-grant-tables`，在配置文件夹里注释掉此项，然后重启mysql即可。

在宝塔面板中操作非常简单：`软件商店->Mysql->设置->配置修改`，找到`skip-grant-tables`，改为`#skip-grant-tables`，点击保存，然后切回`服务`点击`重启`就好啦！

## 为什么skip-grant-tables会导致不监听端口？

以下是google到的相关说明：

`--skip-grant-tables`会让服务器跳过读取`mysql`系统模式中的`grant`表，从而在不使用权限系统的情况下启动，这使得任何可以访问服务器的人都可以无限制地访问所有数据库。

因为使用`--skip-grant-tables`启动服务器会禁用身份验证检查，所以在这种情况下，服务器也会通过启用skip_networking来禁用远程连接。

test for cdn flush(01)