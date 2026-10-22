#!/usr/bin/env bash
# Snapshot the FigCraft command catalog and diff it against the previous snapshot.
# Usage: bash scripts/dump-commands.sh [output-dir]
set -uo pipefail

OUT=${1:-/tmp/opencode/figcraft-commands}
mkdir -p "$OUT"
prev=$(ls -1t "$OUT"/commands-*.json 2>/dev/null | head -1)
new="$OUT/commands-$(date +%Y%m%d-%H%M%S-%N).json"

figcraft-cli commands --json > "$new" || { echo "figcraft-cli commands failed"; exit 1; }
cp -f "$new" "$OUT/latest.json"
echo "snapshot: $new ($(wc -c < "$new") bytes)"
python3 - "$new" <<'PY'
import json, sys
cs = json.load(open(sys.argv[1]))
print("commands:", len(cs), " namespaces:", len({c["id"].split(".")[0] for c in cs}))
PY

if [ -n "$prev" ] && [ "$prev" != "$new" ]; then
  echo "previous: $prev"
  python3 - "$prev" "$new" <<'PY'
import json, sys
def load(p):
    return {c["id"]: c for c in json.load(open(p))}
a, b = load(sys.argv[1]), load(sys.argv[2])
added = sorted(set(b) - set(a))
removed = sorted(set(a) - set(b))
changed = []
for i in sorted(set(a) & set(b)):
    fields = ("params", "label", "undoable", "shortcut")
    diff = {f: (a[i].get(f), b[i].get(f)) for f in fields if a[i].get(f) != b[i].get(f)}
    if diff:
        changed.append((i, diff))
print(f"added: {len(added)}  removed: {len(removed)}  changed: {len(changed)}")
for i in added[:40]: print("  +", i)
if len(added) > 40: print(f"  … {len(added)-40} more added")
for i in removed[:40]: print("  -", i)
if len(removed) > 40: print(f"  … {len(removed)-40} more removed")
for i, d in changed[:40]:
    for f, (old, new) in d.items():
        print(f"  ~ {i}.{f}:\n      - {old}\n      + {new}")
if len(changed) > 40: print(f"  … {len(changed)-40} more changed")
PY
else
  echo "no previous snapshot — this one is the baseline"
fi

echo "tip: regenerate references/command-index.md from $OUT/latest.json"
