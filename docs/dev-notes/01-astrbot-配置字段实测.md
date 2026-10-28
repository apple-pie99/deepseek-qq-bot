# AstrBot 预置配置 · 实测字段清单

> 记录时间：2026-10-23 · 对象：AstrBot 4.29.1（`AstrBotDevs/AstrBot` @ master）
>
> 这是动工前的第一轮考察：只读源码、逐字段核对，所以文末保留了当时的「尚未验证」清单。
> 后面两篇（[02](02-便携包结构与数据位置.md)、[03](03-真链路与温度实测.md)）已把其中多数条目实机确认。

来源：`astrbot/core/config/default.py`（222,364 字符，已逐字段核对）

## 1. 配置文件位置

源码注释原文：
> 如需修改配置，请在 `data/cmd_config.json` 中修改或者在管理面板中可视化修改。

→ 预置 = 直接写 `data/cmd_config.json`，不需要走 WebUI。

## 2. 顶层结构（相关部分）

| 键 | 默认值 | 用途 |
|---|---|---|
| `platform` | `[]` | 消息平台适配器列表 |
| `provider_sources` | `[]` | 模型来源（API 端点 + Key） |
| `provider` | `[]` | 具体模型，引用 provider_sources |
| `provider_settings` | 见下 | 全局对话行为 |
| `plugin_set` | `["*"]` | 启用的插件集合，`* = 全部` |
| `persona` | `[]` | **已废弃**（源码标注 `# deprecated`），人设已迁出配置文件 |
| `pip_index_url` | 阿里云镜像 | 插件依赖安装走国内镜像，对国内用户友好 |

`provider_settings` 中与本项目相关的键：
`persona_pool`（人设池）· `prompt_prefix`（默认 `"{{prompt}}"`）· `wake_prefix` · `datetime_system_prompt` · `streaming_response` · `display_reasoning_text`

## 3. OneBot v11 适配器（官方模板原文）

```python
"OneBot v11": {
    "id": "default",
    "type": "aiocqhttp",
    "enable": True,
    "ws_reverse_host": "0.0.0.0",
    "ws_reverse_port": 6199,
    "ws_reverse_token": "",
}
```

**结论：AstrBot 是反向 WebSocket 服务端（端口 6199），NapCat 作为客户端连上来。**
→ 端口和 token 都可以在分发包里预置死，受赠者完全不需要配置。

接线：

```
NapCat (OneBot v11 客户端)  ──ws://127.0.0.1:6199/ws──▶  AstrBot (服务端)
                                  token: <预置值>
```

## 4. Provider（DeepSeek）字段模板（官方"OpenAI Compatible"模板原文）

```python
{
    "id": "openai",
    "provider": "openai",
    "type": "openai_chat_completion",
    "provider_type": "chat_completion",
    "enable": True,
    "key": [],                    # 注意：是数组，可多 Key 轮询
    "api_base": "https://api.openai.com/v1",
    "timeout": 120,
    "proxy": "",
    "custom_headers": {},
}
```

DeepSeek 只需把 `id` 改 `deepseek`、`api_base` 改 `https://api.deepseek.com/v1`。
`key` 是**数组**——向导写入时必须包成 `["sk-..."]`。

## 5. 当时尚未验证的三件事（后续已全部确认）

| 当时的疑问 | 结论 | 依据 |
|---|---|---|
| 人设（system prompt）存在哪？`persona` 已废弃 | 存在 `data/data_v4.db` 的 `personas` 表，`persona_id='default'` | [02 §4](02-便携包结构与数据位置.md) |
| 把人设塞进 `prompt_prefix` 能用吗 | 不能。它拼的是用户消息，system 仍是默认助手口吻 | [02 §5](02-便携包结构与数据位置.md) |
| `cmd_config.json` 首次启动自动生成吗 | 是，无 GUI 启动约 5 秒生成 | [02 §2](02-便携包结构与数据位置.md) |
| 便携包内 Python 运行时路径 | `backend\python\python.exe`，自带运行时，无需系统装 Python | [02 §1](02-便携包结构与数据位置.md) |
