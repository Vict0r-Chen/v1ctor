---
title: IOS开发之付费订阅学习笔记 - Revenuecat篇
tags:
  - IOS
  - 付费订阅
  - SwiftUI
  - RevenueCat
categories:
  - IOS
abbrlink: 3769334848
date: 2023-02-04 01:00:59
---

虽然听起来有点奇怪：Swift语法都还没琢磨明白就要写付费订阅的功能了🤣但需求来了总不能不理是吧，本想在B站找找付费订阅相关的开发教程的，结果找到的全是"iOS游戏辅助开发流程"、"IOS无法取消订阅解决办法"、"兼容iOS16 跟Lebus学iOS原生开发..."、"关于入门成为苹果平台上独立开发者的二三事"....🤣

最后还是靠Google找到了`RevenueCat`，初步在demo实现了订阅的功能，特做记录。

<!-- more -->

老规矩，在做某一件事前首先要看的便是官方教程了：[App 内购买项目配置流程](https://help.apple.com/app-store-connect/?lang=zh-cn#/devb57be10e7)，这里说明了如何设置订阅项、如何沙箱测试等操作，如果你也是我一样的IOS开发新手，建议是必看的。

# 关于RevenueCat

## 说明

- 这个产品提供了用于和Apple通讯的API服务（好像叫Server to Server？)，另外提供了Swift/OC的SDK用于与RevenueCat通讯及对StoreKit的包装。
- 这个属于商业产品，月销售额低于1万美元不收取任何费用
- 使用他们提供的Demo，可以快速实现订阅目标

## 使用流程

### App Store Connect配置

1. 创建订阅群组;
{% asset_img 2.png %}
2. 创建订阅（自行设定订阅时长、价格或者[试用期](https://help.apple.com/app-store-connect/#/deve1d49254f)等等）;
{% asset_img 3.png %}

### RevenueCat配置

1. [注册](https://app.revenuecat.com/signup)`RevenueCat`帐户;
2. 新建App Store App；
{% asset_img 4.png %}
填写对应的APP name、App Bundle Id、共享密钥（在App Store Connect-APP信息-App专用共享密钥中可见）；
3. 新建成功后可看到`RevenueCat App ID`（**Demo代码中使用**）、`Apple Server Notification URL`（**填入到App Store Connect-APP信息-App Store 服务器通知-沙盒环境服务器 URL**）；
{% asset_img 5.png %}
4. 创建Entitlements；
{% asset_img 6.png %}
5. 点击Attach关联Products，然后点击`Add a new product`，创建产品，这**需要与App Store Connect中的订阅名称、identifier保持一致**，最终应该如下图：
{% asset_img 7.png %}
6. 创建Offerings；
{% asset_img 8.png %}
7. 在Offerings下创建Packages以及关联对应的Product（如Annual就应该关联quick.process.1year）；
{% asset_img 9.png %}

### Demo使用

1. Demo[源码下载](https://github.com/RevenueCat/purchases-ios/tree/main/Examples/MagicWeatherSwiftUI)；
2. 关联开发者帐户、TeamId、bundleId等信息；
3. 安装`RevenueCat`包：在Swift Package Manager中添加URL https://github.com/RevenueCat/purchases-ios.git；
4. 填写源码`Shared/Constants.swift`中的ApiKey、及entitlementID（此文设置的是`ProAccess`）；
{% asset_img 10.png %}

### 测试

1. [添加`沙盒测试员`](https://appstoreconnect.apple.com/access/users/sandbox)，此处的邮箱不能注册过AppleId，我这里使用的是[临时邮箱服务](https://www.linshiyouxiang.net/)；
{% asset_img 11.png %}
2. 在`设置-App Store-沙箱帐户`登录刚刚创建的帐户；
3. 将xcode运行目标设为自己的手机，运行即可查看效果；

在User界面登录沙箱帐户，可以看到订阅状态是未激活的
{% asset_img 12.png %}

此时在Weather界面点击`Change the Weather`会弹出购买订阅的信息
{% asset_img 13.png %}

点击购买就会弹出购买确认
{% asset_img 14.png %}

输入密码购买之后User界面的状态就会变为已激活，此时就可以随意点击`Change the Weather`来改变天气了！
{% asset_img 15.png %}

## 总结

RevenueCat本身优点还是很明显的，IOS开发者可以专注前端业务逻辑，不用关注后台相关的东西，并且作为一个成熟的产品，应该是全球范围的高可用的，比自建的服务器应该要稳定很多。

缺点就是在国内访问好像速度不够快，境外访问应该没有这个问题。

这次先记录到这里，应该有不少处不够清楚甚至有错误的地方，下次加强🥹🥹