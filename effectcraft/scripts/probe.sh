#!/usr/bin/env bash
# Verify the installed EffectCraft: versions, control channel, MCP handshake,
# command/effect counts and resources. Read-only; starts no GUI.
set -uo pipefail

PORT="${EFFECTCRAFT_PORT:-9877}"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== binaries =="
command -v effectcraft || true
command -v effectcraft-cli || true
effectcraft --version 2>&1 | head -1
effectcraft-cli --version 2>&1 | head -1

echo
echo "== package =="
dpkg -s effectcraft 2>/dev/null |
  awk -F': ' '/^(Package|Version|Status|Depends):/{print $1": "$2}' || true

echo
echo "== GUI control channel (port $PORT) =="
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "listening on $PORT"
  python3 - "$PORT" <<'PY'
import json, socket, sys
port = int(sys.argv[1])
try:
    s = socket.create_connection(("127.0.0.1", port), timeout=5)
    s.sendall(b'{"id":1,"method":"ui.inspect","params":{}}\n')
    buf = b""
    while b"\n" not in buf:
        buf += s.recv(65536)
    r = json.loads(buf.split(b"\n", 1)[0])
    if "error" in r:
        print("ui.inspect error:", r["error"])
    else:
        d = r["result"]
        print("window:", d.get("window"), "fps:", round(d.get("fps", 0), 1),
              "dialog:", d.get("dialog"), "activeComp:", d.get("activeComp"))
    s.close()
except Exception as e:
    print("control FAILED:", e)
PY
else
  echo "not running (start with: EFFECTCRAFT_CONFIG_DIR=/tmp/ec-agent effectcraft --control $PORT &)"
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
    {"jsonrpc":"2.0","id":3,"method":"resources/list","params":{}},
]
try:
    p = subprocess.Popen(["effectcraft-cli","mcp","--empty"], stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = p.communicate(input="\n".join(json.dumps(m) for m in msgs)+"\n", timeout=30)
except Exception as e:
    print("FAILED:", e); sys.exit(1)
tools = None
for line in out.splitlines():
    try: m = json.loads(line)
    except Exception: continue
    if m.get("id") == 1:
        si = m.get("result", {}).get("serverInfo", {})
        print(f"server: {si.get('name')} {si.get('version')} protocol={m.get('result',{}).get('protocolVersion')}")
    elif m.get("id") == 2:
        tools = m.get("result", {}).get("tools", [])
    elif m.get("id") == 3:
        rs = [r.get("uri") for r in m.get("result", {}).get("resources", [])]
        print("resources:", rs)
if tools is None:
    print("FAILED: no tools/list reply"); print(err[:500]); sys.exit(1)
print(f"tools: {len(tools)}")
print("  " + ", ".join(t["name"] for t in tools))
PY

echo
echo "== commands and effects =="
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT
effectcraft-cli commands --json > "$TMP"
python3 - "$TMP" <<'PY'
import json, sys, collections
cmds = json.load(open(sys.argv[1]))
ns = collections.Counter(c["id"].split(".")[0] for c in cmds)
print(f"commands: {len(cmds)} in {len(ns)} namespaces")
print("largest: " + ", ".join(f"{k}={v}" for k, v in ns.most_common(8)))
PY
python3 - <<'PY'
import json, subprocess
try:
    out = subprocess.run(["effectcraft-cli","info","--empty","--json"],
                         capture_output=True, text=True, timeout=40)
    d = json.loads(out.stdout)
    print(f"version: {d.get('version')}  commands: {d.get('commands')}  effects: {d.get('effects')}")
    p = d.get("project", {})
    print("renderer:", p.get("renderer", {}).get("renderer"), "| gpu:", p.get("renderer", {}).get("gpuAcceleration"))
except Exception as e:
    print("info FAILED:", e)
PY

echo
echo "== skill files =="
ls "$SKILL_DIR/references" "$SKILL_DIR/scripts" 2>/dev/null | sed 's/^/  /'
echo "SKILL.md bytes: $(wc -c < "$SKILL_DIR/SKILL.md") (limit 12000)"
echo "OK"
