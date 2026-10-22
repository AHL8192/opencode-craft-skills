# PdfCraft MCP tools (171) — verified 2026-10-22 (0.10.1)

Generated from the live server (`pdfcraft-cli tools`). Arguments marked `*` are required.
Some read tools return their JSON in `content[0].text` instead of `structuredContent` — see `bugs-and-workarounds.md`.

## accessibility (18)

- **accessibility_autotag_apply** — Write marked content, a Document structure element, paragraph tags and a parent tree for every text object in an untagged, text-only PDF. Refuses graphics, images, annotations, forms,…  
  `doc*`
- **accessibility_autotag_form_fields** — Write `/Form` tags, widget structure-parent keys, and a parent tree for all page widgets in an untagged AcroForm. Existing tag trees are refused for review. Text, figures, links, and…  
  `doc*`
- **accessibility_autotag_preview** — Propose paragraph and heading tags for visible text blocks on one page. Returns page bounds, tentative roles and reasons. Does not change the PDF or claim accessibility compliance.…  
  `doc*, page*`
- **accessibility_check** — Run the Accessibility Checker's full check (32 rules in 7 categories: document, page_content, forms, alternate_text, tables, lists, headings). Each rule is passed, failed (with findings…  
  `all, categories, doc*, pages, rules`
- **accessibility_figures** — The tagged figures (Figure elements, through the role map) in document order: figure number, page, alternate text and where the figure is drawn (top-left-origin points).  
  `doc*`
- **accessibility_find_untagged** — Find untagged painted page content, annotations, and form widgets. This focused check does not modify the PDF or claim that its other accessibility rules pass.  
  `doc*, pages`
- **accessibility_fix** — Apply the checker's automatic fix for a rule: primary-language (value: the language, e.g. en-US), title (value: the title; default the current title or file name; also shows it in the…  
  `doc*, rule*, value`
- **accessibility_mark_tag_artifact** — Mark a reachable leaf structure tag's direct marked content as an artifact and remove the tag from the reading structure. Use object and generation from accessibility_tags. Tags with…  
  `doc*, generation*, object*`
- **accessibility_move_tag** — Move a reachable indirect structure tag before or after a direct sibling in their parent's /K array, changing tagged reading order without changing page appearance. Use object and…  
  `anchor*, anchor_generation*, doc*, generation*, object*, placement*`
- **accessibility_report** — Run the full check and write the accessibility report (HTML) to path; returns the results too. Takes the same options as accessibility_check.  
  `all, categories, doc*, pages, path*, rules`
- **accessibility_review_html** — Compare two open versions of a PDF and write a self-contained HTML summary of the same evidence as accessibility_review_record: document hashes, outcome counts, rule changes, and rules…  
  `after*, all, before*, path*`
- **accessibility_review_load** — Read a local review sidecar only when its recorded SHA-256 matches the open PDF. Returns the decisions without changing the PDF.  
  `doc*, path*`
- **accessibility_review_record** — Compare the same accessibility rules on two open versions of a PDF and write a JSON record to path. Includes document SHA-256 hashes, before/after rule statuses and finding counts,…  
  `after*, all, before*, path*`
- **accessibility_review_save** — Write a local JSON sidecar for an open PDF with rule-level human review decisions. The sidecar records the PDF SHA-256; replacing one tied to different bytes requires replace: true. Does…  
  `decisions*, doc*, path*, replace`
- **accessibility_set_alt** — Set a figure's alternate text (alt; empty or omitted clears it), or mark it decorative (decorative: true: its content becomes an artifact and the figure leaves the tags). figure is a…  
  `alt, decorative, doc*, figure*`
- **accessibility_set_tag_property** — Set or clear one property of a reachable indirect structure tag. Use object and generation from accessibility_tags. Properties: type, title, actual_text, alternate_text, language. Empty…  
  `doc*, generation*, object*, property*, value`
- **accessibility_tag_content** — List the marked-content references directly owned by one reachable indirect structure tag, including page, MCID and extracted text.  
  `doc*, generation*, object*`
- **accessibility_tags** — List reachable indirect structure tags in document order with PDF object number, generation, nearest indirect parent, depth, page, type, title, actual text, alternate text and language,…  
  `doc*, limit, max_depth, offset, pages, types`

## action (2)

- **action_list** — Action Wizard: the built-in actions (name, description, steps) and every step an action can use (id, label, whether it takes a text argument).  
  `—`
- **action_run** — Action Wizard: run a built-in action (action: its name) or a list of steps ([{step, arg}], ids from action_list) on each PDF in paths, writing the results into folder under the same…  
  `action, folder*, paths*, steps`

## bookmark (7)

- **bookmark_add** — Add a bookmark that goes to a page, under a parent bookmark (or at the top level), at a position. Undoable.  
  `doc*, page*, parent, position, title*`
- **bookmark_delete** — Delete a bookmark and the bookmarks under it. Undoable.  
  `doc*, path*`
- **bookmark_from_structure** — Make bookmarks from the document's tagged headings (H, H1-H6), nested by level under a new first bookmark titled "Untitled". Fails if the document has no tagged headings. Returns the…  
  `doc*`
- **bookmark_list** — The bookmarks in outline order, one page at a time: each with its path (1-based, as the other bookmark tools take it), title, target page and open state, and its children on the same…  
  `doc*, limit, offset`
- **bookmark_move** — Move a bookmark (with its children) under another parent, or within its level. Undoable.  
  `doc*, parent, path*, position`
- **bookmark_rename** — Change a bookmark's title. Undoable.  
  `doc*, path*, title*`
- **bookmark_set_page** — Point a bookmark at another page. Undoable.  
  `doc*, page*, path*`

## command (3)

- **command_batch** — Run steps in order (at most 1000). Returns completed/failed counts and per-step ok/result/error; stop_on_error defaults to true.  
  `steps*, stop_on_error`
- **command_list** — Every registered PdfCraft command with its menu, shortcut, whether it is enabled now, and the tool that automates it.  
  `doc, enabled_only, filter`
- **command_run** — Run a registry command through its headless tool. Pass that tool's arguments in params (see command_list). Unknown params are ignored with warnings; path confinement still applies.  
  `id*, params`

## comment (9)

- **comment_add** — Add a comment as Acrobat's commenting tools do. Geometry is in points with the origin at the top-left of the displayed page, y down (as in page_render images at 72 dpi and text_find…  
  `all, at, author, color, contents, doc*, dynamic, endings, fill, find, font_size, from, icon, knee, opacity, page*, path, points, quads, rect, stamp, strokes, to, type*, width`
- **comment_delete** — Delete a comment with its pop-up and replies. Undoable.  
  `doc*, id, index, page`
- **comment_edit** — Change a comment's text, colour, opacity, line width, font size (text box/typewriter/callout), fill (rectangle/oval/polygon/text box/callout; "none" removes it), rectangle…  
  `color, contents, doc*, fill, font_size, id, index, move, opacity, page, rect, width`
- **comment_image_preview** — Return a PNG of the page without the selected image signature/initials (layer=background, default), or its embedded image with alpha (layer=image). Includes the displayed rectangle,…  
  `doc*, dpi, id, index, layer, page`
- **comment_list** — Every comment (annotation other than links, form widgets and pop-ups) with its page, index, id, type, author, text, date, rectangle, colour, review status and replies.  
  `doc*, page`
- **comment_lock** — Lock or unlock a comment (Properties ▸ Locked). Locked comments can't be moved, resized, restyled or deleted; their text stays editable. Undoable.  
  `doc*, id, index, locked, page`
- **comment_mark** — Mark or unmark a comment with a checkmark (Acrobat: Mark with checkmark), recorded as a private reply. Undoable.  
  `author, doc*, id, index, marked, page`
- **comment_reply** — Add a reply to a comment's thread. Undoable.  
  `author, doc*, id, index, page, text*`
- **comment_set_status** — Set a comment's review status (Acrobat: Set status), recorded as a status reply. Undoable.  
  `author, doc*, id, index, page, status*`

## comments (2)

- **comments_hide** — Hide or show every comment on the page (fields and links still draw). A view setting: the file doesn't change.  
  `doc*, hidden`
- **comments_summarize** — Make a PDF summarising every comment (number, author, type, date, text, replies), sorted by page, author, date or type.  
  `doc*, open, out, sort`

## content (3)

- **content_delete** — Delete an added item (page, index from content_list). Undoable.  
  `doc*, index*, page*`
- **content_list** — Text and images added with page_add_text/page_add_image (or Edit a PDF ▸ Add content), per page with a 1-based index, rect (points from the top-left of the page), and text style.  
  `doc*`
- **content_update** — Move/resize (rect), retype (text) or restyle (font, size, bold, italic, color, align) an added item (page, index from content_list). Images: rotate (degrees, multiple of 90,…  
  `align, bold, color, crop, doc*, flip_h, flip_v, font, image, index*, italic, page*, rect, rotate, size, text`

## doc (38)

- **doc_audit_redactions** — Find faux redactions: opaque filled rectangles painted over text that is still extractable, and /Redact annotations that were marked but never applied. Paint-order and colour-aware: a…  
  `doc*`
- **doc_audit_space** — How many bytes each kind of content takes and its share of the file (PDF Optimizer ▸ Audit space usage): images, content streams, fonts, forms, comments, structure, bookmarks, … and…  
  `doc*`
- **doc_background** — Fill page backgrounds with a colour, or a picture from `file` (an image, or page `file_page` of a PDF) fitted at `scale` (default 1), behind the content. Undoable.  
  `color, doc*, file, file_page, opacity, pages, replace, scale`
- **doc_batch** — Run convert, ocr and/or optimize over files and folders, one file at a time. recursive defaults to false. Preserve paths relative to each selected folder inside out_dir; duplicate inputs…  
  `dpi, language, out_dir*, paths*, ppi, quality, recursive, skip_text_pages, steps*, stop_on_error`
- **doc_close** — Close a document. Fails if it has unsaved changes unless discard_changes is true.  
  `discard_changes, doc*`
- **doc_combine** — Combine files, in order, into one PDF (bookmarks are kept under one entry per file). Images (PNG, JPEG, TIFF, GIF, BMP, JPEG 2000) and .txt files are made into PDFs first. pages…  
  `field_conflicts, groups, open, out, pages, passwords, paths*`
- **doc_compare** — Compare the text of two open documents: other is the older version, doc the newer. Returns counts and each change (replaced, inserted, deleted) with the old and new text, pages (1-based)…  
  `doc*, limit, other*, visual`
- **doc_compare_mark** — Add the differences from other (older) to doc (newer) as comments in doc: highlights over replaced (blue) and inserted (green) text, notes where text was deleted (red), authored Compare.…  
  `doc*, other*`
- **doc_compare_report** — Write the compare summary report (a PDF listing every change) to path.  
  `doc*, other*, path*`
- **doc_create** — Create a new, unsaved document and return it like doc_open: `blank` (pages, width, height in points; default 1 US Letter page), `images` (paths of PNG, JPEG, TIFF (every page), GIF or…  
  `dpi, from*, height, name, pages, path, paths, text, width`
- **doc_create_multiple** — Convert several files (PDFs, PNG/JPEG/JPEG 2000/TIFF/GIF/BMP images, .txt files) to PDF in one run. mode "combine" (default) joins them, in order, into one PDF with a bookmark per file;…  
  `mode, open, out, out_dir, pages, paths*`
- **doc_export_all_images** — Write the images that pages use into a folder (`<name>_Page_<n>_Image_<k>.jpg|png`, n zero-padded to the page count's digits), each once: JPEG images unchanged, others as PNG with their…  
  `doc*, folder*, min_size, pages`
- **doc_export_data** — Write comments and/or form data to path; the extension picks the format: .xfdf or .fdf (comments and/or fields), .xml, .csv or .txt (form data). For an XFA form, .xml is its data alone…  
  `doc*, path*, what`
- **doc_export_images** — Write pages as PNG, JPEG or TIFF files (`<name>_page_<n>.png|jpg|tif`) into a folder, at a resolution (default 150 dpi). JPEG and TIFF are flattened onto white paper. A page too large…  
  `doc*, dpi, folder*, format, pages, quality`
- **doc_export_office** — Export a PDF ▸ Word (.docx), PowerPoint (.pptx, one slide per page), HTML (.html, one file with images inline) or RTF (.rtf), chosen by path's extension: text, headings, bold and italic.…  
  `doc*, path*`
- **doc_export_text** — Write the reading-order text of pages to a .txt file (pages separated by form feeds).  
  `doc*, pages, path*`
- **doc_flatten** — Merge comment and/or form field appearances into the page content, so they print and display everywhere but can no longer be edited. Flattening the fields of an XFA form also takes the…  
  `comments, doc*, fields`
- **doc_header_footer** — Add a header and/or footer to pages. Text boxes: header_left/center/right, footer_left/center/right. Tokens: <<1>> page number, <<n>> page count, <<1 of n>>, <<Page 1 of n>>, <<1/n>>,…  
  `color, doc*, font_size, footer_center, footer_left, footer_right, header_center, header_left, header_right, margins, pages, replace, start_number`
- **doc_hidden_info** — What Remove Hidden Information would remove, by category (metadata, attachments, comments, form-fields, hidden-text, hidden-layers, bookmarks, links-actions-scripts, private-data) with…  
  `doc*`
- **doc_import_data** — Import comments and/or field values from an XFDF, FDF, XML, CSV or tab-delimited text file (detected from its content). Comments with the same name are replaced; values go through the…  
  `doc*, path*`
- **doc_info** — Metadata, page sizes and labels, bookmarks, annotations, form fields, links, layers, page transitions and display times, attachments, fonts, security and repair notes.  
  `doc*`
- **doc_initial_view** — Read or change how the document opens (Document Properties ▸ Initial View) and its reading options: navigation (page, bookmarks, pages, attachments, layers), layout (default, single,…  
  `binding, center_window, display_title, doc*, fit_window, full_screen, hide_menubar, hide_toolbar, hide_window_ui, language, layout, magnification, navigation, page`
- **doc_inspect** — With doc, return doc_info; otherwise return information for every open document (empty documents array when none are open).  
  `doc`
- **doc_list** — List the open documents with their ids, page counts and unsaved state.  
  `—`
- **doc_open** — Open a PDF file and return its document id, page count and whether it can be edited.  
  `password, path*`
- **doc_open_revision** — Open saved revision `revision` (1 = the oldest) of a document as a new, unsaved document, to see the file as it was then.  
  `doc*, revision*`
- **doc_optimize** — Write an optimized copy to `path` (Acrobat's PDF Optimizer). preset: standard (default; Reduce File Size's choices) or mobile (images to 96 ppi above 144, JPEG high quality); the options…  
  `color, discard, discard_alternate_images, discard_print_settings, discard_tags, discard_thumbnails, doc*, flate_unencoded, gray, merge_fragments, path*, preset, remove_invalid_links, remove_unreferenced_dests`
- **doc_print** — Print with Acrobat's Print dialog options, or save the print-ready PDF. pages: a range such as "1-3, 6, 9-" (page labels allowed; default all); subset odd/even; reverse. layout: fit…  
  `as_image, auto_rotate, binding, booklet_subset, border, collate, comments_forms, copies, cut_marks, doc*, dpi, duplex, grayscale, layout, options, order, orientation, overlap, pages, paper, path, per_sheet, printer, reverse, scale, subset`
- **doc_protect** — Encrypt the document (applied by the next doc_save, a full rewrite). open_password is needed to open it. permissions_password is needed to change security and lifts the restrictions…  
  `accessibility, changes, compatibility, copy, doc*, encrypt_metadata, open_password, permissions_password, printing`
- **doc_reduce** — Write a smaller copy of the document to `path` with Acrobat's Reduce File Size choices: images above 225 ppi downsampled to 150 ppi and JPEG-compressed (medium quality), thumbnails…  
  `doc*, path*`
- **doc_remove_hidden** — Remove the listed categories (see doc_hidden_info), or every category when none are listed (Sanitize Document). Form fields are flattened so their values stay visible. The next save…  
  `categories, doc*`
- **doc_remove_marks** — Remove every header and footer, watermark or background PdfCraft (or a compatible tool) added. Undoable.  
  `doc*, kind*`
- **doc_revisions** — List the document's saved revisions (oldest first): each incremental update is one. Returns revision number, where it ends in the file and its size, and which signatures sign exactly…  
  `doc*`
- **doc_save** — Save to its own file (an incremental update, which keeps signatures valid) or to a new path (a full rewrite). The write is atomic. flatten_fill_sign bakes Fill & Sign text, marks and…  
  `doc*, flatten_fill_sign, full, path`
- **doc_set_info** — Set a document information entry such as Title, Author, Subject or Keywords, or a custom property under any other name (no spaces, delimiters, / or #; at most 127 bytes; doc_info lists…  
  `doc*, key*, value*`
- **doc_split** — Split into several files written to out_dir: every N pages, before given pages, at top-level bookmarks (bookmarks: true; files named after them, repeated titles get -2, -3), or by file…  
  `before, bookmarks, doc*, every, max_mb, out_dir*`
- **doc_unprotect** — Remove password security (the document must have been opened with its permissions password, or have none). Applied by the next doc_save. Undoable.  
  `doc*`
- **doc_watermark** — Add a watermark to pages: text, or a picture from `file` (an image, or page `file_page` of a PDF) at `scale` of the page (default 0.5); rotated (degrees counter-clockwise, default 45),…  
  `behind, color, doc*, file, file_page, font_size, offset_x, offset_y, opacity, pages, replace, rotation, scale, text`

## edit (2)

- **edit_redo** — Redo the last undone edit of a document.  
  `doc*`
- **edit_undo** — Undo the last edit of a document.  
  `doc*`

## fill (2)

- **fill_sign_add** — Fill in a form that has no fields, as Acrobat's Fill & Sign does: type text (`text`, default 10 pt; `font_size` 4–300 pt), place a check, cross, dot or line, today's date (in Preferences…  
  `at*, author, doc*, font_size, format, language, page*, path, scan, sensitivity, text, type*`
- **fill_sign_date_format** — Preferences ▸ Date format: the pattern Fill & Sign dates use (default m/d/yyyy). Set it with `format` (Acrobat date codes yyyy yy mmmm mmm mm m dddd ddd dd d, other runs of y, m or d are…  
  `format, language`

## form (13)

- **form_actions** — Field Properties ▸ Actions: the field's action for each trigger (mouse_up, mouse_down, mouse_enter, mouse_exit, on_focus, on_blur).  
  `doc*, field*`
- **form_add_field** — Add a form field on a page. type: text, date, checkbox, radio, combo, list, button, image (a picture placeholder; fill it with form_set_image), signature. rect in points from the…  
  `caption, doc*, editable, export, group, multi_select, multiline, name, options, page*, rect*, type*`
- **form_delete_field** — Delete a form field and all its widgets. Undoable.  
  `doc*, field*`
- **form_detect_fields** — Prepare a form ▸ automatic field detection: find the blanks a printed form asks to be filled (underscore runs, lines, empty boxes, rows of comb boxes, small squares for check boxes; on…  
  `add, doc*, pages`
- **form_fields** — Every interactive form field: name, type (text, checkbox, radio, combo, list, button, signature), value, options, page, rect (top-left-origin points) and rotation (0, 90, 180 or 270…  
  `doc*`
- **form_fill** — Set several fields at once (one undo step). values maps field names (from form_fields) to: a string for text fields, combo boxes and radio groups (an option), true/false for check boxes,…  
  `doc*, values*`
- **form_merge_data** — Collect the field values of form data files (FDF, XFDF) or filled-in PDF forms into one CSV file at path: a column per field name, a row per file. Returns the row and column counts.  
  `path*, paths*`
- **form_reset** — Reset fields to their default values: all of them, or only those listed. Undoable.  
  `doc*, fields`
- **form_set_actions** — Field Properties ▸ Actions: replace the field's actions. Each item: trigger (mouse_up, mouse_down, mouse_enter, mouse_exit, on_focus, on_blur) and one of javascript (source), url, reset…  
  `actions*, doc*, field*`
- **form_set_image** — Show an image file (PNG, JPEG, TIFF, GIF or BMP) in an image field or button, scaled to fit and centred (what clicking an image field does). On an XFA form the picture is kept in its…  
  `doc*, field*, path*`
- **form_set_props** — Change field properties: give field for one field, or fields for a list of unique field names (1–1000). A bulk change is atomic and one Undo step; an invalid or locked field leaves every…  
  `align, appearance, calculate, caption, check_style, default, doc*, field, fields, flags, font_size, format, locked, max_length, multiline, name, options, read_only, rect, required, rotation, tooltip, validate, widget`
- **form_set_script** — Field Properties ▸ Run custom script: set field's JavaScript for event keystroke, format, validate or calculate (the field's actions; calculated fields join the calculation order) or…  
  `doc*, event*, field*, script`
- **form_tab_order** — Set the tab order of pages (default all): row (top to bottom, left to right), column, structure, or annotations (unspecified). Or order tabs manually: `field` with `move` earlier|later…  
  `doc*, field, move, order, pages`

## image (3)

- **image_edit** — Change one of a page's images (number from page_images): action move (rect: new full placement box in top-left-origin points, based on page_images.rect), crop (rect: the part to keep,…  
  `action*, doc*, image*, page*, path, quarters, rect`
- **image_hit** — List image/Form numbers whose placement and all clipping paths contain point [x,y] in top-left-origin points. Bezier curves, even-odd/nonzero fill and holes are respected. Read only.  
  `doc*, page*, point*`
- **image_save** — Write one of a page's raster images (number from page_images; forms are refused) to path: JPEG images unchanged, others as PNG (the extension is added when missing).  
  `doc*, image*, page*, path*`

## js (4)

- **js_document_scripts** — List the document-level JavaScripts (name and source), which define functions field scripts use.  
  `doc*`
- **js_enabled** — Preferences ▸ JavaScript ▸ Enable Acrobat JavaScript: set it with `enabled`, or read it. With JavaScript off, field scripts other than Acrobat's AF calls don't run.  
  `enabled`
- **js_run** — Run Acrobat JavaScript in the document, as the JavaScript console does (or as push button `field`'s Mouse Up script when field is given; on a laid-out XFA form, `field` runs that…  
  `doc*, field, script*`
- **js_set_document_script** — Add or replace the document-level JavaScript `name` with `script`, or delete it (script omitted). Undoable.  
  `doc*, name*, script`

## link (5)

- **link_add** — Add a link over rect on page that opens url or goes to to_page. Appearance: visible (rectangle), color, width 1-3, highlight none/invert/outline/inset. Undoable.  
  `color, doc*, highlight, page*, rect*, to_page, url, visible, width`
- **link_delete** — Delete one link (page, index from link_list). Undoable.  
  `doc*, index*, page*`
- **link_edit** — Change a link's rect, destination (url or to_page) or appearance. Undoable.  
  `color, doc*, highlight, index*, page*, rect, to_page, url, visible, width`
- **link_list** — Every link: page, 1-based index (for link_edit/link_delete), rect (points from the top-left of the page), and where it goes (url or to_page).  
  `doc*`
- **link_open** — Follow a local GoToR link in PdfCraft: open the referenced PDF as a new document, respecting --root. page and index use link_list numbering. Named destinations are reported but not…  
  `allow_absolute, doc*, index*, page*, password`

## links (2)

- **links_from_urls** — Find web addresses (http://, https://, www.) in the text of every page and make them clickable links. Returns the URLs. Undoable.  
  `doc*`
- **links_remove** — Remove every link in the document (or on the given pages). Undoable.  
  `doc*, pages`

## measure (8)

- **measure_area** — Add an undoable area annotation from a simple polygon. The last edge closes automatically.  
  `author, doc*, label, page*, points*`
- **measure_distance** — Add an undoable two-point distance annotation using the scale of the first point's viewport.  
  `author, doc*, label, page*, points*`
- **measure_export** — Atomically write saved measurement values, labels, authors and scale ratios as spreadsheet-safe CSV. Returns how many unsupported measurements were left out.  
  `doc*, out*`
- **measure_info** — Calculate a live distance, perimeter or area, deltas, angle and scale without adding an annotation. Incomplete paths are allowed.  
  `doc*, page*, points*, type`
- **measure_list** — Saved measurement annotations with calculated values, scale and vertices in display coordinates. Measurements with unsupported imported formats (compound or fractional units,…  
  `doc*, page`
- **measure_perimeter** — Add an undoable connected-line length annotation. To include a closing edge, repeat the first point at the end.  
  `author, doc*, label, page*, points*`
- **measure_scale** — Read the scale at a point, or add a rectangular viewport using units_per_point or two calibration points and their real-world distance. Existing measurements retain their original…  
  `at, distance, doc*, name, page*, points, precision, rect, unit, units_per_point`
- **measure_snap** — Snap a point to vector paths, endpoints, midpoints or intersections. Coordinates and tolerance are in display points. Bounded extraction reports truncated geometry.  
  `at*, doc*, endpoints, intersections, midpoints, page*, paths, tolerance`

## object (2)

- **object_list** — List existing paragraphs, Image/Form artwork and added content once, with source kind/index references, displayed rectangles and document generation. Indexes change when content changes;…  
  `doc*, page*`
- **object_move** — Atomically translate 1–1000 mixed references from object_list by [dx, dy] in displayed points (right/down). Preserves glyph codes, fonts, image data and relative spacing; success is one…  
  `doc*, generation, objects*, offset*, page*`

## ocr (3)

- **ocr_recognize** — Scan & OCR ▸ Recognize text: render pages, read the words in them and add them as invisible text over the page image, so scanned pages become searchable and selectable (a searchable…  
  `doc*, dpi, language, pages, skip_text_pages`
- **ocr_recognize_files** — Scan & OCR ▸ Recognize text ▸ In multiple files: read every page of each PDF in paths and write the searchable result into folder under the same name (pages that already have text are…  
  `dpi, folder*, language, paths*, skip_text_pages`
- **ocr_status** — Whether text recognition is available (its models are installed: release packages include them; a source build fetches them with `cargo xtask models`; PDFCRAFT_MODELS overrides), where…  
  `—`

## page (17)

- **page_add_image** — Add an image file (PNG, JPEG, TIFF, GIF, BMP) as page content: in rect (points from the top-left of the page), or centred at its natural size (shrunk to fit). Undoable; movable with…  
  `doc*, page*, path*, rect`
- **page_add_text** — Add text as page content (not a comment). Place it with at [x, y] (top-left, points from the top-left of the displayed page) and width (wrap width, default 200), or rect. Newlines start…  
  `align, at, bold, color, doc*, font, italic, page*, rect, size, text*, width`
- **page_delete** — Delete pages. Undoable until saved.  
  `doc*, pages*`
- **page_duplicate** — Insert copies of pages so the first copy becomes page `at`, or after the last of them when `at` is left out (fonts and images are shared, not copied). Undoable.  
  `at, doc*, pages*`
- **page_enhance_camera** — Straighten a photographed document (Scan & OCR ▸ Enhance ▸ Camera image): the part of the page inside the four corners (x1, y1, … x4, y4 in top-left-origin points, any order, a convex…  
  `corners, doc*, level, mode, page*`
- **page_extract** — Copy pages into a new PDF (links, bookmarks, fields and layers that belong to them come along). separate: true writes each page as its own file into out_dir; delete: true removes the…  
  `delete, doc*, open, out, out_dir, pages*, separate`
- **page_images** — The raster images and grouped Form artwork a page draws (Edit a PDF): number, full placement rect and visible_rect after page/path clipping (top-left-origin points; null if fully…  
  `doc*, page*`
- **page_insert_blank** — Insert a blank page so it becomes page `at`. Size defaults to the neighbouring page. Undoable.  
  `at*, doc*, height, width`
- **page_insert_file** — Insert pages of another PDF so the first becomes page `at`. Its bookmarks come along, collapsed under one bookmark named after the file, placed among the document's bookmarks where the…  
  `at*, doc*, pages, path*`
- **page_move** — Move pages so the first of them lands at position `to` (1-based, counted before the move). Undoable.  
  `doc*, pages*, to*`
- **page_number** — Label a range of pages (e.g. i, ii, iii for front matter, or A-1, A-2 for an appendix). Later pages keep their labels. Undoable.  
  `doc*, from*, prefix, start, style, to*`
- **page_render** — Render one page to a PNG image (default 96 dpi, at most 600).  
  `doc*, dpi, hide_added_text, hide_text_block, page*`
- **page_replace** — Replace the content of pages with pages of another PDF (same count). Links, comments, form fields and bookmarks on the original pages stay, as in Acrobat. Undoable.  
  `doc*, from_pages, pages*, path*`
- **page_reverse** — Reverse the order of pages among the positions they occupy: the listed pages (at least two), or the whole document when pages is omitted. Undoable.  
  `doc*, pages`
- **page_rotate** — Rotate pages by a multiple of 90 degrees (positive is clockwise): the listed pages (default all), filtered like Acrobat's Rotate Pages by subset (all, even, odd page numbers) and…  
  `degrees*, doc*, orientation, pages, subset`
- **page_set_box** — Set a page box (crop by default; also trim, bleed, art, media) on pages: either margins in points from the media box [left, bottom, right, top], or an absolute rect in points from the…  
  `box, doc*, margins, pages, rect`
- **page_transition_set** — Set or remove the transition and display time pages play in a full-screen presentation (ISO 32000-2 §12.4.4; Acrobat's Organize ▸ Page Transitions). style: Split, Blinds, Box, Wipe,…  
  `dimension, direction, display, doc*, duration, motion, opaque, pages, scale, style`

## pdfa (2)

- **pdfa_convert** — Standards ▸ Save as PDF/A: fix what can be fixed for PDF/A-2b or 3b (XMP identification and metadata, an sRGB output intent, forbidden actions and JavaScript, annotation print flags,…  
  `doc*, level`
- **pdfa_verify** — Standards ▸ Verify PDF/A compliance: the PDF/A-2b or 3b rules the document breaks (ISO 19005 clause, message, page, whether Save as PDF/A can fix it), plus what it declares.  
  `doc*, level`

## print (1)

- **print_readiness** — Verification only. Reports effective image resolution where each image is drawn (not against the page size), page boxes and bleed past the trim, output intents, fonts that are not…  
  `doc*`

## printer (1)

- **printer_options** — A printer driver's own job options (CUPS: from its PPD), such as the paper tray, paper type or finishing: key, label, group, default and choices. Pass chosen values to doc_print as…  
  `printer*`

## printers (1)

- **printers** — The printers the system's print spooler knows (CUPS on macOS and Linux), with the default marked.  
  `—`

## redact (3)

- **redact_apply** — Apply the redaction marks (all, or those on pages): text, images, vectors, comments and form fields under them are removed for good and boxes are drawn in their place. A verification…  
  `doc*, pages`
- **redact_clear** — Remove every redaction mark without applying it. Undoable.  
  `doc*`
- **redact_mark** — Mark content for redaction (nothing is removed until redact_apply). One of: rect [x0, y0, x1, y1] (points from the top-left of the displayed page) with page; find (text, every match);…  
  `author, case_sensitive, code_set, codes, doc*, fill, find, overlay, page, pages, pattern, rect, whole_pages, whole_words, words`

## render (1)

- **render_preview** — Render a PNG bounded by max_side (default 1024), without changing or saving the document. Page defaults to 1; doc may be omitted when exactly one document is open.  
  `doc, max_side, page`

## sign (6)

- **sign_document** — Sign with a digital ID (a .p12/.pfx path, or on macOS a Keychain identity: "keychain:<common name or fingerprint>" from sign_keychain_ids, or on Windows a store identity:…  
  `appearance, certify, contact, doc*, field, graphic, id*, labels, location, out*, page, password, reason, rect`
- **sign_id_create** — Create a self-signed digital ID and save it as a password-protected .p12 file (Acrobat: Configure a new digital ID ▸ Create a new digital ID ▸ Save to file). Default key: 2048-bit RSA,…  
  `country, email, key, name*, organization, password*, path*, unit, years`
- **sign_keychain_ids** — macOS: the signing identities in the user's keychains (certificate details and the keychain: reference sign_document takes). The private keys stay in the Keychain, which may ask the user…  
  `—`
- **sign_list** — Every signature field with its validation: status (valid, unknown = intact but the signer isn't trusted, invalid, unsigned), signer and certificate, date, reason, location, certification…  
  `doc*`
- **sign_trust** — Add certificates (.cer/.crt/.pem/.der, or the certificates in a .p12 with `password`) to the trusted certificates used to validate signatures, or clear the list (clear: true). Every open…  
  `clear, password, paths`
- **sign_windows_ids** — Windows: signing identities in the Current User Personal certificate store (certificate details and the windows: reference sign_document takes). Private keys remain in CNG; Windows may…  
  `—`

## stamp (1)

- **stamp_custom** — Stamp a picture: a PDF page (file_page, default 1) or an image file, centred at at [x, y] (points from the top-left of the displayed page) at its natural size, at most 200 pt. name…  
  `at*, author, doc*, file_page, name, page*, path*`

## text (10)

- **text_edit** — Replace the text of one paragraph (paragraph, from text_paragraphs: rewrapped to the paragraph's width with its line spacing) or one line (line, from text_lines) in place, keeping…  
  `align, bold, char_spacing, color, doc*, dx, dy, font, font_resource, italic, line, line_spacing, page*, paragraph, ranges, scale, size, text, underline, width`
- **text_edit_layout** — Measure a paragraph draft using the same PDF rewrite as Apply, without changing the document. Returns source_rect, draft_rect (top-left-origin points), overflow, and the embedded sfnt…  
  `doc*, font_resource, page*, paragraph*, ranges, size, text, width`
- **text_extract** — Extract the text of some or all pages, in reading order. With rect, only the text inside that rectangle on each page, as Column select takes it: one row per visual line, side-by-side…  
  `doc*, pages, rect`
- **text_find** — Find a phrase (case-insensitive, whitespace-normalised) and return matches in page order with page and line rectangles in points (origin top-left). Reads growing batches, looking one…  
  `doc*, limit, query*, skip, start_page`
- **text_font_files** — Discover openly licensed, embeddable TrueType/OpenType files on request. Optional directories (at most 16) restrict the scan; with --root, only that root is scanned by default and…  
  `directories`
- **text_font_import** — Load an explicitly selected, openly licensed full TrueType/OpenType face into a page. The program's family, embedding permissions and licence declaration are validated. Completes source…  
  `doc*, page*, path*`
- **text_fonts** — List validated embedded source faces and approved full preview faces for a page. Full registered resources can be selected by text_edit.font_resource; preview_only faces are not PDF…  
  `doc*, page*`
- **text_lines** — The lines of existing text on a page (Edit a PDF ▸ Edit text): number, text, box (top-left-origin points), font and size. Use the number with text_edit.  
  `doc*, page*`
- **text_paragraphs** — The paragraphs on a page (adjacent source runs grouped into aligned visual rows, including mixed fonts, sizes and colours): number, text, editor_text (visual rows separated by newlines),…  
  `doc*, page*`
- **text_word_count** — Count Unicode words and characters on selected pages (default all), with totals and per-page counts. Table/code exclusions use PDF structure tags, not visual guesses; unclassified text…  
  `doc*, exclude_code, exclude_images, exclude_tables, pages`

## view (1)

- **view_reading_colors** — Set the document's reading colours (Acrobat's Replace Document Colors, in the Reading Options): solid text and line-art paints are remapped for readability and the page clears to the…  
  `background, doc*, line_art, mode*, only_black, text`

## xfa (1)

- **xfa_to_static** — Make an XFA form an ordinary PDF form: the XFA packets (template, data, scripts) and PdfCraft's private keys go; the pages as laid out and the fields with their values stay, so every…  
  `doc*`
