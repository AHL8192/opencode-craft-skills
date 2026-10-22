#!/usr/bin/env bash
# End-to-end smoke test for EffectCraft 0.13.0. Builds a comp, keys, an effect,
# renders a frame and a short MP4, saves and reopens. Uses a throwaway directory
# and never touches the user's project or config.
#
# Usage: smoke-test.sh [--keep]
set -uo pipefail

KEEP=0
[[ "${1:-}" == "--keep" ]] && KEEP=1
TMP="$(mktemp -d /tmp/opencode/effectcraft-smoke-XXXXXX)"
PASS=0; FAIL=0
say()  { printf '%s\n' "$*"; }
ok()   { PASS=$((PASS+1)); say "  PASS  $*"; }
bad()  { FAIL=$((FAIL+1)); say "  FAIL  $*"; }
check(){ if [[ $1 -eq 0 ]]; then ok "$2"; else bad "$2"; fi; }

say "EffectCraft smoke test — dir $TMP"
cd "$TMP" || exit 1

say
say "== build =="
effectcraft-cli run --empty \
  comp.new '{"name":"Smoke","width":320,"height":180,"frameRate":30,"duration":1}' \
  layer.newText '{"name":"Title","text":"SMOKE","size":60,"fill":"#ffcc00","position":[160,90]}' \
  effect.apply '{"layer":"Title","effect":"Gaussian Blur"}' \
  --save-as smoke.ecproj > build.log 2>&1
check $? "build and save"
if [[ ! -s smoke.ecproj ]]; then
  bad "project file missing — aborting"
  say "see $TMP/build.log"
  exit 1
fi
ok "project file exists"

effectcraft-cli set Smoke Title effects/#1/blurriness 4 smoke.ecproj --save > fx.log 2>&1
check $? "set effect parameter"

effectcraft-cli exec prop.addKey --params \
  '{"layer":"Title","path":"transform/opacity","time":0,"value":0}' \
  smoke.ecproj --save > keys.log 2>&1
check $? "add a keyframe"
effectcraft-cli exec prop.addKey --params \
  '{"layer":"Title","path":"transform/opacity","time":0.5,"value":100}' \
  smoke.ecproj --save > keys2.log 2>&1
check $? "add second keyframe"

say
say "== read back =="
effectcraft-cli get Smoke Title transform/opacity --time 0.5 smoke.ecproj --json > prop.json 2>&1
python3 - <<'PY' && ok "opacity evaluates to 100 at 0.5s" || bad "opacity read"
import json
d = json.load(open("prop.json"))
assert abs(float(d["value"]) - 100.0) < 1e-6, d
PY
effectcraft-cli props Smoke Title --flat smoke.ecproj > props.log 2>&1
check $? "property tree"

say
say "== render frame =="
effectcraft-cli render-frame smoke.ecproj --comp Smoke --time 0.5 --max-side 320 \
  --out frame.png > frame.log 2>&1
check $? "render-frame"
python3 - <<'PY' && ok "PNG is 320x180 RGB" || bad "PNG validation"
from PIL import Image
im = Image.open("frame.png")
assert im.size == (320, 180), im.size
assert im.format == "PNG", im.format
assert im.mode in ("RGB", "RGBA"), im.mode
PY

say
say "== render movie =="
effectcraft-cli render smoke.ecproj --comp Smoke --out movie.mp4 --format h264 \
  --start 0 --end 0.5 > movie.log 2>&1
check $? "render H.264"
python3 - <<'PY' && ok "MP4 has ftyp+moov boxes" || bad "MP4 validation"
import struct
b = open("movie.mp4","rb").read()
assert b[4:8] == b"ftyp", b[:12]
found = b"moov" in b[:4096] or b"moov" in b
assert found
PY

say
say "== reopen in a fresh process =="
effectcraft-cli info smoke.ecproj --json > info.json 2>&1
python3 - <<'PY' && ok "project reopens with comp and text layer" || bad "reopen"
import json
d = json.load(open("info.json"))
ac = d.get("activeComp") or {}
assert ac.get("name") == "Smoke", ac.get("name")
assert any(l.get("name") == "Title" for l in ac.get("layers", [])), ac.get("layers")
PY
effectcraft-cli get Smoke Title transform/opacity --time 0.5 smoke.ecproj --json > prop2.json 2>&1
python3 - <<'PY' && ok "keys survive save/reopen" || bad "reopened keys"
import json
d = json.load(open("prop2.json"))
assert d["animated"] and len(d["keys"]) == 2, d
PY

say
say "== result =="
say "pass=$PASS fail=$FAIL dir=$TMP"
if [[ $KEEP -eq 0 && $FAIL -eq 0 ]]; then
  rm -rf "$TMP"
  say "(removed $TMP; use --keep to inspect)"
fi
[[ $FAIL -eq 0 ]]
