# MCP, CLI transport and GUI control — PdfCraft 0.10.1

Verified 2026-10-22 against the installed build. Re-check after upgrades.

## OpenCode configuration

```json
"mcp": {
  "servers": {
    "pdfcraft": {
      "type": "local",
      "command": ["/usr/bin/pdfcraft-cli", "mcp"]
    }
  }
}
```

Only the headless server is configured. To confine file access, add
`--automation-read-root DIR` and/or `--automation-write-root DIR` (an omitted
side grants **no** access), or `--root DIR` for both. The default (no flags) is
unconfined: it can open/save anywhere the user can.

Do not add a second entry that runs the GUI: `pdfcraft-cli mcp` has no
`--connect` flag. Drive the window with the control channel instead.

## Handshake and tool surface

```
→ initialize {"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":…}
← serverInfo {"name":"pdfcraft","title":"PdfCraft","version":"0.10.1",…}
→ notifications/initialized
→ tools/list
```

- **171 tools** by default, **201 registry commands**.
- **`--compact`: 17 tools** — `doc_open`, `doc_info`, `doc_save`, `doc_close`,
  `page_render`, `text_extract`, `text_find`, `doc_combine`, `doc_split`,
  `edit_undo`, `command_list`, `command_run`, `command_batch`, `doc_inspect`,
  `render_preview`, `tool_search`, `tool_call`.
- `command_run {id, params}` runs any registry command. Unknown ids error;
  unknown `params` keys are ignored **with warnings**.
- `command_batch {steps:[{id,params}], stop_on_error?}` (max 1000) returns
  `completed`/`failed`/`results`; with failures it is reported as a tool error
  even when `stop_on_error:false`, so read `results` from the error payload.

## Return shapes (important)

Two families exist:

| Shape | Tools |
|---|---|
| `structuredContent` populated | most edit tools: `doc_open`, `doc_save`, `page_*` edits, `comment_add`, `form_fill`, `redact_apply`, `doc_export_text/office/images`, `doc_optimize`, `doc_reduce`, `doc_print`, `action_run` (edit), … |
| JSON only in `content[0].text` | most read/report tools: `doc_info` (full), `bookmark_list`, `link_list`, `measure_list`, `doc_hidden_info`, `doc_audit_space`, `doc_audit_redactions`, `pdfa_verify`, `pdfa_convert`, `print_readiness`, `accessibility_check`, `accessibility_report`, `ocr_status`, `ocr_recognize`, `doc_revisions`, `js_run`, `js_enabled`, `js_document_scripts`, `doc_compare`, `doc_compare_mark`, `action_run` (read), `sign_list`, `printers`, `command_list` … |

If a client shows `{}` for one of these, parse the text content. Do not treat an
empty object as “no results”.

Errors are `content:[{type:"text",text:"…"}]` with `isError:true`. Protocol-level
argument errors arrive as JSON-RPC `-32602` (e.g. `unknown argument "angle"
(expected: degrees, doc, orientation, pages, subset)`).

## Resources

`resources/list` after opening a document exposes per-document resources:

- `pdfcraft://doc/{doc}/info` — same as `doc_info` (application/json)
- `pdfcraft://doc/{doc}/text` — all pages, `Page n` headings (text/plain)
- `pdfcraft://doc/{doc}/page/{n}/text`
- `pdfcraft://doc/{doc}/page/{n}/image` — PNG

Templates: `pdfcraft://doc/{doc}/info`, `/text`, `/page/{page}/text`,
`/page/{page}/image`.

The server also advertises static `pdfcraft://document` (all open documents,
same shape as `doc_inspect`) and `pdfcraft://commands` (the full 201-command
registry, ~55 KB JSON). These are useful for discovery without a tool call.

## Document ids

`doc_open`/`doc_create` return a session-local integer id. Ids increment for the
lifetime of the server process and are **not reusable**; after close+reopen the
document gets a new id. Passing a stale id yields
`no open document with id N (see doc_list)`. Use `doc_list` after any restart.

`doc_close` refuses unsaved changes:
`the document has unsaved changes: save it with doc_save, or pass
discard_changes: true`.

## GUI control channel

Start a private app instance:

```sh
CTRL=~/.config/pdfcraft/control-skilltest-$(date +%Y%m%dT%H%M%S).json
pdfcraft --control "$CTRL" /abs/path/doc.pdf >/tmp/pdfcraft-gui.log 2>&1 &
# wait for the file:
# {"pid":123,"port":54321,"token":"…"}   (mode 0600)
pdfcraft-cli ui --control "$CTRL" state
```

- There is **no fixed port** and no `--port` flag. The app chooses a loopback
  port and writes it with a token to `CTRL`.
- Do **not** put `--` before the PDF path: `pdfcraft … -- file.pdf` is rejected
  as an unknown option. Pass the path directly.
- `pdfcraft --control FILE` with no PDF opens an empty window.
- Kill only your PID (from the control file or `$!`) and remove only your file.

### Methods

| Method | Args | Returns / notes |
|---|---|---|
| `state` | — | window, documents, active page/zoom/layout, `pages_on_screen`, `dialog`, `close_prompt`, `notice` |
| `inspect` | `query=`? | accessibility tree: role, label, id, rect, clickable/focusable/toggled |
| `screenshot` | `--out png` | whole-window PNG |
| `click` | `x= y=` or `id=` or `label=` | one widget; ambiguous duplicate labels error |
| `drag` | `from=[x,y] to=[x,y]` | pointer drag in window coordinates |
| `move` | `x= y=` | pointer move |
| `focus` | `id=` / `label=` | focus a widget (ids are per-frame) |
| `type` | `text="…"` | type into the focused widget |
| `key` | `key=Enter modifiers='["command"]'` | Ctrl = `command`, Shift = `shift`, Alt = `alt` |
| `set` | `key= page|zoom|select|layout value=…` | layout: `single`, `continuous`, `two-up`, `two-page`; select: `1,2` |
| `command` | `id=file.save` | **params are ignored** (calls `host.command(id)` only) |
| `open` | `path=/abs/doc.pdf` | returns `{accepted:…,pending:true}`; may never complete |
| `quit` | — | `{quitting:true}` or `{quitting:false,needs_confirmation:true}` |

### Coordinate mapping

`state.active.pages_on_screen` gives each visible page as
`{"page":1,"rect":[x0,y0,x1,y1]}` in window pixels. Page points map as:

```
screen_x = rect[0] + pdf_x * (rect[2]-rect[0]) / page_width
screen_y = rect[1] + pdf_y * (rect[3]-rect[1]) / page_height
```

Re-read `state` after selecting a tool (zoom can change when a tool is chosen)
and after any zoom/scroll. Verified exactly: a drag over the `text_find` rect for
“Total due” produced the saved highlight `[40.0,78.88,98.35,92.88]`.

### Widget and dialog behaviour

- egui widget ids change between frames. An id from an old `inspect` fails with
  `no widget with id … on screen (run ui.inspect again)`. Use labels or fresh
  coordinates.
- Duplicate labels are common (`Close` in the title bar and in a dialog). A
  label click errors; disambiguate with a fresh `inspect` + coordinates.
- **Properties (Ctrl+D)**: edits apply on **OK**, discard on **Cancel**. Before
  the first edit it shows `Close`; after typing it shows `OK`/`Cancel`.
  `Document properties (Ctrl+D)` in the toolbar is a button.
- **Find (Ctrl+F)**: typing a query and Enter jumps to the first match and
  selects it.
- **Unsaved quit**: `ui quit` returns `{quitting:false,needs_confirmation:true}`;
  the prompt offers Don't save / Cancel / Save. Cancel keeps the app; Ctrl+S
  saves; then quit succeeds.
- Save with `ui command id=file.save` (no params) or Ctrl+S.
- Screenshots cannot be seen by a text-only agent; use `state`/`inspect` and
  validate the saved PDF externally.

### Verified open/save flow

Argv open → `state` shows the document and `dirty:false`; drag-highlight →
`dirty:true`, `selected_comment`; `file.save` → file grows (1059→2470 bytes, 1
annotation); reopen with MCP confirms the annotation; clean quit works.

`ui.open` with a second file returned `{"accepted":…,"pending":true}` and never
completed in 0.10.1 — open additional files with argv or close the app first.

## Protocol limits

- stdio MCP and the control socket are line-delimited JSON. Control connections
  are short-lived; one request per invocation from `pdfcraft-cli ui`.
- `page_render` dpi is 1–600 (601 errors). Page numbers are 1-based.
- `command_batch` accepts at most 1000 steps.
- `doc_open` ids live per process; do not share them between sessions.
