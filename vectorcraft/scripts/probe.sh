#!/usr/bin/env bash
# VectorCraft environment probe: binaries, package, ports, MCP handshake, catalogue sizes.
# Read-only. Safe to run while another craft app is open.
set -uo pipefail

PORT="${VECTORCRAFT_PORT:-7983}"

echo "== date/host =="
date -Is; hostname; uname -sr
echo

echo "== binaries =="
for b in vectorcraft vectorcraft-cli; do
  p="$(command -v "$b" 2>/dev/null || true)"
  if [[ -n "$p" ]]; then printf '%-16s %s\n' "$b" "$p"; else echo "$b MISSING"; fi
done
vectorcraft --version 2>/dev/null || true
vectorcraft-cli --version 2>/dev/null || true
echo

echo "== package =="
dpkg-query -W -f='${Package} ${Version} ${Status}\n' vectorcraft 2>/dev/null || \
  rpm -q vectorcraft 2>/dev/null || echo "(not installed through a package manager)"
echo

echo "== catalogue =="
N=$(vectorcraft-cli commands 2>/dev/null | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null || echo '?')
echo "vectorcraft-cli commands: $N ids"
echo

echo "== processes and port $PORT =="
pgrep -af '^([^ ]*/)?vectorcraft( |$)' || echo "no vectorcraft process"
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "port $PORT is LISTENING (a VectorCraft app or another service)"
  ss -ltnp 2>/dev/null | grep ":$PORT " || true
else
  echo "port $PORT is free"
fi
for p in 7979 7981 7983; do
  ss -ltn 2>/dev/null | grep -q ":$p " && echo "port $p busy"
done
echo

echo "== config =="
CFG="${VECTORCRAFT_CONFIG_DIR:-$HOME/.config/vectorcraft}"
echo "config dir: $CFG $([[ -d $CFG ]] && echo '(exists)' || echo '(missing)')"
ls "$CFG" 2>/dev/null | head -10 || true
echo

echo "== MCP headless handshake =="
python3 - "$PORT" <<'PY'
import json, subprocess, sys
msgs = [
    {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18",
     "capabilities":{},"clientInfo":{"name":"probe","version":"1"}}},
    {"jsonrpc":"2.0","method":"notifications/initialized","params":{}},
    {"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}},
    {"jsonrpc":"2.0","id":3,"method":"prompts/list","params":{}},
    {"jsonrpc":"2.0","id":4,"method":"resources/list","params":{}},
    {"jsonrpc":"2.0","id":5,"method":"resources/templates/list","params":{}},
]
try:
    p = subprocess.Popen(["vectorcraft-cli","mcp","--headless"], stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    p.stdin.write("\n".join(json.dumps(m) for m in msgs) + "\n"); p.stdin.flush()
    p.stdin.close()
    import time; time.sleep(1)
    out = p.stdout.read(); p.terminate()
except Exception as e:
    print("FAILED:", e); sys.exit(1)

seen = {}
for line in out.splitlines():
    try: m = json.loads(line)
    except Exception: continue
    if m.get("id") == 1:
        r = m.get("result", {})
        print("server:", r.get("serverInfo", {}).get("name"), r.get("serverInfo", {}).get("version"))
        print("protocol:", r.get("protocolVersion"))
    elif m.get("id") == 2:
        print("tools:", len(m.get("result", {}).get("tools", [])))
    elif m.get("id") == 3:
        print("prompts:", len(m.get("result", {}).get("prompts", [])))
    elif m.get("id") == 4:
        print("resources:", len(m.get("result", {}).get("resources", [])))
    elif m.get("id") == 5:
        print("resource templates:", len(m.get("result", {}).get("resourceTemplates", [])))
if not out.strip():
    print("no output (server failed to start)")
PY
