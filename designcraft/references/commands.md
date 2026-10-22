# DesignCraft commands (0.10.0)

Every user-visible action is a command. Full id list: `command-index.md`
(521 headless commands, 64 namespaces). Ask live for parameters:

```sh
designcraft-cli describe frame.create
designcraft-cli commands footnote          # filter id/label/menu
designcraft-cli commands                   # full JSON catalog
```

MCP equivalents: `list_commands {filter, enabledOnly}` returns
`{commands:[…], count}`; `execute {command, params}`; `batch {commands:[…]}`.

## Context and `enabled`

`enabled` is not a static capability flag. In a fresh headless process 491 of 521
commands are disabled with reasons such as `no document open`,
`select text or a text frame`, `nothing selected`, `no recent files`.
With a document open 321 are enabled headless; the running app reports 480 of 685.
Always check `enabled`/`disabled_reason` before assuming a command can run, or
handle the clean error:

```
command `transform.move` is not available right now: nothing selected
```

Commands that act on "the selection" also accept `ids` (objects) or
`story`/`frame`/`table` targets. Prefer explicit ids: selections are lost when a
document is reopened.

## Parameter strictness

At the engine/MCP/control layer an **unknown or wrong-case parameter is an
error**, not ignored (this contradicts `docs/agents.md`):

```
invalid parameters for `frame.create`: unknown parameter `bogusParam`;
the command takes: spread, rect, shape, content, sides, starInset, text, caret, vertical
invalid parameters for `frame.create`: unknown parameter `Rect`; did you mean `rect`?
```

But **values** are weakly validated: bad enums, wrong scalar types and
out-of-range numbers are often silently ignored or coerced (see
`bugs-and-workarounds.md`). Unknown *attribute* names inside `type.char`/`type.para`
are errors; unknown values are not.

## Namespaces

| Namespace | Count | What it covers |
|---|---|---|
| `object` | 59 | arrange, group, lock/hide, fill/stroke, effects, wrap, fitting, pathfinder, QR, captions |
| `type` | 43 | character/paragraph attributes, styles at caret, OpenType, ruby, kenten, warichu, tabs |
| `table` | 40 | insert/delete rows+columns, merge/split, cell options, styles, sort, convert |
| `file` | 35 | new/open/save/export/import, presets, recovery, recent, package |
| `style` | 28 | paragraph, character, object, cell and table styles; load/export tags |
| `layout` | 25 | pages, spreads, parents, margins, sections, guides, alternate layouts |
| `edit` | 18 | undo/redo, clipboard, duplicate, step-and-repeat, previews |
| `text` | 16 | caret/selection, insert/delete, threading, story direction |
| `path` | 14 | path editing and boolean operations |
| `swatch` | 13 | swatches, gradients, groups, ASE load/save, tints |
| `book`/`xml`/`data` | 30 | book files, tagged XML, data merge |
| `layer` | 9 | layers, move/merge/others/activate |
| `story` | 8 | set text, replace range, links, get |
| `links`/`article`/`changes`/`guide` | 32 | placed links, articles, tracked changes, guides |
| `find`/`spelling`/`xref`/`footnote`/`endnote`/`note` | 31 | editorial tooling |
| `document`/`prefs`/`view`/`tool`/`page` | 18 | preferences, inspect, list, history, units, transitions |

## Core commands and real parameter shapes

```text
file.new        {preset?:"A4"|"Letter"|…, width?, height?, pages?, facingPages?,
                 columns?, gutter?, margins?: n|{top,bottom,inside,outside}, bleed?, title?}
file.open       {path}            → {index, documentFonts, warnings[]}
file.save       {path?}           → {path, bytes}   (adds .designcraft if missing)
file.exportPdf  {path?, pages?, standard?:"none"|"x4"|"a2b", tagged?, marks?, bleed?,
                 spreads?, compressImages?, title?, author?} → {path, bytes, pages, warnings[]}

frame.create    {spread?, rect:[x0,y0,x1,y1], shape?:rectangle|ellipse|polygon,
                 content?:graphic|text|unassigned, sides?, starInset?,
                 text?, caret?:bool, vertical?:bool} → {id, story?}
frame.grid      {rect, cols, rows, gutter?, shape?, content?}

text.select     {story, anchor, focus}      # UTF-8 byte offsets
text.insert     {text, raw?:bool}           # at the caret / replaces selection
story.setText   {story, text}               # whole story
story.replaceRange {story, start, end, text}
text.thread     {from?, to?, rect?, spread?, autoflow?}
text.move       {dir:left|right|up|down|lineStart|lineEnd|storyStart|storyEnd, extend?, word?}

type.char       {attrs:{fontFamily?, fontStyle?, size?, leading?, tracking?, fill?,
                 stroke?, hScale?, vScale?, baselineShift?, capitalization?, …}}
type.para       {attrs:{align?, leftIndent?, firstLineIndent?, spaceBefore?, spaceAfter?,
                 hyphenate?, columns?, …}}
type.selectionAttrs {mixed?} → {chars:{…}, para:{…}, paragraphStyle, characterStyle, selectedText}
type.bold/italic/underline/allCaps {on?}

style.paragraph.create {name, basedOn?, nextStyle?, para?:{…}}
style.paragraph.apply  {name, clearOverrides?}
style.character.create {name, chars?:{…}}
style.character.apply  {name}

swatch.create   {name?, color:"#rrggbb"|{c,m,y,k}|[r,g,b], spot?}
swatch.create   {name?, gradient:{…}}
object.fill     {swatch?, tint?, ids?}      at least one of swatch/tint
object.stroke   {swatch?, tint?, weight?, align?:center|inside|outside, type?, ids?}
object.color    {color, target?:fill|stroke, text?, ids?}

table.insert    {rows?:body rows (4), cols?|columns?, headerRows?, footerRows?, width?}
table.get       {table?|story?, rows?, cols?} → {rows[], columns[], cells[], options{}}
table.setCell   {fill?, insets?, vj?, …}
table.sortRows  {column?:0-based, descending?, …}

layout.pages.insert {count?, after?:page index (default last), parent?}
layout.pages.delete {pages:[0-based]}
layout.pages.move   {from, to}
layout.marginsAndColumns {pages?, margins?, columns?, gutter?}
layout.parents.new  {prefix?, name?}
object.arrange  {to:front|forward|backward|back, ids?}
object.reorder  {ids?, above?|below?|index?|layer?}
transform.move  {dx, dy, ids?}
transform.set   {x?, y?, width?, height?, rotation?, shear?, ids?}
object.rename   {id|ids?, name}
```

## Measurement strings

`layout.*` dialogs/parameters accept measurement strings via the UI
(`"250 mm"`, `"3 picas"`), but the engine commands take **points**. Convert in
your client: 1 in = 72 pt, 1 mm = 2.834645669 pt, 1 pica = 12 pt.

`document.preferences {horizontalUnits, verticalUnits}` accepts
`points|picas|inches|inchesDecimal|millimeters|centimeters|ciceros|agates|pixels|q|ha`.
Invalid units are a clean error listing the valid set.

## Dialogs are commands, but not through `engine.execute`

`engine.execute` with `layout.documentSetup {}` **applies** the current settings
and returns them; it does not open a dialog. To open the dialog use the control
channel method:

```json
{"id":1,"method":"ui.menu.invoke","params":{"command":"layout.documentSetup"}}
→ {"ok":true,"result":{"dialog":"documentSetup"}}
```

Then MCP `dialog_set {field,value}`, `dialog_confirm`, `dialog_cancel`.
`ui_inspect.dialog.fields` lists the fields and their current values.
