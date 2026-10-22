#!/usr/bin/env bash
# probe.sh — report the installed PdfCraft surface. Read-only.
set -u

say() { printf '\n== %s ==\n' "$1"; }

say "versions"
pdfcraft --version 2>&1 || true
pdfcraft-cli --version 2>&1 || true
dpkg -s pdfcraft 2>/dev/null | grep -E '^(Status|Version):' || true
command -v pdfcraft pdfcraft-cli

say "tools (full / compact)"
pdfcraft-cli tools 2>/dev/null | python3 -c '
import json,sys
d=json.load(sys.stdin); ts=d.get("tools",d) if isinstance(d,dict) else d
print("full tools:",len(ts))
print("mapped to commands:",sum(1 for t in ts if t.get("command")))
' || echo "tool listing failed"

python3 - <<'PY' 2>/dev/null || echo "compact handshake failed"
import json, subprocess
p = subprocess.Popen(["pdfcraft-cli","mcp","--compact"], stdin=subprocess.PIPE,
                     stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
def send(o): p.stdin.write(json.dumps(o)+"\n"); p.stdin.flush()
def reply(i):
    while True:
        line = p.stdout.readline()
        if not line: raise SystemExit("server closed")
        try: m = json.loads(line)
        except Exception: continue
        if m.get("id") == i: return m
send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}})
info = reply(1).get("result",{}).get("serverInfo",{})
send({"jsonrpc":"2.0","method":"notifications/initialized"})
send({"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}})
tools = reply(2).get("result",{}).get("tools",[])
print("server:", info)
print("compact tools:", len(tools))
print("names:", ", ".join(t["name"] for t in tools))
p.stdin.close(); p.wait(timeout=5)
PY

say "command registry"
python3 - <<'PY' 2>/dev/null || echo "registry probe failed"
import json, subprocess
p = subprocess.Popen(["pdfcraft-cli","mcp"], stdin=subprocess.PIPE,
                     stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
def send(o): p.stdin.write(json.dumps(o)+"\n"); p.stdin.flush()
def reply(i):
    while True:
        line = p.stdout.readline()
        if not line: raise SystemExit("server closed")
        try: m = json.loads(line)
        except Exception: continue
        if m.get("id") == i: return m
send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}})
reply(1)
send({"jsonrpc":"2.0","method":"notifications/initialized"})
send({"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"command_list","arguments":{}}})
r = reply(2)
content = (r.get("result") or {}).get("content") or []
text = content[0].get("text","") if content else ""
try:
    cmds = json.loads(text).get("commands", [])
    print("commands:", len(cmds))
    print("namespaces:", len({c["id"].split(".")[0] for c in cmds}))
except Exception:
    print("registry payload unreadable:", text[:200])
p.stdin.close(); p.wait(timeout=5)
PY

say "control files and processes"
ls -l ~/.config/pdfcraft/control-*.json 2>/dev/null || echo "no control files"
pgrep -af 'pdfcraft( |$)|pdfcraft-cli' | grep -v pgrep || true

say "OCR"
pdfcraft-cli tools >/dev/null 2>&1 && echo "CLI OK"
dpkg -L pdfcraft 2>/dev/null | grep -q "/models/" && echo "models shipped in /usr/share/pdfcraft/models" || echo "no models in the package (OCR may fetch them)"
