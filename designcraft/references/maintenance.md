# Maintenance

DesignCraft is pre-alpha; treat every version bump as a possible surface change.
This skill was verified against **0.10.0-1** on 2026-10-22.

## 1. Check what changed

```sh
designcraft --version
designcraft-cli --version
dpkg -s designcraft | grep -E '^(Version|Status)'
```

If the version differs from the snapshot in `SKILL.md`:

```sh
~/.config/opencode/skills/designcraft/scripts/probe.sh
~/.config/opencode/skills/designcraft/scripts/dump-commands.sh --update-skill
```

`dump-commands.sh` prints added/removed command ids and, with `--update-skill`,
regenerates `references/command-index.md`.

## 2. Refresh the docs

```sh
cd /tmp && for f in README.md docs/mcp.md docs/control-protocol.md docs/agents.md \
  docs/gaps.md docs/file-format-parity.md docs/parity-checklist.md; do
  curl -sSL "https://raw.githubusercontent.com/storytold/designcraft/main/$f" -O
done
```

Compare against the claims in `bugs-and-workarounds.md`; docs in this project have
been stale before (unknown-parameter behaviour, `ui:` menu invocation, nested
pages).

## 3. Re-verify the core surface

Run the smoke test (headless, writes only under a temp dir):

```sh
scripts/smoke-test.sh
```

It checks: versions, MCP handshake + tool count, `new_document`, `frame.create`,
`get_story` read-back, `render_page`, save, fresh-process reopen, PDF export and
`pdfinfo`.

For a full regression, repeat the categories from the build session:

1. Object model: pages/spreads/parents/layers, `rect` normalization, 0-based
   vs 1-based index rules.
2. Lifecycle: create/edit/duplicate/delete, undo/redo, redo invalidation, dirty
   flag, id stability across save/reload.
3. Styles/satches/tables/text: create+apply+read back with
   `type.selectionAttrs`, `table.get`.
4. Silent-success sweep: nonexistent ids, bad enums, wrong types, out-of-range
   pages, unknown dialog fields, wrong export extensions.
5. Round-trip: native, IDML, PDF (x4/a2b), PNG/JPG, EPUB (both), PPTX, HTML.
6. GUI: launch isolated, screenshot, pointer/type, dialog open→set→confirm,
   `ui.menu.invoke` on `cmd:` and `ui:` items.

## 4. Re-check the MCP registration

Expected entries in `~/.config/opencode/opencode.json` under `mcp.servers`:

```json
"designcraft":     {"type":"local","command":["/usr/bin/designcraft-cli","mcp"]},
"designcraft-app": {"type":"local","command":["/usr/bin/designcraft-cli","mcp","--connect","127.0.0.1:7984"]}
```

`designcraft-app` only works while a window listens on 7984. Before adding or
changing entries, lock the file, make a timestamped backup and re-validate the
JSON — other applications' entries live in the same file.

## 5. Ports and profiles

`designcraft-cli app` defaults to 7979, which GridCraft also uses on this machine.
Use 7984 or higher and check first:

```sh
ss -ltn | grep -E ':79[0-9][0-9] '
```

Isolate manual GUI runs:

```sh
DESIGNCRAFT_CONFIG_DIR=/tmp/dc-profile designcraft --control 7984 &
```

Kill only the PID you started. The control port has no authentication.

## 6. When a bug is fixed

Delete the corresponding entry from `bugs-and-workarounds.md` after reproducing
the fix (command → read-back), and note the version in which it changed. Keep the
"not tested" list in `SKILL.md` honest.
