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

主流的做法是设置完语言后重启APP，当然这样的体验不太好，最简单的办法就是（面向[StackOverflow](https://stackoverflow.com/questions/32715690/c-sharp-change-app-language-programmatically-uwp-realtime)编程？😁）在设置完语言后重定向到当前页面即可：

``` csharp
ApplicationLanguages.PrimaryLanguageOverride = "en-US";
Windows.ApplicationModel.Resources.Core.ResourceContext.SetGlobalQualifierValue("Language", "en-US");
Frame.Navigate(this.GetType());
```

## 切换多语言后不生效

### 对于PC

可能是因为没有在Windows多语言设置界面安装对应的语言，比如我这里安装了很多语言，但是没有安装意大利语，如果在程序里把语言切换到`it-IT`，虽然调试时可以看到生效了，但是生成Release包或者上传到Store后，在用户那边会发现切换也不生效。

{% asset_img 20221212180040.png %}

这种情况必须要用户安装对于语言才可以切换成功。

### 对于XBox

Xbox上切换语言后会提示用户重启主机，但即便重启，APP里的语言选择还是不会生效。

这种情况则必须要用户重新安装APP才能切换到当前系统的语言。

### 为什么会这样？如何解决？

首先看看微软[关于资源包的说明](https://learn.microsoft.com/zh-cn/windows/uwp/app-resources/build-resources-into-app-package)：

> 默认情况下，构建应用程序包 (.appxbundle) 时，只会将语言、缩放和 DirectX 功能级别的默认资源构建到应用包。 翻译的资源以及为非默认缩放和/或 DirectX 功能级别定制的资源都构建到资源包中，仅供需要的设备下载。 如果客户使用语言首选项设置为西班牙语的设备从 Microsoft Store 购买应用，则只下载并安装应用和西班牙语资源包。 如果同一用户稍后在设置中将他们的语言首选项更改为法语，则将下载并安装应用的法语资源包。 符合缩放和 DirectX 功能级别的资源的情况也类似。 对于大多数应用，此行为会提高效率，而这正是你和客户想要实现的。
>
>但是如果应用支持用户在应用中即时（而不是通过设置）更改语言，则该默认行为并不适合使用。 你实际上希望无条件下载所有语言资源并随应用一次性安装，然后将它们保留在设备上。 你希望将所有这些资源构建到应用包而不是单独的资源包。

简而言之就是UWP的多语言资源包和APP包是分开的，在安装时只会根据当前系统支持的语言列表来安装对应的语言包。

这就可以解释为什么XBox需要重新安装才能生效语言设置、而PC必须要安装对应的语言包才能切换———因为根本没有安装对应语言包啊！

所以解决方案就是要把资源包跟APP包放在一起，这一点微软文档说得非常清楚，按教程做就可以（用真心也可以😁），详情参见这个[链接](https://learn.microsoft.com/zh-cn/windows/uwp/app-resources/build-resources-into-app-package#option-1-use-priconfigpackagingxml-to-build-resources-into-your-app-package)。
