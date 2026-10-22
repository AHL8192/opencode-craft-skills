# MCP and the JSON control channel — 0.13.0

Both surfaces sit on the same engine: the MCP server calls commands, the running
GUI listens on a TCP port and does the same. Nothing is authenticated.

## MCP server

```sh
effectcraft-cli mcp                      # headless, in-memory project
effectcraft-cli mcp --autosave           # save after each mutation (needs a path)
effectcraft-cli mcp --bridge 9877        # attach to a running window
effectcraft-cli mcp --project /abs/x.ecproj
effectcraft-cli mcp --automation-read-root /dir --automation-write-root /dir
```

Global options such as `--project`, `--demo`, `--empty`, `--save` also apply.
Transport is **newline-delimited JSON-RPC** (not Content-Length framing), stdio.
`initialize` with protocol `2025-06-18` is accepted; the server reports
`{"name":"effectcraft","title":"EffectCraft (headless)","version":"0.13.0"}`.
There are no prompts and no sampling; two resources:

- `effectcraft://document` → the `doc_inspect` payload
- `effectcraft://commands` → the full 731-command catalog

### Headless tools (27)

| Tool | Input | Notes |
|---|---|---|
| `list_commands` | `{filter?, enabledOnly?}` | array of `{id,label,menu,shortcut,enabled,why}` |
| `describe_command` | `{command}` | adds `params`, `schema`, `undoable` |
| `execute_command` | `{command, params?}` | the engine |
| `batch` | `{commands:[{command,params}|…]}` | one undo step, atomic |
| `get_state` | `{}` | app version/counts, project, active comp, selection, time |
| `get_project` | `{}` | items, path, dirty |
| `get_comp` | `{comp?}` | comp settings + layers |
| `get_layer` | `{layer, comp?, flat?}` | `flat:true` lists every property path |
| `get_property` | `{layer, path, time?}` | value/evaluated/keys/expression |
| `set_property` | `{layer, path, value?, expression?, time?}` | expression `""` removes it |
| `add_keyframe` | `{layer, path, keys:[{time,time? value}], interpolation?}` | bulk keys |
| `add_effect` | `{layer, effect, values?}` | name or id |
| `list_effects` | `{}` | 307, with `category`, `gpu` |
| `list_fonts` | `{}` | installed families |
| `render_frame` | `{comp?, time?, max_side?, path?, transparent?, inline?}` | PNG content + `{comp,time,width,height}`; `path` must have an existing parent folder (relative → server CWD) |
| `render_preview` | same | alias |
| `open_project` | `{path}` or `{demo}` or `{new:true}` | independent process safe |
| `save_project` | `{path}` | ignore-extension bug — see below |
| `undo` / `redo` | `{steps?}` | |
| `history` | `{}` | `undoStack`, `redoStack`, ids |
| `run_script` | `{code}` | AE-style JS; `{ok,result,output,error}` |
| `script_ui` | `{…}` | opens ScriptUI windows in a bridged app |
| `doc_inspect` | `{}` | project + active comp together |
| `command_list` | alias of `list_commands` | |
| `command_run` | alias of `execute_command` | |
| `command_batch` | `{steps:[{id, params}], stop_on_error?}` | **not** atomic: per-step undo, stops at first error keeping earlier steps |

Tool results are MCP `content` blocks with a JSON text block plus `structuredContent`
where present. Failures come back as a tool error whose text begins
```json
{"error":"…"} 
```
or as `{"__tool_error__": "…"}` from the Python harness — in an MCP client they
are ordinary error results, not protocol errors.

### Bridged tools (+9 = 36)

Start the app with `effectcraft --control 9877` (or `EFFECTCRAFT_CONTROL_PORT=9877`),
then connect with `--bridge 9877`. Added tools:

| Tool | Input | Returns |
|---|---|---|
| `screenshot` | `{path?, panel?, id?}` | `{path,width,height}` PNG of window/panel/element |
| `ui_inspect` | `{}` | `{window:[w,h], pixelsPerPoint, fps, activeComp, dialog, keyboardFocus, windowFocused, elements?}` |
| `ui_elements` | `{prefix?}` | `[{id,label,rect:[x,y,w,h]}]` from the last frame |
| `ui_click` | `{id}` or `{x,y,button?,count?,modifiers?}` | null |
| `ui_drag` | `{from:{id|x,y}, to:{…}, steps?, modifiers?}` | null |
| `ui_key` | `{key:"Ctrl+Z"|"p"|"Space"|"Escape"}` | null |
| `ui_type` | `{text}` | null |
| `ui_set` | `{tool?,workspace?,theme?,viewer?,timeline?,menuBar?,home?}` | null |
| `control` | `{method, params?}` | raw control-channel result |

The headless tool names stay available in bridge mode, so one agent can build with
`execute_command` and look with `screenshot`.

### Aliases and time defaults

`execute_command`≡`command_run`, `list_commands`≡`command_list`,
`batch`≡`command_batch`, `render_frame`≡`render_preview`,
`get_project`≈`doc_inspect`. Prefer the first form (it is the primary name in the
server), and prefer `batch` over `command_batch` when atomicity matters.

Time bases are asymmetric in the tools:

- `add_keyframe.time`, `set_property.time` → **layer seconds**
- `get_property.time`, `render_frame.time` → **comp seconds**

On a layer with nonzero `start`/`in` or `stretch`, pass `timeBase:"comp"` to the
`prop.*` commands to avoid off-by-offset keys, or convert yourself.

## Control channel

TCP, loopback, **no auth**, one JSON object per line:

```sh
printf '{"id":1,"method":"ui.inspect","params":{}}\n' | nc 127.0.0.1 9877
```

Requests run on the UI thread between frames. Only objects with a string `method`
are read; blank lines are skipped; malformed lines get an error reply. The reply
echoes `id` and has `result` or `error`.

### Methods

| Method | Params | Result |
|---|---|---|
| `engine.execute` | `{command, params?}` | command result; never opens a dialog |
| `engine.commands` | `{filter?, enabledOnly?}` | catalog |
| `ui.menu.invoke` | `{id, params?}` | like a menu click; may open a dialog |
| `ui.menu.list` | `{}` | menu tree with enablement |
| `render.frame` | `{comp?, time?, max_side?, path?, base64?}` | `{comp,time,width,height,path,png?}` |
| `ui.inspect` | `{}` | full UI state (includes `elements` with 90 widgets on this build) |
| `ui.elements` | `{prefix?}` | widgets in the last frame |
| `ui.set` | `{tool?, workspace?, theme?, focused?, viewer?, timeline?, menuBar?, home?}` | viewer: `{zoom,res,pan,grid,rulers,safeMargins,transparencyGrid}`, timeline: `{pps,start,graphEditor,showModes,openLayers,openGroups}` |
| `ui.panel.show` / `ui.panel.close` | `{panel}` | `Project`, `Composition`, `Timeline`, `EffectControls`, `EffectsPresets`, `Info`, `Preview`, `Character`, `Paragraph`, `Align` |
| `ui.playback` | `{action: play\|stop\|toggle\|status}` | `{playing,time,audio,levelsDb,peaksDb}` |
| `ui.resize` | `{width,height}` | **no-op on Wayland here** |
| `ui.focus` | `{}` | activates/steals focus — avoid |
| `ui.click` | `{id}` or `{x,y,button?,count?,modifiers?}` | |
| `ui.move` | `{id}` or `{x,y}` | |
| `ui.drag` | `{from,to,steps? 12,modifiers?}` | press/move/release |
| `ui.scroll` | `{id|x,y,dx,dy}` | |
| `ui.key` | `{key}` e.g. `Space`, `F9`, `Cmd+Z`, `PageDown`, `Escape` | layout-aware; text fields use physical keys |
| `ui.type` | `{text}` | into the focused field |
| `ui.viewer.locate` | `{x,y}` comp px | window point |
| `ui.viewer.hit` | `{id}` or `{x,y}` window pt | comp px |
| `ui.timeline.locate` | `{layer, time?}` | window point on the layer bar |
| `ui.screenshot` | `{path?,panel?,id?}` | `{path,width,height}` |
| `app.quit` | `{force?}` | unsaved prompt unless `force:true` |

`ui.inspect` also reports `pixelsPerPoint`, `keyboardFocus`, `windowFocused`,
`workspaceStorageError`, `lastRenderMs`, selection and open dialog.

### Driving the GUI reliably

1. `ui_inspect` → window size, dialog, fps. Window on this machine: **1912×1004
   points**, 1296×481 composition panel at 100%.
2. `ui_elements {"prefix":"tools."}` or `"timeline."` to get stable ids.
   Element ids seen: `tools.Type`, `tools.Selection`, `dialog.comp.name`,
   `dialog.comp.ok`, `dialog.comp.cancel`.
3. Click by id. Use coordinates only after `ui.viewer.locate`; verify with
   `ui.viewer.hit` (480,270 → 956.33,330.75 → 480.0,270.0).
4. Dialogs: `ui.menu.invoke {"id":"comp.new"}` opens `NewComp`;
   `ui_inspect.dialog` = `"NewComp"`. Fill, then `ui_click dialog.comp.ok`
   (or `ui_key Escape`).
5. To replace a field's text: click with `{"id":"dialog.comp.name","fx":1.0}`
   (caret at end), Backspace × current length, then `ui_type`. `Ctrl+A`/`Cmd+A`
   does **not** select-all in these fields.
6. `ui_key {"key":"p"}` on a selected layer reveals Position (shortcut-driven).
7. Playback: `ui.playback play` → `status` shows `time` advancing; `stop`.
8. Screenshots are real: 1912×1004 PNG, and the comp panel crop showed the text
   layer at the expected position. `screenshot {"panel":"Composition"}` gives
   1296×481.

### Coordinates

- Comp space: pixels, origin top-left, y down. `ui.viewer.locate/hit` convert
  between comp pixels and window points; zoom/pan are handled.
- Effects, masks, paint and puppet pins: **layer space** (layer pixels, origin at
  the layer's top-left). Shape/text layer bounds are comp-sized and centred on the
  content, so a mask rect of `[0,0,w,h]` is the full comp for those layers.
- `ui_elements.rect` and `ui.set.viewer.pan` are in window points, not comp px.

### Isolation

The control port is unauthenticated and the app writes `~/.config/effectcraft`.
For agent work start a separate instance:

```sh
EFFECTCRAFT_CONFIG_DIR=/tmp/ec-agent effectcraft --control 9877 &
```

Do not attach a bridge to a user's port unless asked. Never call
`app.quit {force:true}` on someone else's window.
