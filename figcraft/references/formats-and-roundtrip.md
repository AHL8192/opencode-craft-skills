# Formats, import/export, round trips — verified matrix

Everything below was produced by 0.8.0 on 2026-10-22 and then checked with tools outside FigCraft
(`file`, `unzip`, `identify`, `pdfinfo`, `pdftotext`, Python's XML parser). Byte counts and pixel
sizes are from that run.

## Formats

| Format | Direction | Notes |
|---|---|---|
| `.figcraft` | open / save / import | **native**, a ZIP: `document.json`, `thumbnail.png`, `images/<sha256>` |
| `.json` | open / import / convert out | FigCraft document JSON or REST API file JSON; valid files open by path |
| `.fig` | export / open / import (best effort) | ZIP of `canvas.fig` + `fig-kiwi`; warns what it left out |
| `.svg` | import / export (also `convert`) | import → editable frame with shapes/text/gradients/masks/effects; export outlines text by default |
| PNG/JPG/WebP/GIF/BMP/TIF | import / `placeImage` / open | import → image layer (or a one-layer document with `open_file`) |
| PNG/JPG/WebP/SVG/PDF | export | PDF is vector with real text; print options (bleed, marks, CMYK) |
| JSON (variables) | `variable.export` / `variable.import` | local-variables JSON, or CSS custom properties |

## Native `.figcraft` internals

```text
document.json          # format, version, imageIndex, name, pages, nodes, next_id, styles,
                       # variables, current_page, document_colors, comments
thumbnail.png          # 8–10 KB preview
images/<sha256>        # one file per raster image (hash = image id used by image fills)
```

Verified with `unzip -l` on a 4-node file (2 entries), a 185-layer dashboard (2 entries) and a
one-image document (3 entries: `document.json`, `images/82c1…`, `thumbnail.png`). Saves are fast
(40 ms for 2,000 layers, 96 KB) and the archive is ordinary deflate ZIP.

## Round trips (all passed)

| Test | Result |
|---|---|
| native save → reopen | frame id and name identical (`2`, "RT"), 1 style, 1 variable collection, `dirty:false` |
| 10× save + reopen | ~36 ms total, ids stable |
| `.figcraft` → `.json` (`convert`) | 291,577 B; 1 page, 186 nodes, 19 styles; `convert` back → 43,987 B `.figcraft`; render 1800×844 |
| `.json` → `open_file` | opened as "Dashboard", 185 layers, `opened:{index, summary, repairs:[]}` |
| `.json` → `file.import` | page(s) appended to the current document (new page id 372, 185 layers) |
| export `.fig` → `open_file` | frame, text, 1 style and 1 variable survived; `currentPage` numeric page id |
| SVG import | editable frame "shapes", 4 nodes (frame, rect, text), no warnings |
| PNG import | one image layer, 640×400, `image` hash; `placeImage` then `fill.set` works |
| malformed `.figcraft` (empty / `PK` garbage) | rejected: `not a valid FigCraft file: invalid Zip archive: Could not find EOCD` |
| malformed `.json` | rejected with the **same zip error** (misleading message; a valid JSON opens fine) |
| malformed SVG (`<svg><rect`) | rejected: `SVG import failed: SVG data parsing failed cause the root node was opened but never closed` |
| missing import path | `…: No such file or directory (os error 2)` |
| CLI `info` on an empty file | exit 1 |

Ids are not regenerated on open, so ids in a saved file remain valid for later scripts. Images are
content-addressed, so the same image placed twice is stored once.

## Export matrix

| Call | Output | Validation |
|---|---|---|
| `export {ids:[frame], format:"png", scale:2}` | 600×400 PNG, 12,954 B | `identify` |
| `export {ids:[frame], format:"png", size:"512w"}` | 512×342 PNG | `identify` |
| `export {ids:[frame], format:"jpg"}` | 300×200 JPEG, 4,417 B | `identify` |
| `export {ids:[frame], format:"webp"}` | 300×200 WebP, 1,016 B | `identify` |
| `export {ids:[frame], format:"svg"}` (default) | 6,338 B, **0 `<text>`** (text outlined to paths) | XML parses |
| `export {…, format:"svg", svgOutlineText:false}` | 488 B, **1 `<text>`** with `tspan` | XML parses |
| `export {ids:[frame], format:"pdf"}` | 1-page PDF 133×36 pt for the selected text | `pdfinfo`, `pdftotext` |
| `export {format:"pdf"}` after `select.none` | 4 pages, 392×846 pt, real text (`RIDGELINE TRAILS…`) | `pdfinfo`, `pdftotext` |
| CLI `export file -o dir` | one PNG per top-level frame (4 files: Explore, Profile, Trail, Welcome) | `ls`, `identify` |
| `export {…, format:"pdf", bleed:"3mm", cropMarks:true, bleedMarks:true, cmyk:true}` | MediaBox 365×265, BleedBox 24 pt inset, TrimBox 32.5 pt inset | `pdfinfo -box` |
| `file.exportLayers` with a `2x` setting | `One@2x.png` 12,954 B | `identify` |
| `export {format:"fig"}` | ZIP, reopens | `file`, `open_file` |
| `export {…, scale:1000}` | succeeds; scale is capped at **64** (no warning) | pixel dimensions |

Defaults and gotchas:

- **No `ids` → the selection, then the page.** A leftover selection silently exports one layer.
  `select.none` first when you mean the page. `nothing to export` means nothing matched.
- **Scale cap 64**, no error, no note in the result.
- **The extension is not checked.** `format:"png"` with `path:"x.jpg"` writes PNG bytes to `x.jpg`;
  `file.export {format:"pdf", path:"x.png"}` writes a PDF named `x.png`. Read the result's
  `format` field or run `file(1)`.
- **PDF:** with `ids` you get one page; `file.exportFramesPdf` gives one page per top-level frame in
  reading order (verified 4 pages from the mobile-app template). The CLI's directory/PDF mode does
  the same.
- **SVG** outlines text unless `svgOutlineText:false`. `contentsOnly`, `includeBoundingBox`,
  `svgIdAttribute`, `svgSimplifyStroke` are also accepted by the tool.
- **`scale` vs `size`:** `size:"512w"`, `"512h"`, `"2x"` or `{by:"scale"|"width"|"height",value}`
  wins over `scale`.
- `export.add` sets per-layer export settings used by `file.exportLayers`, which names files
  `<layer><suffix>.<format>` (default suffix `@2x` for scaled settings, ` 2` for repeats, `/` in a
  layer name becomes a folder).
- `.fig` export is explicitly experimental; expect warnings and check what reopened.

## Import and edit behaviour

- `file.import {path|data+name, x?, y?, center?}` appends. SVG becomes one editable frame; text
  stays text, gradients/masks/effects are translated, and `warnings` lists what was dropped.
- `file.placeImage` returns `{id, image:"<hash>", width, height, imageProfile}`. Use that hash for
  an image paint (`fill.set`/`fill.add` with `{"type":"image","image":"<hash>","scaleMode":"fill"}`).
- `file.import` of `.figcraft`/`.json`/`.fig` appends pages **to the open document**, with
  `summary {name, pages, layers, images}` and (for REST/.fig) `warnings`.
- `open_file` on an image opens it as a document with one image layer.
- `open_file` on a file already open returns `opened:{index}` with no summary; use the index with
  the document tabs.

## Validators to run after export

```sh
file out.bin                      # true container/encoding
unzip -l out.figcraft             # native archive layout
identify out.png out.jpg out.webp # dimensions, depth, colorspace
python3 -c 'import xml.etree.ElementTree as E; E.parse("out.svg")'   # XML well-formedness
pdfinfo out.pdf                   # pages, page size, Creator (FigCraft)
pdfinfo -box out.pdf              # MediaBox / BleedBox / TrimBox
pdftotext out.pdf - | head        # real text (not outlined)
```

## Not validated

- CMYK colour accuracy/proofing, Display P3 conversion, overprint and spot colours.
- Fonts missing on the render machine (`missingFonts` is reported by `info`; `--no-system-fonts`
  renders with built-ins only, but glyph coverage was not compared).
- Real Figma `.fig` files (only FigCraft's own export), huge `.fig` files, and files above ~2,000
  layers.
- Interactive prototype playback, presentation mode, printing, and PDF/X conformance.
