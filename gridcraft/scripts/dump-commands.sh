#!/usr/bin/env bash
# Snapshot the live GridCraft catalog and compare it with this skill's index.
# Usage: dump-commands.sh [OUT.json] [--update-skill]
# Exit 1 when the live catalog differs and --update-skill was not given.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE=0
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--update-skill" ]]; then
    UPDATE=1
  else
    ARGS+=("$arg")
  fi
done
OUT="${ARGS[0]:-/tmp/opencode/gridcraft-commands.json}"
FUNCS="${OUT%.json}-functions.json"
mkdir -p "$(dirname "$OUT")"

gridcraft-cli commands --json > "$OUT"
gridcraft-cli functions --json > "$FUNCS"
echo "wrote $OUT"
echo "wrote $FUNCS"

python3 - "$OUT" "$FUNCS" "$SKILL_DIR" "$UPDATE" <<'PY'
import collections
import datetime
import json
import pathlib
import re
import sys

commands_path, functions_path, skill_dir, update = sys.argv[1:5]
skill = pathlib.Path(skill_dir)
index_path = skill / "references/command-index.md"
funcs_path = skill / "references/functions.md"
cmds = json.load(open(commands_path))
funcs = json.load(open(functions_path))

by_ns = collections.OrderedDict()
for c in cmds:
    by_ns.setdefault(c["id"].split(".")[0], []).append(c)
by_cat = collections.OrderedDict()
for f in funcs:
    by_cat.setdefault(f["category"], []).append(f)

def render_commands():
    lines = [
        "# GridCraft command index", "",
        f"{len(cmds)} commands in {len(by_ns)} namespaces, GridCraft 0.9.0. "
        f"Generated from `gridcraft-cli commands --json` on {datetime.date.today()}.",
        "",
        "This index is also the snapshot used by `scripts/dump-commands.sh`; "
        "each line starts with the command id.", "",
    ]
    for ns, items in sorted(by_ns.items()):
        lines += [f"## {ns} ({len(items)})", ""]
        for c in sorted(items, key=lambda x: x["id"]):
            lines.append(f"- `{c['id']}` — {c.get('label','').replace(chr(10),' ').strip()}")
        lines.append("")
    return "\n".join(lines)

def render_functions():
    lines = [
        "# GridCraft worksheet functions", "",
        f"{len(funcs)} functions in {len(by_cat)} categories, GridCraft 0.9.0. "
        f"Generated from `gridcraft-cli functions --json` on {datetime.date.today()}.",
        "",
        "Signatures use square brackets for optional arguments. Use "
        "`list_functions({search,category})` over MCP or `gridcraft-cli functions` "
        "for descriptions.", "",
        "| Category | Count |", "|---|---|",
    ]
    for cat, items in sorted(by_cat.items()):
        lines.append(f"| {cat} | {len(items)} |")
    lines.append("")
    for cat, items in sorted(by_cat.items()):
        lines += [f"## {cat}", ""]
        for f in sorted(items, key=lambda x: x["name"]):
            lines.append(f"- `{f['name']}` — `{f['signature']}`")
        lines.append("")
    return "\n".join(lines)

old_ids = set()
old_labels = {}
if index_path.exists():
    text = index_path.read_text(encoding="utf-8")
    for cid, label in re.findall(r"^- `([^`]+)` — (.*)$", text, re.M):
        old_ids.add(cid)
        old_labels[cid] = label.strip()
new_ids = {c["id"] for c in cmds}

old_funcs = set()
if funcs_path.exists():
    old_funcs = set(re.findall(r"^- `([A-Z0-9.]+)` —", funcs_path.read_text(encoding="utf-8"), re.M))
new_funcs = {f["name"] for f in funcs}

added = sorted(new_ids - old_ids)
removed = sorted(old_ids - new_ids)
changed = sorted(cid for cid in (new_ids & old_ids)
                 if cid in old_labels and old_labels[cid] !=
                 next(c.get("label", "").replace("\n", " ").strip() for c in cmds if c["id"] == cid))
func_added = sorted(new_funcs - old_funcs)
func_removed = sorted(old_funcs - new_funcs)

print(f"live: {len(cmds)} commands, {len(funcs)} functions")
print(f"snapshot: {len(old_ids)} commands, {len(old_funcs)} functions")
if added:
    print("added commands:", ", ".join(added))
if removed:
    print("removed commands:", ", ".join(removed))
if changed:
    print("changed labels:", ", ".join(changed))
if func_added:
    print("added functions:", ", ".join(func_added))
if func_removed:
    print("removed functions:", ", ".join(func_removed))

drift = bool(added or removed or changed or func_added or func_removed)
if drift and update == "1":
    index_path.write_text(render_commands(), encoding="utf-8")
    funcs_path.write_text(render_functions(), encoding="utf-8")
    print("updated references/command-index.md and references/functions.md")
elif drift:
    print("catalog differs; re-run with --update-skill to refresh the snapshot")
    sys.exit(1)
else:
    print("catalog matches the skill snapshot")
PY
