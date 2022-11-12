---
title: 我永远都想不到UWP/WPF开发中的这个自带的小组件会浪费我一整天的时间
tags:
  - WPF
  - UWP
categories:
  - UWP
abbrlink: 3346291601
date: 2022-11-12 16:52:58
---

直接上元凶：

{% asset_img 1.png 元凶 %}

关于这个工具好像没有找到相关介绍，只有在WPF的[教程](https://learn.microsoft.com/zh-cn/visualstudio/get-started/csharp/tutorial-wpf?view=vs-2022#view-a-representation-of-the-ui-elements)中一笔带过了，这个工具不仅存在于WPF里，也存在于UWP（Winform似乎没有，好久没写过了），类似于谷歌浏览器F12里的Inspect功能，的确非常好用，直到我开发带焦点导航功能的APP之前....
<!--more-->
如图：

{% asset_img 2.png %}

由于我开发的APP需要使用手柄操作焦点来选择菜单，如果初始焦点在A点，当一直按下向右的导航键时，预想的顺序自然是**A->B->C->D->E**，但实际上居然是**A->B->E**！我真是百思不得其解，无论我如何设置`XYFocusRightNavigationStrategy`都不顶用，只能通过`XYFocusRight`指定下一个元素😢 ————或者你不小心把工具栏收缩时，你会发现焦点顺序就正常了：

{% asset_img 3.png %}

害人不浅呐😁

若需要永久关闭此工具栏：

**工具->选项->调试->XAML热重载->取消勾选“应用内工具栏”**
{% asset_img 4.png %}