# MCP and the control channel — DeckCraft 0.9.0

Verified 2026-10-22 against `/usr/bin/deckcraft-cli` 0.9.0 (protocol
`2025-06-18`).

## Two servers, one engine

| Mode | Command | OpenCode name | What it can do |
|---|---|---|---|
| Headless | `deckcraft-cli mcp` (stdio) | `deckcraft` | Own in-process deck, no window. File-read/write roots available. |
| App bridge | `deckcraft --control 7990` then `deckcraft-cli mcp --connect 127.0.0.1:7990` | `deckcraft-app` | Drives the real window: `screenshot`, `pointer`, `select_tool`, `key`, `type_text`, `call_app`. Not confined. |

`--sample` opens the built-in 8-slide sample deck in either mode.
`--connect` accepts `PORT` or `host:port`.

**Port trap:** `deckcraft-cli app --help` documents **7979 as the app's default
port**, and 7979 is also the GridCraft bridge's port on this machine. Always pass
an explicit port (`deckcraft --control 7990`) and check `ss -ltn` before starting.

**Isolation:** the app honours `XDG_CONFIG_HOME`; run
`XDG_CONFIG_HOME=$TMP/xdg deckcraft --control 7990` to keep `prefs.json`,
`ui.json`, `logs/` and recovery data out of the user's `~/.config/deckcraft`.

**No auth:** the control server binds `127.0.0.1` only and, in 0.9.0, uses no
token or key file (unlike WordCraft's `control-key.local-PORT`). Any local process
that can connect can drive the window. Do not expose the port.

## Handshake (headless)

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{
  "protocolVersion":"2025-06-18","capabilities":{},
  "clientInfo":{"name":"probe","version":"1"}}}
{"jsonrpc":"2.0","method":"notifications/initialized"}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
{"jsonrpc":"2.0","id":3,"method":"resources/list","params":{}}
```

- `serverInfo`: `{name:"deckcraft", title:"DeckCraft", version:"0.9.0"}`
- capabilities: `tools`, `resources`
- **25 tools**, 2 resources, **no prompts** (`prompts/list` → `-32601 method not found`)
- initialize carries agent instructions: points on the current slide, 960×540,
  "every action is a command", typical flow `new_presentation → add_slide → …`.

Resources: `deckcraft://document` (`document.inspect` payload) and
`deckcraft://commands` (all commands). Both are JSON text.

## The 25 tools

| Tool | Arguments | Notes |
|---|---|---|
| `list_commands` | `{filter?}` | id, label, menu, shortcut, params, enabled |
| `run_command` | `{command*, params}` | the universal verb |
| `batch` | `{commands*, keepGoing?}` | ordered; stops at first error |
| `new_presentation` | `{blank?, theme?}` | blank → 0 slides |
| `open_presentation` | `{path*}` | `.deckcraft`, `.pptx`; returns lostSlides/damagedMedia/missingFonts |
| `save_presentation` | `{path?}` | format from extension; omit path to save in place |
| `export` | `{path*, format?, slide?, all?, scale?, layout?, perPage?, paper?, orientation?, dpi?, slides?, includeHidden?, textLayer?, transparentBackground?, width?, secondsPerSlide?, loop?, frame?}` | png/jpeg/pptx/deckcraft/pdf/gif/outline |
| `inspect_document` | — | slides, sections, layouts, theme, media, selection, size |
| `inspect_slide` | `{index?}` | shapes with box/text/fill/chart/table, notes, transition, animations |
| `render_slide` | `{slide?, scale?, edit?}` | returns an image + `{width,height,slide}` |
| `add_slide` | `{layout?, title?, body?}` | after the current slide |
| `go_to_slide` | `{index*}` | |
| `add_shape` | `{preset*, x*, y*, w*, h*, text?, fill?, line?}` | selects it |
| `add_text_box` | `{text*, x*, y*, w*, h?, size?, color?, align?}` | |
| `set_text` | `{id*, text*}` | replaces text, keeps first run's formatting |
| `insert_picture` | `{path?\|data?, x?, y?, w?, h?, name?}` | |
| `insert_table` | `{rows*, cols*, data?, x?, y?, w?, h?}` | 0×0 silently becomes 1×1 |
| `insert_chart` | `{type?, categories?, series?, title?}` | unknown type → Clustered Column |
| `select` | `{ids*}` | |
| `pointer` | `{events*, mods?}` | slide-point events: down/drag/up/move/doubleclick/tripleclick/contextclick |
| `select_tool` | `{tool*, preset?}` | select/text/shape/pen/highlighter/eraser… |
| `key` | `{key*, mods?}` | editing keys and shortcuts |
| `type_text` | `{text*}` | into the text being edited, or the selected shape |
| `screenshot` | — | **app only**; whole window PNG |
| `call_app` | `{method*, params?}` | **app only**; any control method |

Tool arguments are schema-checked: an extra key is refused, e.g.
`insert_chart: unknown argument "data" (expected: categories, series, title, type)`.
Keys inside `run_command.params` are **not** checked against an enum of known
parameter names — typos there are silently ignored.

## Control methods (`call_app` / `deckcraft-cli app --method`)

| Method | Params | Purpose |
|---|---|---|
| `engine.execute` / `command` / `ui.menu.invoke` | `{command, params}` | run a command by id |
| `engine.commands` | `{filter?}` | live catalog with enabled state |
| `document.inspect` | — | same as the tool |
| `ui.inspect` | — | window, canvas/slide rects, canvasScale, dialog, documents, tool, showing, perf |
| `ui.tool.select` | `{tool, preset?}` | same as `select_tool` |
| `ui.pointer` | `{events:[{kind,x,y,mods?,pressure?}]}` | slide-point pointer |
| `ui.key` / `ui.text` / `ui.ime` | `{key,shift?,alt?,cmd?}` / `{text}` / `{preedit,active?}` | keyboard, IME |
| `ui.move` / `ui.click` / `ui.drag` | screen points | real egui input, reaches menus and panes |
| `ui.set` | `{tab?, view?, pane?, notes?, zoom?, gridlines?, guides?, …}` | UI state |
| `ui.dialog.open` / `ui.dialog.close` | `{id, fields?}` | open/close a dialog by id |
| `ui.screenshot` / `ui.render` | `{path?}` / `{path?, slide?, scale?}` | PNG of window / slide |
| `ui.resize` / `ui.focus` | — | window control |
| `show.start` / `show.end` | `{from?, custom?, reading?}` | slide show |
| `app.open` / `app.save` / `app.export` / `app.quit` | `{path, …}` | file handling |

Everything else is a **command**, not a method: `call_app {method:"view.closeMaster"}`
fails with `unknown method`, while
`call_app {method:"command", params:{"command":"view.closeMaster"}}` works.

## Coordinates

- `ui.pointer`, `pointer`, `insert.*` rects, `shape.move`: **slide points**,
  origin top-left, y down, 960 × 540 by default.
- `ui.click`, `ui.move`, `ui.drag`: **screen points** in the window.
- `ui.inspect` gives `canvasRect:[x,y,w,h]`, `slideRect:[x,y,w,h]`,
  `canvasScale`, `ui.zoom`. Map slide→screen as
  `screenX = slideRect.x + x * (slideRect.w/960)` (and the same for y with 540).
  At 200 % zoom the slide rect goes off-window (e.g. `[-123,-67,1921,1081]`);
  `ui.pointer` still accepts any in-slide point.
- `render_slide` and `file.render` take **slide indices** (0-based); the CLI
  `render --slide` also takes 0-based indices, and `--all` names files
  `slide-01.png` (1-based).
- Drag test: original box `[100,120,200,120]`, drag from (150,160) to (250,210)
  → box `[198,168,200,120]`. A ~2 pt rounding difference; do not assert exact
  equality after a drag.

## Limits and framing

- Newline-delimited JSON-RPC on stdio; connected mode caps a reply at **16 MiB**
  including the newline. A big `render_slide`/`screenshot` can exceed it — write
  images to a file with `file.export`/`ui.screenshot {path}` instead.
- Control channel: 16 connections, 16 MiB request line, 64 queued requests,
  10 min idle, 30 s blocked write, 60 s waiting for the UI. A request still
  queued at timeout is abandoned; one already started reports "outcome unknown".
- `--automation-read-root DIR --automation-write-root DIR` confine every path
  the in-process server reads/writes. They are **incompatible with `--connect`**
  (the server refuses to start). A missing root is an error. Errors look like
  `automation path rejected: outside the read root …`.
- The app bridge is **not** confined and has no equivalent flags.

## Client gotchas

- `type_text` returns `{"handled": false}` when no text is being edited; it does
  not fall back to the selection in every state. Enter edit mode first
  (`text.edit` or a double-click through `ui.pointer`).
- `ui.key` returns `{"handled": true/false}`; a handled key can still leave a
  dialog open (see bugs).
- `ui.inspect` is the only source of truth for dialog state; commands keep
  working while a dialog is open.
- Processes: the app writes `logs/deckcraft.log` (rotating `.1`, `.2`) under the
  settings dir, and started with a terminal it also logs to stderr.
