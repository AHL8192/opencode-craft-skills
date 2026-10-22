---
name: DeckCraft
description: Use whenever working with DeckCraft on this machine — the Rust presentation app and PowerPoint alternative — including creating, editing, styling, animating or exporting decks (.deckcraft, .pptx, .pdf, .png, .jpg, .gif, .txt, .md), driving the running desktop window, or using its MCP server, `deckcraft-cli`, or control channel. Triggers on "DeckCraft", "deckcraft-cli", "deckcraft mcp", "DeckCraft MCP", "make a slide deck", "build a presentation", "add a chart/table to this deck", "export these slides to PDF/PPTX/PNG", "take a DeckCraft screenshot", "drive the DeckCraft window", and requests to automate presentation work or DeckCraft itself. Invoke with @deckcraft.
---

# DeckCraft — agent operating guide

DeckCraft is a presentation editor (a PowerPoint clone) built in Rust. Every
ribbon button, menu item, shortcut and gesture is a **command** with an id; the
MCP tools are thin wrappers over those commands. Use the raw surfaces described
here — there is no proxy layer.

This skill is the operating manual: connection modes, the 25 MCP tools, the
command vocabulary, coordinates, exports, the traps that silently corrupt work,
and verified recipes.

## Machine snapshot — verified 2026-10-22

| Item | Value |
|---|---|
| App | `deckcraft` 0.9.0 at `/usr/bin/deckcraft` |
| CLI | `deckcraft-cli` 0.9.0, package `0.9.0-1` (deb) |
| Control port | **use 7990**; do not rely on the default (see the 7979 trap) |
| Settings | `~/.config/deckcraft/` (`prefs.json`, `ui.json`, `logs/`) |
| Servers in OpenCode | `deckcraft` (headless stdio), `deckcraft-app` (bridge to :7990) |
| Commands | **321** in 31 namespaces |
| MCP tools | **25**, plus 2 resources, no prompts |
| Slide | 960 × 540 pt (16:9), x right, y **down** |
| Themes / presets / transitions | 8 / 183 / 49 |
| Sample deck | 8 slides (`--sample`) |

## Mental model

- A presentation has **slides** (0-based index), each with a **layout** (by name
  or camelCase kind), **shapes**, **notes**, a **transition** and
  **animations**.
- Lengths are **points**; a rect is `[x, y, w, h]`. Shape ids are handles and
  are **unique per slide only**. The engine has a **current slide**: commands
  like `shape.inspect`, `format.*`, `table.*` act there and on the **selection**.
- **`slide.new` inserts after the current slide**, not at the end.
- Commands return `null` when they succeed without a useful value (e.g.
  `edit.deselect`), so treat `null` as success and verify with inspection.
- Unknown **parameter names inside a command are silently ignored**; unknown
  **tool arguments are rejected**. This asymmetry causes most bad decks.

## Two connection modes

**Headless (default)** — no window, own in-process deck:

```sh
deckcraft-cli mcp                    # stdio JSON-RPC; serverInfo deckcraft 0.9.0
deckcraft-cli mcp --sample           # opens the 8-slide sample
```

**App bridge** — drives the real window:

```sh
XDG_CONFIG_HOME=$TMP/xdg deckcraft --control 7990 &     # isolated settings
deckcraft-cli mcp --connect 127.0.0.1:7990              # or deckcraft-cli app --port 7990 …
```

Both speak MCP over stdio with newline-delimited JSON-RPC. Only the bridge has
`screenshot`, `pointer`, `select_tool`, `key`, `type_text`, `call_app`; the
headless server also has `--automation-read-root` / `--automation-write-root`
confinement. The bridge is **not** confined.

**The 7979 trap:** `deckcraft-cli app` and the app's help text default to port
**7979**, which is also the GridCraft bridge on this machine. Always pass
`--control 7990` / `--port 7990`, and check `ss -ltn` before starting. The
control server binds `127.0.0.1` but has **no auth token** in 0.9.0 — any local
process can drive the window.

## Standard workflow

1. **Create or open** — `new_presentation {theme?}` (blank → start slide) or
   `open_presentation {path}`; read `lostSlides`, `damagedMedia`, `missingFonts`.
2. **Add slides** — `add_slide {layout,title,body}`; body levels use `\t`
   indentation. New slides land after the current one.
3. **Build shapes** — `add_shape {preset,x,y,w,h,text}` (183 presets via
   `shape.presets`), `insert_table`, `insert_chart`, `insert_picture`,
   `insert.smartArt`. The new object becomes the selection.
4. **Style** — `format.*` for text, `shape.fill/line/effects/quickStyle`,
   `table.style/options`, `chart.options`, `design.theme/variant/background`.
5. **Inspect** — `inspect_document`, `inspect_slide {index}`,
   `shape.inspect {id}`, `render_slide`, `slide.colorAt`.
6. **Save / export** — `save_presentation {path}` (`.deckcraft` or `.pptx`) and
   `export` / `file.export` (PDF layouts, PNG/JPG, GIF, outline).
7. **Reopen and verify** — open the saved file and compare counts, text, notes,
   hidden flags. Reopening is the only fidelity report.

## The 25 tools

| Group | Tools |
|---|---|
| Discovery | `list_commands {filter?}`, `run_command {command,params}`, `batch {commands,keepGoing?}` |
| Document | `new_presentation`, `open_presentation`, `save_presentation`, `export`, `inspect_document`, `file.info` via command |
| Slides | `add_slide`, `go_to_slide`, `inspect_slide`, `render_slide` |
| Content | `add_shape`, `add_text_box`, `set_text`, `insert_picture`, `insert_table`, `insert_chart`, `select` |
| GUI (bridge only) | `pointer`, `select_tool`, `key`, `type_text`, `screenshot`, `call_app` |

`save_presentation` takes only a path; the extension picks the writer.
`export` takes the same options as the `file.export` command.

## Finding and running commands

```sh
deckcraft-cli commands                  # 321 lines: id — label: {params}
deckcraft-cli commands format.          # prefix filter
deckcraft-cli describe shape.insert     # params + menu path + shortcut
```

At runtime: `commands.list {filter}`, or read the `deckcraft://commands`
resource. Useful entry points: `file.new/open/save/export`, `slide.new/go/
layout/notes/hide/fromOutline`, `shape.insert/fill/line/effects/move/connect`,
`insert.table/chart/smartArt/picture/icon/wordArt/hyperlink`, `text.edit/
insert/set`, `format.*` (46), `table.*` (21), `design.theme/slideSize`,
`transition.set`, `animation.add`, `section.add`, `comment.add`,
`review.accessibility/spelling`, `arrange.*`, `selection.select`.

Run several commands atomically with `batch {commands:[{command,params}…],
keepGoing?}`; without `keepGoing` it stops at the first error, and a command
that fails leaves the deck unchanged but later ones still run if you continue.

## Coordinates and verification

- Slide points: `ui.pointer`, `pointer`, all rects, `shape.move` — origin
  top-left of the slide.
- Screen points: `ui.click`, `ui.move`, `ui.drag`. Map with `slideRect` and
  `canvasScale` from `ui.inspect`; at 200 % zoom the slide rect is bigger than
  the window.
- `render_slide`/`file.render` take 0-based slide indices; CLI `render --all`
  names files `slide-01.png` (1-based).
- `slide.colorAt {slide,x,y}` reads a rendered pixel — cheap proof a fill or
  theme actually drew.
- After any drag, expect a ~2 pt difference; use `shape.setBounds` when exact
  geometry matters.

## Pitfalls that bite (all verified — see `bugs-and-workarounds.md`)

1. A typo inside `params` (e.g. `titel`) is ignored — the slide gets no title.
2. Wrong types are dropped: `title:123` → `""`; `shape.move {dx:"abc"}` → no move.
3. A malformed `rect` (string, or `[x,y]`) becomes a centred **72×72** shape.
4. `insert_table {rows:0,cols:0}` → 1×1; chart `type:"banana"` → Clustered Column.
5. An unknown table style id is written verbatim into the deck.
6. `slide.hide {index:999}` returns `{hidden:true}` and hides nothing.
7. `file.export` to `.docx` writes a **deckcraft ZIP** with that extension
   (CLI `convert` refuses it); `file.save {path,format}` can mismatch the
   extension in either direction.
8. A command-opened dialog cannot be dismissed with `ui.key` Enter/Escape (both
   return `handled:true`); use `ui.dialog.close {id}`, and note commands still
   run underneath it.
9. `ui.dialog.open {id:"noSuchDialog"}` sets a bogus dialog state; `ui.set
   {zoom:"huge"}` silently does nothing.
10. `smartArt.*` with a wrong id silently uses the selection — use the returned id.
11. Shape ids and `shape.inspect` are **slide-scoped**; `go_to_slide` first.
12. Hidden slides are skipped by PDF, GIF, `all` PNG and outline exports;
    `includeHidden` exists for PDF only.
13. `all:true` PNG writes `<base>1.png`, `<base>2.png` (1-based), not your path.
14. `.md` export is tab-indented outline text, not Markdown.
15. `comment.list` defaults to the current slide.
16. Deleting the last slide leaves a **0-slide deck**; `slide.duplicate` then
    fails. `inspect_document` with nothing open errors (`no presentation open`).
17. Charts default to **Arial**, so reopening reports `missingFonts:["Arial"]`.
18. Pre-rename native files are refused: `not a DeckCraft file: slidecraft`.

## Safety on this machine

- Work on **copies**. Never overwrite a user's deck, and save only where you
  were asked (or under `/tmp/opencode/…`).
- For visual checks, start your **own** GUI on **7990** with
  `XDG_CONFIG_HOME` pointing at a temp dir; kill only the PID you started.
- Never use port 7979 or another agent's app/port; check `ss -ltn` first.
- Headless work needs no display; the bridge needs the user's session.
- LibreOffice cross-checks are heavy: use a private profile and
  `flock -x /tmp/opencode/craft-heavy.lock`.
- The control channel is unauthenticated — never expose it beyond localhost.
- A failing command aborts `deckcraft-cli run` and **nothing is saved**; in a
  batch, read every result instead of trusting the exit status.
- Quote `--cmd 'id={"json"}'` carefully; JSON is parsed, and a shell-mangled
  `--cmd` is reported as an unknown option.

## References

| File | Contents |
|---|---|
| `references/commands.md` | Curated command map with parameters, by namespace |
| `references/command-index.md` | All 321 ids with live parameter summaries |
| `references/recipes.md` | 16 verified end-to-end recipes (deck, table, chart, export, GUI) |
| `references/mcp-and-control.md` | Handshake, tool schemas, control methods, coordinates, limits |
| `references/cli.md` | `info/render/convert/run/commands/describe/mcp/app/bench`, confinement |
| `references/formats-and-roundtrip.md` | Format matrix, validators, fidelity, import failures |
| `references/bugs-and-workarounds.md` | Every trap above with a minimal reproduction |
| `references/maintenance.md` | Refresh sources, version-diff procedure, test matrix |
| `scripts/probe.sh` | Versions, ports, MCP handshake, command count, sample |
| `scripts/dump-commands.sh` | Snapshot and diff the command catalog |
| `scripts/smoke-test.sh` | Build → reopen → pptx/pdf conversion → validate |
| `assets/commands.txt` | 0.9.0 catalog snapshot for diffs |

## Maintenance

DeckCraft is an alpha; ids, parameters and counts move between releases. Run
`scripts/probe.sh`, then `scripts/dump-commands.sh`, then
`scripts/smoke-test.sh`; update the snapshot table and `references/` from the
live binary, not from the docs. Re-run the checker:

```sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/deckcraft
```

## What was not tested

- Windows/macOS builds; only Linux 0.9.0.
- Password-protected or macro-enabled files, `.odp` import (unsupported).
- Presenter view / multi-monitor show, audio/video playback in a real session.
- Printing, digital signatures, Ink, and the Ideas pane beyond opening it.
- Recovery (`file.recovery.*`) after a real crash.
- `.potx`/`.ppsx` **import** (only export/convert was exercised).
