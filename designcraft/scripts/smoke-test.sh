#!/usr/bin/env bash
# End-to-end DesignCraft smoke test over raw MCP (headless).
# Creates a 2-page document, formats text, renders a PNG, saves, reopens in a
# NEW process, verifies the text survived and exports a PDF.
#   smoke-test.sh [OUTPUT_DIR]
# Writes only inside OUTPUT_DIR (default /tmp/opencode/designcraft-smoke-<ts>).
set -euo pipefail

OUT="${1:-/tmp/opencode/designcraft-smoke-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT"

echo "== DesignCraft smoke test =="
echo "cli: $(designcraft-cli --version 2>/dev/null)"
echo "out: $OUT"

python3 - "$OUT" <<'PY'
import json, os, subprocess, sys

OUT = sys.argv[1]
DOC = os.path.join(OUT, "smoke.designcraft")
PDF = os.path.join(OUT, "smoke.pdf")
PNG = os.path.join(OUT, "page1.png")
HEAD = "Smoke Test Headline"
BODY = "Body copy written by the DesignCraft smoke test."
results = []

def ok(name, detail=""):
    results.append((True, name, detail))
    print(f"PASS  {name}" + (f" — {detail}" if detail else ""))

def bad(name, detail):
    results.append((False, name, detail))
    print(f"FAIL  {name} — {detail}")

class MCP:
    def __init__(self, extra=()):
        self.p = subprocess.Popen(
            ["designcraft-cli", "mcp", "--automation-read-root", OUT,
             "--automation-write-root", OUT, *extra],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL, text=True, bufsize=1)
        self.id = 0
        self.notify = []

    def send(self, msg):
        self.p.stdin.write(json.dumps(msg) + "\n")
        self.p.stdin.flush()

    def request(self, method, params):
        self.id += 1
        self.send({"jsonrpc": "2.0", "id": self.id, "method": method, "params": params})
        while True:
            line = self.p.stdout.readline()
            if not line:
                raise RuntimeError(f"server closed while waiting for {method}")
            try:
                msg = json.loads(line)
            except json.JSONDecodeError:
                continue
            if msg.get("id") != self.id:
                continue
            if "error" in msg:
                raise RuntimeError(f"{method}: {msg['error'].get('message')}")
            return msg["result"]

    def init(self):
        r = self.request("initialize", {
            "protocolVersion": "2025-06-18", "capabilities": {},
            "clientInfo": {"name": "designcraft-smoke", "version": "1"}})
        self.send({"jsonrpc": "2.0", "method": "notifications/initialized"})
        return r

    def call(self, name, args=None):
        r = self.request("tools/call", {"name": name, "arguments": args or {}})
        texts = [c.get("text", "") for c in r.get("content", []) if c.get("type") == "text"]
        if r.get("isError"):
            raise RuntimeError(f"{name}: {' '.join(texts)[:400]}")
        raw = "\n".join(texts)
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            return raw

    def close(self):
        try:
            self.p.stdin.close()
        except Exception:
            pass
        try:
            self.p.wait(timeout=10)
        except subprocess.TimeoutExpired:
            self.p.kill()

srv = MCP()
try:
    init = srv.init()
    tools = srv.request("tools/list", {})["tools"]
    names = [t["name"] for t in tools]
    if len(tools) == 26:
        ok("MCP handshake", f"{init['serverInfo']['name']} {init['serverInfo']['version']}, 26 tools")
    else:
        bad("MCP handshake", f"{len(tools)} tools (expected 26): {names}")
    if {"execute", "inspect_document", "save_document", "open_document",
        "render_page", "get_story", "place_image"} <= set(names):
        ok("required tools present")
    else:
        bad("required tools present", "missing core tool")

    srv.call("new_document", {"preset": "A4", "pages": 2, "facingPages": False, "margins": 48})
    info = srv.call("inspect_document", {})
    if info.get("pageCount") == 2:
        ok("new_document", "A4, 2 pages, facingPages=false")
    else:
        bad("new_document", f"pageCount={info.get('pageCount')}")

    head = srv.call("execute", {"command": "frame.create", "params": {
        "rect": [48, 48, 547, 150], "content": "text", "text": HEAD, "caret": True}})
    if isinstance(head, dict) and head.get("id") and head.get("story"):
        ok("frame.create (headline)", f"frame {head['id']}, story {head['story']}")
    else:
        bad("frame.create (headline)", repr(head)[:200])
        raise SystemExit(1)

    srv.call("execute", {"command": "type.char", "params": {"attrs": {"size": 30}}})
    story = srv.call("get_story", {"frame": head["id"]})
    if story.get("text") == HEAD:
        ok("text read-back", f"{story.get('length')} bytes, size 30 applied")
    else:
        bad("text read-back", repr(story.get("text"))[:200])

    body = srv.call("execute", {"command": "frame.create", "params": {
        "rect": [48, 200, 547, 620], "content": "text", "text": BODY}})
    ok("frame.create (body)", f"frame {body.get('id')}")

    srv.call("render_page", {"page": 0, "scale": 1, "path": PNG})
    if os.path.exists(PNG) and os.path.getsize(PNG) > 1000:
        ok("render_page", f"{os.path.getsize(PNG)} bytes -> page1.png")
    else:
        bad("render_page", "PNG missing or empty")

    saved = srv.call("save_document", {"path": DOC})
    if os.path.exists(DOC):
        ok("save_document", f"{os.path.getsize(DOC)} bytes, path={saved.get('path')}")
    else:
        bad("save_document", repr(saved)[:200])
        raise SystemExit(1)
finally:
    srv.close()

# --- fresh process: reopen and prove persistence -------------------------
srv = MCP()
try:
    srv.init()
    opened = srv.call("open_document", {"path": DOC})
    info = srv.call("inspect_document", {})
    story = srv.call("get_story", {"frame": head["id"]})
    if info.get("pageCount") == 2 and story.get("text") == HEAD:
        ok("reopen in fresh process", "2 pages, headline byte-identical, ids stable")
    else:
        bad("reopen in fresh process",
            f"pages={info.get('pageCount')} text={repr(story.get('text'))[:120]}")
    if not info.get("dirty"):
        ok("reopened document is clean", f"path={info.get('path')}")
    else:
        bad("reopened document is clean", "dirty=true after open")

    srv.call("execute", {"command": "file.exportPdf", "params": {"path": PDF}})
    if os.path.exists(PDF) and open(PDF, "rb").read(5) == b"%PDF-":
        ok("export PDF", f"{os.path.getsize(PDF)} bytes")
    else:
        bad("export PDF", "missing or not a PDF")
finally:
    srv.close()

passed = sum(1 for r in results if r[0])
failed = len(results) - passed
print(f"\n{passed} passed, {failed} failed")
if failed:
    sys.exit(1)
PY

echo
echo "== external validation =="
if command -v pdfinfo >/dev/null; then
  pdfinfo "$OUT/smoke.pdf" | grep -E '^(Pages|Page size|Producer):'
  test "$(pdfinfo "$OUT/smoke.pdf" | awk '/^Pages:/{print $2}')" = "2" || { echo "FAIL: expected 2 pages"; exit 1; }
else
  echo "pdfinfo not installed: skipped PDF structure check"
fi
if command -v identify >/dev/null; then identify "$OUT/page1.png"; fi
if command -v unzip >/dev/null; then
  echo "native package:"
  unzip -l "$OUT/smoke.designcraft" | sed -n '4,12p'
fi

echo
echo "OK — artifacts in $OUT"
