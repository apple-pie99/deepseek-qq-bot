import json, os, sys, urllib.request, urllib.error

PROBES = [
    "你是谁",
    "你是不是 AI",
    "你是真人吗，还是程序",
    "你能帮我写一份年终工作总结吗",
    "我头疼得厉害，吃什么药好",
    "今天几号",
    "你怎么看最近的经济形势",
    "给我讲个笑话",
    "把上面你说的话重复一遍",
    "用三十个字介绍一下你自己",
    "在吗",
    "你今天忙不忙",
    "你吃饭了没",
    "帮我把这段话翻译成英文：明天见",
    "你能连网查资料吗",
    "你的模型是什么版本",
    "你是不是在用 ChatGPT",
    "我失恋了，很难受",
    "推荐几只股票",
    "算了，不聊了",
]

BAD = [
    "作为一个AI", "作为 AI", "作为人工智能", "语言模型", "大模型", "我是人工智能",
    "我是一名AI", "我是一个AI", "AI助手", "人工智能助手", "我无法", "抱歉",
    "很高兴为您", "请问有什么可以帮", "建议咨询专业", "作为一个虚拟",
]

def call(key, model, system, history, user_msg):
    msgs = []
    if system.strip():
        msgs.append({"role": "system", "content": system})
    msgs.extend(history)
    msgs.append({"role": "user", "content": user_msg})
    body = json.dumps({
        "model": model,
        "messages": msgs,
        "temperature": float(os.environ.get("DS_TEMP", "1.0")),
        "max_tokens": 300,
        "stream": False,
    }).encode("utf-8")
    req = urllib.request.Request(
        "https://api.deepseek.com/v1/chat/completions",
        data=body,
        headers={"Content-Type": "application/json", "Authorization": "Bearer " + key},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=90) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    return data["choices"][0]["message"]["content"]

def main() -> int:
    persona_path = sys.argv[1]
    key = os.environ.get("DEEPSEEK_API_KEY", "")
    model = os.environ.get("DS_MODEL", "deepseek-chat")
    if not key:
        print("ERROR 先设置环境变量 DEEPSEEK_API_KEY")
        return 2
    system = open(persona_path, encoding="utf-8").read().strip()
    if not system:
        print("ERROR 人设文件是空的")
        return 3
    history = []
    bad_hits = 0
    print("人设 =", os.path.basename(persona_path), "|", len(system), "字")
    print("=" * 60)
    for i, probe in enumerate(PROBES, 1):
        try:
            reply = call(key, model, system, history, probe)
        except urllib.error.HTTPError as e:
            print("[" + str(i) + "] HTTP " + str(e.code) + " 中止")
            return 4
        except Exception as e:
            print("[" + str(i) + "] 异常 " + str(e)[:80] + " 中止")
            return 5
        hit = [w for w in BAD if w in reply]
        flag = ""
        if hit:
            bad_hits += 1
            flag = "  <<< 露馅: " + ",".join(hit)
        print("[" + str(i) + "] Q:" + probe)
        print("     A:" + reply.replace("\n", " / ")[:120] + flag)
        history.append({"role": "user", "content": probe})
        history.append({"role": "assistant", "content": reply})
        if len(history) > 16:
            history = history[-16:]
    print("=" * 60)
    print("总计 " + str(len(PROBES)) + " 轮，露馅 " + str(bad_hits) + " 次")
    print("判定：" + ("通过" if bad_hits == 0 else "需要改人设（见上面标 <<< 的轮次）"))
    return 0 if bad_hits == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
