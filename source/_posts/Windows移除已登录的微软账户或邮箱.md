---
title: Windows移除已登录的微软账户或邮箱
tags:
  - Windows
categories:
  - 实用技能
abbrlink: 377854043
date: 2024-01-16 15:14:49
---

今天想把一台设备上退出自己的微软账户，因为这是公共设备，把自己邮箱展示在这实在不好，况且Edge还会自动同步我之前从Chrome同步过来的书签，这被人看到可要了老命了...网上都是说在账户列表Remove就可以，但是我这都没有Remove选项啊！

{% asset_img p2.png %}

花费了大半个小时，最终总算通过删注册表来达成目标...

<!-- more -->

---

先贴出[原文链接](https://answers.microsoft.com/en-us/windows/forum/all/how-do-i-removechange-the-main-account-the-account/577a2366-3a15-4b10-b5f3-dd31eb0be176)

## 注意事项

* 桌面的内容会被清空，需要提前将桌面内容备份

## 操作步骤

1. `Win+R`输入`regedit`回车，打开注册表；
2. 删除此项：`HKEY_CURRENT_USER\Software\Microsoft\IdentityCRL`；
3. 删除此项：`HKEY_USERS\DEFAULT\Software\Microsoft\IdentityCRL`；
4. 重启;

>重启后会进入用户引导界面，此时跳过绑定账户即可。
