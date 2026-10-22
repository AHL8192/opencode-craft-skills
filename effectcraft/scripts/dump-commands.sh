#!/usr/bin/env bash
# Dump the live EffectCraft command catalog and diff it against this skill's
# snapshot. Usage: dump-commands.sh [OUT.json] [--update-skill]
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX="$SKILL_DIR/references/command-index.txt"
UPDATE=0
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--update-skill" ]]; then UPDATE=1; else ARGS+=("$arg"); fi
done
OUT="${ARGS[0]:-/tmp/opencode/effectcraft-commands.json}"

mkdir -p "$(dirname "$OUT")"
effectcraft-cli commands --json > "$OUT"
echo "wrote $OUT"

python3 - "$OUT" "$INDEX" "$UPDATE" <<'PY'
import json, sys, re, collections, pathlib, subprocess

src, index_path, update = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
cmds = json.load(open(src))
by = collections.OrderedDict()
for c in cmds:
    by.setdefault(c["id"].split(".")[0], []).append(c)

print(f"{len(cmds)} commands in {len(by)} namespaces")

old = set()
p = pathlib.Path(index_path)
if p.exists():
    old = set(re.findall(r"^- `([^`]+)`", p.read_text(), re.M))
new = {c["id"] for c in cmds}
added, removed = sorted(new - old), sorted(old - new)
if old:
    print(f"since snapshot: {len(added)} added, {len(removed)} removed")
    for i in added[:60]:
        print("  +", i)
    for i in removed[:60]:
        print("  -", i)
    if len(added) > 60 or len(removed) > 60:
        print(f"  … {len(added) + len(removed) - 120} more")
else:
    print("no snapshot yet; writing one")

if not update:
    print("(pass --update-skill to rewrite references/command-index.txt)")
    sys.exit(0)

try:
    version = json.loads(subprocess.run(
        ["effectcraft-cli", "info", "--empty", "--json"],
        capture_output=True, text=True, check=True).stdout).get("version", "?")
except Exception:
    version = "?"

lines = [
    f"# EffectCraft command index — {version}",
    "",
    "Snapshot from `effectcraft-cli commands --json` (run `scripts/dump-commands.sh --update-skill`",
    "to refresh). One line per command: id — label — shortcut. Parameter docs and JSON Schemas",
    "are intentionally omitted; get them live with `describe_command` / `exec --list --schemas`.",
    f"{len(cmds)} commands in {len(by)} namespaces.",
    "",
]
for ns, items in by.items():
    lines.append(f"## {ns} ({len(items)})")
    lines.append("")
    for c in sorted(items, key=lambda x: x["id"]):
        sc = f" — *{c['shortcut']}*" if c.get("shortcut") else ""
        lines.append(f"- `{c['id']}` — {c.get('label', '')}{sc}")
    lines.append("")

p.write_text("\n".join(lines))
print(f"updated {p} ({len(cmds)} commands, {len(by)} namespaces, version {version})")
PY
