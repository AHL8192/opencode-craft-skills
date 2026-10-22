# VectorCraft command map (0.14.0)

792 commands in `vectorcraft-cli commands`; 1090 in `engine.commands` with a
document open. Params below are informal: `?` optional. Live, authoritative text:

```sh
vectorcraft-cli commands | python3 -c 'import json,sys; [print(c["id"],"|",c["params"]) for c in json.load(sys.stdin) if c["id"]=="shape.rectangle"]'
```

Over MCP use `command_list {query:"shadow"}` or `command_run {id, params}`.

> **Validation.** Both layers validate. Engine commands reject unknown ids,
> unknown/misspelled params (`unknown parameter \`widht\`; did you mean
> \`width\`?`), wrong types and bad colours; MCP convenience tools reject them at
> the JSON-schema level. Value-level coercions (negative widths, scale 0, empty
> text) are still silent — read back after every engine-level edit.

## Document and files

- `file.new` — `{width?=612, height?=792, units?, orientation?, artboards? 1–1000, artboardLayout?:{layout,columns,spacing,rightToLeft}, bleed?, backgroundContents?:transparent|white, colorMode?:rgb|cmyk, rasterEffectsPpi?, name?|title?}`
- `file.open` — `{path}` (any readable format; templates open untitled)
- `file.close` — `{index?}`
- `document.activate` — `{index}` (0-based among open docs)
- `document.save` — `{path?, format?:vectorcraft|template|pdf|svg|svgz|ai, version? 1–4, compress?, preview?, pdfCompatible?, separateArtboards?, range?}` → `{path,bytes,warnings,files?}`; **no path → `{dataBase64}` and the document stays dirty**
- `document.export` — `{path?, format?, artboard? 0-based, artboards?, range?: "1-3,5", scale? px/pt, ppi?, quality?, background?, selectionOnly?, useArtboards?, outlineText?, svg?:{…}, …}` → `{path,format,bytes,warnings,files?}`; never changes the document's own path
- `document.exportPdf` — `{path?, standard?:pdfA2b|pdfX1a|pdfX3|pdfX4, compatibility?, preserveEditing?, createLayers?, marks?, bleed?, security?}`
- `document.exportDxf` — `{path?, version?=2018, unit?=mm, scale?, colors?, preserve?:appearance|editability}`
- `document.exportEps` — `{path?, level?:2|3, previewFormat?, useArtboards?}`
- `document.exportForScreens` — `{folder?, formats:[{format,scale,width,height,suffix}], artboards?|range?, zip?}`
- `document.setup` — `{units?, bleed?, gridSize?, language?, exportText?}` (no params → current setup)
- `document.info` — `{category?:document|objects|fonts|…, format?:"text"}`
- `file.saveAsTemplate` — `{path?, format?:template|ait}`
- `file.place` — `{path|dataBase64, link?, at?, rect?, page?, crop?}`
- `file.revert` — (not in 0.14.0 catalog; use reopen)

## Shapes and paths

- `shape.rectangle` — `{x,y,width,height, radius?, rotation?}` → `{id}`
- `shape.ellipse` — `{x,y,width,height, rotation?}`
- `shape.polygon` — `{cx,cy,radius, sides?=6, rotation?}`
- `shape.star` — `{cx,cy,radius1,radius2, points?=5, rotation?}`
- `shape.line` — `{x1,y1,x2,y2}`
- `shape.spiral` — `{cx,cy,radius, decay?=80, segments?=10, clockwise?}`
- `shape.arc` — `{x1,y1,x2,y2, closed?}`
- `path.create` — `{anchors:[{x,y,in?:[x,y],out?:[x,y]}], closed?, d?: "M0 0 L…"}`
- `path.join` — `{ids?:[a,b], ends?, to?:corner|smooth}`; `path.close` — `{id}`
- `path.deleteAnchors`, `path.reverse`, `path.simplify`, `object.path.outlineStroke`, `object.path.offsetPath`

## Objects, layers, stacking

- `object.group` — `{ids?}` → `{id}`; `object.ungroup` — `{ids?}`
- `object.setProps` — `{ids?|id?, name?, visible?, locked?, opacity? 0–100, blend?, data?:{k:v}}`
- `object.align` — `{horizontal?:left|center|right, vertical?:top|center|bottom, to?:selection|artboard|key, artboard?}`
- `object.arrange.bringToFront | bringForward | sendBackward | sendToBack` — `{ids?}`
- `edit.duplicate` — `{}` (selection; offset by the preference)
- `layer.delete` — `{ids?|id?}` (deletes objects, groups or layers and their contents)
- `layer.new` — `{name?, top?, color?, template?, locked?, visible?, printable?}`
- `layer.newSublayer`, `layer.move`, `layer.merge`, `layer.duplicate`
- `layer.setCurrent` — `{id}`, `layer.selectAll`, `layer.setProps`

## Transform (all accept `ids?`, default selection)

- `object.move` — `{dx, dy, copy?, objects?, patterns?, typeAreas?}`
- `object.rotate` — `{angle (ccw), origin?:[x,y], absolute?, copy?}`
- `object.scale` — `{sx %, sy?, origin?, strokes?, corners?, copy?}`
- `object.reflect` — `{axis:vertical|horizontal|<deg>, origin?, copy?}`
- `object.shear` — `{angle, axis?, origin?}`
- The MCP `transform` tool wraps these: `{dx,dy,rotate,scale,scaleX,scaleY,shear,reflect,copy,origin,ids}`.
  `scale:-50` is accepted and behaves as +50 % (verified 0.14.0).

## Pathfinder (destructive; back → front)

`object.pathfinder.unite`, `.minusFront`, `.intersect`, `.exclude`,
`.divide`, `.trim`, `.merge`, `.crop`, `.outline`, `.minusBack` — `{ids?}` → `{ids}`

## Paint and appearance

- `paint.setFill` — `{color?: "#rrggbb"|[r,g,b 0..1]|{c,m,y,k}|{gray}|{l,a,b}, none?, swatch?, tint?, gradient?:{kind?:linear|radial|freeform, stops:[{offset,color,opacity?,midpoint?}], angle?, start?, end?, aspect?, focal?}, ids?|id?, item?, target?, span?:object|selection, keepModel?}`
- `paint.setStroke` — same shape, for the stroke
- `stroke.set` — `{weight?, cap?, join?, miterLimit?, align?:center|inside|outside, dash?, dashOffset?, startArrow?, endArrow?, profile?, ids?}`
- `swatch.new` — `{name?, color?|swatch?|gradient?, tint?, global?, spot?, group?}` → `{name,names}`
- `effect.list` — `{ids?}` → `{catalog:[{id,label,menu,params,defaults}], applied}`
- `effect.apply` — `{effect:"stylize.dropShadow", params?, item?, ids?}` → `{ids,index}`
- `effect.setParams`, `effect.remove`, `appearance.addFill/addStroke`

## Text

- `text.create` — `{x,y,text, size?, font?, style?, color?, vertical?, area?:{width,height,fit?}, justify?, placeholder?}` → `{id,bounds,overflow?}`
- `text.setRangeStyle` — `{id?, start? byte, end?, font?, style?, size?, leading?, tracking?, fill?, stroke?, underline?, allCaps?, smallCaps?, position?}`
- `type.createOutlines` — `{}` (selection) → `{ids}`
- `text.fitHeadline` / `type.fitHeadline`, `text.thread`, `text.wrap` (MCP `text_wrap`)
- MCP `add_text` is the convenience wrapper (point type, or area type with `width`/`height`).

## Selection and view

- `select.all` — `{}` → `{count}`; `select.none`; `select.set` — `{ids}` → `{count,ids}`
- `select.add`, `select.toggle`, `select.same.fillColor`, `select.key`
- `edit.undo`, `edit.redo`, `edit.copy`, `edit.paste` — `{center?|dx?,dy?}`
- View tools are UI-side: use control `ui.set`, `ui.wheel`, `ui.tool.select`;
  `view.fitArtboard` is a menu id, not an engine command (verified).

## Artboards

- `artboard.new` — `{x?,y?,width?,height?,name?}`
- `artboard.setProps` — `{index, name?, width?, height?, x?, y?, bleed?}`
- `artboard.delete`, `artboard.duplicate`, `artboard.rearrange`, `artboard.fitToArt`

## Graph

MCP `create_graph` — `{type:column|stackedColumn|bar|stackedBar|line|area|scatter|pie|radar, x,y,width,height, csv?|rows?, categories?, series?}`
Engine equivalents live under `object.graph.*` (`command_list {query:"graph"}`).

## Menu-only ids and catalogue gaps

`ui.menu.list` has 902 entries / 336 unique ids, `engine.commands` has 1090, and
the CLI catalogue 792 — none is the full set. Some ids exist only in the menu
(`file.exportAs`, `file.export.png`, `file.exportForScreens`); `file.export` is
in the CLI catalogue and works through `command_run` even though the menu and
`engine.commands` omit it. Check before relying on an id:

```sh
vectorcraft --control 7983   # then: ui.menu.list, engine.commands
```
