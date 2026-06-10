---
title: ChatGPT闲聊之从 WebAssembly 到 CPU Cache
tags:
  - WebAssembly
  - .NET
  - C++
  - CPU
  - 性能优化
  - AOT
categories:
  - 技术杂谈
date: 2026-06-10 16:35:41
---


# 前言

最近和 ChatGPT 连续聊了几个小时，从 WebAssembly 一路聊到了 .NET IL、Blazor、C++、CPU Cache，最后聊到了为什么现代 CPU 要设计 L1/L2/L3 缓存，觉得这次对话受益不少，解了多年疑惑，特地让 ChatGPT 生成本篇总结方便后续重温。

---

# WebAssembly 到底是什么

很多人第一次接触 Wasm 时都会认为它是浏览器里的机器码。

实际上并不是。

Wasm（WebAssembly）本质上是一种中间字节码。
<!-- more -->

它和下面这些东西属于同一类：

- .NET IL
- Java ByteCode
- LLVM IR

工作流程大致如下：

```text
C++ / Rust / Go / C#
          ↓
       Wasm
          ↓
 浏览器运行时
          ↓
       机器码
```

浏览器负责把 Wasm 转换成当前 CPU 可以执行的代码。

因此同一个 Wasm 文件可以同时运行在：

- Windows
- Linux
- macOS
- Android
- iOS

开发者只需要编译一次。

---

# Blazor 为什么还要下载 DLL

刚开始接触 Blazor 的时候，我有一个疑问：

既然已经有 Wasm 了，为什么浏览器还会下载一堆 DLL？

后来才理解：

Blazor 早期模式其实是这样的。

```text
C#
 ↓
IL
 ↓
DLL
```

浏览器下载：

```text
dotnet.wasm
System.dll
YourApp.dll
```

其中：

```text
dotnet.wasm
```

实际上是 .NET Runtime。

浏览器先启动 Runtime，再由 Runtime 去加载 DLL 并执行里面的 IL。

本质上相当于：

```text
Windows
 ↓
CLR
 ↓
YourApp.dll
```

被搬到了浏览器里。

---

# DLL 和桌面程序里的 DLL 是同一个东西吗

答案是：

大多数情况下，是。

Blazor 下载的 DLL 本质上仍然是标准 .NET 程序集。

如果是纯业务逻辑库，例如：

- CRC
- 协议解析
- 加密算法
- 工具类

那么：

```text
WPF
ASP.NET Core
Blazor
MAUI
```

通常都可以直接共用。

真正限制兼容性的并不是 DLL 格式，而是代码依赖的运行环境。

例如：

```csharp
IJSRuntime
```

这种浏览器专属能力，放到桌面环境自然无法运行。

---

# 为什么 .NET 要设计 IL

很多人第一次接触 .NET 时都会有一个疑问：

既然最终都要变成机器码，为什么不直接编译成机器码？

为什么还要多一个 IL？

答案其实和 .NET 的设计目标有关。

.NET 最开始并不是为了 C# 设计的。

而是为了：

```text
C#
VB.NET
F#
```

甚至更多语言设计的。

因此出现了：

```text
源码
 ↓
IL
 ↓
CLR
 ↓
机器码
```

其中 CLR 的全称是：

```text
Common Language Runtime
```

即公共语言运行时。

它最大的价值其实不是性能，而是统一生态。

---

# 为什么 .NET 特别容易反编译

因为 IL 保留了大量高级语义信息。

例如：

- 类名
- 方法名
- 泛型
- 属性
- 参数类型

所以像 ILSpy、dnSpy 这样的工具几乎可以还原整个项目结构。

而 C++ 编译后已经变成：

```text
mov
jmp
call
```

这种底层机器指令。

大量语义已经丢失。

因此反编译难度高得多。

---

# AOT 为什么现在又火起来了

过去：

- CPU性能有限
- 磁盘空间有限
- 内存昂贵

因此 IL + JIT 是非常合理的方案。

但现在环境变了。

云原生、Docker、Serverless、移动端越来越关注启动速度。

于是又开始流行：

```text
IL
 ↓
AOT
 ↓
机器码
```

这种模式。

.NET 现在实际上同时支持：

## JIT

优点：

- 灵活
- 支持反射
- 包体较小

## Native AOT

优点：

- 启动快
- 内存占用低
- 更难反编译

本质上是性能和灵活性的取舍。

---

# C++ 为什么通常比 C# 快

很多人认为原因是：

> C++ 算得更快。

实际上现代 .NET 已经非常快。

真正拉开差距的往往是：

> 数据。

更准确地说：

> 数据在内存中的布局。

---

# CPU 真正慢的不是计算

现代 CPU 做一次整数加法几乎不要时间。

真正昂贵的是：

```text
从内存取数据
```

CPU 的速度远远快于内存。

于是出现了缓存体系。

---

# CPU Cache 结构

现代 CPU 大致如下：

```text
寄存器
 ↓
L1 Cache
 ↓
L2 Cache
 ↓
L3 Cache
 ↓
RAM
 ↓
SSD
```

越往下：

- 容量越大
- 速度越慢

大致可以理解为：

```text
L1   桌面
L2   抽屉
L3   文件柜
RAM  档案室
SSD  仓库
```

CPU 总是优先从最近的地方拿数据。

---

# 为什么连续内存那么重要

假设：

```cpp
int arr[1000000];
```

内存是连续的。

CPU 读取 arr[0] 时，不会只拿一个元素。

而是直接读取一个 Cache Line。

通常是：

```text
64 字节
```

因此：

```cpp
arr[1]
arr[2]
arr[3]
```

大概率已经在缓存里。

这就是缓存命中（Cache Hit）。

---

# 为什么对象散落会变慢

例如：

```csharp
class User
{
    int Age;
}
```

大量对象分配后可能散落在内存各处。

CPU 每次访问都需要跳转到新的地址。

缓存频繁失效。

产生：

```text
Cache Miss
```

这时候 CPU 只能去更慢的层级找数据。

性能会出现数量级差距。

这也是为什么游戏引擎、数据库和 AI 框架如此关注内存布局。

---

# 为什么不把 L1 做成 1GB

看起来似乎很合理。

既然缓存快，那就做大一点。

实际上不行。

原因有几个：

## 太贵

缓存使用 SRAM。

成本远高于内存使用的 DRAM。

## 太耗电

缓存越大，查找成本越高。

## 太慢

缓存不是越大越快。

缓存越大，查找时间也会增加。

最终形成了现在的结构：

```text
L1
小而极快

L2
中等

L3
较大

RAM
超大但较慢
```

这是经过几十年 CPU 演进后形成的平衡。

---

# 最后的总结

回头看这次讨论，其实所有问题都指向同一个核心。

现代软件开发始终在三个目标之间权衡：

```text
开发效率
跨平台能力
运行性能
```

C++ 选择了性能。

.NET 选择了开发效率。

Java 选择了统一运行时。

WebAssembly 则试图把跨平台能力带到浏览器。

而 AOT、Native 编译、LLVM、Wasm 等技术的发展，又在不断把这些路线重新拉近。

很多时候程序慢，并不是因为 CPU 算不动。

而是因为 CPU 在等待数据。

很多时候框架复杂，也不是因为设计者喜欢折腾。

而是在性能、灵活性和生态之间做出的取舍。

理解这些底层逻辑之后，再看 .NET、C++、Wasm、AOT，很多设计都会变得顺理成章。
