# Recipes (verified on 0.11.1)

Every recipe below was run end-to-end on this machine; the `→` lines are real
results. Replace `/work` with your directory and pass it to both
`--automation-read-root` and `--automation-write-root`.

Headless setup:

```sh
photocraft-cli mcp --automation-read-root /work --automation-write-root /work
```

The MCP calls are shown as tool name + arguments; with the CLI use
`photocraft-cli run in.pcraft --cmd <id> --params '<json>'`, and with the bridge
use `control_call {"method":"engine.execute","params":{"command":…,"params":…}}`.

## 1. Poster / card from scratch

Goal: 400×300 card, coloured background, one line of type, one accent shape,
saved as layered `.pcraft` plus a PNG.

```text
doc_new {width:400, height:300, background:"white"}
command_run shape.create {kind:"rect", rect:[0,0,400,300], fill:"#2f4858"}
command_run layer.select {layer:"Background"}       # see gotcha below
command_run select.rect {x:40, y:40, width:180, height:120}
command_run edit.fill {contents:"color", color:"#88c0d0"}
command_run select.deselect {}
command_run type.create {x:40, y:240, text:"RECIPE", size:56, color:"#ffffff"}
command_run shape.create {kind:"ellipse", rect:[240,140,120,120], fill:"#d08770"}
doc_save {path:"card.pcraft"}
doc_save {path:"card.png"}
```

Results: `type.create → {bounds:[43,198,233,242], layer:4}`,
`shape.create → {layer:5, bounds:[240,140,120,120]}`, `card.png` is 400×300,
mean 0.271.

**Gotcha:** `edit.fill` needs a **pixel** layer. After `shape.create` the active
layer is a shape and the fill is refused:

```text
command `edit.fill` is not available right now: active layer is a Shape layer, not a pixel layer
```

Select the background (or add `layer.new.layer`) first. The same applies to Type
and Smart Object layers. `shape.create`'s `fill` is the right way to colour a
shape.

## 2. Selective grade with a masked adjustment layer

Goal: warm up only the left half, non-destructively.

```text
doc_open {path:"photo.psd"}
command_run select.rect {x:0, y:0, width:400, height:300, feather:20}
command_run layer.newAdjustmentLayer.hueSaturation {saturation:40, hue:-8}
command_run select.deselect {}
doc_save {path:"graded.pcraft"}
```

`layer.newAdjustmentLayer.*` turns the current selection into the layer mask
(no selection → unmasked). The return is `{layer:6}`; verify with `doc_inspect`
(`hasMask:true`) and by toggling `layer.layerMask.enabled`.

Other live adjustments: `layer.newAdjustmentLayer.curves {points:[[0,0],[64,48],[192,212],[255,255]]}`,
`…levels {inBlack:8, gamma:1.05, inWhite:248}`, `…vibrance {vibrance:20}`,
`…blackWhite {reds:40,…}`. Edit later with `layer.setAdjustment`; a destructive
one-shot is `image.adjustments.hueSaturation` with the same params.

## 3. Badge with a layer style

```text
command_run shape.create {kind:"ellipse", rect:[240,140,120,120], fill:"#d08770"}
command_run layer.layerStyle.dropShadow {layer:5, opacity:60, distance:8, size:12, color:"#000000"}
command_run layer.layerStyle.stroke {layer:5, size:3, color:"#ffffff", position:"inside"}
doc_save {path:"badge.psd"}
```

Both return `{layer:5}`. Drop shadow params: `angle` (deg), `distance`, `spread`
0–100, `size`, `blend` (default `multiply`), `color` `#rrggbb`. Stroke:
`width` in the UI, `size` in the command; `position:"inside|center|outside"`.

Composite several effects atomically with `layer.layerStyle.replace`:

```json
{"layer":5,"effects":[
  {"kind":"dropShadow","params":{"color":"#000000","opacity":60,"distance":8,"size":12}},
  {"kind":"stroke","params":{"color":"#ffffff","size":3,"position":"inside"}}]}
```

`layer.layerStyle.clear {layer:5}` removes them; `copyLayerStyle` /
`pasteLayerStyle` move a whole style between layers.

## 4. Soften a region with a blurred, masked duplicate

```text
doc_open {path:"photo.psd"}
command_run layer.select {layer:"Background"}
command_run layer.duplicate {}
command_run select.rect {x:100, y:80, width:140, height:120, feather:25}
command_run layer.layerMask.revealSelection {}
command_run select.deselect {}
command_run filter.blur.gaussianBlur {radius:6}
doc_save {path:"soft.pcraft"}
```

Layer order after this: `Background copy` (Pixel, `hasMask:true`, blurred) above
`Background`. Increase `feather` for a gentler transition; `radius` is 0.1–1000.
`filter.*` commands apply to the active pixel layer; on a Smart Object they
become `layer.smartFilter.*` entries instead (editable later).

## 5. PSD → web PNG at a target width

```text
doc_open {path:"poster.psd"}                 → {index:0, width:400, height:300, layers:5}
command_run image.imageSize {width:200}      → {width:200, height:150}
doc_save {path:"poster-web.png"}
```

`image.imageSize` keeps the aspect ratio when only one dimension is given and
returns the final size; add `percent`, `resolution`, `keepPrintSize`, `resample`
for other modes. `doc_save` to `.png` warns that layers are flattened — that is
expected. To export several sizes, run this per size against a fresh `doc_open`
or duplicate the document with `image.duplicate {name, mergedOnly}`.

## 6. Batch a folder (CLI only)

`grade.json`:

```json
{"steps":[
  {"id":"image.adjustments.levels","params":{"inBlack":6,"inWhite":250,"gamma":1.05}},
  {"id":"image.adjustments.vibrance","params":{"vibrance":12}},
  {"id":"filter.sharpen.unsharpMask","params":{"amount":60,"radius":1.2,"threshold":2}}
]}
```

```sh
photocraft-cli batch --actions grade.json --in ./raw --out ./graded --format png
```

- Each file starts from its own document; the steps run in order.
- `--out` must differ from `--in` (or use `--in-place`).
- Failures print `FAIL <file>: …` and set exit code 1.
- `.atn` works too: `--actions set.atn --action "My Action"`.

## 7. Export layers and artboards

Layers, from MCP (recommended):

```text
doc_export_layers {dir:"/work/layers", format:"png", prefix:"r", visible_only:true}
→ {count:4, files:["…/r_0000_Rectangle 1.png", …]}
```

Adjustment layers have no pixels and are **skipped**; `count` can be lower than
the layer count, with no warning. Files are document-sized with transparency,
named `<prefix>_<index>_<layer name>.png`.

Equivalent with ambient paths, from the CLI:

```sh
photocraft-cli run doc.pcraft --cmd file.export.layersToFiles \
  --params '{"dir":"/work/layers","format":"png"}'
```

Artboards to a multi-page PDF (CLI; the MCP automation layer blocks it):

```sh
photocraft-cli run doc.pcraft \
  --cmd layer.new.artboard --params '{"rect":[0,0,400,300],"name":"Card"}' \
  --cmd file.export.artboardsToPdf --params '{"path":"/work/boards.pdf"}'
# → {"pages":1,"path":"/work/boards.pdf"}; pdfinfo: 1 page, 400 x 300 pts
```

## 8. Place a logo as a Smart Object

```text
doc_open {path:"card.pcraft"}
doc_place {path:"/work/logo.png", scale:40, center:[200,150]}
→ {layer:10, bounds:[120,90,280,210], scale:40.0, smartObject:true}
doc_save {path:"card-logo.psd"}
```

`doc_place` always places a Smart Object (kind is `"Smart Object"`, with a
space). `doc_inspect` shows it as `"kind": "Smart Object"`.

Replacing its contents **cannot** be done over MCP automation — the command
takes a raw path and is gated:

```text
command `layer.smartObjects.replaceContents` uses ambient filesystem paths and is
disabled; use capability-scoped document methods
```

Use the CLI instead (layer id from `photocraft-cli info`):

```sh
photocraft-cli run placed.psd \
  --cmd layer.smartObjects.replaceContents \
  --params '{"layer":8,"path":"/work/logo-v2.png"}' --out replaced.psd
# → {"instances":[8],"layer":8}
```

## 9. Drive the GUI (bridge)

Start the window, then run dialog flows through the control channel:

```sh
photocraft --control 7878 --control-token-file ~/.config/photocraft/control-7878.token \
  --automation-read-root /work --automation-write-root /work &
```

```text
ui.inspect                                  → tool:"Brush", window 1440×900
ui.menu.invoke {id:"image.imageSize"}       → opens the Image Size dialog
ui.dialog.set {dialog:<id>, field:"width", value:150}   # id from ui.inspect.dialogs
ui.dialog.confirm {dialog:<id>}              → waits for the job; document resized
ui.inspect                                  → document.width == 150
ui.screenshot {path:"/work/gui.png"}        → {path, width:1440, height:900}
```

New-document dialog: `ui.dialog.open {kind:"newDocument"}`, set `width`,
`height`, `mode`, `depth`, `background`, then confirm; `ui.dialog.cancel`
discards. Dialogs are also opened by menu id (`file.new`,
`image.imageSize`, `filter.blur.gaussianBlur`, …).

Verify a screenshot without a viewer:

```sh
identify -format '%wx%h mean=%[fx:mean] sd=%[fx:standard_deviation]\n' gui.png
```

## 10. Paint a stroke through the bridge

```text
ui.set {tool:"brush"}
ui.pointer {events:[
  {kind:"down", x:100, y:100, pressure:0.8},
  {kind:"move", x:160, y:120, pressure:0.9},
  {kind:"up",   x:200, y:160, pressure:0.5}]}
```

Coordinates are **document** pixels. One down/move/up sequence is one history
step (`Brush Tool`). Tool ids are internal (`rectMarquee`, `magicWand`,
`paintBucket`, `ellipseMarquee`, `type`, `move`, `hand`, `zoom`); display names
are rejected.

## 11. Verify before declaring success

```text
doc_inspect                  → layer tree, hasMask, history, selection, dirty
doc_render_preview {max_side:800}  → flattened PNG content
doc_save {path:"check.png"}
```

```sh
compare -metric AE before.png after.png null: 2>&1   # 0 = pixel identical
convert after.png -format '%[pixel:p{20,20}]' info:  # exact colour
photocraft-cli info after.psd --compact | python3 -m json.tool | head -40
```

Remember `photocraft-cli info` omits mask flags; use `doc_inspect` for
`hasMask`/`hasVectorMask`.
