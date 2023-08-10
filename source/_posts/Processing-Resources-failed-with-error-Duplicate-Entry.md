---
title: 'Processing Resources failed with error: Duplicate Entry'
tags:
  - UWP
  - XBox
categories:
  - UWP
abbrlink: 1977514895
date: 2023-08-10 16:52:33
---

今天写代码写着写着发现项目跑不起来了，一直报一个从来没见过的错误“`Processing Resources failed with error: Duplicate Entry`”，翻译过来大概是“处理资源失败并出现错误：重复条目”，但是错误信息只说出错的项目是入口项目，具体哪个文件又没指出，清理解决方案、重启VS都没用，但是回滚代码竟然可以了，这几十个文件难道要一一排除？😢

<!-- more -->

最后经过一番谷歌，发现是多语言资源中的项目重复了（我认为也有可能是Visual Studio的bug），原代码如下：

``` xml
<data name="Test" xml:space="preserve">
    <value>测试</value>
</data>
  <data name="Test_A.Text" xml:space="preserve">
    <value>测试A</value>
</data>
```

你可能跟我一样，这乍一看这没有重复啊，难不成`Test`和`Test_A`属于重复项？还真是！
于是去掉下划线，竟然可以了：

``` xml
<data name="Test" xml:space="preserve">
    <value>测试</value>
</data>
  <data name="TestA.Text" xml:space="preserve">
    <value>测试A</value>
</data>
```

这就很奇怪，难道把下划线变成分隔符了吗？于是我去掉后面的“`.`”，保留下划线，这时居然又不会报错了：

``` xml
<data name="Test" xml:space="preserve">
    <value>测试</value>
</data>
  <data name="Test_A" xml:space="preserve">
    <value>测试A</value>
</data>
```

这样看来，下划线应该是只有包含“`.`”的时候才会被视为分隔符？这是什么逻辑😅
