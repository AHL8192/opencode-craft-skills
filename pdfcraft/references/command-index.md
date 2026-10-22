# PdfCraft command registry (201 ids) — verified 2026-10-22 (0.10.1)

Every Ribbon/menu action is a registry command. `command_list` reads this list;
`command_run id=… params={…}` runs one; `command_batch` runs up to 1000 steps.
Tools marked `—` have no direct MCP wrapper. Unknown `params` keys are ignored **with warnings**.

| id | menu | label | tool |
|---|---|---|---|
| `a11y.alt_text` |  | Add alternate text… | accessibility_figures |
| `a11y.autotag` |  | Automatically tag PDF | — |
| `a11y.autotag_fields` |  | Tag form fields | accessibility_autotag_form_fields |
| `a11y.check` |  | Check for accessibility… | accessibility_check |
| `a11y.find_untagged` |  | Find untagged content | accessibility_find_untagged |
| `a11y.reading_options` |  | Change reading options… | view_reading_colors |
| `a11y.report` |  | Open accessibility report | accessibility_report |
| `a11y.tags` |  | Tags panel | accessibility_tags |
| `actions.distribution` |  | Prepare for distribution… | — |
| `actions.optimize_scans` |  | Optimize scanned documents… | — |
| `actions.wizard` |  | Action Wizard… | action_list |
| `app.preferences` | Edit | Preferences… | — |
| `bookmark.add` | Pages | New bookmark | — |
| `bookmark.from_structure` | Pages | New bookmarks from structure | — |
| `comment.arrow` |  | Draw an arrow | — |
| `comment.attach` |  | Attach a file | — |
| `comment.callout` |  | Add a callout | — |
| `comment.caret` |  | Insert text | — |
| `comment.circle` |  | Draw an oval | — |
| `comment.cloud` |  | Draw a cloud | — |
| `comment.eraser` |  | Erase drawings | — |
| `comment.export` |  | Export all comments to data file… | — |
| `comment.flatten` |  | Flatten comments | — |
| `comment.freetext` |  | Add a text box | — |
| `comment.hide_all` |  | Hide all comments | comments_hide |
| `comment.highlight` |  | Highlight text | — |
| `comment.import` |  | Import comments… | — |
| `comment.ink` |  | Draw freehand | — |
| `comment.line` |  | Draw a line | — |
| `comment.list` | View | Comments panel | — |
| `comment.note` |  | Add a sticky note | — |
| `comment.polygon` |  | Draw a polygon | — |
| `comment.polyline` |  | Draw connected lines | — |
| `comment.replace` |  | Replace text | — |
| `comment.square` |  | Draw a rectangle | — |
| `comment.squiggly` |  | Squiggly underline text | — |
| `comment.stamp` |  | Add a stamp | stamp_custom |
| `comment.strikeout` |  | Strikethrough text | — |
| `comment.summarize` |  | Summarize comments | comments_summarize |
| `comment.underline` |  | Underline text | — |
| `create.blank` | File | New blank PDF | — |
| `create.clipboard` | File | Create PDF from clipboard | — |
| `create.file` | File | Create PDF from file… | — |
| `create.images` | File | Create PDF from images… | — |
| `create.multiple` | File | Create PDF from multiple files… | doc_create_multiple |
| `create.multiple_separate` | File | Create separate PDFs… | — |
| `doc.compare` |  | Compare files… | doc_compare |
| `edit.advanced_search` | Edit | Advanced search… | — |
| `edit.background` |  | Add background… | doc_background |
| `edit.background.remove` |  | Remove background | — |
| `edit.background.update` |  | Update background… | — |
| `edit.bates` |  | Add Bates numbering… | — |
| `edit.column_select` | Edit | Column select | text_extract |
| `edit.copy` | Edit | Copy | — |
| `edit.edit_text` |  | Edit text & images | text_lines |
| `edit.find` | Edit | Find… | text_find |
| `edit.header_footer` |  | Add header & footer… | doc_header_footer |
| `edit.header_footer.remove` |  | Remove header & footer | — |
| `edit.header_footer.update` |  | Update header & footer… | — |
| `edit.image` |  | Add image… | page_add_image |
| `edit.link` |  | Add or edit links | link_add |
| `edit.links_from_urls` |  | Create links from URLs | links_from_urls |
| `edit.redo` | Edit | Redo | edit_redo |
| `edit.remove_links` |  | Remove all links | links_remove |
| `edit.snapshot` | Edit | Take a snapshot | — |
| `edit.text` |  | Add text | page_add_text |
| `edit.undo` | Edit | Undo | edit_undo |
| `edit.watermark` |  | Add watermark… | doc_watermark |
| `edit.watermark.remove` |  | Remove watermark | — |
| `edit.watermark.update` |  | Update watermark… | — |
| `export.all_images` | File | Export all images… | doc_export_all_images |
| `export.docx` | File | Export to Word… | doc_export_office |
| `export.html` | File | Export to HTML… | — |
| `export.image` | File | Export to image… | doc_export_images |
| `export.pptx` | File | Export to PowerPoint… | — |
| `export.rtf` | File | Export to RTF… | — |
| `export.text` | File | Export to text… | doc_export_text |
| `file.clear_recent` |  | Clear Recent Files | — |
| `file.close` | File | Close file | doc_close |
| `file.close_all` | File | Close all | — |
| `file.open` | File | Open… | doc_open |
| `file.open_recent` | File | Open Recent | — |
| `file.pin_folder` | File | Pin folder to Home… | — |
| `file.properties` | File | Document properties… | doc_info |
| `file.revert` | File | Revert | — |
| `file.save` | File | Save | doc_save |
| `file.save_as` | File | Save as… | — |
| `file.word_count` | File | Word count… | text_word_count |
| `form.add.button` |  | Add a button | — |
| `form.add.checkbox` |  | Add a checkbox | — |
| `form.add.combo` |  | Add a drop-down list | — |
| `form.add.date` |  | Add a date field | — |
| `form.add.image` |  | Add an image field | — |
| `form.add.list` |  | Add a list box | — |
| `form.add.radio` |  | Add a radio button | — |
| `form.add.signature` |  | Add a digital signature field | — |
| `form.add.text` |  | Add a text field | — |
| `form.clear` | Edit | Clear form | — |
| `form.detect` |  | Detect form fields | form_detect_fields |
| `form.export_data` |  | Export form data… | — |
| `form.field.properties` |  | Field properties… | — |
| `form.fields` | View | Form fields panel | — |
| `form.flatten` |  | Flatten form fields | — |
| `form.import_data` |  | Import form data… | — |
| `form.merge_data` |  | Merge data files into spreadsheet… | form_merge_data |
| `form.prepare` |  | Prepare a form | form_set_script |
| `form.tab_order.column` |  | Tab order: by columns | — |
| `form.tab_order.row` |  | Tab order: by rows | — |
| `form.tab_order.structure` |  | Tab order: by document structure | — |
| `help.about` | Help | About PdfCraft | — |
| `help.app_page` | Help | PdfCraft web page | — |
| `help.check_updates` | Help | Check for updates… | — |
| `help.discord` | Help | Join the ArtCraft Discord | — |
| `help.github` | Help | PdfCraft on GitHub | — |
| `help.shortcuts` | Help | Keyboard shortcuts | — |
| `help.website` | Help | ArtCraft website | — |
| `measure.area` |  | Measure area | measure_area |
| `measure.distance` |  | Measure distance | measure_distance |
| `measure.export` |  | Export measurements as CSV | measure_export |
| `measure.info` |  | Measurement information | measure_info |
| `measure.perimeter` |  | Measure perimeter | measure_perimeter |
| `measure.scale` |  | Set measurement scale | measure_scale |
| `measure.snap` |  | Measurement snapping | measure_snap |
| `ocr.enhance_camera` |  | Enhance camera image | page_enhance_camera |
| `ocr.recognize` |  | Recognize text… | ocr_recognize |
| `ocr.recognize_batch` |  | Recognize text in multiple files… | ocr_recognize_files |
| `optimize.advanced` | File | Optimize PDF… | doc_audit_space |
| `optimize.reduce` | File | Reduce file size… | doc_reduce |
| `page.boxes` | Pages | Set page boxes… | page_set_box |
| `page.combine` | File | Combine files… | doc_combine |
| `page.copy` |  | Copy pages | — |
| `page.crop` | Pages | Crop pages | — |
| `page.cut` |  | Cut pages | — |
| `page.delete` | Pages | Delete pages | page_delete |
| `page.duplicate` | Pages | Duplicate pages | page_duplicate |
| `page.extract` | Pages | Extract pages… | page_extract |
| `page.insert` | Pages | Insert pages from file… | page_insert_file |
| `page.insert_blank` | Pages | Insert blank page | page_insert_blank |
| `page.number` | Pages | Number pages… | — |
| `page.organize` | Pages | Organize pages | — |
| `page.paste` |  | Paste pages | — |
| `page.replace` | Pages | Replace pages… | page_replace |
| `page.reverse` | Pages | Reverse pages | page_reverse |
| `page.rotate` | Pages | Rotate pages clockwise | page_rotate |
| `page.rotate_ccw` | Pages | Rotate pages counterclockwise | — |
| `page.rotate_dialog` | Pages | Rotate pages… | — |
| `page.split` | Pages | Split document… | doc_split |
| `print.dialog` | File | Print… | — |
| `protect.password` | File | Protect using password… | doc_protect |
| `protect.properties` | File | Security properties… | — |
| `protect.remove` | File | Remove security | doc_unprotect |
| `protect.remove_hidden` |  | Remove hidden information… | — |
| `protect.unlock` |  | Enter permissions password… | — |
| `redact.apply` |  | Apply redactions… | — |
| `redact.clear` |  | Clear redaction marks | — |
| `redact.mark` |  | Redact text and images | — |
| `redact.pages` |  | Redact pages… | — |
| `redact.properties` |  | Redaction properties… | — |
| `redact.sanitize` |  | Sanitize document… | — |
| `redact.search` |  | Find text and redact… | — |
| `sign.certify` |  | Certify (visible signature) | — |
| `sign.certify_invisible` |  | Certify (invisible signature) | — |
| `sign.digital` |  | Digitally sign | sign_windows_ids |
| `sign.fill.check` |  | Fill & Sign: checkmark | — |
| `sign.fill.cross` |  | Fill & Sign: cross | — |
| `sign.fill.date` |  | Fill & Sign: date | — |
| `sign.fill.dot` |  | Fill & Sign: dot | — |
| `sign.fill.initials` |  | Fill & Sign: initials | — |
| `sign.fill.initials.change` |  | Fill & Sign: change initials | — |
| `sign.fill.initials.remove` |  | Fill & Sign: remove saved initials | — |
| `sign.fill.line` |  | Fill & Sign: line | — |
| `sign.fill.signature` |  | Fill & Sign: sign | — |
| `sign.fill.signature.change` |  | Fill & Sign: change signature | — |
| `sign.fill.signature.remove` |  | Fill & Sign: remove saved signature | — |
| `sign.fill.text` |  | Fill & Sign: add text | fill_sign_add |
| `sign.panel` | View | Signatures panel | — |
| `sign.validate` |  | Validate all signatures | — |
| `standards.pdfa` |  | PDF/A… | pdfa_verify |
| `tools.document_js` |  | Document JavaScripts… | js_document_scripts |
| `tools.js_console` |  | JavaScript console… | js_run |
| `ui.dock.reset` | View | Reset panel layout | — |
| `view.continuous` |  | Continuous scrolling | — |
| `view.fit_one_page` |  | Fit one full page | — |
| `view.fit_visible` |  | Fit visible | — |
| `view.fit_width_scrolling` |  | Fit to width scrolling | — |
| `view.focus_page_input` | View | Go to page… | — |
| `view.full_screen` | View | Full screen mode | — |
| `view.layout.cover` |  | Show cover page in two-page view | — |
| `view.layout.single` |  | Single page | — |
| `view.layout.two_up` |  | Two-page view | — |
| `view.marquee_zoom` | View | Marquee zoom | — |
| `view.next_tab` | View | Next tab | — |
| `view.next_view` |  | Next view | — |
| `view.palette` | View | Find tools and commands… | — |
| `view.previous_tab` | View | Previous tab | — |
| `view.previous_view` |  | Previous view | — |
| `view.read_mode` | View | Read mode | — |
| `view.theme` |  | Switch light / dark theme | — |
| `view.theme.dark` |  | Dark gray | — |
| `view.theme.light` |  | Light gray | — |
| `view.theme.system` |  | Use system setting | — |