# Command index — DeckCraft 0.9.0

All 321 command ids from `deckcraft-cli commands` on 2026-10-22.
Grouped by namespace; the text after the dash is the live one-line parameter summary.
Regenerate with `scripts/dump-commands.sh` and compare with `assets/commands.txt`.

## file (19)

- file.new — New Presentation: {theme?: name, template?: starter name, size?: [w,h] pt, blank?: bool}
- file.templates — Starter Templates → [{name, summary, theme, slides}]
- file.open — Open…: {path}
- file.adopt — Open: {path, token?} (a presentation the host read in the background and staged with Session::stage_loaded; without one, reads path like file.open)
- file.openBytes — Open Data: {name, data: base64}
- file.save — Save: {path?, format?: deckcraft|pptx}
- file.saveAs — Save As…: {path, format?}
- file.saveTemplate — Save as Template…: {path}
- file.saveBytes — Save to Data: {format?: deckcraft|pptx} → {data: base64}
- file.export — Export…: {path, format?: png|jpeg|pptx|deckcraft|outline|pdf|gif (else by path), slide?: index, all?: bool, scale?: px per pt, layout?: slides|notes|handouts (pdf), perPage?: 1|2|3|4|6|9, paper?: letter|a4|legal|a3 (pdf), orientation?: portrait|landscape (pdf), dpi?, slides?: [index]|range ("1-3,5"), includeHidden?, textLayer?, frame?, transparentBackground?: bool (png: leave the slide background out), width?: px 16-3840|small|medium|large|extraLarge (gif), secondsPerSlide?: 0.1-600 (gif; 5), loop?: bool (gif; true: forever)} → {path, bytes} or {files} (png, jpeg); gif adds frames, width, height, secondsPerSlide
- file.info — Info → {title, path, format, dirty, slides, hiddenSlides, sections, bytes?, properties}
- file.render — Render Slide: {slide?: index, scale?, edit?: bool, transparentBackground?: bool} → {png: base64, width, height}
- file.close — Close
- file.properties — Properties: {title?, subject?, author?, keywords?, comments?, category?, company?} → properties
- file.recovery.save — Save AutoRecover Information → {written}
- file.recovery.list — Recovered Presentations → [{uid, path, title, saved}]
- file.recovery.open — Open Recovered Presentations → {opened: [document index]}
- file.recovery.discard — Discard Recovered Presentations: {uid?: one entry (else all)}
- file.revert — Revert

## slide (19)

- slide.colorAt — Color At: {slide?: index, x, y (slide units), scale?: px per unit (2)} → {color: "RRGGBB", alpha: 0..255, x, y}: the colour drawn at a point of the slide (the Eyedropper)
- slide.new — New Slide: {layout?: layout name or kind (title, titleAndContent, sectionHeader, twoContent, comparison, titleOnly, blank, contentWithCaption, pictureWithCaption), at?: index, title?: text, body?: text}
- slide.duplicate — Duplicate Slide: {index?}
- slide.delete — Delete Slide: {index?, ids?: [slide id]}
- slide.move — Move Slide: {from?: index, to: index}
- slide.go — Go to Slide: {index} | {id}
- slide.next — Next Slide
- slide.previous — Previous Slide
- slide.first — First Slide
- slide.last — Last Slide
- slide.selectSlides — Select Slides: {ids?: [slide id], indices?: [index], add?: bool}
- slide.hide — Hide Slide: {index?, hidden?: bool}
- slide.layout — Layout: {layout: name or kind, index?}
- slide.reset — Reset: {index?}
- slide.notes — Notes: {text | body: formatted notes (as in slide.inspect's notesBody), index?} (text as typed: untouched notes keep their formatting)
- slide.rename — Rename Slide: {name, index?}
- slide.fromOutline — Slides from Outline…: {text, markdown?: bool (headings are slides, list items bullets)}
- slide.reuse — Reuse Slides…: {path? | data: base64, name?, slides?: [index] (0-based, default all), keepFormatting?: bool (default false: use the destination theme), at?: index (default after the current slide)}
- slide.inspect — Inspect Slide: {index?} → the slide's shapes with ids, kinds, boxes, text, fills, animations, transition, notes (text, and notesBody with its formatting)

## window (1)

- window.next — Next Window: {index?}

## edit (12)

- edit.undo — Undo
- edit.redo — Redo
- edit.cut — Cut: {scope?: slides} → {text, html?}
- edit.copy — Copy: {scope?: slides} → {text, html?}
- edit.paste — Paste: {text?: plain text to paste, html?: rich text from another app, scope?: slides}
- edit.pasteSpecial — Paste Special: {as: destinationTheme|keepSource|picture|text} — Use Destination Theme, Keep Source Formatting, Picture (PNG), Keep Text Only
- edit.pasteText — Paste and Match Formatting: {text?}
- edit.duplicate — Duplicate: {ids?}
- edit.delete — Delete: {ids?, scope?: slides}
- edit.selectAll — Select All: {scope?: slides}
- edit.deselect — Deselect
- edit.select — Select Objects: {ids: [id], add?: bool, toggle?: bool}

## section (5)

- section.add — Add Section: {name?, at?: slide index}
- section.rename — Rename Section: {index, name}
- section.remove — Remove Section: {index, slides?: bool (also delete its slides)}
- section.removeAll — Remove All Sections
- section.move — Move Section: {index, to}

## shape (33)

- shape.insert — Shapes: {preset: rect|roundRect|ellipse|triangle|rightArrow|star5|… (see shape.presets), rect: [x,y,w,h] pt, text?: string}
- shape.presets — Shape Gallery → [{name, label, category}]
- shape.action — Action Settings: {on?: click|hover, action: none|next|previous|first|last|lastViewed|endShow|playMedia|slide|url|customShow|program, slide?: index, url?, show?: custom show name, path?, highlight?: bool, tooltip?, ids?}
- shape.connect — Connect Shapes: {from: shape id, to: shape id, fromSite?, toSite?: site index (default: the closest pair), id?: existing line to glue (else a new connector), preset?: straightConnector1|bentConnector3|curvedConnector3} → {id}
- shape.freeform — Freeform: {points: [[x, y], …] slide pt (≥ 2), closed?: bool (filled shape), smooth?: bool (curve through the points)} → {id}
- shape.sites — Connection Sites: {id} → [[x, y]] connection sites in slide points
- shape.move — Move: {dx?: pt (relative), dy?: pt (relative), ids?} | {x?: pt (absolute), y?: pt (absolute), ids?}
- shape.resize — Size: {w?: pt, h?: pt, lockAspect?: bool, ids?}
- shape.setBounds — Position and Size: {x, y, w, h, ids?}
- shape.rotate — Rotation: {deg?: absolute, by?: relative, ids?, gesture?: move|end}
- shape.sizePosition — Size and Position…: {x?, y?: pt, w?, h?: pt, rot?: deg, scaleW?, scaleH?: percent of the current size (100 = unchanged), lockAspect?: bool, ids?} — with none of those keys, opens the dialog
- shape.flip — Flip: {axis: horizontal|vertical, ids?}
- shape.adjust — Adjust Shape: {index, value (file units), ids?}
- shape.change — Change Shape: {preset, ids?}
- shape.smoothCorners — Smooth Corners: {smoothing: 0..100 (%), radius?: pt (default: the rounded rectangle's own), ids?} → rectangle outline with smoothed (squircle) corners
- shape.fill — Shape Fill: {color? | none?: true | gradient?: {stops: [[pos, color]], angle?, kind?: linear|radial} | picture?: base64 | pattern?: {preset, fg, bg} | transparency?: 0..1 | reset?: true, ids?}; pictureProps?: {tile?: bool, offsetX?, offsetY?: pt, scaleX?, scaleY?: 0..10, align?: tl|t|tr|l|ctr|r|bl|b|br, mirror?: none|x|y|xy, stretch?: [l, t, r, b] fractions, rotateWithShape?: bool} adjusts a picture fill
- shape.line — Shape Outline: {color?, none?, width?: pt, dash?: solid|dot|dash|lgDash|dashDot|sysDot|sysDash, cap?: flat|round|square, join?: round|bevel|miter, compound?: single|double|thickThin|thinThick|triple, head?: none|triangle|stealth|diamond|oval|arrow, tail?, headSize?: sm|med|lg, tailSize?, reset?, ids?}
- shape.effects — Shape Effects: {shadow?: none|outer|inner|perspective|{color, blur, dist, dir}, glow?: none|{color, radius}, softEdges?: pt, reflection?: none|tight|half|full, bevel?: none|circle|…, threeD?: {camera?: preset, rotX?, rotY?, rotZ?: deg, z?: pt, bevelTop?, bevelBottom?: none|circle|…, bevelTopW?, bevelTopH?, bevelBottomW?, bevelBottomH?, depth?, contour?: pt, material?, lighting?, reset?: true}, shadowProps?: {color?, transparency?: 0..1, blur?: pt, dist?: pt, dir?: deg}, glowProps?: {color?, transparency?, radius?: pt}, reflectionProps?: {transparency?, size?: 0..1, dist?: pt, blur?: pt}, reset?, ids?} (the *Props keys adjust the current effect, adding a default one when there is none)
- shape.quickStyle — Quick Styles: {index: 0..41 (theme style row×accent), ids?}
- shape.rename — Rename: {name, id?}
- shape.altText — Alt Text: {text, decorative?: bool, ids?}
- shape.visible — Show/Hide: {visible?: bool, ids?}
- shape.lock — Lock: {locked?: bool (default: toggle), ids?} (a group locks or unlocks with everything in it)
- shape.setDefault — Set as Default Shape
- shape.merge — Merge Shapes: {op: union|combine|fragment|intersect|subtract, ids?: shapes in selection order (the first one's formatting is kept)} → {ids}
- shape.editPoints — Edit Points: {on?: bool (default: toggle), id?} — enter or leave Edit Points for one selected shape; entering turns a preset into a freeform
- shape.points — Points: {id?} → {id, paths: [[[x, y] slide pt]], types: [[smooth|straight|corner]]} vertices of a freeform
- shape.movePoint — Move Point: {path?: 0, index, x, y: slide pt, id?}
- shape.addPoint — Add Point: {path?: 0, segment: index of the vertex ending it, t?: 0..1 (0.5), id?}
- shape.pointType — Point Type: {path?: 0, index, type: smooth|straight|corner, id?} — smooth: handles in line and equal; straight: in line; corner: independent
- shape.moveHandle — Move Handle: {path?: 0, index, side: in|out, x, y: slide pt, type?: smooth|straight|corner (default: read from the handles), id?}
- shape.deletePoint — Delete Point: {path?: 0, index, id?}
- shape.inspect — Inspect Shape: {id} → full shape JSON plus its effective box

## insert (18)

- insert.icon — Icons: {name: star|arrow-right|… (see insert.icons), rect?: [x,y,w,h]}
- insert.icons — Icon Gallery → [{name, label, category}]
- insert.textBox — Text Box: {rect?: [x,y,w,h], text?: string}
- insert.picture — Picture from File…: {path? | data: base64, name?, rect?: [x,y,w,h]}
- insert.photoAlbum — Photo Album…: {pictures?: [{path?|data: base64, name?, rot?: deg, brightness?: -1..1, contrast?: -1..1} | {text}], layout?: fit|1|2|4|1title|2title|4title, frame?: none|rect|rounded|simple, captions?: bool, grayscale?: bool, theme?: name} — omit pictures to open the dialog
- insert.photoAlbumEdit — Edit Photo Album…: {album?: id, pictures?: same as insert.photoAlbum, layout?, frame?, captions?, grayscale?, theme?} — omit pictures to reopen the dialog on the current album
- insert.table — Table…: {rows, cols, rect?}
- insert.chart — Chart…: {type?: column|bar|line|pie|doughnut|area|scatter|stackedColumn|…, rect?, categories?: [..], series?: [{name, values}]}
- insert.audio — Audio from File…: {path? | data: base64, name?, rect?}
- insert.video — Video from File…: {path? | data: base64, name?, rect?}
- insert.wordArt — WordArt: {text?, style?: 0..}
- insert.slideNumber — Slide Number
- insert.dateTime — Date & Time: {format?: datetime1..datetime13, update?: bool, language?: en-US|en-GB|fr-FR|ja-JP|sv-SE} — no keys opens the dialog
- insert.symbol — Symbol: {text: character(s)}
- insert.hyperlink — Link: {url? | slide?: index, tooltip?, text?: shown when nothing is selected, highlightClick?, ids?}
- insert.smartArt — SmartArt: {kind: list|process|cycle|hierarchy|pyramid|matrix, items?: [text] (leading tabs = sub-points), nodes?: [{text, level}]} → {id}
- insert.actionButton — Action Buttons: {kind: back|forward|beginning|end|home|information|return|movie|document|sound|help|custom, rect?}
- insert.zoom — Zoom: {kind?: slide|section|summary (default slide); slides?: [index] (slide and summary zooms); sections?: [index] (section zoom); returnToZoom?: bool (default: on for section and summary, off for slide)}

## chart (3)

- chart.type — Change Chart Type: {type, id?}
- chart.data — Edit Data: {categories?: [..], levels?: [[..]] (outer category levels, innermost first), series?: [{name, values}], id?}
- chart.options — Chart Elements: {title?: string|null, legend?: b|t|l|r|null, dataLabels?: bool, gridlines?: bool, palette?, binCount?: n|null, binSize?: n|null, subtotals?: [point index], quartiles?: exclusive|inclusive, upDownBars?: bool, id?}

## smartArt (13)

- smartArt.nodes — Text Pane: {id?} → {id, kind, nodes: [{text, level}]} (id: the SmartArt group or one of its shapes; default the selection)
- smartArt.setNodes — Edit SmartArt Text: {id?, nodes?: [{text, level}], lines?: [string] (leading tabs set the level), index?, text?, title?} (index + text edits one node; title: its Name and Title box)
- smartArt.addNode — Add Shape: {id?, index?, position?: after|before|below|above|assistant, text?} → {index} (default: after the last node)
- smartArt.removeNode — Remove Shape: {id?, index} (its sub-points move up one level)
- smartArt.promote — Promote: {id?, index}
- smartArt.demote — Demote: {id?, index}
- smartArt.layout — Change Layout: {id?, kind: list|blockList|hBulletList|process|chevron|verticalProcess|stepUp|cycle|blockCycle|radial|hierarchy|pyramid|invertedPyramid|matrix|titledMatrix|pictureList|pictureCaption|pictureProcess|pictureHList|timeline|venn|target|textCycle|continuousCycle|horizontalHierarchy|gridMatrix|gear|funnel|segmentedCycle|multidirectionalCycle|orgChart|halfCircleOrgChart|cycleMatrix|segmentedPyramid|pie|nameTitleOrgChart|verticalBoxList|trapezoidList|tableList|accentProcess|continuousBlockProcess|bendingProcess|linearVenn|stackedVenn|nestedTarget}
- smartArt.fromText — Convert to SmartArt: {id?, kind?} → {id} (a text box or placeholder becomes a SmartArt graphic in its place: one node per paragraph, indent levels kept)
- smartArt.toText — Convert to Text: {id?} → {id} (the graphic becomes a text box of its outline, bulleted by level)
- smartArt.toShapes — Convert to Shapes: {id?} (the graphic becomes a plain group of its shapes; the outline is dropped)
- smartArt.picture — Insert Picture in SmartArt: {id?, index, data?: base64 | path?: string | reset?: bool} (the node's picture placeholder in picture layouts)
- smartArt.style — SmartArt Styles: {id?, style: flat|subtle|intense|outline|polished|inset|cartoon|powder|brick}
- smartArt.colors — Change Colors: {id?, colors: colorful|range23|range34|range45|range56|accent1|…|accent6|accent1Grad|…|accent6Grad}

## draw (1)

- draw.inkToShape — Ink to Shape → {shapes: [ids], kept: n} turns recognisable ink strokes on the slide into lines, rectangles, ellipses and triangles

## picture (12)

- picture.crop — Crop: {left?: fraction 0..1, top?: fraction 0..1, right?: fraction 0..1, bottom?: fraction 0..1, ids?}
- picture.adjust — Corrections: {brightness?: -1..1, contrast?: -1..1, saturation?: 0..4, grayscale?: bool, transparency?: 0..1, reset?: bool, ids?}
- picture.reset — Reset Picture: {ids?}
- picture.change — Change Picture: {path? | data: base64, name?, ids?}
- picture.removeBackground — Remove Background: {tolerance?: 0..100 (how different a colour may be from the edge's, default 20), ids?}
- picture.style — Picture Styles: {style: simpleFrameWhite|dropShadowRectangle|softEdgeOval|… | none (see picture.styles), ids?}
- picture.styles — Picture Style Gallery → [{id, label}]
- picture.recolor — Recolor: {preset: none|grayscale|sepia|washout|bw25|bw50|bw75|accent1Dark…accent6Dark|accent1Light…accent6Light|tx2Dark|tx2Light (see picture.recolors), ids?}
- picture.recolors — Recolor Gallery → [{id, label}]
- picture.transparentColor — Set Transparent Color: {color: #RRGGBB | none: true, ids?} (pixels of that colour become transparent)
- picture.artisticEffect — Artistic Effects: {effect: none|artisticBlur|artisticPencilGrayscale|artisticLineDrawing|artisticFilmGrain|artisticCutout|artisticGlowEdges|artisticPhotocopy, ids?}
- picture.compress — Compress Pictures: {ppi?: 330|220|150|96 (default 220), deleteCropped?: bool (default true), all?: bool (every picture in the presentation; default the selected pictures), ids?} → {pictures, before, after}

## media (9)

- media.options — Playback: {autoplay?, loop?, rewind?, acrossSlides?, hide?, fullScreen?, volume?: 0..1, trimStart?: ms, trimEnd?: ms, fadeIn?: ms, fadeOut?: ms, ids?}
- media.play — Play: {id?, from?: ms}
- media.pause — Pause: {id?}
- media.toggle — Play/Pause: {id?}
- media.stop — Stop: {id?}
- media.seek — Seek: {id?, ms}
- media.info — Media Info: {id?} → {id, name, contentType, bytes, durationMs, video, width, height, probe: {container, audio?, video?}, options, status?}
- media.posterFrame — Poster Frame: {id?, ms?: frame time (default: current position)}
- media.gifPlay — Play/Pause GIF: {id?, play?: bool (default: toggle)} → {id, playing}

## guide (4)

- guide.add — Add Guide: {vertical: bool, pos?: pt (default: the slide's centre)} → {index}. `defaults: true` adds the two centre guides when there are none
- guide.move — Move Guide: {index, pos: pt}
- guide.delete — Delete Guide: {index}
- guide.list — Guides → [{vertical, pos}]

## arrange (15)

- arrange.bringToFront — Bring to Front: {ids?}
- arrange.bringForward — Bring Forward: {ids?}
- arrange.sendBackward — Send Backward: {ids?}
- arrange.sendToBack — Send to Back: {ids?}
- arrange.reorder — Reorder Objects: {id, index: position among its siblings (0 = back; a group's child stays in its group)} → {index}
- arrange.group — Group: {ids?}
- arrange.ungroup — Ungroup: {ids?}
- arrange.regroup — Regroup
- arrange.align — Align: {edge: left|center|right|top|middle|bottom, to?: slide|selection (default: slide for one object), ids?}
- arrange.distribute — Distribute: {dir: horizontal|vertical, to?: slide|selection, ids?}
- arrange.rotateLeft — Rotate Left 90°: {ids?}
- arrange.rotateRight — Rotate Right 90°: {ids?}
- arrange.flipHorizontal — Flip Horizontal: {ids?}
- arrange.flipVertical — Flip Vertical: {ids?}
- arrange.nudge — Nudge: {dx, dy, ids?} (arrow keys: 6 pt, with Alt 1 pt)

## selection (3)

- selection.select — Select: {ids | id, toggle?: bool (Ctrl+click), add?: bool} → {selected}: objects in groups too; a hidden object picked from the list is shown
- selection.showAll — Show All shows every object on the slide, inside groups too
- selection.hideAll — Hide All hides every top-level object on the slide

## font (4)

- font.used — Fonts in Presentation → [family] (theme fonts resolved)
- font.replace — Replace Fonts: {from, to} — every explicit use of family `from`, theme fonts included → {replaced}
- font.add — Add Font: {data: base64 TTF/OTF/TTC} → {faces} added for this session
- font.rescan — Rescan Installed Fonts → {faces, families} (fonts installed since start-up)

## text (16)

- text.edit — Edit Text: {id?, at?: [paragraph, char], end?: bool, cell?: [row, col], notes?: bool}
- text.exit — Stop Editing Text
- text.autocorrect — AutoCorrect Options: {on?, twoInitials?, sentenceCaps?, days?, capsLock?, fractions?, ordinals?: bool, add?: [from, to], remove?: from} → the options and the replacement list
- text.insert — Type Text: {text} (\n = new paragraph, \u000b = line break)
- text.compose — Compose Text: {text, active?: [start, end]} — an input method's composition (preedit) at the insertion point; empty text cancels it
- text.commit — Commit Composition: {text} — the input method's result replaces its composition, as one undo step
- text.delete — Delete Text: {dir?: backward|forward|wordBackward|wordForward} — the word directions are Ctrl+Backspace/Delete: they work from the start of a selection without deleting it
- text.move — Move Insertion Point: {to: left|right|up|down|wordLeft|wordRight|lineStart|lineEnd|paraStart|paraEnd|paraUp|paraDown|start|end, extend?: bool} — left/right are on screen: in a right-to-left paragraph left goes forward
- text.select — Select Text: {anchor: [p, c], caret: [p, c]}
- text.selectAll — Select All Text
- text.selectWord — Select Word: {at?: [p, c]}
- text.selectParagraph — Select Paragraph: {at?: [p, c]}
- text.set — Set Text: {id?, text, cell?: [r, c]} — replaces the whole text, keeping the first run's formatting
- text.get — Get Text: {id?} → {text, paragraphs}
- text.find — Find: {text, matchCase?: bool, wholeWords?: bool} → [{slide, shape (null = notes), cell?: [row, col], para, start, end}] (char offsets in the paragraph)
- text.replace — Replace: {text, with, matchCase?, wholeWords?, at?: a text.find match (replace just that one; default: replace all)} → {replaced}

## format (46)

- format.bold — Bold: {on?: bool}
- format.italic — Italic: {on?: bool}
- format.underline — Underline: {on?: bool, style?: sng|dbl|heavy|dotted|dash|wavy}
- format.strikethrough — Strikethrough: {on?: bool, double?: bool}
- format.superscript — Superscript: {on?: bool}
- format.subscript — Subscript: {on?: bool}
- format.font — Font: {family}
- format.size — Font Size: {size: pt}
- format.grow — Increase Font Size
- format.shrink — Decrease Font Size
- format.color — Font Color: {color: #RRGGBB|accent1..6|tx1…|{scheme, lumMod…}}
- format.textTransparency — Text Transparency: {value: 0..1} — 0 opaque, 1 invisible; keeps the text's colour (inherited colours included)
- format.language — Language: {lang?, noProof?: bool} (proofing language of the selected text, and Do Not Check Spelling)
- format.highlight — Text Highlight Color: {color? (absent = none)}
- format.case — Change Case: {mode?: cycle|sentence|lower|upper|title|toggle} — cycle (Shift+F3, the default) goes lowercase → Capitalize Each Word → UPPERCASE; a caret in a word changes that word
- format.caps — Caps: {caps: none|small|all}
- format.spacing — Character Spacing: {pt} (veryTight -3, tight -1.5, normal 0, loose 3, veryLoose 6)
- format.clear — Clear All Formatting
- format.fontDialog — Font…: {family?, size?: pt, bold?: bool, italic?: bool, underline?: none|sng|dbl|heavy|dotted|dash|wavy, color?, strike?: none|sng|dbl, baseline?: none|super|sub|<fraction>, caps?: none|small|all, spacing?: pt} — with none of these, opens the Font dialog
- format.textShadow — Text Shadow: {on?: bool}
- format.textOutline — Text Outline: {color?, width?: pt} (no color = none)
- format.textWarp — Text Transform: {preset: a prstTxWarp name or none, adj?: [finite raw guide values, at most 8]} — none clears the transform; omitted adj uses the preset's defaults
- format.align — Align: {align: left|center|right|justify|justifyLow|distributed}
- format.rtl — Right-to-Left Text Direction: {on?: bool} (off = left-to-right; switching mirrors left/right alignment)
- format.alignLeft — Align Left
- format.alignCenter — Center
- format.alignRight — Align Right
- format.justify — Justify
- format.bullets — Bullets: {on?: bool, char?: •|○|■|□|◆|➢|✓|–, color?, size?: % of text}
- format.numbering — Numbering: {on?: bool, scheme?: arabicPeriod|arabicParenR|romanUcPeriod|romanLcPeriod|alphaUcPeriod|alphaLcParenR|alphaLcPeriod, start?: n, color?, size?: % of text}
- format.indent — Increase List Level
- format.outdent — Decrease List Level
- format.lineSpacing — Line Spacing: {lines?: 1.0|1.5|2.0…, pt?: exactly}
- format.paragraph — Paragraph…: {align?, indentLeft?: pt, indentFirst?: pt (negative = hanging), spaceBefore?: pt, spaceAfter?: pt, lineSpacing?: lines}
- format.ruler — Ruler → {x, y, width, rotated, marginLeft, indent, tabs: [{pos, align}], defaultTab} for the paragraph with the caret (x, y: the text area's top-left in slide pt)
- format.paragraphDialog — Paragraph…: {align?: left|center|right|justify|justLow|distributed, indentLeft?: pt, indentRight?: pt, special?: none|first|hanging, specialBy?: pt, indentFirst?: pt, spaceBefore?: pt, spaceAfter?: pt, spaceBeforeKind?: pts|pct, spaceAfterKind?: pts|pct, lineSpacing?: lines, lineSpacingPt?: pt} — with none of these, opens the Paragraph dialog
- format.tabs — Tabs…: {set?: [{pos, align?}] (replaces all), add?: {pos, align?: l|ctr|r|dec}, move?: {from, to}, remove?: pos, clear?: bool, defaultTab?: pt} on the selected paragraphs; with none of them, opens the Tabs dialog (pos in pt from the text area's left)
- format.anchor — Align Text: {anchor: top|middle|bottom}
- format.direction — Text Direction: {dir: horizontal|rotate90|rotate270|stacked}
- format.columns — Columns: {count, spacing?: pt}
- format.autofit — Autofit: {mode: none|shrink|resize}
- format.wrap — Wrap Text in Shape: {on: bool}
- format.margins — Text Box Margins: {left?: pt, top?: pt, right?: pt, bottom?: pt}
- format.painter — Format Painter: {sticky?: bool}
- format.painterApply — Paste Formatting: {ids?}
- format.state — Formatting State → the effective formatting at the selection (font, size, bold, …)

## design (14)

- design.theme — Themes: {name} (see design.themes)
- design.browseTheme — Browse for Themes…: {path} | {name, data: base64} — apply the theme of a .thmx, .pptx or .potx file
- design.themes — Theme Gallery → themes, colour schemes, font schemes and effect schemes
- design.colors — Colors opens Create New Theme Colors | {name} | {colors: {dk1|lt1|dk2|lt2|accent1..6|hlink|folHlink: #RRGGBB}}
- design.variant — Variants: {index: 0..3} (see design.variants)
- design.variants — Variant Gallery → the current theme's four colour variants and which is applied
- design.fonts — Fonts opens Create New Theme Fonts | {name} | {major, minor}
- design.effects — Effects: {name} (see design.themes)
- design.background — Format Background: {color? | gradient? | picture?: base64 | pattern? | style?: 1..12 | reset?, all?: bool, index?, transparency?: 0..1, pictureProps?: {tile?, offsetX?, offsetY?: pt, scaleX?, scaleY?: 0.01..10, align?, mirror?, stretch?: [l,t,r,b], rotateWithShape?}, copy?: bool}
- design.hideBackgroundGraphics — Hide Background Graphics: {hide?: bool}
- design.slideSize — Slide Size: {preset: widescreen|standard|…, orientation?: portrait|landscape, scale?: maximize|ensureFit|none} | {w: pt, h: pt, orientation?: portrait|landscape, scale?: maximize|ensureFit|none}
- design.headerFooter — Header and Footer…: {date?: bool, dateText?: fixed text, slideNumber?: bool, footer?: bool, footerText?, hideOnTitle?: bool, all?: bool (default true)}
- design.ideas — Design Ideas: {slide?} → [{id, label}] ideas for the slide
- design.applyIdea — Apply Design Idea: {id, slide?}

## view (4)

- view.slideMaster — Slide Master: {master?: index, layout?: index}
- view.handoutMaster — Handout Master (creates the handout master with header, date, footer and page number if the deck has none)
- view.notesMaster — Notes Master (creates the notes master with header, date, slide image, notes body, footer and page number if the deck has none)
- view.closeMaster — Close Master View

## handout (1)

- handout.placeholders — Handout Placeholders: {header?: bool, date?: bool, footer?: bool, pageNumber?: bool} (show or hide each)

## notes (1)

- notes.placeholders — Notes Placeholders: {header?, date?, slideImage?, body?, footer?, pageNumber?: bool} (show or hide each)

## master (6)

- master.insertLayout — Insert Layout: {name?}
- master.renameLayout — Rename Layout: {name, master?, layout?}
- master.deleteLayout — Delete Layout: {master?, layout?}
- master.insertPlaceholder — Insert Placeholder: {kind: content|text|picture|chart|table|media, rect?: [x,y,w,h]}
- master.preserve — Preserve: {preserve?: bool}
- master.placeholders — Layout Placeholders: {title?: bool, footers?: bool}

## transition (6)

- transition.set — Transition: {kind: none|morph|fade|push|wipe|split|reveal|cut|randomBar|shape|uncover|cover|flash|… (transition.list), option?, duration?: ms, index?}
- transition.options — Effect Options: {option, index?}
- transition.timing — Timing: {duration?: ms, onClick?: bool, after?: ms | null, index?}
- transition.sound — Sound: {builtin?: chime|click|camera|whoosh|drumRoll|laser | path? | data: base64, name?, none?: true (No Sound), stopPrevious?: true, loop?: bool (Loop Until Next Sound), index?} — the sound plays as the slide comes in
- transition.applyAll — Apply To All
- transition.list — Transition Gallery → [{id, label, category, duration, options}]

## animation (11)

- animation.set — Animation Styles: {effect: fade|fly|zoom|wipe|appear|spin|pulse|fadeOut|lines|… (animation.list), class?: entrance|emphasis|exit|path, option?, ids?} — replaces the shapes' animations
- animation.add — Add Animation: {effect, class?, option?, start?: onClick|withPrevious|afterPrevious, duration?: ms, delay?: ms, ids?}
- animation.remove — Remove Animation: {index} | {ids? (all of the shapes' animations)}
- animation.move — Reorder Animation: {index, to}
- animation.timing — Timing: {index? (else selected shapes), start?: onClick|withPrevious|afterPrevious, duration?: ms, delay?: ms, repeat?: n, rewind?: bool, trigger?: shape id | null}
- animation.options — Effect Options: {option?, textBuild?: asOne|byParagraph|byWord|byLetter, index?}
- animation.clear — Remove All Animations: {index?: slide}
- animation.painter — Animation Painter: {sticky?: bool, id?}
- animation.painterApply — Apply Animation: {ids?}
- animation.list — Animation Gallery → [{id, label, class, options}]
- animation.get — Animations on Slide: {slide?} → [animation]

## table (21)

- table.insertRowAbove — Insert Above: {row?, id?}
- table.insertRowBelow — Insert Below: {row?, id?}
- table.insertColumnLeft — Insert Left: {col?, id?}
- table.insertColumnRight — Insert Right: {col?, id?}
- table.deleteRow — Delete Rows: {row?, id?}
- table.deleteColumn — Delete Columns: {col?, id?}
- table.merge — Merge Cells: {from: [r, c], to: [r, c], id?}
- table.split — Split Cells: {cell?: [r, c] (else the edited cell), id?} | {row?: index, col?: index, id?}
- table.style — Table Styles: {style: medium2-accent1|light1-accent2|dark1-tx1|grid|none…, id?}
- table.options — Table Style Options: {headerRow?: bool, totalRow?: bool, bandedRows?: bool, firstColumn?: bool, lastColumn?: bool, bandedColumns?: bool, id?}
- table.cellFill — Shading: {color? | none?, cells?: [[r,c],…] (default: selected cells or all), id?}
- table.borders — Borders: {which: all|outside|inside|insideH|insideV|top|bottom|left|right|diagDown|diagUp|none, color?, width?: pt, dash?: solid|dash|dot…, cells?: [[r,c],…] (default: selected cells or all), id?}
- table.cellMargins — Cell Margins: {preset?: normal|none|narrow|wide, left?, right?, top?, bottom?: pt, cells?, id?}
- table.cellAlign — Align Cell Text: {anchor: top|middle|bottom, cells?, id?}
- table.distributeRows — Distribute Rows: {id?}
- table.distributeColumns — Distribute Columns: {id?}
- table.columnWidth — Width: {col, width: pt, keepTotal?: bool (the next column absorbs the change), id?}
- table.rowHeight — Height: {row, height: pt, id?}
- table.drawLine — Draw Table: {from: [x, y], to: [x, y] slide pt, id?: table (default: the one under `from`)} splits the cells the line crosses
- table.eraseLine — Table Eraser: {at: [x, y] slide pt, id?, tol?: pt (default 6)} merges the two cells on either side of the nearest border
- table.selectCells — Select Cells: {from: [r,c], to: [r,c], id?}

## comment (7)

- comment.add — New Comment: {text, x?, y?, id?: shape}
- comment.reply — Reply: {index, text}
- comment.delete — Delete Comment: {index? | all?: bool}
- comment.resolve — Resolve Thread: {index, resolved?: bool}
- comment.list — Comments: {slide?} → comments
- comment.next — Next Comment: {slide?, index?} → {slide, index, text}
- comment.prev — Previous Comment: {slide?, index?} → {slide, index, text}

## review (11)

- review.accessibility — Check Accessibility → [{slide, shape, issue}]
- review.spelling — Spelling: {lang?, ignore?:[word]} → [{slide, shape?, row?, col?, notes?, para, start, end, word, lang, suggestions}] (shapes, table cells and notes; repeated words as {repeated, deleteFrom}; runs marked noProof skipped; each run in its own language, lang? for runs without one; Hunspell dictionaries installed on the system, else a built-in list of common misspellings)
- review.spellingChange — Change Spelling: {shape, word, to, all?, para?, start?, row?, col?} → {changed} (replace the whole word in that shape's text, the one at para/start, or in every shape with all)
- review.addToDictionary — Add to Dictionary: {word} → {word, file} (append to the user dictionary file; not an undo step)
- review.dictionary — Spelling Dictionary: {lang?} → {lang, available, found, folders} (whether review.spelling has a dictionary, and which file)
- review.thesaurus — Thesaurus: {word? (default: the selected word, or the word at the caret)} → {word, senses: [{word, synonyms}]}
- review.replaceWord — Insert Synonym: {with}: replace the selected word (or the word at the caret) while editing text
- review.compare — Compare: {path} | {name, data: base64} — compare with a revised copy → {name, changes}
- review.revisions — Revisions → {name, changes: [{kind: inserted|deleted|changed, slide, revised, details}]}
- review.accept — Accept Revision: {index} | {all: true}
- review.endCompare — End Review

## show (4)

- show.fromStart — Play from Start
- show.fromCurrent — Play from Current Slide
- show.setup — Set Up Slide Show…: {type?: speaker|browsed|kiosk, loop?: bool, noNarration?, noAnimation?, useTimings?, showMediaControls?, from?, to?, custom?: name}
- show.customShow — Custom Slide Show: {name, slides: [index]} | {name, delete: true}

## document (1)

- document.inspect — Inspect Presentation → slides with titles, layouts, shape counts; selection; size; theme

## commands (1)

- commands.list — List Commands: {filter?: substring} → [{id, label, params, enabled}]
