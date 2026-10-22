#!/usr/bin/env bash
# Check the installed WordCraft, its command surface, and the MCP handshake.
set -euo pipefail

PORT="${WORDCRAFT_PORT:-7981}"
echo "== binaries =="
command -v wordcraft || true
command -v wordcraft-cli || true
wordcraft --version 2>/dev/null | head -1 || true
wordcraft-cli --version 2>/dev/null || true

echo
echo "== package =="
dpkg -s wordcraft 2>/dev/null | awk -F': ' '/^(Package|Version|Status):/{print $1": "$2}' || true

echo
echo "== control channel (port $PORT) =="
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "listening on $PORT"
  KEYFILE="$HOME/.config/wordcraft/control-key.local-$PORT"
  if [[ -f "$KEYFILE" ]]; then
    echo "key file: $KEYFILE ($(stat -c '%a' "$KEYFILE"))"
  else
    echo "key file missing: $KEYFILE"
  fi
else
  echo "not running (start with: wordcraft --control $PORT &)"
fi

echo
echo "== MCP headless handshake =="
python3 - <<'PY'
import json, subprocess, sys
msgs = [
    {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18",
     "capabilities":{},"clientInfo":{"name":"probe","version":"1"}}},
    {"jsonrpc":"2.0","method":"notifications/initialized"},
    {"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}},
]
try:
    p = subprocess.Popen(["wordcraft-cli","mcp"], stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = p.communicate(input="\n".join(json.dumps(m) for m in msgs)+"\n", timeout=25)
except Exception as e:
    print("FAILED:", e); sys.exit(1)
tools = None
for line in out.splitlines():
    try: m = json.loads(line)
    except Exception: continue
    if m.get("id") == 1:
        si = m.get("result", {}).get("serverInfo", {})
        print(f"server: {si.get('name')} {si.get('version')} protocol={m.get('result',{}).get('protocolVersion')}")
    if m.get("id") == 2:
        tools = m.get("result", {}).get("tools", [])
if tools is None:
    print("FAILED: no tools/list reply")
    print(err[:500]); sys.exit(1)
print(f"tools: {len(tools)} -> " + ", ".join(t["name"] for t in tools))
PY

echo
echo "== commands =="
TMP="$(mktemp)"
wordcraft-cli commands --json > "$TMP"
python3 - "$TMP" <<'PY'
import json, sys, collections
cmds = json.load(open(sys.argv[1]))
ns = collections.Counter(c["id"].split(".")[0] for c in cmds)
print(f"commands: {len(cmds)} in {len(ns)} namespaces")
print("largest: " + ", ".join(f"{k}={v}" for k, v in ns.most_common(8)))
print("macros: " + ", ".join(c["id"] for c in cmds if "macro" in c["id"].lower()))
PY
rm -f "$TMP"

echo
echo "== parity =="
wordcraft-cli parity 2>/dev/null | python3 -c 'import json,sys; d=json.load(sys.stdin); print("%s/%s live (%s%%)" % (d.get("live"), d.get("total", "?"), d.get("percent")))' || true

echo
echo "OK"
