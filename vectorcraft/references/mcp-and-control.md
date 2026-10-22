# MCP and the control channel

## Modes

```sh
vectorcraft-cli mcp                     # headless stdio; in-process document
vectorcraft-cli mcp --connect 127.0.0.1:7983   # drive the open window
vectorcraft-cli mcp --headless --automation-read-root DIR --automation-write-root DIR
vectorcraft --control 7983              # the app's control server
VECTORCRAFT_CONFIG_DIR=/tmp/vc-profile vectorcraft --control 7983   # isolated profile
```

- `--connect` **does not fall back**; it fails if nothing listens.
- The control port is loopback-only and **unauthenticated**. Enable it only
  while in use, and never on a shared/exposed interface.
- `--automation-read-root` / `--automation-write-root` imply `--headless` and
  confine `open`, `place`, `relink`, `save`, `export`, `package`, library I/O.
  A missing root grants none of that kind of access.

## Handshake (verified 0.14.0)

```
initialize → serverInfo {name:"vectorcraft", title:"VectorCraft", version:"0.14.0"}
             protocolVersion "2025-06-18" (also accepts 2025-03-26, 2024-11-05)
             capabilities: completions, logging, prompts, resources, tools
notifications/initialized
tools/list → 32 tools
```

Newline-delimited JSON-RPC 2.0 on stdio. Logs go to stderr, stdout is protocol.

## The 32 tools

MCP reports 32 entries but four pairs are aliases with different argument
names — both work:

| Tool | Args | Notes |
|---|---|---|
| `command_list` / `list_commands` | `query?, filter?, menu?, brief?, enabled_only?` | catalogue |
| `command_run` / `run_command` | `id` / `command`, `params` | **raw engine, no param validation** |
| `command_batch` | `steps:[{id,params?}]` ≤256, `atomic?, label?, stop_on_error?` | `{completed,failed,results,created}` |
| `doc_inspect` / `inspect_document` | `ids?, kind?, depth?, limit?, offset?, childLimit?` | layer tree, selection, history |
| `render_preview` | `artboard? 0-based, max_side? 1–4096` | inline PNG, no edit |
| `ui_inspect` / `inspect_ui` | — | app bridge only; tool error headless |
| `ui_screenshot` | — | app bridge only; inline PNG |
| `screenshot` | `artboard?, path?, scale?, window?` | artboard render or window capture |
| `select_tool` | `tool` | `selection`, `directSelection`, `rectangle`, `rotate`, … |
| `pointer_gesture` | `events:[{kind:down|drag|up|move|doubleclick,x,y,mods?,pressure?,holdMs?}], tool?, mods?` | document coords |
| `draw_shape` | `shape:rectangle|ellipse|polygon|star|line` plus geometry | validated; returns `{id,name,paint,shape}` |
| `draw_path` | `points?` or `d:"M…"`, `closed?, fill?, stroke?, strokeWidth?, cap?, join?, dash?, opacity?, name?, effects?` | |
| `set_paint` | `fill?, stroke?, strokeWidth?, ids?` | selection default |
| `add_text` | `text, x, y, size?, font?, color?, width?, height?, mode?, justify?, fit?, path?` | point or area type |
| `apply_effect` | `effect?, params?, ids?` | omit effect for the catalogue |
| `pathfinder` | `operation:unite|minusFront|intersect|exclude|divide|trim|merge|crop|outline|minusBack`, `ids?` | |
| `transform` | `dx,dy,rotate,scale,scaleX,scaleY,shear,reflect,copy,origin,ids` | |
| `create_graph` | `type, x,y,width,height, csv?|rows?, categories?, series?` | |
| `text_wrap` | `ids?, offset?, invert?, release?` | wrap area type |
| `open_file` | `path` | result has **no path**, only title/format/warnings |
| `save_file` | `path?` | no path → base64, stays dirty |
| `export` | `path?, format?, options?, artboard?, range?, scale?, outlineText?, selection?` | no path → base64 |
| `undo`, `redo` | — | |
| `press_key` | `key, mods:{cmd,alt,ctrl,shift}` | app bridge; key must be a real key name |
| `type_text` | `text` | app bridge, focused widget |
| `invoke_menu` | `command, params?` | menu ids (see `ui.menu.list`) |
| `open_panel` | `panel` | `layers`, `swatches`, `stroke`, `align`, `pathfinder`, … |

Strictness: **unknown top-level args → JSON-RPC -32602**; convenience-tool
validation failures and command failures → `result.isError:true` with text.
`command_run` still validates the engine command's own parameters (unknown ids,
unknown keys, wrong types, bad colours all error), but value-level coercion
inside a valid range is silent — see `bugs-and-workarounds.md` 3–8.

## Resources and prompts

Resources (JSON):

- `vectorcraft://document` — same summary as `doc_inspect`
- `vectorcraft://document/json` — full document model
- `vectorcraft://commands` — the catalogue

Templates: `vectorcraft://object/{id}`, `vectorcraft://command/{id}`,
plus effect/format templates. Prompts: `poster`, `icon set`, `diagram`,
`social`, `marketing` (arguments such as `brief`, `palette`, `text`).

## Control channel methods

One JSON request per line on TCP 127.0.0.1:PORT; replies are `{id,ok,result}` or
`{id,ok:false,error}`. No auth. 4 MiB line cap, 16 connections, 5 min idle.

| Method | Params | Purpose |
|---|---|---|
| `engine.execute` | `{command, params}` | run any engine command |
| `engine.commands` | — | full catalogue with enablement |
| `document.inspect` | `{depth?, ids?, kind?, limit?, offset?}` | layer tree/selection |
| `ui.inspect` | — | tool, view, panels, dialog, window, documents, perf |
| `ui.menu.list` / `ui.menu.invoke` | `{command, params?}` | menu tree / invoke |
| `ui.tool.select` / `ui.tool.list` | `{tool}` | |
| `ui.pointer` | `{events:[{kind,x,y,space?:"doc"|"screen",mods?}]}` | draw like the mouse |
| `ui.click` / `ui.drag` | `{x,y,button?,count?,shift?,alt?,ctrl?,cmd?}` / `{x,y,toX,toY,steps?}` | screen points |
| `ui.move` / `ui.wheel` | `{x,y}` / `{x,y,dy?,dx?,unit?}` | |
| `ui.key` / `ui.text` | `{key, shift?, alt?, cmd?}` / `{text}` | real key names only |
| `ui.set` | `{rulers?, grid?, panel?, brightness?, outline?, smartGuides?, …}` | toggles (read back in `ui.inspect.ui.view`) |
| `ui.dialog.set` / `.confirm` / `.cancel` | `{field, value}` | |
| `ui.screenshot` / `ui.render` | `{path?, data?}` / `{path?, scale?, artboard?, data?}` | window vs artboard |
| `app.open` / `app.save` / `app.export` / `app.quit` | `{path…}` | file ops on the live app |
| `ui.resize` / `ui.focus` | — | |

`ui.screenshot` needs a presented frame. Synthetic input has budgets: ≤256 drag
steps, ≤16 click count, 1,024 pending events shared by all `ui.*` input, 64
requests per frame. A request unanswered after 60 s returns a timeout error that
says whether it ran.

## Coordinates and the GUI

- Document space: points, y down, origin at artboard 1's top-left. The second
  artboard starts at `width + 20` unless laid out otherwise.
- `ui.inspect` gives `canvasRect [x, y, w, h]` (screen px) and
  `view {zoom, center, rotation, artboard}`. Screen point:
  `x = canvasX + canvasW/2 + (docX - center.x) * zoom` (same for y).
- `ui.click`/`ui.drag` use **screen** points; `ui.pointer`/`pointer_gesture`
  use **document** points.
- Verified on Wayland: click select, shift-click add, drag move (ellipse moved
  exactly 30×20 pt for a 70.7×47.1 px drag at 2.3567 zoom), rectangle tool drag
  created a shape with exact bounds, `ui.set {rulers:true}` reflected in
  `ui.view.rulers`.

## App-bridge specifics

- Run exactly one instance per profile; a second `--control` on the same port
  fails to bind.
- `ui.screenshot` returned 1440×900 here; the window must be mapped.
- `ui_inspect` shows `dialog: {kind, fields}`; dialogs only open from menu/tool
  invocations that the UI routes to a dialog (`tool.options`, `file.exportAs`,
  `effect.dialog`), not from `engine.execute` with empty params.
- OS file dialogs are not automatable on Linux: `ui.dialog.confirm` on an
  `exportAs` dialog returns `{"error":"cancelled"}`. Use explicit paths.
- `press_key {key:"Shift"}` is rejected (`unknown or missing key`); modifiers
  are flags on the click/gesture, not keys.
