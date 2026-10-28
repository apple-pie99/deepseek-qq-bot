param(
    [string]$PackRoot = "",
    [string]$OutName = "",
    [switch]$WithDeps
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }
if ([string]::IsNullOrWhiteSpace($PackRoot)) { $PackRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath) }
$PackRoot = (Resolve-Path $PackRoot).Path

function Say($t) { Write-Host $t }

$stamp = Get-Date -Format "yyyyMMdd"
if ([string]::IsNullOrWhiteSpace($OutName)) {
    if ($WithDeps) { $OutName = "DeepSeek-QQ-Bot_full_" + $stamp + ".zip" }
    else { $OutName = "deepseek-qq-bot_" + $stamp + ".zip" }
}
$outPath = Join-Path (Split-Path -Parent $PackRoot) $OutName
Remove-Item $outPath -Force -ErrorAction SilentlyContinue

$tar = Get-Command tar.exe -ErrorAction SilentlyContinue
if (-not $tar) { Say "缺少 tar.exe（Windows 10 1803 以上自带）。请升级系统。"; exit 2 }

$missing = @()
foreach ($req in @("README.md", "LICENSE", "THIRD-PARTY-NOTICES.md", "1_先读我.txt", "2_配置向导.bat", "3_一键启动.bat", "lib\wizard.ps1", "lib\start.ps1", "lib\set_persona.py")) {
    if (-not (Test-Path (Join-Path $PackRoot $req))) { $missing += $req }
}
if ($missing.Count -gt 0) { Say ("警告：缺少必需文件 " + ($missing -join ", ")) }

Say "原地打包（不复制，避免超长路径问题）..."
$excludes = @(
    "--exclude=./_dl",
    "--exclude=./_test",
    "--exclude=./.git",
    "--exclude=./.github",
    "--exclude=./*.bak_*",
    "--exclude=./诊断_*.zip",
    "--exclude=./诊断结果_*",
    "--exclude=./backup_*.zip"
)
if ($WithDeps) {
    Say "模式：含依赖（app/ + napcat/，体积约 200MB+，适合离线发给别人）"
    Say "注意：随包分发 AstrBot 需履行 AGPL-3.0 义务，THIRD-PARTY-NOTICES.md 已在包内"
    $excludes += "--exclude=./app/AstrBot*/data"
    $excludes += "--exclude=./napcat/logs"
} else {
    Say "模式：不含依赖（默认，约 100KB，使用者自己跑 installer\下载依赖.bat）"
    $excludes += "--exclude=./app"
    $excludes += "--exclude=./napcat"
}

$t0 = Get-Date
$tarArgs = @("-a", "-c", "-f", $outPath) + $excludes + @("-C", $PackRoot, ".")
& tar.exe @tarArgs
if ($LASTEXITCODE -ne 0) { Say ("打包失败，tar exit=" + $LASTEXITCODE); exit 3 }

$sec = [math]::Round(((Get-Date)-$t0).TotalSeconds, 1)
$size = [math]::Round((Get-Item $outPath).Length/1MB, 2)
Say ""
Say ("打包完成: " + $outPath)
Say ("体积: " + $size + " MB，耗时 " + $sec + " 秒")
