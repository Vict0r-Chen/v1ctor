---
title: Windows批量更改文件名（超简单PowerShell命令）
abbrlink: Windows批量更改文件名（超简单PowerShell命令）
date: 2022-07-05 20:17:12
tags:
    - PowerShell
categories:
    - 实用技能
---

## 正文

今天有一个批量替换文件名的需求，记得以前用过一个工具可以批量命名，但想着应该有更简单的方式，于是Google，发现了一段超简单的PowerShell命令：

`Get-ChildItem {筛选条件} *| Rename-Item -NewName { $_.Name -replace '{查找内容}','{替换内容}' }`

<!--more-->

我的需求是把一堆`*.png`的文件名里面的`test_`删除，那么对应的命令则是：

`Get-ChildItem .png *| Rename-Item -NewName { $_.Name -replace 'test_','' }`

如果需求是把一堆`txt`文件名里的`a`替换成`b`，那么对应的命令：

`Get-ChildItem .txt *| Rename-Item -NewName { $_.Name -replace 'a','b' }`

## 说明

记得调用此命名前使用`cd {path}`跳转到对应文件夹，也可以在对应文件夹内按住`shift+鼠标右键`，在弹框中找到“**在此处打开Powershell**”。

## 参考

[Get-ChildItem](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-7.2)

[Rename-Item](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-item?view=powershell-7.2)