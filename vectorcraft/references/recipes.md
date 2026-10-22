# VectorCraft recipes

All recipes assume a headless MCP session (`vectorcraft-cli mcp`) or the app
bridge. Every step below was run against 0.14.0. Coordinates are **points, y down**.

## 1. Poster: shapes, gradient, type, effects, export

```
command_run {id:"file.new", params:{width:800, height:1000, title:"poster"}}
draw_shape  {shape:"rectangle", x:0, y:0, width:800, height:1000, fill:"#0b1020", stroke:"none", name:"bg"}
draw_shape  {shape:"ellipse", x:250, y:180, width:300, height:300,
             fill:{gradient:{kind:"radial", stops:[{offset:0,color:"#ffcc00"},{offset:1,color:"#e8573f"}]}},
             stroke:"none", name:"sun"}
add_text    {text:"NEON DRIVE", x:70, y:780, size:96, font:"DejaVu Sans", color:"#ffe9d6"}
apply_effect{effect:"stylize.outerGlow", params:{color:"#ff5fa2", blur:18}}
export      {path:"/tmp/poster.png", scale:2}
export      {path:"/tmp/poster.pdf"}
```

`apply_effect` with no `effect` returns the catalogue; ids look like
`stylize.dropShadow`, `stylize.outerGlow`, `blur.gaussian`, `warp.arc`.

## 2. Verified read-back loop

Never trust `null`. After each edit:

```
doc_inspect {ids:[2]}        # one node with bounds/paint
doc_inspect {kind:"Rectangle", limit:5, offset:0}
doc_inspect {depth:0}        # layer skeleton
```

`doc_inspect.objects` counts **rows** (layer included), not objects. Use
`total` or count `nodes`.

## 3. Batch-build many objects (max 256 steps)

```
command_batch {atomic:true, label:"grid", steps:[
  {id:"shape.rectangle", params:{x:0,  y:0,  width:40, height:40, fill:"#e8573f"}},
  {id:"shape.rectangle", params:{x:60, y:0,  width:40, height:40, fill:"#1f7ae0"}},
  {id:"object.group",    params:{}}
]}
```

- 256 steps per call. Verified: 8 calls of 250 steps made 2,000 distinct
  rectangles in 43–269 ms per call (~0.9 s of command time); the whole
  create + 2,000 shapes + save (929 KB) + PNG export took 1.96 s.
- `atomic:true` = one undo entry named `label`.
- `{command:…}` is **not** a valid step; the step fails with
  `unknown step argument (expected id, params)`.
- Results: `{completed, failed, results:[{ok,result|error}], created:[ids]}`.
- Cross-step references: a param string `"$0.id"` or `"$last.ids[0]"`.

## 4. Recolour without touching the selection

```
draw_shape {shape:"rectangle", …}        # id 2
draw_shape {shape:"ellipse",  …}         # id 3
set_paint  {ids:[2], fill:"#22aa66", stroke:"none"}
doc_inspect{ids:[2]}
```

`set_paint` without `ids` uses the selection and also sets the **new-art
default**, so later `draw_shape` calls inherit that fill.

## 5. Boolean badge

```
draw_shape {shape:"ellipse", x:40, y:40, width:160, height:160, fill:"#ffcc00", stroke:"none"}
draw_shape {shape:"ellipse", x:110, y:40, width:160, height:160, fill:"#ffcc00", stroke:"none"}
pathfinder {operation:"minusFront"}                    # both selected
doc_inspect {kind:"Path"}
```

Engine form: `object.pathfinder.minusFront {ids:[..]}`. Operations are
destructive — duplicate first if you need the originals.

## 6. Type with mixed styles

```
add_text {text:"Plain and bold words", x:40, y:120, size:36, color:"#111111"}
command_run {id:"text.setRangeStyle",
             params:{id:2, start:10, end:14, style:"Bold", fill:"#e8573f"}}
type.createOutlines {}      # selection → outlines
```

`start`/`end` are **byte** offsets, not characters. `add_text {font:"NoSuchFont"}`
creates the text without complaint and only warns at export — check
`fc-match` and `vectorcraft-cli info` (`fonts[].status`).

## 7. Artboards and multi-page export

```
command_run {id:"file.new", params:{width:400, height:300, artboards:3,
             artboardLayout:{layout:"gridByRow", columns:3, spacing:20}}}
export {path:"/tmp/sheet.pdf"}                   # 3 pages
export {path:"/tmp/sheet.svg", range:"1-3"}      # sheet-Artboard-1.svg …
export {path:"/tmp/a2.png", artboard:1}          # 0-based
```

SVG with a range writes `<stem>-<Artboard name>.svg`, not `<stem>-2.svg`.
A single-artboard PDF export warns that editing data was left out.

## 8. Save, reopen, prove identity

```
save_file {path:"/tmp/work.vectorcraft"}
open_file {path:"/tmp/work.vectorcraft"}
doc_inspect {kind:"Rectangle"}
```

Native ids survive the round trip (verified: rectangle stayed id 2). Compare
`selectionBounds`/`bounds`, fills and `total` before and after.

## 9. Layers and hidden art

```
command_run {id:"layer.new", params:{name:"art", color:"#e8573f"}}
draw_shape  {shape:"rectangle", …}
command_run {id:"object.setProps", params:{ids:[2], name:"plate", locked:false}}
command_run {id:"layer.setProps", params:{id:1, visible:false}}
export {path:"/tmp/hidden.svg"}    # SVG keeps hidden layers (display:none)
export {path:"/tmp/hidden.png"}    # raster leaves them out
```

## 10. Import with warnings (always read them)

```
open_file {path:"/tmp/foreign.svg"}
```

Result carries `warnings`, `missingLinks`, `modifiedLinks`, `restored`.
A missing linked image becomes a placeholder and warns; an unsupported SVG
`<filter>` is dropped **without** a warning — compare a render to the source.

## 11. GUI: click, shift-click, drag, dialogs

```python
# control channel, port 7983
ins = call("ui.inspect")
cr, v = ins["canvasRect"], ins["view"]         # [x,y,w,h], {zoom, center}
sx, sy = cr[0] + cr[2]/2, cr[1] + cr[3]/2
def to_screen(x, y):
    return sx + (x - v["center"]["x"]) * v["zoom"], sy + (y - v["center"]["y"]) * v["zoom"]
```

- `ui.click {x,y}` selects; add `shift:true` to extend; `ui.drag {x,y,toX,toY,steps:10}` moves.
- **Sleep 0.5 s** after input before `document.inspect`; at 4–30 fps the click
  is applied on a later frame.
- Clicking an already-selected object keeps the multi-selection (observed
  behaviour, not a bug).
- `Escape` does **not** deselect on Linux; use `select.none`.
- Dialogs: `tool.options {tool:"rotate"}` opens `{kind:"rotate", fields:{angle:0,…}}`;
  `ui.dialog.set {field:"angle", value:30}` then `ui.dialog.confirm` applied a
  30° rotation (bounds changed, history gained "Rotate"). `ui.dialog.cancel`
  leaves the document unchanged.
- Native file dialogs (`file.exportAs`) cannot be completed: confirm returns
  `{"error":"cancelled"}`. Pass explicit paths instead.

## 12. Screenshots and verification without eyes

```
ui_screenshot {data:true}      # or MCP ui_screenshot → inline PNG, 1440×900 here
ui.render {artboard:0, data:true, scale:1}
```

Check pixels rather than trusting the image name:

```sh
convert shot.png -format "%[pixel:p{100,100}]" info:
compare -metric RMSE expected.png actual.png null:
```
