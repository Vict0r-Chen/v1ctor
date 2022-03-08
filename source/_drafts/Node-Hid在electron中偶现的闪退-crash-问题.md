---
title: Node-Hid在electron中偶现的闪退(crash)问题
date: 2022-02-28 15:36:23
tags:
---

### 前言

前段时间在一个`electron`项目中使用[node-hid](https://github.com/node-hid/node-hid)配合`C++`类库实现设备的固件升级(即`dfu`)，在开始升级时出现了闪退的现象，概率为1%左右（个别电脑可达到10%）。

