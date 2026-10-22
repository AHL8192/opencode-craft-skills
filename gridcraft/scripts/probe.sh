#!/usr/bin/env bash
# Check the installed GridCraft, its catalog and the MCP handshake.
# Read-only: does not launch the GUI or modify workbooks.
set -euo pipefail

PORT="${GRIDCRAFT_PORT:-7979}"

echo "== binaries =="
for bin in gridcraft gridcraft-cli; do
  p="$(command -v "$bin" 2>/dev/null || true)"
  if [[ -n "$p" ]]; then
    printf '%s\t%s\n' "$bin" "$p"
    dpkg -S "$p" 2>/dev/null || true
  else
    echo "$bin: MISSING"
  fi
done
echo
echo "== versions =="
gridcraft --version 2>/dev/null || true
gridcraft-cli version 2>/dev/null || true
dpkg-query -W -f='${Package} ${Version}\n' gridcraft 2>/dev/null || true

echo
echo "== config and log =="
for f in "$HOME/.config/gridcraft" "$HOME/.config/gridcraft/logs/gridcraft.log"; do
  if [[ -e "$f" ]]; then ls -ld "$f"; else echo "missing: $f"; fi
done

echo
echo "== control channel (port $PORT) =="
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "listening on 127.0.0.1:$PORT (no authentication)"
  timeout 8 gridcraft-cli send "$PORT" ui.inspect 2>/dev/null |
    python3 -c 'import json,sys; d=json.load(sys.stdin); print("mode:",d.get("mode"),"window:",d.get("window"),"docs:",[x.get("title") for x in d.get("documents",[])])' 2>/dev/null ||
    echo "control port open but ui.inspect did not return JSON"
else
  echo "not running (start with: gridcraft --control $PORT &)"
fi

echo
echo "== MCP headless handshake =="
python3 - <<'PY'
import json, subprocess, sys
p = subprocess.Popen(["gridcraft-cli", "mcp"], stdin=subprocess.PIPE,
                     stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                     text=True, bufsize=1)
n = 1

def send(method, params=None, notify=False):
    global n
    msg = {"jsonrpc": "2.0", "method": method}
    if params is not None:
        msg["params"] = params
    if not notify:
        msg["id"] = n
        n += 1
    p.stdin.write(json.dumps(msg) + "\n")
    p.stdin.flush()
    if notify:
        return None
    while True:
        line = p.stdout.readline()
        if not line:
            err = p.stderr.read()[:800]
            raise RuntimeError("server closed: " + err)
        try:
            reply = json.loads(line)
        except json.JSONDecodeError:
            continue
        if reply.get("id") == msg["id"]:
            return reply

try:
    init = send("initialize", {"protocolVersion": "2025-06-18",
                               "capabilities": {},
                               "clientInfo": {"name": "gridcraft-probe", "version": "1"}})
    send("notifications/initialized", None, notify=True)
    tools = send("tools/list", {})["result"]["tools"]
    resources = send("resources/list", {}).get("result", {}).get("resources", [])
    wb = send("tools/call", {"name": "inspect_workbook", "arguments": {}})
    result = wb.get("result", {})
    content = result.get("content") or []
    data = json.loads(content[0]["text"]) if content else {}
    print("serverInfo:", json.dumps(init["result"].get("serverInfo"), ensure_ascii=False))
    print("protocol:", init["result"].get("protocolVersion"))
    print("tools:", len(tools), "resources:", len(resources))
    print("workbook:", data.get("title"), "sheets:", [s.get("name") for s in data.get("sheets", [])])
    print("tool names:", ", ".join(t["name"] for t in tools))
finally:
    try:
        p.stdin.close()
    except Exception:
        pass
    p.terminate()
    try:
        p.wait(timeout=5)
    except Exception:
        p.kill()
PY

echo
echo "== catalog counts =="
CMDS="$(mktemp)"; FUNCS="$(mktemp)"
trap 'rm -f "$CMDS" "$FUNCS"' EXIT
gridcraft-cli commands --json > "$CMDS"
gridcraft-cli functions --json > "$FUNCS"
python3 - "$CMDS" "$FUNCS" <<'PY'
import collections, json, sys
cmds = json.load(open(sys.argv[1]))
funcs = json.load(open(sys.argv[2]))
ns = collections.Counter(c["id"].split(".")[0] for c in cmds)
print(f"commands: {len(cmds)} in {len(ns)} namespaces")
print("namespaces:", ", ".join(f"{k}={v}" for k, v in sorted(ns.items())))
print(f"functions: {len(funcs)}")
PY

echo
echo "== skill snapshot =="
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$SKILL_DIR/references/command-index.md" ]]; then
  grep -c '^- `[^`]*`' "$SKILL_DIR/references/command-index.md" |
    sed 's/^/snapshot commands: /'
else
  echo "missing references/command-index.md"
fi
