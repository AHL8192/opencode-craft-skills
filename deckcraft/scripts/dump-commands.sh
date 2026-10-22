#!/usr/bin/env bash
# Snapshot the live command catalog and diff it against the skill's snapshot.
# Usage: dump-commands.sh [OUT]   (default /tmp/opencode/deckcraft-commands-<version>.txt)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SKILL="$(cd "$HERE/.." && pwd)"
VER="$(deckcraft-cli --version 2>/dev/null | awk '{print $2}')"
OUT="${1:-/tmp/opencode/deckcraft-commands-${VER:-unknown}.txt}"
mkdir -p "$(dirname "$OUT")"
deckcraft-cli commands > "$OUT"
echo "wrote $OUT ($(wc -l < "$OUT") commands, version ${VER:-unknown})"
if [[ -f "$SKILL/assets/commands.txt" ]]; then
  if diff -u "$SKILL/assets/commands.txt" "$OUT" > /tmp/opencode/deckcraft-commands.diff; then
    echo "catalog unchanged since the skill snapshot"
    rm -f /tmp/opencode/deckcraft-commands.diff
  else
    echo "catalog differs; review /tmp/opencode/deckcraft-commands.diff"
    sed -n '1,60p' /tmp/opencode/deckcraft-commands.diff
  fi
else
  echo "no snapshot at $SKILL/assets/commands.txt; copy $OUT there after review"
fi
