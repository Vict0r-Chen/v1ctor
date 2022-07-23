---
title: IOS中通过快捷捷径打开健康码/场所码
date: 2022-07-03 13:50:52
tags: Geek
---

## 说明

本文标题其实应该叫“使用快捷捷径打开任意微信小程序页面”，因为本质上这篇文章就是说明如何在获取微信小程序任意界面的页面路径，以及通过Universal link在微信中打开对应页面的方法（本文使用“跨时空”APP来达到此目的）。

<!--more-->

## 无关的话

终于又得空，有时间写写blog(bug?)了，最近有点理解《开端》里说的“塞尔达才是天”了😂 

其实本来有很多东西可写，奈何自己一直都这么懒

## 正文

自从上次把“智慧南山”（似乎其它区的门禁小程序似乎也差不多）打开门禁的请求包用`Charles`抓下来放在快捷指令后总想着还有其它重复操作可以简化的，正好最近疫情又变严重，自然想起了场所码啦！

废话少说，开打开打～

### 一、获取场所码页面路径

其实此方法来源于微信公众号发表文章时，需要在文章中打开指定小程序页面的功能，本意上是增加小程序的使用场景，没想到给了我们可乘之机😁

***前提***：拥有一个微信公众号（个人或企业资质均可）

操作步骤：

1. 登录[微信公众号](https://mp.weixin.qq.com/)，在`草稿箱`新建`图文消息`，点击上方的“小程序”，然后在弹出窗中输入对应小程序的全称或AppId（此处以`粤省事`为例，**AppId**：`wx82d43fee89cdc7df`，***账号原始ID***：`gh_1ac06b5a8f4e`，因广东场所码都在`粤省事`里面），点击下一步；
   
   {% asset_img p1.png %}

2. 在“填写详细信”的窗口，将鼠标悬浮在`获取更多页面路径`后，在新的弹窗中输入自己的微信号，点击开启；
   
   {% asset_img p2.png %}

3. 开启后，你就可以扫描你目标二维码打开小程序=>点击右上角菜单按钮=>点击`复制页面路径`，此处我得到的路径是：
   `operation_plus/pages/yiqing/daka/worker/inspector/fast-result/index.html?scene=id%3D999999999%2Ccp%3D0`；

   {% asset_img p3.png %}

至此，准备工作已经完成，接下来就是“跨时空”APP登场啦！

### 二、使用“跨时空”APP打开已复制的页面路径

***前提***：前往APP Store下载“跨时空”

1. 将第一步的`账号原始ID(gh_1ac06b5a8f4e)`和`复制的小程序路径`粘贴到下方并点击**生成**。

{% raw %}
<script>
   function concatPath(){
      let id=document.getElementById("txtId").value;
      let path=document.getElementById("txtPath").value;
      document.getElementById("result").innerText=`ksk://kainy.cn/#weixin://app/KSK_URLscheme/jumpWxa/?userName=${id}&path=${path}`;
   }
</script>
<div style="background:#23507f23; padding:10px; border-radius: 10px;margin: 10px 20px;">
   <p style="text-align:center;margin-bottom:10px;">
      <strong>生成URL</strong>
   </p>
   <div>
      <span>账号原始ID：</span>
      <input id="txtId">
      <span>小程序路径：</span>
      <input id="txtPath">
      <button onclick="concatPath()">生成</button>
      <p id="result"></p>
   </div>
</div>
{% endraw %}

2. 将上一步替换后的URL添加到`快捷指令`中：
   1. 打开`快捷指令`，点击右上角“+”，输入`快捷指令`的名称；
   2. 点击`添加操作`，输入`打开URL`；
   3. 将替换后的URL粘贴进`URL`中；
*此处生成的URL应是：`ksk://kainy.cn/#weixin://app/KSK_URLscheme/jumpWxa/?userName=gh_1ac06b5a8f4e&path=operation_plus/pages/yiqing/daka/worker/inspector/fast-result/index.html?scene=id%3D999999999%2Ccp%3D0`*

{% asset_img p4.png %}

3. 运行快捷指令看看效果～
4. 尝试将快捷指令增加到桌面或者添加到通知界面吧！

**最后Show一下我的快捷指令组件吧～**
{% asset_img p5.png %}