# GridCraft 0.9.0 — bugs, silent successes and workarounds

All reproductions below were run against the installed Debian package
`gridcraft 0.9.0-1` on 2026-10-22. The workaround is what the skill uses. Some
entries are deliberate behavior rather than bugs; they are included because they
cause silent data loss if treated like Excel.

## 1. `write_range` range is only a top-left anchor

```js
await gc.write_range({range:"A1:D10", values:[["a","b"],["c","d"]]});
// writes A1:B2, not A1:D10
```

A 1-D array fills one row. `values:[]` returns `{"cells":0}` and changes
nothing. Consequence: do not use `range` to size the write, and do not assume a
non-empty result means a rectangle of the requested shape.

**Workaround:** write exactly the arrays you mean and read back the used range.

## 2. `get_cell` rejects `sheet`

```js
await gc.get_cell({cell:"A1", sheet:"Sheet2"});
// JSON-RPC -32602: get_cell: unknown argument `sheet`
```

**Workaround:** `execute_command {command:"cell.get",params:{cell:"A1",sheet:"Sheet2"}}`,
or `read_range` which does accept `sheet`.

## 3. Reopening an open path does not reload it

```js
await gc.open_workbook({path:"/tmp/book.xlsx"});   // first open
await gc.set_cell({cell:"A1", input:"changed"});
await gc.open_workbook({path:"/tmp/book.xlsx"});
// {"alreadyOpen":true,"index":0}; A1 still "changed"
```

**Workaround:** `file.close {force:true}` first, or use a fresh headless MCP
process. If unsaved changes matter, save before closing. This also affects
“reopen to verify” checks in the app bridge.

## 4. Object ids are session-local, shared, and silent on mismatch

Charts, pictures and shapes share one id counter. Ids change after reload.
`object.delete` with a nonexistent or wrong-kind id returns success with no
effect:

```js
await gc.execute_command({command:"object.delete",
  params:{kind:"chart", id:999}});
// {"isError":false,"data":null} — nothing deleted
```

`chart.set` without `chart` edits the selected chart if one is selected;
otherwise it errors `no such chart`. `object.delete` is the dangerous one
because it looks successful.

**Workaround:** take ids from `document.inspect`/`arrange.selectionPane` in the
same session, verify the kind and count before/after, and never cache ids across
save/reload.

## 5. Unknown parameter names are ignored

```js
await gc.execute_command({command:"home.bold", params:{rang:"A1"}});
// {"on":true}; A1 is not bold
```

`home.bold {range:"A1", on:"yes"}` returns `{"on":false}` and does not bold;
the string is coerced to false. Omitting `on` toggles state.

**Workaround:** pass exact field names and real booleans (`on:true` /
`on:false`). Re-read the cell style after every formatting call.

## 6. `format_range` applies properties sequentially and can stop halfway

```js
await gc.format_range({range:"A1", bold:true, fontColor:"notacolor"});
// isError:true
// format_range: home.fontColor: ... invalid `color`
// (applied before the failure: ["home.bold"])
```

A1 is left bold even though the overall call failed.

**Workaround:** prefer one `execute_command` per property when failure matters,
or inspect the “applied before the failure” list and re-read the cell.

## 7. Arbitrary number formats are accepted

```js
await gc.execute_command({command:"home.numberFormat",
  params:{range:"A1", format:"Bogus"}});
// success; A1 displays 1234.5 as "Bogu0"
```

The string is stored as a format code, not validated as a named format.

**Workaround:** use a documented name (`General`, `Currency`, `Short Date`,
`Percentage`, `Text`, …) or a valid Excel format code (`"#,##0.00"`).

## 8. Unsupported chart types silently become ColumnClustered

```js
await gc.insert_chart({range:"A1:B4", type:"donut"});
// creates a column chart; id returned normally
```

`donut` and `notAType` both fell back to column in testing. The supported
spelling is `doughnut`. Check `document.inspect`/`chart` metadata after insert;
do not trust the returned id alone.

## 9. Dialogs confirm without applying

`ui.dialog` names: `formatCells`, `sort`, `dataValidation`, `nameManager`,
`pageSetup`. Observed over the control channel:

| Dialog | `confirm` result | Applied? |
|---|---|---|
| `dataValidation` | success | yes |
| `sort` | error: “this dialog has no OK command; drive it with its own commands” | no |
| `formatCells` | same error | no |
| `nameManager` | same error | no |
| `pageSetup` | success | **no** |

Clicking the visual OK button for Format Cells also closed the dialog without
applying the edited style in one test. Unknown dialog names return
`{"dialog":null}` with success.

**Workaround:** drive `data.sort`, `home.formatCells`, `formulas.defineName`,
`pageLayout.pageSetup`, etc. Use dialogs for inspection or screenshots only, and
verify the cell/sheet after any confirm.

## 10. GUI input needs focus and the editor API

`ui.cell.click` can hang or block when another application has focus/a modal
dialog; call `ui.focus` first.

```python
call("ui.focus")
call("ui.cell.click", cell="C3")
call("ui.edit.begin", text="=SUM(A1:A3)")
call("ui.edit.commit", move="down")
```

- `ui.key` letters/digits and `ui.text` do not reliably start grid editing.
- `F2` + `ui.text` + Enter did not commit a formula in one test; the edit API
  did.
- `ui.edit.text` **replaces** the prefilled editor text, not appends.
- Clicking another cell while an edit is open can be ignored or misapplied;
  commit/cancel first.
- `ui.cell.drag` did not create a range (one cell selected, edit mode entered).
  Use `select({range:"B2:C3"})` or click/keyboard selection.
- `edit.goTo` moves the selection but did not scroll the viewport.

**Workaround:** focus, use `ui.cell.click` + `ui.edit.begin/text/commit`, use
`select` for ranges, and take a screenshot after each GUI step.

## 11. HTML import is broken

The app exports valid HTML (`file.save` / `save_workbook` to `.html`), but
`open_workbook` on that HTML treats it as delimited text. A1 becomes:

```text
<!doctype html><html><head><meta charset="utf-8"><title>Sheet1</title>…
```

The rest of the markup is split across many columns (used range `A1:AD1` in
testing). It does not reconstruct the table.

**Workaround:** import XLSX, CSV or TSV. Use HTML only as an export format for
browsers, and never round-trip through it.

## 12. ODS import is data-only; ODS save is refused

```js
await gc.open_workbook({path:"rich.ods"});
// title: "rich (imported).xlsx"; path: null
// warning: "ODS data-only import: formulas become their saved results and
// will not recalculate. Source formatting, charts, images and other features
// are not imported. Save a new .xlsx file; ODS saving is not supported."
```

Formulas become plain values; number formats, styles, charts, tables, names and
validations are lost. The imported workbook has no path until saved.

**Workaround:** use `.xlsx` for any round-trip. Convert ODS with LibreOffice to
XLSX first if formulas/styles matter.

## 13. XLS import is partial; XLS save is refused

`open_workbook` imports values, formulas, number formats, merged cells, column
widths, row heights and defined names from Excel 97-2003. Fonts, fills, borders,
charts, pictures, comments and other features are **not** imported; headers warn
about each unsupported class. The title becomes `name (imported).xlsx` and the
in-memory path is null. `save_workbook` to `.xls` fails:

```text
Excel 97-2003 (.xls) is supported for import only.
```

**Workaround:** save as XLSX. Do not expect a true `.xls` round-trip.

## 14. CSV exports displayed values, imports inferred types

Export:

```csv
Region,Units,Price,Revenue,Date,Share
East,12,$2.50,$30.00,1/15/2026,26.67%
```

The values are formatted display text, not raw formulas/cells. Import then
infers numbers, dates and currency formats, strips leading zeros, and treats
`=1+1` as text, not a formula.

**Workaround:** use XLSX for fidelity. If CSV must be the transport, call the
`file.open` **command** with `{path, csvAsText:true}` to keep every field as
text; `open_workbook` has no such flag. Do not expect formulas.

## 15. `.txt` save silently writes TSV; `.ods`/`.xls` saves error

```js
await gc.save_workbook({path:"out.txt"});
// success; bytes are "x\t1\r\n" not a .txt layout
await gc.save_workbook({path:"out.ods"});
// error: ODS is supported for data import only
await gc.save_workbook({path:"out.xls"});
// error: .xls is supported for import only
```

**Workaround:** treat `.txt` as TSV with CRLF; use `.xlsx` or `.csv` explicitly.
`file.saveBytes` accepts xlsx/csv/tsv/json/html only.

## 16. Save-time validation is weak

These all saved successfully in 0.9.0:

- **Invalid base64 picture.** `insert.picture {base64:"aW52YWxpZA==",
  mime:"image/png"}` produced `xl/media/image2.png` containing the 7 bytes
  `invalid`. `gridcraft-cli check` still passed; media is not validated.
- **Cell text > 32,767 characters.** A 40,000-character string was written to
  `sharedStrings.xml` intact. Excel's limit is 32,767.
- **Header > 255 characters.** A 300-character header saved intact. Excel's
  limit is 255.
- **Overlapping merges.** Merging a range over an existing merge silently
  replaces the first merge.
- **Invalid print paper.** `pageLayout.size {paper:"Bogus"}` is accepted and
  the preview says `Bogus`, but the saved XLSX omits `pageSize` and opens as
  Letter. `pageLayout.orientation`/`size` ignore a `value` field; use
  `orientation`/`paper`.

**Workaround:** validate pictures with an image decoder, enforce Excel limits
yourself, unzip/inspect merges, and check `pageSetup` XML or open in LibreOffice.
`check` alone is not sufficient.

## 17. Third-party XLSX round-trip loses package/chart styling

A LibreOffice-generated workbook with 10 formulas, tables, charts and names
survived a GridCraft save with all content categories equal; `gridcraft-cli
check` exited 1 because `package` differed:

```text
lost relationship chartColorStyle
lost relationship chartStyle
lost relationship core-properties
```

The saved chart lost style/color parts and some chart XML detail. Do not treat
`check` exit 1 as “all content lost”; inspect `roundTrip.categories` and compare
in LibreOffice/Excel.

**Workaround:** for third-party files, keep the original and deliver a
GridCraft-saved copy only after visual inspection. For native GridCraft XLSX,
`check` passed twice in the comprehensive round-trip test.

## 18. Edge writes can inflate `usedRange`

Writing to `XFD1`, `A1048576` or `XFD1048576` (or selecting an entire row/column)
expanded `usedRange` to `A1:XFD1048576` in testing. Subsequent reads and saves
then operate on an enormous nominal range.

**Workaround:** avoid edge cells and entire-sheet selections in generated
workbooks; prefer `select` on the data block. If `usedRange` is already huge,
rebuild the workbook or clear the edge cells and re-check.

## 19. `selection.column`/`row` are fine; don't “fix” them

`B2` → `B:B`, `B2:C3` → `B:C`; `row` gives `2:2`/`2:3`. An earlier suspected
bug was not reproducible. Whole-column selections can still inflate usedRange
when written to.

## 20. CLI exit codes do not always mean success

```sh
gridcraft-cli eval '=SUM('
# prints #NAME? and exits 0
gridcraft-cli eval '=SUM(' --json
# {"error":"#NAME?"} and exits 0
```

`convert` prints `wrote …` to **stderr**, so stdout may be empty on success.
A failed `run` writes no output file. `check` exits 1 for any difference,
including the package-only case above.

**Workaround:** parse JSON/output, check that the output file exists, and treat
`check` categories individually.

## 21. Names and invalid references are accepted

`formulas.defineName` accepts invalid `refersTo` text and duplicate names
silently overwrite the existing definition. `formulas.createFromSelection`
returns `skipped` for existing names; other paths do not warn.

**Workaround:** read `formulas.nameManager`/`inspect_workbook` after defining,
and use unique names.

## 22. `edit.goTo` and GUI scrolling

`edit.goTo {reference:"A1000"}` moves the selection but does not scroll the
viewport in 0.9.0 (despite the command's UI description). Keyboard
Ctrl+Down/PageDown scrolls; `ui.cell.click` on an off-screen cell may not.
After navigation, `ui.inspect` the scroll and selection before clicking.

## 23. `ui.dialog.set` is not validation

`ui.dialog.set {field:"Bogus", value:123}` echoes the field in the dialog state
and returns success even when the dialog does not use it. Combined with unknown
dialog names returning `null`, a “successful” dialog sequence can change
nothing.

**Workaround:** set only fields observed in `ui.inspect().dialog`, confirm with
the underlying command, and verify the workbook.

## 24. Conditional-format styles silently drop the fill

```js
await gc.execute_command({command:"home.conditionalFormat", params:{
  range:"D2:D10",
  rule:{type:"cellIs", operator:"greaterThan", value:25,
        style:{fill:{color:"#C6EFCE"}}}}});
// {"rules":1} — rule exists, but the saved dxf has <font> only, no <fill>
```

`rule.style` is a full `Style`; its `fill` is `{pattern:"None|Solid|…", bg:Color,
fg:Color}`, not `{color:…}`. Fields it does not recognise are dropped without an
error (see §5) — the saved dxf keeps only what it understood, often just the
`<font>`. The rule is still stored, still counted by `inspect_workbook`, and
still evaluates; it just paints nothing.

Correct form:

```js
style:{fill:{pattern:"Solid", bg:{Rgb:0xC6EFCE}, fg:{Rgb:0xC6EFCE}},
       font:{color:{Rgb:0x006100}, bold:true}}
```

**Workaround:** after any conditional format, save and check `xl/styles.xml`
for a `<fill>` inside the matching `<dxf>` (§28 has the one-liner), or open the
file in LibreOffice. `{"rules":n}` and `conditionalFormats:n` prove only that a
rule object exists.

## 25. Colour encoding differs between commands

```js
home.fillColor {range:"A1", color:"#C6EFCE"}              // OK — hex string
style:{font:{color:"#006100"}}
// invalid parameters: unknown variant `#006100`, expected `Auto`, `Rgb`, `Theme`
style:{font:{color:{Rgb:"#006100"}}}
// invalid type: string "#006100", expected u32
style:{font:{color:{Rgb:0x006100}}}                       // OK — 24-bit integer
```

`Color` inside a `Style`/dxf is an externally tagged enum (`"Auto"`,
`{Rgb:u32}`, `{Theme:n}`). Commands with their own `color` parameter
(`home.fillColor`, `home.fontColor`, `home.borders`) take `"#RRGGBB"` instead.
Same-looking field, two encodings, and the error message names the expected
variants so it is quick to correct once seen.

**Workaround:** `"#RRGGBB"` for `fillColor`/`fontColor`/`borders`; `{Rgb:0xRRGGBB}`
inside `style`, `rule.style` and any dxf-shaped payload.

## 26. On-screen conditional colours are theme-blended

A `#C6EFCE` fill renders in the window as a paler, differently-valued tint
(`#B2E3BE` and `#E5BFBE` were the greens/reds actually present where the dxf
hexes were expected) because the app composites the rule over the workbook theme
and table style. Sampling the screenshot for the exact dxf hex finds nothing —
only the ribbon's swatch buttons — and that is not evidence the rule failed.

**Workaround:** judge conditional formatting from the saved XLSX (`dxf` in
`xl/styles.xml`) or a LibreOffice render, not from `screenshot` pixels. If you
must sample, histogram the cell region and look for any green/red tint rather
than the exact hex.

## 27. Tool-schema traps: `screenshot` needs `path`, `set_cell` needs `input`

```js
await gc.screenshot({});
// path: Missing key
await gc.screenshot({path:"/tmp/opencode/shot.png"});   // OK

await gc.set_cell({cell:"I12", value:1003});
// input: Missing key
await gc.set_cell({cell:"I12", input:"1003"});          // OK
```

The MCP wrappers validate their own keys before reaching the engine, so these
surface as `Missing key` rather than being ignored. `set_cell` accepts numbers
as strings (`"1003"`) and stores them as numbers; `read_range` returns real
numbers back.

**Workaround:** pass `path` to every app-bridge screenshot and `input` to
`set_cell`; when a wrapper rejects arguments, list its schema with
`list_commands {search:"<id>"}` rather than guessing a second time.

## 28. Verifying conditional formatting from the file

The fastest end-to-end check for styles the UI cannot show reliably:

```sh
mkdir -p /tmp/xl && cd /tmp/xl && unzip -o book.xlsx >/dev/null
python3 - <<'PY'
import re
s = open('xl/worksheets/sheet1.xml').read()
print(re.findall(r'<conditionalFormatting.*?</conditionalFormatting>', s, re.S))
print(re.search(r'<dxfs.*?</dxfs>', open('xl/styles.xml').read(), re.S).group(0))
PY
```

Each `<cfRule dxfId="n">` must point at a `<dxf>` that contains the expected
`<fill><patternFill patternType="solid">…` and/or `<font>`. A rule with only
`<font>` is the §24 failure. A LibreOffice PDF/PNG render is the final proof:
`soffice --headless --convert-to pdf` then `pdftoppm -png`.
