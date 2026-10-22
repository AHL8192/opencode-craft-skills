---
name: PhotoCraft
description: Use whenever working with PhotoCraft on this machine — the Rust image editor and Photoshop alternative — including opening, editing, retouching, masking or exporting images (.pcraft, .psd, .psb, .png, .jpg, .tif, .webp, .exr, .ora, .xcf, .kra, .pdn), driving the running desktop window, or using its MCP server, CLI (`photocraft-cli`) or control channel. Triggers on "PhotoCraft", "photocraft-cli", "photocraft mcp", "PhotoCraft MCP", "edit this image in PhotoCraft", "make a PSD", "open this photo", "add an adjustment layer", "mask the subject", "export a PNG from this PSD", "drive the PhotoCraft window", "take a PhotoCraft screenshot", and requests to automate image editing or PhotoCraft itself. Invoke with @photocraft.
---

# PhotoCraft — agent operation

PhotoCraft is a native Rust image editor (Photoshop-compatible menus, layers,
masks, adjustment layers, layer styles, type, vectors, real PSD I/O). Every
action is a command with an id: the UI, shortcuts, CLI, JSON control channel and
MCP server all drive the same engine.

## Machine snapshot (verified 2026-10-22)

| Thing | Value |
|---|---|
| Desktop app | `/usr/bin/photocraft` — `photocraft 0.11.1 (46e538b3a, 2026-10-20)` |
| CLI | `/usr/bin/photocraft-cli` — `0.11.1` (same build) |
| Install | Debian package `photocraft` `0.11.1-1` |
| App flags | `--control <port>`, `--control-token-file <path>`, `--automation-read-root`, `--automation-write-root`, `--new-instance`, `--safe-gpu`, `--version`, `-h` |
| Settings | `~/.config/photocraft/` (`preferences.json`, `logs/photocraft.log`); `PHOTOCRAFT_CONFIG_DIR` overrides |
| Control token | `~/.config/photocraft/control-7878.token` (mode 0600) |
| OpenCode servers | `photocraft` = headless; `photocraft-app` = bridge to `127.0.0.1:7878` |
| Commands | **918** in **36** namespaces (`photocraft-cli commands --json`) |
| MCP tools | **25**, resources `photocraft://document` + `photocraft://commands` |
| Formats | PSD/PSB, layered TIFF, `.pcraft`, ORA, PDN, XCF/KRA (read), SVG, PNG, JPEG, WebP, GIF, BMP, TGA, ICO, QOI, PNM, EXR, HDR, FITS, read-only HEIC/Affinity |

Version drift is expected. Re-verify with `scripts/probe.sh`; see
`references/maintenance.md`.

## Mental model

- A **document** holds a layer tree (`inspect.layers`, top to bottom), channels,
  history, selection, notes, variables. Documents are indexed **0-based** in the
  open session; the *active* document is what most commands act on.
- A **layer** has a `u32` **id** (not an index). Ids and names survive `.pcraft`
  save/reopen; use `layer.select` / the `layer` param with an id.
- A **command** is `{"id": "namespace.command", "params": {…}}`. `command_list`
  returns each id plus a human parameter string and `enabled` /
  `disabledReason`. One command = one history step.
- The 25 **MCP tools** are thin wrappers: `doc_*`, `command_run`,
  `command_batch`, `render_preview`, `jobs_*`, `session_list`, and `ui_*`
  (bridge only).
- **Verify by reading the document**, never by trusting the reply alone:
  `doc_inspect`, `render_preview` (PNG you can sample), or `ui_inspect` in
  bridge mode. A command can return success and change nothing (see Bugs).

## Two connection modes

| Mode | Start | Use for |
|---|---|---|
| Headless (MCP) | `photocraft-cli mcp --automation-read-root DIR --automation-write-root DIR` | Batch work, scripts, no window. **File access is denied unless you pass the root flags.** |
| App bridge (MCP) | `photocraft --control 7878 --control-token-file ~/.config/photocraft/control-7878.token` then `photocraft-cli mcp --bridge 127.0.0.1:7878 --control-token-file …` | Driving the real window: screenshots, dialogs, pointer, live UI state. File access follows the app's own `--automation-*-root` flags. |

The OpenCode entries already exist, so in this session use
`tools.photocraft.*` (headless) and `tools["photocraft-app"].*` (live window).

```sh
# headless, with file access
photocraft-cli mcp --automation-read-root ~/work --automation-write-root ~/work

# live window + bridge
photocraft --control 7878 --control-token-file ~/.config/photocraft/control-7878.token &
photocraft-cli mcp --bridge 127.0.0.1:7878 --control-token-file ~/.config/photocraft/control-7878.token
```

`--bridge` (not `--connect`), and the bridge **requires** a token
(`--control-token`, `--control-token-file`, `PHOTOCRAFT_CONTROL_TOKEN` or
`PHOTOCRAFT_CONTROL_TOKEN_FILE`).

## Minimal working example

```sh
# one-shot CLI: new document, edit, save
photocraft-cli run --new '{"width":1200,"height":800,"background":"#f5f0e6"}' \
  --cmd edit.fill --params '{"color":"#204060"}' \
  --cmd type.create --params '{"x":80,"y":400,"text":"Hello","size":64,"color":"#ffffff"}' \
  --out card.pcraft
```

Note: MCP calls execute concurrently — wait for `doc_new` to reply before saving.
MCP equivalent (headless): `doc_new` → `command_run {id:"edit.fill"}` →
`command_run {id:"type.create"}` → `doc_inspect` → `doc_save {path:"card.pcraft"}`
→ `doc_close` → `doc_open` to prove the round trip.

## Safest default workflow

1. **Probe.** `command_list({filter:"…"})` (or `photocraft-cli commands --filter`)
   to get the exact id and its parameter string. `session_list` for open docs.
2. **Copy first.** Never open the user's original for editing; copy it into a
   work directory and open the copy.
3. **Start.** `doc_open` / `doc_new`; capture the returned `index` and `warnings`.
4. **Select deliberately.** Commands act on the active document and the targeted
   layer/selection. Use `layer.select`, `select.rect/all/…`, `channel.target`.
5. **Edit** with `command_run` (one step) or `command_batch` (ordered, stops on
   error by default). Prefer an adjustment layer over a destructive filter.
6. **Verify** with `doc_inspect` (layer tree, history, selection, dirty) and
   `render_preview` → write the PNG and sample pixels (`identify`, `convert`).
7. **Save** `.pcraft` (lossless, keeps layers, incremental) then export by
   extension. Warnings are reports, not errors: read them.
8. **Reopen** the saved file and compare before declaring success.

## Units, ids and coordinates

- Document pixels; origin top-left, **y grows downward**.
- Selection: `{"x","y","width","height"}`; `shape.create` rect `[x,y,w,h]`;
  `select.rect` accepts negative x/y and clips to the canvas.
- Type: `x`,`y` is the **baseline anchor** of point text; a `box:[x,y,w,h]`
  makes paragraph text.
- `layer.new.layer` takes `opacity` **0–1**; blend/style params
  (`blendingOptions`, `layerStyle.*`) take **0–100**. `doc_inspect` reports 0–1.
- Layer ids are u32 and stable across `.pcraft`; document indices are session
  order and shift when documents close.
- `doc_inspect` returns the document object, or
  `{"document": null, "session": {…}}` when nothing is open.

## Key commands (full list: references/commands.md)

| Task | Command |
|---|---|
| New / open / save | `doc_new`, `doc_open`, `doc_save` (MCP); `file.openAs` only via CLI/GUI — there is **no** `file.save`/`file.saveAs` command |
| Layers | `layer.new.layer`, `layer.duplicate`, `layer.delete`, `layer.moveTo`, `layer.mergeLayers`, `layer.flattenImage` |
| Fill / paint | `edit.fill`, `paint.stroke`, `paint.gradient`, `select.rect` |
| Adjustments | `layer.newAdjustmentLayer.curves` (also `levels`, `vibrance`, `hueSaturation`, …) or `image.adjustments.*` (destructive) |
| Masks | `layer.layerMask.revealSelection`, `layer.vectorMask.currentPath`, `select.subject`, `select.object` |
| Type / shapes | `type.create`, `type.setStyle`, `shape.create`, `shape.edit` |
| Effects | `layer.layerStyle.dropShadow`, `…stroke`, `…replace`, `style.presets.apply` |
| Export | `doc_export`, `doc_export_layers`; `file.export.*` only via CLI/GUI (blocked under MCP automation) |
| State | `edit.undo`, `edit.redo`, `history.selectState`, `prefs.get` |

## Known bugs and workarounds (details + repros: references/bugs-and-workarounds.md)

- `edit.fill` accepts an invalid colour (`"notacolor"`, `null`, a number,
  `"#f0f"`) and **silently fills black**. Only `"#rrggbb"`/`"rrggbb"`/`[r,g,b]`
  are honoured. Validate the colour yourself; prefer `shape.create`/fill layers,
  which reject bad colours.
- **Unknown parameter names are ignored**, so a typo (`"colour"`) runs the
  command with defaults and reports success. Copy ids and keys from
  `command_list`, then verify the result.
- Layer-style `opacity` clamps instead of erroring: `150`→1.0, `true`→1.0,
  `"50"`→1.0, `-5`→0.0. Pass numbers 0–100.
- History keeps **50 states** by default; older steps are dropped silently.
- ORA export leaves adjustment layers out (it warns); type/shape layers become
  pixels. Reimporting loses the adjustment look even though `mergedimage.png`
  has it.
- EXR is linear: exporting and converting back to PNG gives a much darker image
  unless you apply the sRGB transfer.
- `doc_export` with `format` ≠ the path extension writes that codec **under the
  wrong name** (JPEG bytes in a `.png`). Keep them consistent.
- Path-taking commands (`file.saveACopy`, `file.export.layersToFiles`,
  `file.placeEmbedded`, `layer.smartObjects.replaceContents`) are **refused
  under MCP automation** ("uses ambient filesystem paths"). Use `doc_save`,
  `doc_export`, `doc_place` or the CLI.
- Bridge `ui.set {tool}` takes internal ids (`brush`, `rectMarquee`,
  `magicWand`, `paintBucket`), not display names; `"Rectangular Marquee"` is
  rejected.

## Safety rules

- Work on copies under your own test directory; never save over an original.
- `flattenImage`, `rasterize.*`, `image.mode.*`, `image.trim`, `image.imageSize`
  and history-state deletion change structure; treat them as destructive and
  keep a `.pcraft` copy first.
- `batch` refuses `--in` == `--out` unless `--in-place`; keep it that way.
- Do not kill a PhotoCraft you did not start; give your own instance a unique
  `--control` port and `PHOTOCRAFT_CONFIG_DIR`.
- Automation paths must be **inside** the granted roots; `..` traversal and
  absolute paths outside the root are rejected by design.
- Screenshots and previews may contain the user's image — keep them in the work
  directory and do not paste them into reports.

## Files in this skill

- `references/commands.md` — namespaces and the command ids worth knowing
- `references/recipes.md` — verified end-to-end recipes
- `references/mcp-and-control.md` — MCP tools, bridge, control methods, dialogs
- `references/cli.md` — `photocraft-cli` subcommands and patterns
- `references/formats-and-roundtrip.md` — measured export matrix and caveats
- `references/bugs-and-workarounds.md` — repros for every silent failure above
- `references/maintenance.md` — version/catalog/doc refresh procedure
- `scripts/probe.sh`, `scripts/dump-commands.sh`, `scripts/smoke-test.sh`

## What was not tested

CMYK/Lab editing beyond document creation; PSD corpus fidelity beyond a
synthetic 5-layer file; HEIC/Affinity/PDF/video/print; the web build; 32-bit
compositing accuracy; native Wayland GUI (only XWayland was driven); visual
inspection of screenshots (no vision provider — verified by pixel statistics
instead); Photoshop pixel parity.
