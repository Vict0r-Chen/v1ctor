---
title: MacOS启动 Claude Code 时提示Invalid URL protocol
tags:
  - Claude Code
categories:
  - AI
date: 2025-07-22 21:28:49
---

这两天想利用 MacOS 来 vibe coding 一个 IOS APP，但是装完 `Claude Code` 后，启动遇到“Invalid URL protocol”错误。实际上是由于`Claude Code`使用了`nodejs`内置的 http 类库 `undici`，但`undici`本身不支持socks5代理，所以把 socks5 代理换成 http 代理即可。

<!-- more -->

这里贴一下原始的错误，方便网友们 google 搜索

```
[InvalidArgumentError]: Invalid URL protocol: the URL must start with `http:` or `https:`.
    at DZ2 (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:371:13606)
    at Object.zw4 [as parseOrigin] (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:371:13713)
    at new GY2 (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:409:8173)
    at TR4 (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:409:13530)
    at new RY2 (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:409:14532)
    at file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:753:56171
    at Q (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:653:14408)
    at dV2 (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:753:56550)
    at file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:871:1176
    at Q (file:///usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js:653:14408) {
  code: 'UND_ERR_INVALID_ARG'
}
Node.js v22.17.1
```

事后才发现实际上有人在`Claude Code`的仓库提了[Issue](https://github.com/anthropics/claude-code/issues/3387)了

 > This is a limitation of the undici proxy library that we use. Here's the upstream github issue tracking this: nodejs undici#2224

所以这个跟`Claude Code`也没关系，老老实实把 socks5 换成 http 代理就行。

先执行`nano ~/.bash_profile`，然后找到类似以下的配置：

``` bash
export http_proxy=socks5://xxx
export https_proxy=socks5://xxx
```

改成这样

``` bash
export http_proxy=http://xxx
export https_proxy=http://xxx
```

然后`source ~/.bash_profile`即可。