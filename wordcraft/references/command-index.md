# WordCraft command index — 0.9.0

Snapshot generated from the installed `wordcraft-cli commands --json` on 2026-10-21.
633 commands in 36 namespaces. Parameter schemas are intentionally omitted;
get them live with `wordcraft-cli commands --json` or `list_commands({query})`.
Commands marked **M** mutate the document (the `mutates` flag).

## text (22)

- `text.insert` — Type Text — *M*
- `text.newParagraph` — New Paragraph — *Enter, M*
- `text.lineBreak` — Line Break — *Shift+Enter, M*
- `text.pageBreak` — Page Break — *Mod+Enter, M*
- `text.columnBreak` — Column Break — *Mod+Shift+Enter, M*
- `text.tab` — Tab — *Tab, M*
- `text.backTab` — Shift+Tab — *Shift+Tab, M*
- `text.backspace` — Backspace — *Backspace, M*
- `text.delete` — Delete — *Delete, M*
- `text.deleteWordBack` — Delete Previous Word — *Mod+Backspace / Alt+Backspace, M*
- `text.deleteWordForward` — Delete Next Word — *Mod+Delete / Alt+Delete, M*
- `text.nbsp` — Nonbreaking Space — *Mod+Shift+Space, M*
- `text.nbHyphen` — Nonbreaking Hyphen — *Mod+Shift+-, M*
- `text.optionalHyphen` — Optional Hyphen — *Mod+-, M*
- `text.toggleUnicode` — Toggle Unicode Character — *Alt+X, M*
- `text.typeCode` — Type Character Code — *M*
- `text.emDash` — Em Dash — *Mod+Alt+-, M*
- `text.copyright` — Copyright Sign — *Mod+Alt+C, M*
- `text.registered` — Registered Sign — *Mod+Alt+R, M*
- `text.trademark` — Trademark Sign — *Mod+Alt+T, M*
- `text.ellipsis` — Ellipsis — *Mod+Alt+., M*
- `text.overtype` — Overtype

## caret (16)

- `caret.left` — Left — *Left*
- `caret.right` — Right — *Right*
- `caret.up` — Up — *Up*
- `caret.down` — Down — *Down*
- `caret.wordLeft` — Word Left — *Mod+Left / Alt+Left*
- `caret.wordRight` — Word Right — *Mod+Right / Alt+Right*
- `caret.home` — Line Start — *Home*
- `caret.end` — Line End — *End*
- `caret.paraUp` — Paragraph Up — *Mod+Up / Alt+Up*
- `caret.paraDown` — Paragraph Down — *Mod+Down / Alt+Down*
- `caret.docStart` — Document Start — *Mod+Home*
- `caret.docEnd` — Document End — *Mod+End*
- `caret.pageUp` — Page Up — *PageUp*
- `caret.pageDown` — Page Down — *PageDown*
- `caret.set` — Set Caret
- `caret.pastCitation` — Move Past Citation

## select (14)

- `select.all` — Select All — *Mod+A*
- `select.range` — Select Range
- `select.word` — Select Word
- `select.sentence` — Select Sentence
- `select.paragraph` — Select Paragraph
- `select.dragUnit` — Extend Selection by Units
- `select.line` — Select Line
- `select.text` — Select Text
- `select.collapse` — Collapse Selection — *Escape*
- `select.column` — Column Selection — *Mod+Shift+F8*
- `select.addObject` — Add Object to Selection
- `select.objects` — Select Objects
- `select.similar` — Select Text with Similar Formatting
- `select.extend` — Extend Selection — *F8*

## edit (31)

- `edit.undo` — Undo — *Mod+Z*
- `edit.undoTo` — Undo Actions
- `edit.undoHistory` — Undo History
- `edit.redo` — Redo — *Mod+Y / Mod+Shift+Z*
- `edit.cut` — Cut — *Mod+X, M*
- `edit.copy` — Copy — *Mod+C / Mod+Insert*
- `edit.spike` — Spike — *Mod+F3, M*
- `edit.insertSpike` — Insert Spike — *Mod+Shift+F3, M*
- `edit.paste` — Paste — *Mod+V / Shift+Insert, M*
- `edit.pasteText` — Paste: Keep Text Only — *Mod+Shift+Alt+V, M*
- `edit.pasteMerge` — Paste: Merge Formatting — *M*
- `edit.clipboardPane` — Clipboard Pane
- `edit.clipboardItems` — Clipboard Items
- `edit.pasteClipboardItem` — Paste Clipboard Item — *M*
- `edit.pasteAllClipboard` — Paste All — *M*
- `edit.deleteClipboardItem` — Delete Clipboard Item
- `edit.clearClipboard` — Clear All
- `edit.find` — Find — *Mod+F*
- `edit.advancedFind` — Advanced Find
- `edit.findNext` — Find Next — *Mod+G / F3 / Shift+F4 / Mod+PageDown*
- `edit.findPrevious` — Find Previous — *Mod+PageUp*
- `edit.replace` — Replace — *M*
- `edit.findReplace` — Find and Replace — *Mod+H*
- `edit.replaceAll` — Replace All — *M*
- `edit.goto` — Go To — *Mod+Alt+G / F5*
- `edit.goBack` — Go Back — *Shift+F5 / Mod+Alt+Z*
- `edit.formatPainter` — Format Painter
- `edit.copyFormat` — Copy Formatting — *Mod+Shift+C*
- `edit.pasteFormat` — Paste Formatting — *Mod+Shift+V, M*
- `edit.pasteSpecial` — Paste Special — *Mod+Alt+V, M*
- `edit.repeat` — Repeat — *F4*

## format (39)

- `format.bold` — Bold — *Mod+B, M*
- `format.italic` — Italic — *Mod+I, M*
- `format.underline` — Underline — *Mod+U, M*
- `format.doubleUnderline` — Double Underline — *Mod+Shift+D, M*
- `format.wordUnderline` — Underline Words Only — *Mod+Shift+W, M*
- `format.strikethrough` — Strikethrough — *Mod+Shift+X, M*
- `format.border` — Character Border — *M*
- `format.doubleStrikethrough` — Double Strikethrough — *M*
- `format.subscript` — Subscript — *Mod+=, M*
- `format.superscript` — Superscript — *Mod+Shift+=, M*
- `format.allCaps` — All Caps — *Mod+Shift+A, M*
- `format.smallCaps` — Small Caps — *Mod+Shift+K, M*
- `format.hidden` — Hidden — *Mod+Shift+H, M*
- `format.outline` — Outline — *M*
- `format.shadow` — Shadow — *M*
- `format.emboss` — Emboss — *M*
- `format.engrave` — Engrave — *M*
- `format.font` — Font — *Mod+Shift+F, M*
- `format.size` — Font Size — *Mod+Shift+P, M*
- `format.growFont` — Increase Font Size — *Mod+Shift+. / Mod+Shift+>, M*
- `format.shrinkFont` — Decrease Font Size — *Mod+Shift+, / Mod+Shift+<, M*
- `format.growFont1` — Grow Font 1 Point — *Mod+], M*
- `format.shrinkFont1` — Shrink Font 1 Point — *Mod+[, M*
- `format.color` — Font Color — *M*
- `format.highlight` — Text Highlight Color — *Mod+Alt+H, M*
- `format.shading` — Character Shading — *M*
- `format.changeCase` — Change Case — *Shift+F3, M*
- `format.clear` — Clear All Formatting — *M*
- `format.resetChar` — Reset Character Formatting — *Mod+Space, M*
- `format.spacing` — Character Spacing — *M*
- `format.scale` — Character Scale — *M*
- `format.position` — Character Position — *M*
- `format.charStyle` — Apply Character Style — *M*
- `format.set` — Set Character Formatting — *M*
- `format.fontDialog` — Font Dialog — *Mod+D*
- `format.enclose` — Enclose Characters — *M*
- `format.state` — Formatting at Selection
- `format.phonetic` — Phonetic Guide — *M*
- `format.textEffects` — Text Effects — *M*

## font (4)

- `font.add` — Add Font…
- `font.list` — Added Fonts
- `font.remove` — Remove Added Font
- `font.loadSystem` — Load System Installed Fonts…

## para (50)

- `para.alignLeft` — Align Left — *Mod+L, M*
- `para.alignCenter` — Center — *Mod+E, M*
- `para.alignRight` — Align Right — *Mod+R, M*
- `para.justify` — Justify — *Mod+J, M*
- `para.distribute` — Distributed — *Mod+Shift+J, M*
- `para.align` — Alignment — *M*
- `para.rtl` — Right-to-Left Text Direction — *M*
- `para.ltr` — Left-to-Right Text Direction — *M*
- `para.indent` — Increase Indent — *Mod+M, M*
- `para.outdent` — Decrease Indent — *Mod+Shift+M, M*
- `para.hangingIndent` — Hanging Indent — *Mod+T, M*
- `para.removeHanging` — Reduce Hanging Indent — *Mod+Shift+T, M*
- `para.indents` — Indents — *M*
- `para.lineSpacing` — Line and Paragraph Spacing — *M*
- `para.single` — Single Spacing — *Mod+1, M*
- `para.double` — Double Spacing — *Mod+2, M*
- `para.oneAndHalf` — 1.5 Line Spacing — *Mod+5, M*
- `para.spacing` — Paragraph Spacing — *M*
- `para.addSpaceBefore` — Add Space Before Paragraph — *Mod+0, M*
- `para.removeSpaceAfter` — Remove Space After Paragraph — *M*
- `para.reset` — Reset Paragraph Formatting — *Mod+Q, M*
- `para.style` — Apply Style — *M*
- `para.normal` — Normal Style — *Mod+Shift+N, M*
- `para.heading1` — Heading 1 — *Mod+Alt+1, M*
- `para.heading2` — Heading 2 — *Mod+Alt+2, M*
- `para.heading3` — Heading 3 — *Mod+Alt+3, M*
- `para.bullets` — Bullets — *Mod+Shift+L, M*
- `para.numbering` — Numbering — *M*
- `para.multilevel` — Multilevel List — *M*
- `para.listLevel` — Change List Level — *M*
- `para.restartNumbering` — Restart at 1 — *M*
- `para.moveUp` — Move Paragraph Up — *Alt+Shift+Up, M*
- `para.moveDown` — Move Paragraph Down — *Alt+Shift+Down, M*
- `para.promote` — Promote — *Alt+Shift+Left, M*
- `para.demote` — Demote — *Alt+Shift+Right, M*
- `para.shading` — Shading — *M*
- `para.borders` — Borders — *M*
- `para.sort` — Sort — *M*
- `para.keepNext` — Keep with Next — *M*
- `para.keepLines` — Keep Lines Together — *M*
- `para.pageBreakBefore` — Page Break Before — *M*
- `para.widowControl` — Widow/Orphan Control — *M*
- `para.asianTypography` — Asian Typography — *M*
- `para.tabs` — Tabs — *M*
- `para.outlineLevel` — Outline Level — *M*
- `para.set` — Set Paragraph Formatting — *M*
- `para.dialog` — Paragraph Settings
- `para.setNumberingValue` — Set Numbering Value — *M*
- `para.defineBullet` — Define New Bullet — *M*
- `para.defineNumber` — Define New Number Format — *M*

## styles (16)

- `styles.create` — Create a Style — *M*
- `styles.modify` — Modify Style — *M*
- `styles.updateToMatch` — Update Style to Match Selection — *M*
- `styles.delete` — Delete Style — *M*
- `styles.manage` — Manage Styles
- `styles.setVisibility` — Show or Hide Style — *M*
- `styles.list` — Styles
- `styles.pane` — Styles Pane — *Mod+Alt+Shift+S*
- `styles.apply` — Apply Styles — *Mod+Shift+S*
- `styles.addToGallery` — Add to Style Gallery — *M*
- `styles.inspector` — Style Inspector — *Shift+F1*
- `styles.inspect` — Inspect Styles at Selection
- `styles.inspectorClear` — Clear Formatting Level — *M*
- `styles.organizer` — Organizer
- `styles.copyFrom` — Copy Styles — *M*
- `styles.rename` — Rename Style — *M*

## list (3)

- `list.define` — Define New Multilevel List — *M*
- `list.get` — List Definition
- `list.multilevelPreset` — Multilevel List Library — *M*

## view (36)

- `view.marks` — Show/Hide ¶ — *Mod+Shift+8 / Mod+8*
- `view.printLayout` — Print Layout — *Mod+Alt+P*
- `view.webLayout` — Web Layout
- `view.draft` — Draft — *Mod+Alt+N*
- `view.outline` — Outline — *Mod+Alt+O*
- `view.readMode` — Read Mode
- `view.readColumnWidth` — Reading Column Width
- `view.readTextSize` — Reading Text Size
- `view.readLineSpacing` — Reading Line Spacing
- `view.hideWhiteSpace` — Hide White Space
- `view.focus` — Focus
- `view.ruler` — Ruler
- `view.gridlines` — Gridlines
- `view.navigationPane` — Navigation Pane
- `view.zoom` — Zoom
- `view.zoom100` — 100%
- `view.zoomIn` — Zoom In
- `view.zoomOut` — Zoom Out
- `view.onePage` — One Page
- `view.multiplePages` — Multiple Pages
- `view.pageWidth` — Page Width
- `view.darkMode` — Switch Modes
- `view.interfaceTheme` — Interface Theme
- `view.stylesPane` — Styles Pane
- `view.commentsPane` — Comments Pane
- `view.accessibilityPane` — Accessibility Pane
- `view.altTextPane` — Alt Text Pane
- `view.newWindow` — New Window
- `view.split` — Split — *Mod+Alt+S*
- `view.fullScreen` — Full Screen — *F11*
- `view.state` — View State
- `view.numeral` — Numerals
- `view.fieldCodes` — Field Codes — *Alt+F9*
- `view.immersive` — Immersive Reader
- `view.vertical` — Vertical
- `view.sideToSide` — Side to Side

## table (48)

- `table.viewGridlines` — View Gridlines
- `table.insertRowAbove` — Insert Above — *M*
- `table.insertRowBelow` — Insert Below — *M*
- `table.insertColumnLeft` — Insert Left — *M*
- `table.insertColumnRight` — Insert Right — *M*
- `table.deleteRow` — Delete Rows — *M*
- `table.deleteColumn` — Delete Columns — *M*
- `table.deleteTable` — Delete Table — *M*
- `table.deleteCells` — Delete Cells — *M*
- `table.merge` — Merge Cells — *M*
- `table.split` — Split Cells — *M*
- `table.splitTable` — Split Table — *M*
- `table.style` — Table Styles — *M*
- `table.look` — Table Style Options — *M*
- `table.shading` — Shading — *M*
- `table.borders` — Borders — *M*
- `table.cellAlign` — Alignment — *M*
- `table.textDirection` — Text Direction — *M*
- `table.autofit` — AutoFit — *M*
- `table.distributeColumns` — Distribute Columns — *M*
- `table.distributeRows` — Distribute Rows — *M*
- `table.columnWidth` — Table Column Width — *M*
- `table.rowHeight` — Table Row Height — *M*
- `table.repeatHeader` — Repeat Header Rows — *M*
- `table.altText` — Alt Text — *M*
- `table.sort` — Sort — *M*
- `table.toText` — Convert to Text — *M*
- `table.formula` — Formula — *M*
- `table.selectTable` — Select Table
- `table.selectRow` — Select Row
- `table.selectColumn` — Select Column
- `table.selectCell` — Select Cell
- `table.rtl` — Right-to-Left Table — *M*
- `table.properties` — Properties — *M*
- `table.fromText` — Convert Text to Table — *M*
- `table.quick` — Quick Tables — *M*
- `table.newStyle` — New Table Style — *M*
- `table.modifyStyle` — Modify Table Style — *M*
- `table.deleteStyle` — Delete Table Style — *M*
- `table.draw` — Draw Table — *M*
- `table.eraser` — Eraser — *M*
- `table.resizeDrag` — Resize Table by Dragging — *M*
- `table.selectAt` — Select Table Cells by Clicking
- `table.insertAt` — Insert Row or Column by Clicking — *M*
- `table.moveDrag` — Move Table by Dragging — *M*
- `table.fitColumn` — AutoFit Column by Double-Clicking — *M*
- `table.cellMargins` — Cell Margins — *M*
- `table.borderPainter` — Border Painter — *M*

## outline (26)

- `outline.promoteToHeading1` — Promote to Heading 1 — *M*
- `outline.promote` — Promote — *M*
- `outline.demote` — Demote — *M*
- `outline.demoteToBody` — Demote to Body Text — *M*
- `outline.level` — Outline Level — *M*
- `outline.moveUp` — Move Up — *M*
- `outline.moveDown` — Move Down — *M*
- `outline.expand` — Expand — *Alt+Shift+=*
- `outline.collapse` — Collapse — *Alt+Shift+-*
- `outline.toggle` — Expand or Collapse Heading
- `outline.selectSubtree` — Select Heading and Content
- `outline.showLevel` — Show Level
- `outline.showLevel1` — Show Level 1 — *Alt+Shift+1*
- `outline.showLevel2` — Show Level 2 — *Alt+Shift+2*
- `outline.showLevel3` — Show Level 3 — *Alt+Shift+3*
- `outline.showLevel4` — Show Level 4 — *Alt+Shift+4*
- `outline.showLevel5` — Show Level 5 — *Alt+Shift+5*
- `outline.showLevel6` — Show Level 6 — *Alt+Shift+6*
- `outline.showLevel7` — Show Level 7 — *Alt+Shift+7*
- `outline.showLevel8` — Show Level 8 — *Alt+Shift+8*
- `outline.showLevel9` — Show Level 9 — *Alt+Shift+9*
- `outline.showAll` — Show All Levels — *Alt+Shift+A*
- `outline.firstLineOnly` — Show First Line Only — *Alt+Shift+L*
- `outline.showFormatting` — Show Text Formatting
- `outline.close` — Close Outline View
- `outline.state` — Outline State

## insert (44)

- `insert.pageBreak` — Page Break — *M*
- `insert.blankPage` — Blank Page — *M*
- `insert.coverPage` — Cover Page — *M*
- `insert.table` — Table — *M*
- `insert.picture` — Pictures — *M*
- `insert.icon` — Icons — *M*
- `insert.shape` — Shapes — *M*
- `insert.textBox` — Text Box — *M*
- `insert.link` — Link — *Mod+K, M*
- `insert.removeLink` — Remove Hyperlink — *M*
- `insert.bookmark` — Bookmark — *Mod+Shift+F5, M*
- `insert.deleteBookmark` — Delete Bookmark — *M*
- `insert.header` — Header — *M*
- `insert.footer` — Footer — *M*
- `insert.pageNumber` — Page Number — *M*
- `insert.editHeader` — Edit Header
- `insert.editFooter` — Edit Footer
- `insert.createHeader` — Header — *M*
- `insert.createFooter` — Footer — *M*
- `insert.closeHeader` — Close Header and Footer
- `insert.removeEmptyHeaders` — Close Header and Footer — *M*
- `insert.removeHeader` — Remove Header — *M*
- `insert.removeFooter` — Remove Footer — *M*
- `insert.dateTime` — Date & Time — *M*
- `insert.symbol` — Symbol — *M*
- `insert.field` — Field — *Mod+F9, M*
- `insert.dateField` — Insert Date Field — *Alt+Shift+D, M*
- `insert.timeField` — Insert Time Field — *Alt+Shift+T, M*
- `insert.pageField` — Insert Page Field — *Alt+Shift+P, M*
- `insert.dropCap` — Drop Cap — *M*
- `insert.horizontalLine` — Horizontal Line — *M*
- `insert.textFromFile` — Text from File — *M*
- `insert.equation` — Equation — *Alt+=, M*
- `insert.crossReference` — Cross-reference — *M*
- `insert.smartArt` — SmartArt — *M*
- `insert.chart` — Chart — *M*
- `insert.canvas` — Drawing Canvas — *M*
- `insert.wordArt` — WordArt — *M*
- `insert.quickParts` — Quick Parts — *M*
- `insert.autoText` — AutoText — *Alt+F3, M*
- `insert.docProperty` — Document Property — *M*
- `insert.signatureLine` — Signature Line — *M*
- `insert.object` — Object — *M*
- `insert.spreadsheet` — Spreadsheet Table — *M*

## link (1)

- `link.targets` — Link

## equation (20)

- `equation.edit` — Edit Equation
- `equation.exit` — Leave Equation
- `equation.type` — Type in Equation — *M*
- `equation.insertStructure` — Insert Structure — *M*
- `equation.insertSymbol` — Insert Symbol — *M*
- `equation.move` — Move in Equation
- `equation.backspace` — Delete Back in Equation — *M*
- `equation.delete` — Delete in Equation — *M*
- `equation.enter` — Enter in Equation — *M*
- `equation.convert` — Convert — *M*
- `equation.inputFormat` — Input Format
- `equation.normalText` — Normal Text
- `equation.display` — Change to Display — *M*
- `equation.justify` — Justification — *M*
- `equation.number` — Equation Number — *M*
- `equation.set` — Set Equation — *M*
- `equation.get` — Equation Info
- `equation.gallery` — Equation Gallery
- `equation.structureActions` — Structure Actions
- `equation.structure` — Change Structure — *M*

## layout (18)

- `layout.margins` — Margins — *M*
- `layout.orientation` — Orientation — *M*
- `layout.size` — Size — *M*
- `layout.columns` — Columns — *M*
- `layout.break` — Breaks — *M*
- `layout.lineNumbers` — Line Numbers — *M*
- `layout.hyphenation` — Hyphenation — *M*
- `layout.manualHyphenation` — Manual Hyphenation
- `layout.pageSetup` — Page Setup — *M*
- `layout.verticalAlign` — Vertical Alignment — *M*
- `layout.sectionRtl` — Right-to-Left Section — *M*
- `layout.textDirection` — Text Direction — *M*
- `layout.differentFirstPage` — Different First Page — *M*
- `layout.differentOddEven` — Different Odd & Even Pages — *M*
- `layout.pageNumberFormat` — Format Page Numbers — *M*
- `layout.documentGrid` — Document Grid — *M*
- `layout.section` — Section Properties
- `layout.linkToPrevious` — Link to Previous — *Alt+Shift+R, M*

## review (35)

- `review.newComment` — New Comment — *Mod+Alt+M, M*
- `review.reply` — Reply — *M*
- `review.editComment` — Edit Comment — *M*
- `review.deleteComment` — Delete — *M*
- `review.resolveComment` — Resolve — *M*
- `review.nextComment` — Next
- `review.previousComment` — Previous
- `review.comments` — Show Comments
- `review.trackChanges` — Track Changes — *Mod+Shift+E, M*
- `review.acceptAll` — Accept All Changes — *M*
- `review.rejectAll` — Reject All Changes — *M*
- `review.accept` — Accept — *M*
- `review.reject` — Reject — *M*
- `review.nextChange` — Next Change
- `review.previousChange` — Previous Change
- `review.markup` — Display for Review
- `review.trackingOptions` — Track Changes Options
- `review.wordCount` — Word Count — *Mod+Shift+G*
- `review.changes` — Reviewing Pane
- `review.spelling` — Spelling & Grammar — *F7 / Alt+F7*
- `review.issues` — Proofing Issues
- `review.suggestions` — Spelling Suggestions
- `review.addToDictionary` — Add to Dictionary
- `review.ignoreAll` — Ignore All
- `review.applySuggestion` — Change — *M*
- `review.proofing` — Check Spelling as You Type
- `review.thesaurus` — Thesaurus — *Shift+F7*
- `review.hideInk` — Hide Ink
- `review.compare` — Compare — *M*
- `review.combine` — Combine — *M*
- `review.language` — Language — *M*
- `review.showMarkup` — Show Markup
- `review.editor` — Editor
- `review.restrict` — Restrict Editing — *M*
- `review.readAloud` — Read Aloud — *Mod+Alt+Space*

## file (28)

- `file.rename` — Rename Document
- `file.new` — New — *Mod+N*
- `file.open` — Open — *Mod+O / Mod+F12 / Mod+Alt+F2*
- `file.save` — Save — *Mod+S / Shift+F12 / Alt+Shift+F2*
- `file.saveAs` — Save As — *F12 / Alt+F2*
- `file.encrypt` — Encrypt with Password
- `file.exportPdf` — Export PDF
- `file.exportPng` — Export Page as PNG
- `file.printMarkup` — Print Markup
- `file.printPdf` — Print to PDF
- `file.print` — Print — *Mod+P / Mod+Shift+F12 / Mod+F2 / Mod+Alt+I*
- `file.close` — Close — *Mod+W / Mod+F4*
- `file.properties` — Properties — *M*
- `file.info` — Info
- `file.setAuthor` — User Name
- `file.privacyOptions` — Privacy Options — *M*
- `file.privacy` — Privacy Settings
- `file.options` — Options
- `file.accessibility` — Check Accessibility
- `file.inspect` — Inspect Document — *M*
- `file.protect` — Protect Document — *M*
- `file.versions` — Version History
- `file.recover` — Recover Unsaved Documents
- `file.newFromTemplate` — New from Template
- `file.saveTemplate` — Save as Template
- `file.autosave` — AutoSave
- `file.compatibility` — Check Compatibility
- `file.share` — Share

## document (6)

- `document.inspect` — Inspect Document
- `document.text` — Document Text
- `document.paragraph` — Paragraph Details
- `document.selection` — Selection
- `document.layout` — Layout Summary
- `document.setText` — Replace Document Text — *M*

## design (11)

- `design.theme` — Themes — *M*
- `design.themeFonts` — Fonts — *M*
- `design.themeColors` — Colors — *M*
- `design.styleSet` — Style Set — *M*
- `design.paragraphSpacing` — Paragraph Spacing — *M*
- `design.watermark` — Watermark — *M*
- `design.pageColor` — Page Color — *M*
- `design.pageBorders` — Page Borders — *M*
- `design.setDefault` — Set as Default
- `design.themes` — Theme List
- `design.effects` — Effects — *M*

## references (25)

- `references.toc` — Table of Contents — *M*
- `references.updateToc` — Update Table — *M*
- `references.removeToc` — Remove Table of Contents — *M*
- `references.addText` — Add Text — *M*
- `references.footnote` — Insert Footnote — *Mod+Alt+F, M*
- `references.endnote` — Insert Endnote — *Mod+Alt+D, M*
- `references.convertNotes` — Convert Notes — *M*
- `references.nextFootnote` — Next Footnote — *Alt+Shift+> / Alt+Shift+.*
- `references.notes` — Show Notes
- `references.caption` — Insert Caption — *M*
- `references.updateFields` — Update Field — *F9, M*
- `references.sources` — Manage Sources — *M*
- `references.citation` — Insert Citation — *M*
- `references.citationStyle` — Style — *M*
- `references.bibliography` — Bibliography — *M*
- `references.tableOfFigures` — Insert Table of Figures — *M*
- `references.updateFigures` — Update Table — *M*
- `references.markCitation` — Mark Citation — *Alt+Shift+I, M*
- `references.tableOfAuthorities` — Insert Table of Authorities — *M*
- `references.updateAuthorities` — Update Table — *M*
- `references.noteOptions` — Footnote and Endnote — *M*
- `references.researcher` — Researcher
- `references.markEntry` — Mark Entry — *Alt+Shift+X, M*
- `references.index` — Insert Index — *M*
- `references.updateIndex` — Update Index — *M*

## fields (8)

- `fields.toggleCode` — Toggle Field Codes — *Shift+F9, M*
- `fields.setCode` — Edit Field Code — *M*
- `fields.unlink` — Unlink Fields — *Mod+Shift+F9, M*
- `fields.lock` — Lock Fields — *Mod+F11, M*
- `fields.unlock` — Unlock Fields — *Mod+Shift+F11, M*
- `fields.next` — Next Field — *Alt+F1*
- `fields.previous` — Previous Field — *Shift+F11 / Alt+Shift+F1*
- `fields.selected` — Selected Fields

## mailings (19)

- `mailings.start` — Start Mail Merge
- `mailings.recipients` — Select Recipients
- `mailings.editRecipients` — Edit Recipient List — *Alt+Shift+E*
- `mailings.filterRecipients` — Filter Recipients
- `mailings.sortRecipients` — Sort Recipients
- `mailings.insertField` — Insert Merge Field — *Alt+Shift+F, M*
- `mailings.addressBlock` — Address Block — *M*
- `mailings.greetingLine` — Greeting Line — *M*
- `mailings.rules` — Rules — *M*
- `mailings.matchFields` — Match Fields
- `mailings.highlightFields` — Highlight Merge Fields
- `mailings.preview` — Preview Results — *Alt+Shift+K, M*
- `mailings.next` — Next Record — *M*
- `mailings.previous` — Previous Record — *M*
- `mailings.findRecipient` — Find Recipient — *M*
- `mailings.checkErrors` — Check for Errors
- `mailings.finish` — Finish & Merge — *Alt+Shift+N, M*
- `mailings.envelopes` — Envelopes — *M*
- `mailings.labels` — Labels — *M*

## picture (14)

- `picture.size` — Size — *M*
- `picture.crop` — Crop — *M*
- `picture.altText` — Alt Text — *M*
- `picture.corrections` — Corrections — *M*
- `picture.color` — Color — *M*
- `picture.iconColor` — Icon Color — *M*
- `picture.effects` — Artistic Effects — *M*
- `picture.transparency` — Transparency — *M*
- `picture.removeBackground` — Remove Background — *M*
- `picture.compress` — Compress Pictures — *M*
- `picture.reset` — Reset Picture — *M*
- `picture.change` — Change Picture — *M*
- `picture.style` — Picture Styles — *M*
- `picture.border` — Picture Border — *M*

## object (1)

- `object.altText` — Alt Text — *M*

## arrange (15)

- `arrange.rotate` — Rotate — *M*
- `arrange.rotation` — Rotation — *M*
- `arrange.wrap` — Wrap Text — *M*
- `arrange.wrapText` — Wrap Text Sides — *M*
- `arrange.moveWithText` — Move with Text — *M*
- `arrange.position` — Position — *M*
- `arrange.bringForward` — Bring Forward — *M*
- `arrange.sendBackward` — Send Backward — *M*
- `arrange.align` — Align — *M*
- `arrange.selectionPane` — Selection Pane
- `arrange.bounds` — Move or Resize — *M*
- `arrange.copyTo` — Copy to — *M*
- `arrange.nudge` — Nudge — *M*
- `arrange.group` — Group — *M*
- `arrange.ungroup` — Ungroup — *M*

## shape (9)

- `shape.fill` — Shape Fill — *M*
- `shape.outline` — Shape Outline — *M*
- `shape.effects` — Shape Effects — *M*
- `shape.change` — Change Shape — *M*
- `shape.textDirection` — Text Direction — *M*
- `shape.alignText` — Align Text — *M*
- `shape.link` — Create Link — *M*
- `shape.breakLink` — Break Link — *M*
- `shape.connect` — Connect Shapes — *M*

## smartArt (8)

- `smartArt.items` — Edit Items — *M*
- `smartArt.textPane` — Text Pane
- `smartArt.addShape` — Add Shape — *M*
- `smartArt.promote` — Promote — *M*
- `smartArt.demote` — Demote — *M*
- `smartArt.layout` — Change Layout — *M*
- `smartArt.colors` — Change Colors — *M*
- `smartArt.reset` — Reset Graphic — *M*

## chart (5)

- `chart.type` — Change Chart Type — *M*
- `chart.editData` — Edit Data — *M*
- `chart.title` — Chart Title — *M*
- `chart.legend` — Legend — *M*
- `chart.dataLabels` — Data Labels — *M*

## draw (16)

- `draw.select` — Select
- `draw.lasso` — Lasso Select
- `draw.lassoMove` — Move Selected Ink — *M*
- `draw.lassoDelete` — Delete Selected Ink — *M*
- `draw.lassoColor` — Recolor Selected Ink — *M*
- `draw.eraser` — Eraser
- `draw.pen` — Pen
- `draw.pencil` — Pencil
- `draw.highlighter` — Highlighter
- `draw.addPen` — Add Pen
- `draw.removePen` — Remove Pen
- `draw.stroke` — Draw Ink — *M*
- `draw.erase` — Erase Ink — *M*
- `draw.inkToShape` — Ink to Shape
- `draw.convertInk` — Convert to Shapes — *M*
- `draw.replay` — Ink Replay

## canvas (4)

- `canvas.fit` — Fit — *M*
- `canvas.expand` — Expand — *M*
- `canvas.scale` — Scale Drawing — *M*
- `canvas.member` — Canvas Member — *M*

## wordArt (4)

- `wordArt.style` — WordArt Styles — *M*
- `wordArt.textFill` — Text Fill — *M*
- `wordArt.textOutline` — Text Outline — *M*
- `wordArt.transform` — Transform — *M*

## tools (11)

- `tools.recordMacro` — Record Macro
- `tools.macros` — Macros — *Alt+F8*
- `tools.autocorrect` — AutoCorrect Options
- `tools.customizeKeyboard` — Customize Keyboard
- `tools.customizeRibbon` — Customize Ribbon
- `tools.search` — Search — *Alt+Q*
- `tools.templates` — Templates and Add-ins
- `tools.attachTemplate` — Attach Template — *M*
- `tools.detachTemplate` — Detach Template — *M*
- `tools.linkStyles` — Automatically Update Document Styles — *M*
- `tools.updateStyles` — Update Styles from Template — *M*

## hf (3)

- `hf.next` — Next Section
- `hf.previous` — Previous Section
- `hf.position` — Header/Footer Position — *M*

## readAloud (7)

- `readAloud.playPause` — Play/Pause
- `readAloud.next` — Next Sentence
- `readAloud.previous` — Previous Sentence
- `readAloud.stop` — Stop Reading
- `readAloud.speed` — Reading Speed
- `readAloud.skipCitations` — Skip Citations and Bibliography
- `readAloud.status` — Read Aloud Status

## developer (16)

- `developer.richText` — Rich Text Content Control — *M*
- `developer.plainText` — Plain Text Content Control — *M*
- `developer.picture` — Picture Content Control — *M*
- `developer.buildingBlock` — Building Block Gallery Content Control — *M*
- `developer.checkBox` — Check Box Content Control — *M*
- `developer.comboBox` — Combo Box Content Control — *M*
- `developer.dropDown` — Drop-Down List Content Control — *M*
- `developer.datePicker` — Date Picker Content Control — *M*
- `developer.repeatingSection` — Repeating Section Content Control — *M*
- `developer.designMode` — Design Mode
- `developer.properties` — Properties — *M*
- `developer.control` — Content Control at Selection
- `developer.toggleCheckBox` — Toggle Check Box — *M*
- `developer.chooseItem` — Choose List Item — *M*
- `developer.setDate` — Set Date — *M*
- `developer.removeControl` — Remove Content Control — *M*
