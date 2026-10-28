# 更新日志

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循[语义化版本](https://semver.org/lang/zh-CN/)。

## [0.1.0] - 2026-10-24

首个可用版本：把 AstrBot + NapCat + DeepSeek 接成一条能跑通的链路，并把配置过程脚本化。

### 新增

- `installer/下载依赖.bat` + `lib/fetch.ps1`：下载 AstrBot 4.29.1 便携版（固定 URL 与 181,677,433 字节校验）
  与 NapCat 最新 Shell 包，带直连探测与常见代理端口自动试探（7890 / 7897 / 10809 / 1080）。
- `lib/wizard.ps1`（`2_配置向导.bat`）：一次交互完成
  - 写入 OneBot v11 反向 WebSocket 平台（端口 6199，随机 token）
  - 写入 DeepSeek 模型来源（`provider_sources`，Key 存为数组）
  - 写入模型条目（`provider`，`deepseek-chat`）
  - 通过 `lib/set_persona.py` 把人设写进 `data_v4.db` 的 `personas` 表（`persona_id='default'`）
  - 调用 DeepSeek 校验 Key（200 / 401 / 402 分别提示）
  - 打印 NapCat 需要填的两项，并在写配置前自动备份 `.bak_<时间戳>`
- `lib/start.ps1`（`3_一键启动.bat`）：依次拉起 NapCat 与 AstrBot。
- `lib/collectlogs.ps1`（`诊断\收集日志.bat`）：收集配置与日志并生成 zip，
  API Key 与 token 自动打码（`sk-***`、`"token": "***"`）。
- `lib/persona_qa.py`：人设压力测试，20 条探针 + 露馅词（"作为一个AI""语言模型"等）检测。
- `preset/` 模板：OneBot 平台、DeepSeek 来源、模型条目；空白人设、填写模板、示例人设「林小满」；
  世界书格式说明与示例 yaml。
- `docs/`：快速开始、常见问题、人设指南、世界书、架构与原理、部署与运维，
  以及四篇 `dev-notes`（AstrBot 配置字段实测、便携包结构、真链路与温度实测、世界书 schema）。

### 已知限制

- 仅支持 Windows（脚本为 PowerShell + bat）。
- 温度默认写 1.3；实测该示例人设在 1.0 更稳，见 `docs/dev-notes/03-真链路与温度实测.md`。
- 主动插话、长期记忆、世界书都需要使用者在面板或插件市场自行开启/安装。
- 未提供 Linux / Docker 部署路径。

## [未发布]

- 规划见 README 的「路线图」。
