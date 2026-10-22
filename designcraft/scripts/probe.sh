#!/usr/bin/env bash
# Check the installed DesignCraft, its command surface, MCP handshake and ports.
# Read-only: never launches the GUI (designcraft --help would!).
set -euo pipefail

PORT="${DESIGNCRAFT_PORT:-7984}"

echo "== binaries =="
command -v designcraft || true
command -v designcraft-cli || true
designcraft --version 2>/dev/null | head -1 || true
designcraft-cli --version 2>/dev/null || true

echo
echo "== package =="
dpkg -s designcraft 2>/dev/null | awk -F': ' '/^(Package|Version|Status|Architecture):/{print $1": "$2}' || true

echo
echo "== processes / ports =="
ps -eo pid,comm,args --no-headers | awk '$2=="designcraft" || $2=="designcraft-cli"' || true
ps -eo comm --no-headers | grep -qx designcraft || echo "no designcraft process"
ss -ltnp 2>/dev/null | grep -E ":(79[0-9][0-9])\b" || echo "no 79xx listeners"
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "port $PORT: listening (app bridge available)"
else
  echo "port $PORT: free (start with: DESIGNCRAFT_CONFIG_DIR=/tmp/dc-profile designcraft --control $PORT &)"
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
    p = subprocess.Popen(["designcraft-cli","mcp"], stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = p.communicate(input="\n".join(json.dumps(m) for m in msgs)+"\n", timeout=30)
except Exception as e:
    print("FAILED:", e); sys.exit(1)
tools = resources = None
for line in out.splitlines():
    try: m = json.loads(line)
    except Exception: continue
    if m.get("id") == 1:
        r = m.get("result", {}); si = r.get("serverInfo", {})
        print(f"server: {si.get('name')} {si.get('version')}  protocol={r.get('protocolVersion')}")
    if m.get("id") == 2:
        tools = m.get("result", {}).get("tools", [])
    if m.get("id") == 3:
        resources = m.get("result", {}).get("resources", [])
if tools is None:
    print("FAILED: no tools/list reply"); print(err[:500]); sys.exit(1)
print(f"tools: {len(tools)}")
print("  " + ", ".join(t["name"] for t in tools))
print(f"resources: {len(resources or [])} -> " + ", ".join(r.get("uri","?") for r in (resources or [])))
PY

echo
echo "== command catalog =="
TMP="$(mktemp)"
designcraft-cli commands > "$TMP"
python3 - "$TMP" <<'PY'
import json, sys, collections
cmds = json.load(open(sys.argv[1]))
ns = collections.Counter(c["id"].split(".")[0] for c in cmds)
print(f"commands: {len(cmds)} in {len(ns)} namespaces")
print("largest: " + ", ".join(f"{k}={v}" for k, v in ns.most_common(8)))
print(f"enabled right now: {sum(1 for c in cmds if c.get('enabled'))}")
print(f"with shortcuts: {sum(1 for c in cmds if c.get('shortcut'))}")
PY
rm -f "$TMP"

echo
echo "== app bridge (optional) =="
if ss -ltn 2>/dev/null | grep -q ":$PORT "; then
  echo "app document (requires an open document):"
  if designcraft-cli app --port "$PORT" document.inspect >/tmp/dc-probe-doc.json 2>/tmp/dc-probe-doc.err; then
    python3 -c 'import json;d=json.load(open("/tmp/dc-probe-doc.json"));print("app document:",d.get("title"),"pages:",d.get("pageCount"),"dirty:",d.get("dirty"))'
  else
    cat /tmp/dc-probe-doc.err
  fi
  echo "app window:"
  designcraft-cli app --port "$PORT" --method ui.inspect 2>/dev/null |
    python3 -c 'import json,sys;d=json.load(sys.stdin);print("window:",d.get("window"),"canvas:",d.get("canvasRect"),"fps:",round((d.get("perf") or {}).get("fps") or 0,1))' 2>/dev/null || echo "ui.inspect did not answer"
  echo "app commands:"
  designcraft-cli app --port "$PORT" --method engine.commands 2>/dev/null |
    python3 -c 'import json,sys;r=json.load(sys.stdin);print(len(r),"commands,",sum(1 for c in r if c.get("enabled")),"enabled right now")' 2>/dev/null || echo "engine.commands did not answer"
  rm -f /tmp/dc-probe-doc.json /tmp/dc-probe-doc.err
else
  echo "skipped (no app on $PORT)"
fi

echo
echo "OK"
