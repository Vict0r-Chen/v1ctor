---
title:  Advanced Installer 19.2 安装包及激活工具分享
date: 2022-03-08 10:25:56
tags: AdvanceInstaller 破解工具
---
## 重点

`Advance Install 19.2`最新包： [点击下载](https://www.advancedinstaller.com/downloads/advinst.msi)

激活工具：[点击下载](/download/patch.zip)

## 使用说明：

安装`Advance Install`之后，打开可执行文件路径（我的是`C:\Program Files (x86)\Caphyon\Advanced Installer 19.2\bin\x86`），将压缩包内的`patch.exe`粘贴到此，**以管理员身份运行**即可。
<!--more-->

## 温馨提示：

下载前后都会收到Chrome跟Windows防火墙的病毒提醒😂 **有条件请支持正版**！

## 无关的话

这段时间做了个WPF工具，因为内部有很多文件引用，使用Fody进行单文件打包不能直接使用，所以就在找安装包制作工具。

对比了一圈，如`WiX toolset`、`NSIS`、`InstallShield`还有最终选定的`Advance Installer`。

`Wix toolset`之前有使用，功能很强大，文档也齐全（虽然说是全英文），但由于是纯靠xml配置来生成界面，需要花费相当的时间来学习对应的语法，所以就放弃了。另外两个也有所耳闻，但只有`Advance Install`能满足我不花时间，能实现一定程度的配置以及点几个按钮就能生成安装包的需求🤣。

但由于`Advance Install`是商业软件，只能使用有限功能最长30天，所以需要破解工具才能愉快的使用。经过一番筛选，期间还碰到了几个病毒（虚拟机都搞坏了），最终确认上面链接中的工具可以使用。