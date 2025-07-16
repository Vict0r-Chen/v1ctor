---
title: UWP打包应用提示未给任务RemoveDisposableSigningCertificate的必需参数CertificateThumbprint赋值
tags:
  - UWP
categories:
  - UWP
abbrlink: 219264919
date: 2025-04-15 12:00:00
---

一不小心又触发到一个不知名的Bug了😢我想要发布一个UWP应用到商店做测试，但是又不想重新创建新的应用填一堆信息，于是就绑定了之前创建的一个应用，但发布时就碰到提示`“未给任务RemoveDisposableSigningCertificate的必需参数CertificateThumbprint赋值”`，下意识感觉这是个冷门的问题，中文一搜果然搜不到相关问题，幸好MS论坛里面有个今年一月份的[英文贴](https://learn.microsoft.com/en-ie/answers/questions/2151054/error-msb4044-removedisposablesigningcertificate)描述了相关的问题...

<!-- MORE -->

打开贴又看到"老熟人"Junjie Zhu和Roy Li😂难道UWP论坛就这俩人负责？

仔细看完贴后发现2种解决方案

## Solution1：将原应用的“Package.StoreAssociation.xml”覆盖到项目

如果之前用这个应用身份，那就去那个项目把“Package.StoreAssociation.xml”覆盖到本项目就行，但是由于我都没有之前那个项目的源码，所以只能跳过这个解决方案了。

## Solution2：创建新的应用后重新关联

这也是我的采取的方案，去应用中心创建一个新的应用，填完相关信息，然后重新关联这个应用后再发布就正常了。

想再吐槽一下，难道微软内部不用发布UWP应用吗？噢噢，突然想起来，好像UWP要被放弃了😅后面应该只有XBox才会用UWP了吧。
