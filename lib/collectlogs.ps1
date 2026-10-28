param([string]$PackRoot = "")
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }
if ([string]::IsNullOrWhiteSpace($PackRoot)) { $PackRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath) }
$PackRoot = (Resolve-Path $PackRoot).Path

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir = Join-Path $PackRoot ("诊断结果_" + $stamp)
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

function CopyIfExists($src, $name) {
    if (Test-Path $src) { Copy-Item $src (Join-Path $outDir $name) -Recurse -Force; Write-Host ("  收集: " + $name) }
}

$cfg = Get-ChildItem $PackRoot -Recurse -Filter "cmd_config.json" -File -Depth 5 -ErrorAction SilentlyContinue | Select-Object -First 1
if ($cfg) {
    $content = Get-Content $cfg.FullName -Raw -Encoding UTF8
    $content = $content -replace 'sk-[A-Za-z0-9_\-]{8,}', 'sk-***已隐藏***'
    [IO.File]::WriteAllText((Join-Path $outDir "cmd_config.redacted.json"), $content, (New-Object Text.UTF8Encoding($false)))
    Write-Host "  收集: cmd_config.redacted.json（Key 已打码）"
}

CopyIfExists (Join-Path $PackRoot "app\logs") "astrbot_logs"
CopyIfExists (Join-Path $PackRoot "app\data\logs") "astrbot_data_logs"
CopyIfExists (Join-Path $PackRoot "napcat\logs") "napcat_logs"
CopyIfExists (Join-Path $env:LOCALAPPDATA "com.napcatqq.desktop\logs") "napcat_desktop_logs"
$onebotCfg = Get-ChildItem $PackRoot -Recurse -Filter "onebot11*.json" -File -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
if ($onebotCfg) {
    $obText = Get-Content $onebotCfg.FullName -Raw -Encoding UTF8
    $obText = $obText -replace '"token"\s*:\s*"[^"]*"', '"token": "***已隐藏***"'
    [IO.File]::WriteAllText((Join-Path $outDir "onebot11.redacted.json"), $obText, (New-Object Text.UTF8Encoding($false)))
    Write-Host "  收集: onebot11.redacted.json（token 已打码）"
}

$sysinfo = @()
$sysinfo += "OS: " + [Environment]::OSVersion.VersionString
$sysinfo += "PS: " + $PSVersionTable.PSVersion.ToString()
$sysinfo += "64bit: " + [Environment]::Is64BitOperatingSystem
$sysinfo += "时间: " + (Get-Date).ToString("s")
$sysinfo += "端口占用(6185/6199/3000/3001):"
foreach ($p in 6185,6199,3000,3001) {
    $t = (Test-NetConnection -ComputerName 127.0.0.1 -Port $p -InformationLevel Quiet -WarningAction SilentlyContinue)
    $sysinfo += ("  " + $p + " -> " + $t)
}
$sysinfo | Set-Content (Join-Path $outDir "环境信息.txt") -Encoding UTF8

$zip = Join-Path $PackRoot ("诊断_" + $stamp + ".zip")
Compress-Archive -Path (Join-Path $outDir "*") -DestinationPath $zip -Force
Remove-Item $outDir -Recurse -Force
Write-Host ""
Write-Host ("已生成: " + $zip)
Write-Host "把这个文件发给给你机器人的人即可。"
