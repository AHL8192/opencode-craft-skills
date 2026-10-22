# Commands — DeckCraft 0.9.0

Every ribbon button, menu item, shortcut and gesture is a command with an id.
`deckcraft-cli commands` lists all 321; `deckcraft-cli describe ID` prints the
same parameter text plus the menu path; `commands.list {filter}` does it at
runtime. The complete index is in `command-index.md`.

A command is run as `{"command": "id", "params": {…}}` through
`run_command`, `batch`, `deckcraft-cli run --cmd 'id={…}'`, or the control
channel. **Unknown parameter names are silently ignored** — never guess one.

## Conventions

- **Lengths** are points (72 pt = inch) on the slide; the default 16:9 slide is
  **960 × 540**, x right, y down. A rect is `[x, y, w, h]`.
- **Slide indices are 0-based.** Shape ids are handles, unique per slide only.
- Commands that add an object select it; `format.*` then acts on the selection
  (or on all selected shapes' text).
- `ids?` parameters default to the current selection.
- Shapes may sit outside the slide; there is no clipping or bounds check.

## File and document

| Command | Params |
|---|---|
| `file.new` | `{theme?, template?, size?: [w,h] pt, blank?: bool}` |
| `file.open` | `{path}` — `.deckcraft`, `.pptx` |
| `file.openBytes` | `{name, data: base64}` |
| `file.save` / `file.saveAs` | `{path?, format?: deckcraft\|pptx}` — see the format trap in bugs |
| `file.saveBytes` | `{format?}` → `{data: base64}` |
| `file.export` | `{path, format?: png\|jpeg\|pptx\|deckcraft\|outline\|pdf\|gif, slide?, all?, scale?, layout?: slides\|notes\|handouts, perPage?, paper?, orientation?, dpi?, slides?, includeHidden?, textLayer?, frame?, transparentBackground?, width?, secondsPerSlide?, loop?}` |
| `file.render` | `{slide?, scale?, edit?, transparentBackground?}` → base64 PNG |
| `file.info` | — → title, path, format, dirty, slides, hidden, sections, bytes, properties |
| `file.properties` | `{title?, subject?, author?, keywords?, comments?, category?, company?}` |
| `file.close`, `file.revert`, `file.templates` | |
| `file.recovery.save/list/open/discard` | AutoRecover |

## Slides

| Command | Params |
|---|---|
| `slide.new` | `{layout?, at?, title?, body?}` — inserts **after the current slide**, makes it current |
| `slide.go` | `{index}` or `{id}` |
| `slide.delete` | `{index?, ids?}` — deleting the last slide leaves a 0-slide deck |
| `slide.duplicate`, `slide.move {from?,to}`, `slide.next/previous/first/last` | |
| `slide.layout {layout, index?}` | name (`"Title and Content"`) or kind (`titleAndContent`) |
| `slide.rename {name}`, `slide.reset`, `slide.hide {index?, hidden?}` | |
| `slide.notes {text \| body, index?}`, `slide.inspect {index?}` | |
| `slide.fromOutline {text, markdown?}` | headings become slides, list items bullets |
| `slide.reuse {path?\|data, slides?, keepFormatting?, at?}` | |
| `slide.colorAt {slide?, x, y, scale?}` | `{color:"RRGGBB", alpha}` — a real rendered-pixel probe |

## Shapes

| Command | Params |
|---|---|
| `shape.insert` | `{preset, rect: [x,y,w,h], text?}` — 183 presets, see `shape.presets` |
| `insert.textBox` | `{rect?, text?}` |
| `shape.presets` | gallery → `[{name,label,category}]` |
| `shape.move` | `{dx?, dy?, x?, y?, ids?}` |
| `shape.resize {w?,h?,lockAspect?,ids?}`, `shape.setBounds {x,y,w,h,ids?}` | |
| `shape.rotate {deg?, by?, ids?}`, `shape.flip {axis}` | |
| `shape.fill` | `{color? \| none? \| gradient?{stops:[[pos,color]],angle?,kind?} \| picture? \| pattern?{preset,fg,bg}, transparency?, reset?, ids?}` |
| `shape.line` | `{color?, none?, width?, dash?, cap?, join?, compound?, head?, tail?, headSize?, tailSize?, ids?}` |
| `shape.effects` | `{shadow?, glow?{color,radius}, softEdges?, reflection?, bevel?, threeD?, shadowProps?, glowProps?, reflectionProps?, ids?}` |
| `shape.quickStyle {index: 0..41}` | `shape.change {preset}`, `shape.adjust {index,value}` |
| `shape.connect {from,to,preset?}`, `shape.sites {id}`, `shape.freeform {points,closed?,smooth?}` | |
| `shape.merge {op, ids?}` — union/combine/fragment/intersect/subtract | |
| `shape.rename`, `shape.altText`, `shape.visible`, `shape.lock`, `shape.setDefault` | |
| `shape.inspect {id}` | full shape JSON — **only on the current slide** |
| `shape.points/addPoint/movePoint/pointType/deletePoint` | freeform editing |

## Text and paragraphs

Edit mode first: `text.edit {id?, at?, end?, cell?, notes?}`, then
`text.insert`, `text.selectAll`, `text.set`, `text.get`, `text.move`,
`text.delete`, `text.exit`. Without an insertion point, formatting commands act
on the selected shapes instead, or silently do nothing.

| Command | Params |
|---|---|
| `format.bold/italic/underline/strikethrough/superscript/subscript` | `{on?}` (`underline` also `{style}`) |
| `format.font {family}`, `format.size {size}`, `format.color {color}` | colors: `RRGGBB`, `#RRGGBB`, `accent1..6`, `tx1..`, `{scheme,lumMod…}` |
| `format.align {align}`, `format.anchor {anchor}`, `format.direction {dir}` | |
| `format.bullets {on?, char?, color?, size?}`, `format.numbering {scheme?, start?}` | |
| `format.indent/outdent`, `format.lineSpacing {lines?\|pt?}` | |
| `format.paragraph {align?,indentLeft?,indentFirst?,spaceBefore?,spaceAfter?,lineSpacing?}` | |
| `format.columns {count,spacing?}`, `format.margins`, `format.autofit {mode}`, `format.wrap {on}` | |
| `format.highlight`, `format.caps`, `format.spacing {pt}`, `format.case {mode}` | |
| `format.textShadow {on}`, `format.textOutline`, `format.textWarp {preset}` | |
| `format.state` | effective formatting at the selection |
| `text.find {text,…}` → matches; `text.replace {text,with,…}` | |

## Tables (21)

`insert.table {rows, cols, rect?, data?}` then `table.*` on the selected table:
`insertRowAbove/Below`, `insertColumnLeft/Right`, `deleteRow/Column`,
`merge {from,to}`, `split`, `style {style}`, `options {headerRow,bandedRows,…}`,
`cellFill`, `borders {which,…}`, `cellMargins`, `cellAlign`, `distributeRows/Columns`,
`columnWidth`, `rowHeight`, `drawLine`, `eraseLine`, `selectCells`.

Styles are ids such as `medium2-accent1`, `light1-accent2`, `dark1-tx1`, `grid`,
`none`; **unknown ids are stored verbatim** (see bugs).

## Charts (3 + insert)

`insert.chart {type?, rect?, categories?, series?: [{name, values}]}` with
`column|bar|line|pie|doughnut|area|scatter|stackedColumn|…`; then
`chart.type {type}`, `chart.data {categories?, levels?, series?}`,
`chart.options {title?, legend?: b|t|l|r|null, dataLabels?, gridlines?, palette?, …}`.
An unknown type silently becomes **Clustered Column**.

## SmartArt, icons, pictures, media

`insert.smartArt {kind, items?, nodes?, rect?}` (kinds: list, process, cycle,
hierarchy, pyramid, matrix), then `smartArt.nodes/setNodes/addNode/removeNode/
promote/demote/layout/style/colors/picture/fromText/toText/toShapes`.
`insert.icon {name, rect?}`, `insert.wordArt`, `insert.symbol {text}` (needs a
text insertion point), `insert.photoAlbum`, `insert.actionButton`,
`insert.hyperlink {url?|slide?, text?}`.

Pictures: `insert.picture {path?|data, rect?}`, then `picture.crop/adjust/reset/
change/style/recolor/transparentColor/removeBackground/artisticEffect/compress`.
Media: `insert.audio`, `insert.video`, `media.options/play/pause/toggle/stop/
seek/info/posterFrame/gifPlay`.

## Design, master, sections, transitions, animation

| Command | Params |
|---|---|
| `design.theme {name}` | 8 themes: DeckCraft, Harbor, Ember, Meadow, Nocturne, Paper, Coral Reef, Slate |
| `design.colors {colors:{dk1,lt1,dk2,lt2,accent1..6,hlink,folHlink}}`, `design.fonts {major,minor}`, `design.effects`, `design.variant {index:0..3}` | |
| `design.background {color?\|gradient?\|picture?\|pattern?\|style?, all?, transparency?}` | |
| `design.slideSize {preset\|w,h, orientation?, scale?: maximize\|ensureFit\|none}` | |
| `design.hideBackgroundGraphics`, `design.headerFooter`, `design.ideas` | |
| `view.slideMaster/notesMaster/handoutMaster`, `view.closeMaster` | |
| `master.insertLayout/renameLayout/deleteLayout/insertPlaceholder/preserve/placeholders` | |
| `section.add {name?, at?}`, `section.rename/remove/removeAll/move` | |
| `transition.set {kind, option?, duration?, index?}` | 49 kinds, `transition.list`; `transition.applyAll` |
| `animation.set {effect, class?, option?, ids?}`, `animation.add {effect, start?, duration?, delay?}`, `animation.remove/move/timing/options/clear/get` | 11 animation commands |
| `insert.slideNumber`, `insert.dateTime {format?, update?}` | |

## Arrange, selection, guides, review

- `arrange.*`: bringToFront/Forward, sendBackward/ToBack, reorder {id,index},
  group/ungroup/regroup, align {edge,to}, distribute {dir}, rotateLeft/Right,
  flipHorizontal/Vertical, nudge {dx,dy,ids?}.
- `selection.select {ids|id,toggle?,add?}`, `selection.showAll/hideAll`;
  `edit.select {ids}`, `edit.selectAll {scope?: slides}`, `edit.deselect`,
  `edit.cut/copy/paste/pasteSpecial/pasteText`, `edit.duplicate/delete`.
- `guide.add {vertical,pos}`, `guide.move`, `guide.delete`, `guide.list`.
- `comment.add {text,x?,y?,id?}`, `comment.reply/delete/resolve/list/next/prev`.
- `review.accessibility`, `review.spelling {lang?}`, `review.spellingChange`,
  `review.thesaurus`, `review.compare {path}`, `review.revisions`,
  `review.accept {index|all}`, `review.endCompare`.
- `show.fromStart/fromCurrent` (commands), `show.setup`, `show.customShow`.
- `commands.list {filter}` → id/label/params/enabled; `window.next {index?}`.

## Introspection commands

`document.inspect`, `slide.inspect {index?}`, `shape.inspect {id}`,
`format.state`, `format.ruler`, `comment.list`, `animation.get`, `media.info`,
`review.revisions`, `file.info`, `design.themes`, `shape.presets`,
`transition.list`, `animation.list`, `font.used`.
