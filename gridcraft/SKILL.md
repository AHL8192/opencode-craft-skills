---
name: GridCraft
description: Use whenever working with GridCraft on this machine — the Rust spreadsheet app and Excel alternative — including creating, editing, formatting, calculating, charting, importing or exporting workbooks (.xlsx, .xls, .ods, .csv, .tsv, .json, .html, .pdf), driving the running desktop window, or using its MCP server, CLI, or control channel. Triggers on "GridCraft", "gridcraft-cli", "gridcraft mcp", "GridCraft MCP", "open/edit this spreadsheet in GridCraft", "drive the GridCraft window", "take a GridCraft screenshot", "convert xlsx with GridCraft", and requests to automate spreadsheet work or GridCraft itself. Invoke with @gridcraft.
---

# GridCraft — agent operation

GridCraft is a native Rust spreadsheet with an Excel-compatible ribbon, XLSX
read/write, PDF export, and **every action is a command with an id**. Ribbon,
shortcuts, CLI, control channel, MCP and scripts share one command engine.

## Machine snapshot (verified 2026-10-22)

| Thing | Value |
|---|---|
| Desktop app | `/usr/bin/gridcraft` — `0.9.0` |
| CLI | `/usr/bin/gridcraft-cli` — `0.9.0` |
| Install | Debian package `gridcraft` `0.9.0-1` (`dpkg -S /usr/bin/gridcraft`) |
| App flags | `--control PORT`, `--version` |
| Control channel | `127.0.0.1:7979`, newline JSON, **no key/auth** |
| OpenCode servers | `gridcraft` = headless; `gridcraft-app` = bridge to 7979 |
| Commands | **341** in 27 namespaces (`gridcraft-cli commands --json`) |
| Worksheet functions | **514** (`gridcraft-cli functions --json`) |
| MCP | 21 tools, 3 resources; protocol `2025-06-18`, server `gridcraft 0.9.0` |

**Version drift is expected**; re-verify via *Maintenance*.

## Mental model

- A **workbook** has sheets. A **cell** is A1-style (`B7`, `Sheet2!A1`,
  `A1:D10`, `B:B`, `1:1`). A workbook also holds tables, charts, pictures,
  shapes, names, comments and validation.
- `write_range` uses its `range` only as the **top-left anchor**; the 2-D
  `values` array decides the written extent. A 1-D list becomes one row.
  `null` and `""` both clear a cell.
- A **command** is `{"command":"id","params":{…}}`. `list_commands` finds ids
  and parameter docs; `execute_command` runs one. The 21 MCP tools are thin
  conveniences over that engine.
- **Verify by reading back** with `read_range` (`formulas`, `formatted`),
  `get_cell`, or `inspect_workbook`; for files, reopen and run `gridcraft-cli
  check`. A success response does not prove the change persisted.
- Formulas cover 514 functions. `evaluate_formula` computes without writing.
  Dates are serial numbers with number formats.

## Two connection modes

| Mode | Server / command | Use |
|---|---|---|
| Headless | `gridcraft-cli mcp` → OpenCode `gridcraft` | No window. Batch work, conversion, scripts, confined files. `screenshot` fails. |
| App bridge | `gridcraft --control 7979` + `gridcraft-cli mcp --connect 7979` → OpenCode `gridcraft-app` | Drives the real window: screenshot, click, key, dialogs, UI inspect. |

Configured in `~/.config/opencode/opencode.json`; exposed here as
`tools.gridcraft.*` and `tools["gridcraft-app"].*`. The control channel is
**unauthenticated and unconfined**; keep it on localhost.

```sh
gridcraft-cli mcp                              # headless stdio MCP
gridcraft --control 7979 &                     # live window
gridcraft-cli mcp --connect 7979               # bridge to it
ss -ltn | grep 7979                            # check the port
```

## Standard workflow

1. **Probe.** `inspect_workbook` for title, sheets, used range, selection, dirty
   state; `list_commands({search:"…"})` before guessing an id or parameter.
2. **Work on a copy.** `open_workbook({path})`; save to a new path. Reopening an
   already-open path does **not** reload the file — close it first
   (`file.close {force:true}`) or start a fresh MCP process.
3. **Write.** `write_range` or `set_cell`; formulas are strings starting with
   `=`. Build headings, data and formulas in one pass, then add structure.
4. **Structure and style.** `execute_command` with `home.*`, `insert.table`,
   `insert.chart`, `data.*`, `view.*`, `pageLayout.*`. Commands without `range`
   act on the current selection.
5. **Verify.** `read_range` with `formulas:true` and `formatted:true`; inspect
   the workbook for tables/charts/names. Check a sample of computed values.
6. **Save a copy.** `save_workbook({path})`; extension chooses format. Omit
   `path` only to overwrite the current file deliberately.
7. **Validate the file independently.** `gridcraft-cli check out.xlsx --json`
   reopens and round-trips it; for PDF/CSV use `pdfinfo`/`soffice` or read it
   back. Check images and oversized strings separately.
8. **Close deliberately.** `file.close {force:true}` discards unsaved changes;
   omit `force` to get an error instead of a prompt.

## Tools (21)

| Tool | Purpose | Notes |
|---|---|---|
| `inspect_workbook` | workbook summary | sheets, used ranges, objects, names, history |
| `list_commands` | discover ids | `{search}` matches id, label, ribbon path |
| `execute_command` | run any command | `{command, params}` |
| `read_range` | read 2-D values | `{range, sheet?, formulas?, formatted?}` |
| `write_range` | write 2-D values | anchor-only range; one undo step |
| `set_cell` | type into one cell | payload key is `input`, not `value`; numbers may be strings |
| `get_cell` | full cell detail | value, formula, display, style, comment, link |
| `evaluate_formula` | calculate without writing | `{formula, cell?}` |
| `select` | set selection | supports `A1:B2,D4`, sheet prefixes |
| `format_range` | apply formats in one call | runs properties sequentially; partial failure possible |
| `insert_chart` | insert chart | returns chart id |
| `create_table` | format as Excel table | header row by default |
| `sort_range` | multi-key sort | keys like `["B",{"column":"C","order":"desc"}]` |
| `filter` | AutoFilter | values, custom, top/bottom, clear |
| `open_workbook` | open file | xlsx, xlsm, xls, xlsb, ods, csv, tsv, txt, json |
| `save_workbook` | save/export | xlsx, csv, tsv, json, html, pdf; not ods/xls |
| `new_workbook` | blank or sample | `budget`, `sales`, `grades` |
| `undo` / `redo` | history | `{steps}` |
| `screenshot` | window PNG | **app bridge only**; needs an explicit `path` |
| `list_functions` | function catalog | `{search?, category?}` |

Resources: `gridcraft://workbook`, `gridcraft://commands`,
`gridcraft://functions`.

## Key commands

- **File/sheets:** `file.open`, `file.save`, `file.exportPdf`, `file.close`;
  `sheet.rename`, `sheet.activate`, `sheet.move`, `home.insertSheet`.
- **Cells:** `cell.set/get`, `range.setValues/fill`, `edit.find/replace`,
  `edit.copy/paste`, `edit.clearContents`.
- **Formatting:** `home.bold`, `fontName`, `fontSize`, `fontColor`, `fillColor`,
  `borders`, `numberFormat`, `formatCells`, `columnWidth`, `mergeCenter`.
- **Data:** `formulas.defineName`, `calculateNow`; `data.sort`, `filterBy`,
  `validation`, `removeDuplicates`, `textToColumns`, `subtotal`, `goalSeek`;
  `home.conditionalFormat`.
- **Objects:** `insert.chart`, `insert.table`, `insert.picture`, `insert.shape`,
  `insert.pivotTable`; `object.delete/move/setAnchorMode`.
- **Review/page:** `review.newComment`, `review.protectSheet`, `view.freezePanes`,
  `pageLayout.pageSetup`, `headerFooter`, `printArea`.
- **Automation:** `automate.newScript`, `runScript`, `recordActions`.

Params: `references/commands.md`. All 341 ids:
`references/command-index.md`. Never guess a parameter — query it.

## Formatting and formulas

`format_range` applies properties one at a time; if a later property fails,
earlier ones may already be applied. Inspect the return message and re-read the
cell. `home.formatCells` takes a style object for several properties at once.

- Colors: `"#RRGGBB"`, `"auto"`, or theme objects; `"none"` clears a fill.
  **Inside a `Style`/dxf the encoding differs**: `{Rgb:0xC6EFCE}` / `{Theme:n}`,
  and a fill is `{pattern:"Solid", bg:…, fg:…}`. `"#RRGGBB"` is only valid on
  commands with their own `color` param (`fillColor`, `fontColor`, `borders`).
- Number format: a named format (`General`, `Currency`, `Short Date`,
  `Percentage`, `Text`) **or** a format code (`"#,##0.00"`, `"yyyy-mm-dd"`).
  Arbitrary strings are accepted and can produce garbage display.
- Boolean toggles: pass the value explicitly (`on:true`). `on:"yes"` is coerced
  to false in some commands; omitting it toggles.
- Formulas are saved with cached results; `formulas.calculateNow` recalculates.
  `data.refreshAll` refreshes PivotTables, not formulas.

## Pitfalls

- **`write_range` is anchor-only.** A 2×2 array at `A1` fills `A1:B2`; a 1-D
  list fills a row. Empty `values` is a silent no-op. Edge-cell writes such as
  `XFD1` or `A1048576` can inflate `usedRange` to the whole sheet.
- **`get_cell` has no `sheet` argument** over MCP. Use
  `execute_command {command:"cell.get",params:{cell,sheet}}`.
- **Object IDs are session-local and shared** across pictures/shapes/charts;
  they change after reload. Inspect ids before `object.delete`/`chart.set`.
  A wrong/nonexistent id may return success without deleting anything.
- **Unknown parameter names are silently ignored.** A misspelling looks like
  “nothing happened”. `home.bold {rang:…}` returns `{on:true}` but does nothing.
- **Conditional-format fills fail silently.** `rule.style` is a full `Style`, so
  `{fill:{color:"#C6EFCE"}}` is accepted and drops the fill; the rule still
  evaluates and counts in `inspect_workbook`, it just paints nothing. Use
  `{fill:{pattern:"Solid", bg:{Rgb:0xC6EFCE}, fg:{Rgb:0xC6EFCE}}}` and confirm
  the `<fill>` inside the saved `dxf` (`bugs-and-workarounds` §24, §28).
- **On-screen colours are theme-blended.** CF fills composite over the theme and
  table style, so screenshot pixels never match the dxf hex. Verify styles from
  the saved XLSX or a LibreOffice render, not from `screenshot`.
- **Import formats are not equivalent.** HTML import is broken (raw markup in
  A1); ODS is data-only (formulas become values); XLS/XLSB are partial. Use XLSX
  for round-trip work.
- **CSV is display text.** Export writes formatted values (`$2.50`,
  `10/22/2026`); import infers types and loses leading zeros. `=1+1` imports as
  text. Use `csvAsText:true` or XLSX when fidelity matters.
- **Unknown chart types fall back to ColumnClustered.** Use `doughnut`, not
  `donut`; `chart.set` without an id edits the selected chart.
- **Dialogs do not reliably apply.** `ui.dialog.confirm` works for
  `dataValidation`, but `sort`, `formatCells` and `nameManager` report “no OK
  command” and `pageSetup` returns success without applying. Drive the
  underlying command instead.
- **GUI focus first.** Call `ui.focus` before clicks; a click while another
  app's modal dialog is focused can block the control channel. Type with
  `ui.edit.begin` → `ui.edit.text` → `ui.edit.commit`; `ui.edit.text` replaces
  the editor text. Commit or cancel before clicking another cell.
- **`.txt` save is actually TSV** with CRLF. `.ods` and `.xls` saves are
  refused. `.html` export is fine but `.html` import is not.
- **Validation is weak on save.** Invalid base64 images, cells over 32,767
  characters, headers over 255 characters, invalid print paper and overlapping
  merges are accepted. `gridcraft-cli check` can still pass because it does not
  validate every payload. Check those separately.
- **Third-party XLSX round-trips lose package/chart styling.** A LibreOffice-
  generated workbook keeps cell content after GridCraft save but `check` exits 1
  on `package` differences and chart style/color parts. Inspect before delivery.

## Reference files

`references/`: `mcp-and-control.md`, `cli.md`, `commands.md`, `command-index.md`,
`functions.md`, `recipes.md`, `bugs-and-workarounds.md`, `formats.md`.
`scripts/`: `probe.sh`, `dump-commands.sh`, `smoke-test.sh`.

## Maintenance — this software is changing

Verified **2026-10-22 against 0.9.0**. Command ids, params, counts, schemas and
defaults can change between releases; confirm details against the installed build.

```sh
bash ~/.config/opencode/skills/gridcraft/scripts/probe.sh
bash ~/.config/opencode/skills/gridcraft/scripts/dump-commands.sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/gridcraft
```

`probe.sh` checks versions, paths, port, MCP handshake and catalog counts.
`dump-commands.sh` diffs the live catalog against `command-index.md`; add
`--update-skill` to refresh it. `smoke-test.sh` does a write/read/formula/save/
check on a temp workbook.

**Not tested in 0.9.0:** password-protected XLSX import, XLSB import, macros,
printing to hardware, very large workbooks (millions of cells), simultaneous
editing, and Microsoft Excel itself (LibreOffice was the independent validator).
