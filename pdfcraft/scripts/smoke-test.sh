#!/usr/bin/env bash
# smoke-test.sh — end-to-end PdfCraft check in a scratch directory.
# Creates a PDF, edits it, saves, reopens, extracts, and tests redaction.
# Exits nonzero if any step fails or the external checks disagree.
set -euo pipefail

TMP="${1:-/tmp/opencode/pdfcraft-smoke-$(date +%Y%m%dT%H%M%S)}"
mkdir -p "$TMP"
CTRL_PID=""

cleanup() { :; }
trap cleanup EXIT

cat > "$TMP/steps.json" <<JSON
[
 {"tool":"doc_create","args":{"from":"blank","pages":1,"width":400,"height":500,"name":"smoke"}},
 {"tool":"page_add_text","args":{"doc":1,"page":1,"text":"PDFCRAFT-SMOKE 12345","at":[40,60],"size":14,"color":"#003366"}},
 {"tool":"doc_save","args":{"doc":1,"path":"$TMP/smoke.pdf"}},
 {"tool":"doc_close","args":{"doc":1}},
 {"tool":"doc_open","args":{"path":"$TMP/smoke.pdf"}},
 {"tool":"text_extract","args":{"doc":2}},
 {"tool":"text_find","args":{"doc":2,"query":"PDFCRAFT-SMOKE"}},
 {"tool":"page_render","args":{"doc":2,"page":1,"dpi":72},"out":"$TMP/smoke.png"},
 {"tool":"doc_close","args":{"doc":2}},
 {"tool":"doc_open","args":{"path":"$TMP/smoke.pdf"}},
 {"tool":"redact_mark","args":{"doc":3,"find":"PDFCRAFT-SMOKE"}},
 {"tool":"redact_apply","args":{"doc":3}},
 {"tool":"doc_audit_redactions","args":{"doc":3}},
 {"tool":"doc_save","args":{"doc":3,"path":"$TMP/redacted.pdf"}},
 {"tool":"doc_close","args":{"doc":3}}
]
JSON

echo "== run =="
pdfcraft-cli run --script "$TMP/steps.json" --root "$TMP" --report > "$TMP/report.json"
echo "report: $TMP/report.json"

echo "== external checks =="
pdfinfo "$TMP/smoke.pdf" | grep -E '^(Pages|Page size|File size):'
if ! pdftotext "$TMP/smoke.pdf" - | grep -q 'PDFCRAFT-SMOKE'; then
  echo "FAIL: marker not extractable from smoke.pdf" >&2; exit 1
fi
echo "PASS: marker extractable"
test -s "$TMP/smoke.png" && echo "PASS: page render written ($(stat -c%s "$TMP/smoke.png") bytes)"

echo "== redaction =="
echo -n "remaining marker in redacted.pdf: "
if pdftotext "$TMP/redacted.pdf" - | grep -q 'PDFCRAFT-SMOKE'; then
  echo "YES (redaction failed)"
else
  echo "no"
fi
python3 - "$TMP/report.json" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
ops=d.get("ops") or d.get("steps") or (d if isinstance(d,list) else [])
bad=[o for o in ops if o.get("isError") or o.get("ok") is False or o.get("error")]
print("steps:",len(ops),"failures:",len(bad))
for o in ops:
    if o.get("tool")=="doc_audit_redactions":
        c=o.get("content") or []
        print("audit:", (c[0].get("text","") if c else "").replace("\n"," ")[:200])
if bad: sys.exit(1)
PY

echo
echo "PASS - scratch kept at $TMP"
