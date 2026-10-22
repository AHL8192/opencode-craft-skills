---
name: VectorCraft
description: Use whenever working with VectorCraft on this machine — the Rust vector illustration app and Illustrator alternative — including creating or editing artwork (shapes, paths, type, gradients, effects, Pathfinder, artboards, layers), opening or exporting .vectorcraft/.svg/.pdf/.ai/.eps/.png/.psd/.dxf, driving the running desktop window, or using its MCP server, `vectorcraft-cli`, or JSON control channel. Triggers on "VectorCraft", "vectorcraft-cli", "vectorcraft mcp", "VectorCraft MCP", "draw a poster/logo/icon in VectorCraft", "export this as SVG/PDF", "take a VectorCraft screenshot", "drive the VectorCraft window", and requests to automate vector artwork or VectorCraft itself. Invoke with @vectorcraft.
---

# VectorCraft — agent operation

VectorCraft is a native Rust vector editor. The menu, tools, dialogs, CLI,
control channel and MCP server all drive **one command engine**: every action is
a command id plus JSON params. Learn the ids and you can build anything the UI can.

## Machine snapshot (verified 2026-10-22)

| Thing | Value |
|---|---|
| App | `/usr/bin/vectorcraft` — `vectorcraft 0.14.0` |
| CLI | `/usr/bin/vectorcraft-cli` — `0.14.0` |
| Package | Debian `vectorcraft 0.14.0-1` (both binaries) |
| MCP | `vectorcraft-cli mcp` (headless) · `mcp --connect 127.0.0.1:PORT` (live app) |
| Control channel | `vectorcraft --control PORT` (we use **7983**; 7979 = GridCraft, 7981 = WordCraft) |
| MCP surface | **32 tools**, resources `vectorcraft://document`, `/document/json`, `/commands`, 5 prompts |
| Commands | **792** in `vectorcraft-cli commands`; **1090** via `engine.commands` with a doc open; **902** menu items / 336 unique ids |
| Config | `~/.config/vectorcraft/` (`ui.json`, `logs/`); isolate with `VECTORCRAFT_CONFIG_DIR` |
| Formats | read: `vectorcraft drawcraft svg svgz pdf ai ait png jpg jpeg gif webp tif tiff bmp tga vda icb vst psd psb vctemplate dxf emf wmf eps epsf ps af afdesign afpub` |
| | write: `vectorcraft svg svgz pdf ai png jpg gif webp tif bmp vctemplate txt dxf eps emf wmf tga psd` (+`png8`) |

**Version drift is expected.** Re-verify with `scripts/probe.sh` before trusting counts.

## Mental model

- **Document** = artboards + a layer tree. New document is 612×792 pt, RGB,
  one artboard. **Coordinates are points, y down, origin at artboard 1's top-left.**
  Artboard 2 sits at x = width + 20 pt by default.
- **Ids**: layer 1, objects from 2 upward. Ids are stable across native
  save/reload (verified). Deleting does not reuse ids.
- **Selection**: a new object becomes the selection; most commands act on the
  selection or on explicit `ids`.
- **Two API layers, both strict** (the most important thing on this page):
  - **MCP convenience tools** (`draw_shape`, `set_paint`, `add_text`, `transform`,
    `apply_effect`, `export`, …) validate JSON schemas and return **tool errors**
    on bad shapes/enums/types.
  - **Engine commands** (`command_run`, `run_command`, `engine.execute`, CLI
    `run --cmd`) validate too: unknown ids, unknown/misspelled params, wrong
    types, bad colours and unknown effects all **error** (often with a
    did-you-mean). The silent cases are value-level, listed under gotchas 3–4.
    Always read back with `doc_inspect` anyway.
- **Native file** `.vectorcraft` is JSON (`version: 4`), often gzipped, and
  embeds a PDF only if asked (`pdfCompatible`).
- `command_batch` = up to **256** steps of `{id, params}`; `atomic:true` makes
  it one undo step. It is *not* the engine's `command.batch` (which takes
  `{command, params}`).

## Two connection modes

| Mode | How | Use for |
|---|---|---|
| Headless | `vectorcraft-cli mcp` → OpenCode `vectorcraft` | Batch work, conversion, scripts, confined roots (`--automation-read-root/-write-root` imply headless) |
| App bridge | `vectorcraft --control 7983` + `vectorcraft-cli mcp --connect 127.0.0.1:7983` → `vectorcraft-app` | Watching edits live, screenshots, mouse/keyboard, dialogs, UI inspection |

```sh
# isolated GUI instance (does not touch the user's profile or other craft apps)
VECTORCRAFT_CONFIG_DIR=/tmp/vc-profile vectorcraft --control 7983 &
# MCP against it
vectorcraft-cli mcp --connect 127.0.0.1:7983
# no window at all
vectorcraft-cli mcp --headless
```

The control port is **unauthenticated and loopback-only**. Run it only while
you need it; never expose the port.

## Minimal working example (headless MCP)

```
command_run {id:"file.new", params:{width:600, height:400, title:"demo"}}
draw_shape  {shape:"rectangle", x:60, y:60, width:220, height:120, radius:10,
             fill:"#e8573f", stroke:"none", name:"plate"}
draw_shape  {shape:"ellipse", x:320, y:100, width:120, height:120, fill:"#1f7ae0",
             stroke:"none"}
add_text    {text:"Hello", x:60, y:240, size:36, color:"#222222"}
export      {path:"/tmp/demo.png"}          # also: svg, pdf, ai, psd, dxf, eps …
doc_inspect {kind:"Rectangle"}              # read back, never assume
```

CLI equivalent — **only engine command ids work here**:

```sh
vectorcraft-cli run \
  --cmd file.new --params '{"width":600,"height":400}' \
  --cmd shape.rectangle --params '{"x":60,"y":60,"width":220,"height":120}' \
  --cmd paint.setFill --params '{"color":"#e8573f"}' \
  --export /tmp/demo.png
vectorcraft-cli info /tmp/demo.vectorcraft
```

## Safest default workflow

1. `file.new` (or `open_file`/`app.open` on a **copy**) and record the doc title.
2. Build with **convenience tools** where they exist — they validate.
3. After every mutation, `doc_inspect` (or `document.inspect`) and compare
   `selection`, `nodes[].bounds`, `nodes[].fill`, `history`.
4. Save with an explicit path, then `open_file` the result and inspect again.
5. Export with an explicit `path` **and** matching extension (see gotcha 5).
6. Validate independently: `identify`, `pdfinfo`, `gs`, `pdftotext`,
   `rsvg-convert`, `vectorcraft-cli info` (reports import warnings).
7. On GUI, settle ~0.5 s after input before reading state (see gotcha 11).

Full parameter docs: `command_list {query:"…"}` / `vectorcraft-cli commands`.
Ids, recipes and gotchas are in the references below.

## Reference map

| File | Contents |
|---|---|
| `references/commands.md` | Command namespaces and the ids you actually use, with params |
| `references/recipes.md` | Task recipes: poster, icon set, batch build, artboards, type, export |
| `references/mcp-and-control.md` | Handshake, all 32 tools, resources, control methods, GUI driving, coordinates |
| `references/cli.md` | `mcp`, `run`, `convert`, `info`, `bench`, `perf`, `commands`; flags and failures |
| `references/formats-and-roundtrip.md` | Verified export/import matrix, fidelity numbers, validator commands |
| `references/bugs-and-workarounds.md` | Version-specific bugs with minimal reproductions |
| `references/maintenance.md` | Catalog refresh and version-diff procedure |
| `scripts/probe.sh` | Versions, package, ports, process, MCP handshake, catalog counts |
| `scripts/dump-commands.sh` | Snapshot command ids/params and diff two versions |
| `scripts/smoke-test.sh` | End-to-end create → save → export → re-read proof |

## Known bugs and workarounds (0.14.0)

1. **CLI `run --cmd` rejects MCP tool names** (`draw_shape`, `doc_inspect`) with
   `unknown command`, then **stops the run and skips every `--export`**. It takes
   engine ids (`shape.rectangle`, `paint.setFill`, `document.inspect`,
   `document.save`) plus the host commands `file.open`, `file.save`,
   `file.export`.
2. **The engine is stricter than you may expect.** Unknown ids, typo'd params,
   wrong types, bad colours and unknown effects all return explicit errors
   (`unknown command …`, `unknown parameter 'widht'; did you mean 'width'?`,
   `bad color`, `unknown effect`). Do not build “best effort” flows that assume
   silent no-ops — but do still read back.
3. **These cases *are* silent** (reports success, no warning):
   `set_paint {ids:[9999]}` → `{"applied":…}` but only the new-art default
   changes; `strokeWidth:-5` → reports applied, stores `0`; `transform
   {scale:-50}` → half size, sign ignored; `add_text {text:"",size:0}` → empty
   zero-width Type object; `shape.rectangle {width:0}` → zero-width object;
   unknown `font` → substituted (export warns, the call does not).
4. **`export {format:"png", path:"x.svg"}`** writes PNG bytes into `x.svg` with
   no warning. `scale:0` and `scale:-2` are ignored and export at 1× (no error).
   Keep the extension and `format` consistent; assert size with `identify`.
5. **`file.export` is invokable but undiscoverable**: in
   `vectorcraft-cli commands`, absent from `ui.menu.list` and
   `engine.commands`, yet `command_run {id:"file.export"}` works like
   `document.export`. Prefer `document.export`/`file.exportAs`.
6. **SVG import drops `<filter>` silently** (no warning in the open result).
   Missing linked images *do* warn.
7. **`command_batch` does not accept `{command, params}` steps** — it fails the
   step with `unknown step argument (expected id, params)`. Cap is 256 steps.
8. **`doc_inspect.objects` counts layer rows**, not objects (empty doc = 1).
   Use `total` or `nodes`.
9. **GUI state lags input by a frame or more** (4–30 fps). A `document.inspect`
   right after `ui.click` shows the previous state. Sleep ~0.5 s, then read.
   `ui.key` needs real key names; pass modifiers as `shift`/`cmd`/`alt` flags.
10. **Native save/export dialogs are unusable over the control channel on
    Linux**: `ui.dialog.confirm` on `exportAs` returns `{"error":"cancelled"}`
    because the OS file chooser is external. Always pass explicit paths to
    `export`/`save_file`/`document.export`.
11. **`open_file` result has no `path`** (only `title`, `format`, warnings).
12. **PDF/`.ai` with `artboard:n`** warns that editing data was left out; use
    `range:"1-2"` when round-tripping multi-artboard files.
13. **Extreme coordinates are rejected**: `x:1e9` errors with `result would
    exceed the canvas (coordinates out of range)`, while `x:100000` is accepted.

## Safety rules

- Work on copies. Never export over, or `document.save` into, a user's original.
- `export` without `path` and `document.save` without `path` return base64 and
  leave the document **dirty**; always pass a path for real work.
- One GUI instance per profile. Use `VECTORCRAFT_CONFIG_DIR` and a free port;
  kill only the PID you started. Never `pkill vectorcraft`.
- Do not enable `--control` on a shared port, and close it (quit the app) after
  GUI tests.
- Confirm before destructive commands (`layer.delete`, `layer.merge`,
  `file.close {force:true}`); undo exists but is per-command.

## What was not tested

- Affinity (`.af`, `.afdesign`, `.afpub`), EPS-from-preview, `.ait` templates and
  PostScript input: no sample files were available; only self-produced files were
  round-tripped.
- 3D Revolve, gradient mesh, perspective grids, symbols, brushes, envelope
  distort, plug-ins, Variables, printing/Package: catalogued but not exercised.
- The web/WASM build, Windows/macOS behaviour, and non-Latin text shaping.
- Documents beyond 2,000 objects (2,000 were verified end to end; no 50k-path
  stress run).
- Native OS file dialogs (blocked by design, see gotcha 12).
