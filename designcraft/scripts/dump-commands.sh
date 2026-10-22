#!/usr/bin/env bash
# Snapshot the DesignCraft command catalog and diff it against the last snapshot.
#   dump-commands.sh                  # capture + diff
#   dump-commands.sh --update-skill   # also rewrite references/command-index.md
# Read-only apart from the snapshot dir and, with --update-skill, that one file.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SNAP_DIR="${DESIGNCRAFT_SNAPSHOT_DIR:-$HOME/.cache/designcraft-skill}"
UPDATE=0
[ "${1:-}" = "--update-skill" ] && UPDATE=1
mkdir -p "$SNAP_DIR"

VERSION="$(designcraft-cli --version 2>/dev/null | awk '{print $2}')"
CUR="$SNAP_DIR/commands-$VERSION.json"
designcraft-cli commands > "$CUR"

PREV="$(ls -1t "$SNAP_DIR"/commands-*.json 2>/dev/null | grep -v -F "/commands-$VERSION.json" | head -1 || true)"

python3 - "$CUR" "${PREV:-}" "$VERSION" <<'PY'
import json, sys, collections
cur_path, prev_path, version = sys.argv[1], sys.argv[2], sys.argv[3]
cur = {c["id"]: c for c in json.load(open(cur_path))}
print(f"catalog {version}: {len(cur)} commands, "
      f"{len({c.split('.')[0] for c in cur})} namespaces")
print(f"enabled with no document: {sum(1 for c in cur.values() if c.get('enabled'))}")
if not prev_path:
    print("no previous snapshot: this run is the baseline")
    sys.exit(0)
prev = {c["id"]: c for c in json.load(open(prev_path))}
added = sorted(set(cur) - set(prev))
removed = sorted(set(prev) - set(cur))
changed = sorted(i for i in set(cur) & set(prev)
                 if (cur[i].get("label"), cur[i].get("params"), cur[i].get("shortcut"), cur[i].get("menu"))
                 != (prev[i].get("label"), prev[i].get("params"), prev[i].get("shortcut"), prev[i].get("menu")))
print(f"previous: {prev_path} ({len(prev)} commands)")
print(f"added ({len(added)}): " + (", ".join(added[:40]) or "none"))
print(f"removed ({len(removed)}): " + (", ".join(removed[:40]) or "none"))
print(f"changed ({len(changed)}): " + (", ".join(changed[:40]) or "none"))
PY

if [ "$UPDATE" = "1" ]; then
  python3 - "$CUR" "$SKILL_DIR/references/command-index.md" "$VERSION" <<'PY'
import json, sys, collections, pathlib
cur_path, out_path, version = sys.argv[1], sys.argv[2], sys.argv[3]
cmds = json.load(open(cur_path))
by = collections.OrderedDict()
for c in cmds:
    by.setdefault(c["id"].split(".")[0], []).append(c)
out = [f"# DesignCraft command index — {version} (headless catalog)", "",
       f"Generated from `designcraft-cli commands` ({len(cmds)} commands, "
       f"{len(by)} namespaces).", "",
       "The running desktop app exposes more commands: the extra ones are UI-layer",
       "`ui:*`/`app.*` menu commands that only exist with a window.", "",
       "`enabled` is contextual — most commands need a document or a selection.",
       "Parameters are omitted here; ask live with `designcraft-cli describe ID`.",
       "`shortcut` and `ctx` (disabled with no document) are noted.", ""]
for ns, items in by.items():
    out += [f"## {ns} ({len(items)})", ""]
    for c in items:
        flags = []
        if c.get("shortcut"):
            flags.append(c["shortcut"])
        if not c.get("enabled", True):
            flags.append("ctx")
        suffix = f" — *{', '.join(flags)}*" if flags else ""
        out.append(f"- `{c['id']}` — {c['label']}{suffix}")
    out.append("")
pathlib.Path(out_path).write_text("\n".join(out))
print(f"updated {out_path} ({len(cmds)} commands)")
PY
fi
