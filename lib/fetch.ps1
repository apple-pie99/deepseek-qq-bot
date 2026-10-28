param(
    [string]$PackRoot = "",
    [string]$ProxyUrl = "",
    [switch]$NoProxy
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }
if ([string]::IsNullOrWhiteSpace($PackRoot)) { $PackRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath) }
$PackRoot = (Resolve-Path $PackRoot).Path
$dl = Join-Path $PackRoot "_dl"
New-Item -ItemType Directory -Path $dl -Force | Out-Null
$appDir = Join-Path $PackRoot "app"

function Say($t) { Write-Host $t }
function Probe() {
    $c = & curl.exe -s -o NUL -w "%{http_code}" --max-time 10 https://api.github.com
    return $c
}

$curl = Get-Command curl.exe -ErrorAction SilentlyContinue
if (-not $curl) { Say "缺少 curl.exe（Windows 10 1803 以上自带）。请升级系统或手动下载。"; exit 2 }

$proxyArg = @()
$direct = Probe
if ($direct -ne "200") {
    if ($NoProxy) { Say "直连失败且指定了 -NoProxy，退出。"; exit 3 }
    $candidates = @()
    if (-not [string]::IsNullOrWhiteSpace($ProxyUrl)) { $candidates += $ProxyUrl }
    $candidates += @("http://127.0.0.1:7890", "http://127.0.0.1:7897", "http://127.0.0.1:10809", "http://127.0.0.1:1080")
    $chosen = $null
    foreach ($c in $candidates) {
        $code = & curl.exe -s -o NUL -w "%{http_code}" --max-time 8 -x $c https://api.github.com
        if ($code -eq "200") { $chosen = $c; break }
    }
    if ($chosen) {
        $ProxyUrl = $chosen
        $proxyArg = @("-x", $ProxyUrl)
        Say ("GitHub 直连不通，改用代理: " + $ProxyUrl)
    } else {
        Say "GitHub 直连和常见代理端口都不通（试过 7890 / 7897 / 10809 / 1080）。"
        Say "请先打开你的代理软件，确认它的 HTTP 或混合端口，然后编辑 installer\下载依赖.bat，在最后一行加："
        Say "  -ProxyUrl ""http://127.0.0.1:你的端口"""
        Say "（也可以用 -NoProxy 强制直连）"
        exit 4
    }
} else { Say "GitHub 直连正常。" }

# ---- AstrBot 便携包 ----
$abUrl = "https://github.com/AstrBotDevs/AstrBot-desktop/releases/download/v4.29.1/AstrBot_4.29.1_windows_amd64_portable.zip"
$abZip = Join-Path $dl "AstrBot_portable.zip"
$abSize = 181677433
$needAb = -not (Test-Path (Join-Path $appDir "AstrBot.exe"))
if (-not $needAb) { $needAb = -not (Get-ChildItem $appDir -Recurse -Filter "*.exe" -File -ErrorAction SilentlyContinue) }
if ($needAb) {
    Say ""
    Say ("[1/2] 下载 AstrBot 便携包（约 173MB）...")
    $args1 = @("-L", "--fail", "--retry", "3", "-o", $abZip, "-w", "%{http_code}", "--max-time", "1800") + $proxyArg + @($abUrl)
    $code = & curl.exe @args1
    if ($code -ne "200") { Say ("下载失败，HTTP " + $code); exit 5 }
    $len = (Get-Item $abZip).Length
    if ($len -ne $abSize) { Say ("大小校验不符：期望 " + $abSize + "，实际 " + $len); Say "可能被截断，请重试。"; exit 6 }
    Say "  下载完成，大小校验通过。解压中..."
    New-Item -ItemType Directory -Path $appDir -Force | Out-Null
    Expand-Archive -Path $abZip -DestinationPath $appDir -Force
    Say ("  已解压到 " + $appDir)
} else { Say "[1/2] AstrBot 已存在，跳过。" }

# ---- NapCat ----
$napDir = Join-Path $PackRoot "napcat"
if (-not (Test-Path $napDir)) {
    Say ""
    Say "[2/2] 查询 NapCat 最新版本..."
    $jsonFile = Join-Path $dl "napcat_release.json"
    $args2 = @("-s", "-L", "--max-time", "60", "-o", $jsonFile) + $proxyArg + @("https://api.github.com/repos/NapNeko/NapCatQQ/releases/latest")
    & curl.exe @args2 | Out-Null
    $rel = Get-Content $jsonFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $asset = $rel.assets | Where-Object { $_.name -match "Shell" -and $_.name -match "\.zip$" } | Select-Object -First 1
    if (-not $asset) { $asset = $rel.assets | Where-Object { $_.name -match "\.zip$" } | Select-Object -First 1 }
    if (-not $asset) { Say "  没在 release 里找到 zip 资产，请手动下载 NapCat.Shell。"; exit 7 }
    Say ("  找到 " + $rel.tag_name + " / " + $asset.name)
    $napZip = Join-Path $dl $asset.name
    $args3 = @("-L", "--fail", "--retry", "3", "-o", $napZip, "-w", "%{http_code}", "--max-time", "900") + $proxyArg + @($asset.browser_download_url)
    $c3 = & curl.exe @args3
    if ($c3 -ne "200") { Say ("NapCat 下载失败 HTTP " + $c3); exit 8 }
    New-Item -ItemType Directory -Path $napDir -Force | Out-Null
    Expand-Archive -Path $napZip -DestinationPath $napDir -Force
    Say ("  已解压到 " + $napDir)
    Say "  注意：NapCat 许可证状态不明确，本包不内置；此脚本由你自己运行下载，责任在你。"
} else { Say "[2/2] NapCat 已存在，跳过。" }

Say ""
Say "全部完成。下一步：双击 2_配置向导.bat"
