param(
    [string]$PackRoot = "",
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }

if ([string]::IsNullOrWhiteSpace($PackRoot)) {
    $PackRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}
$PackRoot = (Resolve-Path $PackRoot).Path

function Line($t) { Write-Host $t }
function AskText($prompt, $def) {
    if ([string]::IsNullOrWhiteSpace($def)) { Write-Host ($prompt + "：") -NoNewline }
    else { Write-Host ($prompt + " [" + $def + "]：") -NoNewline }
    $a = Read-Host
    if ([string]::IsNullOrWhiteSpace($a)) { return $def }
    return $a.Trim()
}
function SetProp($obj, $name, $val) {
    if ($null -ne $obj.PSObject.Properties[$name]) { $obj.$name = $val }
    else { $obj | Add-Member -NotePropertyName $name -NotePropertyValue $val }
}
function FindFirstFile($dir, $pattern, $depth) {
    if (-not (Test-Path $dir)) { return $null }
    $hit = Get-ChildItem $dir -Recurse -Filter $pattern -File -Depth $depth -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) { return $hit.FullName }
    return $null
}

Line ""
Line "=============================================="
Line "  DeepSeek QQ 机器人 · 配置向导"
Line "  只需要填两个东西：API Key 和 机器人名字"
Line "=============================================="
Line ""

$exe = FindFirstFile (Join-Path $PackRoot "app") "AstrBot*.exe" 4
if (-not $exe) { $exe = FindFirstFile (Join-Path $PackRoot "app") "*.exe" 3 }
if ($exe) { Line ("[1/5] 找到 AstrBot: " + $exe) }
else {
    Line "[1/5] 没有在 app 目录里找到 AstrBot 主程序。"
    Line "      请确认已经把 AstrBot 便携包解压到本目录下的 app 文件夹。"
    Line "      如果装到别处，请把完整路径粘贴进来（直接回车退出）："
    $manual = Read-Host
    if ([string]::IsNullOrWhiteSpace($manual)) { exit 2 }
    $exe = $manual.Trim()
}

$appDir = Split-Path -Parent $exe
$candidates = @(
    (Join-Path $appDir "data\cmd_config.json"),
    (Join-Path (Split-Path -Parent $appDir) "data\cmd_config.json"),
    (Join-Path $env:APPDATA "AstrBot\data\cmd_config.json"),
    (Join-Path $env:LOCALAPPDATA "AstrBot\data\cmd_config.json")
)
$cfgPath = $null
foreach ($c in $candidates) { if (Test-Path $c) { $cfgPath = $c; break } }
if (-not $cfgPath) {
    Line "[2/5] 还没找到 data\cmd_config.json。"
    Line "      请先双击运行一次 AstrBot，让它自己生成配置，然后关掉，再重新运行本向导。"
    exit 3
}
Line ("[2/5] 配置文件: " + $cfgPath)

Line ""
Line "[3/5] 请输入你的 DeepSeek API Key（sk- 开头，粘贴后回车）："
$key = (Read-Host).Trim()
if ([string]::IsNullOrWhiteSpace($key)) { Line "  Key 不能为空。"; exit 4 }
if (-not $key.StartsWith("sk-")) { Line "  提示：DeepSeek 的 Key 通常以 sk- 开头，请确认没粘错。" }
$botName = AskText "机器人叫什么名字（用于人设标题）" "林小满"

$body = '{"model":"deepseek-chat","messages":[{"role":"user","content":"hi"}],"max_tokens":1}'
$tmp = Join-Path $env:TEMP "dsk_probe.txt"
$code = "000"
$curl = Get-Command curl.exe -ErrorAction SilentlyContinue
if ($curl) {
    $argList = @("-s", "-o", $tmp, "-w", "%{http_code}", "--max-time", "25", "-X", "POST", "https://api.deepseek.com/v1/chat/completions", "-H", ("Authorization: Bearer " + $key), "-H", "Content-Type: application/json", "-d", $body)
    $code = & curl.exe @argList
} else {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $resp = Invoke-WebRequest -Uri "https://api.deepseek.com/v1/chat/completions" -Method Post -TimeoutSec 25 -Headers @{ Authorization = ("Bearer " + $key) } -ContentType "application/json" -Body $body -UseBasicParsing
        $code = [string]$resp.StatusCode
    } catch {
        if ($_.Exception.Response) { $code = [string][int]$_.Exception.Response.StatusCode } else { $code = "000" }
    }
}
Line ("[4/5] API 校验结果: HTTP " + $code)
switch ($code) {
    "200" { Line "      Key 有效，余额正常。" }
    "401" { Line "      Key 无效或已失效，请重新申请。"; exit 5 }
    "402" { Line "      Key 有效但账户余额不足，请充值后重试。" }
    "000" { Line "      连不上 api.deepseek.com。若用了代理请先开好，或检查网络。" }
    default { Line "      返回了意外状态码，可能是网络或代理问题，可以先继续，稍后再测。" }
}

$raw = Get-Content $cfgPath -Raw -Encoding UTF8
$cfg = $raw | ConvertFrom-Json

$token = "astrbot-" + ([guid]::NewGuid().ToString("N").Substring(0, 24))
$obTemplate = Join-Path $PackRoot "preset\astrbot\platform_onebot.json"
$obJson = (Get-Content $obTemplate -Raw -Encoding UTF8).Replace("__ASTRBOT_TOKEN__", $token)
$onebot = $obJson | ConvertFrom-Json

$pvTemplate = Join-Path $PackRoot "preset\astrbot\provider_deepseek.json"
$pvJson = (Get-Content $pvTemplate -Raw -Encoding UTF8).Replace("__DEEPSEEK_API_KEY__", $key)
$provider = $pvJson | ConvertFrom-Json

$platforms = @()
if ($cfg.platform) { $platforms = @($cfg.platform) | Where-Object { $_.id -ne "default" } }
$platforms = @($platforms) + $onebot
SetProp $cfg "platform" $platforms

$sources = @()
if ($cfg.provider_sources) { $sources = @($cfg.provider_sources) | Where-Object { $_.id -ne "deepseek" } }
$sources = @($sources) + $provider
SetProp $cfg "provider_sources" $sources

$pmTemplate = Join-Path $PackRoot "preset\astrbot\provider_model_deepseek.json"
if (Test-Path $pmTemplate) {
    $model = (Get-Content $pmTemplate -Raw -Encoding UTF8) | ConvertFrom-Json
    $models = @()
    if ($cfg.provider) { $models = @($cfg.provider) | Where-Object { $_.id -ne $model.id } }
    $models = @($models) + $model
    SetProp $cfg "provider" $models
    Line ("      已写入模型条目: " + $model.id)
} else {
    Line "      警告: 缺少 provider_model_deepseek.json，机器人将没有可用模型。"
}

$ps = $cfg.provider_settings
if (-not $ps) { $ps = [pscustomobject]@{}; SetProp $cfg "provider_settings" $ps }
SetProp $ps "enable" $true

if ($DryRun) {
    Line "[5/5] DRY RUN：不写文件。将写入: platform / provider_sources，并更新 personas 表 system_prompt"
    Line ("      机器人名字: " + $botName + "  token: " + $token)
    exit 0
}

$backup = $cfgPath + ".bak_" + (Get-Date -Format "yyyyMMdd_HHmmss")
Copy-Item $cfgPath $backup -Force
$json = $cfg | ConvertTo-Json -Depth 40
[IO.File]::WriteAllText($cfgPath, $json, (New-Object Text.UTF8Encoding($false)))

$personaPath = Join-Path $PackRoot "preset\persona\_我的设定.md"
$localPersona = Join-Path (Split-Path -Parent $PackRoot) "persona_local\_我的设定.md"
if (Test-Path $localPersona) { $personaPath = $localPersona }
$dbPath = Join-Path $appDir "data\data_v4.db"
if (-not (Test-Path $dbPath)) { $dbPath = Join-Path (Split-Path -Parent $appDir) "data\data_v4.db" }
if (-not (Test-Path $personaPath)) {
    Line "      人设: 未设置（保持 AstrBot 默认的通用助手语气）"
    Line "      想给它一个角色：把 preset\persona\_模板.md 填好，另存为 _我的设定.md，再跑一次本向导。"
} elseif (-not (Test-Path $dbPath)) {
    Line "      还没有数据库 data_v4.db，人设这次跳过。"
    Line "      请先完整启动一次 AstrBot（3_一键启动.bat）再重跑本向导。"
} elseif (Test-Path $personaPath) {
    $py = Get-ChildItem $appDir -Recurse -Filter "python.exe" -File -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
    $setter = Join-Path $PackRoot "lib\set_persona.py"
    if ($py -and (Test-Path $setter)) {
        $r = & $py.FullName $setter $dbPath $personaPath "default" 2>&1
        Line ("      人设: " + (($r | Out-String).Trim()))
    } else { Line "      没找到内置 python 或 set_persona.py，人设需在管理面板手动填。" }
}

Line ""
Line "[5/5] 配置完成。"
Line ("      原配置已备份: " + (Split-Path -Leaf $backup))
Line ""
Line "============ 把下面两项填进 NapCat ============"
Line "  反向 WebSocket 地址: ws://127.0.0.1:6199/ws"
Line ("  Access Token:        " + $token)
Line "  消息格式:            array"
Line "=============================================="
Line "  （NapCat 里新建「WebSocket 客户端（反向）」，填上面两项并启用）"
Line ""
Line "  下一步：双击 3_一键启动.bat（先起 NapCat 再起 AstrBot 也行，先后无所谓）"
Line ""
