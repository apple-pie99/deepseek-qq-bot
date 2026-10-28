# 第三方组件与许可声明

本仓库**只包含**配置模板、PowerShell / batch 脚本、Python 小工具、人设与说明文本。
下方第三方组件均**不随仓库分发**：使用者通过 `installer/下载依赖.bat` 或官方渠道自行获取。

## 1. AstrBot / AstrBot-desktop

- 许可证：**AGPL-3.0**
- 源码：<https://github.com/AstrBotDevs/AstrBot> 、<https://github.com/AstrBotDevs/AstrBot-desktop>
- 本项目如何使用：`installer/下载依赖.bat` 调用 `lib/fetch.ps1`，从 AstrBot-desktop 的 GitHub Releases
  下载 `AstrBot_4.29.1_windows_amd64_portable.zip`（已固定版本与字节数校验），由使用者在本地解压运行。
- 义务说明：AGPL-3.0 的分发义务落在**分发 AstrBot 本体的人**身上。本仓库不包含其二进制或源码，
  因此不承担该项分发义务；但若你基于本项目制作"整合包"并把 AstrBot 一起打包发放，则必须随包提供
  AGPL-3.0 全文并给出对应源码获取方式（包括你对 AstrBot 的任何修改）。
- 本项目未修改 AstrBot 源码；对它的所有操作都通过 `data/cmd_config.json` 与 SQLite 数据库完成。

## 2. NapCatQQ

- 许可证：**NOASSERTION**（GitHub 未识别出标准开源许可证，权利状态不明确）
- 源码：<https://github.com/NapNeko/NapCatQQ>
- 本项目如何使用：`lib/fetch.ps1` 查询其最新 Release 并下载 `Shell` 包，解压到使用者本地 `napcat/` 目录。
- 建议：**任何情况下都不要把 NapCat 内置进你制作的整合包**。让使用者自己下载，可规避再分发授权风险。

## 3. QQ 客户端

- 专有软件，**不随任何形式分发**。
- 唯一合规途径是从腾讯官网 <https://im.qq.com> 下载安装。

## 4. 本项目文档中提到的插件

| 插件 | 许可证 | 来源 |
|---|---|---|
| `astrbot_plugin_worldbook` | GPL-3.0 | <https://github.com/Zhalslar/astrbot_plugin_worldbook> |
| `astrbot_plugin_qzone` | GPL-3.0 | <https://github.com/Zhalslar/astrbot_plugin_qzone> |
| `astrbot_plugin_group_chat_plus` | AGPL-3.0 | <https://github.com/Him666233/astrbot_plugin_group_chat_plus> |
| `astrbot_plugin_memory` | 无许可证（10★，已停更） | <https://github.com/Bluezeamer/astrbot_plugin_memory> |
| `astrbot_plugin_memory_beyond` | MIT | <https://github.com/AlanBacker/astrbot_plugin_memory_beyond> |

这些插件由使用者在 AstrBot 管理面板的插件市场中自行安装，本项目不包含其代码。
**在你依赖某个插件之前，请自行复核该插件仓库当前的许可证**——上表只是记录撰写时的状态。

## 5. DeepSeek API

- 由使用者自行注册并承担调用费用，受 <https://platform.deepseek.com> 的服务条款约束。

## 6. 示例人设「林小满」

`preset/persona/_示例人设-林小满.md` 与 `preset/worldbook/_示例世界书-满记.yaml`
是为演示格式而虚构的角色与店铺，与现实中的任何自然人、商户无关。可自由修改、替换、删除。

## 免责声明

本项目通过非官方协议接入 QQ，可能违反腾讯的服务条款，存在账号被限制、冻结或封禁的风险。

因使用本项目产生的任何账号、数据、法律或其他后果，由使用者自行承担。
