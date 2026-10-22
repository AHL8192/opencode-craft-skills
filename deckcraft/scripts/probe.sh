#!/usr/bin/env bash
# Check the installed DeckCraft, its command surface, and the MCP handshake.
set -euo pipefail

PORT="${DECKCRAFT_PORT:-7990}"
echo "== binaries =="
command -v deckcraft || true
command -v deckcraft-cli || true
deckcraft --version 2>/dev/null | head -1 || true
deckcraft-cli --version 2>/dev/null | head -1 || true

echo
echo "== package =="
dpkg -s deckcraft 2>/dev/null | awk -F': ' '/^(Package|Version|Status):/{print $1": "$2}' || true

echo
echo "== processes and ports (79xx) =="
pgrep -af 'deckcraft' | grep -v pgrep || echo "no deckcraft process"
ss -ltn 2>/dev/null | awk -v p=":$PORT" '$4 ~ p {print "listening: "$4}' || true
ss -ltn 2>/dev/null | awk 'NR>1 && $4 ~ /:79[0-9][0-9]$/ {print "79xx: "$4}' || true
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "control channel: up on $PORT (open it with: deckcraft-cli mcp --connect 127.0.0.1:$PORT)"
else
  echo "control channel: down (start with: deckcraft --control $PORT &)"
fi
echo "note: the control server has no auth token in 0.9.0; it binds 127.0.0.1 only."

echo
echo "== MCP headless handshake =="
python3 - <<'PY'
import json, subprocess, sys
msgs = [
    {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18",
     "capabilities":{},"clientInfo":{"name":"probe","version":"1"}}},
    {"jsonrpc":"2.0","method":"notifications/initialized"},
    {"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}},
    {"jsonrpc":"2.0","id":3,"method":"resources/list","params":{}},
]
try:
    p = subprocess.Popen(["deckcraft-cli","mcp"], stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = p.communicate(input="\n".join(json.dumps(m) for m in msgs)+"\n", timeout=40)
except Exception as e:
    print("FAILED:", e); sys.exit(1)
tools = resources = None
for line in out.splitlines():
    try: m = json.loads(line)
    except Exception: continue
    if m.get("id") == 1:
        si = m.get("result", {}).get("serverInfo", {})
        print(f"server: {si.get('name')} {si.get('version')} protocol={m.get('result',{}).get('protocolVersion')}")
    if m.get("id") == 2: tools = m.get("result", {}).get("tools", [])
    if m.get("id") == 3: resources = m.get("result", {}).get("resources", [])
if tools is None:
    print("FAILED: no tools/list reply"); print(err[:400]); sys.exit(1)
print(f"tools: {len(tools)} -> " + ", ".join(t["name"] for t in tools))
print(f"resources: {len(resources or [])} -> " + ", ".join(r.get("uri","") for r in (resources or [])))
PY

echo
echo "== commands =="
TMP="$(mktemp)"
deckcraft-cli commands > "$TMP"
python3 - "$TMP" <<'PY'
import sys, collections
lines = [l for l in open(sys.argv[1], encoding="utf-8") if l.strip()]
ns = collections.Counter(l.split(".")[0] for l in lines)
print(f"commands: {len(lines)} in {len(ns)} namespaces")
print("largest: " + ", ".join(f"{k}={v}" for k, v in ns.most_common(10)))
PY
rm -f "$TMP"

echo
echo "== sample deck =="
deckcraft-cli run --sample --print --cmd 'document.inspect' 2>/dev/null > /tmp/deckcraft-probe-sample.txt || true
python3 - <<'PY2' || true
import json
raw = open('/tmp/deckcraft-probe-sample.txt', encoding='utf-8').read().split('→', 1)[-1].strip()
d = json.loads(raw)
print(f"sample: {len(d['slides'])} slides, {d.get('slideSize')}, theme fonts {d.get('fonts')}")
PY2
rm -f /tmp/deckcraft-probe-sample.txt

echo
echo "OK"
