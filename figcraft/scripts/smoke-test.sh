#!/usr/bin/env bash
# Headless end-to-end smoke test: build → save → info → render/export → validate → bad input.
# Usage: bash scripts/smoke-test.sh [work-dir]
set -uo pipefail

W=${1:-/tmp/opencode/figcraft-smoke-$$}
mkdir -p "$W"
FAIL=0
ok(){ echo "PASS  $1"; }
bad(){ echo "FAIL  $1"; FAIL=$((FAIL+1)); }
have(){ command -v "$1" >/dev/null 2>&1; }

echo "== work dir: $W =="
figcraft-cli --version | head -1

cat > "$W/build.json" <<'JSON'
[
 {"command":"node.create","params":{"type":"frame","name":"Smoke","x":0,"y":0,"width":320,"height":200,
   "props":{"fill":"#FFFFFF","cornerRadius":12}}},
 {"command":"node.create","params":{"type":"text","parent":{"$step":0},"x":24,"y":32,
   "text":"Hello FigCraft","props":{"fontSize":28,"fill":"#1B1B1B"}}},
 {"command":"node.create","params":{"type":"ellipse","parent":{"$step":0},"x":24,"y":96,
   "width":48,"height":48,"props":{"fill":"#7048E8"}}}
]
JSON

echo
echo "== run script =="
if figcraft-cli run "$W/build.json" --out "$W/smoke.figcraft" > "$W/run.log" 2>&1; then
  ok "run exited 0"
else
  bad "run failed"; sed -n '1,5p' "$W/run.log"
fi
grep -q '"ok":true' "$W/run.log" && ok "step results are ok:true" || bad "step results missing"
[ -s "$W/smoke.figcraft" ] && ok "output file exists" || bad "output file missing"

echo
echo "== info (independent read-back) =="
if figcraft-cli info "$W/smoke.figcraft" --json > "$W/info.json" 2> "$W/info.err"; then
  ok "info exited 0"
  python3 - "$W/info.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
n = d.get("nodes"); p = d.get("pages", [])
print("   name:", d.get("name"), "nodes:", n, "pages:", len(p), "styles:", d.get("styles"),
      "variables:", d.get("variables"), "missingFonts:", d.get("missingFonts"))
assert n == 4, f"expected 4 nodes, got {n}"
assert len(p) == 1, f"expected 1 page, got {len(p)}"
frames = p[0]["frames"]
assert frames and frames[0]["name"] == "Smoke" and frames[0]["width"] == 320, frames
PY
  [ $? -eq 0 ] && ok "info counts and frame size" || bad "info content wrong"
else
  bad "info failed"; head -3 "$W/info.err"
fi

echo
echo "== render / export / validate =="
figcraft-cli render "$W/smoke.figcraft" -o "$W/render.png" >/dev/null 2>&1 \
  && [ -s "$W/render.png" ] && ok "render produced a PNG" || bad "render failed"
figcraft-cli export "$W/smoke.figcraft" -o "$W/out" --scale 2 >/dev/null 2>&1
ls "$W/out" >/dev/null 2>&1 && [ "$(ls "$W/out" | wc -l)" -ge 1 ] \
  && ok "export directory has $(ls "$W/out" | wc -l) file(s)" || bad "export directory empty"
figcraft-cli export "$W/smoke.figcraft" -o "$W/smoke.svg" --node "Smoke" >/dev/null 2>&1 \
  && python3 -c 'import xml.etree.ElementTree as E,sys; E.parse(sys.argv[1])' "$W/smoke.svg" \
  && ok "SVG well-formed" || bad "SVG export/parse failed"
figcraft-cli export "$W/smoke.figcraft" -o "$W/smoke.pdf" >/dev/null 2>&1 \
  && [ -s "$W/smoke.pdf" ] && ok "PDF written ($(wc -c < "$W/smoke.pdf") bytes)" || bad "PDF export failed"

if have identify; then
  echo "   $(identify "$W/render.png" | head -1)"
fi
if have pdfinfo; then
  echo "   $(pdfinfo "$W/smoke.pdf" 2>/dev/null | grep -E '^(Pages|Page size):' | tr '\n' ' ')"
fi
if have file; then
  echo "   native: $(file -b "$W/smoke.figcraft")"
  echo "   svg:    $(file -b "$W/smoke.svg")"
fi

echo
echo "== convert round trip =="
figcraft-cli convert "$W/smoke.figcraft" "$W/smoke.json" >/dev/null 2>&1 \
  && python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print("   json pages:",len(d.get("pages",[])),"nodes:",len(d.get("nodes",{})))' "$W/smoke.json" \
  && ok "native → JSON" || bad "convert to JSON failed"
figcraft-cli convert "$W/smoke.json" "$W/back.figcraft" >/dev/null 2>&1 \
  && [ -s "$W/back.figcraft" ] && ok "JSON → native" || bad "convert back failed"

echo
echo "== failure behaviour =="
printf 'PK\003\004not a zip' > "$W/bad.figcraft"
if figcraft-cli info "$W/bad.figcraft" >/dev/null 2>&1; then
  bad "malformed file was accepted"
else
  ok "malformed file rejected (exit $?)"
fi
cat > "$W/fail.json" <<'JSON'
[{"command":"node.create","params":{"type":"frame","name":"Rollback","width":10,"height":10}},
 {"command":"node.set","params":{"ids":[99999],"opacity":0.5}}]
JSON
if figcraft-cli run "$W/fail.json" --out "$W/rollback.figcraft" >/dev/null 2>&1; then
  bad "failing script exited 0"
else
  ok "failing script exited non-zero"
fi
[ -e "$W/rollback.figcraft" ] && bad "failing script wrote an output file" \
  || ok "failing script wrote no output (rollback)"

echo
if [ "$FAIL" -eq 0 ]; then
  echo "SMOKE TEST PASSED — artefacts in $W"
else
  echo "SMOKE TEST FAILED — $FAIL check(s) failed — artefacts in $W"
  exit 1
fi
