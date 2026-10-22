# MCP and the control channel

## Server identity

`photocraft-cli mcp` speaks JSON-RPC 2.0 over stdio. Verified handshake:

```
initialize {protocolVersion:"2024-11-05"} ->
  serverInfo {name:"photocraft", version:"0.11.1"},
  capabilities {tools:{}, resources:{}},
  instructions: "…Start with doc_new/doc_open…"
tools/list -> 25 tools
resources/list -> photocraft://document, photocraft://commands
prompts/list -> []
```

No `tools/list_changed` notifications; no prompts. Resources are read with
`resources/read {uri}` and return live JSON (`photocraft://commands` is ~330 KB).

**Calls run concurrently.** If you pipeline `doc_new` and `doc_save` without
waiting for the first reply, the save can execute first and fail with
`no document open`. Wait for each relevant reply (as the OpenCode client does)
before sending a dependent call. Unrelated calls may be parallelised.

## The 25 tools

| Tool | Required args | Notes |
|---|---|---|
| `doc_new` | – | `{width=1920, height=1080, mode=rgb, depth=8, background=white, name}` → `{document:index}` |
| `doc_open` | `path` | → `{index, name, width, height, layers, warnings[]}` |
| `doc_select` | `index` | make a document active |
| `doc_close` | – | `{index?}` (default active) |
| `doc_inspect` | – | `{index?}` → document tree/history/selection/layers, or `{document:null, session}` when empty |
| `doc_save` | – | `{path, format?, quality 1–100?, index?, tiffLayers?, tgaBits?, dpxBits?}`; omitting `path` writes back only for PSD/PSB/pcraft |
| `doc_export` | – | same as save with an explicit format |
| `doc_export_layers` | `dir` | `{dir, format="png", prefix, visible_only=true, quality}` |
| `doc_export_data_sets` | `dir` | variable-data sets |
| `doc_import_data_sets` | `path` | CSV → data sets |
| `doc_place` | `path` | place as Smart Object `{scale, fit, center, index}` |
| `doc_render_preview` | – | `{max_side ≤2048}` → PNG content (flattened); bridge mode returns the window shot and rejects `index` |
| `render_preview` | – | same, bounded |
| `command_list` | – | `{filter?, enabled_only?}` → `[{id,label,menu,shortcut,params,enabled,disabledReason,needsDocument}]` |
| `command_run` | `id` | `{id, params?, wait?}` (one history step) |
| `command_batch` | `steps` | `[{id,params}]` or `["id",…]`; `{stop_on_error=true}` |
| `session_list` | – | `{active, documents:[{index,name,width,height,dirty,path}], foreground, background}`; **bridge** returns the UI-state envelope — read `.session` |
| `jobs_list`, `jobs_cancel` | – / – | long filters/file opens run as jobs |
| `control_call` | `method` | bridge only: raw control method |
| `ui_inspect` | – | bridge only with `--bridge` and a token |
| `ui_screenshot` | – | `{max_side ≤2048}` → PNG content (no path; the control method writes files) |
| `ui_menu_invoke` | `id` | bridge: menu item (opens its dialog when no params) |
| `ui_pointer` | `events` | bridge: document-coordinate events; `modifiers` is an object (`{"shift":true}`) |
| `ui_set` | `fields` | bridge: tool, panels, dock, zoom, theme, brush… |

Headless `ui_*` calls fail with a precise message telling you to start the app
and use `--bridge`.

## File access (the usual first failure)

The headless server starts with **no filesystem authority**:

```
doc_save {"path":"out.png"} -> isError: true
  "automation filesystem access is not granted: write authority is absent"
doc_open {"path":"in.png"}  -> "read authority is absent"
```

Grant it at launch:

```sh
photocraft-cli mcp --automation-read-root /home/you/work --automation-write-root /home/you/work
```

Rules (enforced):

- Relative paths resolve under the root; absolute paths are allowed only when
  **inside** it.
- `../` traversal → `automation path rejected: parent traversal is not allowed`.
- `/etc/hostname` → `absolute paths must be inside the automation root`.
- The environment variables `PHOTOCRAFT_AUTOMATION_READ_ROOT/WRITE_ROOT` are
  **not** honoured by `photocraft-cli mcp` (verified 0.11.1); use the flags.
- The same rules apply to the app's own automation paths (`app.open`,
  `app.save` over the control channel), bounded by the flags the app was
  launched with.
- Commands whose parameters are raw paths (`file.saveACopy`,
  `file.export.layersToFiles`, `file.placeEmbedded`,
  `layer.smartObjects.replaceContents`, …) are **disabled** in the automation
  build: `automation command … uses ambient filesystem paths and is disabled;
  use capability-scoped document methods`. Use the `doc_*` tools, the CLI, or
  the GUI.

## Desktop control channel

Start:

```sh
photocraft --control 7878 \
  --control-token-file ~/.config/photocraft/control-7878.token \
  --automation-read-root ~/work --automation-write-root ~/work \
  --new-instance
```

- Loopback only (`127.0.0.1:<port>`), JSON lines, one request/response per line.
- **Every new TCP connection must authenticate first**:

```json
{"id":0,"method":"auth","params":{"token":"<64 hex>"}}
-> {"id":0,"ok":true,"result":{"authenticated":true}}
```

  Anything else first → `authentication required`. A second `auth` on the same
  connection → `already authenticated` and the connection keeps working.
- Requests: `{"id":1,"method":"ui.inspect","params":{}}`; replies
  `{"id":1,"ok":true,"result":{…}}` or `{"id":1,"ok":false,"error":"…"}`.
- The window waits up to 60 s. `timeout: not run` is safe to resend;
  `timeout: no reply in 60s` means it may still be running — check the document
  before resending.
- Token file is created with mode `0600` if missing. Without any token option the
  app prints a fresh token to stderr. The MCP bridge **requires** a token and
  exits with: `error: bridge mode needs --control-token, --control-token-file,
  PHOTOCRAFT_CONTROL_TOKEN, or PHOTOCRAFT_CONTROL_TOKEN_FILE`.
- `--bridge`, not `--connect` (that is WordCraft's spelling; PhotoCraft rejects
  `--connect` with `unknown flag`).

Verified desktop methods: `auth`, `engine.execute {command, params}`,
`engine.commands`, `jobs.list`, `jobs.cancel`, `ui.inspect`, `ui.set`,
`ui.screenshot {path, focus}`, `ui.menu.list`, `ui.menu.invoke {id, params?, wait?}`,
`ui.dialog.open {kind, fields?}`, `ui.dialog.set {dialog, field, value}`,
`ui.dialog.confirm {dialog, wait?}`, `ui.dialog.cancel {dialog}`,
`ui.pointer {events, tool?, modifiers?, button?}`, `app.open`, `app.save`.
`methods` and `session.list` are **not** control methods (that list belongs to
`photocraft-cli serve`).

### Screenshots

```json
{"method":"ui.screenshot","params":{"path":"/work/shot.png"}}
-> {"ok":true,"result":{"path":"/work/shot.png","width":1440,"height":900}}
```

- The control method takes `{path, focus}` and writes the file under the app's
  write root. `maxSide` is rejected (`unknown field maxSide`); that parameter
  belongs to the MCP tool `ui_screenshot {max_side}`, which returns PNG content.
- Window is 1440×900 with `pixelsPerPoint: 1.0` on this machine.
- Under Wayland the control drain only runs on compositor frame callbacks, so a
  sleeping or fully occluded window times out. Running the app with
  `WAYLAND_DISPLAY=` (XWayland) was reliable here.

### ui.inspect

Returns the full UI state. Useful keys: `tool`, `window`, `panels`, `dialogs`,
`document` (same shape as `doc_inspect`), `views`, `brush`, `status`,
`theme`, `jobs`, `toolOptions`, `view`, `perf`.

Dialogs appear as objects with `id`, `__command`/`kind`, and `fields`
(e.g. `newDocument` exposes `width,height,mode,depth,background,name`,
`__focused`).

### Dialogs

```json
{"method":"ui.dialog.open","params":{"kind":"newDocument"}}
{"method":"ui.dialog.set","params":{"dialog":4,"field":"width","value":200}}
{"method":"ui.dialog.confirm","params":{"dialog":4}}
{"method":"ui.dialog.cancel","params":{"dialog":4}}
```

Other kinds: `about`, `layerStyle {effect?}`, `colorPicker {target, parent…}`,
`command {command}`, `newCropPreset`/`deleteCropPreset`. Menu-driven dialogs open
with `ui.menu.invoke {id:"image.imageSize"}` and expose their real fields
(`width`, `height`, `__constrain`, `__resample`, …). Confirming a dialog waits
for the command's job by default; `wait:false` returns `{job, pending:true}`.

Caveat: `ui.dialog.cancel` on an unknown dialog id reports
`missing dialog` even though the field was supplied — check `ui.inspect.dialogs`
for the real id.

### ui.set

`ui.set {fields}` — accepted fields include `tool`, `panels`, `dock`,
`dockTabs`, `dockWidth`, `colorPanel`, `maskTarget`, `vectorMaskTarget`,
`selectionMode`, `zoom`, `center`, `rotation`, `fit`, `theme`, `brushSize`,
`brushSection`, `brushTab`, `brushesView`, `brushPicker*`, `gradientBlendMode`,
`gradientClassic`, `shapeStroke`, `strokeTrace`. Unknown fields are rejected with
the full list. `tool` takes internal ids (`brush`, `rectMarquee`, `magicWand`,
`paintBucket`, `type`, `move`, …), not menu labels.

### ui.pointer

`{"events":[{"kind":"down|move|up","x":docX,"y":docY,"pressure":0..1,"tiltX":…}],
"tool?":"brush","modifiers?":{"shift":true},"button?":"left|right"}``

- Coordinates are **document** pixels, not screen pixels.
- A stroke = `down`, several `move`, `up`. It lands as one history step named
  after the tool (`Brush Tool`).
- A click without a drag with the Gradient tool creates a *Gradient Fill Layer*
  (Photoshop-like), not a one-pixel paint.

## `photocraft-cli serve` (headless JSON server)

`serve` keeps one headless session and answers the same JSON lines on stdio or
`--port`. Methods (verified): `engine.execute`, `jobs.list`, `jobs.cancel`,
`engine.commands`, `session.list`, `doc.open`, `doc.place`, `doc.new`,
`doc.save`, `doc.exportLayers`, `doc.exportDataSets`, `doc.importDataSets`,
`doc.inspect`, `doc.render`, `doc.select`, `doc.close`, `batch`, `methods`.

Prefer MCP for agent work; `serve` is useful for long-lived scripts and for
`methods`.
