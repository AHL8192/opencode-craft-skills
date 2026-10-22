#!/usr/bin/env bash
# End-to-end VectorCraft smoke test in a scratch directory (headless, no window).
# Usage: smoke-test.sh [DIR]   (default: mktemp -d)
# Creates, saves, exports, reopens and verifies; exits non-zero on failure.
set -euo pipefail

DIR="${1:-$(mktemp -d /tmp/vc-smoke.XXXXXX)}"
mkdir -p "$DIR"
[[ -e "$DIR/proof.vectorcraft" ]] && { echo "refusing to overwrite $DIR/proof.vectorcraft" >&2; exit 1; }

command -v vectorcraft-cli >/dev/null || { echo "vectorcraft-cli missing" >&2; exit 1; }
echo "== smoke test in $DIR =="
echo "vectorcraft-cli $(vectorcraft-cli --version | awk '{print $2}')"

# 1. create + save + export (engine command ids only)
vectorcraft-cli run \
  --cmd file.new --params '{"width":400,"height":300,"title":"smoke"}' \
  --cmd shape.rectangle --params '{"x":40,"y":40,"width":200,"height":120,"radius":8}' \
  --cmd paint.setFill --params '{"color":"#e8573f"}' \
  --cmd path.create --params '{"anchors":[{"x":260,"y":200},{"x":330,"y":200},{"x":295,"y":260}],"closed":true}' \
  --cmd paint.setFill --params '{"color":"#1f7ae0"}' \
  --cmd document.save --params "{\"path\":\"$DIR/proof.vectorcraft\"}" \
  --export "$DIR/proof.png" > "$DIR/run.jsonl"

for f in "$DIR/proof.vectorcraft" "$DIR/proof.png"; do
  [[ -s "$f" ]] || { echo "FAIL: $f missing or empty"; exit 1; }
done

# 2. independent checks
DIMS=$(identify -format '%wx%h' "$DIR/proof.png" 2>/dev/null || echo '?')
[[ "$DIMS" == "400x300" ]] || { echo "FAIL: PNG is $DIMS, expected 400x300"; exit 1; }
PIX=$(convert "$DIR/proof.png" -format '%[pixel:p{100,100}]' info: 2>/dev/null || echo '?')
echo "PNG: 400x300, pixel(100,100) = $PIX"
case "$PIX" in
  *232,87,63*) ;;
  *) echo "FAIL: expected the red rectangle at 100,100"; exit 1;;
esac

# 3. re-read and round-trip
vectorcraft-cli info "$DIR/proof.vectorcraft" > "$DIR/info.json"
python3 - "$DIR/info.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
assert d["info"]["title"] == "smoke", d["info"]["title"]
assert len(d["artboards"]) == 1, d["artboards"]
kinds = d["kinds"]
assert kinds.get("Rounded Rectangle") == 1, kinds
assert kinds.get("Path") == 1, kinds
assert d["warnings"] == [], d["warnings"]
print("info: title=smoke, 1 artboard, kinds =", kinds)
PY

vectorcraft-cli convert "$DIR/proof.vectorcraft" "$DIR/rt.pdf" >/dev/null
pdfinfo "$DIR/rt.pdf" | grep -q '^Pages:[[:space:]]*1' || { echo "FAIL: PDF page count"; exit 1; }
vectorcraft-cli convert "$DIR/proof.vectorcraft" "$DIR/rt.svg" >/dev/null
grep -q '<path' "$DIR/rt.svg" || { echo "FAIL: SVG has no paths"; exit 1; }

# 4. re-render the native round trip and compare
vectorcraft-cli convert "$DIR/proof.vectorcraft" "$DIR/rt.png" >/dev/null
convert "$DIR/proof.png" -background white -alpha remove -alpha off "$DIR/a.png"
convert "$DIR/rt.png" -background white -alpha remove -alpha off "$DIR/b.png"
RMSE=$(compare -metric RMSE "$DIR/a.png" "$DIR/b.png" null: 2>&1 | awk '{print $1}')
echo "native round-trip RMSE: $RMSE"

echo "PASS: $DIR"
