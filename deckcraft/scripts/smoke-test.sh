#!/usr/bin/env bash
# Minimal end-to-end proof: build a deck, read it back, save, convert, validate.
# Headless only. Writes to a throwaway folder and prints it.
set -euo pipefail

DIR="${1:-$(mktemp -d /tmp/opencode/deckcraft-smoke.XXXXXX)}"
mkdir -p "$DIR"
DECK="$DIR/smoke.deckcraft"
PPTX="$DIR/smoke.pptx"
PDF="$DIR/smoke.pdf"

echo "== build =="
deckcraft-cli run \
  --cmd 'file.new={"blank":true}' \
  --cmd 'slide.new={"layout":"titleOnly","title":"Smoke test"}' \
  --cmd 'shape.insert={"preset":"roundRect","rect":[80,160,320,120],"text":"Hello"}' \
  --cmd 'insert.table={"rows":2,"cols":2,"rect":[440,160,360,120]}' \
  --cmd 'insert.chart={"type":"column","categories":["Q1","Q2"],"series":[{"name":"S","values":[3,5]}]}' \
  --cmd 'slide.notes={"text":"Speaker note"}' \
  --print --save "$DECK" > "$DIR/build.log"
cat "$DIR/build.log"

echo "== read back =="
deckcraft-cli run --in "$DECK" --print --cmd 'document.inspect' > "$DIR/doc.log"
python3 - "$DIR/doc.log" <<'PY'
import json, sys
raw = open(sys.argv[1], encoding="utf-8").read().split("→", 1)[-1].strip()
d = json.loads(raw)
slides = d["slides"]
assert len(slides) == 1, slides
assert slides[0]["title"] == "Smoke test", slides[0]
assert slides[0]["notes"] == "Speaker note", slides[0]
print("inspect ok:", slides[0]["title"], "shapes", slides[0]["shapes"], "notes", repr(slides[0]["notes"]))
PY

echo "== convert =="
deckcraft-cli convert "$DECK" "$PPTX"
deckcraft-cli convert "$DECK" "$PDF"
[[ -s "$PPTX" && -s "$PDF" ]] || { echo "FAIL: empty export"; exit 1; }
unzip -l "$PPTX" | grep -q 'ppt/slides/slide1.xml' || { echo "FAIL: pptx has no slide1.xml"; exit 1; }
pages="$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')"
[[ "$pages" == "1" ]] || { echo "FAIL: pdf pages $pages"; exit 1; }
pdftotext "$PDF" - | grep -q 'Smoke test' || { echo "FAIL: pdf text missing title"; exit 1; }
echo "exports ok: $(stat -c%s "$PPTX") bytes pptx, $(stat -c%s "$PDF") bytes pdf, $pages page"

echo
echo "PASS — artifacts in $DIR"
