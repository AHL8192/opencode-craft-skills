---
name: WordCraft
description: Use whenever working with WordCraft on this machine — the Rust word processor and MS Word alternative — including creating, editing, restyling, reviewing or converting documents (.docx, .doc, .odt, .rtf, .html, .md, .tex, .txt, .pdf), driving the running desktop window, or configuring and using its MCP server or CLI for agentic document work. Triggers on "WordCraft", "wordcraft-cli", "wordcraft mcp", "WordCraft MCP", "open/edit this document in WordCraft", "drive the WordCraft window", "take a WordCraft screenshot", "convert docx with WordCraft", "track changes/comments/mail merge in WordCraft", and requests to automate document creation or WordCraft itself. Invoke with @wordcraft.
---

# WordCraft — agent operation

WordCraft is a native Rust word processor with a Word-compatible ribbon, `.docx`
read/write, PDF export, and an agent interface designed in: **every action is a
command with an id**. The ribbon, shortcuts, command search, CLI, control
channel, MCP server and macros all drive the same command engine.

## Machine snapshot (verified 2026-10-21)

| Thing | Value |
|---|---|
| Desktop app | `/usr/bin/wordcraft` — `wordcraft 0.9.0 (2e6db0bd)` |
| CLI | `/usr/bin/wordcraft-cli` — `0.9.0` |
| Install | Debian package `wordcraft` `0.9.0-1` (`dpkg -S /usr/bin/wordcraft`) |
| App flags | `--sample`, `--control PORT`, `--version`, `-h` |
| Preferences | `~/.config/wordcraft/` (`ui.json`, `recovery/`, `logs/`) |
| Log | `~/.config/wordcraft/logs/wordcraft.log` (+ `.1`, `.2`) |
| Control key | `~/.config/wordcraft/control-key.local-7981` (mode 0600) |
| OpenCode servers | `wordcraft` = headless; `wordcraft-app` = bridge to port 7981 |
| Command count | **633** in 0.9.0 (`wordcraft-cli commands --json`); the README's 422 is stale |
| Parity | 492/507 ribbon features live = 97% (`wordcraft-cli parity`) |

**Version drift is expected.** Re-verify with *Maintenance* below.

## Mental model

- A **document** is blocks (paragraphs, tables) plus parts (headers, footers,
  notes, text boxes). A **position** is:
  `{"story":"body" | {"part": n}, "path":[block,(row,cell,block)…], "off":byteOffset}`.
- A **command** is `{"command": "id", "params": {…}}`. `list_commands` finds ids
  and parameter docs; `execute` runs one; `batch` runs many.
- The **16 MCP tools** are thin wrappers over that engine. `type_text`,
  `select_text`, `open_document`, etc. are conveniences; anything not wrapped is
  reached with `execute`.
- **All lengths are points** (72 pt = 1 inch). Colours are `"RRGGBB"`,
  `"#RRGGBB"`, `[r,g,b]`, or `"Auto"`.
- **Verify by reading the document**, not by assuming a command worked:
  `get_text`, `inspect_document`, `render_page`, or `ui_inspect` in app mode.

## Two connection modes

| Mode | Server / command | What it is for |
|---|---|---|
| Headless | `wordcraft-cli mcp` → OpenCode `wordcraft` | No window. Batch creation, conversion, scripts, confined file access. |
| App bridge | `wordcraft --control 7981` + `wordcraft-cli mcp --connect 127.0.0.1:7981` → OpenCode `wordcraft-app` | Drives the actual window: screenshot, click, key, inspect UI. Unconfined. |

Configured in `~/.config/opencode/opencode.json`; exposed here as
`tools.wordcraft.*` and `tools["wordcraft-app"].*` (live window).

```sh
# headless MCP (what OpenCode runs)
wordcraft-cli mcp

# live window
wordcraft --control 7981 &
wordcraft-cli mcp --connect 127.0.0.1:7981

# check whether the window/control channel is up
pgrep -a -f "wordcraft --control"; ss -ltn | grep 7981
```

## Standard workflow

1. **Probe before acting.**
   - Headless: `get_text` (empty is fine), `list_commands({query:"..."})`.
   - App: `ui_inspect` to see title, dialog, dirty state, page rectangles.
2. **Start or open.** `new_document({template})` with `blank|sample|letter|resume|report`,
   or `open_document({path})`. On an unsaved app document, save first — `new_document`
   and `open_document` replace what is on screen.
3. **Edit with commands.** Type with `type_text`, select with `select_text`, then
   `execute` formatting/insertion commands. Use `batch` for ordered sequences.
4. **Position the caret deliberately.** After typing, the caret is after the text;
   `caret.docEnd`, `caret.home`, `caret.docStart`, `caret.set` move it. Code that
   applies a style to “the current paragraph” depends on this.
5. **Verify.** Read `get_text`/`inspect_document`; render a page for layout.
6. **Save a copy.** `save_document({path})`; the extension chooses the format
   (docx, pdf, odt, rtf, html, md, tex, txt, png). Save in place by omitting `path`
   only when overwriting is intended.
7. **Close only when asked.** `file.close` with unsaved changes errors rather than
   prompting; `{"force": true}` discards them.

## Tools (16)

| Tool | Purpose | Notes |
|---|---|---|
| `list_commands` | discover command ids/params | `{query}` filters id, label, location, params |
| `execute` | run one command | `{command, params}`; errors leave the document unchanged |
| `batch` | run many in order | stops at first error unless `keepGoing:true` |
| `new_document` | blank/sample/letter/resume/report | replaces the open document |
| `open_document` | open a file | `.docx .doc .odt .rtf .html .md .tex .txt .json`, any text file |
| `save_document` | save/export | format from extension; omit `path` to save in place |
| `type_text` | type at caret | replaces the selection; `paragraphs:true` splits lines |
| `select_text` | select the n-th occurrence | `{text, occurrence}` (1-based) |
| `get_text` | plain body text | tracked deletions omitted |
| `inspect_document` | structure JSON | blocks, runs, styles, tables, sections, selection, pages |
| `render_page` | page → PNG | `{page, scale}`; image content + width/height |
| `parity` | feature coverage | read-only |
| `screenshot` | whole window PNG | **app only** |
| `click` | pointer at window pixels | **app only**; `{x,y,count?,shift?,cmd?}` |
| `key` | key with modifiers | **app only**; `{key:"Enter", cmd?, shift?, alt?}` |
| `ui_inspect` | UI state JSON | **app only**; title, dialog, dirty, pages, caret, balloons, perf |

Resources: `wordcraft://document` (same as inspect) and `wordcraft://commands`
(all commands). Both are readable through the MCP resources API.

## Finding commands

`list_commands({query:"table"})` filters by id, label, location and parameter
text. The most-used ids: `insert.table`, `para.style`, `format.bold`,
`edit.find`/`edit.replaceAll`, `review.trackChanges`/`review.newComment`,
`references.toc`/`references.footnote`, `mailings.recipients`/`mailings.finish`,
`file.save`/`file.exportPdf`.

Full map with parameters: `references/commands.md`. All 633 ids:
`references/command-index.md`. Never guess a parameter — query it.

## Formatting properties

`format.set`, `para.set` and `styles.modify` take `CharProps` / `ParaProps`
objects. Every field is optional; **unknown field names are silently ignored**,
so a typo looks like “nothing happened”. Full tables: `references/properties.md`.

```json
{"command":"styles.modify","params":{"style":"Heading1",
 "chr":{"font":"Georgia","size":18,"bold":true,"color":"1B1611"},
 "para":{"spaceBefore":12,"lineSpacing":{"rule":"multiple","value":1.15}}}}
```

Lengths are **points**; `underline` is a style name, not a bool; a border needs
`width > 0`; `para.set` also takes `onPage` for page-relative indents.

## Track changes and comments

WordCraft records edits under the session user name. **Name the agent** so
reviewers can distinguish its work:

```sh
wordcraft-cli mcp --author "OpenCode (copyedit)"
```

or, at runtime, `file.setAuthor {"name":"OpenCode (copyedit)"}`.

Turn tracking on explicitly — omitting `value` **toggles**, which can switch
tracking off in a document saved with it on:

```json
{"command":"review.trackChanges","params":{"value":true}}
```

Then edit normally, and comment on a selection with
`review.newComment {"text":"…"}`. Reviewers can accept/reject; an agent can
`review.acceptAll`, `review.rejectAll`, or `review.compare` two files. For a
clean copy without markup, save to a new path after accepting.

## Macros

`tools.recordMacro` starts/stops recording; `tools.macros` lists, defines or
runs named command sequences. Details: `references/commands.md`.

## CLI in 30 seconds

Full reference: `references/cli.md`.

```sh
wordcraft-cli convert report.docx report.pdf     # format from extension
wordcraft-cli text report.docx                   # plain text
wordcraft-cli inspect report.docx                # structure JSON
wordcraft-cli render report.docx page.png --page 1 --scale 2
wordcraft-cli commands --json                    # authoritative command catalog
wordcraft-cli run --script job.json              # commands + multi-format save
wordcraft-cli mcp                                 # headless MCP on stdio
```

A script is `{"file"?, "template"?, "commands":[…], "save":[paths]}`; relative
script paths resolve against the script's folder, and a failure saves nothing.

## Verify your work

`get_text` for content, `inspect_document` for blocks/tables/styles/pages,
`render_page` for layout, and in app mode `screenshot`/`ui_inspect` for the
window. For saved files, `wordcraft-cli info path.docx` is an independent check.

## Pitfalls

- **`type_text` replaces the selection.** Collapse first (`select.collapse`,
  `caret.docEnd`) when appending.
- **Stories & occurrence.** `select_text`/`get_text` act on the active story and
  pick the n-th occurrence; use `select.range` for precise ranges. Collapse
  before `references.footnote`, then return via `caret.set` to a body position.
- **Objects & stories.** Chart/SmartArt/WordArt stay selected; collapse
  (`caret.docEnd`) before Enter/typing. Text boxes become the active story;
  return with `caret.set` before adding shapes, links or bookmarks. Odd/even
  headers are not separated in 0.9.0; verify the PDF.
- **Toggles flip state.** Pass `{"off":true}` or a value when determinism
  matters; Enter at the end of a list usually continues it.
- **Tab in the last table cell adds a row.** Fill the last cell without Tab.
- **Unknown params are ignored.** Misspellings silently do nothing.
- **Command errors leave the document unchanged**, but `batch` stops at the
  first error unless `keepGoing:true`; with it, inspect each result.
- **Saving/closing.** `file.close` never prompts and errors on unsaved changes
  (`force:true` discards); saving changes the path/title; in app mode save a
  copy deliberately; `new_document`/`open_document` replace the window.
- **The app bridge is not sandboxed.** Headless supports
  `--automation-read-root` / `--automation-write-root`; the app does not.
- **Control protocol:** one JSON object per line (1 MiB max); `ui.key`/`ui.text`
  queue before the edit lands — inspect before depending.
- **Coordinates differ:** `click` uses window pixels and ignores blank page
  area; `ui.clickText` uses page points (0-based); `render_page` is 1-based.
- **College layout.** `insert.coverPage` can spill onto extra pages; build a
  manual title page. Type headings as Normal, style them after the text, before
  the TOC. Body numbering is per section; `NUMPAGES` counts the cover.

## Reference files

`references/`: `mcp-and-control.md` (protocol, keys, UI methods, confinement),
`cli.md`, `properties.md`, `recipes.md`, `commands.md`, `command-index.md`,
`maintenance.md`.
`scripts/`: `probe.sh`, `dump-commands.sh`, `refresh-docs.sh`.

## Maintenance — this software is changing

**WordCraft is an ever-changing alpha.** Command ids, parameters, counts, tool
names and defaults can change between releases. The snapshot above was verified
on **2026-10-21 against 0.9.0**. Before relying on a detail that matters, confirm
it against the installed build.

Quick check and refresh:

```sh
bash ~/.config/opencode/skills/wordcraft/scripts/probe.sh
bash ~/.config/opencode/skills/wordcraft/scripts/dump-commands.sh
bash ~/.config/opencode/skills/wordcraft/scripts/refresh-docs.sh
```

`probe.sh` reports versions, MCP tools, command count and parity.
`dump-commands.sh` diffs the live catalog against this skill's snapshot.
`refresh-docs.sh` pulls the latest README, MCP docs, control protocol and
release notes from GitHub into `/tmp/opencode/wordcraft-upstream`.

When anything differs, update this skill and its references rather than
trusting stale text. Full URLs, the ordered update checklist, and how to inspect
a new release: `references/maintenance.md`. Re-run the skill checker afterwards:

```sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/wordcraft
```
