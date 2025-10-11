---
title: 使用fail2ban解决frps转发Windows远程时碰到的安全问题
tags:
  - frp
  - RDP
  - fail2ban
categories:
  - 实用技能
date: 2025-10-11 14:02:13
---
## 背景

最近在使用 frp (fast reverse proxy) 转发 Windows 远程桌面服务时，发现frps的日志包含大量来自不同 IP 的连接尝试记录（主要是国外 的ip，俄罗斯、荷兰等等...）。这些频繁的扫描和暴力破解尝试不仅消耗服务器资源，而且如果密码强度不够，还真的有可能被破解。

查看 frps 日志，可以看到类似这样的记录：

<!-- more -->

```log
2025-10-11 13:37:43.571 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [18.4.91.173:49836]
2025-10-11 13:37:54.943 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [13.06.0.239:63403]
2025-10-11 13:37:59.320 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [12.8.24.151:44449]
2025-10-11 13:38:10.664 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [18.4.91.173:3052]
2025-10-11 13:38:15.670 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [13.06.0.239:59346]
2025-10-11 13:38:17.733 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [12.8.24.151:51430]
2025-10-11 13:38:35.991 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [13.06.0.239:55001]
2025-10-11 13:38:36.196 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [12.8.24.151:58245]
2025-10-11 13:38:38.755 [I] [proxy/proxy.go:204] [4339aac5d3d8dded] [rdp_victor] get a user connection [18.4.91.173:20452]
```

短时间内来自多个 IP 的连接尝试显然是扫描行为。为了加强安全防护，我决定使用 fail2ban 来自动封禁这些恶意 IP。
解决方案：使用 fail2ban 防护
fail2ban 是一个开源的入侵防御工具，它可以监控日志文件并根据规则自动封禁可疑 IP。下面是完整的配置过程。

## 1. 安装 fail2ban

``` bash
# CentOS/RHEL
sudo yum install -y fail2ban

# Ubuntu/Debian
sudo apt install -y fail2ban

# 启动服务
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

## 2. 创建 frps 过滤器规则

创建文件 `/etc/fail2ban/filter.d/frps.conf`：

``` bash
sudo vim /etc/fail2ban/filter.d/frps.conf
```

写入以下内容：

``` bash
[Definition]
failregex = .*get a user connection \[<HOST>:.*\]
ignoreregex =
```

注意要点：

<HOST> 是 fail2ban 的特殊标记，会自动提取 IP 地址
尖括号不需要转义，直接使用 <HOST> 而不是 \<HOST\>
方括号需要转义：\[ 和 \]

## 3. 创建 jail 配置

创建文件 /etc/fail2ban/jail.d/frps.local：

``` bash
sudo vim /etc/fail2ban/jail.d/frps.local
```

写入以下内容：

``` bash
[frps]
enabled = true
filter = frps
logpath = /usr/local/frps/frps.log
maxretry = 10
findtime = 600
bantime = 3600
action = iptables[name=frps, port="5001,5002", protocol=tcp]
```

配置说明：

* enabled = true：启用此 jail
* filter = frps：使用上面创建的 frps 过滤器
* logpath：frps 日志文件的实际路径（根据你的安装路径调整）
* maxretry = 10：10 次尝试后封禁
* findtime = 600：在 600 秒（10分钟）内统计失败次数
* bantime = 3600：封禁 3600 秒（1小时）
* action：使用 iptables 封禁，保护端口 5001 和 5002

## 4. 测试正则表达式
在应用配置前，务必测试正则表达式是否正确匹配：

``` bash
sudo fail2ban-regex /usr/local/frps/frps.log /etc/fail2ban/filter.d/frps.conf
```

成功的输出应该类似：

``` bash
Lines: 9 lines, 0 ignored, 9 matched, 0 missed

Failregex: 9 total
|-  #) [# of hits] regular expression
|   1) [9] .*get a user connection \[<HOST>:.*\]
`-

Ignoreregex: 0 total
```

## 5. 重启 fail2ban 服务

``` bash
# 完全重启服务
sudo systemctl restart fail2ban

# 或者只重载配置
sudo fail2ban-client reload
```

## 6. 验证配置是否生效
查看 frps jail 的状态：

``` bash
sudo fail2ban-client status frps
```

正常输出应该是：

``` bash
Status for the jail: frps
|- Filter
|  |- Currently failed: 3
|  |- Total failed:     9
|  `- File list:        /usr/local/frps/frps.log
`- Actions
   |- Currently banned: 2
   |- Total banned:     2
   `- Banned IP list:   18.4.91.173 13.06.0.239
```

查看所有活动的 jail：

``` bash
sudo fail2ban-client status
```

## 7. 常用管理命令

``` bash
# 查看被封禁的 IP 列表
sudo fail2ban-client status frps

# 手动封禁某个 IP
sudo fail2ban-client set frps banip 1.2.3.4

# 手动解封某个 IP
sudo fail2ban-client set frps unbanip 1.2.3.4

# 查看 fail2ban 日志
sudo tail -f /var/log/fail2ban.log

# 查看 iptables 规则
sudo iptables -L -n | grep frps
```

## 最后

最后还有一点需要注意的是，最好禁用本地账户登录，使用微软账户（邮箱登录），密码至少为12位数以上的强密码，可以使用Bitwarden等工具生成和保存，日常还是使用ping登录（没人想每次打开电脑时要输那么长的密码😂）。