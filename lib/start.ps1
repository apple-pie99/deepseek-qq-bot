param([string]$PackRoot = "")
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }
if ([string]::IsNullOrWhiteSpace($PackRoot)) { $PackRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath) }
$PackRoot = (Resolve-Path $PackRoot).Path

function Say($t) { Write-Host $t }

Say "=============================="
Say "  DeepSeek QQ 机器人 · 启动器"
Say "=============================="

$napDir = Join-Path $PackRoot "napcat"
if (Test-Path $napDir) {
    $entry = Get-ChildItem $napDir -File -Include *.bat,*.exe -Depth 2 -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -match "启动|start|boot|NapCat" } |
             Select-Object -First 1
    if (-not $entry) { $entry = Get-ChildItem $napDir -File -Filter *.bat -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1 }
    if ($entry) {
        Say ("[1/3] 启动 NapCat: " + $entry.Name)
        Start-Process -FilePath $entry.FullName -WorkingDirectory $entry.DirectoryName
    } else { Say "[1/3] napcat 目录里没找到可执行入口，请手动启动 NapCat。" }
} else { Say "[1/3] 没有 napcat 目录，跳过（只启动 AstrBot）。" }

Start-Sleep -Seconds 5

$exe = Get-ChildItem (Join-Path $PackRoot "app") -Recurse -Filter "AstrBot*.exe" -File -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $exe) {
    Say "[2/3] 没有找到 AstrBot 主程序，请先解压便携包到 app 目录。"
    exit 2
}
Say ("[2/3] 启动 AstrBot: " + $exe.Name)
Start-Process -FilePath $exe.FullName -WorkingDirectory $exe.DirectoryName

Start-Sleep -Seconds 12
Say "[3/3] 已拉起。管理面板通常是 http://127.0.0.1:6185"
Say ""
Say "注意：NapCat 首次需要扫码登录 QQ，扫完之后再回群里 @ 它。"
Say "关掉这个黑窗口不影响机器人运行。"
