#!/usr/bin/env bash
# Dump the live WordCraft command catalog and compare it with this skill's snapshot.
# Usage: dump-commands.sh [OUT.json] [--update-skill]
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE=0
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--update-skill" ]]; then UPDATE=1; else ARGS+=("$arg"); fi
done
OUT="${ARGS[0]:-/tmp/opencode/wordcraft-commands.json}"

mkdir -p "$(dirname "$OUT")"
wordcraft-cli commands --json > "$OUT"
echo "wrote $OUT"

python3 - "$OUT" "$SKILL_DIR/references/command-index.md" "$UPDATE" <<'PY'
import json, sys, re, collections, pathlib

src, index_path, update = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
cmds = json.load(open(src))
by = collections.OrderedDict()
for c in cmds:
    by.setdefault(c["id"].split(".")[0], []).append(c)

print(f"{len(cmds)} commands in {len(by)} namespaces")

# Compare ids with the existing snapshot index.
old = set()
p = pathlib.Path(index_path)
if p.exists():
    old = set(re.findall(r"^- `([^`]+)`", p.read_text(), re.M))
new = {c["id"] for c in cmds}
added, removed = sorted(new - old), sorted(old - new)
if old:
    print(f"since snapshot: {len(added)} added, {len(removed)} removed")
    for i in added[:40]: print("  +", i)
    for i in removed[:40]: print("  -", i)
    if len(added) > 40 or len(removed) > 40:
        print("  … run with --update-skill to regenerate the full index")

if update:
    lines = [
        "# WordCraft command index — live",
        "",
        "Regenerated from the installed `wordcraft-cli commands --json`.",
        f"{len(cmds)} commands in {len(by)} namespaces. Parameters are omitted; query them live.",
        "",
    ]
    for ns, items in by.items():
        lines.append(f"## {ns} ({len(items)})")
        lines.append("")
        for c in items:
            extra = []
            if c.get("shortcut"): extra.append(c["shortcut"])
            if c.get("mutates"): extra.append("M")
            suffix = f" — *{', '.join(extra)}*" if extra else ""
            lines.append(f"- `{c['id']}` — {c['label']}{suffix}")
        lines.append("")
    p.write_text("\n".join(lines))
    print("updated", index_path)
PY
