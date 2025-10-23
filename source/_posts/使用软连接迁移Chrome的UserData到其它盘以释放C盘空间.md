---
title: 使用软连接迁移Chrome的UserData到其它盘以释放C盘空间
tags:
  - Windows
  - PowerShell
categories:
  - 实用技能
date: 2025-10-23 11:34:55
---

直接分享PowerShell脚本（AI率100%，自测没问题😂），根据需求修改`$Source`和`$Target`变量，下面的脚本是把数据迁移到`F:\Program Files (x86)\Chrome`目录

<!-- more -->

## PowerShell脚本

```powershell
# === 移动 Chrome 用户数据并创建联接 (Junction) ===
# 以管理员身份运行

$ErrorActionPreference = "Stop"

# 源与目标路径（按需修改）
$Source = "$env:LOCALAPPDATA\Google\Chrome"
$Target = "F:\Program Files (x86)\Chrome"

# 可选：复制完成后是否自动删除备份
$RemoveBackupAfterVerify = $false

# 检查：源目录是否存在
if (-not (Test-Path -LiteralPath $Source)) {
    throw "找不到源目录：$Source"
}

# 检查：是否已经是联接
$srcItem = Get-Item -LiteralPath $Source -ErrorAction SilentlyContinue
if ($srcItem -and ($srcItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    throw "源路径 $Source 已经是联接（ReparsePoint）。无需重复迁移。"
}

# 关闭 Chrome 相关进程
Write-Host "正在关闭 Chrome 进程..."
Get-Process chrome -ErrorAction SilentlyContinue | ForEach-Object {
    try { $_.CloseMainWindow() | Out-Null } catch {}
}
Start-Sleep -Seconds 2
Get-Process chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 创建目标父目录
$TargetParent = [System.IO.Path]::GetDirectoryName($Target)
if (-not (Test-Path -LiteralPath $TargetParent)) {
    Write-Host "创建目标父目录：$TargetParent"
    New-Item -ItemType Directory -Path $TargetParent | Out-Null
}

# 若目标目录不存在则创建
if (-not (Test-Path -LiteralPath $Target)) {
    Write-Host "创建目标目录：$Target"
    New-Item -ItemType Directory -Path $Target | Out-Null
} else {
    # 目标存在但不为空时给出提示（避免 /MIR 覆盖）
    $existing = Get-ChildItem -LiteralPath $Target -Force | Select-Object -First 1
    if ($existing) {
        Write-Host "警告：目标目录非空，将进行合并复制，不会删除已有文件。"
    }
}

# 复制（使用 robocopy，保留权限/时间戳）
Write-Host "复制文件到新位置（可能需要一些时间）..."
$rcLog = Join-Path $env:TEMP "chrome_migrate_$(Get-Date -Format yyyyMMdd_HHmmss).log"
$robocmd = ('robocopy "{0}" "{1}" /E /COPYALL /XJ /R:1 /W:1 /MT:16 /NFL /NDL /NP /LOG:"{2}"' -f $Source, $Target, $rcLog)
cmd /c $robocmd | Out-Null

# 简单校验：判断关键文件是否存在（如 User Data\Default）
$expected = Join-Path $Target "User Data"
if (-not (Test-Path -LiteralPath $expected)) {
    throw "复制似乎不完整：未发现 $expected。请查看日志：$rcLog"
}

# 备份原目录
$Backup = ("{0}.bak_{1}" -f $Source, (Get-Date -Format yyyyMMdd_HHmmss))
Write-Host "将源目录改名为备份：$Backup"
Rename-Item -LiteralPath $Source -NewName (Split-Path -Leaf $Backup)

# 创建联接（Junction）
Write-Host "创建联接：$Source -> $Target"
$mk = 'mklink /J "' + $Source + '" "' + $Target + '"'
cmd /c $mk | Out-Null

# 骑验联接是否创建成功
$item = Get-Item -LiteralPath $Source -ErrorAction SilentlyContinue
if (-not $item -or -not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    # 回滚
    Write-Warning "联接创建失败，正在回滚..."
    if (Test-Path -LiteralPath $Source) { Remove-Item -LiteralPath $Source -Force -Recurse }
    Rename-Item -LiteralPath $Backup -NewName (Split-Path -Leaf $Source)
    throw "创建联接失败。已回滚到原状态。"
}

Write-Host "联接创建成功！Chrome 数据现已位于：$Target"
Write-Host "备份保存在：$Backup"

# 可选：删除备份
if ($RemoveBackupAfterVerify) {
    Write-Host "验证通过，删除备份目录：$Backup"
    Remove-Item -LiteralPath $Backup -Recurse -Force
} else {
    Write-Host "建议在确认 Chrome 正常运行一段时间后，再手动删除备份以释放空间。"
}

Write-Host "完成。"
```

预期的输出结果应该是这样

``` plain
正在关闭 Chrome 进程...
创建目标目录：F:\Program Files (x86)\Chrome
复制文件到新位置（可能需要一些时间）...
将源目录改名为备份：C:\Users\victor\AppData\Local\Google\Chrome.bak_20251023_112041
创建联接：C:\Users\victor\AppData\Local\Google\Chrome -> F:\Program Files (x86)\Chrome
联接创建成功！Chrome 数据现已位于：F:\Program Files (x86)\Chrome
备份保存在：C:\Users\victor\AppData\Local\Google\Chrome.bak_20251023_112041
建议在确认 Chrome 正常运行一段时间后，再手动删除备份以释放空间。
完成。
```

最后打开Chrome看看运行是否正常，没问题的话手动删掉`$env:LOCALAPPDATA\Google\Chrome.bak_xxx`文件夹即可。