# MCP, control channel, coordinates, windows

## MCP servers

```sh
figcraft-cli mcp                        # headless, in-process engine, no window
figcraft-cli mcp --attach 47801         # drive a running app (also --attach 127.0.0.1:47801)
figcraft-cli mcp --automation-read-root /work --automation-write-root /work/out
```

Handshake (verified): protocol `2025-06-18`, server `figcraft` 0.8.0, 18 tools, capabilities for
tools/resources/prompts (no list changes, no resource subscribe). stdio JSON-RPC, one JSON object
per line.

`~/.config/opencode/opencode.json` stores servers under `mcp.servers` (merge, don't replace):

```jsonc
{
  "mcp": {
    "servers": {
      "figcraft":     { "type": "local", "command": ["/usr/bin/figcraft-cli", "mcp"] },
      "figcraft-app": { "type": "local",
                        "command": ["/usr/bin/figcraft-cli", "mcp", "--attach", "47801"] }
    }
  }
}
```

OpenCode exposes them in Code Mode as `tools.figcraft.*` and `tools["figcraft-app"].*`. The app
server only connects if something is listening on 47801 when OpenCode starts it; otherwise the
headless server still works.

## The 18 tools

| Tool | Arguments (all optional unless marked) | Notes |
|---|---|---|
| `list_commands` | `filter?` | literal, case-insensitive substring; returns id/label/menu/params/shortcut/undoable |
| `run_command` | `command`, `params?` | the whole engine; errors are tool errors |
| `batch` | `commands[{command,params?}]`, `label?` | one undo step, stops at first failure, `{"$step":n}` |
| `create_node` | `type`, `x? y? width? height? parent? index? name? text? path? props?` | `type` enum of 12; x/y relative to parent |
| `set_properties` | `ids`, `props` | returns `{nodes:[…], ok:true}`; unknown props rejected |
| `inspect_document` | `depth?`, `allPages?` | summary + pages + layer tree + styles + selection + history |
| `get_node` | `id`, `depth?` | one layer; `absoluteBounds` is page-space |
| `select` | `ids` | replaces selection; `[]` deselects |
| `export` | `ids?`, `format`, `scale?`, `size?`, `path?`, `bleed?`, `cropMarks?`, `bleedMarks?`, `cmyk?`, `svgOutlineText?` | without ids: selection, else page; without path returns base64 |
| `screenshot` | `ids?`, `scale?`, `maxSize?`, `window?` | design render; `window:true` captures the app (attached) |
| `open_file` | `path`, `variables?` | `.figcraft/.json/.fig/.svg/image`; `{document, opened:{index, summary, repairs}}`; an already-open file gives `{opened:{index}}` only |
| `save_file` | `path?` | native save; **does not validate the extension** |
| `undo` / `redo` | — | one command/batch/gesture per step |
| `pointer` | `kind`, `x`, `y`, `to?`, `steps?`, `tool?`, `shift? alt? cmd? ctrl?` | page coords; `to` is `[x,y]`; kinds click/double/down/move/up/drag/hover |
| `key` | `key`, `shift? alt? cmd? ctrl?` | canvas shortcut, e.g. `R`, `Delete`, `,` with cmd |
| `type_text` | `text`, `id?` | replaces characters, or types into the open edit |
| `inspect_ui` | — | attached: tool/view/panels/timings/windows/status |

Resources: `figcraft://document` (active document JSON), `figcraft://commands` (catalog, ~150 KB).
Templates: `figcraft://node/{id}` (one layer, depth 2) and `figcraft://command/{id}` (one command's
params/shortcut) — an unknown id returns `resource not found`. Prompts: `mobile_screen`,
`design_system`, `landing_page`, `prototype_flow` — they return step recipes that use
`run_command` and `frame.create {preset:…}`.

Unknown tool → JSON-RPC error `-32602 unknown tool`. Unknown resource → `-32002 resource not found`.
Invalid args are tool errors (`isError:true`) with the engine message; a successful call may still
be a silent no-op (see `bugs-and-workarounds.md`).

## Coordinates

- Page units = px at 100% zoom, y **down**, origin at the page's top-left. Frames sit anywhere.
- `create_node`/`set_properties` `x`/`y` are relative to the **parent frame**; the page when there
  is no parent. `get_node.x/y` reports the same relative value; `absoluteBounds` is page-space.
- Groups, boolean groups, sections and components do **not** create a coordinate space: layers in
  them are still positioned in the surrounding frame/page.
- In auto layout, the engine owns child positions; set layout properties instead of x/y.
- Pointer coordinates are always page coordinates, at any zoom (verified at 50%).
- Off-page coordinates are accepted (nothing to hit, no error).

## Control channel (what `--attach` speaks)

```sh
figcraft --control 47801 [file.figcraft|file.svg|image]
```

- Loopback only (`127.0.0.1`), newline-delimited JSON, one reply per request, in order.
- Request `{"id":n,"method":"…","params":{…}}` → reply `{"id":n,"ok":true,"result":…}` or
  `{"id":n,"ok":false,"error":"…"}`.
- Requests run on the UI thread at the next frame, so replies reflect real UI state.
- Limits: 32 MiB per request line; 60 s UI timeout; 60 s inactivity timeout; at most 8 queued
  requests per socket queue and per UI queue; a full queue replies
  `control request queue is full`. Non-JSON input gets an error and closes the connection.
- `--automation-read-root DIR` / `--automation-write-root DIR` (repeatable) confine every path;
  refusals say `automation path rejected: …`. A malformed flag exits with `unknown option` and
  never starts unconfined. The CLI takes the same flags on every subcommand.

Methods: `engine.execute {command, params?}`, `engine.commands {}`,
`document.inspect {depth?, allPages?}`, `node.get {id, depth?}`, `ui.inspect {}`,
`ui.pointer {kind, x, y | sx, sy, to?, steps?, shift?, alt?, cmd?, ctrl?, pressure?, pressureTo?}`,
`ui.key {key, shift?, alt?, cmd?, ctrl?}`, `ui.type {text}`, `ui.input {events}` (batched input),
`ui.menu.invoke {id}`, `ui.set {rightTab?, leftTab?, theme?, palette?, mainMenu?, focusRegion?,
layerFilter?, presentScroll?, …}` (panel/dialog state), `ui.screenshot {path?}`,
`ui.render {path?, scale?, ids?}`, `window.new {path?, index?}`, `window.list {}`,
`window.focus {id}`, `app.quit {}`.

There is no `window.resize` method; size the window through the desktop, not the protocol.
`ui.menu.invoke` takes a command id (the menu item's id, not its label); the same ids are in
`command-index.md`.

## Attached mode behaviour (verified)

- `inspect_ui` reports `status`, `tool`, `canvas`, `panels`, `windows`, `tabs`, `frameMs`,
  `framesDrawn`, `renderMs`, `dark`, `uiScale` and other UI state (43 keys). In attached mode there
  is **no `backend` field** (headless reports `backend:"headless"` and `message`), and there is no
  `view` key either — use `view.get` for zoom/centre. Both contradict the docs' field list.
- `screenshot {window:true}` returned a 1440×900 PNG.
- `pointer`/`key`/`type_text`/`screenshot` and any command that redraws require the window to be
  drawn. On Wayland a covered or minimised window is not drawn and cannot be detected; the request
  waits for the 60 s UI timeout and fails with
  `timed out waiting for the UI: screenshots and input need the FigCraft window on screen (is it
  minimised or covered?)`.
- One observed failure mode: after such a timeout (with the client killed by a shell timeout), the
  control channel stopped answering new connections, including `initialize`, until the app was
  killed and restarted. Keep UI tests short and the window in front; if `initialize` hangs, you are
  already wedged — restart your own instance.
- Headless mode has no window, so `pointer`/`key`/`type_text`/`window` screenshots are meaningless
  or error; use `screenshot`/`export` and the command engine instead.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `mcp --attach` prints nothing and exits | port not listening, or the app is wedged; check `ss -ltn \| grep 47801`, restart your own app |
| Every request hangs, including `initialize` | wedged UI queue after a timeout; kill only your PID and relaunch |
| `timed out waiting for the UI` | window covered/minimised on Wayland; bring it to the front |
| `no such node N` | wrong id, or the page that held it was deleted; ids are not reused |
| `nothing to export` | selection empty and no page content, or ids stale; `select.none` for the page |
| `control request queue is full` | more than 8 in flight; await replies, don't fire-and-forget |
| `automation path rejected` | path outside `--automation-read-root`/`--automation-write-root` |
| file written but wrong type | extension is not checked; look at `file(1)` |
| png/svg/pdf of the wrong thing | export defaulted to the selection; pass `ids` or deselect |

## Concurrency

- One FigCraft app instance per control port. Two agents attaching to the same port share one
  document and selection — coordinate or use separate ports and separate test roots.
- Headless `figcraft-cli mcp` processes are independent; each has its own in-memory documents.
- FigCraft writes preferences to `~/.config/figcraft` (recent files, panels). Running a second
  instance is fine, but recent-file state is shared.
- Do not send global keyboard/mouse events to the session while another GUI test runs; drive only
  the window you launched, through its control port.
