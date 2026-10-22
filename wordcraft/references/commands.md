# WordCraft command map

633 commands in 0.9.0 across 36 namespaces. This file covers the ones you will
actually reach for, with their parameters. The complete id list is in
`command-index.md`; authoritative live parameters come from:

```sh
wordcraft-cli commands --json
```

or `list_commands({query:"..."})` over MCP. Parameter syntax below is informal:
`?` = optional, `…` = additional documented options.

## File and document

- `file.new` — `{template?: "blank|sample|letter|resume|report"}`
- `file.open` — `{path, data?: base64, password?}`
- `file.save` — `{path?, password?, markup?, format?: "wordml2003|flatopc"}`
- `file.saveAs` — `{path, password?, markup?, format?}`
- `file.exportPdf` — `{path, markup?}`
- `file.exportPng` — `{path, page?, scale?, markup?}`
- `file.printPdf` — `{path, range?, pages?, parity?, copies?, collate?, paper?}`
- `file.close` — `{force?}` (no prompt; unsaved changes error unless `force:true`)
- `file.properties` — `{title?, subject?, author?, keywords?, comments?, category?, custom?}`
- `file.info`, `file.inspect {remove?}`, `file.accessibility`
- `file.setAuthor` — `{name}`
- `file.encrypt` — `{password | null}`
- `file.protect` — `{mode: "none|readOnly|comments|trackedChanges"}` (readOnly
  blocks edits with “the document is protected (read only)”; `mode:"none"`
  unlocks; the result exposes `protection`)
- `file.versions` — `{save?: label, restore?: index}`
- `file.newFromTemplate` — `{path}`, `file.saveTemplate` — `{path}`
- `file.rename` — `{name}` (no extension)
- `document.inspect` — `{text?}`
- `document.text`, `document.selection`, `document.layout`
- `document.paragraph` — `{path:[n], story?}`
- `document.setText` — `{text}` (replaces the whole document text)

## Text, caret, selection

- `text.insert` — `{text}`
- `text.newParagraph`, `text.lineBreak`, `text.pageBreak`, `text.columnBreak`
- `text.tab`, `text.backTab`, `text.backspace`, `text.delete`,
  `text.deleteWordBack`, `text.deleteWordForward`
- `text.nbsp`, `text.nbHyphen`, `text.optionalHyphen`, `text.emDash`,
  `text.ellipsis`, `text.copyright`, `text.registered`, `text.trademark`
- `text.overtype` — `{value?}` (omitting toggles)
- `caret.left/right/up/down` — `{extend?: bool}`
- `caret.wordLeft/wordRight`, `caret.home/end`, `caret.paraUp/paraDown`,
  `caret.pageUp/pageDown`, `caret.docStart/docEnd`
- `caret.set` — `{pos, extend?}` or `{page, x, y}`
- `select.text` — `{text, occurrence?}` (1-based)
- `select.all`, `select.word`, `select.sentence`, `select.paragraph`
- `select.range` — `{anchor: Pos, focus: Pos}`
- `select.collapse`, `select.extend`, `select.similar`
- `select.line` — `{pos?}`
- `select.column` — `{anchor, focus}` or `{from:{page,x,y}, to:{page,x,y}}`
- `select.dragUnit` — `{unit, start, end, pos}`

## Character formatting

- `format.bold/italic/strikethrough` — `{value?}` (omitting toggles)
- `format.underline` — `{value?, style?}`
- `format.subscript`, `format.superscript`, `format.allCaps`, `format.smallCaps`
- `format.hidden`, `format.outline`, `format.shadow`, `format.emboss`,
  `format.engrave`
- `format.font` — `{name?, eastAsia?}`
- `format.size` — `{size}` (pt)
- `format.growFont/shrinkFont` (+`1` point variants)
- `format.color` — `{color: "RRGGBB"|"auto"}`
- `format.highlight` — `{color: "yellow|brightGreen|…|none"}`
- `format.shading` — `{color: "RRGGBB"|null}`
- `format.changeCase` — `{mode: "sentence|lower|upper|title|toggle"}`
- `format.spacing` — `{points}`, `format.scale` — `{percent}`,
  `format.position` — `{points}`
- `format.charStyle` — `{style}`
- `format.set` — `{props: CharProps}`
- `format.clear`, `format.resetChar`
- `format.state` — formatting at the selection
- `format.enclose`, `format.phonetic`, `format.textEffects`

## Paragraphs and styles

- `para.align` — `{value: "left|center|right|justify|distribute|start|end"}`
- Shortcuts: `para.alignLeft/alignCenter/alignRight/justify/distribute`
- `para.indent/outdent`, `para.hangingIndent`, `para.removeHanging`
- `para.indents` — `{left?, right?, firstLine?}` (pt; negative = hanging)
- `para.spacing` — `{before?, after?, beforeAuto?, afterAuto?}`
- `para.lineSpacing` — `{value}` (multiple) or `{atLeast}` / `{exactly}`
- `para.single/double/oneAndHalf`
- `para.style` — `{style}` (name or id)
- `para.heading1/2/3`, `para.normal`
- `para.bullets` — `{kind?: "bullet"|char, off?}`
- `para.numbering` — `{kind?: "numbered|numberedParen|upperLetter|lowerLetter|lowerRoman|outline", off?}`
- `para.multilevel` — `{kind?: "legal|outline"}`
- `para.listLevel` — `{level: 0-8}`
- `para.restartNumbering`, `para.setNumberingValue` — `{value}`
- `para.moveUp/moveDown`, `para.promote/demote`
- `para.shading` — `{color}`
- `para.borders` — `{kind, width?, color?, style?}`
- `para.tabs` — `{tabs?, set?, clear?, clearAll?}`
- `para.keepNext/keepLines/pageBreakBefore/widowControl` — `{value?}`
- `para.rtl`, `para.ltr`, `para.outlineLevel`, `para.set` — `{props, onPage?}`
- `para.sort` — `{descending?}`, `para.reset`, `para.dialog`
- `styles.create` — `{name, basedOn?, fromSelection?}`
- `styles.modify` — `{style, chr?, para?, name?, next?}`
- `styles.apply` — `{style?}`, `styles.list`, `styles.pane`
- `styles.updateToMatch` — `{style?}`, `styles.rename` — `{style, name}`
- `styles.delete` — `{style}`, `styles.inspect`, `styles.inspector`
- `styles.organizer` — `{path?, data?}`, `styles.copyFrom` — `{path, data?, styles}`

## Tables

- `insert.table` — `{rows, cols, style?}` (default style usually `TableGrid`)
- `table.style` — `{style}`
- `table.look` — `{headerRow?, totalRow?, bandedRows?, firstColumn?, lastColumn?, bandedColumns?}`
- `table.insertRowAbove/insertRowBelow`, `table.insertColumnLeft/insertColumnRight`
- `table.deleteRow/deleteColumn/deleteTable/deleteCells`
- `table.merge`, `table.split` — `{columns?, rows?, mergeFirst?}` (0.9.0: a
  split of a row-merged cell can leave extra empty cells; inspect `cells`)
- `table.splitTable`, `table.selectTable/Row/Column/Cell`
- `table.shading` — `{color}`
- `table.borders` — `{kind: "all|outside|inside|none|top|bottom|left|right", width?, color?, style?}`
- `table.cellAlign` — `{value:"topLeft|…|bottomRight"}`
- `table.cellMargins` — `{top?, left?, bottom?, right?}`
- `table.autofit` — `{mode:"contents|window|fixed"}`
- `table.columnWidth` — `{width}`, `table.rowHeight` — `{height, rule?}`
- `table.distributeColumns/Rows`
- `table.repeatHeader`, `table.altText` — `{text?, title?}`
- `table.sort` — `{column?, descending?, header?}`
- `table.formula` — `{formula?: "=SUM(ABOVE)"}` (returns the computed result,
  e.g. `"30"`; insert it in the target cell)
- `table.toText` — `{separator}`, `table.fromText` — `{separator?, char?, columns?, …}`
- `table.quick` — `{kind:"calendar|tabular|matrix"}`
- `table.newStyle` / `table.modifyStyle` — `{name?, basedOn?, <part>: {chr?, para?}}`
- `table.properties` — `{align?, rtl?, width?, widthPct?, indent?}`
- Drawing helpers: `table.draw`, `table.eraser`, `table.resizeDrag`,
  `table.selectAt`, `table.insertAt`, `table.moveDrag`, `table.fitColumn`

## Insert

- `insert.picture` — `{path?|data?, width?, alt?}`
- `arrange.wrap` — `{wrap:"inline|square|tight|through|topAndBottom|behindText|inFrontOfText"}`;
  `arrange.wrapText` — `{side:"bothSides|left|right|largest"}` (a floating picture
  makes text flow around it; `side` is the text side)
- `insert.shape` — `{kind, …}`; `insert.textBox` — `{text?, width?, height?}`
  (a text box becomes the active story; return with `caret.set` before body edits)
- `insert.icon` — `{id?, color?, size?, query?}`
- `insert.link` — `{url | bookmark | heading | top}`, `insert.removeLink`
- `insert.bookmark` / `insert.deleteBookmark` — `{name}`
- `insert.header` / `insert.footer` — `{text?, preset?}`
- `insert.editHeader/Footer` — `{page?}`; `insert.createHeader/Footer`;
  `insert.closeHeader`, `insert.removeHeader/Footer`
- `insert.pageNumber` — `{position?: "top|bottom|current", align?, format?: "x of y"}`
  (current section only; `layout.pageNumberFormat {start}` restarts numbering.
  `x of y` uses `NUMPAGES`, which counts an unnumbered cover section)
- `insert.dateTime` — `{format?, update?}`, `insert.dateField`, `insert.timeField`,
  `insert.pageField`
- `insert.field` — `{instr, result?}` (body `PAGE`/`SECTIONPAGES` results can
  stay empty until a PDF export with `--update-fields`; `SECTIONPAGES` gives a
  body-only total when the cover is a separate section)
- `insert.symbol` — `{char, font?}`
- `insert.dropCap` — `{position?, lines?}`
- `insert.horizontalLine`, `insert.blankPage`, `insert.coverPage` — `{title?, subtitle?, author?}`
  (0.9.0: `coverPage` can spill onto extra pages; build a manual title page when
  the cover must be exactly one page)
- `insert.textFromFile` — `{path}`
- `insert.equation` — `{linear?|latex?|builtin?}`
- `insert.crossReference` — `{to, …}`
- `insert.smartArt` — `{layout?, items?}`
- `insert.chart` — `{type?, data?}`
  (chart/SmartArt/WordArt stay selected after insertion; collapse with
  `caret.docEnd` before Enter/typing or the next paragraph replaces them)
- `insert.canvas` — `{width?, height?, fill?}`
- `insert.wordArt` — `{text?, style?, transform?}` (style is a WordArt/text-effect
  name such as `solid` or `outlined`; `style1` is rejected)
- `insert.quickParts`, `insert.autoText`
- `insert.docProperty` — `{name}`
- `insert.signatureLine` — `{signer?, title?}`
- `insert.object` — `{path}`, `insert.spreadsheet` — `{csv?}`
- `insert.pageBreak`, `insert.blankPage`

## References

- `references.toc` — `{levels?, title?, pageNumbers?, rightAlign?, tabLeader?, hyperlinks?, headingStyles?, outlineLevels?, tcFields?, styleLevels?}`
  (`{}` updates an existing TOC)
- `references.updateToc`, `references.removeToc`
- `references.addText` — `{level: 0|1-9}`
- `references.footnote` / `references.endnote` — `{text?, mark?}`
- `references.convertNotes` — `{to}`, `references.nextFootnote`, `references.notes`
- `references.caption` — `{label?, text?, position?}`
- `references.sources` — `{add?, remove?, import?}`
- `references.citation` — `{tag?, source?, pages?}`
  (`source`: `{tag, kind, author, title, year, publisher, city, journal,
  volume, issue, pages, url, …}`; set the style first; it inserts at the caret
  with no leading space)
- `references.citationStyle` — `{style:"APA|MLA|Chicago|IEEE|…"}`
- `references.bibliography` — `{title?}`
- `references.tableOfFigures` — `{label?}`, `references.updateFigures`
- `references.markCitation` — `{entry?}`
- `references.tableOfAuthorities`, `references.updateAuthorities`
- `references.noteOptions` — `{kind?, pos?, …}`
- `references.researcher`
- `references.markEntry` — `{entry?, subentry?, crossReference?, bookmark?}`
- `references.index` — `{type?, columns?, rightAlign?, tabLeader?}`
- `references.updateIndex`

## Review

- `review.trackChanges` — `{value?}` (omit to toggle; pass `true` explicitly)
- `review.newComment` — `{text}` (selection is the anchor; returns `{id}`)
- `review.reply` / `review.editComment` — `{id, text}` (`inspect_document`'s
  `comments` is a count, not a list — use the id returned by `newComment`)
- `review.deleteComment` — `{id?|all?}`, `review.resolveComment`
- `review.nextComment` / `previousComment`, `review.comments`
- `review.accept`/`review.reject`, `review.acceptAll`/`review.rejectAll`
- `review.nextChange` / `previousChange`
- `review.markup`, `review.showMarkup`, `review.changes`
- `review.trackingOptions` — `{comments?, ink?, insertionsDeletions?, formatting?, balloons?, commentDisplay?, insertMark?, insertColor?, deleteMark?, deleteColor?, changedLines?, trackFormatting?, moveFromMark?, moveToMark?, trackMoves?}`
- `review.wordCount` — `{includeTextBoxes?}`
- `review.spelling`, `review.issues`, `review.suggestions` — `{pos?}`
- `review.addToDictionary` — `{word?}`, `review.ignoreAll`,
  `review.applySuggestion` — `{text}`
- `review.proofing`, `review.thesaurus`, `review.language` — `{lang?, noProof?, detect?}`
- `review.compare` / `review.combine` — `{path?|text?, original?, author?, caseChanges?, whiteSpace?, formatting?, level?, showIn?, …}`
- `review.restrict` — `{mode: "none|readOnly|comments|trackedChanges|forms"}`
- `review.readAloud`, `review.editor`, `review.hideInk`

## Mail merge

- `mailings.start` — `{kind:"letters|emails|envelopes|labels|directory|normal"}`
- `mailings.recipients` — `{csv?|path?|data?, encoding?, sheet?, headers?, rows?, fields?}`
  (CSV/TSV/TXT or XLSX/XLSM/XLS/ODS)
- `mailings.editRecipients`, `mailings.filterRecipients`, `mailings.sortRecipients`
- `mailings.insertField` — `{field}`
- `mailings.addressBlock`, `mailings.greetingLine`, `mailings.rules`
- `mailings.matchFields`, `mailings.highlightFields`
- `mailings.preview`, `mailings.next/previous`, `mailings.findRecipient`
- `mailings.checkErrors`
- `mailings.finish` — `{path?, from?, to?}`
- `mailings.envelopes` — `{delivery, return?, size?}` (creates an envelope-sized
  page, e.g. #10 = 684×297 pt, and places the return/delivery blocks)
- `mailings.labels` — `{text?, product?, fromRecipients?}` (with recipients and
  `fromRecipients:true`, fills the label table; it lays out an address block,
  so add a Name field manually if the name must print)

## Layout and design

- `layout.margins` — `{preset?, top?, bottom?, left?, right?, gutter?}`
- `layout.orientation` — `{value:"portrait|landscape"}`
- `layout.size` — `{name?, width?, height?}`
- `layout.columns` — `{count, space?, separator?, preset?, widths?}`
- `layout.break` — `{kind:"page|column|textWrapping|nextPage|continuous|evenPage|oddPage"}`
  (`continuous` starts a new section without a page break; `layout.columns
  {count, space, separator, apply:"section"}` then affects that section only)
- `layout.lineNumbers` — `{value, start?, countBy?, restart?}`
- `layout.hyphenation` — `{value?, zone?, caps?}`
- `layout.manualHyphenation` — `{from?}`
- `layout.verticalAlign` — `{value:"top|center|justify|bottom"}`
- `layout.pageSetup` — `{section}` (replaces the whole section)
- `layout.differentFirstPage`, `layout.differentOddEven`, `layout.linkToPrevious`
  (0.9.0: odd/even does not create separate `even` header/footer parts;
  `insert.createHeader/Footer {page:1}` appends to the default part — verify PDF)
- `layout.pageNumberFormat` — `{format?, start?}`
- `layout.textDirection`, `layout.sectionRtl`, `layout.documentGrid`
- `design.theme` — `{name}`, `design.themeFonts` — `{heading, body?}`
- `design.themeColors`, `design.themes`
- `design.styleSet` — `{name:"default|basic|lines|shaded|casual|centered|minimalist|title"}`
- `design.paragraphSpacing` — `{value:"default|none|compact|tight|open|relaxed|double"}`
- `design.watermark` — `{text?, remove?, diagonal?, color?}`
- `design.pageColor` — `{color|null}`
- `design.pageBorders` — `{kind?, width?, color?, style?}`
- `design.setDefault`, `design.effects`

## View and UI

- `view.zoom` — `{value: percent|"pageWidth"|"onePage"|"multiplePages"}`
- `view.zoom100/zoomIn/zoomOut`, `view.onePage/multiplePages/pageWidth`
- `view.printLayout`, `view.webLayout`, `view.draft`, `view.outline`,
  `view.readMode`
- `view.marks`, `view.ruler`, `view.gridlines`, `view.navigationPane`,
  `view.stylesPane`, `view.commentsPane`
- `view.darkMode`, `view.interfaceTheme` — `{value?:"light|dark|system"}`
- `view.fullScreen` — `{value?}`, `view.focus`, `view.split`, `view.newWindow`
- `view.state`, `view.fieldCodes`, `view.numeral`, `view.vertical`
- `view.readColumnWidth`, `view.readTextSize`, `view.readLineSpacing`
- `view.hideWhiteSpace`, `view.immersive`, `view.sideToSide`

## Tools, macros, fields

- `tools.recordMacro` — `{name?}` (call again to stop)
- `tools.macros` — `{run?|define?:{name, steps}|delete?}`
- `tools.search` — `{query?}` → command matches
- `tools.autocorrect`, `tools.customizeKeyboard`, `tools.customizeRibbon`
- `tools.templates`, `tools.attachTemplate` — `{path, linkStyles?, update?}`,
  `tools.detachTemplate`, `tools.linkStyles`, `tools.updateStyles`
- `fields.toggleCode`, `fields.setCode` — `{code}`, `fields.unlink`,
  `fields.lock/unlock`, `fields.next/previous`, `fields.selected`
- `format.textEffects`, `insert.wordArt`, `wordArt.*`
- Equation namespace (`equation.*`, 20 commands), charts (`chart.*`, 5),
  SmartArt (`smartArt.*`, 8), drawing (`draw.*`, 16), outline (`outline.*`, 26)
  — use `list_commands({query:"equation"})` etc. for exact ids.

## Position-taking commands

Many commands act on the selection, not an explicit position. To be precise,
move/select first:

```json
{"command":"caret.set","params":{"pos":{"story":"body","path":[3],"off":12}}}
{"command":"select.range","params":{"anchor":{…},"focus":{…}}}
```

Table cell positions: `path:[tableBlock, row, col, cellBlock]`.

## Mutating vs read-only

`wordcraft-cli commands --json` marks each command with `mutates`. Use it to
filter for safe inspection commands. MCP tools also carry `readOnlyHint` where
applicable.
