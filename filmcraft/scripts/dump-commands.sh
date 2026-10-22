#!/usr/bin/env bash
# Dump the FilmCraft command catalog as JSON, Markdown and a summary.
# Usage: dump-commands.sh [outdir]      (default: ./filmcraft-commands)
set -eu

CLI=${FILMCRAFT_CLI:-filmcraft-cli}
OUT=${1:-filmcraft-commands}
mkdir -p "$OUT"

"$CLI" --version > "$OUT/version.txt"
"$CLI" commands --json > "$OUT/commands.json"

python3 - "$OUT" <<'PY'
import json, os, collections, sys
out = sys.argv[1]
cmds = json.load(open(os.path.join(out, "commands.json")))
by = collections.defaultdict(list)
for c in cmds:
    by[c["id"].split(".")[0]].append(c)

lines = [f"# FilmCraft command catalog ({len(cmds)} commands)", ""]
lines += ["| namespace | n |", "|---|---|"]
for ns in sorted(by):
    lines.append(f"| `{ns}` | {len(by[ns])} |")
lines += ["", "## Commands", ""]
for ns in sorted(by):
    lines += [f"### {ns}", ""]
    for c in sorted(by[ns], key=lambda x: x["id"]):
        p = c.get("params") or ""
        sc = c.get("shortcut") or ""
        lines.append(f"- `{c['id']}` {p}" + (f"  ({sc})" if sc else ""))
    lines.append("")
open(os.path.join(out, "commands.md"), "w").write("\n".join(lines))

summary = [f"total: {len(cmds)}", f"namespaces: {len(by)}", ""]
summary += [f"{ns}: {len(by[ns])}" for ns in sorted(by)]
open(os.path.join(out, "summary.txt"), "w").write("\n".join(summary) + "\n")
print("\n".join(summary[:3]))
print("wrote", os.path.join(out, "commands.json"), "commands.md", "summary.txt")
PY
