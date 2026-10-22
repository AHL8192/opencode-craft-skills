# GridCraft CLI

`gridcraft-cli` 0.9.0 is the batch/headless companion to the desktop app. It
opens files in-process; it does not share the GUI's open workbooks. Paths can be
relative. Most commands print human-readable output; `--json` switches to
machine-readable output where supported.

```text
usage:
  gridcraft-cli info <file> [--json]
  gridcraft-cli convert <in> <out> [--sheet NAME]
  gridcraft-cli eval <formula> [--in FILE] [--sheet S] [--cell A1] [--json]
  gridcraft-cli cat <file> [--range A1:D20] [--sheet S] [--formulas] [--csv]
  gridcraft-cli check <file-or-dir>... [--json] [--tolerance 1e-9] [--max-report N]
  gridcraft-cli run [--in FILE | --sample NAME] [--cmd 'id={json}']...
                     [--script FILE.jsonl] [--out FILE] [--print RANGE] [--quiet]
  gridcraft-cli commands [--json] [--search X]
  gridcraft-cli functions [--json] [--search X] [--category C]
  gridcraft-cli mcp [--connect PORT] [--in FILE | --sample NAME]
  gridcraft-cli send <port> <method> [json]
  gridcraft-cli version
```

## `info`

```sh
gridcraft-cli info book.xlsx
gridcraft-cli info book.xlsx --json
```

Prints title, sheets, used ranges, cell counts, tables, charts and names —
useful as a cheap independent check after an agent saved a file. It does not
recalculate or validate the package; use `check` for that.

## `convert`

```sh
gridcraft-cli convert in.xlsx out.pdf
gridcraft-cli convert in.xlsx out.csv --sheet Sheet2
gridcraft-cli convert in.csv out.xlsx
```

The output format is chosen from the destination extension: xlsx, csv, tsv,
json, html, pdf. Success messages (`wrote …`) go to **stderr**, so scripts that
capture stdout may see nothing. Conversion is data-oriented and may not preserve
everything from the source; inspect the result.

## `eval`

```sh
gridcraft-cli eval '=SUM(A1:A3)'
gridcraft-cli eval '=SUM(B2:B4)' --in book.xlsx --sheet Data --cell B5
gridcraft-cli eval '=A1*2' --json
```

Evaluates against the file (or a blank workbook), optionally at a position for
relative references. Formulas with syntax errors return `#NAME?` (or another
error value) and **exit 0**; `--json` gives `{"error":"#NAME?"}`. Check the
output, not just the exit code.

## `cat`

```sh
gridcraft-cli cat book.xlsx
gridcraft-cli cat book.xlsx --range A1:D20 --sheet Data
gridcraft-cli cat book.xlsx --formulas
gridcraft-cli cat book.xlsx --range A1:D20 --csv
```

Prints cell values (or formulas with `--formulas`) as aligned text or CSV.
Without `--range`, prints the used range. Empty cells are blank. This is a
read-only inspection path and does not open the GUI.

## `check`

```sh
gridcraft-cli check out.xlsx
gridcraft-cli check out.xlsx --json
gridcraft-cli check exports/ --json
gridcraft-cli check out.xlsx --tolerance 1e-6 --max-report 50
```

The strongest verification available. For each XLSX it:

1. opens the file,
2. evaluates formulas and compares cached vs computed values (the calculation
   oracle),
3. saves a round-trip copy and compares categories: `package`, `sheets`,
   `values`, `formulas`, `numFmts`, `merges`, `names`, `tables`,
   `condFormats`, `validations`, `charts`, `comments`, `hyperlinks`, `pivots`.

Exit code 0 means no differences; exit 1 means differences (or load/calc
failure). `--json` reports `files[].opened`, `calc.checked`,
`calc.mismatched`, and `roundTrip.differing`. The `package` category is
sensitive to third-party XLSX structure: a LibreOffice-generated file often
keeps all content categories equal but reports lost chart style/color
relationships and therefore exits 1. Read the category list, not just the exit
code.

`check` does not validate embedded media bytes, Excel's 32,767-character cell
limit, 255-character header limit, or whether every app can open the result.
Pair it with LibreOffice (`soffice --headless --convert-to pdf`) and a media
inspection when those matter.

## `run`

Run a sequence of commands in one process, optionally save and print:

```sh
gridcraft-cli run --sample budget --out /tmp/budget.xlsx

gridcraft-cli run --in in.xlsx \
  --cmd 'home.bold={"range":"A1:F1"}' \
  --cmd 'cell.set={"cell":"H2","input":"from CLI"}' \
  --out out.xlsx --print A1:H10

gridcraft-cli run --script steps.jsonl --out out.xlsx
```

`--cmd` accepts `id={json}` or `id` (bare). `--script` is one command per line:

```text
# comments are allowed
home.bold {"range":"A1:F1"}
cell.set={"cell":"H2","input":"from script"}
```

A failed command stops the run and **no output file is written** (the tool
reports the failure). `--quiet` suppresses progress. `--print` prints the given
range after the commands. Use absolute paths in shared automation.

## `commands`, `functions`

```sh
gridcraft-cli commands --json                 # 341 commands, full params
gridcraft-cli commands --search chart
gridcraft-cli functions --json                # 514 functions
gridcraft-cli functions --category "Math & Trig"
```

`--json` is the authoritative catalog used by the skill's
`scripts/dump-commands.sh`. Counts can change between releases; compare, don't
assume.

## `mcp`

```sh
gridcraft-cli mcp                              # headless stdio MCP
gridcraft-cli mcp --in book.xlsx               # start with a file
gridcraft-cli mcp --sample budget              # start with a sample
gridcraft-cli mcp --connect 7979               # bridge to GUI
```

The headless server speaks MCP on stdin/stdout; stderr carries logs. The bridge
requires `gridcraft --control 7979` to be running. `--in` and `--sample` are
startup conveniences; they do not give the headless process access to the GUI's
documents.

## `send`

```sh
gridcraft-cli send 7979 ui.inspect
gridcraft-cli send 7979 cell.get '{"cell":"C1"}'
gridcraft-cli send 7979 engine.execute '{"command":"home.bold","params":{"range":"A1"}}'
```

Sends one control-channel request and prints the JSON response. The control
channel is unauthenticated localhost TCP; see `mcp-and-control.md`. Focus the
window first if a request involves UI input. If the app is behind another
application's modal dialog, take a screenshot before retrying or killing it.

## `version`

```sh
gridcraft-cli version        # gridcraft-cli 0.9.0
gridcraft --version          # GridCraft 0.9.0
dpkg-query -W gridcraft      # gridcraft 0.9.0-1
```

## Common failures

| Message | Meaning |
|---|---|
| `ODS is supported for data import only` | Save as `.xlsx`, not `.ods`. |
| `Excel 97-2003 (.xls) is supported for import only` | Save as `.xlsx`. |
| `No such file or directory` | Wrong path, or file was never written. Check the run result. |
| `check` exit 1, `package` differing | Third-party package/chart-style relationships changed. Inspect the categories. |
| `eval` prints `#NAME?`, exit 0 | Formula parse/name error; check output. |
| `convert` prints nothing on stdout | Success text is on stderr; check the destination file. |
