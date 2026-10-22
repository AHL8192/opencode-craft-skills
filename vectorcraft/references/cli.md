# vectorcraft-cli 0.14.0

`vectorcraft-cli` is the headless side of VectorCraft: the MCP server, a batch
runner, a converter, a document inspector and benchmarks.

```
vectorcraft-cli mcp [--connect ADDR | --headless] [--automation-read-root DIR] [--automation-write-root DIR]
vectorcraft-cli run [--in FILE] [--cmd ID [--params JSON]]... [--export FILE]... [--scale N]
vectorcraft-cli convert IN OUT [--scale N] [--artboard I | --range R] [--outline-text]
                    [--decimals N] [--replace-lossy] [--editing-data]
                    [--ai-version 7|pdf] [--hidden-objects layer|omit|visible]
                    [--transparent-images flatten|omit]
vectorcraft-cli commands            # JSON catalogue (792 entries, no doc open)
vectorcraft-cli info FILE           # JSON: warnings, title, units, artboards, kinds, fonts
vectorcraft-cli bench FILE [--size WxH] [--iters N]
vectorcraft-cli perf [--paths N] [--deep]
vectorcraft-cli --version / --help
```

## `mcp`

- Default: try `127.0.0.1:7979`, **fall back to headless** when nothing listens.
- `--connect ADDR`: use that app only; errors if unreachable, never falls back.
- `--headless`: never touch a window.
- Automation roots imply `--headless`; `--connect` plus roots is an error.
- Startup line (`vectorcraft-cli: MCP server on stdio (headless)`) goes to stderr.

## `run` — batch without a window

```sh
vectorcraft-cli run \
  --cmd file.new --params '{"width":600,"height":400}' \
  --cmd shape.rectangle --params '{"x":40,"y":40,"width":200,"height":120}' \
  --cmd paint.setFill --params '{"color":"#e8573f"}' \
  --cmd document.save --params '{"path":"/tmp/out.vectorcraft"}' \
  --export /tmp/out.png
```

- `--in FILE` opens a file first; `--export` can repeat; the extension picks the format.
- One JSON result per step on stdout: `{"step":"cmd","command":"…","result":…}`.
- **`--cmd` takes engine command ids plus three host commands**
  (`file.open`, `file.save`, `file.export`). MCP tool names (`draw_shape`,
  `doc_inspect`, `command_run`) fail with `unknown command`. A failing step
  aborts the run, so later `--export` steps are silently skipped.
- Verified host-command run: `file.save {path:"x.svg"}` writes SVG (with a
  "SVG keeps the artwork but not everything…" warning) and
  `file.export {path:"x.png"}` writes the PNG, both exiting 0.
- Engine commands still validate *named* required params: `shape.rectangle {}`
  → `missing number 'x'`. Extra/typo keys and wrong types are ignored
  (`{"widht":10}` → no shape, no error).
- `--scale` applies to raster exports only.

## `convert` — one file in, one out

- Format from OUT's extension; readable/writable lists are in `--help`.
- PDF gets every artboard unless `--artboard`/`--range`; EPS the art bounds;
  other formats the first artboard.
- `--artboard` is **0-based** and `--range` **1-based** ("1-3,5") per `--help`;
  the MCP `export` artboard index is 0-based (verified: `artboard:1` gave page 2).
- `--outline-text`, `--decimals 1–7`, `--editing-data` (read a .ai from its
  editing copy), `--ai-version 7|pdf`, `--hidden-objects`, `--transparent-images`.
- Refuses `OUT == IN` when reading IN lost anything unless `--replace-lossy`.
- Prints `warnings` for the export and `importWarnings` for what IN lost.

## `info` — the fastest fidelity check

```sh
vectorcraft-cli info out.vectorcraft
```

Returns `file`, `info` (title, units, artboards, objects, colorMode, dates),
`artboards[]`, `kinds{}`, `fonts[]` (`family`, `resolved`, `status`,
`missingGlyphs`), and `warnings` from import. Use it after every import/export
round trip — it is how you catch "opened as a picture" degradations.

## `commands`

Full JSON catalogue. Entries look like:

```json
{"id":"shape.rectangle","label":"Rectangle","menu":["Object","…"],
 "params":"{x, y, width, height, radius?: pt, …} → {id}",
 "enabled":true,"shortcut":null}
```

Without an open document 665 of 792 are `enabled:false`; that is expected, not a
broken install. Use MCP `command_list` on a live document for true enablement.
Note the catalogue can contain ids the engine/menu do not expose (`file.export`).

## `bench` and `perf`

`bench FILE [--size 2880x1800] [--iters N]` renders the document fitted and
prints ms/frame (warm, multithreaded and single-threaded). Verified on an
800×600, 3-object document: `threads 3: 47.1 ms/frame`, `threads 0:
5.6 ms/frame`. `perf [--paths N]` checks the project's performance budgets on a
synthetic document; with `--paths 100` it printed 8 budgets, marked 2 OVER
(400% zoom 54.7 ms vs 16 ms; Pathfinder 1,000 paths 153.4 ms vs 150 ms) and still
exited 0 with `2 over budget, but the machine is busy: re-run when idle`.
Both are safe on copies; avoid concurrent heavy benchmarks.

## Observed failure messages (0.14.0)

| Situation | Output |
|---|---|
| unknown command | `vectorcraft-cli: <id>: unknown command \`<id>\`` |
| missing required param | `invalid parameters for \`shape.rectangle\`: missing number \`x\`` |
| unknown extension | `unknown extension \`.xyz\`: pass \`format\` (see document.formats)` |
| no such artboard | `no artboard 99 (0-based; the document has 1)` |
| missing directory | `<path>: No such file or directory (os error 2)` |
| permission denied | `<path>: Permission denied (os error 13)` |
| junk input | `can't open \`x\`: not a format VectorCraft reads (see document.formats)` |
| empty native file | `not a VectorCraft file: EOF while parsing a value at line 1 column 0` |
| bad SVG | `SVG parse error: unexpected end of stream` |
