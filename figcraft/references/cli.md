# `figcraft-cli` — headless operation (0.8.0)

```text
figcraft-cli — FigCraft without a window

  figcraft-cli info <file> [--json]
  figcraft-cli export <file> -o <out> [--format png|jpg|svg|webp|pdf|fig] [--scale N]
                      [--page NAME] [--node ID|NAME] [--bleed LENGTH] [--crop-marks]
                      [--bleed-marks] [--cmyk]
  figcraft-cli convert <in> <out>
  figcraft-cli render <file> -o <out.png> [--scale N] [--page NAME]
  figcraft-cli run <script.json|script.jsonl> [--in <file>] [--out <file>]
  figcraft-cli commands [--json] [--filter TEXT]
  figcraft-cli mcp [--attach PORT] [--automation-read-root DIR]... [--automation-write-root DIR]...
  figcraft-cli plugin publish <folder> --server ws://host:port/[?key=KEY]
  figcraft-cli perf [--layers N[,N...]] [--instances N[,N...]]
  figcraft-cli help | --help | --version
```

Global: `--no-system-fonts` on every subcommand (or `FIGCRAFT_NO_SYSTEM_FONTS=1`) — built-in fonts
only, for reproducible renders. Installed fonts are indexed once per run when text is first laid
out (~60 ms class).

Exit codes (verified): **2** for bad arguments/unknown option/unknown subcommand, **1** for a
failure at run time, **0** on success. Usage text goes to stderr for errors.

## info

```sh
figcraft-cli info file.figcraft
figcraft-cli info file.figcraft --json
```

Human output: `file — name (N nodes, S styles, V variables, I images)`, then per page
`page 1 "Page 1": n nodes, t top-level` and each top-level frame with size. JSON adds `images`,
`missingFonts`, `notes` (for `.fig`, what wasn't imported), `styles`, `variables`.

Use it as the independent read-back after `save_file`.

## export

```sh
# one file per top-level frame into a directory
figcraft-cli export deck.figcraft -o out-frames --scale 1        # out-frames/Trail.png …
# one file: out has an image extension
figcraft-cli export deck.figcraft -o shot.png --node 2 --scale 2
figcraft-cli export deck.figcraft -o hero.png --node "Welcome"   # id or layer name
# PDF: one page per top-level frame (reading order)
figcraft-cli export deck.figcraft -o deck.pdf
# print options
figcraft-cli export deck.figcraft -o print.pdf --bleed 3mm --crop-marks --bleed-marks --cmyk
# whole file as experimental .fig
figcraft-cli export deck.figcraft -o deck.fig
```

Verified: `--node 2` produced 434×471 for a 434×471 frame; `--node "Welcome"` produced 392×846;
a 4-frame template exported a 4-page PDF with real text (`pdftotext`), page size in points
(392×846); `--scale 2` doubled pixels; `--page NAME` selects a page by name (not id).
`--node` with a name that doesn't exist errors `no layer with id or name \`Home\`` and exits 1.

Format is taken from `--format` when given, otherwise from the output extension. Ask for what the
extension says; unlike MCP `file.export`, the CLI's directory mode and extension handling are
consistent.

## convert

```sh
figcraft-cli convert dashboard.figcraft dashboard.json   # native → FigCraft/REST JSON
figcraft-cli convert dashboard.json back.figcraft        # JSON → native
figcraft-cli convert shapes.svg fromsvg.figcraft         # SVG → editable frame
figcraft-cli convert proof.png frompng.figcraft          # image → document with one image layer
```

Verified round trip: `dashboard.figcraft` → 291 KB JSON with 1 page, 186 nodes in `nodes`,
19 styles → back to a 44 KB `.figcraft` → rendered 1800×844. SVG became `shapes` (4 nodes:
frame + rect + text, warnings empty). PNG became `proof` (2 nodes, 1 image). Output format comes
from the extension; `.figcraft`, `.json`, `.svg`, images are understood.

## render

```sh
figcraft-cli render file.figcraft -o page.png [--scale N] [--page NAME]
```

Renders the current page (first frame? no — the page render) at the page size × scale. Fast path
for CI: 457 ms / 28 MB peak RSS on a 2000-layer file measured with `/usr/bin/time -v`.

## run — command scripts

```sh
figcraft-cli run build.json --out result.figcraft
figcraft-cli run steps.jsonl --in seed.figcraft --out result.figcraft
```

A script is a JSON array (or JSON lines) of `{"command": id, "params": {…}}`. `{"$step": n}`
inside params refers to the id returned by step n. Output is one JSON result line per step:

```json
{"command":"node.create","ok":true,"result":{"id":2},"step":0}
```

A failing step prints `ok:false` with the error, aborts the script, **writes no output**, and exits
1 (verified with a bad node id after a good create). `--in` opens a starting document; `--out`
saves at the end (`.figcraft`, or `.fig` for the experimental export). This is the quickest way to
script FigCraft without an MCP client.

## commands

```sh
figcraft-cli commands                     # human list, one command per line
figcraft-cli commands --json              # 569 objects: id,label,menu,params,shortcut,undoable
figcraft-cli commands --filter "auto layout"
figcraft-cli commands --filter autoLayout # 0 lines (literal substring, no space = no match)
```

Filter is case-insensitive but literal: `layout` and `Layout` match the same 36 lines,
`autoLayout` matches nothing, `auto layout` matches 22.

## mcp

See `mcp-and-control.md`. `--attach PORT` drives a running app; `--attach` refuses automation
roots (the app confines itself at launch). Headless `mcp` accepts the roots to confine every
command it runs.

## Automation roots

```sh
figcraft --control 47801 --automation-read-root /work/project \
         --automation-write-root /work/project/out
figcraft-cli render /work/project/in.figcraft -o /work/project/out/x.png \
         --automation-read-root /work/project --automation-write-root /work/project/out
```

Reads must be inside a read **or** write root; writes must be inside a write root; no write root
means no writes. Refusals are `automation path rejected: …` (exit 1). Roots must exist. Passing a
misspelled flag (`--automation-write-roots`) exits 2 with `unknown option` and never starts
unconfined — verified both directions (inside allowed, outside refused).

## perf

```sh
figcraft-cli perf --layers 100 --instances 0
```

Builds synthetic documents and prints timings (open/build/save/render, memory). Useful as a
smoke test for regressions; it does not read a document.

## plugin publish

```sh
figcraft-cli plugin publish ./my-plugin --server ws://host:port/?key=KEY
```

Sends `figcraft-plugin.json`, the module and optional `assets/` to a `figcraft-server` plugin
directory. Not exercised here (no server).

## Measured timings (this machine, 4 cores)

| Operation | Result |
|---|---|
| 2,000 rectangles in one `batch` | 2,271 ms |
| save 2,000-layer document | 40 ms (96 KB) |
| `inspect_document allPages` on it | 144 ms |
| select all 2,000 | 5 ms |
| 10× save + reopen a small file | ~36 ms total |
| 10,000-character text layer / save / render | 676 / 131 / 284 ms |
| 40-deep frame nesting | under 1 s total |
| template open + save + PNG export | 110–986 ms per template |
| CLI render 2,000 layers | 457 ms, 28 MB peak RSS |

Memory: the desktop app idles around 300 MB RSS; the headless CLI around 30–60 MB.
