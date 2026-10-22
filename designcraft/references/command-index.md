# DesignCraft command index — 0.10.0 (headless catalog)

Generated from `designcraft-cli commands` (521 commands, 64 namespaces).

The running desktop app exposes more commands: the extra ones are UI-layer
`ui:*`/`app.*` menu commands that only exist with a window.

`enabled` is contextual — most commands need a document or a selection.
Parameters are omitted here; ask live with `designcraft-cli describe ID`.
`shortcut` and `ctx` (disabled with no document) are noted.

## file (35)

- `file.new` — Document… — *Cmd+N*
- `file.newSample` — Sample Document
- `file.presets` — Document Presets
- `file.savePreset` — Save Document Preset
- `file.deletePreset` — Delete Document Preset
- `file.open` — Open… — *Cmd+O*
- `file.openBytes` — Open Bytes
- `file.openRecent` — Open Recent File — *ctx*
- `file.recentFiles` — Recent Files
- `file.clearRecent` — Clear Recent Files — *ctx*
- `file.save` — Save — *Cmd+S, ctx*
- `file.saveAs` — Save As… — *Cmd+Shift+S, ctx*
- `file.saveACopy` — Save a Copy… — *ctx*
- `file.revert` — Revert — *ctx*
- `file.recovery.list` — Recovery Data
- `file.recovery.save` — Save Recovery Data
- `file.recovery.open` — Recover Documents
- `file.serialize` — Serialize — *ctx*
- `file.close` — Close — *Cmd+W, ctx*
- `file.activate` — Activate Document — *ctx*
- `file.place` — Place… — *Cmd+D, ctx*
- `file.exportIdml` — Export IDML… — *ctx*
- `file.openIdml` — Open IDML
- `file.exportPdf` — Export PDF… — *ctx*
- `file.exportEpub` — Export EPUB (Reflowable)… — *ctx*
- `file.exportFixedEpub` — Export EPUB (Fixed Layout)… — *ctx*
- `file.printBooklet` — Print Booklet… — *ctx*
- `file.exportHtml` — Export HTML… — *ctx*
- `file.exportPptx` — Export PowerPoint… — *ctx*
- `file.exportText` — Export Text… — *ctx*
- `file.exportXml` — Export XML… — *ctx*
- `file.importXml` — Import XML… — *ctx*
- `file.package` — Package… — *ctx*
- `file.printers` — Printers
- `file.print` — Print… — *Cmd+P, ctx*

## snippet (2)

- `snippet.export` — Export Selection as Snippet — *ctx*
- `snippet.place` — Place Snippet — *ctx*

## place (3)

- `place.styles` — Import Options: Styles — *ctx*
- `place.load` — Load Place Cursor — *ctx*
- `place.drop` — Place Loaded Graphic — *ctx*

## edit (18)

- `edit.undo` — Undo — *Cmd+Z, ctx*
- `edit.redo` — Redo — *Cmd+Shift+Z, ctx*
- `edit.selectAll` — Select All — *Cmd+A, ctx*
- `edit.deselectAll` — Deselect All — *Cmd+Shift+A, ctx*
- `edit.clear` — Clear — *Delete, ctx*
- `edit.copy` — Copy — *Cmd+C, ctx*
- `edit.cut` — Cut — *Cmd+X, ctx*
- `edit.pasteWithoutFormatting` — Paste without Formatting — *Cmd+Shift+V, ctx*
- `edit.paste` — Paste — *Cmd+V, ctx*
- `edit.pasteInto` — Paste Into — *Cmd+Alt+V, ctx*
- `edit.pasteInPlace` — Paste in Place — *Cmd+Alt+Shift+V, ctx*
- `edit.duplicate` — Duplicate — *Cmd+Alt+Shift+D, ctx*
- `edit.preview` — Preview Change — *ctx*
- `edit.commitPreview` — Commit Preview — *ctx*
- `edit.cancelPreview` — Cancel Preview — *ctx*
- `edit.pasteSvg` — Paste Vector Art — *ctx*
- `edit.stepAndRepeat` — Step and Repeat… — *Cmd+Alt+U, ctx*
- `edit.transparencyBlendSpace` — Transparency Blend Space — *ctx*

## selection (2)

- `selection.set` — Select — *ctx*
- `selection.toggle` — Toggle Selection — *ctx*

## endnote (5)

- `endnote.insert` — Insert Endnote — *ctx*
- `endnote.edit` — Edit Endnote — *ctx*
- `endnote.delete` — Delete Endnote — *ctx*
- `endnote.list` — Endnotes — *ctx*
- `endnote.options` — Document Endnote Options… — *ctx*

## note (5)

- `note.new` — New Note — *ctx*
- `note.edit` — Edit Note — *ctx*
- `note.delete` — Delete Note — *ctx*
- `note.convertToText` — Convert Note to Text — *ctx*
- `note.list` — Notes — *ctx*

## frame (2)

- `frame.create` — Create Frame — *ctx*
- `frame.grid` — Gridify — *ctx*

## line (1)

- `line.create` — Create Line — *ctx*

## transform (10)

- `transform.move` — Move — *ctx*
- `transform.resize` — Resize — *ctx*
- `transform.rotate` — Rotate — *ctx*
- `transform.scale` — Scale — *ctx*
- `transform.again` — Transform Again — *Cmd+Alt+3, ctx*
- `transform.clear` — Clear Transformations — *ctx*
- `transform.shear` — Shear — *ctx*
- `transform.flip` — Flip — *ctx*
- `transform.set` — Transform Panel — *ctx*
- `transform.info` — Transform Values — *ctx*

## object (59)

- `object.matchAttributes` — Apply Attributes (Eyedropper) — *ctx*
- `object.arrange` — Arrange — *ctx*
- `object.bringToFront` — Bring to Front — *Cmd+Shift+], ctx*
- `object.bringForward` — Bring Forward — *Cmd+], ctx*
- `object.sendBackward` — Send Backward — *Cmd+[, ctx*
- `object.sendToBack` — Send to Back — *Cmd+Shift+[, ctx*
- `object.group` — Group — *Cmd+G, ctx*
- `object.ungroup` — Ungroup — *Cmd+Shift+G, ctx*
- `object.lock` — Lock — *Cmd+L, ctx*
- `object.unlockAll` — Unlock All on Spread — *Cmd+Alt+L, ctx*
- `object.hide` — Hide — *Cmd+3, ctx*
- `object.showAll` — Show All on Spread — *Cmd+Alt+3, ctx*
- `object.setFlags` — Set Visibility / Lock — *ctx*
- `object.fill` — Fill — *ctx*
- `object.swapFillStroke` — Swap Fill and Stroke — *ctx*
- `object.defaultFillStroke` — Default Fill and Stroke — *ctx*
- `object.stroke` — Stroke — *ctx*
- `object.opacity` — Opacity — *ctx*
- `object.dropShadow` — Drop Shadow — *Cmd+Alt+M, ctx*
- `object.innerShadow` — Inner Shadow — *ctx*
- `object.outerGlow` — Outer Glow — *ctx*
- `object.exportOptions` — Object Export Options… — *ctx*
- `object.innerGlow` — Inner Glow — *ctx*
- `object.bevel` — Bevel and Emboss — *ctx*
- `object.satin` — Satin — *ctx*
- `object.directionalFeather` — Directional Feather — *ctx*
- `object.effects` — Effects — *ctx*
- `object.feather` — Basic Feather — *ctx*
- `object.content` — Content — *ctx*
- `object.textFrameOptions` — Text Frame Options… — *Cmd+B, ctx*
- `object.cornerOptions` — Corner Options… — *ctx*
- `object.textWrap` — Text Wrap — *Cmd+Alt+W, ctx*
- `object.fit` — Fitting — *ctx*
- `object.fittingOptions` — Frame Fitting Options… — *ctx*
- `object.rename` — Rename — *ctx*
- `object.align` — Align — *ctx*
- `object.distribute` — Distribute — *ctx*
- `object.clippingPath` — Clipping Path… — *ctx*
- `object.clippingPathOptions` — Clipping Path Options… — *ctx*
- `object.primaryTextFrame` — Primary Text Frame — *ctx*
- `object.attributes` — Attributes — *ctx*
- `object.globalLight` — Global Light… — *ctx*
- `object.label` — Script Label — *ctx*
- `object.altText` — Object Export Options — *ctx*
- `object.transparencyGroup` — Group Transparency — *ctx*
- `object.findByLabel` — Find by Script Label — *ctx*
- `object.setLayer` — Move to Layer — *ctx*
- `object.reorder` — Reorder Objects — *ctx*
- `object.makeCompoundPath` — Make Compound Path — *Cmd+8, ctx*
- `object.releaseCompoundPath` — Release Compound Path — *Cmd+Alt+Shift+8, ctx*
- `object.pathfinder` — Pathfinder — *ctx*
- `object.gradientFeather` — Gradient Feather — *ctx*
- `object.caption` — Generate Static Caption — *ctx*
- `object.pdfLayers` — Object Layers — *ctx*
- `object.layerOptions` — Object Layer Options… — *ctx*
- `object.qrCode` — Generate QR Code… — *ctx*
- `object.convertShape` — Convert Shape — *ctx*
- `object.gradient` — Gradient — *ctx*
- `object.color` — Apply Color — *ctx*

## path (14)

- `path.create` — Create Path — *ctx*
- `path.appendAnchor` — Add Anchor — *ctx*
- `path.setAnchor` — Set Anchor — *ctx*
- `path.reverse` — Reverse Path — *ctx*
- `path.close` — Close Path — *ctx*
- `path.moveAnchors` — Move Anchors — *ctx*
- `path.addAnchor` — Add Anchor Point — *ctx*
- `path.deleteAnchor` — Delete Anchor Point — *ctx*
- `path.convertAnchor` — Convert Direction Point — *ctx*
- `path.erase` — Erase — *ctx*
- `path.smooth` — Smooth — *ctx*
- `path.join` — Join — *ctx*
- `path.convertPoints` — Convert Point — *ctx*
- `path.split` — Split Path — *ctx*

## tool (3)

- `tool.polygonSettings` — Polygon Settings…
- `tool.select` — Select Tool
- `tool.list` — List Tools

## gap (1)

- `gap.move` — Move Gap — *ctx*

## article (6)

- `article.list` — Articles — *ctx*
- `article.new` — New Article — *ctx*
- `article.add` — Add Selection to Article — *ctx*
- `article.remove` — Remove from Article — *ctx*
- `article.options` — Article Options — *ctx*
- `article.delete` — Delete Article — *ctx*

## type (43)

- `type.createOutlines` — Create Outlines — *Cmd+Shift+O, ctx*
- `type.onPath` — Type on a Path — *ctx*
- `type.pathOptions` — Type on a Path Options… — *ctx*
- `type.pickUpFormat` — Apply Text Attributes (Eyedropper) — *ctx*
- `type.fillWithPlaceholder` — Fill with Placeholder Text — *ctx*
- `type.char` — Character Formatting — *ctx*
- `type.kernPair` — Kerning — *ctx*
- `type.para` — Paragraph Formatting — *ctx*
- `type.align` — Align — *ctx*
- `type.alignLeft` — Align Left — *Cmd+Shift+L, ctx*
- `type.alignCenter` — Align Center — *Cmd+Shift+C, ctx*
- `type.alignRight` — Align Right — *Cmd+Shift+R, ctx*
- `type.justify` — Justify Left — *Cmd+Shift+J, ctx*
- `type.bold` — Bold — *Cmd+Shift+B, ctx*
- `type.italic` — Italic — *Cmd+Shift+I, ctx*
- `type.swapFillStroke` — Swap Text Fill and Stroke — *ctx*
- `type.underline` — Underline — *Cmd+Shift+U, ctx*
- `type.allCaps` — All Caps — *Cmd+Shift+K, ctx*
- `type.tateChuYoko` — Tate-Chu-Yoko — *ctx*
- `type.ruby` — Ruby — *ctx*
- `type.kenten` — Kenten — *ctx*
- `type.shatai` — Shatai — *ctx*
- `type.autoTateChuYoko` — Auto Tate-Chu-Yoko — *ctx*
- `type.gridSettings` — Grid Settings — *ctx*
- `type.rotateRoman` — Rotate Roman Characters in Vertical Text — *ctx*
- `type.romanWordBreak` — Roman Word Break — *ctx*
- `type.warichu` — Warichu — *ctx*
- `type.storyDirection` — Story Direction — *ctx*
- `type.kernStep` — Kerning/Tracking Step — *ctx*
- `type.sizeUp` — Increase Point Size — *Cmd+Shift+., ctx*
- `type.sizeDown` — Decrease Point Size — *Cmd+Shift+,, ctx*
- `type.changeCase` — Change Case — *ctx*
- `type.openType` — OpenType — *ctx*
- `type.selectionAttrs` — Selection Attributes — *ctx*
- `type.openTypeFeatures` — OpenType Features — *ctx*
- `type.feature` — Set OpenType Features — *ctx*
- `type.tabs.get` — Get Tabs — *ctx*
- `type.tabs.add` — Add Tab — *ctx*
- `type.tabs.move` — Move Tab — *ctx*
- `type.tabs.change` — Change Tab — *ctx*
- `type.tabs.remove` — Delete Tab — *ctx*
- `type.tabs.clear` — Clear All Tabs — *ctx*
- `type.tabs.repeat` — Repeat Tab — *ctx*

## flex (5)

- `flex.add` — Add to Flex Layout — *ctx*
- `flex.convert` — Convert to Flex Layout — *ctx*
- `flex.remove` — Remove Flex Layout — *ctx*
- `flex.set` — Flex Layout Options — *ctx*
- `flex.reorder` — Reorder in Flex Layout — *ctx*

## book (10)

- `book.new` — New Book
- `book.open` — Open Book
- `book.close` — Close Book — *ctx*
- `book.add` — Add Document — *ctx*
- `book.remove` — Remove Document — *ctx*
- `book.styleSource` — Style Source — *ctx*
- `book.list` — Book — *ctx*
- `book.paginate` — Update Numbering — *ctx*
- `book.syncStyles` — Synchronize Book — *ctx*
- `book.exportPdf` — Export Book to PDF… — *ctx*

## button (3)

- `button.set` — Convert to Button — *ctx*
- `button.clear` — Convert to Object — *ctx*
- `button.list` — Buttons — *ctx*

## form (3)

- `form.set` — Convert to Form Field — *ctx*
- `form.clear` — Convert to Object — *ctx*
- `form.list` — Form Fields — *ctx*

## color (5)

- `color.settings` — Color Settings
- `color.loadProfile` — Load Profile…
- `color.convert` — Convert Color
- `color.extractTheme` — Extract Color Theme — *ctx*
- `color.sample` — Sample Color (Eyedropper) — *ctx*

## swatch (13)

- `swatch.addColorTheme` — Color Theme… — *ctx*
- `swatch.create` — New Color Swatch… — *ctx*
- `swatch.new` — New Swatch — *ctx*
- `swatch.load` — Load Swatches… — *ctx*
- `swatch.save` — Save Swatches for Exchange… — *ctx*
- `swatch.addToSwatches` — Add to Swatches — *ctx*
- `swatch.options` — Swatch Options… — *ctx*
- `swatch.addUnnamed` — Add Unnamed Colors — *ctx*
- `swatch.delete` — Delete Swatch — *ctx*
- `swatch.newColorGroup` — New Color Group — *ctx*
- `swatch.moveToGroup` — Move to Color Group — *ctx*
- `swatch.ungroupColorGroup` — Ungroup Color Group — *ctx*
- `swatch.renameColorGroup` — Color Group Options — *ctx*

## changes (6)

- `changes.track` — Track Changes — *ctx*
- `changes.list` — Changes — *ctx*
- `changes.accept` — Accept Change — *ctx*
- `changes.reject` — Reject Change — *ctx*
- `changes.acceptAll` — Accept All Changes — *ctx*
- `changes.rejectAll` — Reject All Changes — *ctx*

## condition (5)

- `condition.list` — Conditions — *ctx*
- `condition.new` — New Condition… — *ctx*
- `condition.options` — Condition Options… — *ctx*
- `condition.delete` — Delete Condition — *ctx*
- `condition.apply` — Apply Condition — *ctx*

## library (8)

- `library.new` — New Library
- `library.open` — Open Library
- `library.list` — Library Items — *ctx*
- `library.json` — Library Contents — *ctx*
- `library.add` — Add Item — *ctx*
- `library.place` — Place Item — *ctx*
- `library.remove` — Delete Item — *ctx*
- `library.close` — Close Library — *ctx*

## conveyor (4)

- `conveyor.collect` — Collect — *ctx*
- `conveyor.place` — Place — *ctx*
- `conveyor.list` — Conveyor
- `conveyor.clear` — Clear Conveyor

## list (2)

- `list.define` — Define Lists… — *ctx*
- `list.delete` — Delete List — *ctx*

## story (8)

- `story.placeAndLink` — Place and Link — *ctx*
- `story.links` — Linked Stories — *ctx*
- `story.updateLink` — Update Link — *ctx*
- `story.unlink` — Unlink — *ctx*
- `story.setDirection` — Story Column Direction — *ctx*
- `story.setText` — Set Story Text — *ctx*
- `story.replaceRange` — Edit Story — *ctx*
- `story.get` — Get Story — *ctx*

## math (2)

- `math.insert` — Insert Math Expression… — *ctx*
- `math.svg` — Math Expression SVG — *ctx*

## media (2)

- `media.options` — Media Options — *ctx*
- `media.get` — Media — *ctx*

## liquid (2)

- `liquid.pageRule` — Liquid Page Rule — *ctx*
- `liquid.object` — Object Liquid Settings — *ctx*

## guide (6)

- `guide.liquid` — Convert to Liquid Guide — *ctx*
- `guide.add` — New Guide — *ctx*
- `guide.move` — Move Guide — *ctx*
- `guide.delete` — Delete Guide — *ctx*
- `guide.deleteAll` — Delete All Guides on Spread — *ctx*
- `guide.list` — Guides — *ctx*

## layout (25)

- `layout.createAlternate` — Create Alternate Layout… — *ctx*
- `layout.pages.insert` — Insert Pages… — *Cmd+Shift+P, ctx*
- `layout.rotateSpreadView` — Rotate Spread — *ctx*
- `layout.pages.delete` — Delete Pages — *ctx*
- `layout.pages.move` — Move Pages… — *ctx*
- `layout.pages.duplicateSpread` — Duplicate Spread — *ctx*
- `layout.pages.applyParent` — Apply Parent to Pages… — *ctx*
- `layout.parents.new` — New Parent… — *ctx*
- `layout.parents.delete` — Delete Parent — *ctx*
- `layout.parents.edit` — Edit Parents — *ctx*
- `layout.parents.options` — Parent Options… — *ctx*
- `layout.marginsAndColumns` — Margins and Columns… — *ctx*
- `layout.documentSetup` — Document Setup… — *Cmd+Alt+P, ctx*
- `layout.pages.toSpread` — Add Page to Spread — *ctx*
- `layout.spreadShuffle` — Allow Selected Spread to Shuffle — *ctx*
- `layout.pageSize` — Page Size — *ctx*
- `layout.pageOptions` — Page Options — *ctx*
- `layout.selectPage` — Select Page — *ctx*
- `layout.section` — Numbering & Section Options… — *ctx*
- `layout.chapterNumbering` — Document Chapter Numbering — *ctx*
- `layout.numberingOptions` — Apply Numbering & Section Options — *ctx*
- `layout.overrideParentItems` — Override All Parent Page Items — *Cmd+Alt+Shift+L, ctx*
- `layout.removeOverrides` — Remove All Local Overrides — *ctx*
- `layout.detachAll` — Detach All Objects from Parent — *ctx*
- `layout.createGuides` — Create Guides… — *ctx*

## xml (10)

- `xml.tags` — Tags — *ctx*
- `xml.newTag` — New Tag — *ctx*
- `xml.deleteTag` — Delete Tag — *ctx*
- `xml.tagText` — Tag Text — *ctx*
- `xml.tag` — Tag Frame — *ctx*
- `xml.mapStyle` — Map Styles to Tags — *ctx*
- `xml.structure` — Structure — *ctx*
- `xml.loadDtd` — Load DTD… — *ctx*
- `xml.deleteDtd` — Delete DTD — *ctx*
- `xml.validate` — Validate from Root Element — *ctx*

## strokeStyle (3)

- `strokeStyle.list` — Stroke Styles — *ctx*
- `strokeStyle.new` — New Stroke Style… — *ctx*
- `strokeStyle.delete` — Delete Stroke Style — *ctx*

## script (1)

- `script.run` — Run Script

## states (5)

- `states.create` — Convert Selection to Multi-State Object — *ctx*
- `states.list` — Object States — *ctx*
- `states.show` — Show State — *ctx*
- `states.rename` — State Options — *ctx*
- `states.release` — Release State to Objects — *ctx*

## page (2)

- `page.transition` — Page Transition — *ctx*
- `page.transitions` — Page Transitions — *ctx*

## select (8)

- `select.firstAbove` — First Object Above — *Cmd+Alt+Shift+], ctx*
- `select.nextAbove` — Next Object Above — *Cmd+Alt+], ctx*
- `select.nextBelow` — Next Object Below — *Cmd+Alt+[, ctx*
- `select.lastBelow` — Last Object Below — *Cmd+Alt+Shift+[, ctx*
- `select.container` — Container — *ctx*
- `select.content` — Content — *ctx*
- `select.nextInGroup` — Next Object in Group — *ctx*
- `select.previousInGroup` — Previous Object in Group — *ctx*

## links (7)

- `links.copyTo` — Copy Link(s) To… — *ctx*
- `links.list` — Links — *ctx*
- `links.relink` — Relink… — *ctx*
- `links.relinkFolder` — Relink to Folder… — *ctx*
- `links.update` — Update Link — *ctx*
- `links.embed` — Embed Link — *ctx*
- `links.goTo` — Go To Link — *ctx*

## text (16)

- `text.placeCaret` — Place Caret — *ctx*
- `text.release` — Release — *ctx*
- `text.extendTo` — Extend Text Selection — *ctx*
- `text.selectWord` — Select Word — *ctx*
- `text.selectAt` — Select Text Unit — *ctx*
- `text.selectSentence` — Select Sentence — *ctx*
- `text.selectParagraph` — Select Paragraph — *ctx*
- `text.selectStory` — Select Story — *ctx*
- `text.select` — Select Text — *ctx*
- `text.insert` — Type — *ctx*
- `text.delete` — Delete Text — *ctx*
- `text.move` — Move Caret — *ctx*
- `text.exitToFrame` — Select Frame — *ctx*
- `text.thread` — Thread Text Frames — *ctx*
- `text.unthread` — Break Thread — *ctx*
- `text.removeFromThread` — Remove Frame from Thread — *ctx*

## style (28)

- `style.breakLink` — Break Link to Style — *ctx*
- `style.compositeFont.list` — List Composite Fonts — *ctx*
- `style.compositeFont.set` — Set Composite Font — *ctx*
- `style.exportTag` — Export Tagging — *ctx*
- `style.paragraph.apply` — Apply Paragraph Style — *ctx*
- `style.character.apply` — Apply Character Style — *ctx*
- `style.paragraph.redefine` — Redefine Paragraph Style — *ctx*
- `style.character.redefine` — Redefine Character Style — *ctx*
- `style.paragraph.create` — New Paragraph Style… — *ctx*
- `style.paragraph.edit` — Paragraph Style Options… — *ctx*
- `style.paragraph.delete` — Delete Paragraph Style — *ctx*
- `style.character.create` — New Character Style… — *ctx*
- `style.character.edit` — Character Style Options… — *ctx*
- `style.character.delete` — Delete Character Style — *ctx*
- `style.list` — List Styles — *ctx*
- `style.object.apply` — Apply Object Style — *ctx*
- `style.object.create` — New Object Style… — *ctx*
- `style.object.edit` — Object Style Options… — *ctx*
- `style.object.clearOverrides` — Clear Object Style Overrides — *ctx*
- `style.group` — Move to Group — *ctx*
- `style.load` — Load Styles… — *ctx*
- `style.load.list` — List Styles in File — *ctx*
- `style.cell.create` — New Cell Style… — *ctx*
- `style.cell.apply` — Apply Cell Style — *ctx*
- `style.cell.edit` — Cell Style Options… — *ctx*
- `style.table.create` — New Table Style… — *ctx*
- `style.table.apply` — Apply Table Style — *ctx*
- `style.table.edit` — Table Style Options… — *ctx*

## ink (2)

- `ink.list` — Ink Manager — *ctx*
- `ink.options` — Ink Manager — *ctx*

## table (40)

- `table.insert` — Create Table — *Cmd+Alt+Shift+T, ctx*
- `table.convertFromText` — Convert Text to Table — *ctx*
- `table.convertToText` — Convert Table to Text — *ctx*
- `table.insertRow` — Insert Row — *ctx*
- `table.insertRowAbove` — Insert Row Above — *ctx*
- `table.insertRowBelow` — Insert Row Below — *ctx*
- `table.insertColumn` — Insert Column — *ctx*
- `table.insertColumnLeft` — Insert Column Left — *ctx*
- `table.insertColumnRight` — Insert Column Right — *ctx*
- `table.deleteRow` — Delete Row — *ctx*
- `table.deleteColumn` — Delete Column — *ctx*
- `table.delete` — Delete Table — *ctx*
- `table.merge` — Merge Cells — *ctx*
- `table.dropCells` — Drag Rows or Columns — *ctx*
- `table.placeGraphic` — Convert Cell to Graphic Cell — *ctx*
- `table.textCell` — Convert Cell to Text Cell — *ctx*
- `table.moveRow` — Move Row — *ctx*
- `table.moveColumn` — Move Column — *ctx*
- `table.sortRows` — Sort — *ctx*
- `table.unmerge` — Unmerge Cells — *ctx*
- `table.splitHorizontally` — Split Cell Horizontally — *ctx*
- `table.splitVertically` — Split Cell Vertically — *ctx*
- `table.setCell` — Cell Options — *ctx*
- `table.getCellStroke` — Get Cell Stroke — *ctx*
- `table.setRowHeight` — Row Height — *ctx*
- `table.setColumnWidth` — Column Width — *ctx*
- `table.resizeBorder` — Resize Row or Column — *ctx*
- `table.distributeColumns` — Distribute Columns Evenly — *ctx*
- `table.distributeRows` — Distribute Rows Evenly — *ctx*
- `table.options` — Table Options — *ctx*
- `table.convertRowsToHeader` — To Header — *ctx*
- `table.convertRowsToBody` — To Body — *ctx*
- `table.convertRowsToFooter` — To Footer — *ctx*
- `table.select` — Select Cells — *ctx*
- `table.selectTable` — Select Table — *ctx*
- `table.selectRow` — Select Row — *ctx*
- `table.selectColumn` — Select Column — *ctx*
- `table.nextCell` — Next Cell — *ctx*
- `table.prevCell` — Previous Cell — *ctx*
- `table.get` — Get Table — *ctx*

## layer (9)

- `layer.move` — Move Layer — *ctx*
- `layer.selectItems` — Select All on Layer — *ctx*
- `layer.new` — New Layer… — *ctx*
- `layer.set` — Layer Options… — *ctx*
- `layer.delete` — Delete Layer — *ctx*
- `layer.merge` — Merge Layers — *ctx*
- `layer.deleteUnused` — Delete Unused Layers — *ctx*
- `layer.others` — Hide/Lock Others — *ctx*
- `layer.activate` — Set Active Layer — *ctx*

## prefs (1)

- `prefs.set` — Preferences

## document (4)

- `document.preferences` — Document Preferences — *ctx*
- `document.inspect` — Inspect Document — *ctx*
- `document.list` — List Documents
- `document.history` — History — *ctx*

## app (1)

- `app.links` — Community & Project Links

## find (5)

- `find.objects` — Find Object — *ctx*
- `find.changeObjects` — Change All (Object) — *ctx*
- `find.find` — Find — *ctx*
- `find.change` — Change All — *ctx*
- `find.next` — Find Next — *Cmd+Alt+F, ctx*

## variables (4)

- `variables.list` — Text Variables — *ctx*
- `variables.define` — Define Text Variable… — *ctx*
- `variables.delete` — Delete Text Variable — *ctx*
- `variables.insert` — Insert Variable — *ctx*

## toc (3)

- `toc.generate` — Table of Contents… — *ctx*
- `toc.update` — Update Table of Contents — *ctx*
- `toc.entries` — Table of Contents Entries — *ctx*

## footnote (6)

- `footnote.insert` — Insert Footnote — *ctx*
- `footnote.options` — Document Footnote Options… — *ctx*
- `footnote.list` — Footnotes — *ctx*
- `footnote.setText` — Set Footnote Text — *ctx*
- `footnote.delete` — Delete Footnote — *ctx*
- `footnote.goToReference` — Go to Footnote Reference — *ctx*

## xref (5)

- `xref.insert` — Insert Cross-Reference… — *ctx*
- `xref.list` — Cross-References — *ctx*
- `xref.formats` — Cross-Reference Formats — *ctx*
- `xref.defineFormat` — Define Cross-Reference Format… — *ctx*
- `xref.setFormat` — Set Cross-Reference Format — *ctx*

## anchor (2)

- `anchor.create` — New Hyperlink Destination… — *ctx*
- `anchor.list` — Text Anchors — *ctx*

## index (4)

- `index.addReference` — New Page Reference… — *ctx*
- `index.list` — Index Page References — *ctx*
- `index.generate` — Generate Index… — *ctx*
- `index.update` — Update Index — *ctx*

## anchored (4)

- `anchored.insert` — Insert Anchored Object… — *ctx*
- `anchored.options` — Anchored Object Options… — *ctx*
- `anchored.release` — Release — *ctx*
- `anchored.list` — Anchored Objects — *ctx*

## view (2)

- `view.zeroPoint` — Ruler Zero Point — *ctx*
- `view.lockZeroPoint` — Lock Zero Point — *ctx*

## font (3)

- `font.list` — Fonts in Document — *ctx*
- `font.replace` — Find/Replace Font… — *ctx*
- `font.reload` — Reload Fonts

## spelling (5)

- `spelling.check` — Check Spelling… — *Cmd+I, ctx*
- `spelling.setWords` — User Dictionary — *ctx*
- `spelling.words` — User Dictionary Words — *ctx*
- `spelling.addWord` — Add to Dictionary — *ctx*
- `spelling.change` — Change — *ctx*

## hyphenation (3)

- `hyphenation.addException` — Add Hyphenation Exception — *ctx*
- `hyphenation.removeException` — Remove Hyphenation Exception — *ctx*
- `hyphenation.list` — Hyphenation Exceptions — *ctx*

## data (10)

- `data.source.select` — Select Data Source… — *ctx*
- `data.source.update` — Update Data Source — *ctx*
- `data.source.remove` — Remove Data Source — *ctx*
- `data.fields` — Data Fields — *ctx*
- `data.placeholder.add` — Insert Field — *ctx*
- `data.placeholder.remove` — Remove Field — *ctx*
- `data.options` — Data Merge Options — *ctx*
- `data.preview` — Preview Record — *ctx*
- `data.preview.stop` — Stop Preview — *ctx*
- `data.merge` — Create Merged Document… — *ctx*

## hyperlink (5)

- `hyperlink.create` — New Hyperlink… — *ctx*
- `hyperlink.delete` — Delete Hyperlink — *ctx*
- `hyperlink.list` — Hyperlinks — *ctx*
- `hyperlink.edit` — Hyperlink Options… — *ctx*
- `hyperlink.goToSource` — Go To Source — *ctx*

## bookmark (4)

- `bookmark.rename` — Rename Bookmark — *ctx*
- `bookmark.add` — New Bookmark — *ctx*
- `bookmark.delete` — Delete Bookmark — *ctx*
- `bookmark.list` — Bookmarks — *ctx*

## preflight (1)

- `preflight.run` — Preflight Document — *ctx*
