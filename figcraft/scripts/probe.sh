#!/usr/bin/env bash
# FigCraft environment + protocol probe. Read-only; starts no GUI.
# Usage: bash scripts/probe.sh
set -uo pipefail

echo "== when / host =="
date -Is
uname -srm
echo "session: XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-unset} DISPLAY=${DISPLAY:-unset} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-unset}"

echo
echo "== binaries =="
command -v figcraft figcraft-cli || true
figcraft --version 2>&1 | head -1
figcraft-cli --version 2>&1 | head -1
if command -v dpkg >/dev/null 2>&1; then
  dpkg -s figcraft 2>/dev/null | grep -E '^(Package|Version|Status):' || true
fi

echo
echo "== processes / ports =="
pgrep -af 'figcraft' | grep -v -e 'pgrep' -e 'scripts/probe.sh' || echo "no figcraft process running"
if command -v ss >/dev/null 2>&1; then
  ss -ltnp 2>/dev/null | grep -E ':(47801|7979|7981|7982|7983|7984|7990)\b' || echo "no Craft-app ports listening"
fi
free -m | head -2

echo
echo "== command catalog =="
CAT=$(mktemp /tmp/figcraft-catalog.XXXXXX.json)
figcraft-cli commands --json > "$CAT"
python3 - "$CAT" <<'PY'
import json, sys, collections
cs = json.load(open(sys.argv[1]))
ns = collections.Counter(c["id"].split(".")[0] for c in cs)
print("commands:", len(cs), " namespaces:", len(ns),
      " undoable:", sum(1 for c in cs if c.get("undoable")),
      " shortcuts:", sum(1 for c in cs if c.get("shortcut")))
print("top:", ", ".join(k + "=" + str(v) for k, v in ns.most_common(8)))
print("non-undoable:", sum(1 for c in cs if c.get("undoable") is False))
PY
rm -f "$CAT"

echo
echo "== MCP handshake (headless) =="
python3 - <<'PY'
import json, subprocess
p = subprocess.Popen(["figcraft-cli", "mcp"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     stderr=subprocess.PIPE, text=True, bufsize=1)
n = 0
def rpc(method, params=None):
    global n
    n += 1
    msg = {"jsonrpc": "2.0", "id": n, "method": method}
    if params is not None:
        msg["params"] = params
    p.stdin.write(json.dumps(msg) + "\n")
    p.stdin.flush()
    while True:
        line = p.stdout.readline()
        if not line:
            raise SystemExit("no reply: " + p.stderr.read()[:300])
        try:
            rep = json.loads(line)
        except json.JSONDecodeError:
            continue
        if rep.get("id") == n:
            return rep
try:
    init = rpc("initialize", {"protocolVersion": "2025-06-18", "capabilities": {},
                              "clientInfo": {"name": "figcraft-probe", "version": "1"}})
    p.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized"}) + "\n")
    p.stdin.flush()
    si = init["result"]["serverInfo"]
    print("server:", si["name"], si["version"], " protocol:", init["result"]["protocolVersion"])
    tools = [t["name"] for t in rpc("tools/list", {})["result"]["tools"]]
    res = [r["uri"] for r in rpc("resources/list", {})["result"]["resources"]]
    prompts = [x["name"] for x in rpc("prompts/list", {})["result"]["prompts"]]
    print("tools:", len(tools), " resources:", ", ".join(res), " prompts:", ", ".join(prompts))
    print("tool names:", ", ".join(tools))
    rep = rpc("tools/call", {"name": "run_command",
                             "arguments": {"command": "template.list", "params": {}}})
    tpl = json.loads(rep["result"]["content"][0]["text"])
    print("templates:", len(tpl), " ids:", ", ".join(t["id"] for t in tpl))
    rep = rpc("tools/call", {"name": "run_command",
                             "arguments": {"command": "page.list", "params": {}}})
    print("headless empty document page.list:", rep["result"]["content"][0]["text"].strip()[:120])
finally:
    try:
        p.stdin.close()
    except Exception:
        pass
    try:
        p.wait(timeout=5)
    except Exception:
        p.kill()
PY

echo
echo "== filter check (literal substring) =="
printf 'filter "auto layout": '
figcraft-cli commands --filter 'auto layout' | wc -l
printf 'filter "autoLayout":  '
figcraft-cli commands --filter 'autoLayout' | wc -l
