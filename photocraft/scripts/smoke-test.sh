#!/usr/bin/env bash
# End-to-end smoke test: create, edit, save, reopen, render, verify pixels.
# Usage: smoke-test.sh [--keep]
set -euo pipefail

KEEP=0
[[ "${1:-}" == "--keep" ]] && KEEP=1
PARENT="${PHOTOCRAFT_SMOKE_DIR:-/tmp/opencode}"
mkdir -p "$PARENT"
ROOT="$(mktemp -d "$PARENT/photocraft-smoke.XXXXXX")"
echo "work dir: $ROOT"

cleanup() {
  local rc=$?
  if [[ $rc -eq 0 && $KEEP -eq 0 ]]; then
    rm -rf "$ROOT"
  else
    echo "kept: $ROOT (exit $rc)"
  fi
}
trap cleanup EXIT

python3 - "$ROOT" <<'PY' > "$ROOT/result.json"
import json, subprocess, sys
root = sys.argv[1]
p = subprocess.Popen(["photocraft-cli", "mcp",
                      "--automation-read-root", root,
                      "--automation-write-root", root],
                     stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     stderr=subprocess.PIPE, text=True, bufsize=1)
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
            raise RuntimeError("MCP closed: " + p.stderr.read()[:400])
        m = json.loads(line)
        if m.get("id") == _id:
            return m
def tool(name, args=None):
    m = rpc("tools/call", {"name": name, "arguments": args or {}})
    res = m.get("result", {})
    txt = (res.get("content") or [{}])[0].get("text", "")
    if res.get("isError"):
        raise RuntimeError(f"{name}: {txt[:300]}")
    try:
        return json.loads(txt) if txt else None
    except json.JSONDecodeError:
        return txt

rpc("initialize", {"protocolVersion": "2024-11-05", "capabilities": {},
                   "clientInfo": {"name": "smoke", "version": "1"}})
p.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized"}) + "\n")
p.stdin.flush()

out = {}
out["new"] = tool("doc_new", {"width": 64, "height": 64, "background": "white"})
tool("command_run", {"id": "select.all", "params": {}})
out["fill"] = tool("command_run", {"id": "edit.fill",
                                   "params": {"contents": "color", "color": "#ff0000"}})
out["shape"] = tool("command_run", {"id": "shape.create",
                                    "params": {"kind": "ellipse", "rect": [8, 8, 20, 20],
                                               "fill": "#00ff00"}})
out["save_pcraft"] = tool("doc_save", {"path": "smoke.pcraft"})
d = tool("doc_inspect")
d = (d or {}).get("document") or d
out["layers_before"] = len(d.get("layers", []))
out["size_before"] = [d.get("width"), d.get("height")]
out["ids_before"] = [l["id"] for l in d.get("layers", [])]
tool("doc_close")
out["open"] = tool("doc_open", {"path": "smoke.pcraft"})
d = tool("doc_inspect")
d = (d or {}).get("document") or d
out["layers_after"] = len(d.get("layers", []))
out["ids_after"] = [l["id"] for l in d.get("layers", [])]
out["save_png"] = tool("doc_save", {"path": "smoke.png"})
out["session"] = tool("session_list")
print(json.dumps(out, indent=1))
p.stdin.close()
try: p.wait(timeout=10)
except Exception: p.kill()
PY

python3 - "$ROOT" <<'PY'
import json, sys
root = sys.argv[1]
r = json.load(open(root + "/result.json"))
fail = []
if r["layers_before"] != 2: fail.append(f"layers before reopen = {r['layers_before']} (want 2)")
if r["layers_after"] != 2: fail.append(f"layers after reopen = {r['layers_after']} (want 2)")
if r["ids_before"] != r["ids_after"]: fail.append(f"layer ids changed: {r['ids_before']} -> {r['ids_after']}")
if r["size_before"] != [64, 64]: fail.append(f"size = {r['size_before']}")
if r["save_pcraft"].get("warnings"): fail.append(f"pcraft warnings: {r['save_pcraft']['warnings']}")
if (r.get("fill") or {}).get("contents") != "color": fail.append(f"fill result: {r.get('fill')}")
if not r["shape"].get("layer"): fail.append(f"shape result: {r['shape']}")
print("bridge-free MCP session OK" if not fail else "FAILURES:")
for f in fail: print("  -", f)
sys.exit(1 if fail else 0)
PY

echo
echo "== file checks =="
identify -format 'smoke.png: %m %wx%h %z-bit\n' "$ROOT/smoke.png"
PX1="$(convert "$ROOT/smoke.png" -format '%[pixel:p{2,2}]' info:)"
PX2="$(convert "$ROOT/smoke.png" -format '%[pixel:p{14,14}]' info:)"
echo "pixel 2,2  = $PX1 (want red)"
echo "pixel 14,14= $PX2 (want green)"
[[ "$PX1" == "srgb(255,0,0)" ]] || { echo "FAIL: background pixel is not red"; exit 1; }
[[ "$PX2" == "srgb(0,255,0)" ]] || { echo "FAIL: ellipse pixel is not green"; exit 1; }

echo
echo "smoke test: PASS"
