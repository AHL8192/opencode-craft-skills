# GridCraft MCP and control channel

GridCraft 0.9.0 exposes the same command engine through three interfaces:

1. **MCP over stdio** — `gridcraft-cli mcp` (headless) or
   `gridcraft-cli mcp --connect PORT` (bridge to a running window).
2. **Control channel** — newline-delimited JSON over TCP, started with
   `gridcraft --control PORT` (default in this skill: `7979`).
3. **CLI** — `gridcraft-cli …`; see `cli.md`.

The GUI ribbon, shortcuts, command search and scripts all call the same
`command` ids. There is no separate “agent API” with different semantics.

## OpenCode configuration

On this machine the entries live under `mcp.servers` in
`~/.config/opencode/opencode.json`:

```json
"gridcraft": {
  "type": "local",
  "command": ["/usr/bin/gridcraft-cli", "mcp"]
},
"gridcraft-app": {
  "type": "local",
  "command": ["/usr/bin/gridcraft-cli", "mcp", "--connect", "7979"]
}
```

They appear as `tools.gridcraft.*` (headless) and `tools["gridcraft-app"].*`
(live window). The headless server owns its own in-process workbook; it does not
see the GUI's open documents. The app server forwards to the window.

Start the window before using `gridcraft-app`:

```sh
gridcraft --control 7979 &
# wait for the port
ss -ltn | grep 7979
```

If the port is occupied, use another free port and update the MCP entry. Do not
connect to a port owned by another session.

## MCP handshake

Protocol `2025-06-18`; serverInfo `{"name":"gridcraft","title":"GridCraft",
"version":"0.9.0"}`. The stdio framing is one JSON-RPC object per line.

```
→ {"jsonrpc":"2.0","id":1,"method":"initialize","params":{
     "protocolVersion":"2025-06-18","capabilities":{},
     "clientInfo":{"name":"my-agent","version":"1"}}}
← {"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"2025-06-18",
     "capabilities":...,"serverInfo":{"name":"gridcraft",...}}}
→ {"jsonrpc":"2.0","method":"notifications/initialized","params":{}}
→ {"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
→ {"jsonrpc":"2.0","id":3,"method":"tools/call","params":{
     "name":"write_range","arguments":{"range":"A1","values":[["x",1]]}}}
```

A tool result is `result.content[0].text` containing JSON. A command-level
failure normally returns `result.isError:true` with a text message (for
example `open_workbook: No such file or directory`). An invalid argument shape
can instead produce a JSON-RPC error such as `-32602 unknown argument \`sheet\``
— check both `error` and `isError`.

Useful resources:

- `gridcraft://workbook` — same data as `document.inspect`.
- `gridcraft://commands` — all 341 commands with params and enabled state.
- `gridcraft://functions` — all 514 worksheet functions.

Resources can be read through the MCP resources API; the `list_commands` and
`list_functions` tools are usually easier in agent code.

## The 21 MCP tools

| Tool | Arguments | Important behavior |
|---|---|---|
| `execute_command` | `{command, params?}` | Runs any command id. Unknown ids error; most missing params error. |
| `list_commands` | `{search?}` | Returns id, label, menu, shortcut, params, enabled. |
| `inspect_workbook` | `{}` | Active workbook summary; selection and history included. |
| `read_range` | `{range?, sheet?, formulas?, formatted?}` | 2-D rows; no range = used range. Errors are objects. |
| `write_range` | `{range, values}` | `range` is the **top-left anchor**; values determine extent; one undo step. |
| `set_cell` | `{cell, input}` | Types exactly like the formula bar; `=…` is a formula. |
| `get_cell` | `{cell}` | Full cell detail; **no `sheet` argument** (use `cell.get`). |
| `evaluate_formula` | `{formula, cell?}` | Computes without writing; `cell` sets relative-reference origin. |
| `select` | `{range, active?}` | Supports multiple areas and `Sheet2!` prefixes. |
| `format_range` | `{range, bold?, …}` | Runs each format command in sequence; partial failure possible. |
| `insert_chart` | `{range, type, subtype?, title?, at?}` | Returns chart id; unsupported types may silently fall back. |
| `create_table` | `{range, header?, style?, name?}` | Header row by default. |
| `sort_range` | `{keys, range?, header?}` | Keys may be strings or `{column,order}` objects. |
| `filter` | `{column, values?, custom?, top?, clear?}` | Hides rows; `clear` removes that column's filter. |
| `open_workbook` | `{path}` | Already-open path returns `alreadyOpen` and does not reload. |
| `save_workbook` | `{path?}` | Extension picks format; omit path to overwrite. |
| `new_workbook` | `{sample?}` | `budget`, `sales`, `grades`. |
| `undo` / `redo` | `{steps?}` | One workbook history. |
| `screenshot` | `{path}` | **App bridge only**; headless returns an error. |
| `list_functions` | `{search?, category?}` | Function catalog; descriptions included. |

Examples:

```js
const gc = tools.gridcraft;                 // headless
// const gc = tools["gridcraft-app"];       // live window
const run = (command, params={}) => gc.execute_command({command, params});

await gc.new_workbook({});
await gc.write_range({range:"A1", values:[["Item","Cost"],["Rent",1200]]});
await run("home.bold", {range:"A1:B1"});
await run("home.numberFormat", {range:"B2", format:"Currency"});
const values = await gc.read_range({range:"A1:B2", formatted:true});
const formula = await gc.evaluate_formula({formula:"=SUM(B2:B2)"});
await gc.save_workbook({path:"/tmp/gridcraft-demo.xlsx"});
```

`write_range` with a 2×2 array at `A1` fills `A1:B2` even if you pass
`range:"A1:D10"`. A 1-D array fills one row. Empty values is a silent no-op.
This is different from `set_cell`, which writes exactly one cell.

## Control channel

Start:

```sh
gridcraft --control 7979 &
```

The listener binds `127.0.0.1` and has **no authentication**. Each request is
one JSON object followed by `\n`; each response is one JSON object:

```json
{"id":1,"method":"ui.inspect","params":{}}
{"id":1,"ok":true,"result":{...}}
{"id":2,"ok":false,"error":"unknown method `nope`"}
```

A minimal client:

```python
import json, socket
s = socket.create_connection(("127.0.0.1", 7979), timeout=10)
f = s.makefile("rwb")
f.write((json.dumps({"id":1,"method":"ui.inspect","params":{}})+"\n").encode())
f.flush()
print(json.loads(f.readline()))
s.close()
```

### Tested control methods

| Method | Params | Purpose |
|---|---|---|
| `app.open` | `{path}` | Open a workbook in the window. |
| `app.save` | `{path?}` | Save active workbook. |
| `engine.execute` | `{command, params}` | Run any command id. |
| `engine.commands` | `{search?}` | Command catalog. |
| `document.inspect` | `{}` | Workbook/selection/sheets/charts/history. |
| `sheet.read` | `{range?, sheet?, formulas?, formatted?}` | Read values. |
| `cell.get` / `cell.set` | `{cell, …}` | Cell detail / typed input. |
| `ui.inspect` | `{}` | Window, grid rectangle, scroll, mode, dialog, editor, docs. |
| `ui.focus` | `{}` | Bring the window to the front; **use before input**. |
| `ui.screenshot` | `{path}` | Whole-window PNG. |
| `ui.cell.click` | `{cell}` | Click a cell; returns window `{x,y}`. |
| `ui.click` | `{x, y, count?, shift?, ctrl?}` | Click at window pixels (top-left = 0,0). |
| `ui.key` | `{key, ctrl?, shift?, alt?}` | Key press, e.g. `{key:"B",ctrl:true}`. |
| `ui.text` | `{text}` | Type into the active editor; does not open edit mode by itself. |
| `ui.edit.begin` | `{text?}` | Enter cell-edit mode, optionally prefilled. |
| `ui.edit.text` | `{text}` | Replace the editor contents (not append). |
| `ui.edit.commit` | `{move?: "down"|"right"}` | Commit the edit and optionally move. |
| `ui.edit.cancel` | `{}` | Discard the edit. |
| `ui.ribbon` | `{tab}` | Switch ribbon tab (`Home`, `Insert`, …). |
| `ui.dialog` | `{name}` | Open a named dialog: `formatCells`, `sort`, `dataValidation`, `nameManager`, `pageSetup`. |
| `ui.dialog.set` | `{field, value}` | Set a dialog field (field names are dialog-specific). |
| `ui.dialog.confirm` / `.cancel` | `{}` | Confirm/cancel; see the dialog caveat below. |
| `ui.resize` | `{width, height}` | Resize the window; re-inspect grid coordinates after. |

`ui.inspect` returns at least:

```json
{"activeDocument":0,"documents":[{"title":"Book1","dirty":false}],
 "window":[1440,900],"grid":[28,215,1398,627],
 "scroll":[0,0],"mode":"Ready","dialog":null,"editor":null,
 "selectedChart":null,"ui":{"ribbonTab":"Home","interfaceScale":100}}
```

`window` and `grid` are in pixels at the current scale. `ui.cell.click` converts
a cell to window coordinates using the current scroll and returns the point it
used. The grid strip at 1440×900 was `[28,215,1398,627]`; sheet tabs sit near
the bottom (around `y=860`). Do not hard-code these numbers in scripts; inspect
first.

### GUI workflow

```python
def call(method, **params):
    return session([{"method":method, "params":params}])[0]

call("ui.focus")                 # required if another app/dialog has focus
call("ui.cell.click", cell="C3")
call("ui.edit.begin", text="=SUM(A1:A3)")
call("ui.edit.commit", move="down")
assert call("cell.get", cell="C3")["result"]["formula"] == "=SUM(A1:A3)"
call("ui.screenshot", path="/tmp/gridcraft.png")
```

GUI changes are asynchronous: after `ui.cell.click`/`ui.edit.commit`, wait
0.3–0.5 s before `document.inspect` or a screenshot, or the reported selection
can still be the previous cell even though the grid has moved.

Keyboard editing is inconsistent: `ui.key` with a letter or `ui.text` by itself
does not reliably start cell editing. Use `ui.edit.begin` → `ui.edit.text` →
`ui.edit.commit`, or press `F2` and then use the editor. `ui.edit.text` replaces
the prefilled value. Commit or cancel before clicking another cell.

`ui.cell.drag` did **not** create a range selection in 0.9.0; it left one cell
selected and entered edit mode. Use `select({range:"B2:C3"})` or keyboard
selection; no reliable drag-range method was found. `edit.goTo` moves the
selection but does not scroll; use Ctrl+Down/PageDown or click after scrolling.

### Dialog caveat

`ui.dialog({name})` opens internal dialogs. Unknown names return
`{"dialog":null}` with success. `ui.dialog.set` accepts arbitrary fields and can
return them even when the dialog ignores them. `ui.dialog.confirm`:

- `dataValidation`: applies.
- `sort`, `formatCells`, `nameManager`: fails with
  `"this dialog has no OK command; drive it with its own commands"`.
- `pageSetup`: returns success but does **not** apply the values.

Prefer the underlying command (`data.sort`, `home.formatCells`,
`formulas.defineName`, `pageLayout.pageSetup`). The dialog is useful for
inspection/screenshots, not for reliable edits.

## Security and process hygiene

- The control channel can open/save files, execute commands, and quit the app.
  It binds localhost only; never expose it to a network or paste it into a
  remote service.
- The app bridge is unconfined. For untrusted documents prefer headless mode.
- Write GUI/helper PIDs under your own test root; never `pkill gridcraft`.
- `file.close {force:true}` discards unsaved changes without a prompt. Save a
  copy first.
- If the control channel stops responding, take a desktop screenshot before
  killing anything: another app may have a modal dialog focused. Focus the
  GridCraft window (`ui.focus`) and retry.
