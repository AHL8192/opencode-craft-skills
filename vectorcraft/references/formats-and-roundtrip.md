# Formats and round-trip fidelity (0.14.0)

Test document: 400×300 pt, 2 artboards, rounded rect `#e8573f` + 3 pt stroke,
gradient ellipse (`#ffcc00` → `#1f7ae0`), live text "Hi VectorCraft" in
DejaVu Sans 28 pt, green star. Reference raster: `out.png` (transparent bg).

## Export matrix — all succeeded, warnings only where noted

| Format | Size | Independent check | Re-import result | Notes |
|---|---|---|---|---|
| `.vectorcraft` | 35,776 B | JSON, `info` ok | 2 artboards, 5 kinds, 5 objects | native, ids stable |
| `.svg` | 1,345 B | `rsvg-convert` ok, XML parses | 1 artboard, 3 Path + Type | live `<text>`, one artboard per file |
| `.svgz` | 738 B | gzip → same SVG | same as SVG | |
| `.pdf` | 13,265 B | `pdfinfo`: 2 pages, 400×300, Producer VectorCraft; `pdftotext` finds the text | 2 artboards, live text | page 2 blank (empty artboard) |
| `.ai` | 14,234 B | `file`: PDF 1.7, 2 pages | 2 artboards, editable | PDF-compatible + native data |
| `.png` | 7,464 B | `identify`: 400×300 RGBA | image | transparent bg |
| `.jpg` | 10,394 B | 400×300, JFIF 1.02 | image | white behind transparency |
| `.gif` | 5,702 B | 400×300, 256c | image | |
| `.webp` | 6,520 B | 400×300 | image | lossless only; lossy is refused with a warning |
| `.tif` | 40,904 B | LZW, 400×300 | image | |
| `.bmp` | 360,054 B | 24-bit, 400×300 | image | |
| `png8` | 3,797 B | 8-bit colormap | image | `format:"png8"`, `colors` 2–256 |
| `.txt` | 15 B | content = `Hi VectorCraft` | n/a | one line per story; hidden/template art left out |
| `.dxf` | 51,076 B | `file`: AutoCAD 2018 | 41 Paths + 1 compound, no text | **warning**: gradients flattened to their average colour |
| `.eps` | 129,036 B | DOS EPS + TIFF preview, DSC 3.0 | 2 artboards, live text | type written as outlines in EPS but reopens as Type |
| `.emf` | 37,580 B | Windows Enhanced Metafile | Clip Group + Image + 5 Paths | transparency/clipping rasterised inside the vector frame |
| `.wmf` | 4,696 B | WMF, 5 objects | 5 Paths | **warning**: gradients flattened; curves become polygons |
| `.tga` | 360,044 B | RGB 400×300 | image | |
| `.psd` | 98,372 B | `file`: RGBA, 4 channels | single merged image | `layers:true` writes real layers; import is merged |
| `.vctemplate` | 35,798 B | JSON | opens as Untitled-1, 2 artboards | template, not a document |

Export options verified: `scale:2` → 800×600 PNG; `artboard:1` → 1-page PDF
(with a "Preserve editing was left out" warning); `range:"1-2"` → 2 pages;
`outlineText:true` → SVG with 0 `<text>` elements (8,227 B vs 1,345 B);
`selection:true` with nothing selected → clear error.

## Pixel fidelity (ImageMagick `compare -metric RMSE`)

Reference: `out.png` flattened on white.

| Round trip | RMSE | Verdict |
|---|---|---|
| native → PNG | **0** | pixel exact |
| PDF → PNG | **0** | pixel exact (page 1) |
| `.ai` → PNG | **0** | pixel exact |
| EPS → PNG | **0** | pixel exact |
| SVG → PNG | 18.31 (0.00028) | visually identical, sub-pixel AA |
| PDF page 1 vs direct PNG (PDF unflattened) | 3,935 (0.060) | difference is the transparent background, not content |

Sample points after round trip: (100,80) `#e8573f`, (260,80) `#99a767`
(gradient mid), (200,150) white/transparent — unchanged.

## Import matrix (self-produced files)

| Input | Result | Kinds | Warnings |
|---|---|---|---|
| `.vectorcraft` | full fidelity, ids preserved | Layer, Rounded Rectangle, Ellipse, Path, Type | none |
| `.svg` / `.svgz` | 3 Paths + Type, CSS classes and `rgb()` honoured | | none |
| `.pdf` / `.ai` | 2 artboards, live type | | none |
| `.eps` | 2 artboards, live type | | none |
| `.png/.jpg/.gif/.webp/.tif/.bmp/.tga/.psd` | one Image object | Image | none |
| `.dxf` | 41 Paths + Compound Path, **no text** | | none |
| `.emf` | Clip Group + Image + 5 Paths | | none |
| `.wmf` | 5 Paths | | none |
| foreign `.svg` with CSS, `<filter>`, `<foreignObject>`, missing image | CSS fill and `rgb()` applied; image placeholder; **filter dropped silently**; foreignObject ignored | Path, Type, Image | only the missing link |

Malformed input: empty native file, truncated SVG, invalid XML, `random.bin`
all fail with explicit errors (see `cli.md`). No crashes.

## How to validate

```sh
identify out.png out.jpg out.gif out.webp out.tif out.bmp out.tga
pdfinfo out.pdf | grep -E 'Pages|Page size|Producer'
pdftotext out.pdf - | head
gs -q -dNOPAUSE -dBATCH -sDEVICE=png16m -r72 -dFirstPage=1 -dLastPage=1 \
   -sOutputFile=page1.png out.pdf
rsvg-convert -w 400 out.svg -o svg.png
unzip -l out.svgz            # gzip member, not a zip
vectorcraft-cli info out.svg # warnings + kinds + fonts
```

## Fidelity caveats

- **One artboard per file** for SVG/PNG/etc. Use `range` (SVG/PDF/EPS) or
  `useArtboards` (raster) to get one file per artboard. SVG names them
  `<stem>-<Artboard name>.svg`.
- **Transparency**: only PNG/TIFF/GIF/WebP/TGA/PSD keep alpha; JPG and PDF
  flatten on white. Compare after flattening or the RMSE is misleading.
- **Text**: PDF, AI, SVG, EPS and PSD-as-layers keep live text where the format
  allows; DXF (appearance mode) and `outlineText` turn it into paths.
- **Gradients**: DXF and WMF flatten them to the average stop colour and warn;
  EPS level 3 keeps them, level 2 steps them.
- **EPS re-import** reports `Type` objects, but the file itself stores outlines.
- **Fonts**: a missing family silently becomes a fallback (`Source Sans 3`).
  `vectorcraft-cli info` lists `fonts[].status:"substitute"`; export warns.
- **PSD import** is the merged composite, never layers.
- **`.ai` round trip** is VectorCraft's own PDF-compatible file; arbitrary
  Illustrator files may import as their PDF part only (warning lists losses).
