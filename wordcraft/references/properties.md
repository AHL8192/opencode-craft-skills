# WordCraft document properties and positions

## Positions

```json
{"story": "body" | {"part": 0}, "path": [block, row, cell, block, …], "off": 123}
```

- `story`: `"body"` or `{"part": n}` for headers, footers, footnotes, endnotes,
  comments, text boxes.
- `path`: block index in the story; for a table cell, add `row`, `cell`, then
  the block index inside that cell.
- `off`: byte offset within the block's text.

Commands that take a position: `caret.set`, `select.range`, `select.dragUnit`,
`select.column`, `select.line`, `select.addObject`, `document.paragraph`, etc.

`caret.set` also accepts `{"page": n, "x": pt, "y": pt}` for a page coordinate.

## Units, colours, defaults

- All lengths are **points** (1/72 inch): sizes, indents, spacing, tab stops,
  borders, object positions.
- Colour: `"RRGGBB"`, `"#RRGGBB"`, `[r,g,b]` (0–255), or `"Auto"`.
  `Auto` is black on light backgrounds and white on dark; it reads back as
  `"Auto"` or `{"Rgb": …}`.
- Every property is optional. Omitted fields keep what the style chain gives.
- **Unknown field names are ignored, not rejected.** A typo silently does
  nothing, so verify with `format.state`/`inspect_document`.
- `format.set` also copies `size`, `bold`, `italic` to the complex-script
  properties when those are not given.

## CharProps

Used by `format.set`, `styles.modify` (`chr`) and table-style parts.

| Field | Type | Values |
|---|---|---|
| `style` | string | character style id |
| `font` | string | font family |
| `size` | number | points |
| `bold`, `italic`, `strike`, `doubleStrike`, `caps`, `smallCaps`, `hidden`, `outline`, `shadow`, `emboss`, `engrave`, `noProof` | bool | |
| `underline` | string | `none`, `single`, `words`, `double`, `thick`, `dotted`, `dash`, `dotDash`, `dotDotDash`, `wave`, `doubleWave` |
| `underlineColor` | colour | |
| `color` | `"Auto"`, colour, or `{"Rgb": colour}` | |
| `highlight` | string | `none`, `yellow`, `brightGreen`, `turquoise`, `pink`, `blue`, `red`, `darkBlue`, `teal`, `green`, `violet`, `darkRed`, `darkYellow`, `gray50`, `gray25`, `black`, `white` |
| `shading` | colour | background fill |
| `border` | Border | character border; `{"style":"none"}` explicitly removes |
| `vertAlign` | string | `baseline`, `superscript`, `subscript` |
| `spacing` | number | character spacing, pt (negative condenses) |
| `scale` | number | horizontal scale percent (100 = normal) |
| `position` | number | raised (+) / lowered (−), pt |
| `kern` | number | kern at or above this size, pt; 0 = off |
| `textEffects` | object | WordArt `fill`, `outline`, `shadow`, `glow`, `reflection` |
| `lang` | string | BCP 47 proofing language |
| `rtl` | bool | right-to-left run |
| `cs` | bool | apply to complex-script properties |
| `fontCs`, `fontEa` | string | complex-script / East Asian font |
| `sizeCs` | number | complex-script size, pt |
| `boldCs`, `italicCs` | bool | complex-script bold/italic |
| `langBidi` | string | complex-script language, e.g. `fa-IR` |
| `link` | string | hyperlink target: URL or `#bookmark` |
| `ins`, `del`, `fmtChange` | | Track Changes bookkeeping (revision indexes) |

## ParaProps

Used by `para.set`, `styles.modify` (`para`) and table-style parts.

| Field | Type | Values |
|---|---|---|
| `style` | string | paragraph style id |
| `align` | string | `left`, `center`, `right`, `justify`, `distribute` (`left` is the start edge; right in RTL) |
| `indentLeft`, `indentRight` | number | points |
| `indentFirst` | number | first-line indent, pt; negative = hanging |
| `indentLeftChars`, `indentRightChars`, `indentFirstChars` | number | same indents in characters; non-zero wins over points, 0 cancels an inherited one |
| `spaceBefore`, `spaceAfter` | number | points |
| `lineSpacing` | object | `{"rule":"multiple","value":1.15}` (1 single, 2 double), `{"rule":"atLeast","value":pt}`, `{"rule":"exactly","value":pt}` |
| `contextualSpacing` | bool | ignore space between same-style paragraphs |
| `mirrorIndents` | bool | swap left/right indents on even pages |
| `keepNext`, `keepLines`, `pageBreakBefore`, `widowControl` | bool | |
| `outlineLevel` | integer | 0–8 = Level 1–9; 9 = body text |
| `numbering` | object | `{"num":n,"level":n}`, both required; level is 0-based; `num:0` removes numbering the style gives |
| `tabs` | array | `[{"pos":pt,"align"?:"left\|center\|right\|decimal\|bar\|clear","leader"?:"none\|dot\|hyphen\|underscore\|middleDot"}]`; replaces inherited stops; `clear` removes one at `pos` |
| `shading` | colour | background fill |
| `borders` | object | `{"top","left","bottom","right","between"}` each a Border; `inside_v` is used by tables |
| `suppressHyphens`, `suppressLineNumbers` | bool | |
| `bidi` | bool | right-to-left paragraph |
| `dropCap` | integer | lines to drop; 0 = none |
| `kinsoku`, `wordWrap`, `overflowPunct`, `autoSpaceDE`, `autoSpaceDN`, `snapToGrid` | bool | East Asian typography; unset = on |
| `topLinePunct` | bool | East Asian typography; unset = off |
| `numChange`, `fmtChange` | | Track Changes bookkeeping |

`para.set` additionally accepts:

```json
{"props": {…}, "onPage": {"align":"left|center|right|justify|distribute",
                          "left": 72, "right": 72}}
```

`onPage` is the alignment/indents as seen on the page; each selected paragraph
converts them to its own start/end after `props` (e.g. `bidi`) is applied. The
Paragraph dialog sends only changed fields this way, as one undo step.

## Border

```json
{"style":"single","width":1,"color":"999999","space":1}
```

- Missing fields mean `none`, 0, no colour, 0.
- A border needs `width > 0` to show.
- `style`: `none`, `single`, `double`, `dotted`, `dashed`, `thick`, `triple`,
  `dotDash`, `wave`.
- `space` is distance from the text, pt.

## Track Changes fields

`ins`, `del`, `fmtChange`, `numChange` are internal revision indexes. Do not
invent them. Use `review.trackChanges` and normal edits; the engine records the
revision bookkeeping. `review.accept`/`reject` and `review.acceptAll`/
`rejectAll` are the supported ways to resolve markup.

## Table styles

`table.newStyle` / `table.modifyStyle` accept a `para` and character properties
per table part. Part names include:

`wholeTable`, `headerRow`, `totalRow`, `firstColumn`, `lastColumn`,
`bandedRows`, `bandedColumns`, `nwCell` (north-west corner), and the edge/corner
cell names used by `table.modifyStyle`.

`table.look` toggles `headerRow`, `totalRow`, `bandedRows`, `firstColumn`,
`lastColumn`, `bandedColumns`.

## Section properties

`layout.pageSetup {"section": SectionProps}` replaces the **whole section**,
including headers and footers. To change a few fields safely, read the current
section from `inspect_document` (`sections[n].props`), modify only those fields,
and send the whole object back. `inspect_document` exposes margins, page size,
orientation, columns, gutter, header/footer distances, titlePage, valign,
page-number format, borders, line numbers and RTL.

## Checking formatting

- `format.state` — character formatting at the selection.
- `document.paragraph {"path":[n]}` — paragraph details.
- `styles.inspect` — styles at the selection.
- `inspect_document` — blocks with style and runs.
- `document.inspect` — same structure through a command.
