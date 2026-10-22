#!/usr/bin/env bash
# Snapshot the live PhotoCraft command catalog and diff it with the previous snapshot.
# Usage: dump-commands.sh [--diff] [--dir DIR] [OUT.json]
set -euo pipefail

DIR="${PHOTOCRAFT_SNAPSHOT_DIR:-$HOME/.cache/photocraft/skill}"
DIFF=0
OUT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --diff) DIFF=1; shift ;;
    --dir) DIR="$2"; shift 2 ;;
    *) OUT="$1"; shift ;;
  esac
done
mkdir -p "$DIR"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="${OUT:-$DIR/commands-$STAMP.json}"
PREV="$(ls -1t "$DIR"/commands-*.json 2>/dev/null | grep -v -F "$OUT" | head -1 || true)"

photocraft-cli commands --json > "$OUT"
echo "wrote $OUT ($(wc -c < "$OUT") bytes)"

python3 - "$OUT" "$PREV" "$DIFF" <<'PY'
import json, sys, collections

new_path, old_path, do_diff = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
new = json.load(open(new_path))
ns = collections.Counter(c["id"].split(".")[0] for c in new)
print(f"{len(new)} commands in {len(ns)} namespaces")
print("  " + "  ".join(f"{k}={v}" for k, v in sorted(ns.items(), key=lambda kv: -kv[1])))

if not old_path:
    print("no previous snapshot to diff")
    sys.exit(0)

old = json.load(open(old_path))
print(f"\nprevious: {old_path} ({len(old)} commands)")
oldm = {c["id"]: c for c in old}
newm = {c["id"]: c for c in new}
added = sorted(set(newm) - set(oldm))
removed = sorted(set(oldm) - set(newm))
changed = sorted(i for i in set(newm) & set(oldm)
                 if (newm[i].get("params") or "") != (oldm[i].get("params") or ""))
print(f"added={len(added)} removed={len(removed)} param-changed={len(changed)}")

if do_diff:
    for i in added[:60]: print("  +", i)
    for i in removed[:60]: print("  -", i)
    for i in changed[:40]:
        print(f"  ~ {i}")
        print(f"      old: {(oldm[i].get('params') or '')[:160]}")
        print(f"      new: {(newm[i].get('params') or '')[:160]}")
    if len(added) > 60 or len(removed) > 60 or len(changed) > 40:
        print("  … truncated; open the two JSON files for the rest")
else:
    if added: print("  added: " + ", ".join(added[:20]) + (" …" if len(added) > 20 else ""))
    if removed: print("  removed: " + ", ".join(removed[:20]) + (" …" if len(removed) > 20 else ""))
    if changed: print("  params changed: " + ", ".join(changed[:20]) + (" …" if len(changed) > 20 else ""))
    print("  (use --diff for the full list)")
PY
