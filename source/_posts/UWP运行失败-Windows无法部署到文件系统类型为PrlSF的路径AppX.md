---
title: 'UWP运行失败:Windows无法部署到文件系统类型为PrlSF的路径AppX'
tags:
  - UWP
  - ParallelsDesktop
categories:
  - UWP
abbrlink: 2126052679
date: 2022-10-22 16:29:38
---

封控期间，因为台式电脑被霸占，得重新掏出Mac办公，用PD重新装了个Win10，Git下载项目后编译正常，但是运行时老是提示“UWP运行失败:Windows无法部署到文件系统类型为PrlSF的路径AppX”，奇怪的是Google竟然都没有找到匹配度比较高的结果🥲（百度：你当我不存在？）

<!--more-->

由于之前PD上好像没出现过这种问题，而且因为用的是新版的PD18，所以可能是PD的问题，最终在PD上找到了[相关信息](https://forum.parallels.com/threads/prlsf-permissions-issue-when-developing-an-uwp-app-in-visual-studio.342549/)，原来是Git默认把Repo下载到`\\Mac\Home\Documents\GitHub\RepoName`的，而这个地址协议是PD共享文件夹的协议——“PrlSF”，看起来是VS目前还不支持部署项目到这种协议的地址上，所以解决方案就是把Repo老老实实放在C盘等本地磁盘就好啦😁

附：[PrlSF相关信息](https://superuser.com/questions/1619669/prlsf-file-system-on-mac)