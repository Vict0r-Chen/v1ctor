---
title: Windows批量更改文件名（超简单PowerShell命令）
date: 2022-07-05 20:17:12
tags: PowerShell
---

今天有一个批量替换文件名的需求，记得以前用过一个工具可以批量命名，但想着应该有更简单的方式，于是Google，发现了一段超简单的PowerShell命令：

`Get-ChildItem {筛选条件} *| Rename-Item -NewName { $_.Name -replace '{查找内容}','{替换内容}' }`

我的需求是把一堆`*.png`的文件名里面的`test_`删除，那么对应的命令则是：

`Get-ChildItem .png *| Rename-Item -NewName { $_.Name -replace 'mapping_','' }`