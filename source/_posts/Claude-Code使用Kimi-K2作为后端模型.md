---
title: Claude Code使用Kimi K2作为后端模型
tags:
  - AI
categories:
  - AI
abbrlink: 2575047331
date: 2025-07-16 09:47:59
---

由于`Claude Pro`计划实在不太够用，然后`Kimi K2`发布这几天又火得不行，所以尝试使用`Claude Code`+`Kimi K2`的方式看看效果，接下来将说明如何配置。

<!-- more -->

## 配置方式

目前有两种方式可以让`Claude Code`使用`Kimi K2`作为后端模型：

### 方式一：使用 Claude Code Router

[Claude Code Router](https://github.com/musistudio/claude-code-router) 是一个第三方路由工具，可以将Claude Code的请求转发到Kimi K2，实际上通过CCR可以使用任意模型。

### 方式二：使用官方兼容接口（推荐）

Kimi K2官方提供了与Anthropic API兼容的接口，这是我目前使用的方式。配置相当简单：

#### 配置步骤

1. **获取API Key**：首先需要在[Moonshot平台](https://platform.moonshot.cn/)注册账号并获取API Key

2. **配置环境变量**：在`~/.bashrc`文件底部添加以下配置：

   ```bash
   export ANTHROPIC_BASE_URL=https://api.moonshot.cn/anthropic
   export ANTHROPIC_API_KEY=你的API_KEY
   ```

3. **重新加载配置**：执行`source ~/.bashrc`或重启终端

4. **重新编译Claude Code**：配置完成后重新运行Claude Code即可。需要注意的是运行后要看`API Base URL`是不是`https://api.moonshot.cn/anthropic/`，如果没有显示`API Base URL`就代表配置没有生效，正常应该如下图

{% asset_img p1.png %}

### 注意

如果要取消使用`Kimi K2`切换回`Claude`模型，注释编译`~/.bashrc`后可能不会生效，因为之前的配置还存在ram里面，这时要么重启终端，要么使用`unset ANTHROPIC_BASE_URL`+`unset ANTHROPIC_API_KEY`来即时移除配置。

## 使用体验对比

### Kimi K2 vs Claude Sonnet 4

经过一段时间的使用，个人感受如下：

**Kimi K2的优点：**

- 价格相对便宜
- 对中文理解较好
- 基本的编程任务能够胜任
- 更加擅长前端

**不足之处：**

- 与Claude Sonnet 4相比，**推理深度明显不够**
- 对复杂问题的处理能力有限
- 代码质量和架构设计能力还有差距
- 注册的免费15￥额度根本没法用

### 速度和限制问题

**速度问题：**
Kimi K2的响应速度确实比较慢，这在日常编程中会影响工作效率。

**限速限制：**
根据[Moonshot官方文档](https://platform.moonshot.cn/docs/pricing/limits)，K2模型有以下限制：

- 免费用户限制较严格
- **需要充值一定金额才能正常使用**
- 我个人充值了50元后才能够正常使用，供参考

## 总结

虽然`Kimi K2`在某些方面还无法完全替代`Claude Sonnet 4`，但作为一个性价比选择，特别是对于预算有限或者`Claude Pro`额度不够的人来说，还是值得尝试的
