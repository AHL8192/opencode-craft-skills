#!/usr/bin/env bash
# Probe the FilmCraft MCP surface: version, handshake, tools, resources, commands.
# Usage: probe.sh [--bridge 127.0.0.1:PORT]
# Exit: 0 ok, 1 handshake/tool mismatch, 2 missing binary.
set -u

CLI=${FILMCRAFT_CLI:-filmcraft-cli}
command -v "$CLI" >/dev/null || { echo "probe: $CLI not found" >&2; exit 2; }

BRIDGE=()
if [ "${1:-}" = "--bridge" ] && [ -n "${2:-}" ]; then
  BRIDGE=(--bridge "$2")
fi

echo "filmcraft-cli: $("$CLI" --version 2>&1)"
[ -x /usr/bin/filmcraft ] && echo "filmcraft: $(/usr/bin/filmcraft --version 2>&1)"
echo "date: $(date -Is)"
[ ${#BRIDGE[@]} -gt 0 ] && echo "mode: bridge ${BRIDGE[1]}" || echo "mode: headless (--demo)"
echo

FILMCRAFT_MCP_ARGS="${BRIDGE[*]:-}" python3 - "$CLI" <<'PY'
import json, os, subprocess, sys

cli = sys.argv[1]
args = [cli, "mcp"]
extra = os.environ.get("FILMCRAFT_MCP_ARGS", "").split()
if extra:
    args += extra
else:
    args += ["--demo"]

p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     stderr=subprocess.PIPE, text=True)
n = 0
def send(method, params=None):
    global n
    n += 1
    msg = {"jsonrpc": "2.0", "id": n, "method": method}
    if params is not None:
        msg["params"] = params
    p.stdin.write(json.dumps(msg) + "\n"); p.stdin.flush()
    while True:
        line = p.stdout.readline()
        if not line:
            raise SystemExit("server closed: " + p.stderr.read(800))
        try:
            m = json.loads(line)
        except Exception:
            continue
        if m.get("id") == n:
            return m

try:
    init = send("initialize", {"protocolVersion": "2025-06-18", "capabilities": {},
                               "clientInfo": {"name": "filmcraft-probe", "version": "1"}})
    p.stdin.write(json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized"}) + "\n")
    p.stdin.flush()
    r = init.get("result", {})
    print("protocol:", r.get("protocolVersion"))
    si = r.get("serverInfo", {})
    print("server:", si.get("name"), si.get("version"))
    caps = sorted(r.get("capabilities", {}))
    print("capabilities:", ", ".join(caps) or "-")

    tools = send("tools/list", {})["result"]["tools"]
    names = sorted(t["name"] for t in tools)
    print(f"tools ({len(tools)}):", ", ".join(names))
    expected = {"command_list", "command_run", "command_batch", "doc_inspect",
                "project_inspect", "sequence_inspect", "media_import",
                "render_frame", "render_preview"}
    missing = expected - set(names)
    if missing:
        print("MISSING TOOLS:", ", ".join(sorted(missing)))

    res = send("resources/list", {})["result"].get("resources", [])
    print("resources:", ", ".join(x["uri"] for x in res) or "-")

    cmd = send("tools/call", {"name": "command_list", "arguments": {}})
    txt = cmd["result"]["content"][0]["text"]
    cmds = json.loads(txt)
    print("commands:", len(cmds))
    ns = {}
    for c in cmds:
        ns[c["id"].split(".")[0]] = ns.get(c["id"].split(".")[0], 0) + 1
    print("namespaces:", len(ns))
    if missing:
        raise SystemExit(1)
    print("PROBE OK")
finally:
    try:
        p.stdin.close(); p.wait(timeout=5)
    except Exception:
        p.kill()
PY
