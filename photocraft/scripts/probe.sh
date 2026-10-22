#!/usr/bin/env bash
# Probe the installed PhotoCraft: binaries, package, window, MCP surface, catalog.
# Usage: probe.sh [--no-app]
set -uo pipefail

PORT="${PHOTOCRAFT_PORT:-7878}"
TOKEN="${PHOTOCRAFT_TOKEN_FILE:-$HOME/.config/photocraft/control-$PORT.token}"
CHECK_APP=1
[[ "${1:-}" == "--no-app" ]] && CHECK_APP=0

echo "== binaries =="
command -v photocraft || true
command -v photocraft-cli || true
photocraft --version 2>&1 | head -1 || true
photocraft-cli version 2>&1 | head -1 || true

echo
echo "== package =="
dpkg-query -W -f='${Package} ${Version} (${Status})\n' photocraft 2>/dev/null \
  || rpm -q photocraft 2>/dev/null \
  || echo "not installed through a known package manager"

echo
echo "== config =="
CFG="${PHOTOCRAFT_CONFIG_DIR:-$HOME/.config/photocraft}"
if [[ -d "$CFG" ]]; then
  echo "config dir: $CFG"
  ls -l "$CFG" 2>/dev/null | head -6
else
  echo "no config dir at $CFG (first launch creates it)"
fi
if [[ -f "$TOKEN" ]]; then
  echo "token: $TOKEN mode=$(stat -c '%a' "$TOKEN")"
else
  echo "token: missing ($TOKEN) — the bridge needs --control-token-file"
fi

echo
echo "== desktop control channel (port $PORT) =="
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "listening on 127.0.0.1:$PORT"
  if [[ $CHECK_APP -eq 1 && -f "$TOKEN" ]]; then
    python3 - "$PORT" "$TOKEN" <<'PY'
import json, socket, sys
port, tokf = int(sys.argv[1]), sys.argv[2]
tok = open(tokf).read().strip()
s = socket.create_connection(("127.0.0.1", port), timeout=10)
f = s.makefile("rw")
def call(i, m, p=None):
    msg = {"id": i, "method": m}
    if p is not None: msg["params"] = p
    f.write(json.dumps(msg) + "\n"); f.flush()
    return json.loads(f.readline())
r = call(0, "auth", {"token": tok})
if not r.get("ok"):
    print("auth failed:", r.get("error")); sys.exit(0)
ins = call(1, "ui.inspect", {})
if not ins.get("ok"):
    print("ui.inspect failed:", ins.get("error")); sys.exit(0)
r = ins["result"]
doc = r.get("document") or {}
print(f"tool={r.get('tool')} window={r.get('window',{}).get('width')}x{r.get('window',{}).get('height')}")
print(f"document={doc.get('name')} {doc.get('width')}x{doc.get('height')} layers={len(doc.get('layers',[]))}")
print(f"panels={len(r.get('panels',[]))} dialogs={len(r.get('dialogs',[]))}")
PY
  fi
else
  echo "not running"
  echo "start: photocraft --control $PORT --control-token-file \"$TOKEN\" &"
fi

echo
echo "== MCP headless handshake (no roots) =="
python3 - <<'PY'
import json, subprocess, sys

p = subprocess.Popen(["photocraft-cli", "mcp"], stdin=subprocess.PIPE,
                     stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                     text=True, bufsize=1)
_id = 0
def rpc(method, params=None):
    global _id
    _id += 1
    msg = {"jsonrpc": "2.0", "id": _id, "method": method}
    if params is not None: msg["params"] = params
    p.stdin.write(json.dumps(msg) + "\n"); p.stdin.flush()
    while True:
        line = p.stdout.readline()
        if not line:
            print("FAILED: server closed:", p.stderr.read()[:300]); sys.exit(1)
        m = json.loads(line)
        if m.get("id") == _id: return m

r = rpc("initialize", {"protocolVersion": "2024-11-05", "capabilities": {},
                       "clientInfo": {"name": "probe", "version": "1"}})["result"]
print(f"server: {r['serverInfo']['name']} {r['serverInfo']['version']} protocol={r['protocolVersion']}")
p.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized"}) + "\n"); p.stdin.flush()
tools = rpc("tools/list")["result"]["tools"]
res = rpc("resources/list")["result"]["resources"]
print(f"tools: {len(tools)}")
print("  " + ", ".join(t["name"] for t in tools))
print(f"resources: {len(res)} -> " + ", ".join(x["uri"] for x in res))
rpc("tools/call", {"name": "doc_new", "arguments": {"width": 8, "height": 8}})
r = rpc("tools/call", {"name": "doc_save", "arguments": {"path": "probe.png"}})["result"]
txt = (r.get("content") or [{}])[0].get("text", "")
print(f"write without roots: isError={r.get('isError')} msg={txt[:120]}")
p.stdin.close()
try: p.wait(timeout=10)
except Exception: p.kill()
PY

echo
echo "== command catalog =="
TMP="$(mktemp)"
if photocraft-cli commands --json > "$TMP" 2>/dev/null; then
  python3 - "$TMP" <<'PY'
import json, sys, collections
cmds = json.load(open(sys.argv[1]))
ns = collections.Counter(c["id"].split(".")[0] for c in cmds)
print(f"commands: {len(cmds)} in {len(ns)} namespaces")
print("largest: " + ", ".join(f"{k}={v}" for k, v in ns.most_common(8)))
print("shortcuts: " + str(sum(1 for c in cmds if c.get("shortcut"))))
print("needsDocument: " + str(sum(1 for c in cmds if c.get("needsDocument"))))
PY
else
  echo "photocraft-cli commands --json failed"
fi
rm -f "$TMP"

echo
echo "OK"
