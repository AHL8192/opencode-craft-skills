# GridCraft recipes

All snippets use raw MCP tools. Pick the server first:

```js
const gc = tools.gridcraft;                  // headless
// const gc = tools["gridcraft-app"];        // live window
const run = (command, params={}) => gc.execute_command({command, params});
```

Every recipe ends with a read-back. Use absolute paths; do not overwrite a user
original unless that is explicitly the goal. Paths below are examples.

## 1. Build and verify a small workbook

```js
await gc.new_workbook({});
await gc.write_range({range:"A1", values:[
  ["Region", "Units", "Price", "Revenue"],
  ["East",   12,      2.50,    "=B2*C2"],
  ["West",    8,      4.00,    "=B3*C3"],
  ["Total",  "=SUM(B2:B3)", null, "=SUM(D2:D3)"]
]});
await run("home.bold",        {range:"A1:D1"});
await run("home.fillColor",   {range:"A1:D1", color:"#D9EAF7"});
await run("home.numberFormat",{range:"C2:D4", format:"Currency"});
await run("home.columnWidth", {cols:"A:D", chars:14});
await run("view.freezePanes", {cell:"A2"});

const formulas = await gc.read_range({range:"A1:D4", formulas:true});
const shown    = await gc.read_range({range:"A1:D4", formatted:true});
if (formulas.values[3][3] !== "=SUM(D2:D3)") throw new Error("formula missing");
if (shown.values[3][3] !== "$62.00") throw new Error("total wrong: " + shown.values[3][3]);

await gc.save_workbook({path:"/tmp/gridcraft-report.xlsx"});
```

The `range:"A1"` anchors the block; the array writes `A1:D4`. `null` leaves C4
empty. Verify with `gridcraft-cli check` (recipe 10).

## 2. Edit a copy without touching the original

```js
const src = "/work/in.xlsx";
const dst = "/work/out.xlsx";

await gc.open_workbook({path:src});
const before = await gc.read_range({range:"A1:D20", formulas:true});
await run("edit.replace", {what:"ACME", with:"Acme Corp", all:true, within:"sheet"});
await run("cell.set", {cell:"H1", input:"Reviewed by OpenCode"});
await gc.save_workbook({path:dst});
await run("file.close", {force:false});

await gc.open_workbook({path:dst});
const after = await gc.read_range({range:"A1:H20", formulas:true});
if (JSON.stringify(after) === JSON.stringify(before)) throw new Error("nothing changed");
await run("file.close", {force:false});
```

`save_workbook({path:dst})` leaves the original file alone. Do not call
`open_workbook({path:src})` again to “reload”: if it is already open, the call
returns `{alreadyOpen:true}` and does not read the disk. Close it first.

## 3. Table, sort and filter

```js
await gc.new_workbook({});
await gc.write_range({range:"A1", values:[
  ["Region","Units","Revenue"],
  ["East",12,30],["West",8,32],["North",5,49.95],["South",20,25]
]});
await gc.create_table({range:"A1:C5", name:"Sales", style:"TableStyleMedium9"});
await gc.sort_range({range:"A1:C5", header:true,
  keys:[{column:"C", order:"desc"}]});
await gc.filter({range:"A1:C5", column:"A", values:["East","South"]});

const info = await gc.inspect_workbook({});
const sheet = info.sheets.find(s => s.name === "Sheet1");
if (!sheet.tables.length || !sheet.autofilter) throw new Error("table/filter missing");
await gc.save_workbook({path:"/tmp/gridcraft-table.xlsx"});
```

Filtering hides rows; it does not delete them. Clear with
`execute_command {command:"data.clearFilter"}` before treating the table as a
contiguous block. `filter` turns AutoFilter on automatically.

## 4. Chart and verification

```js
await gc.new_workbook({});
await gc.write_range({range:"A1", values:[
  ["Month","Sales"],["Jan",10],["Feb",14],["Mar",9]
]});
const chart = await gc.insert_chart({
  range:"A1:B4", type:"column", title:"Quarterly sales", at:"D2"
});
await run("chart.set", {chart:chart.id, legend:"bottom", yTitle:"Units"});
await run("chart.changeColors", {chart:chart.id, palette:"colorful"});

const info = await gc.inspect_workbook({});
const charts = info.sheets[0].charts;
if (charts.length !== 1) throw new Error("chart missing");
await gc.save_workbook({path:"/tmp/gridcraft-chart.xlsx"});
```

Chart ids are valid only for the current session and shared with pictures and
shapes. After reopening, inspect again; do not reuse the old id. Supported types
include `column`, `bar`, `line`, `pie`, `doughnut`, `area`, `scatter`, `bubble`,
`radar`, `combo`, `histogram`, `waterfall`, `funnel`, `treemap`, `sunburst`,
`boxWhisker` and `stock`. `donut` silently becomes a column chart.

## 5. Conditional formatting and data validation

```js
await gc.new_workbook({});
await gc.write_range({range:"A1", values:[
  ["Item","Qty","Revenue"],["A",2,10],["B",7,55],["C",4,28]
]});
await run("home.conditionalFormat", {range:"C2:C4", rule:{
  type:"cellIs", operator:"greaterThan", value:30, preset:"greenFill"
}});
await run("data.validation", {range:"B2:B4", type:"whole",
  operator:"greaterThan", formula1:"0", ignoreBlank:false,
  errorStyle:"stop", errorTitle:"Quantity", errorMessage:"Enter a positive whole number"
});

const bad = await run("data.validate", {cell:"B2", input:-1});
if (bad.ok !== false) throw new Error("validation did not reject -1");
const info = await gc.inspect_workbook({});
if (!info.sheets[0].conditionalFormats || !info.sheets[0].validations)
  throw new Error("rule/validation missing");
```

For a list dropdown, use
`type:"list", formula1:"East,West,North,South", dropdown:true`. Validation is a
data-entry rule, not a security boundary; programmatic `set_cell` may bypass it.

## 6. Comments, hyperlinks, names, freeze and protection

```js
await gc.new_workbook({});
await gc.write_range({range:"A1", values:[
  ["Item","Price"],["Widget",2.5],["Gadget",4]
]});
await run("review.newComment", {cell:"A1", text:"Reviewed by OpenCode", author:"OpenCode"});
await run("review.replyComment", {cell:"A1", text:"Checked totals", author:"OpenCode"});
await run("insert.link", {cell:"A2", target:"https://example.com/widget",
  text:"Widget page", tooltip:"Open the product page"});
await run("formulas.defineName", {name:"Prices", refersTo:"=Sheet1!$B$2:$B$3"});
await run("view.freezePanes", {cell:"B2"});

let cell = await gc.get_cell({cell:"A1"});
if (!cell.comment) throw new Error("comment missing");
cell = await gc.get_cell({cell:"A2"});
if (!cell.hyperlink) throw new Error("link missing");
const info = await gc.inspect_workbook({});
if (!info.names.some(n => n.name === "Prices")) throw new Error("name missing");
if (!info.sheets[0].freeze) throw new Error("freeze missing");   // [rows, cols], not "B2"

await run("review.protectSheet", {password:"test-pass"});
await gc.save_workbook({path:"/tmp/gridcraft-review.xlsx"});
// Unprotect before further edits:
// await run("review.unprotectSheet", {password:"test-pass"});
```

Protection is not encryption. Do not use it to protect secrets. `review.newNote`
creates a legacy note; `review.newComment` creates a threaded comment with
replies.

## 7. CSV import with text fidelity, then XLSX

```js
await run("file.open", {path:"/tmp/accounts.csv", csvAsText:true});
const read = await gc.read_range({range:"A1:D5"});
if (typeof read.values[0][0] !== "string") throw new Error("csvAsText failed");
await gc.write_range({range:"F1", values:[["Imported as text"]]});
await gc.save_workbook({path:"/tmp/accounts.xlsx"});
```

`file.open` is the command that exposes `csvAsText`; the `open_workbook` MCP
tool only takes `path`. Without `csvAsText`, values like `00123`, `1/2/2026`
and `$5` are inferred and may change type. CSV export writes displayed text
(`$2.50`), not raw values; use XLSX when formulas or exact numbers matter.

## 8. Page setup and PDF

```js
await gc.new_workbook({});
await gc.write_range({range:"A1", values:[["Report"],["Generated by OpenCode"]]});
await run("pageLayout.orientation", {orientation:"landscape"});
await run("pageLayout.size", {paper:"A4"});
await run("pageLayout.margins", {preset:"narrow"});
await run("pageLayout.printArea", {range:"A1:B2"});
await run("pageLayout.headerFooter", {header:"&LReport&RPage &P of &N"});
await gc.save_workbook({path:"/tmp/gridcraft-report.pdf"});
```

`save_workbook` to `.pdf` exports the active sheet; `file.exportPdf` can export
all sheets. Verify independently:

```sh
pdfinfo /tmp/gridcraft-report.pdf | grep -E 'Pages|Page size'
pdftotext /tmp/gridcraft-report.pdf - | head
```

Invalid paper names may preview but are omitted on save. Use `paper`, not
`value`, for `pageLayout.size`.

## 9. Drive the live GUI window

Start the app and bridge first:

```sh
gridcraft --control 7979 &
```

Raw control-channel Python (no proxy):

```python
import json, socket, time

def call(method, **params):
    s = socket.create_connection(("127.0.0.1", 7979), timeout=10)
    f = s.makefile("rwb")
    f.write((json.dumps({"id":1,"method":method,"params":params})+"\n").encode())
    f.flush()
    out = json.loads(f.readline())
    s.close()
    if not out.get("ok"):
        raise RuntimeError(out.get("error"))
    return out["result"]

call("ui.focus")                       # do this before any input
call("ui.cell.click", cell="C3")
call("ui.edit.begin", text="=SUM(A1:A3)")
call("ui.edit.commit", move="down")
time.sleep(0.4)
assert call("cell.get", cell="C3")["formula"] == "=SUM(A1:A3)"
call("ui.screenshot", path="/tmp/gridcraft-gui.png")
print(call("ui.inspect")["mode"])      # Ready
```

Use `ui.edit.begin`/`ui.edit.text`/`ui.edit.commit`; typing letters with
`ui.key` or `ui.text` without entering edit mode is unreliable. `ui.edit.text`
replaces the prefilled text. Commit before clicking another cell. `ui.focus`
first; without it a click can block behind another app's modal dialog.

## 10. CLI batch and round-trip check

`steps.jsonl`:

```text
# one command per line
home.bold {"range":"A1:F1"}
cell.set={"cell":"H2","input":"from script"}
```

Run:

```sh
gridcraft-cli run --in /work/in.xlsx --script /tmp/steps.jsonl \
  --out /tmp/out.xlsx --print A1:H10
gridcraft-cli info /tmp/out.xlsx
gridcraft-cli check /tmp/out.xlsx --json
```

A failed command writes no output file. `run` accepts repeated
`--cmd 'id={json}'` too. `check` exit 0 means no calculated/round-trip
differences; exit 1 can be a `package`-only difference (inspect the categories).
`convert` success messages go to stderr.

## 11. PivotTable from a table

```js
await gc.new_workbook({});
await gc.write_range({range:"A1", values:[
  ["Region","Product","Revenue"],
  ["East","Widget",30],["West","Widget",32],["East","Gadget",18],
  ["West","Gadget",20],["North","Widget",49.95]
]});
await gc.create_table({range:"A1:C6", name:"SalesData"});
const p = await run("insert.pivotTable", {
  source:"SalesData", destination:"new", name:"RevenuePivot",
  rows:["Region"], values:[{field:"Revenue", func:"sum", name:"Total Revenue"}]
});
await run("pivot.refresh", {pivot:"RevenuePivot"});
const pivots = await run("pivot.list", {});
if (!pivots.length) throw new Error("pivot missing");
await gc.save_workbook({path:"/tmp/gridcraft-pivot.xlsx"});
```

The default destination is a new sheet with the report at A3. Verify the pivot
by reading its sheet, not by trusting the creation response. `data.refreshAll`
refreshes every pivot.

## 12. Insert and verify a picture or shape

```js
const pic = await run("insert.picture", {
  path:"/work/logo.png", at:"H2", width:120, height:40, alt:"Company logo"
});
const shape = await run("insert.shape", {
  kind:"roundedRectangle", at:"H8", width:140, height:60,
  text:"Callout", fill:"#FFE699"
});
const info = await gc.inspect_workbook({});
const sheet = info.sheets[0];
if (!sheet.images?.length || !sheet.shapes?.length) throw new Error("object missing");
```

Object ids are shared across charts, pictures and shapes, and change after
reload. Invalid image bytes may be accepted on save; validate the source file
and inspect the embedded media before delivery.
