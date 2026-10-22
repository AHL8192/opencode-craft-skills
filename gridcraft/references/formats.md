# GridCraft 0.9.0 — formats and round-trip fidelity

GridCraft is XLSX-first. Other formats are useful for interchange, but only XLSX
preserves the full feature set. This matrix reflects tests against the installed
0.9.0 build; “not tested” means exactly that, not “known broken”.

## Matrix

| Format | Open | Save | Fidelity in 0.9.0 |
|---|---|---|---|
| `.xlsx` | yes | yes | Native. Values, formulas, cached results, number formats, merges, names, tables, charts, conditional formats, validation, comments, hyperlinks, freeze panes and page setup round-trip. `check` passed twice on the comprehensive workbook. |
| `.xlsm` | yes (per tool docs) | untested | VBA/macros were **not tested**. Treat as XLSX data unless proven otherwise. |
| `.xls` | yes | **no** | Values, formulas, number formats, merges, column widths, row heights and defined names import. Fonts, fills, borders, charts, pictures, comments and other features are dropped. Title becomes `name (imported).xlsx`, path is null. Save is refused. |
| `.xlsb` | yes (per tool docs) | **no** | Worksheet data and cached formula values only (tool description). Not independently tested. |
| `.ods` | yes | **no** | Data-only: formulas become saved results and do not recalculate; formatting, charts, images, tables, names and validation are lost. Title becomes `name (imported).xlsx`, path null, warning returned. Save refused. |
| `.csv` | yes | yes | Active sheet only. Save writes **displayed/formatted** values. Import infers numbers, dates, currencies and percentages; formulas are text; leading zeros can be lost. `csvAsText:true` disables conversion. |
| `.tsv` | yes | yes | Same as CSV with tab delimiter. |
| `.txt` | yes | “yes” | Save silently writes TSV with CRLF, despite the extension. Import treats it as delimited text. Use `.csv`/`.tsv` explicitly. |
| `.json` | yes | yes | GridCraft's own workbook JSON (sheets, cell bands, styles, theme, calc settings). Not a general tabular JSON interchange; round-trips through GridCraft. |
| `.html` | **broken** | yes | Export writes a styled HTML table. Import does not parse HTML: it treats the markup as delimited text, leaving `<!doctype html>…` in A1 and splitting the rest across columns. Never use HTML as an import path. |
| `.pdf` | no (not a workbook) | yes | PDF export of active sheet or all sheets; honors page setup. Use `pdfinfo`/`pdftotext` for verification. Not a round-trip format. |

## What survived the comprehensive XLSX round-trip

The test workbook (`/tmp/opencode/skill-tests/gridcraft/roundtrip/roundtrip.xlsx`
in the test workspace) contained 10 formulas, multiple sheets, number formats,
merges, defined names, tables, conditional formatting, data validation, charts,
comments/replies, hyperlinks, freeze panes and page setup. `gridcraft-cli check`
reported:

- 10/10 formulas checked with 0 mismatches,
- all 14 categories equal,
- exit 0, twice.

`check` categories: `package`, `sheets`, `values`, `formulas`, `numFmts`,
`merges`, `names`, `tables`, `condFormats`, `validations`, `charts`,
`comments`, `hyperlinks`, `pivots`.

## Third-party XLSX

A LibreOffice-generated XLSX (`independent/lo/source.xlsx`) opened and
round-tripped with content equal (`values`, `formulas`, `numFmts`, `merges`,
`names`, `tables`, `condFormats`, `validations`, `charts`, `comments`,
`hyperlinks`, `pivots` all `equal:true`), but `check` exited 1:

```text
package: 3 differences
lost relationship chartColorStyle
lost relationship chartStyle
lost relationship core-properties
```

The saved chart also lost some style/detail XML. This is a package-fidelity
issue, not a cell-value issue. Always inspect a third-party file visually and
compare the original; do not promise byte-identical output.

## CSV details verified

Export of a formatted sheet produced:

```csv
Region,Units,Price,Revenue,Date,Share
East details,12,$2.50,$30.00,1/15/2026,26.67%
West,8,$4.00,$32.00,2/20/2026,17.78%
```

- Currency, dates and percentages are exported as display text (`$2.50`,
  `1/15/2026`, `26.67%`), not raw numbers.
- Import of a CSV containing `=1+1` produced text, not a formula.
- Import inference can turn `00123` into `123` and dates into serial values.
- `csvAsText:true` keeps every field as text (and is the safe mode for IDs,
  phone numbers, postal codes, account numbers).
- A UTF-8 BOM and semicolon delimiter imported correctly in testing; do not
  generalize that to every dialect. Confirm the resulting used range.

## PDF export

`save_workbook({path:"out.pdf"})` and `file.exportPdf` produce a PDF of the
active sheet; `file.exportPdf {sheets:"all"}` exports all sheets. Page setup is
honored for orientation, paper, margins, print area, titles and scaling. Verify
with:

```sh
pdfinfo out.pdf | grep -E 'Pages|Page size'
pdftotext out.pdf - | head
```

Invalid paper names may preview but are omitted from the saved XLSX; see
`bugs-and-workarounds.md`.

## Images and embedded media

`insert.picture` accepts `path` or base64. A 7-byte payload decoding to
`invalid` was accepted with `mime:"image/png"` and saved as
`xl/media/image2.png`; `check` passed because media bytes are not validated.
Validate images before insertion and inspect the media parts:

```sh
unzip -l out.xlsx | grep media
unzip -p out.xlsx xl/media/image1.png | file -
```

## File-size and Excel limits

GridCraft does not enforce Excel's limits on save in 0.9.0:

| Limit | GridCraft behavior |
|---|---|
| 32,767 characters per cell | A 40,000-character string saved intact. |
| 255 characters per header/footer | A 300-character header saved intact. |
| Valid image bytes | Invalid bytes accepted. |
| Valid paper name | Invalid name accepted in preview, omitted on save. |
| Non-overlapping merges | Overlapping merge silently replaces prior merge. |

Excel or LibreOffice may repair/truncate such files. Enforce limits in the
generating script and open the result in an independent app before delivery.

## Recommended format choices

- **Round-trip / delivery:** `.xlsx`.
- **Data exchange with non-spreadsheet tools:** `.csv` with `csvAsText` on
  import; accept display-value export or build a separate raw-data sheet.
- **Browser/report artifact:** `.html` export only, never import.
- **Print/share:** `.pdf` after checking page setup.
- **ODS/XLS source:** convert with LibreOffice to `.xlsx`, then import; verify
  formulas/styles because GridCraft's direct imports are partial.
