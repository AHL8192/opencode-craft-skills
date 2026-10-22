# MCP and control channel

Verified against `filmcraft-cli 0.10.0` (stdio MCP) and `filmcraft 0.10.0`
(control server), 2026-10-22. Raw protocol, no proxy.

## Starting a server

```sh
# headless MCP (in-process engine, no window)
filmcraft-cli mcp                    # empty project
filmcraft-cli mcp --demo             # built-in demo project
filmcraft-cli mcp --project p.fcproj # open a project
filmcraft-cli mcp --data-dir /tmp/fc # isolate preferences/recovery/models

# bridge to the live window
filmcraft --control 7991 --control-input-only &
filmcraft-cli mcp --bridge 127.0.0.1:7991
```

`--control-input-only` (requires `--control`) makes the app take widget input
only from the control server, so injected clicks/keys never touch the user's
pointer or focus. The control port is loopback-only and **unauthenticated**:
enable it only while needed. `FILMCRAFT_CONTROL_PORT` is the env equivalent.

Both servers expose the same 17 tools. `ui_*` tools require the bridge; on a
headless server they return an error. `filmcraft://document` and
`filmcraft://commands` resources work in both modes.

## Handshake

```
initialize {protocolVersion:"2025-06-18", capabilities:{}, clientInfo:{…}}
  -> {protocolVersion:"2025-06-18",
      capabilities:{resources:{}, tools:{}},
      serverInfo:{name:"filmcraft", version:"0.10.0"}, instructions:"…"}
notifications/initialized
```

`tools/list` → 17 tools; `resources/list` → 2; `prompts/list` → `[]`.

## Tool arguments are strict — params are not

| Mistake | Result |
|---|---|
| unknown tool argument name | JSON-RPC error `-32602`: `unknown argument "bogus" for command_list; expected: enabled_only, filter` |
| wrong JSON type for a tool argument | `isError:true`, text `failed to deserialize parameters: invalid type: string "x", expected f64` |
| unknown command id | `isError:true`, `{"__error__":"unknown command `no.such.command`"}` |
| unknown **command param name** | **ignored**, command may return success |
| wrong param type | **often ignored** (`timeline.place {seconds:"2"}` → 0), but validated by some commands (`graphics.set` → `value has the wrong type`) |
| bad enum/value | usually `isError:true`, `invalid parameters for …`; but `fps:"fast"` silently falls back to 23.976 |
| command disabled in this state | `isError:true`, `command `edit.undo` is not available right now: nothing to undo` |

This asymmetry (strict tool args, permissive command params) is the single most
common source of silent no-ops. Always read the parameter doc from
`commands.md`/`command_list`, then verify by reading state back.

## Result shapes

A normal `command_run` returns text content holding JSON:

```json
{"content":[{"type":"text","text":"{\"clips\":[9,10]}"}],"isError":false}
```

`text()` helpers must unwrap `content[0].text` and then `JSON.parse` it. A failure
puts the engine message in the same place with `isError:true` and the text is
`{"__error__":"…"}`. `render_frame` returns an image content block
(`{"type":"image","data":"<base64 png>","mimeType":"image/png"}`).

**`command_batch` double-encodes its report.** On any failure the call is
`isError:true` and the text is a JSON *string*:

```json
"{\"completed\":2,\"failed\":1,\"results\":[{\"ok\":true,\"result\":{\"time\":254016000000}},
 {\"error\":\"unknown command `no.such.command`\",\"ok\":false},
 {\"ok\":true,\"result\":{\"time\":508032000000}}]}"
```

With `stop_on_error:false` later steps still run (`completed:2`) even though the
whole call says error; with `true` it stops at the first failure. Parse the string
a second time before using it.

## Long jobs

`file.exportMedia` with `wait:true` blocks until the file is written.
`wait:false` returns immediately:

```json
{"job":1,"path":"/abs/out.mp4.mov","poll":"jobs.list","cancel":"jobs.cancel"}
```

`jobs.list` is a **command** (`command_run {id:"jobs.list"}`), not a tool. Poll it:

```json
[{"id":1,"label":"Export out.mp4.mov","status":"Exporting 96 frames (Apple ProRes)",
  "progress":0.0416,"done":4,"total":96,"etaSeconds":null,"finished":true,
  "offlineMedia":[],"result":{"bytes":…,"frames":96,"path":"…"}}]
```

`jobs.cancel {job:1}` stops the encode at the next batch, deletes the partial
file (verified: file absent afterwards) and marks the job
`finished:true, result:{"error":"cancelled"}`. `etaSeconds` is `null` until a
second of progress is measured (and once done).

`file.exportMedia wait:true` also carries `offlineMedia` in its result; a CLI
export additionally warns on stderr and exits 1 (see `cli.md`).

MCP `notifications/progress` (with `_meta.progressToken`) and
`notifications/cancelled` are documented but were **not exercised** by these
probes; `jobs.list` + `jobs.cancel` were used instead.

## Resources

| URI | Size (demo project) | Contents |
|---|---|---|
| `filmcraft://document` | ~48 KB | same as `doc_inspect` (`{project, sequence}`) |
| `filmcraft://commands` | ~192 KB | the full catalog, same as `command_list` |

Both `application/json`; read with `resources/read`. Prefer `doc_inspect` while
editing (smaller, refreshable); use the commands resource when you need the whole
catalog at once.

## Control channel (bridge mode)

One JSON request per line, one reply per line. Methods used by the MCP `ui_*`
tools (call any with `ui_control {method, params}`):

| Method | Params | Returns |
|---|---|---|
| `ui.inspect` | – | tool, workspace, panels, timeline view, playback, selection, dialog, elements count |
| `ui.elements` | `{prefix?}` | `[{id,label,rect:[x,y,w,h],…}]` |
| `ui.click` | `{id}` or `{x,y}`, `button`, `count`, `modifiers` | `null` |
| `ui.drag` | `{from:{x,y},to:{x,y},steps}` | `null` |
| `ui.key` | `{key:"Space"|"Cmd+Z"|"Shift+Delete"}` | `null` |
| `ui.type` | `{text}` | `null` |
| `ui.screenshot` | `{panel?, max_side?}` | PNG content |
| `ui.set` | `{tool, workspace, mode, theme, timeline:{pps,scroll}, panels:{…}, clipDialog:{…}, …}` | `null` |
| `ui.menu.list` | – | `[{id,label,path,shortcut,enabled}]` |
| `ui.playback` | `{}` (or `{playing:bool}`) | `{playhead, playing}` |
| `ui.panel.show` | `{panel:"effects"}` | `null` |
| `ui.scroll` | `{id,x,y,dx,dy}` (needs a target) | `null` |

`ui.set {workspace:"Color"}` and `window.workspace.color` are equivalents; the
latter is a **bridge-only command id that `command_list` does not report**
(see bugs).

`ui_inspect` top-level keys: `window` (points), `ui`, `elements` (**count**),
`activeSequence`, `selection`, `playhead`, `playback`, `sourcePlayback`,
`dialog`, `keyboardFocus`, `input`, `fps`, `pixelsPerPoint`. `ui.ui` holds `tool`,
`workspace`, `dock`, `panels`, `timeline` (`pps`, `scroll`, sizes), `language`,
plus a long list of panel visibility flags. Dialog values live in `ui.dialog`
(e.g. `{"dialog":"newSequence"}` then `"SequenceSettings"` once it is open).

## Bridge-only commands (verified)

```
window.workspace.editing   -> {"workspace":"Editing"}
window.workspace.assembly  -> {"workspace":"Assembly"}
window.workspace.color     -> {"workspace":"Color"}
window.workspace.effects   -> {"workspace":"Effects"}
window.workspace.audio     -> {"workspace":"Audio"}
window.workspace.reset     -> {"workspace":"<current>"}   (resets the layout)
window.toggleFullScreen    -> {"fullScreen":true|false}
app.about                  -> null (opens About)
```

Unknown names under `window.workspace.*` return
`app: unknown workspace 'graphics'`, so the valid set is the five above plus
`reset`. Headless rejects all `window.*` ids with `unknown command`.

## Errors that are not JSON-RPC errors

- A command that panics is reported as `internal error: …` and the session stays
  usable (documented; not reproduced here).
- A bad JSON line gets `-32700` (id `null`) and the server keeps serving
  (documented; not reproduced here).
- `tools/call` for a non-tool (e.g. `jobs.list`) → `-32602 tool not found`.
  Use `command_run` for commands and tools only for the 17 real tools.
