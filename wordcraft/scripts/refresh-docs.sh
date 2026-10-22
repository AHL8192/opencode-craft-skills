#!/usr/bin/env bash
# Fetch the upstream WordCraft docs and release info for comparison.
# Usage: refresh-docs.sh [DEST_DIR]
set -euo pipefail

DEST="${1:-/tmp/opencode/wordcraft-upstream}"
BASE="https://raw.githubusercontent.com/storytold/wordcraft/main"
mkdir -p "$DEST"

fetch() {
  local url="$1" out="$2"
  if curl -fsSL --max-time 30 "$url" -o "$DEST/$out"; then
    echo "fetched $out ($(wc -c < "$DEST/$out") bytes)"
  else
    echo "FAILED $url" >&2
    return 1
  fi
}

fetch "$BASE/README.md" README.md
fetch "$BASE/docs/mcp.md" mcp.md
fetch "$BASE/docs/control-protocol.md" control-protocol.md
fetch "$BASE/docs/parity-checklist.md" parity-checklist.md
fetch "$BASE/docs/gaps.md" gaps.md
fetch "$BASE/ROADMAP.md" ROADMAP.md

echo
echo "== installed =="
wordcraft --version 2>/dev/null | head -1 || true
wordcraft-cli --version 2>/dev/null || true

echo
echo "== latest release =="
curl -fsSL --max-time 30 https://api.github.com/repos/storytold/wordcraft/releases/latest \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tag_name"), d.get("published_at")); print((d.get("body") or "")[:500])' \
  || echo "release API unavailable"

echo
echo "Docs are in $DEST. Compare them with this skill's references; update anything"
echo "that changed, then run: bash $(dirname "${BASH_SOURCE[0]}")/dump-commands.sh --update-skill"
