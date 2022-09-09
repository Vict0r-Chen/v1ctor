---
title: IOS中通过快捷捷径一键打开核酸码
abbrlink: 2351527164
date: 2022-09-09 14:51:51
tags:
    - 快捷捷径
    - COVID-19
categories:
    - Geek
---

## 无关的话

本质上这是一篇分享快捷指令的水文😂

如果不是中文圈没有太多的能看的技术分享站，我就不会再发一篇垃圾文章滥竽充数了😎（说的就是你CSDN！当然V2ex不在此列哈）

<!--more-->

过去几个月一直使用快捷捷径打开核酸码，但第一次操作有点麻烦：需要先自行将核酸码[转换](https://c.runoob.com/front-end/59/)为`BASE64`格式(需要去掉类似“`data:image/png;base64,`”的前缀)，然后在快捷捷径中使用**快速查看**将`BASE64`以图片形式显示。

## 正文

今天本来想要把这个转换逻辑合并在网页里面时在Reddit找到一个更加优雅的快捷指令，初次运行时提示用户选择一个图片，然后将图片编码为`BASE64`后以文本文件(`photo.txt`)方式储存在本地文件夹(Shortcuts)，下次运行快捷捷径时，如果存在此文件则直接将文件解码并展示，Prefect！

\>\>**[先上iCloud 链接](https://www.icloud.com/shortcuts/dadd007de9bd47bbb3a1f65362c88d4e)**<<

快捷指令内容：

{% asset_img 1.png %}