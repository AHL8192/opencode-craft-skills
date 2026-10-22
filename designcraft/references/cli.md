# designcraft-cli (0.10.0)

`designcraft-cli` is the headless renderer, command runner and MCP host. The
desktop app is `designcraft` (same engine, plus a window).

```
designcraft-cli run [--in FILE | --sample] [--cmd ID[=JSON]]... [--page N] [--scale S]
                    [--pdf-options JSON] [--export OUT] [--all-pages DIR]
designcraft-cli commands [FILTER]
designcraft-cli describe COMMAND
designcraft-cli script [FILE|-] [--in FILE | --sample] [--connect PORT]
                       [--save OUT] [--export OUT] [--keep-going]
designcraft-cli app [--port PORT] COMMAND [JSON] | --method METHOD [JSON]
designcraft-cli mcp [--connect PORT] [--sample] [--automation-read-root DIR]
                    [--automation-write-root DIR]
designcraft-cli perf [--pages N] [--runs N] [--strict]
designcraft-cli bench FILE [--runs N]
designcraft-cli links
designcraft-cli --version
```

`designcraft-cli --help` prints this synopsis; `run --help` does **not** work
(`unknown option --help`) — use the top-level help and `script --help`.

## Discovering commands

```sh
designcraft-cli commands                      # JSON array of 521 commands
designcraft-cli commands table                # filter id/label/menu
designcraft-cli describe table.insert         # label, menu, shortcut, params
```

Fields per command: `id`, `label`, `menu[]`, `shortcut`, `params`, `enabled`,
`disabled_reason`. Disabled is contextual — 491 disabled with no document.

## `run`: one-shot render/export

```sh
# render every page of the built-in magazine sample to PNG
designcraft-cli run --sample --all-pages out/

# open a document, run commands, export
designcraft-cli run --in report.designcraft \
  --cmd 'file.exportPdf={"path":"report.pdf","standard":"x4"}' \
  --export page.png
```

`--page`, `--scale` and `--pdf-options` apply to the exports that follow them.
`--sample` builds the four-page magazine in memory (no file needed).

## `script`: several commands, results feed later steps

```sh
cat > page.dcs <<'DCS'
# comment; one command per line
file.new {"preset":"A4","pages":2,"margins":48}
frame.create {"rect":[48,48,547,140],"content":"text","text":"Report","caret":true}
type.char {"attrs":{"size":30}}
frame.create {"rect":[48,180,547,500],"content":"text","text":"$1.story"}
DCS
designcraft-cli script page.dcs --save out.designcraft --export out.pdf
```

Output: `{"completed":n,"results":[…]}` plus `failedIndex`/`failedCommand`/
`error` and a non-zero exit on failure. JSON-lines and a JSON array of
`{command,params}` are also accepted; comments are `#` or `//`; CRLF and BOM are
fine.

References:

- `"$N.path"` — value at `path` in step N's result (0-based; comments/blank lines
  are not steps; `$last` is the previous step).
- `"${N.path}"` — interpolate inside a longer string.
- `$$` — literal `$`; other strings starting with `$` stay as written.
- Text params: `\n` new paragraph, `\u2028` forced line break, `\t` tab.

`--keep-going` records failures as `{"error": …}` and continues. `--connect PORT`
runs the same script against a live app instead of the in-process engine.

## `app`: one-shot client for a running window

```sh
designcraft-cli app --port 7984 document.inspect
designcraft-cli app --port 7984 engine.execute '{"command":"edit.undo"}'
designcraft-cli app --port 7984 --method ui.menu.invoke '{"command":"layout.documentSetup"}'
```

Default port is **7979** — also GridCraft's configured port on this machine. Use
`--port 7984+`. Errors are printed and the exit code is non-zero when the app is
not listening.

## `mcp`: the MCP host

See `mcp-and-control.md`. Use `--automation-read-root`/`--automation-write-root`
for confined agent runs; they cannot be combined with `--connect`.

## `perf` and `bench`

```sh
designcraft-cli perf --pages 20 --runs 1
designcraft-cli bench FILE --runs 3
```

`perf` prints measured vs budget for composing, rendering, keystrokes, PNG/PDF
export, save and open. On this shared 11 GiB / Intel UHD 620 laptop, 20 pages
measured: compose 515 ms, render 100% 155 ms (budget 16 ms, OVER), PDF export
3.8 s (budget 400 ms, OVER), save/open ~276/232 ms (within budget). It appends
"the machine is busy: re-run when idle" when other work is running.

## `links`

Prints the community/website/GitHub/issue URLs. Useful for a bug report footer.

## Exit codes and logs

- `0` success; non-zero on a failed script step or export.
- MCP logs go to stderr (`designcraft-cli: MCP server on stdio (headless …)`).
- The desktop app logs to `<profile>/logs/designcraft.log` and rotates to
  `designcraft.1.log`/`.2.log`; a start that never showed a frame first writes
  `gpu.json`. `--version` writes no log.
- `RUST_LOG` controls both stderr and the file; `WGPU_BACKEND` chooses the
  compositor backend (`vulkan`, `gl`, `dx12`, `metal`).

## Verified examples

```sh
$ designcraft-cli --version
designcraft-cli 0.10.0

$ designcraft-cli script cli-test.dcs --save cli-out.designcraft --export cli-out.pdf
{"completed": 4, "results": [...]}          # 0.50 s, 37 MB RSS

$ pdfinfo cli-out.pdf | grep -E 'Pages|Page size|Producer'
Producer:        DesignCraft
Pages:           2
Page size:       595.276 x 841.89 pts (A4)
```
