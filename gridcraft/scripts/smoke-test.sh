#!/usr/bin/env bash
# Minimal end-to-end proof of the installed GridCraft CLI/MCP stack.
# Writes only under a fresh temporary directory and prints PASS/FAIL.
set -euo pipefail

TMP="$(mktemp -d /tmp/gridcraft-smoke.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

gridcraft-cli version >/dev/null || fail "gridcraft-cli missing"

gridcraft-cli run --sample budget \
  --cmd 'cell.set={"cell":"A1","input":1}' \
  --cmd 'cell.set={"cell":"A2","input":2}' \
  --cmd 'cell.set={"cell":"A3","input":3}' \
  --cmd 'cell.set={"cell":"Z1","input":"=SUM(A1:A3)"}' \
  --out "$TMP/smoke.xlsx" --print Z1 --quiet
[[ -s "$TMP/smoke.xlsx" ]] || fail "run did not write smoke.xlsx"

VALUE="$(gridcraft-cli cat "$TMP/smoke.xlsx" --range Z1 2>/dev/null | tr -d '[:space:]')"
[[ "$VALUE" == "6" ]] || fail "Z1 was '$VALUE', expected 6"

gridcraft-cli check "$TMP/smoke.xlsx" --json > "$TMP/check.json"
python3 - "$TMP/check.json" <<'PY' || exit 1
import json, sys
d = json.load(open(sys.argv[1]))
f = d["files"][0]
if not f.get("opened"):
    raise SystemExit("file did not open")
if f.get("error"):
    raise SystemExit(f"check error: {f['error']}")
if f["roundTrip"]["differing"]:
    raise SystemExit("round-trip differences: " + ", ".join(f["roundTrip"]["differing"]))
if f["calc"].get("mismatched"):
    raise SystemExit(f"formula mismatches: {f['calc']['mismatched']}")
print("smoke: PASS — Z1=6, check exit 0, no round-trip differences")
PY
