# Formats, export and round-trip fidelity

Measured 2026-10-22 on PhotoCraft 0.11.1. Source document: 320×240, 8-bit RGB,
5 layers (Background, colour patch, point type, ellipse shape, Curves adjustment).

## Export matrix

| Format | Size | Keeps layers | Re-import vs source (AE) | Notes |
|---|---:|---|---:|---|
| `.pcraft` | 35 187 B | yes (5) | 0 | native, lossless; layer ids preserved |
| `.psd` | 36 246 B | yes (5) | 0 | pixel-identical re-render |
| `.tif` flat | 230 626 B | no | 0 | |
| `.tif --tiff-layers` | 250 630 B | yes (5) | 0 | Photoshop layer data in the TIFF |
| `.png` | 4 846 B | no | 0 | 8/16-bit samples kept |
| `.jpg --quality 90` | 6 575 B | no | 33 630 | lossy; quality stored as 90 |
| `.webp --quality 90` | 3 032 B | no | 76 797 | lossy with `--quality`, lossless without |
| `.exr` | 23 262 B | no | 76 356 | half-float, **linear** (see below) |
| `.ora` | 15 138 B | 4 of 5 | 76 365 | adjustment layer dropped, type/shape rasterised |
| `.svg` | 112 B test | no | – | **read** verified: imports as one `Shape` layer; SVG **export** not tested |
| `.pdn`, `.xcf`, `.kra`, `.heic`, `.af*` | – | read-only | – | not exercised here |

`AE` = number of differing pixels from `compare -metric AE src-ref.png back.png`;
76 800 = every pixel, i.e. a tone/encoding change rather than a small error.

Independent validators used: ImageMagick `identify` (size, depth, channels,
quality), `compare -metric AE`, and Python `zipfile` for ORA.

## Format notes

### `.pcraft` — the native format

- Lossless, incremental save, keeps layer ids, names, masks, adjustment params,
  history-independent document state.
- Best default: save `.pcraft` while working, export a deliverable at the end.
- Reopening returns the same layer ids (verified: `[(5,M2),(4,M1),(3,M0),(2,Background)]`).

### PSD / PSB

- Read/write; the tested document was 8-bit RGB, 5 layers (render diff 0).
  16/32-bit and CMYK/Lab documents are supported by the format layer, but were
  not round-tripped here.
- Re-saving rewrites image resources and the composite, so files are not
  byte-identical to the source even when the render matches.
- `info` on the re-saved file reports the same 5 layers; render diff 0.

### TIFF

- Flat by default. `--tiff-layers` keeps the layers (verified 5 layers back).
- 8-bit and 16-bit were exercised; export follows the document depth. 32-bit
  float TIFF was not tested.

### PNG

- Preserves the document depth: a 16-bit document exports a 16-bit PNG
  (`identify -format '%z-bit'` → `16-bit`).
- Transparency is kept; a transparent background renders `#00000000`.

### JPEG / WebP / GIF / BMP / TGA / ICO

- 8-bit only; higher depths are reduced **with a warning**
  (`warning: 16-bit will be reduced to 8-bit`) plus `warning: lossy compression`
  for JPEG/WebP-with-quality.
- `quality` is 1–100 for the CLI/MCP `quality` parameter (`doc_export`), while
  `file.saveACopy` documents 0–12 (Photoshop scale). Check the tool you use.

### OpenEXR

- Written as half-float (`identify` → `16-bit rgba`), even from a 32-bit
  document.
- EXR stores **linear** light. Exporting an sRGB document and converting the EXR
  back to PNG produces a much darker image (mean 0.226 vs 0.422) because no
  transfer function is applied on the way out. Treat EXR as a linear
  intermediate and colour-manage the display copy; do not use it as a
  round-trip proof.

### OpenRaster (.ora)

- Writes a valid ORA: `mimetype` = `image/openraster`, `stack.xml`,
  `data/layer*.png`, `mergedimage.png`, thumbnail.
- Adjustment layers cannot be represented: they are **left out with a warning**
  (`warning: adjustment layers cannot be saved to OpenRaster and were left out
  (the merged image keeps their look)`). Type and shape layers are rasterised
  with their own warnings.
- Consequence: `mergedimage.png` matches the source exactly, but re-importing
  the layered stack loses the adjustment (mean 0.441 vs 0.422). If you need the
  look, flatten a copy first.

### Read-only formats

PDN (layers + 14 blend modes), XCF (layers, groups, masks, channels, selection),
KRA (paint layers, groups, blend modes, transparency masks), HEIC, Affinity
(`.af`, `.afdesign`, `.afphoto`, `.afpub` — unsupported features are listed in a
warning). Export to these is unavailable; convert to PSD/pcraft.

## Failure behaviour (verified)

| Case | Result |
|---|---|
| unknown extension (`out.xyz`) | `error: unknown file format: xyz`, exit 1, no file |
| missing input | `error: I/O: missing.png: No such file or directory (os error 2)` |
| missing output directory | `error: I/O: cannot create the folder …` |
| truncated PNG | `error: codec: Png: malformed data: unexpected end of file` |
| empty file | `error: codec: unrecognized image format` |
| PNG bytes named `.jpg` | **accepted** — decoding sniffs content, not the name |
| `--format` ≠ extension | codec forced, filename kept (PNG bytes in `out.jpg`) |
| `quality` on PNG | accepted and ignored (PNG has no quality) |
| `batch --in` == `--out` | refused unless `--in-place` |
| unknown action in `batch` | per-file `FAIL`, exit 1 |

## Export verification checklist

1. `photocraft-cli info exported.psd --compact` → expected layer count/names.
2. `identify -format '%m %wx%h %z-bit %[channels]' file` → codec, size, depth.
3. Re-import and compare: `convert back.png` + `compare -metric AE`.
4. For ORA: `python3 -c "import zipfile;z=zipfile.ZipFile('x.ora');print(z.namelist(),z.read('mimetype'))"`.
5. Read every `warnings[]` entry from `doc_save`/`doc_export` — they are the
   app's own fidelity report.
6. Reopen the saved file in a second document and diff `doc_inspect` layer trees.

## Stress numbers

- 8000×8000 document: create 0.03 s, fill 2.5 s, 40 layers 0.1 s, selection 0.2 s,
  Gaussian blur r=200 0.06 s (on the selected layer), save 3.6–6.3 s (349 KB).
- History is capped at **50** states by default; 120 commands → 51 states,
  50 undos.
