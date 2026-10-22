# Maintenance — keeping this skill true

DeckCraft is an alpha that changes between releases. The snapshot in `SKILL.md`
was verified on **2026-10-22 against 0.9.0**. Re-verify before relying on a
specific id, parameter or count.

## Refresh sources

| What | URL |
|---|---|
| README | https://raw.githubusercontent.com/storytold/deckcraft/main/README.md |
| MCP server docs | https://raw.githubusercontent.com/storytold/deckcraft/main/docs/mcp.md |
| Control protocol | https://raw.githubusercontent.com/storytold/deckcraft/main/docs/control-protocol.md |
| Known gaps | https://raw.githubusercontent.com/storytold/deckcraft/main/docs/gaps.md |
| Format parity | https://raw.githubusercontent.com/storytold/deckcraft/main/docs/file-format-parity.md |
| Feature checklist | https://raw.githubusercontent.com/storytold/deckcraft/main/docs/parity-checklist.md |
| Roadmap | https://raw.githubusercontent.com/storytold/deckcraft/main/ROADMAP.md |
| Releases | https://github.com/storytold/deckcraft/releases |

Treat all of them as possibly stale. The binary wins.

## Quick check

```sh
bash ~/.config/opencode/skills/deckcraft/scripts/probe.sh
bash ~/.config/opencode/skills/deckcraft/scripts/dump-commands.sh
bash ~/.config/opencode/skills/deckcraft/scripts/smoke-test.sh
```

`probe.sh` prints versions, package, 79xx ports, the MCP handshake (25 tools,
2 resources), the command count/namespaces and the sample deck summary.
`dump-commands.sh` diffs the live catalog against `assets/commands.txt`.
`smoke-test.sh` builds a deck, reopens it, converts to pptx/pdf and validates the
output — it exits non-zero on the first mismatch.

## Version-diff procedure

1. `deckcraft --version`, `deckcraft-cli --version`, `dpkg -s deckcraft`.
2. `bash scripts/probe.sh` — tool count, resource URIs, command count.
3. `bash scripts/dump-commands.sh` — review the diff; update
   `assets/commands.txt` and `references/command-index.md` when the change is real.
4. For each changed command, `deckcraft-cli describe ID` and test the new
   parameter with a raw call plus a read-back.
5. Re-check the format matrix in `formats-and-roundtrip.md` if `file.export`,
   the PDF writer or the pptx importer changed (`crates/pdf`, `crates/pptx` in
   the repo are the places to read).
6. Re-run the GUI checks in `mcp-and-control.md` if `ui.*` methods changed:
   `ui.inspect`, `ui.pointer`, `ui.dialog.*`, `screenshot`.
7. Update the snapshot table in `SKILL.md` with the new version and date.
8. Re-run the skill checker (below). Keep the `SKILL.md` body under 12,000 bytes.

## Inspecting a new build without touching the user's setup

```sh
TMP=$(mktemp -d /tmp/opencode/deckcraft-maint.XXXXXX)
XDG_CONFIG_HOME=$TMP/xdg deckcraft --control 7990 &   # explicit port, never 7979
echo $! > $TMP/gui.pid
ss -ltn | grep 7990
deckcraft-cli mcp --connect 127.0.0.1:7990
# … test …
kill "$(cat $TMP/gui.pid)"          # only the process you started
```

Check `ss -ltn` first: this machine has had GridCraft (7979), VectorCraft (7983)
and other agents' apps listening at the same time. `deckcraft-cli app` defaults
to **7979**, so always pass `--port 7990`.

## Test matrix to repeat

| Area | Minimum proof |
|---|---|
| Commands | `commands` count, `describe` for each changed id |
| Object model | 0-based slide indices, slide.new `at`, ids after save/reload |
| Editing | undo/redo, selection scope, `shape.inspect` on the current slide |
| Silent success | typo param, wrong type, bad `rect`, unknown chart/table style |
| Export | PDF pages via `pdfinfo`, text via `pdftotext`, pptx via `unzip` |
| Import | own pptx, LibreOffice-rewritten pptx, truncated file |
| GUI | `ui.inspect`, pointer click, screenshot, dialog open/close |
| Limits | `bench --sample`, 40+ slides, 300 shapes, 10 000-char text |

## Known tooling

- `pdfinfo`, `pdftotext`, `unzip`, `identify` (ImageMagick), `soffice` are
  installed on this machine. `qpdf`, `ffprobe` and `python-pptx` are not.
- LibreOffice checks need a private profile and a lock:
  `flock -x /tmp/opencode/craft-heavy.lock -c "soffice --headless -env:UserInstallation=file://$TMP/lo-profile …"`.

## Checker

```sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/deckcraft
```
