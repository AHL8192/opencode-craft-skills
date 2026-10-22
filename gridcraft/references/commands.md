# GridCraft command map

**341 commands in 27 namespaces** in GridCraft 0.9.0. This file covers the
commands an agent actually uses and their parameters. The complete id list is
`command-index.md`; authoritative live parameters come from:

```sh
gridcraft-cli commands --json
```

or over MCP:

```js
await gc.list_commands({search:"table"});
await gc.execute_command({command:"app.commands", params:{search:"chart"}});
```

Parameter syntax is informal: `?` = optional, `…` = additional options
documented by the catalog. Commands without a range parameter act on the current
selection (or active cell). Most ribbon commands work identically over MCP, the
CLI and the control channel. Programmatic calls do **not** open modal dialogs;
missing required parameters produce an error.

## File and workbook (`file`, 13)

| Command | Parameters / result |
|---|---|
| `file.new` | `{sample?: "budget"|"sales"|"grades"}` — new blank or built-in sample |
| `file.open` | `{path}` or `{name, base64}`; optional `{password, csvAsText?}`; supports xlsx, xlsm, xls, xlsb, ods (data), csv, tsv, txt, json |
| `file.save` | `{path?}` — xlsx by default; csv/tsv/json/html/pdf by extension |
| `file.saveAs` | `{path}` — same formats; PDF is the active sheet |
| `file.saveBytes` | `{format?: xlsx|csv|tsv|json|html}` → `{base64}` |
| `file.exportCsv` | `{path, sheet?}` |
| `file.exportHtml` | `{path}` |
| `file.exportPdf` | `{path?, sheets?: active|all, range?, fitToPage?}` → `{pages, bytes, path}` or base64 |
| `file.printPreview` | `{page?, sheets?, range?, fitToPage?}` → page list and geometry |
| `file.print` | same options → PDF bytes handed to the system print dialog |
| `file.properties` | `{title?, subject?, author?, company?, keywords?, description?}` |
| `file.options` | `{}` → calculation mode and iterative settings |
| `file.close` | `{force?}` — errors on unsaved changes unless `force:true` |

`file.open` on a path already open returns `{"alreadyOpen":true,"index":n}` and
does **not** reload the disk file. `file.save` to `.ods` or `.xls` is refused;
`.txt` is written as TSV. See `formats.md`.

## Sheets (`sheet`, 10; plus `home` sheet commands)

- `sheet.rename {sheet?, name}`
- `sheet.activate {sheet: index|name}`, `sheet.next`, `sheet.previous`
- `sheet.move {sheet?, to: index, copy?: bool}` (also moves/copies)
- `sheet.moveColumns {cols?: "B:C", before: 0-based index}`
- `sheet.hide {sheet?}`, `sheet.unhide {sheet}`
- `sheet.tabColor {sheet?, color: "#RRGGBB"|"none"}`
- `sheet.read {range?, sheet?, formulas?, formatted?}` → rows
- `home.insertSheet {name?, before?: index}`, `home.deleteSheet {sheet?}`
- `document.inspect {}` → sheets, selection, names, tables, charts, dirty,
  history. `inspect_workbook` is the MCP wrapper.

## Cells, ranges and selection (`cell`, `range`, `selection`)

- `cell.set {cell?, input, sheet?, array?}` — typed input; `=…` is a formula.
- `cell.get {cell?, sheet?}` → value, type, formula, display text, raw input,
  spill range, style, merge, comment, hyperlink.
- `cell.toggleCheckbox {cell?}`.
- `range.setValues {range?, values:[[…]]}` — rows of numbers, strings, booleans,
  null; strings starting with `=` are formulas.
- `range.fill {range?, input}` — same input in every selected cell; relative
  formulas adjust.
- `selection.set {range: "A1:B2,D4"|cell, active?, sheet?}`.
- `selection.move {dr, dc, extend?, jump?, page?}`.
- `selection.next {forward?, byRow?}`, `selection.currentRegion`,
  `selection.row`, `selection.column`, `selection.stats`.
- `edit.selectAll` (current region first, then sheet), `edit.goTo {reference}`,
  `edit.goToSpecial {kind}`.

`read_range`/`sheet.read` return `null` for empty cells and `{"error":"#DIV/0!"}`
for errors. `formulas:true` returns formula text; `formatted:true` returns the
display text. `get_cell` does **not** accept a `sheet` argument over MCP; use
`cell.get` through `execute_command`.

## Editing, clipboard and fill (`edit`, 26)

- `edit.undo {steps?}`, `edit.redo {steps?}`, `history.list`.
- `edit.copy {range?, html?}`, `edit.cut`, `edit.paste {at?, text?, html?}`,
  `edit.pasteSpecial {what, operation?, skipBlanks?, transpose?, link?}`,
  `edit.clearClipboard`.
- `edit.clearAll`, `edit.clearContents`, `edit.clearFormats`,
  `edit.clearComments`, `edit.clearHyperlinks` — all accept `{range?}`.
- `edit.fillDown/Right/Up/Left {range?}`; `edit.autoFill
  {source,target,mode?}`; `edit.fillSeries {range?,direction?,type?,step?,stop?,dateUnit?}`;
  `edit.flashFill {range?}`.
- `edit.find {what, matchCase?, wholeCell?, lookIn?: formulas|values,
  byColumns?, all?, within?: sheet|workbook}`;
  `edit.replace {what, with, matchCase?, wholeCell?, all?, within?}`.
- `edit.formatPainter {sticky?}` then `{apply:"C3:D4"}`.
- `edit.beginEdit {}` — enter edit mode in the active cell.

Values written as strings are parsed like typed input: `"12%"`, `"1/2/2024"`,
`"$5"`. This is useful but can surprise; write a leading apostrophe to force
text if a string looks like a date or number.

## Formatting (`home`, 64)

The most-used commands; every one accepts `{range?}` unless noted. All have a
`home.*` id and most boolean toggles accept `on?: bool`.

- Font: `home.bold`, `home.italic`, `home.underline {style?}`, `home.doubleUnderline`,
  `home.strikethrough`, `home.superscript`, `home.subscript`,
  `home.fontName {name}`, `home.fontSize {size}`, `home.increaseFontSize`,
  `home.decreaseFontSize`, `home.fontColor {color}`.
- Fill/borders: `home.fillColor {color|"none"|{theme,tint}}`,
  `home.borders {preset, style?, color?}`, `home.drawBorder {range,edge,style?,color?}`.
- Alignment: `home.alignLeft/Center/Right/Justify`, `home.alignTop/Middle/Bottom`,
  `home.wrapText`, `home.shrinkToFit`, `home.increaseIndent`, `home.decreaseIndent`,
  `home.orientation {angle|-90..90|vertical|counterclockwise|clockwise|up|down}`.
- Merge: `home.mergeCenter`, `home.mergeAcross`, `home.mergeCells`,
  `home.unmergeCells`. Overlapping merges silently replace the previous merge.
- Numbers: `home.numberFormat {format|code}`, `home.accounting {symbol?}`,
  `home.percent`, `home.comma`, `home.increaseDecimal`, `home.decreaseDecimal`.
- Styles: `home.cellStyle {name}`, `home.newCellStyle {name,fromCell?}`,
  `home.formatCells {style:{font?,fill?,borders?,align?,numFmt?,protection?}}`.
- Size/layout: `home.rowHeight {rows,height}`, `home.columnWidth {cols,width|chars}`,
  `home.autofitRowHeight {rows?}`, `home.autofitColumnWidth {cols?}`,
  `home.defaultWidth {width}`, `home.hideRows/Columns`, `home.unhideRows/Columns`.
- Rows/columns/cells: `home.insertRows {rows,count?}`,
  `home.insertColumns {cols}`, `home.deleteRows`, `home.deleteColumns`,
  `home.insertCells {range,shift}`, `home.deleteCells {range,shift}`,
  `home.insertCopiedCells {at,shift?}`, `home.lockCell {range,on?}`.
- Tables/conditional: `home.formatAsTable`, `home.conditionalFormat`,
  `home.clearRules`, `home.manageRules {delete?|moveUp?|moveDown?}`.
- `home.addIns` returns an explanatory result; GridCraft extends through MCP and
  scripts, not add-ins.

`home.formatCells` merges a `Style` JSON object into the range; use it for
several properties at once. `format_range` is the MCP convenience wrapper and
applies properties sequentially.

`Style` fields are exact, and colours inside a `Style` are not hex strings:
`fill` is `{pattern, bg, fg}` and each colour is `{Rgb:u32}` or `{Theme:n}`.
The same applies to `home.conditionalFormat`'s `rule.style` — a shorthand
`{fill:{color:"#C6EFCE"}}` is accepted and silently drops the fill. See
`bugs-and-workarounds.md` §24–25 before writing conditional formats.

## Formulas, names and calculation (`formulas`, 27)

- `formulas.autoSum {function?, range?}` — SUM/AVERAGE/COUNT/MAX/MIN.
- `formulas.insertFunction {name?}` — opens the dialog in the UI; with a name,
  starts the formula in the active cell.
- `formulas.functions {category?, search?}` → function catalog.
- `formulas.defineName {name, refersTo?, scope?, comment?, oldName?, oldScope?}`;
  `formulas.deleteName {name,scope?}`; `formulas.nameManager`; 
  `formulas.createFromSelection {range?,top?,left?,bottom?,right?,replace?}`.
- `formulas.tracePrecedents {cell?}`, `formulas.traceDependents {cell?}`,
  `formulas.removeArrows`, `formulas.showFormulas {on?}`.
- `formulas.errorChecking`, `formulas.evaluateFormula {cell?,formula?}`,
  `formulas.evaluate {formula,cell?}`.
- `formulas.calculateNow`, `formulas.calculateSheet`,
  `formulas.calculationOptions {mode?,iterative?,maxIterations?,maxChange?}`.
- `formulas.recentlyUsed`, and category menus (`financial`, `logical`, `text`,
  `dateTime`, `lookupReference`, `mathTrig`, `moreFunctions`).
- `formulas.useInFormula {name}`, `formulas.watchWindow {add?,remove?}`.

Names are workbook- or sheet-scoped. Duplicate names silently replace the old
definition; invalid `refersTo` text is accepted. Always read the name back via
`formulas.nameManager` or `inspect_workbook`.

## Data tools (`data`, 37)

Sorting/filtering:

- `data.sortAscending {range?,column?}`, `data.sortDescending`,
  `data.sort {range?,header?,keys:[{column,order,by?,customList?}],orientation?,matchCase?}`.
- `data.filter {range?}` toggles AutoFilter. `data.filterBy {column, values?,
  blanks?, custom?{op,value,op2?,value2?,and?}, top?{count,bottom?,percent?},
  aboveAverage?, clear?}`. `data.clearFilter`, `data.reapply`.
- `data.removeDuplicates {range?,columns?,header?}`.

Text/data cleanup:

- `data.textToColumns {range?,delimiters?,other?,fixedWidths?,treatConsecutive?,textQualifier?,destination?}`.
- `data.validation {range?,type,operator?,formula1,formula2?,ignoreBlank?,
  dropdown?,inputTitle?,inputMessage?,errorStyle?,errorTitle?,errorMessage?,clear?}`.
- `data.validate {cell?,input}` → `{ok,message?}`; `data.circleInvalid`.
- `data.group/ungroup {rows?|cols?|by?}`, `data.hideDetail`, `data.showDetail`,
  `data.showLevels {rows?,cols?}`, `data.subtotal {range?,groupBy,function?,columns,header?}`.
- `data.flashFill {range?}`.
- `data.fromTextCsv {path|text,delimiter?,sheet?}`,
  `data.getData {path|text}`, `data.fromTableRange {range?}`,
  `data.queriesConnections`.
- `data.advancedFilter {range?,criteria,copyTo?,unique?}`,
  `data.consolidate {sources,destination?,function?,topRow?,leftColumn?}`.
- `data.solver {objective?,goal?,value?,variables,constraints?,…}`,
  `data.solverReport`, `data.goalSeek {set,to,changing}`.
- `data.scenarioManager/Add/Show/Delete/Summary`, `data.dataTable`,
  `data.forecastSheet`, `data.analysisToolPak`.

`data.filterBy` hides rows; it does not delete them. Clear the filter before
reading a table as a contiguous block. `data.sort` reorders cells in place.

## Tables (`table`, 14; `insert.table`)

- `insert.table {range,header?,style?,name?}` or `home.formatAsTable`.
- `table.totalRow {table?,on?}`, `table.totalFunction {table?,column,function}`,
  `table.bandedRows`, `table.bandedColumns`, `table.headerRow`,
  `table.firstColumn`, `table.lastColumn`, `table.style`, `table.rename`,
  `table.resize {table?,range}`, `table.convertToRange`,
  `table.removeDuplicates {table?,columns?}`.
- `table.summarizePivot {table?,destination?}`, `table.insertSlicer`.

Tables have structured references and filter buttons. A table name is also a
valid source for a PivotTable and a named range for formulas.

## Charts, pictures, shapes and objects (`chart`, `object`, `insert`, `shape`, `draw`, `arrange`)

- `insert.chart {range,type,subtype?,title?,at?,width?,height?}`; type:
  `column|bar|line|pie|doughnut|area|scatter|bubble|radar|combo|histogram|
  waterfall|funnel|treemap|sunburst|boxWhisker|stock`.
- `insert.chartRecommendations {range?,type?,subtype?}`,
  `insert.recommendedCharts`.
- `chart.set {chart?,type?,title?,legend?,dataLabels?,gridlines?,style?,
  xTitle?,yTitle?,at?,width?,height?,dx?,dy?}`;
  `chart.switchRowColumn`, `chart.delete`, `chart.addElement`,
  `chart.quickLayout`, `chart.changeColors`, `chart.selectData`,
  `chart.changeType`, `chart.move`, `chart.formatSelection`,
  `chart.shapeFill`, `chart.shapeOutline`.
- `insert.picture {path|base64, mime?, at?, width?, height?, alt?, mode?, placement?}`.
- `insert.shape {kind,at?,width?,height?,text?,fill?,line?}`,
  `insert.icons`, `insert.textBox`, `insert.symbol`, `insert.checkbox`,
  `insert.link {cell?,target,text?,tooltip?,remove?}`.
- `object.delete/move/setAnchorMode {kind,id,…}`;
  `arrange.bringForward`, `sendBackward`, `selectionPane`, `align`, `group`,
  `rotate`; `shape.setText {id,text}`; `draw.pen/eraser/lasso/stroke/inkToShape`.

Pictures and objects share one id space with charts. Verify the id with
`document.inspect`/`arrange.selectionPane` before acting. Invalid image base64
may be accepted and saved as broken media.

## PivotTables (`pivot`, 20)

Creation is `insert.pivotTable {source?,destination?,name?,rows?,columns?,
values?,filters?,replace?}`. `destination:"new"` creates a sheet with the report
at `A3`. Then:

- `pivot.list`, `pivot.fields`/`fieldList`, `pivot.addField`,
  `pivot.removeField`, `pivot.moveField`, `pivot.valueSettings`,
  `pivot.filter`, `pivot.sort`, `pivot.group`, `pivot.collapse`, `pivot.layout`,
  `pivot.grandTotals`, `pivot.subtotals`, `pivot.reportLayout`, `pivot.style`,
  `pivot.refresh`, `pivot.changeSource`, `pivot.delete`.
- `insert.pivotChart {pivot?, type?, subtype?, title?, at?, width?, height?}`.
- `insert.slicer {table?,column?,at?,…}`; `slicer.toggle`, `selectAll`,
  `clear`, `delete`.
- `data.refreshAll {replace?}`.

Pivot changes require `pivot.refresh` or a refresh-all before reading totals,
unless the command itself refreshes.

## Page layout and printing (`pageLayout`, 16)

- `pageLayout.orientation {orientation: portrait|landscape}`.
- `pageLayout.size {paper: Letter|Legal|A4|A3|A5|Tabloid|Executive}`.
- `pageLayout.margins {preset?|left?,right?,top?,bottom?,header?,footer?}`.
- `pageLayout.printArea {range?,clear?}`; `printTitles {rows?,cols?}`;
  `scaleToFit {scale?,width?,height?}`; `printGridlines {on?}`;
  `printHeadings {on?}`; `breaks {insert?,remove?,reset?,cell?}`.
- `pageLayout.headerFooter {sheet?,header?,footer?,differentFirst?,
  differentOddEven?,firstHeader?,firstFooter?,evenHeader?,evenFooter?}` or
  `{page,part,section,text}`.
- `pageLayout.pageSetup {orientation?,paper?,margins?,scale?,fitWidth?,
  fitHeight?,fitToPage?,centerH?,centerV?,gridlines?,headings?,header?,footer?,
  printArea?,titleRows?,titleCols?,rowBreaks?,colBreaks?}`.
- `pageLayout.theme`, `themeColors`, `themeFonts`, `themeEffects`, `background`.

Only `orientation` and `paper` are the accepted keys for orientation/paper;
`value` is ignored. Invalid paper can preview but is omitted on save.

## Review, protection and view (`review`, 21; `view`, 24)

- `review.newNote {cell?,text,author?}`, `review.newComment`,
  `review.replyComment {cell?,text,author?}`, `review.resolveComment`,
  `review.deleteComment`, `review.showNote`, `review.showComments`,
  `review.showAllNotes`, `review.convertToComments`.
- `review.protectSheet {password?,formatCells?,…,autofilter?}`,
  `review.unprotectSheet {password?}`, `review.protectWorkbook {on?,password?}`,
  `review.allowEditRanges`, `review.checkAccessibility`,
  `review.previousComment/nextComment`, `review.workbookStatistics`,
  `review.spelling`, `review.addToDictionary`, `review.changeSpelling`,
  `review.thesaurus`.
- `view.freezePanes {cell?}`, `freezeTopRow`, `freezeFirstColumn`,
  `unfreezePanes`; `view.gridlines/headings/showZeros/rightToLeft {on?}`;
  `view.zoom {percent}`, `zoom100`, `zoomToSelection`;
  `view.normal/pageLayout/pageBreakPreview`; `view.customViews`;
  `view.split`; `view.newWindow`, `arrangeAll`, `hideWindow`, `unhideWindow`,
  `switchWindows`; `view.ruler`; `view.macros`.

Protection is a UI/workbook setting, not encryption. A protected sheet without
a password is trivial to unprotect; do not treat it as security.

## Automation, app and history (`automate`, 5; others)

- `automate.recordActions {stop?,name?}`, `automate.newScript {name,commands}`,
  `automate.allScripts`, `automate.runScript {name}`, `automate.deleteScript`.
- `app.commands {search?}`; `document.inspect`; `window.activate {index}`;
  `history.list`; `object.*`; `link.open {url?,cell?}` (http/https/mailto only).

Scripts are saved command sequences; they are not VBA. `automate.newScript`
accepts an array of `{command,params}` and `runScript` replays it. A failed
command stops the script unless the caller handles each result.

## Finding the right command

`list_commands({search:"…"})` matches id, label and ribbon path. The catalog
includes `params` as a human-readable schema, not JSON Schema; read it before
calling. Unknown commands return
`execute_command: unknown command \`id\``. `sheet.insert` is **not** a command
despite appearing in an MCP tool example; use `home.insertSheet`.

The full 341-id index is `command-index.md`. Function signatures are in
`functions.md`; use `list_functions` for descriptions.
