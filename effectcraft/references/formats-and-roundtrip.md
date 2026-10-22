# Files, formats and round-trips — 0.13.0

Everything here was produced on this machine and checked with independent tools
(`file`, ImageMagick `identify`, PIL, a hand-written MP4 box parser). No ffprobe or
ffmpeg is installed.

## Render formats

| Format | Extension written | Verified result |
|---|---|---|
| `h264` | `.mp4` | ISO Media MP4, 320×180, 15 frames, H.264 |
| `hevc` / `av1` | `.mp4` | not exercised in this run |
| `prores` | `.mov` | QuickTime MOV, 320×180, 15 frames (profile option accepted, not independently verified) |
| `webm` | `.webm` | WebM container, 320×180 |
| `gif` | `.gif` | GIF89a, 15 frames, 320×180, palette |
| `png` | `_#####.png` | PNG RGB sequence (6 frames in the test) |
| `jpeg` | `_#####.jpg` | JPEG RGB sequence |
| `tiff` | `_#####.tif` | TIFF sequence |
| `exr` | `_#####.exr` | OpenEXR sequence, 16-bit half channels |
| `wav` | `.wav` | RIFF/WAVE PCM 16-bit stereo 48 kHz |
| `aiff` | **`.aif`** | AIFF (the requested `.aiff` extension is rewritten) |
| `uncompressed` | `.mov`/`.avi` | not exercised in this run |

Notes:

- `--format` / the output module **wins over the output extension**. Asking for
  `png` with `--out x.mp4` writes `x_[#####].png`; `aiff` with `a.aiff` writes
  `a.aif`. Sequences append `_[#####]` (five digits) to the stem.
- `render_frame` and `comp.saveFrameAs` always write PNG regardless of extension.
- **Alpha:** use `render_frame {"transparent":true}` or CLI `--transparent`.
  Those write RGBA (verified: an RGBA PNG with real alpha extrema). `--channels
  rgba` alone produced an RGB PNG in the test — do not rely on it for alpha.
  `renderQueue` output modules expose `channels: rgb|rgba` plus `alpha_mode`.
- Multi-layer/multi-channel exports:
  - `comp.saveFrameAsExr` → one EXR containing the composite R,G,B,A plus
    `<layer>.R/G/B/A` per layer, linear and premultiplied.
  - `comp.saveFrameAsPsd` → layered PSD: one layer per visible comp layer with
    blend mode/opacity plus the merged frame (ImageMagick saw 3 layers for a
    2-layer comp: layers + merged).
  - `file.saveCopyAsXml` → `.ecprojx`, a **project copy**, not an interchange
    format for other apps.
- EXR depth: `identify` reports 16-bit channels for both sequence and
  `saveFrameAsExr` output, even when the output module asks for 16 bpc. No 32-bit
  float switch was found in 0.13.0.
- Missing output directories: the CLI `render` creates them; MCP `render_frame`
  and `comp.saveFrameAs*` **fail** with `No such file or directory`. Create the
  folder first.
- Path bases: CLI `render --out` resolves relative to the **CWD**; a relative
  `renderQueue` output is resolved against the **project file's folder** when the
  item is added; `render_frame` relative paths use the MCP server's CWD. Use
  absolute paths everywhere to avoid surprises (a relative queue path commonly
  produces `out/out/…`).

## Project format (`.ecproj`)

Plain JSON. Top-level keys observed in 0.13.0:

```json
{"activeComp": 1, "items": [...], "next_id": 305, "openComps": [1],
 "savedBy": "0.13.0", "schema": 2, "settings": {...}}
```

- **No `version` key** — use `schema` (2) and `savedBy`.
- `save_project` / `app.project.save` write this JSON under **any** extension:
  `save_project {"path":"x.txt"}` writes ecproj JSON with no warning. Only the
  content matters; do not infer the format from the suffix.
- Save/reopen identity is stable: layer ids and uids, comp ids, item ids,
  keyframe times/values, expressions and layer properties survive a round-trip
  in a fresh process (verified: layers 41 and 2, comp 1, two opacity keys).
- Corrupt files fail loudly and safely:
  - `not json` → `expected ident at line 1 column 2`
  - `{}`-shaped partial JSON → `invalid type: sequence, expected a map`
  - truncated → `EOF while parsing a value`
  - empty → `EOF while parsing a value at line 1 column 0`
  These do not destroy the open project.
- Opening a project does not create missing folders or relink media.

## Lottie

Export (`file.exportLottie {comp, path: ".json"|".lottie", includeExpressions?,
textAsShapes?}`) returns `{bytes, path, warnings}`. Warnings are specific and
worth reading:

- `Title ▸ Transform ▸ Rotation: expression not exported (enable
  includeExpressions…)` — expressions are dropped by default.
- `Title: layer styles are not exported`.
- `BG ▸ Mask 1: mask feather is exported as f (not every Lottie player renders
  it)`.

Import (`file.importLottie {path}`) returns `{comp, items, warnings}`. Verified:

- A foreign hand-written Lottie (24 fps, 2 s, one rectangular shape layer)
  imported as a comp named `Foreign`, fps 24, duration 2.0, one Shape layer.
- Exporting an EffectCraft comp and importing it back recreated the comp with
  text position keys, solids, shape layers, fps and duration intact. It created
  **new** item ids (comp 303, items 164–166, 274, 303) — import never overwrites
  the source.
- Unsupported features degrade with warnings rather than failing.

## Media import

```text
file.import {paths, sequence?, alphabetical?, frameRate?, importAs?,
             layer?, page?, drag?, addToComp?, time?, index?, position?, background?}
```

Verified behaviour:

- `plate_0000.png` (a numbered still) imported the whole run as **one**
  `Image Sequence` item named `clip_[0000-0002].png`; a warning listed missing
  frames in the run.
- `still.png` with `sequence:false` imported as a single `Image`.
- `project.select {items:[1]}` then `file.newCompFromSelection {single:true}`
  created a comp whose duration is `frames/fps` (3 frames → 0.1 s at 30 fps) and
  returned `{comps:[id]}`. Without a selection it errors with “select an item in
  the Project panel first”.
- A missing path appears in the import result's `errors`/`warnings`; the call
  itself still returns a result.
- Importing a `.json` via `file.import` is a silent no-op (no item, no error) —
  use `file.importLottie` for Lottie.
- `footage.check {wait:true}` is the authoritative missing-media check
  (`{checked, missing, probed}`). With the whole media folder moved away it
  reported `{checked:1, missing:1}`. `file.findMissing` returned `{items:[]}` in
  the same state — a bug (see `bugs-and-workarounds.md`).

## Audio

Exporting `wav`/`aiff` from a comp with no audio still produced valid silent
files (RIFF PCM 16-bit stereo 48 kHz / AIFF). Audio-level and waveform features
were not exercised.

## Validation snippets

```sh
file out.mp4 out.mov out.webm out.gif
identify out.gif | head -2            # frame 0,1,… and canvas
python3 - <<'PY'
from PIL import Image
im=Image.open("out.png"); print(im.format, im.size, im.mode, im.getextrema())
PY
python3 - <<'PY'
# minimal MP4 box walk: ftyp/moov presence and size sanity
import struct
b=open("out.mp4","rb").read()
i=0
while i < len(b):
    size=struct.unpack(">I", b[i:i+4])[0]; typ=b[i+4:i+8].decode("latin1")
    print(typ, size); 
    if size < 8: break
    i += size
PY
```
