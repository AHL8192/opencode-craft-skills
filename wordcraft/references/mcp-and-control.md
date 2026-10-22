# WordCraft MCP and control protocol

Two agent surfaces share one engine:

1. **MCP over stdio** — `wordcraft-cli mcp`, optionally bridged to a running app.
2. **Control protocol** — line-delimited JSON on `127.0.0.1:<port>`, used by the
   bridge and available to scripts directly.

Everything ultimately calls `engine.execute` with a command id from
`engine.commands`. The MCP tools are convenience wrappers.

## MCP server

```sh
wordcraft-cli mcp                                   # headless engine, no window
wordcraft-cli mcp --author "OpenCode (copyedit)"    # name the agent's edits
wordcraft-cli mcp --automation-read-root DIR --automation-write-root DIR
wordcraft-cli mcp --connect 127.0.0.1:7981          # bridge to the running app
```

- Transport: JSON-RPC 2.0 over stdio, one object per line.
- Observed protocol version: `2025-06-18`; serverInfo `{name:"wordcraft",
  title:"WordCraft", version:"0.9.0"}`.
- Capabilities: `{tools:{}, resources:{}}`.
- The server returns an `instructions` string with the command-first workflow.
- `--connect` cannot be combined with automation roots (error). The bridge is
  unconfined.
- The bridge reads the app key from `WORDCRAFT_CONTROL_KEY`, else from the key
  file for that port, and re-reads it on every new connection (survives app
  restarts). It sends the key only to loopback addresses.

### Tools

| Tool | Input | Output / notes |
|---|---|---|
| `list_commands` | `{query?}` | JSON list of `{id,label,location,shortcut,params,enabled}` |
| `execute` | `{command, params?}` | command result; unknown id → `isError:true` |
| `batch` | `{commands:[{command,params?}\|id], keepGoing?}` | array of results; stops at first error unless `keepGoing` |
| `new_document` | `{template?: "blank\|sample\|letter\|resume\|report"}` | replaces the document |
| `open_document` | `{path, password?}` | `{path, words, paragraphs, encrypted}` |
| `save_document` | `{path?}` | `{path, saved, encrypted}`; format from extension |
| `type_text` | `{text, paragraphs?}` | replaces selection; `paragraphs:true` splits `\n` |
| `select_text` | `{text, occurrence?}` | 1-based occurrence |
| `get_text` | `{}` | `{text}` — tracked deletions omitted |
| `inspect_document` | `{}` | structure JSON (blocks, runs, tables, sections, pages) |
| `render_page` | `{page?, scale?}` | PNG image + `{width,height,pages}`; page 1-based, scale px/pt |
| `parity` | `{}` | `{live, total, percent, tabs:[…]}` |
| `screenshot` | `{}` | PNG of the window; **only meaningful with `--connect`** |
| `click` | `{x,y,count?,shift?,cmd?}` | window pixels; app only |
| `key` | `{key, shift?, alt?, cmd?}` | app only, e.g. `{key:"B",cmd:true}` |
| `ui_inspect` | `{}` | app only; UI state |

The app-only tools are advertised by the headless server too, but they need the
bridge to do anything.

**Story scoping (observed in 0.9.0):** `get_text` and `select_text` operate on
the **active story**, not always the body. After inserting a footnote the caret
is in the note story, so `get_text` returns the note and `select_text` cannot
find body text. `inspect_document` still returns every block and `parts`.
Return to the body explicitly:

```json
{"command":"caret.set","params":{"pos":{"story":"body","path":[6],"off":35}}}
```

Use the last body block from `inspect_document` for `path` and its `len` for
`off`. Also collapse a selection before `references.footnote`, or the reference
replaces the selected text.

`execute` result shapes vary: cursor positions `{anchor,focus}`, objects,
arrays or plain values. Read the result rather than assuming.

### Resources

| URI | Contents |
|---|---|
| `wordcraft://document` | same as `inspect_document` |
| `wordcraft://commands` | every command with metadata |

Read them through the client's MCP resource API (OpenCode:
`read_mcp_resource`), useful when you want the full catalog in one payload.

### Error semantics

- Unknown command: MCP result `isError:true`, text `unknown command \`id\``.
- A failed command leaves the document unchanged.
- `batch` without `keepGoing` stops at the first failure. With `keepGoing:true`
  it returns entries such as:

```json
[{"command":"format.notACommand","ok":false,"error":"unknown command …"},
 {"command":"format.bold","ok":true,"result":{…}}]
```

## Control protocol

Start the window with a port (or `WORDCRAFT_CONTROL_PORT=7981`):

```sh
wordcraft --control 7981
```

- Listens on `127.0.0.1` only.
- One JSON object per line; one reply line per request.
- Request: `{"id":1,"key":"…","method":"engine.execute","params":{…}}`
- Reply: `{"id":1,"ok":true,"result":{…}}` or `{"id":1,"ok":false,"error":"…"}`.
- A method name that is a command id works directly: `{"method":"format.bold"}`.

### Keys and limits

- Random 256-bit key per app start, written to
  `<settings>/control-key.<instance>` with mode 0600.
- Linux `<settings>` = `$XDG_CONFIG_HOME/wordcraft` (default
  `~/.config/wordcraft`); instance `local-<port>` outside Flatpak.
- Send `key` top-level on every request, or authenticate once per connection:
  `{"method":"auth","key":"…"}`. After that, requests may omit it.
- Wrong/missing key → `{"ok":false,"error":"unauthorized"}` and the app closes
  the connection.
- Line limit 1 MiB → `line too long` and close.
- No authorised request within 30 s → close. After authorisation the connection
  may stay idle.
- Invalid JSON → one error reply, then close. (This prevents an HTTP request from
  driving the port.)
- `WORDCRAFT_PROFILE_DIR` overrides the whole profile folder for isolated runs.
- `WORDCRAFT_CONTROL_KEY` supplies the bridge key; for a remote app, forward the
  port to loopback and set this variable.

### Methods

| Method | Params | Result |
|---|---|---|
| `engine.execute` | `command`, `params` | the command's result |
| `engine.commands` | `{search?}` | command catalog filtered case-insensitively |
| `document.inspect` | `{text?}` | blocks, parts, sections, selection, pages |
| `ui.inspect` | — | window/view/dialog/page rects/caret/balloons/perf |
| `ui.click` | `x,y,button?,count?,shift?,cmd?,alt?` | pointer in window pixels |
| `ui.clickText` | `page` (0-based), `x,y` (page points), `count?` | click inside a page |
| `ui.move` / `ui.drag` | `x,y` / `x,y,toX,toY,steps?` | pointer move / drag |
| `ui.press` / `ui.release` | `x,y`, modifiers | button down/up (screenshot mid-drag) |
| `ui.wheel` | `x,y,dy,dx?,unit?,phase?,modifiers` | scroll (`dy<0` scrolls down) |
| `ui.key` | `key,shift?,alt?,cmd?` | key through egui, shortcuts apply |
| `ui.text` | `text` | typed text through egui |
| `ui.screenshot` | `path?` | PNG, written to path or base64 `png` |
| `ui.render` | `path?,page?,scale?` | page PNG, path or base64 |
| `ui.parity` | — | feature parity |
| `ui.resize` / `ui.focus` / `app.quit` | — | window control |

UI settings commands also exist as engine commands: `ui.tab`, `ui.dialog`
(`{name, part?}` opens New/Modify Table Style on `wholeTable`, `headerRow`,
`firstColumn`, `bandedRows`, `nwCell`…), `ui.backstage`, `ui.language`,
`ui.theme`, `ui.interfaceSize`, `ui.animations`, `ui.fileBrowser`,
`ui.caretAnimation`, `ui.startScreen`, `ui.alignmentGuides`,
`ui.quickAccessToolbar`, `ui.contextMenu`, `ui.zotero.*`.

### Keyboard/text input is queued

`ui.key` and `ui.text` reply `{"queued":true}` when accepted — that means queued,
not applied. Input lands on subsequent UI frames. Inspect the document or widget
state before continuing with an operation that depends on it. Do not replay an
edit merely because the effect is not immediate.

Input goes to the window's focused widget even when another app is in front. A
Find field receives text; the document only while its canvas has keyboard focus.
Shortcuts, dialogs and document protection still apply. These methods do not
raise the window; use `ui.focus` for native activation.

### Closing documents

`file.close` through the control channel or bridge never shows the Save prompt:

- Unsaved changes → error, document stays open.
- `{"force":true}` → discard changes and close.
- Only a boolean `true` counts.
- Closing closes the document, not the app; the window stays with no page and
  `file.new`/`file.open` continues from there.

### Printing

- `ui.printSettings {}` inspects printers, selected printer, copies, duplex,
  grayscale, discovery/submission status and errors.
- `{"refresh":true}` starts discovery; poll until `discovering` is false.
- Set `printer`, `copies` 1–999, `duplex`
  (`printerDefault|off|longEdge|shortEdge`), `grayscale`.
- `ui.printSubmit` submits the print-ready PDF without a dialog; poll until
  `busy` is false and check `status`/`detail`.
- `ui.printSubmit`/`ui.print` accept `range`, `pages`, `parity`, `copies`,
  `collate`, and `paper` (Scale to paper size). `file.printPdf` takes them too.
- PDF export is separate from native printing.

## Confining a headless server

```sh
wordcraft-cli mcp --automation-read-root /work/project \
                  --automation-write-root /work/project/out
```

- Read root covers: `file.open`/`open_document`, `file.newFromTemplate`,
  `insert.textFromFile`, `insert.object`, `insert.picture`/`picture.change`
  with a path, `mailings.recipients` with a path (CSV/TSV/TXT/XLSX/XLSM/ODS),
  `review.compare` (`path` and `original`), templates/documents read by
  `tools.updateStyles`, `styles.organizer`, `styles.copyFrom`, and pictures
  named by an opened HTML file (from beside it; outward links are not followed).
- Write root covers: `save_document`, `file.save`, `file.saveAs`,
  `file.rename` (old and new name), `file.exportPdf`, `file.exportPng`,
  `file.printPdf`, `file.saveTemplate`, `mailings.finish` with a path.
- Read and write are separate. A root left out grants none of that access.
- Paths are made absolute against the server's working directory, then symlinks
  are followed. A link leading outside a root is outside. For not-yet-existing
  files, the nearest existing folder is resolved and the rest must be plain
  names (`..` below a missing folder is refused).
- Comparison is by whole folder names: `/work2/x` is not inside `/work`.
- Roots must already exist; a missing one stops the server.
- Refusals are normal tool errors, e.g. `automation path rejected: outside the
  write root …` or `automation filesystem access is not granted …`.
- **Not covered:** pathless commands (`text.insert`, `execute` on the open
  document) can still change it; `get_text`/`inspect_document` still return it.
  Zotero talks over a socket, not files.
- Check-then-open has a TOCTOU race; roots constrain the agent, not other local
  software.
- The **desktop app bridge has no equivalent confinement**.

## Raw protocol example

```sh
KEY=$(cat ~/.config/wordcraft/control-key.local-7981)
python3 - "$KEY" <<'PY'
import json, socket, sys
key = sys.argv[1]
s = socket.create_connection(("127.0.0.1", 7981))
for i, msg in enumerate([
    {"id":1,"key":key,"method":"engine.execute",
     "params":{"command":"text.insert","params":{"text":"Hello"}}},
    {"id":2,"method":"document.inspect"},
], 1):
    s.sendall((json.dumps(msg)+"\n").encode())
    print(s.makefile().readline().strip())
PY
```

Correct ordering matters; use one file object or read exactly one line per
request.
