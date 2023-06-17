---
title: 记一次Windows登录前运行启动项的设置(frps)
tags:
  - 开机启动
  - Windows
categories:
  - 实用技能
abbrlink: 1199409284
date: 2023-06-17 09:57:49
---

相信很多人都有需要远程电脑的需求（特指打工人😂），向日葵太臃肿而且手机端使用收费，Windows原生的远程桌面深得我心，于是我使用了Frps来实现这个目的。但可能由于安全策略的原因，很多设置开机启动项的方式都需要先登录账户，这让使用便利性急剧下降，本来只需要请人帮忙按下电脑电源键就可以搞定，现在还得让人再帮忙输入一遍密码来启用Frps？！

<!-- more -->

## 启动文件夹 `Shell:startup`

正常情况下，`shell:startup`是最好的选择，操作简单（相对注册表），按下`Windows+R`，输入`shell:startup`然后回车，直接将快捷方式或可执行文件放入其中即可，这时电脑启动后，**登录账户后**即可运行对应程序（注意：是要登录账户后才会运行），显然这不是我要的东西。

## 任务计划 `Task Scheduler`

其实任务计划我也一直有用来做开机启动，但是要做几个特殊设置才能实现真正的开机启动（而不是登录后启动），以下是计划任务导出后的示例，可以创建一个xml文件，将内容复制进去然后直接在计划任务里面导入然后修改。

``` xml
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2023-01-01T00:00:00.0000000</Date>
    <Author>Victor Chen(v1ctor.cn)</Author>
    <URI>\frpcTest</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>Administrator</UserId>
      <LogonType>S4U</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>目标程序全路径(如F:\frp\frpc.vbs)</Command>
      <WorkingDirectory>目标程序所在目录(如:F:\frp\)</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
```

导入后几个关键的设置点：

* 在“操作”中修改“程序或脚本”的路径以及“起始于”的目录（建议直接在xml中修改后再导入）；
* 点击“更改用户或组”，将用户修改为当前登录用户（可以在弹出框中点击“高级”-“查找”列出所有用户，双击选择）；

导入成功后右键点击然后运行先试验是否正确启动程序，确认后再尝试重启电脑，如此即可实现**真正的开机启动**。

PS：
最近购入了一个支持米家生态的开机棒，在米家APP上就可以远程对电脑进行开关机操作了（嗯...打工人....😅）！
后面有时间应该在软路由上部署一下frps，这样电脑端就不用设置开机启动项，只需要启用远程登录，而且整个网络环境下的所有电脑都同步支持了，这个应该是更优的方案，不过 If it is work, do not touch it😁

{% asset_img do_not_touch.gif %}
