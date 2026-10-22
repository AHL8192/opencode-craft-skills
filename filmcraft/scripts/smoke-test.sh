#!/usr/bin/env bash
# End-to-end smoke test: build a 1 s timeline, save, export H.264, render a frame,
# then validate the artifacts independently. Uses only a throwaway data dir.
# Usage: smoke-test.sh
set -euo pipefail

CLI=${FILMCRAFT_CLI:-filmcraft-cli}
command -v "$CLI" >/dev/null || { echo "smoke: $CLI not found" >&2; exit 2; }

TMP=$(mktemp -d /tmp/fc-smoke.XXXXXX)
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

DATA="$TMP/data"; PROJ="$TMP/smoke.fcproj"; OUT="$TMP/out.mp4"; PNG="$TMP/frame.png"
mkdir -p "$DATA" "$TMP/out"
SEC=254016000000

cat > "$TMP/script.jsonl" <<JSONL
{"id":"file.newProject","params":{"name":"Smoke"}}
{"id":"file.importDemoFootage","params":{"scene":"CityNight"}}
{"id":"file.newSequence","params":{"name":"SmokeSeq","width":640,"height":360,"fps":24,"video":2,"audio":2}}
{"id":"timeline.place","params":{"item":1,"track":"V1","seconds":0,"duration":${SEC}}}
{"id":"file.saveAs","params":{"path":"${PROJ}"}}
{"id":"file.exportMedia","params":{"path":"${OUT}","format":"h264","range":"custom","startSeconds":0,"endSeconds":1,"wait":true}}
{"id":"file.exportFrame","params":{"path":"${PNG}","format":"png","time":${SEC},"target":"program"}}
JSONL

echo "smoke: $("$CLI" --version) in $TMP"
timeout 300 "$CLI" --compact --data-dir "$DATA" run - < "$TMP/script.jsonl" | tee "$TMP/run.jsonl"

python3 - "$TMP" "$PROJ" "$OUT" "$PNG" <<'PY'
import json, os, subprocess, sys
tmp, proj, out, png = sys.argv[1:5]

lines = [json.loads(l) for l in open(os.path.join(tmp, "run.jsonl")) if l.strip()]
bad = [l for l in lines if not l.get("ok")]
if bad:
    print("smoke: FAILED commands:", json.dumps(bad, indent=2))
    raise SystemExit(1)
print(f"smoke: {len(lines)} commands ok")

def check(cond, msg):
    print(("ok   " if cond else "FAIL ") + msg)
    if not cond:
        raise SystemExit(1)

check(os.path.getsize(proj) > 1000, f"project saved ({os.path.getsize(proj)} bytes)")
check(os.path.getsize(out) > 1000, f"export written ({os.path.getsize(out)} bytes)")
check(os.path.getsize(png) > 1000, f"frame written ({os.path.getsize(png)} bytes)")

ftype = subprocess.run(["file", "-b", out], capture_output=True, text=True).stdout.strip()
head = open(out, "rb").read(12)
check(b"ftyp" in head, f"MP4 container ({ftype[:60]})")

ident = subprocess.run(["identify", "-format", "%wx%h", png], capture_output=True, text=True)
check(ident.stdout.strip() == "640x360", f"PNG is 640x360 ({ident.stdout.strip() or ident.stderr.strip()[:60]})")

# Independent duration check: parse the MP4 mvhd box (no GStreamer decoders here).
raw = open(out, "rb").read()
pos = 0
mvhd = None
while pos + 8 <= len(raw):
    size = int.from_bytes(raw[pos:pos + 4], "big")
    kind = raw[pos + 4:pos + 8]
    if size == 1:
        size = int.from_bytes(raw[pos + 8:pos + 16], "big")
        body = pos + 16
    else:
        body = pos + 8
    if kind == b"moov":
        inner = body
        while inner + 8 <= pos + size:
            s2 = int.from_bytes(raw[inner:inner + 4], "big")
            k2 = raw[inner + 4:inner + 8]
            if k2 == b"mvhd":
                mvhd = inner + 8
                break
            inner += s2
        break
    if size <= 0:
        break
    pos += size
check(mvhd is not None, "MP4 has a moov/mvhd header")
ver = raw[mvhd]
if ver == 1:
    timescale = int.from_bytes(raw[mvhd + 20:mvhd + 24], "big")
    duration = int.from_bytes(raw[mvhd + 24:mvhd + 32], "big")
else:
    timescale = int.from_bytes(raw[mvhd + 12:mvhd + 16], "big")
    duration = int.from_bytes(raw[mvhd + 16:mvhd + 20], "big")
secs = duration / timescale if timescale else 0
check(0.9 <= secs <= 1.1, f"MP4 duration {secs:.3f}s (mvhd timescale {timescale})")

if subprocess.run(["bash", "-c", "command -v gst-discoverer-1.0"], capture_output=True).returncode == 0:
    gst = subprocess.run(["gst-discoverer-1.0", out], capture_output=True, text=True).stdout
    dur = next((l.strip() for l in gst.splitlines() if "Duration:" in l), "")
    if dur:
        check("0:00:01" in dur, f"GStreamer duration ({dur})")
    else:
        missing = "Missing plugins" in gst
        print("skip GStreamer duration (no H.264/AAC decoder here)" +
              (", missing plugins reported" if missing else ""))
else:
    print("skip GStreamer (not installed)")

print("SMOKE OK")
PY
