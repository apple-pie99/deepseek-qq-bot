# 世界书插件 · 真实 schema（已核实）

> 记录时间：2026-10-23 · 依据：`Zhalslar/astrbot_plugin_worldbook` 仓库 README 字段表
> + 内置 `default_lorebook.yaml` 原文。这是 `preset/worldbook/` 与 [docs/世界书.md](../世界书.md) 的事实来源。

来源：`Zhalslar/astrbot_plugin_worldbook` 仓库 README 字段表 + 内置 `default_lorebook.yaml`（main 分支原文）

## 结构

顶层是 **YAML 列表**（每项以 `- ` 开头），不是字典。

## 字段

| 字段 | 必填 | 说明 |
|---|---|---|
| `name` | 是 | 唯一名称；keywords 为空时自动当触发词 |
| `content` | 是 | 命中后注入的设定正文。**早期样例误写成 inject，已更正** |
| `keywords` | 否 | 关键词或正则，命中才可能激活 |
| `enabled` | 否 | 总开关，false 完全不参与判断 |
| `priority` | 否 | 数字越小越靠前、约束越强；通用 30~60，强规则 0~20 |
| `scope` | 否 | 列表，限定用户/群/会话，如 `["admin"]` |
| `cron` | 否 | 定时点名；**不是直接生效**，下一条消息才尝试 |
| `duration` | 否 | 生效秒数，0 = 永久 |
| `times` | 否 | 单周期最多注入次数，0 = 不限 |
| `probability` | 否 | 最终生效概率 0~1 |
| `template` | 否 | default / resident(常驻) / chance / user / group |

## 变量

`{user_id}` · `{user_name}` · `{time}`
写错的变量会原样保留且不报错 → 必须核对拼写。

## 激活模型

- 激活资格（满足其一）：keywords 命中 / cron 到点
- 激活门禁（必须全过）：enabled → scope → duration → times → probability（最后判）

## 对本项目的意义

插件配置项里可以填「世界书路径」指向一个 yaml，重载插件即加载。
→ 仓库里预置一份 `preset/worldbook/_示例世界书-满记.yaml`，使用者改路径即可，不必在群里逐条敲命令。

未实测：该配置项在 `data/config/` 下的确切文件名与键名（不同插件版本可能变）。
遇到问题以插件 README 为准。
