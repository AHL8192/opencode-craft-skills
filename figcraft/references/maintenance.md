# Maintenance and re-verification

## Sources

| What | Where |
|---|---|
| App + CLI | `/usr/bin/figcraft`, `/usr/bin/figcraft-cli` (Debian package `figcraft 0.8.0-1`) |
| Upstream | https://github.com/storytold/figcraft |
| Docs (fetched 2026-10-22) | `README.md`, `ROADMAP.md`, `docs/mcp.md`, `docs/cli.md`, `docs/control-protocol.md`, `docs/parity-checklist.md` |
| Community | https://discord.gg/artcraft · https://getartcraft.com/apps/figcraft |
| Test evidence for this skill | `/tmp/opencode/skill-tests/figcraft/figc-20261022-a/` (logs, harness, exports, screenshots, docs) |
| Reference skill | `~/.config/opencode/skills/wordcraft/` |

Docs are ahead of/behind the binary in places. Treat a documented feature as unverified until a raw
call plus read-back (and a save/reopen or external validator) confirms it.

## Verified snapshot

- `figcraft` 0.8.0, `figcraft-cli` 0.8.0, package `0.8.0-1`, Linux x86_64, Wayland session.
- Protocol `2025-06-18`, 18 tools, 2 resources, 4 prompts, **569 commands / 57 namespaces**,
  303 undoable, 149 shortcuts, 8 templates.
- Native save/open, `.json`, `.fig`, SVG/PNG import, PNG/JPG/WebP/SVG/PDF/`.fig` export all
  exercised; see `formats-and-roundtrip.md`.
- GUI driven in attached mode on port 47801 (click, shift-click, marquee, drag, R+click, text tool,
  type_text, Delete, Cmd+, preferences, Escape, window screenshot, save).

## Refresh procedure after an upgrade

```sh
# 1. versions + package + process/port state
bash scripts/probe.sh

# 2. catalog diff against the stored snapshot
bash scripts/dump-commands.sh            # writes and diffs under /tmp/opencode/figcraft-commands

# 3. headless end-to-end smoke test (builds, saves, exports, validates)
bash scripts/smoke-test.sh

# 4. skill lint
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/figcraft
```

`dump-commands.sh` reports added/removed ids and changed parameter strings. When counts change,
update the snapshot line in `SKILL.md` and regenerate `references/command-index.md`.

## What to re-check by hand when something changes

1. **Tool surface:** `tools/list` count and names; `inspect_ui` fields; `open_file` return shape.
2. **Coordinates:** create a frame at (100,100) with a child at (10,10); confirm `x` relative and
   `absoluteBounds` absolute; confirm group children keep frame coordinates.
3. **Silent successes:** `save_file` to `.png`, export `format` vs extension, `inspect.code`
   `format` vs `language`, `opacity:2`, unknown args on `create_node`, negative width, scale cap.
4. **Batch:** one undo step, `$step`, all-or-nothing on a bad id.
5. **Export matrix:** PNG/JPEG/WebP/SVG (with and without outlined text)/PDF (1-page vs frames),
   `.fig` reopen; validate externally.
6. **Attached mode:** window screenshot, click/drag, type_text, then a save; keep the window in
   front, kill only your own PID.

## Known-good environment for GUI work

```sh
ss -ltn | grep 47801                      # must be free (or your own instance)
figcraft --control 47801 & echo $! > /tmp/figcraft-gui.pid
# … tests …
kill "$(cat /tmp/figcraft-gui.pid)"
```

Ports used by the other Craft apps on this machine (do not reuse): wordcraft 7981, gridcraft 7979,
photocraft bridge 7878, vectorcraft 7983, designcraft 7984, deckcraft 7990. 47801 was free and is
the convention this skill documents; check `ss -ltnp` before starting anything.

## Updating the skill

- Keep `SKILL.md` body under 12,000 bytes (checker warns above that); push detail into
  `references/`.
- Regenerate `references/command-index.md` from the live catalog rather than editing it.
- Keep `bugs-and-workarounds.md` evidence-first: a repro, the observed value, the workaround.
- Never leave a skill claim that was only read from docs; mark it or test it.
- Back up the skill directory before large rewrites (`cp -a figcraft figcraft.bak-$(date +%F)`).
