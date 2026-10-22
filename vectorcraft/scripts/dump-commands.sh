#!/usr/bin/env bash
# Snapshot VectorCraft's command catalogue as JSON (stdout).
# Usage: dump-commands.sh [LABEL] > cmds.json
#        dump-commands.sh 0.14.0 > old.json   # compare later with the recipe in maintenance.md
set -euo pipefail

LABEL="${1:-$(vectorcraft-cli --version 2>/dev/null | awk '{print $2}')}"
command -v vectorcraft-cli >/dev/null || { echo "vectorcraft-cli not found" >&2; exit 1; }

python3 - "$LABEL" <<'PY'
import json, subprocess, sys
raw = subprocess.run(["vectorcraft-cli", "commands"], capture_output=True, text=True, timeout=120)
if raw.returncode != 0:
    sys.stderr.write(raw.stderr[-500:]); sys.exit(raw.returncode)
cmds = json.loads(raw.stdout)
meta = {
    "label": sys.argv[1],
    "count": len(cmds),
    "ids": sorted(c["id"] for c in cmds),
    "commands": {c["id"]: {"label": c.get("label"), "params": c.get("params"),
                           "menu": c.get("menu"), "shortcut": c.get("shortcut")}
                 for c in cmds},
}
json.dump(meta, sys.stdout, indent=1, sort_keys=True)
sys.stdout.write("\n")
PY
