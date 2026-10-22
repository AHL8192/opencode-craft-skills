# `effectcraft-cli` — 0.13.0

A single-shot client for the same engine. It loads a project into memory, runs,
and exits. There is **no `--help`**: run it with no arguments for usage. Usage
errors exit **2**; a file that cannot be opened exits **1**; command failures
print an error and exit non-zero.

```text
effectcraft-cli <info|commands|exec|run|props|get|set|render-frame|render|script|mcp> [args] [--json]
```

Global options (after the subcommand and its args):

```text
--project F.ecproj | --demo | --empty    what to load (default: the demo project)
--save | --save-as F.ecproj              write changes back / to a copy
--bridge PORT                            use a running app's engine
--json                                   machine-readable output
--gpu                                    GPU path (untested on this machine)
```

`<comp>` is an id or name, `-` means the active comp. `<layer>` is an id, `#n`
(1-based from the top) or a name. `<value>` is JSON, or a bare string.

## Subcommands

| Command | Use |
|---|---|
| `info [F.ecproj]` | project summary: comps, items, engine counts. With no file it opens the **demo** project. |
| `commands [--filter TEXT] [--enabled] [--json]` | catalog |
| `exec <id> [--params JSON] [--json]` | run one command; `exec --list` = `commands` |
| `exec --list --schemas --json` | every id with params + JSON Schema |
| `run [F.ecproj] <id> <json> <id> <json> …` | run several commands in order |
| `props <comp> <layer> [--flat] [--time S] [--json]` | property tree with addressable paths |
| `get <comp> <layer> <path> [--time S] [--json]` | value/evaluated/keys |
| `set <comp> <layer> <path> <value> [--time S] [--expression E] [--json]` | set a value or expression |
| `render-frame [--comp C] [--time S \| --frame N] [--max-side PX \| --scale K] [--out F.png] [--transparent]` | one PNG |
| `render [--comp C] --out FILE [--format F] [--start S] [--end S] [--work-area] [--fps N] [--resolution full\|half\|third\|quarter\|K] [--quality best\|draft] [--channels rgb\|rgba] [--jpeg-quality N] [--bitrate KBPS] [--prores PROFILE] [--audio auto\|on\|off]` | movie / sequence |
| `render … --queue` | render the project's queue instead of `--out` |
| `render/render-frame --template T.ectemplate [--values V.json]` | render a template instance |
| `script FILE.jsx [F.ecproj] \| --eval CODE` | AE-style JS; prints `writeLn`, exits 1 with `file:line:col` on error |
| `mcp [--autosave \| --bridge PORT] [--automation-read-root DIR] [--automation-write-root DIR]` | MCP server on stdio |
| `bench [--comp C] [--time S] [--scale K] [--n N] [--play N] [--gpu [--adv3d]]` | per-layer/effect timings |
| `bench --ops [--small] [--layers N] [--comps N] [--footage N]` | operation benchmark on a generated project |

`render-frame` has no `--format`: it always writes PNG (or returns PNG bytes to
MCP). `--max-side` caps the longest side; `--scale` multiplies.

## Examples

```sh
# inspect
effectcraft-cli info --json
effectcraft-cli info project.ecproj --json
effectcraft-cli props Main '#1' --project project.ecproj
effectcraft-cli props Main Title --flat --time 1.5 --project project.ecproj
effectcraft-cli get Main Title transform/position --time 1.5 --project project.ecproj --json

# build in one process, save
effectcraft-cli run --empty \
  comp.new '{"name":"Main","width":1280,"height":720,"frameRate":30,"duration":3}' \
  layer.newText '{"name":"Title","text":"Hi","size":120}' \
  prop.addKey '{"layer":"Title","path":"transform/opacity","time":0,"value":0}' \
  prop.addKey '{"layer":"Title","path":"transform/opacity","time":1,"value":100}' \
  --save-as main.ecproj

# one-off edits need an explicit project and --save
effectcraft-cli set Main Title transform/opacity 40 main.ecproj --save
effectcraft-cli set Main Title transform/opacity 100 main.ecproj --expression 'time*40' --save
effectcraft-cli exec effect.apply --params '{"layer":"Title","effect":"Gaussian Blur"}' main.ecproj --save

# render
effectcraft-cli render-frame main.ecproj --comp Main --time 1.5 --max-side 960 --out frame.png
effectcraft-cli render main.ecproj --comp Main --out out.mp4 --format h264 --start 0 --end 3
effectcraft-cli render main.ecproj --comp Main --out frames/f_ --format png
effectcraft-cli render main.ecproj --comp Main --out out.mov --format prores --prores 422hq

# scripts
effectcraft-cli script job.jsx main.ecproj
effectcraft-cli script --eval 'writeLn(app.project.activeItem.name)' --empty
```

`--expression` still requires the positional **value**: it becomes the static
value underneath the expression (use the intended base value, and verify with
`get` that `expression` is set and `evaluated` differs). The MCP
`set_property {"expression": "..."}` path is simpler.

## Output and exit behaviour

- Human output is a readable summary; `--json` prints one JSON document
  (arrays for `commands`, objects for `get`/`info`).
- `render-frame` prints the output path (`--json`: `{path,width,height,…}`).
- **Command errors are printed to stderr and exit non-zero**; the CLI does not
  wrap them in JSON even with `--json` in every case (observed: `exec` errors
  print `effectcraft-cli exec: …`).
- `exec` on an empty project reports `… is not available right now: the project
  is empty` — open/create a comp first.
- Nothing is persisted unless `--save`/`--save-as` is passed (or `--autosave` in
  MCP). A successful `run` still exits without writing.

## Quirks verified on this build

- **Format beats extension.** `--format png --out x.mp4` writes
  `x_[#####].png`; `--format aiff --out a.aiff` writes `a.aif`. `--format` is
  authoritative, and sequences append `_[#####]`.
- **Relative `--out` resolves against the CWD**, while a relative `renderQueue`
  output resolves against the project's folder. Expect an extra directory level
  if you mix them (`out/out/…`).
- **Missing output directories are created** (no error).
- `--out` is required unless `--queue` or `--template` is used.
- `info` with no project argument opens the bundled demo, not an empty project.
  Use `--empty` for a blank session.
- `--format` accepts the output-module names (`h264`, `hevc`, `av1`, `prores`,
  `uncompressed`, `webm`, `png`, `jpeg`, `tiff`, `exr`, `gif`, `wav`, `aiff`);
  the JSON state also lists them capitalised (`H264`, `PngSequence`, …).
