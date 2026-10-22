# Commands and properties — FigCraft 0.8.0

569 commands, 57 namespaces, 303 undoable, 149 with shortcuts. The exact, complete list with
parameter strings is in `command-index.md` (generated from `figcraft-cli commands --json`).
This file is the working guide: the ids you actually reach for, their params, and the rules
behind them.

## How to query instead of guessing

```jsonc
// MCP
{"name":"list_commands","arguments":{"filter":"auto layout"}}   // literal, case-insensitive substring
{"name":"run_command","arguments":{"command":"node.set","params":{"ids":[2],"opacity":0.5}}}
{"name":"batch","arguments":{"commands":[
  {"command":"node.create","params":{"type":"frame","width":320,"height":200}},
  {"command":"node.create","params":{"type":"text","parent":{"$step":0},"x":24,"y":24,"text":"Hi"}}]}}
```

```sh
figcraft-cli commands --filter "auto layout"     # 22 lines
figcraft-cli commands --filter "layout"          # 36 lines
figcraft-cli commands --filter autoLayout        # 0 lines — no space, no match
figcraft-cli commands --json                     # all 569, machine-readable
```

Every command result is JSON. A failed command is an MCP tool error (`isError:true`) whose text is
the engine's message, e.g. ``no such node 99999``, ``invalid parameters for `node.set`: unknown
properties: bogus``, ``nothing to export``. Batch stops at the first failure and applies nothing.

## Namespaces

| Namespace | # | What lives there |
|---|---|---|
| `text` | 56 | text.set/style, edit session (`text.edit.*`), bold/italic, lists, case, fonts, on-path |
| `view` | 48 | zoom/pan, panels, fullscreen, dev mode, presentation, `view.set` |
| `vector` | 40 | vector network editing: points, segments, handles, pencil, boolean-ish ops |
| `object` | 28 | group/ungroup, mask/releaseMask, convertToFrame/Group/Section, flip, rotate, rename, rasterize |
| `select` | 21 | select.all/none/parent/children/inverse, byName, area, layersAt, same* |
| `file` | 21 | new/open/save/saveAs/close, import, export, exportFramesPdf, exportLayers, templates |
| `tool` | 21 | switch tools (move, frame, text, pen, pencil, hand, comment, …) |
| `component` | 21 | create, combineVariants, addVariant, properties, detach, slots, playground |
| `collab` | 21 | multiplayer sessions, cursors, follow (not exercised) |
| `proto` | 20 | interactions, actions, flows, evaluate, present, preview, settings |
| `variable` | 18 | collections, modes, values, bind, import/export |
| `library` | 18 | team libraries (not exercised) |
| `edit` | 16 | undo/redo, copy/paste, duplicate, delete, findReplace, pasteDesignLayers |
| `comment` | 14 | comment threads |
| `pref` | 13 | preferences |
| `plugin` | 11 | plugin runtime |
| `arrange` | 10 | z-order, pack, reorder, spacing, tidy, roundToPixels |
| `style` | 10 | create/apply/list/bind/update/detach/duplicate/move |
| `transform` | 9 | nudge, flip, rotate, scale |
| `version` | 8 | version history / branches |
| `page` | 8 | add/delete/duplicate/list/move/rename/select/setBackground |
| `instance` | 8 | create, swap, swapAt, setProperties, slots |
| `annotation` | 8 | annotation measurements |
| `branch` | 7 | branches |
| `shape` | 6 | rectangle, ellipse, polygon, star, line, arrow |
| `stroke` | 6 | add/set/remove/move, widthProfile, brush |
| `align` | 6 | left/hcenter/right/top/vcenter/bottom |
| `node` | 5 | create, get, set, reorder, reparent |
| `image` | 5 | adjust, presets, crop, … |
| `fill` | 5 | add/set/remove/move, pattern |
| `bool` | 5 | union/subtract/intersect/exclude/flatten |
| `doc` | 5 | document-level settings |
| `guide` | 5 | layout guides |
| `inspect` | 5 | code, properties, assets, componentCode, readyForDev |
| `effect` | 4 | add/set/remove/move |
| `selection` | 4 | selection helpers (distinct from `select`) |
| `layout` | 4 | add/remove/setTrack/suggest (auto layout) |
| `dev` | 4 | focus view etc. |
| `frame` | 3 | create, presets, swapOrientation |
| `grid` | 3 | layout grids (add/move/remove) |
| `export` | 3 | per-layer export settings (add/update/remove) |
| `paint` | 1 | documentColors |
| `template` | 1 | list |
| `layers`, `command`, `section`, `widget`, `distribute`, `window`, `app`, `libraries`, `measure`, `plugins`, `help`, `shapeBuilder`, `codeConnect`, `devResource` | 1–4 each | misc/menu-level |

Namespaces are not always symmetrical: `select` vs `selection`, `style` vs `styles`,
`library` vs `libraries`, `plugin` vs `plugins`, `export` (settings) vs `file.export` (bytes).
Check the index before assuming a name.

## Create and change layers

```jsonc
node.create {type, x?, y?, width?, height?, parent?, index?, name?, text?, path?, props?, select?}
node.set    {ids?, name, visible, locked, opacity, blend, x, y, width, height, rotation, ...}
node.get    {id}                     // inspect_document covers the tree
node.reorder{id, index}
node.reparent {ids?, parent, index?}
frame.create {preset?, x?, y?, width?, height?, parent?, name?, props?}
shape.rectangle|ellipse|polygon|star {x, y, width, height, parent?, props?}
shape.line|arrow {x, y, width /* length */, parent?, props?}
text.create {text, x, y, parent?, width? /* wraps */, props?}
```

`type` values: `frame rectangle ellipse polygon star line arrow vector text section component slice`.
`node.create` takes `path` (SVG path data) for `vector`.

Defaults worth knowing: `width`/`height` default to 100 (ignored for lines/arrows and auto-height
text); a new layer is selected unless `select:false`; `index` defaults to the top of the parent.

`frame.presets` returns the named presets used by `frame.create {preset:"iPhone 16"}` (Desktop,
iPhone, Android, iPad, print sizes …). A preset without x/y lands to the right of the page's frames.

## Selection

```jsonc
select.set {ids:[..]}      // = the `select` tool
select.none {}
select.all {}
select.add {ids}, select.remove {ids}, select.inverse {}
select.byName {query, page?}     // page "all" searches every page
select.area {x, y, width, height, add?, deep?}
select.layersAt {x, y}           // hit test in page coordinates, front-most first
select.parent|children|next|previous {}
select.sameFill|sameStroke|sameEffect|sameFont|sameText|sameInstance|sameProperties {}
```

Selection is per document, not per page. Ids are document-wide: a layer on page 1 can be selected
and edited while page 2 is current. `select {ids:[]}` deselects.

## Structure and geometry

- `object.group {ids?, name?}` — first id becomes the group's parent context; groups have **no
  coordinate space**, their children stay in the surrounding frame's coordinates.
- `object.ungroup`, `object.convertToFrame`, `object.convertToGroup`,
  `object.convertToSection` (refused for instances, main components and nested frames).
- `object.mask {ids?}` / `object.releaseMask` — the top layer masks the ones under it;
  `maskType` is `alpha` (default), `vector` or `luminance` (set it with `node.set`).
- `bool.union|subtract|intersect|exclude` wrap the selection in a boolean group, or set the
  operation when the selection is inside one; `bool.flatten` bakes the geometry.
- `align.*` aligns to the selection's bounds (or the parent frame with one layer);
  `distribute.*` and `arrange.spacing|tidy|packH|packV` distribute.
- `arrange.front|forward|backward|back` change z-order; `arrange.reorder {ids?, source, target,
  swap?, fromGesture?}` inserts at a visual slot without hierarchy changes.
- `transform.nudge {dx, dy, big?}` (auto layout children move one place instead).
- `arrange.roundToPixels`, `object.rotateLeft|rotateRight|rotate180`, `object.flipH|flipV`.
- `object.rasterize {ids?, scale?}`, `object.resizeToFit {ids?}`, `object.frameSelection`.
- `object.opacityKeys {digits, ids?}` is the 1–9/0 shortcut; use `node.set {opacity}` in scripts.

## Property keys (`node.set` / `set_properties.props`)

Numeric: `x y width height rotation opacity cornerRadius cornerSmoothing gap crossGap
padding paddingTop paddingRight paddingBottom paddingLeft minWidth maxWidth minHeight maxHeight
gridColumns gridRows gridColumnSpan gridRowSpan pointCount innerRadius arcStart arcSweep arcInner
fontSize paragraphSpacing paragraphIndent indentation listSpacing maxLines`.

Booleans: `visible locked clip isMask absolute wrap strokesIncluded reverseZ hangingPunctuation
hangingList leadingTrim constrainProportions`.

Enums: `blend cornerRadius? textAlign textAlignVertical textAutoResize textCase textDecoration
textDecorationStyle listStyle layout mainAlign crossAlign contentAlign sizingH sizingV
strokeAlign strokeCap strokeJoin gridAlignH gridAlignV constraints.horizontal constraints.vertical
overflow booleanOperation operandOperation description textDecorationColor`.

Paint: `fill` (one colour), `fills` (array of paints), `stroke` (colour), `strokes` (array),
`strokeWeight`, `strokeSides`, `strokeTopWeight`/`Right`/`Bottom`/`Left`, `dashes`,
`widthProfile`, `brush`, `effects` (array), `grids` (layout grids), `exports` (export settings),
`interactions` (prototype).

Text: `characters fontFamily fontStyle fontSize lineHeight letterSpacing features
fontVariations/variationSettings textDecorationThickness textDecorationOffset
textDecorationSkipInk textDecorationColor`.

Layout grids on a layer: `grids: [{kind:"grid"|"columns"|"rows", size?, count?, gutter?, offset?,
alignment?}]`; auto-layout tracks: `columnTracks: [120|"1fr"|"auto"|{sizing,value}]`.

Paints:

```jsonc
"fill": "#7048E8"
"fills": [{"type":"solid","color":"#FFFFFF"}]
"fills": [{"type":"linearGradient","stops":["#7048E8","#1098AD"], ...}]
"fills": [{"type":"radialGradient"|"angularGradient"|"diamondGradient","stops":[...]}]
"fills": [{"type":"image","image":"<hash from file.placeImage or an image layer>","scaleMode":"fill"}]
"effects": [{"type":"DROP_SHADOW"|"dropShadow","color":"#00000033","offsetX":0,"offsetY":4,"radius":12}]
"strokeAlign": "inside"|"center"|"outside"
```

`node.set` rejects unknown keys (`unknown properties: …`). Nested paint objects are validated on
apply, but an unknown `type` in a paint is accepted silently and renders nothing — read back.

## Auto layout and grids

```jsonc
layout.add {ids?, direction:"horizontal"|"vertical"|"grid"}
layout.remove {ids?}
layout.setTrack {ids?, axis:"columns"|"rows", index, sizing:"fixed"|"hug"|"fill", value?}
node.set {layout:"vertical", gap:12, padding:16, mainAlign:"center", crossAlign:"min",
          sizingH:"hug", sizingV:"fill", wrap:true, columnGap:8, rowGap:8}
node.set {layout:"grid", gridColumns:3, columnTracks:["1fr","1fr","1fr"], gridColumn:1,
          gridColumnSpan:2, gridAlignH:"center"}
```

`layout.suggest` proposes a layout from the children. `gap` is the main-axis gap; `crossGap`
(alias `rowGap`) is the cross-axis gap; `columnGap` is an alias of `gap`. In a grid frame,
`gap`/`crossGap` are the column/row gaps. `mainAlign` also accepts `spaceBetween`,
`spaceAround`, `spaceEvenly`. `contentAlign:"spaceBetween"` spreads wrapped rows. `sizingH/V`:
`fixed`, `hug`, `fill`. `absolute:true` takes a child out of the flow.

## Text

```jsonc
text.set {id, characters}
text.style {id?, start?, end?, fontFamily?, fontStyle?, fontWeight?, fontSize?,
            lineHeight?, letterSpacing?, textDecoration?, textCase?, hyperlink?, textFills?}
text.bold|italic|underline|strikethrough {ids?}
text.alignLeft|alignCenter|alignRight|alignJustify {ids?}
text.caseUpper|caseLower|caseTitle|caseSmallCaps|caseOriginal {ids?}
text.listStyle {style:"bulleted"|"numbered"|"none", ids?}
text.onPath {text?, path?, start?, flip?} / text.removeFromPath {ids?} / text.pathOptions
text.fonts {family?, style?} / text.loadFont {path|data} / text.missingFonts {}
text.edit.begin {id, caret?} → text.edit.insert {text} / text.edit.key {key,…} / text.edit.end
```

A `text` layer with no `width` is auto-width; `width` makes it wrap and auto-height.
`text.style` without `start/end` styles the whole layer; with a range it creates styled runs
(readable as `styledRuns` on the layer). While a text edit session is open, range styling applies
to the selected characters. `fontWeight` is accepted as a convenience (400/700); the canonical
keys are `fontStyle` ("Regular", "Bold", "SemiBold", …) and `fontVariations`.

`type_text` (tool) replaces the whole characters string; it does not need an edit session.

## Components, instances, variants

```jsonc
component.create {ids?}                     // frame/group → component; several layers wrapped
component.list {} → [{id,name,type,page,instances,folder,label,…}]
component.combineVariants {ids?}            // ≥2 components → one set (2 variants)
component.properties {id?} → {component, set, properties:[{name,type,options,default,value}], conflicts}
component.addVariant {id?, property?, value?}     // duplicate a variant; name the new one
component.addProperty {id?, name, type:"boolean"|"text"|"instanceSwap"|"variant"|"slot", default?}
component.editProperty / deleteProperty / bindProperty / exposeInstance / goToMain
component.detach {ids?} / component.resetInstance / resetOverride / pushChanges / restoreMain
instance.create {component, x?, y?, parent?}
instance.swap {ids?, component} / instance.swapAt {component, x, y} / instance.place
instance.setProperties {ids?, properties:{"Property 1":"Variant2"}}
component.playground {id?, properties?, language?, path?, scale?}   // code + PNG, no doc change
```

Variant property names are generated (`"Property 1"`) unless you pass `property`/`value` to
`component.addVariant`. `instance.setProperties` rejects unknown names and lists the known ones.
A main component's duplicate is an instance; a variant's duplicate is a new variant in its set.

## Styles and variables

```jsonc
style.create {type:"paint"|"text"|"effect"|"grid", name, from?, description?, value?}
style.apply {ids?, style: id|name, target?:"fill"|"stroke", start?, end?}
style.list {type?}
style.update {style, name?, description?, value?, from?}
style.bind {style, field:"fills/0/color"|"fontSize"|…, variable?}   // null unbinds
style.detach {ids?, which:"fill"|"stroke"|"effect"|"grid"|"text", start?, end?}
style.duplicate {style}, style.move {styles, before?, folder?}, style.renameFolder

variable.createCollection {name, modes?}
variable.create {collection, name, type:"color"|"number"|"string"|"boolean", value|values:{mode:value}}
variable.set {variable, mode?, value|{alias}}
variable.setMode {ids?, collection, mode}        // null → Auto (inherit)
variable.bind {ids?, field, variable}            // field list below
variable.addMode / removeMode / renameMode / moveMode / renameCollection
variable.import {variables} / variable.export {collections?, format:"json"|"css", path?}
variable.list {}
```

`variable.bind` fields: `fill`, `stroke`, `fills/<i>/color`, `strokes/<i>/color`,
`fills/<i>/stops/<j>/color`, `effects/<i>/offsetX|offsetY|radius|startRadius|spread|color`,
`layoutGrids/<i>/size|count|gutter|offset`, `componentProperties/<name>`, `width`, `height`,
`opacity` (percent), `cornerRadius`, `gap`, `paddingHorizontal`, `characters`, `visible`,
`fontSize`, … List indices count from the bottom (first paint/stroke is 0).

Binding a colour variable to a number field is accepted but meaningless; the field keeps its old
value. Read back with `get_node` (bound fields report the value from the layer's modes).

## Prototypes

```jsonc
proto.interaction.add {id?, trigger:{type:"onClick"|"onHover"|"afterDelay"{ms}|"keyPress"{key}},
                       action:{type:"navigate",dest:<frame>}, transition?, durationMs?, easing?}
proto.interaction.add {id, dest}                       // click → navigate shorthand
proto.interaction.set|remove|clear
proto.action.add|set|move|remove {id?, index, path?, action}
proto.conditional.addBlock|removeBlock|setCondition {id?, index, path, expression}
proto.flow.add {start?, name?} / flow.remove / flow.rename
proto.evaluate {expression|expr, id?} → {value,type,text}    // no document change
proto.present {start?} / proto.preview {start?} / proto.presentOptions {…}
proto.settings {device?, background?, rotation?, width?, height?, responsive?}
```

`proto.evaluate` is the quickest way to check expression syntax without touching the document.
`present`/`preview` open UI (attached mode only) and are hard to automate; verify interactions by
reading `get_node` (`interactions`) instead.

## Inspect / handoff

```jsonc
inspect.code {id?, language:"css"|"html"|"react"|"leptos"|"swiftui"|"compose", unit?:"px"|"rem"}
inspect.componentCode {id?, language:"react"|"leptos"|"swiftui"|"compose"}
inspect.properties {id?, colorFormat:"hex"|"rgb"|"css"|"hsl"|"hsb"}
inspect.assets {ids?} → {assets:[{id,name,kind:"export"|"icon"|"image",exports}]}
inspect.readyForDev {status?, page?}
```

`inspect.code` errors on an unknown **value**, but silently ignores an unknown **key**
(`format:"react"` → CSS). Use `language`.

## Files, pages, export

```jsonc
file.new {name?}                       // opens a NEW TAB, does not reset the current document
file.newFromTemplate {template, name?}
file.open {path|data+name, variables?} // new doc: {index, summary, repairs}; already open: {index}
file.save {path?} / file.saveAs {path} // no extension → adds .figcraft
file.close {index?, force?}            // errors on unsaved changes without force
file.import {path|data+name, x?, y?, center?, variables?}
file.export {ids?, format:"png"|"jpg"|"svg"|"pdf"|"webp"|"fig", scale?|size?, path?, bleed?, cropMarks?, bleedMarks?, cmyk?, svgOutlineText?}
file.exportFramesPdf {path?, page?, bleed?, cropMarks?, bleedMarks?, cmyk?}
file.exportLayers {ids?, assets?, dir?}
file.placeImage {path|data, x?, y?}
export.add|update|remove {ids?, setting:{size:"2x"|"512w"|"512h"|{by,value}, suffix?, format?, …}}

page.add {name?} / page.delete {id?} / page.duplicate / page.list / page.move / page.rename
page.select {id|index} / page.setBackground {id?, color}
```

`file.export` with no `ids` uses the selection, else the page. `file.exportFramesPdf` is the
reliable multi-page route (one page per top-level frame, reading order). `file.exportLayers`
writes one file per export setting, using the layer name + suffix.

## Export settings and naming

`export.add` without a setting adds `1x` then a `2x`-style step. Sizes: `"2x"`, `"512w"`,
`"512h"`, or `{by:"scale"|"width"|"height", value:n}`. Suffixes are literal; `@2x` is the default
for a scaled export without a suffix. `file.exportLayers` turns `/` in layer names into folders
and de-duplicates repeated names with ` 2`.

## Shortcuts (149 total; useful ones)

`Cmd+Z` / `Shift+Cmd+Z` undo/redo · `Cmd+D` duplicate · `Cmd+C/X/V` copy/cut/paste ·
`Shift+Cmd+V` paste over · `Alt+Cmd+C/V` copy/paste properties · `Delete` delete ·
`Cmd+G` group · `Cmd+Shift+G` ungroup · `Cmd+Alt+K` create component · `Cmd+Alt+B` detach ·
`Cmd+Shift+K` place image · `Cmd+Alt+G` frame selection · `Cmd+Shift+H` hide · `Cmd+Shift+L`
lock · `Cmd+,` preferences · `Cmd+Shift+E` export · arrow keys nudge, `Shift` = 10×.
The full set is in `command-index.md` (shortcut suffix).
