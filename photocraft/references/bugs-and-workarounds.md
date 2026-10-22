# Bugs, silent successes and workarounds

Everything here was reproduced on PhotoCraft **0.11.1** (2026-10-22). Repros are
the shortest sequence that shows the behaviour; pixel checks used ImageMagick.

## Quick table

| # | Symptom | Severity | Workaround |
|---|---|---|---|
| 1 | `edit.fill` with a bad colour silently fills **black** | high | validate colours; use `#rrggbb`/`[r,g,b]` |
| 2 | unknown parameter keys are ignored → defaults apply, success | high | copy keys from `command_list`; verify pixels |
| 3 | layer-style `opacity` coerces/clamps out-of-range values | medium | pass numbers 0–100 |
| 4 | path-taking engine commands are disabled under MCP automation | high (design) | use `doc_*` tools, CLI, or the GUI |
| 5 | ORA export drops adjustment layers (warned) | medium | flatten a copy for the look |
| 6 | EXR round-trip is linear → dark PNG | medium | colour-manage, don't use as proof |
| 7 | history capped at 50 states, silently | medium | snapshots, save checkpoints |
| 8 | `ui.set {tool}` needs internal ids | low | use `rectMarquee`, `magicWand`, … |
| 9 | control `ui.screenshot` rejects `maxSide` | low | `{path, focus}`; MCP uses `max_side` |
| 10 | `ui.dialog.cancel` on a bad id says `missing dialog` | low | read `ui.inspect.dialogs` |
| 11 | layer export skips adjustment layers without a warning | low | compare `count` to layer count |
| 12 | forced codec under a mismatched extension | medium | keep format = extension |

## 1. `edit.fill` silently fills black for invalid colours

Repro (headless, 40×40 white document, `edit.fill {contents:"color", color:…}`):

| `color` value | Result | Pixel at (20,20) |
|---|---|---|
| `"#3366cc"` | `{"contents":"color"}` | `srgb(51,102,204)` ✅ |
| `"ff00ff"` (no `#`) | success | `srgb(255,0,255)` ✅ |
| `[0,255,0]` | success | `srgb(0,255,0)` ✅ |
| `"notacolor"` | success | **`srgb(0,0,0)`** ❌ |
| `"#f0f"` (3-digit) | success | **black** ❌ |
| `null` | success | **black** ❌ |
| `16711680` (JSON number) | success | **black** ❌ |
| `{"colour":"#ff00ff"}` (typo key) | success | **black** ❌ |

Expected: a parameter error, or the intended colour. Actual: black, reported as
success. `shape.create` does reject bad fills
(`unrecognised fill "notacolor"`), so the bug is specific to `edit.fill`.

Workaround: normalize to `#rrggbb` yourself and verify one pixel after the fill.
Prefer a Solid Color fill layer (`layer.newFillLayer.solidColor`) or a shape when
the fill is structural.

## 2. Unknown parameters are ignored

```text
command_run select.all {"bogus":1}                       → success
command_run image.adjustments.invert {"bogus":1}         → success, image inverted
command_run edit.fill {"colour":"#ff00ff"}               → success, fills foreground/black
```

No warning, no error. Combined with #1 this makes typos look like successful
edits. Workaround: take ids **and** keys from `command_list` output (the `params`
string lists every accepted key), then read back with `doc_inspect` or a pixel.

## 3. Layer-style opacity coerces instead of rejecting

`layer.layerStyle.blendingOptions {layer:5, opacity:X}`:

| X | Stored |
|---|---|
| `50` | 0.5 ✅ |
| `150` | 1.0 |
| `-5` | 0.0 |
| `true` | 1.0 |
| `"50"` | 1.0 (not 0.5) |

Out-of-range numbers are clamped; wrong types are accepted. Workaround: pass a
number 0–100, then assert `doc_inspect` shows the expected 0–1 value.

## 4. Path-taking commands are disabled under MCP automation

With `photocraft-cli mcp --automation-read-root … --automation-write-root …`,
these fail even though the roots are valid:

```text
file.saveACopy            -> automation command `file.saveACopy` uses ambient filesystem paths and is disabled; use capability-scoped document methods
file.export.layersToFiles -> (same)
file.export.quickExport   -> (same)
file.export.artboardsToPdf-> (same)
file.placeEmbedded        -> (same)
layer.smartObjects.replaceContents -> (same)
```

Anything whose parameters are a raw filesystem path is gated in the automation
build. Expected: the roots would authorize them; actual: a blanket refusal.

Workarounds:

- Saving/exporting: `doc_save`, `doc_export`, `doc_export_layers`,
  `doc_export_data_sets`, `doc_import_data_sets`, `doc_place`.
- The rest: `photocraft-cli run … --cmd <id>` (verified working for
  `file.export.layersToFiles`, `file.saveACopy`, `file.export.artboardsToPdf`,
  `layer.smartObjects.replaceContents`) or the GUI.
- `file.new` is fine (no path); use `doc_new`.

This is the single biggest docs-vs-binary gap: the command exists and is enabled
in the UI/CLI, but is unavailable to an MCP agent.

## 5. OpenRaster export drops adjustment layers

Repro: 5-layer doc (Background, patch, type, shape, Curves) → `doc_save {path:"x.ora"}`.

- Result warns:
  `adjustment layers cannot be saved to OpenRaster and were left out (the merged
  image keeps their look)` plus warnings for rasterised type/shape.
- The zip is valid (`mimetype` = `image/openraster`, `stack.xml`, `data/layer*.png`),
  `mergedimage.png` matches the source (mean 0.4217).
- Re-importing the layered ORA loses the adjustment: mean **0.4408** vs 0.4217.

Workaround: flatten a copy before ORA export when the look matters, or deliver
PSD/pcraft.

## 6. EXR is linear; round-tripping darkens the image

`sRGB doc → .exr → .png` gives mean **0.2257** vs **0.4217**. The EXR is written
half-float and holds linear values; no sRGB transfer is applied when converting
back. Not a corruption — an encoding mismatch. Use EXR only as a linear
intermediate, and don't validate a pipeline with this round trip.

## 7. History is capped at 50 states

120 edits → 51 history states and 50 successful undos; further undos do nothing.
No warning. Snapshots (`history.newSnapshot`) and saved `.pcraft` checkpoints are
the only durable waypoints. The cap lives in preferences
(`performance.historyStates`, read it with `prefs.get`).

## 8. `ui.set {tool}` takes internal ids

```text
ui.set {"tool":"Rectangular Marquee"}  -> error: unknown tool `Rectangular Marquee`
ui.set {"tool":"rectMarquee"}          -> ok, ui.inspect.tool == "RectMarquee"
```

Valid ids include `brush`, `pencil`, `eraser`, `rectMarquee`, `ellipseMarquee`,
`lasso`, `magicWand`, `crop`, `type`, `move`, `hand`, `zoom`, `paintBucket`,
`gradient`, `rectangle`, `ellipseShape`, `polygon`, `line`, `customShape`.
There is no discovery method for tool ids; use `ui.inspect.tool` / the docs.

## 9. Screenshot parameters differ between control and MCP

```text
control ui.screenshot {"path":…, "maxSide":800} -> unknown field `maxSide`
MCP     ui_screenshot {"max_side":800}          -> PNG content
control ui.screenshot {"path":…}                -> writes a full-window PNG
```

Two different schemas for the same concept. The control method writes a file
(under the app's write root) and returns `{path,width,height}`; the MCP tool
returns image content.

## 10. Misleading error for an unknown dialog id

`ui.dialog.cancel {"dialog":999}` → `missing dialog`, although the field was
provided. The handler means "no dialog with that id". Read
`ui.inspect.dialogs[*].id` first. Same shape for `ui.dialog.set/confirm`.

## 11. Layer export skips adjustment layers silently

A 5-layer document with one adjustment exports **4** files:

```text
doc_export_layers {dir:"…", format:"png"} → {count:4, files:[…]}
```

The result has no warning; `count` is the only clue. Adjustment layers have no
pixels, so this is defensible, but silent. Compare `count` with the number of
pixel/shape/type layers, or render the flattened document separately.

## 12. Codec forced under a mismatched extension

```sh
photocraft-cli convert in.png out.jpg --format png   # PNG bytes in out.jpg
```

`--format` selects the codec and does not touch the filename. `identify` reports
`PNG`, while the name says JPEG. The MCP equivalent
(`doc_export {path:"x.png", format:"jpg"}`) writes JPEG bytes into `x.png` and
warns only about lossy compression. Workaround: derive the extension from the
format (or omit `format` and let the extension decide), then verify with
`identify -format '%m'`.

## Traps that are not bugs

- **Return shapes vary.** `command_run` returns the payload directly
  (`{"layer":5}`); commands with no payload return `null`; `doc_inspect` returns
  the document, or `{"document":null,"session":…}` when nothing is open. Write
  `d = payload.get("document") or payload` before indexing.
- **`null` results are not failures.** `select.rect`, `select.deselect`,
  `layer.layerMask.revealSelection` and many UI-ish commands return no payload
  even when they change the document. Confirm with `doc_inspect`.
- **`photocraft-cli info` is lossy.** It lists layers and kinds but omits
  `hasMask` / `hasVectorMask`; `doc_inspect` is the full view.
- **Default fills differ.** `edit.fill` defaults to the **foreground** colour;
  `shape.create` defaults to **black**.
- **Smart Object kind has a space**: `"kind": "Smart Object"`, not
  `"SmartObject"`.
- **`edit.fill` needs a pixel layer.** Shape/Type/Smart Object layers are refused
  with a clear message; select a pixel layer or add one.
- **No `file.save`.** Saving is `doc_save` / `doc_export` / CLI `--out` /
  `serve doc.save`. `file.save` and `file.saveAs` are unknown commands.
- **Bridge needs a token and the flag is `--bridge`.** `--connect` (WordCraft's
  spelling) is `unknown flag`; without a token the MCP process exits with
  `bridge mode needs --control-token, --control-token-file,
  PHOTOCRAFT_CONTROL_TOKEN, or PHOTOCRAFT_CONTROL_TOKEN_FILE`.
- **No `methods` / `session.list` on the desktop control channel.** Those belong
  to `photocraft-cli serve`; the desktop answers `unknown method`.
- **Relative paths under MCP need roots.** Without `--automation-*-root`, read
  and write authority are both absent, and `PHOTOCRAFT_AUTOMATION_*` environment
  variables do not grant them.
