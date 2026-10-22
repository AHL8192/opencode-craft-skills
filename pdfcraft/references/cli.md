# PdfCraft CLI — 0.10.1

`/usr/bin/pdfcraft-cli`. The CLI is a thin, scriptable front end to the same
engine as the MCP server. Run `pdfcraft-cli` with no arguments (or with an
unknown verb) to print the full usage block.

## Verbs

| Verb | Purpose |
|---|---|
| `info <file.pdf> [--password PW]` | JSON summary: pages, boxes, metadata, fonts, security, declared PDF/A or PDF/UA |
| `text <file.pdf> [--page N]` | extracted text, pages separated by form feeds |
| `render <file.pdf> --page N [--dpi 96] --out x.png` | render to PNG/JPG/TIF/PAM |
| `edit <in.pdf> --out out.pdf [--rotate 1,3:90] [--delete 2,4] [--move 5:1] [--insert-blank 1] [--title T] [--author A] [--full]` | page edits, applied in the order given; page numbers refer to the document after earlier options |
| `combine <a.pdf> <b.pdf> … --out out.pdf` | merge |
| `extract <in.pdf> --pages 1,3,5-8 --out out.pdf` | extract in the order given |
| `split <in.pdf> (--every N \| --before 3,7) [--out-dir DIR]` | split |
| `check <files or dirs…> [--timeout 20] [--dpi 36] [--json out.json]` | validation sweep |
| `audit <file.pdf> [--password PW]` | find faux redactions; fails when findings exist |
| `batch <files or dirs…> --steps convert,ocr,optimize --out-dir DIR [--recursive] [--root DIR] [--stop-on-error] [--ppi 150] [--quality 60] [--dpi 300] [--language en] [--ocr-all-pages]` | batch convert/OCR/optimize |
| `tools` | 171 tool schemas as JSON |
| `run <tool> key=value … [--root DIR] [--out image.png]` | one tool |
| `run --script steps.json [--root DIR] [--report]` | ordered tool script; `--report` prints one JSON document |
| `mcp [--root DIR] [--compact] [--automation-read-root DIR] [--automation-write-root DIR]` | MCP over stdio |
| `ui --control FILE <method> [key=value …] [--out shot.png]` | drive the GUI control channel |

There is **no `commands` verb**. The registry (201 ids) is read with the MCP
`command_list` tool or the `pdfcraft://commands` resource.

## Scripts (`run --script`)

```json
[
  {"tool":"doc_open",   "args":{"path":"/work/in.pdf"}},
  {"tool":"page_rotate","args":{"doc":1,"pages":[1],"degrees":90}},
  {"tool":"page_add_text","args":{"doc":1,"page":1,"text":"Reviewed",
                                  "at":[36,36],"size":10,"color":"#CC0000"}},
  {"tool":"page_render","args":{"doc":1,"page":1,"dpi":96},
                        "out":"/work/page1.png"},
  {"tool":"doc_save",   "args":{"doc":1,"path":"/work/out.pdf"}},
  {"tool":"doc_close",  "args":{"doc":1}}
]
```

- `"out"` for `page_render` is a **sibling of `args`**. Putting it inside
  `args` gives `unknown argument "out" (expected: doc, dpi, …)`.
- Relative script paths resolve against the script's directory.
- `--report` is the reliable way to get per-step results; without it stdout is
  line-oriented.
- A failing step stops the script; the report names the step and the error.

## File confinement

`--root DIR` applies to reads and writes:

```
/tmp/out.pdf is outside the allowed directory /work
```

Both `doc_open` outside and `doc_save` outside are refused, with the offending
path and the allowed root in the message. Symlinks are followed. For MCP, prefer
the finer `--automation-read-root` / `--automation-write-root`; if you give only
one, the other side has no access at all. Never use `$HOME` as a root for
untrusted work.

## Examples (tested)

```sh
pdfcraft-cli info proof.pdf
pdfcraft-cli text proof.pdf
pdfcraft-cli render proof.pdf --page 1 --dpi 150 --out page.png
pdfcraft-cli run --script steps.json --root /work --report
pdfcraft-cli ui --control ~/.config/pdfcraft/control-x.json state
pdfcraft-cli ui --control ~/.config/pdfcraft/control-x.json screenshot --out gui.png
```

Outputs verified independently:

- `pdfcraft-cli info` reports page sizes, annotations, fields, bookmarks and
  encryption; use it as a second opinion after MCP saves.
- `render` at 150 dpi produced a 833×1042 PNG for a 400×500 pt page
  (400/72×150 ≈ 833).
- `--root` refusal and in-root success both observed.

## GUI subcommand

`ui` speaks one JSON request per invocation to the socket named in the control
file. Full method list and coordinate rules: `mcp-and-control.md`.

```sh
CTRL=~/.config/pdfcraft/control-x.json
pdfcraft-cli ui --control "$CTRL" state
pdfcraft-cli ui --control "$CTRL" click label="Highlight"
pdfcraft-cli ui --control "$CTRL" drag from='[410.3,240.8]' to='[504.1,263.3]'
pdfcraft-cli ui --control "$CTRL" command id=file.save
pdfcraft-cli ui --control "$CTRL" quit
```

Errors from the app are printed verbatim and exit nonzero, e.g.
`layout must be single, continuous, two-up or two-page`,
`no widget with id … on screen (run ui.inspect again)`,
`can't reach the app on port … (Connection refused)`.

## Exit codes and failure signals

- Tool/script errors: nonzero exit, message on stderr.
- `audit`: help text says it fails when faux redactions are found — check the
  exit status in scripts.
- `check --json`: writes a machine-readable report; inspect it rather than
  relying on stdout.
- A missing file, a directory passed as a file, or an out-of-root path all
  produce explicit messages (see `bugs-and-workarounds.md` for wording).
