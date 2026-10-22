# MCP server and control channel (0.10.0)

## MCP: `designcraft-cli mcp`

Newline-delimited JSON-RPC 2.0 on stdin/stdout; logs on stderr. Protocol
`2025-06-18` (also `2025-03-26`, `2024-11-05`). Server info:
`{"name":"designcraft","title":"DesignCraft","version":"0.10.0"}`.

```sh
designcraft-cli mcp                                   # headless, in-process engine
designcraft-cli mcp --connect 127.0.0.1:7984          # drives a running window
designcraft-cli mcp --sample                          # starts with the magazine sample
designcraft-cli mcp --automation-read-root DIR --automation-write-root DIR
```

The two roots confine every file the agent reads (open, images, data sources) and
writes (save, export). They cannot be combined with `--connect` — a running app is
not confined. Confinement is deny-by-default: a root you leave out grants nothing.

Resources (2): `designcraft://document` (the active document) and
`designcraft://commands`; no resource templates and no prompts. The menu tree is
the `menu_list` **tool**, not a resource.

### The 26 tools

| Tool | Notes |
|---|---|
| `list_commands {filter?, enabledOnly?}` | → `{commands, count}`. Each entry: id, label, menu, shortcut, params, enabled, disabled_reason. |
| `execute {command, params}` | One engine command. Unknown params are errors. Cannot open dialogs. |
| `batch {commands[] \| script}` | Stops at first error; supports `$N.path`. |
| `inspect_document` | Document summary: settings, spreads→pages/items, stories, styles, swatches, layers, selection, tool. |
| `get_story {story?\|frame?}` | Text, length (UTF-8 bytes), frames, paragraphs, lines, overset. |
| `set_story_text {story\|frame, text}` | Whole story; keeps first paragraph/character formatting. |
| `new_document {preset?,width?,height?,pages?,facingPages?,margins?,…}` | → `{index}`. |
| `open_document {path}` | `.designcraft`, IDML, INDD/INDT; content-sniffed. |
| `save_document {path?}` | Native `.designcraft`; adds extension if missing. |
| `place_image {path\|base64, frame?, x?, y?, width?, name?, spread?}` | → `{id, asset}`. |
| `render_page {page?, scale?, path?, bleed?}` | Returns PNG; also writes `path`. 0-based page. |
| `export_png {page?, path, scale?}` | PNG (or JPEG when the path ends `.jpg`). 0-based. |
| `screenshot {path?}` | Whole window (app mode only). |
| `select_tool {tool}` | `selection`, `directSelection`, `type`, `rectangleFrame`, … Invalid ids error. |
| `pointer {events[], space?}` | `down`/`drag`/`up`/`move`/`doubleclick`; default doc points. |
| `key {key, shift?, cmd?, ctrl?, alt?}` | Real keyboard path in app mode; shortcuts headless. |
| `type_text {text}` | At the caret or into a focused dialog field. `\n` = new paragraph. |
| `ime {preedit?, active?, commit?}` | IME composition at the Type caret. |
| `click {x,y,button?,count?,mods?}` | **Screen** points, reaches menus/panels/dialogs. App only. |
| `drag {x,y,toX,toY,steps?,mods?}` | **Screen** points. App only. |
| `menu_list` | Full menu tree: `[["File", ["ui:app.newDocumentDialog", "cmd:file.close", …]], …]`. App only. |
| `ui_inspect` | Tool, view (zoom/origin/rotation), canvasRect, window size, documents, open dialog, perf. App only. |
| `ui_set {panel?, zoom?, page?, fit?, screenMode?, …}` | `zoom: 1.0` = 100%. `page` is 1-based. App only. |
| `dialog_set {field, value}` | App only; see dialog notes. |
| `dialog_confirm` | App only. |
| `dialog_cancel` | App only. |

Invalid arguments produce JSON-RPC error `-32602` with a message naming the
unknown parameter and, often, a did-you-mean. Command-level failures come back as
`isError: true` content.

## Control channel: `designcraft --control PORT`

One JSON object per line, one reply per line, `127.0.0.1` only, no authentication.
Start with `--control 7984` or `DESIGNCRAFT_CONTROL_PORT=7984`. At most 16
connections; a 17th gets an error line and is closed.

```json
{"id":1,"method":"engine.execute","params":{"command":"frame.create",
  "params":{"rect":[36,36,300,200],"content":"text","text":"Hello"}}}
{"id":1,"ok":true,"result":{"id":10,"story":11}}
```

| Method | Params |
|---|---|
| `engine.execute` | `{command, params}` |
| `ui.menu.invoke` | `{command, params?}` — `cmd:*` runs the command; a parameter-taking command opens its dialog; `ui:*` is currently a no-op (bug) |
| `engine.commands` | — (685 in the app, 521 headless) |
| `document.inspect` | — |
| `ui.inspect` | — |
| `ui.menu.list` / `ui.tool.list` | — |
| `ui.tool.select` | `{tool}` |

Protocol edge cases, verified:

- Invalid JSON → `{"ok":false,"error":"bad JSON …; closing the connection"}` and the
  connection closes.
- An object without a string `method` → error and close.
- A line over 4 MiB → `request line longer than 4194304 bytes; closing the
  connection`.
- An HTTP request line is rejected as bad JSON — no cross-origin smuggling.
- Unknown command parameters are errors, e.g.
  `invalid parameters for 'frame.create': unknown parameter 'bogus'`.

Use the raw channel when you need `ui.menu.invoke`; the MCP server does not expose
it. `designcraft-cli app --port 7984 CMD '{…}'` is a one-shot client for
`engine.execute` (`--method METHOD` for other methods).

## Coordinates and input

- Engine/`pointer` coordinates: **spread points**, y down, origin at spread 0's
  top-left. Negative values are on the pasteboard and accepted.
- `click`/`drag`: **screen points**, window top-left `(0,0)`; window size is
  `ui_inspect.window`, e.g. `[1440,900]`.
- Mapping (verified): `screen = canvasRect.x0/y0 + (doc - view.origin) * zoom`.
  `ui_inspect.canvasRect` is `[x0,y0,x1,y1]`, `view.zoom` is a factor.
- Input is queued across native frames. After `pointer`/`click`/`drag`/`key`,
  **wait 0.5–1.5 s** before reading state; a drag may show in the canvas before its
  undo entry exists.
- `ui_set {"zoom":100}` clamps to the maximum (40.0 in testing); use
  `{"zoom":1.0}` for 100% and `{"fit":"page"}` to fit.
- `ui_set {"panel":"textWrap"}` opens a panel and `ui_inspect.ui.openPanel` reports
  it. `panel:"layers"` reported no change even though the panel is docked — verify
  visually rather than trusting `openPanel` for every panel.

## Dialog workflow (app mode)

1. Open with raw control:
   `{"id":1,"method":"ui.menu.invoke","params":{"command":"layout.documentSetup"}}`
   → `{"ok":true,"result":{"dialog":"documentSetup"}}`.
2. `ui_inspect.dialog` → `{id, fields:{width:"210 mm", height:"297 mm", …}}`.
3. `dialog_set {"field":"width","value":"250 mm"}` → returns the updated fields.
4. `dialog_confirm {}` → returns the applied setup (`width:708.66` pt for 250 mm).
5. `dialog_cancel {}` reverts and closes.

Verified quirks:

- `engine.execute layout.documentSetup {}` applies and returns settings; it does
  **not** open the dialog.
- `dialog_set` with an unknown field name silently adds it to `fields`.
- `dialog_set` with an unparseable value is accepted; `dialog_confirm` then fails
  with `width: not a measure` and leaves the dialog open.
- `ui.menu.invoke` on `ui:*` ids (preferences, about, fitPage, panels, screen mode)
  returns `{ok:true, dialog:null}` and does nothing. Drive those with `ui_set` or
  screen clicks instead.

## Screenshots and rendering

- `screenshot {path}` returns a PNG of the whole window (1440×900 here) and writes
  it when `path` is given.
- `render_page` renders **printing items only** (no guides, frames edges, panels),
  default 1 px/pt; page 0-based.
- `export_png` defaults to 2 px/pt (A4 → 1191×1684).
- Prefer `render_page` for page fidelity checks and `screenshot` for UI evidence.

## Concurrency

The control port is unauthenticated: only enable it while you use it, bind to
localhost, and never attach to a port you did not start. Isolate GUI runs with
`DESIGNCRAFT_CONFIG_DIR` and a unique port; `designcraft` is not single-instance,
so several isolated windows can coexist.
