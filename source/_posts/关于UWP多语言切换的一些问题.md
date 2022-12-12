---
title: 关于UWP多语言切换的一些问题
tags:
    - UWP
    - XBox
categories:
    - UWP
abbrlink: 2719497957
date: 2022-12-12 17:37:09
---

由于最近有个在UWP中切换语言的需求，以为很简单，但没想到还是有坑....

关键字：不重启的情况下切换多语言、切换多语言后需要重新安装

<!--more-->

其实主要就两点，虽然听起来怪怪的🤣🤣

* 切换后需要立刻生效（不重启APP）
* 切换后无法立刻生效（需要安装对应的语言包或重新安装APP）

## 立刻生效多语言

主流的做法是重启APP，但其实很简单（主要是因为我采用了面向[StackOverflow](https://stackoverflow.com/questions/32715690/c-sharp-change-app-language-programmatically-uwp-realtime)的编程方式😁），在设置语言后重定向到当前页面即可：

``` csharp
ApplicationLanguages.PrimaryLanguageOverride = "en-US";
Windows.ApplicationModel.Resources.Core.ResourceContext.SetGlobalQualifierValue("Language", "en-US");
Frame.Navigate(this.GetType());
```

## 切换多语言后不生效

有两种可能，一是需要在多语言界面安装对应的语言，比如我这里安装了很多语言，但是没有安装意大利语，如果在程序里切换到`it-IT`，虽然调试时可以看到生效了，但是发布后还是没有生效

{% asset_img 20221212180040.png %}

