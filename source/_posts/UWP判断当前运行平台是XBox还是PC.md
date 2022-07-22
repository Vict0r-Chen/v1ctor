---
title: UWP判断当前运行平台是XBox还是PC
date: 2022-07-22 23:08:54
tags: [UWP, XBox, ResouceDictionary]
---

## 前言

其实这是个小众需求，因为在我的视角看来，UWP应用运行在XBox与PC间的差异非常少，对我日常开发来说几乎没有太多区别（除了XBox下没有处理的游戏控制器的B键会退出应用😂）。

<!--more-->

由于XBox通常通过电视机来输出，且用户与电视距离会稍远（[参考链接](https://docs.microsoft.com/zh-cn/windows/apps/design/devices/designing-for-tv#ui-element-sizing)），所以为了让用户能够看清内容，XBox上的UWP的展示默认会放大两倍（**当然**你也可以[阻止自动缩放](https://docs.microsoft.com/zh-cn/windows/apps/design/devices/designing-for-tv#opting-out-of-scale-factor)），这会导致原来在PC下非常正常的布局在XBox下变得亲妈都不认识（指我自己🤣）。

虽然最好的做法是使用自适应布局同时适配两个平台，但是考虑到额外多出来的时间成本🤔...下次一定。

所以我的思路是根据不同平台来加载不同的资源字典（`ResouceDictionary`），应该好搞~

## 如何判断设备类型？

``` csharp
using Windows.System.Profile;
...
if(AnalyticsInfo.VersionInfo.DeviceFamily == "Windows.Xbox"){
    //你的逻辑...
}
```
其实我在Stackoverflow上有找到这个[问题](https://stackoverflow.com/a/69278888/7632913)，说是可以引用`Microsoft.Toolkit`工具包然后用`SystemInformation.DeviceFamily`来获取设备类型字符串，但是根据工具包的[源码](https://github.com/CommunityToolkit/WindowsCommunityToolkit/blob/rel/7.1.0/Microsoft.Toolkit.Uwp/Helpers/SystemInformation.cs#L53)，其实人家根本没做什么特殊操作，只是对`AnalyticsInfo.VersionInfo.DeviceFamily`封装了一下而已....可能因为这人是微软员工想推广自家的组件？🤔

顺便吐槽一下为什么百度到的全是这样的结果？咱这没有`SystemInfo.deviceType`啊！是用`unity`的人多还是全都是爬虫复制的内容？

{% asset_img p1.png %}

## 如何动态操作资源字典？

我这边在根目录下新增了`Theme`文件夹，同时在该文件夹下新增了`XBox.xaml`和`PC.xaml`这两个资源文件，部分代码：

``` csharp App.xaml.cs
protected override void OnLaunched(LaunchActivatedEventArgs e)
{
    var family = AnalyticsInfo.VersionInfo.DeviceFamily;
    //为XBox添加额外的样式（同时移除PC.xaml）
    if (family == "Windows.Xbox")
    {
        var xboxRD = new ResourceDictionary();
        xboxRD.Source = new Uri("ms-appx:///Theme/XBox.xaml");
        Application.Current.Resources.MergedDictionaries.Add(xboxRD);

        var pcRD = Application.Current.Resources.MergedDictionaries.FirstOrDefault(x => x.ContainsKey("PC"));
        Application.Current.Resources.MergedDictionaries.Remove(pcRD);
    }
}
```

``` xml App.xaml
<Application ...>
    <Application.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ResourceDictionary Source="OtherStyle.xaml"/>
                <ResourceDictionary Source="Theme/PC.xaml"/>
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary >
    </Application.Resources >
</Application>
```

``` xml Theme/PC.xaml
<ResourceDictionary
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <!-- 当前资源标识 -->
    <x:Int32 x:Key="PC">0</x:Int32>
    <!-- 页面中使用到的资源 -->
    <x:Double x:Key="PageMaxHeight">550</x:Double>
</ResourceDictionary>
```
``` xml Theme/XBox.xaml
<ResourceDictionary
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <!-- 当前资源标识 -->
    <x:Int32 x:Key="XBox">0</x:Int32>
    <!-- 页面中使用到的资源 -->
    <x:Double x:Key="PageMaxHeight">350</x:Double>
</ResourceDictionary>
```

然后直接在页面中使用`{StaticResource PageMaxHeight}`就可以引用此资源来实现样式差异化处理了。

其实对于合并资源的操作我在网上也没找到比较合适的代码，因为不知道如何定位到指定的资源字典，我这里是提前给资源字典里加了个`Key`来标识当前资源字典，比如`PC.xaml`里有个`PC`的资源，通过`Application.Current.Resources.MergedDictionaries.FirstOrDefault(x => x.ContainsKey("PC"))`就可以定位到此资源。