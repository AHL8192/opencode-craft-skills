# Bugs, silent successes and workarounds — FigCraft 0.8.0

All findings below were reproduced against `figcraft 0.8.0` on 2026-10-22. Severity is from an
agent-automation point of view: does it make a script silently produce the wrong file or hang?

## High

### 1. `opacity` above 1 is reinterpreted as a percentage

```jsonc
{"command":"node.set","params":{"ids":[2],"opacity":2}}
// → success; get_node ⇒ opacity: 0.019999999552965164
{"command":"node.set","params":{"ids":[2],"opacity":-1}}
// → success; get_node ⇒ opacity: 0.0
```

Expected: clamp to 1 / reject. Actual: `2` becomes 2%, not 100%; anything negative becomes 0.
A model that writes `opacity: 100` (percent habit) makes the layer effectively invisible and gets
no error. **Workaround:** always 0–1, and read back `opacity` after setting it. Same risk for any
number that looks like a percentage; no other property showed this rescaling (width/height clamp).

### 2. Attached mode on Wayland: covered window → 60 s timeouts, then a wedged channel

With `figcraft --control 47801` running and the window alive but behind the terminal, UI-dependent
requests fail after the control protocol's 60 s UI timeout:

```text
timed out waiting for the UI: screenshots and input need the FigCraft window on screen
(is it minimised or covered?)
```

Observed sequence: `page.rename` timed out first (a command that should not need a drawn frame per
the docs), then every later call on a **new** connection hung, including MCP `initialize` and
`inspect_ui`, until the app was killed and restarted. The client had been killed by a shell timeout
while waiting, which may be part of the trigger; the wedge itself was not isolated further.

**Workaround:** keep the window in front for GUI work, keep UI sessions short, prefer headless mode
for building/exporting, and if `initialize` hangs, treat the app as wedged: kill **only the PID you
started** (`cat pids/gui.pid`) and relaunch. Do not send OS-level input to another agent's window.

Evidence: transcript error text; `ps -L` showed the process sleeping, port still listening, all
new JSON-RPC requests unanswered.

## Medium

### 3. `save_file` does not validate the extension

```jsonc
{"name":"save_file","arguments":{"path":"/tmp/card.png"}}
// → {"bytes": 2850, "path": "/tmp/card.png"}
```

`file(1)` says `Zip archive data …` — it is a native `.figcraft` archive named `.png`. Reopening it
works (content sniffing), which makes the mistake easy to miss. **Workaround:** always end native
saves in `.figcraft`; verify with `figcraft-cli info` or `unzip -l`.

### 4. Export writes the requested format, not the extension's format

```jsonc
{"name":"export","arguments":{"ids":[2],"format":"png","path":"/tmp/x.jpg"}}
// → success; file(1): PNG image data, 200 x 100
{"command":"file.export","params":{"ids":[2],"format":"pdf","path":"/tmp/x.png"}}
// → success; file(1): PDF document, version 1.7
```

`format` wins, `path` is literal. **Workaround:** derive the extension from `format` in code, or
read the result's `format` field; validate with `file`/`identify` before handing the file on.

### 5. `inspect.code` silently ignores `format` (unknown key → CSS)

```jsonc
{"command":"inspect.code","params":{"id":2,"format":"react"}}
// → {"code":"…CSS…","language":"css","connected":false}
{"command":"inspect.code","params":{"id":2,"language":"react"}}
// → language "react"
```

The command validates values but not unknown keys, so a plausible parameter name yields the wrong
language with no error. **Workaround:** `language`, and assert the returned `language` field.

### 6. `create_node` and `node.create` ignore unknown arguments

```jsonc
{"name":"create_node","arguments":{"type":"rectangle","x":0,"y":200,"width":10,"height":10,"bogus":1}}
// → creates the rectangle, no error
{"command":"node.create","params":{"type":"rectangle","bogus":1}}   // same
{"command":"node.set","params":{"ids":[2],"bogus":1}}
// → invalid parameters for `node.set`: unknown properties: bogus
```

Tool/command argument typos are silent; property typos are loud. **Workaround:** keep properties
inside `props`/`node.set` (validated), and assert the creation result (`id`, `node.type`, `width`).

### 7. CLI `commands --filter` is a literal substring, contrary to the documented example

```sh
figcraft-cli commands --filter "auto layout"   # 22 lines
figcraft-cli commands --filter autoLayout      # 0 lines
figcraft-cli commands --filter layout          # 36 lines (case-insensitive)
```

The README/docs use `--filter autoLayout`. **Workaround:** filter with the menu label's words
(`"auto layout"`), or `--json` and match yourself.

### 8. UI-thread commands time out when the window is not drawn, not just screenshots/input

The control-protocol docs say edits and inspection keep working while the window is minimised or
covered, and only a window capture needs it on screen. On Wayland the compositor stops drawing a
covered window and the app cannot tell; `page.rename` failed with the UI timeout in that state, as
did `create_node` (both normally UI-independent). **Workaround:** as in finding 2 — no GUI work
against a covered window. This is also a docs-vs-binary difference.

## Low

### 9. Negative width/height clamp to 0 without warning

`set_properties {width:-50}` → success, width `0.0`. A frame with width 0 then exports a 1 px
image (with scale 2), which looks like an export bug. **Workaround:** validate sizes before set.

### 10. Export scale is capped at 64 silently

`export {scale:1000}` succeeds; the output is at most 64× the frame. No warning in the result.
**Workaround:** cap your own scale and compute expected pixel dimensions.

### 11. A malformed `.json` array is reported as a ZIP error

```jsonc
// file containing "[[[[…" (100,000 brackets)
{"name":"open_file","arguments":{"path":"huge.json"}}
// → not a valid FigCraft file: invalid Zip archive: Could not find EOCD
```

A valid FigCraft/REST `.json` opens fine (`open_file` → `{document, opened:{index,summary,repairs}}`);
a malformed object (`{not json`) correctly reports `key must be a string at line 1 column 2`. Only
the array-shaped garbage falls through to the ZIP attempt, so the diagnostic misleads.
**Workaround:** validate JSON with `jq` before opening; trust `repairs`/`warnings` when it opens.

### 12. `file.new` opens an additional tab instead of resetting the document

After several `file.new` calls `inspect_ui.status.documents` kept growing (1 → 2 → 3 → 4), and undo
history is per document. **Workaround:** call it once at the start, track `status.documents`, and
use `file.close {index, force:true}` for tabs you created; `file.newFromTemplate` also opens a new
unsaved document.

### 13. `inspect_ui` in attached mode lacks `backend` and `view`

Headless `inspect_ui` returns `backend`, `message`, `status`, `tool`, `view`. Attached mode returns
43 keys including `windows`, `panels`, `canvas`, `frameMs`, `renderMs`, `framesDrawn` — but **no
`backend` and no `view`**. Zoom/centre come from the `view.get` command. **Workaround:** detect
attached mode by `windows`/`framesDrawn`, and query `view.get`.

### 14. The app binary rejects `--help` but `-h` launches the GUI

`figcraft --help` → exit 2, `FigCraft: unknown option …` and no usage. `figcraft -h` opens the GUI.
`--version` works. **Workaround:** use `figcraft-cli --help`, and never run `-h` in a headless
script unless you want a window.

## Silent successes — checklist

| Call | Reported | Actually |
|---|---|---|
| `save_file {path:"x.png"}` | saved | native ZIP named `.png` |
| `export {format:"png", path:"x.jpg"}` | `format:"png"` | PNG bytes in `.jpg` |
| `file.export {format:"pdf", path:"x.png"}` | `format:"pdf"` | PDF named `.png` |
| `inspect.code {format:"react"}` | success | CSS (`language:"css"`) |
| `node.set {opacity:2}` | success | opacity 0.02 |
| `node.set {opacity:-1}` | success | opacity 0 |
| `create_node {bogus:1}` | success | argument dropped |
| `node.create {bogus:1}` | success | parameter dropped |
| `node.set {cornerRadius:"12"}` | success | 12.0 (string coerced) |
| `node.set {name:123}` | success | `"123"` |
| `set_properties {width:-50}` | success | width 0 |
| `export {scale:1000}` | success | scale 64 |
| `file.new` | `{index}` | new tab, old document still open |
| `open_file` on an already-open file | `{opened:{index}}` | no summary/repairs |

## Things that failed loudly and correctly (no workaround needed)

`no such node` for stale ids/parents · `unknown command \`Node.Create\`` (case-sensitive ids) ·
`unknown property` in `node.set` · `\`fill\` must be a colour` · enum validation for `layout`,
`maskType`, `textAlign`, … · `\`visible\` must be a boolean` · `\`x\` must be a finite number` ·
`"abc" is not a layer id` · `type_text` on a frame (`is not a text layer`) · text range with
`start > end` · `no such variable` · bad expression in `proto.evaluate` · missing file/directory
(`os error 2`), permission denied (`os error 13`) · empty `batch` · malformed SVG/ZIP.

## Not bugs, but easy to misread

- `export` without ids exports the **selection** first (a 209-byte PNG was a single 24×24 rect).
  `select.none` for the page.
- `file.export` PDF with `ids` is one page; multi-page is `file.exportFramesPdf` or the CLI.
- `.fig` is explicitly experimental; check `warnings` and reopen the result.
- `file.close` refuses unsaved changes unless `{force:true}` (it never prompts).
- `page.delete` deletes the page's layers with it (undoable).
- `open_file` on an image creates a one-image document (expected, but surprising if you meant to
  place it: use `file.placeImage`).
