#!/usr/bin/env bash
# dump-commands.sh — snapshot tool schemas and the command registry for diffing.
# Writes to /tmp/opencode/pdfcraft-skill/ (override with OUT=...).
set -euo pipefail
OUT="${OUT:-/tmp/opencode/pdfcraft-skill}"
mkdir -p "$OUT"

{
  printf 'pdfcraft: '; pdfcraft --version
  printf 'pdfcraft-cli: '; pdfcraft-cli --version
  printf 'package: '; dpkg -s pdfcraft 2>/dev/null | awk '/^Version:/{print $2}'
  printf 'date: '; date -Is
} > "$OUT/versions.txt"

pdfcraft-cli tools > "$OUT/tools.json"

python3 - "$OUT/commands.json" <<'PY'
import json, subprocess, sys
out = sys.argv[1]
p = subprocess.Popen(["pdfcraft-cli","mcp"], stdin=subprocess.PIPE,
                     stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
def send(o): p.stdin.write(json.dumps(o)+"\n"); p.stdin.flush()
def reply(i):
    while True:
        line = p.stdout.readline()
        if not line: raise SystemExit("server closed before reply")
        try: m = json.loads(line)
        except Exception: continue
        if m.get("id") == i: return m
send({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"dump","version":"1"}}})
reply(1)
send({"jsonrpc":"2.0","method":"notifications/initialized"})
send({"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"command_list","arguments":{}}})
r = reply(2)
content = (r.get("result") or {}).get("content") or []
text = content[0].get("text","") if content else ""
data = json.loads(text)
json.dump(data, open(out,"w"), indent=1)
p.stdin.close(); p.wait(timeout=5)
print("commands:", len(data.get("commands", [])))
PY

python3 - "$OUT" <<'PY'
import json,sys,os
out=sys.argv[1]
t=json.load(open(os.path.join(out,"tools.json")))
ts=t.get("tools",t) if isinstance(t,dict) else t
c=json.load(open(os.path.join(out,"commands.json"))).get("commands",[])
print("tools:",len(ts),"mapped:",sum(1 for x in ts if x.get("command")),"commands:",len(c))
PY

printf 'snapshot written to %s\n' "$OUT"
printf 'To refresh the skill references, rebuild commands.md and command-index.md from these files.\n'
