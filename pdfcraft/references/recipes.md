# PdfCraft recipes (tested)

Tool calls are MCP JSON; `args` only. Replace paths and ids. After every
`doc_open`/`doc_create`, use the id it returned — never assume `1`.

## 1. Create a PDF from scratch and save it

```json
{"tool":"doc_create","args":{"from":"blank","pages":2,"width":400,"height":500,"name":"report"}}
{"tool":"page_add_text","args":{"doc":1,"page":1,"text":"Quarterly report","at":[40,50],"size":22,"bold":true,"color":"#1F3864"}}
{"tool":"page_add_text","args":{"doc":1,"page":1,"text":"Body text wraps at the given width.","at":[40,90],"width":320,"size":11}}
{"tool":"page_number","args":{"doc":1,"from":1,"to":2,"prefix":"p. ","start":1,"style":"decimal"}}
{"tool":"doc_save","args":{"doc":1,"path":"/work/report.pdf"}}
{"tool":"doc_close","args":{"doc":1}}
```

`page_add_text` requires `at` or `rect`; `page_number` requires `from` (and
accepts `to`, `prefix`, `start`, `style`; `arabic` is **not** valid — use
`decimal`).

## 2. Open, inspect, edit pages, save a copy

```json
{"tool":"doc_open","args":{"path":"/work/in.pdf"}}
{"tool":"doc_info","args":{"doc":1}}
{"tool":"page_rotate","args":{"doc":1,"pages":[1],"degrees":90}}
{"tool":"page_delete","args":{"doc":1,"pages":[2]}}
{"tool":"page_move","args":{"doc":1,"pages":[3],"to":1}}
{"tool":"doc_save","args":{"doc":1,"path":"/work/edited.pdf"}}
```

Page ops use `pages` (array/ranges), not `page`. `degrees` must be a multiple of
90. Deleting every page is refused.

## 3. Merge, split, extract (files)

```json
{"tool":"doc_combine","args":{"paths":["/work/a.pdf","/work/b.pdf"],"out":"/work/merged.pdf"}}
{"tool":"doc_split","args":{"doc":1,"every":10,"out_dir":"/work/parts"}}
{"tool":"page_extract","args":{"doc":1,"pages":[1,3,5],"out":"/work/excerpt.pdf"}}
```

`doc_split` writes `<name>-part1.pdf`…; `page_extract` with `separate:true` and
`out_dir` writes `pages-pageN.pdf`. The return value may omit paths — list the
folder. For file-only work, `pdfcraft-cli combine/extract/split` is simpler.

## 4. Text, search and highlights

```json
{"tool":"text_extract","args":{"doc":1}}
{"tool":"text_find","args":{"doc":1,"query":"Total due","limit":20}}
{"tool":"comment_add","args":{"doc":1,"page":1,"type":"highlight","find":"Total due","color":"#FFF176"}}
{"tool":"comment_list","args":{"doc":1}}
{"tool":"comment_reply","args":{"doc":1,"id":"<comment-id>","text":"Please confirm."}}
```

- `text_find` uses **`query`**, not `text`.
- Highlight/underline/strikeout take `find` or `quads`; a bare `rect` errors.
  A sticky note takes `at`; a callout needs `to`; a cloud needs `points`.
- Comment **indices are unstable** — prefer the `id` returned by
  `comment_add`/`comment_list` for edit/delete/reply.

## 5. Fill and round-trip a form

```json
{"tool":"form_fields","args":{"doc":1}}
{"tool":"form_fill","args":{"doc":1,"values":{"fullname":"Ada Lovelace","agree":true,"color":"green"}}}
{"tool":"doc_export_data","args":{"doc":1,"path":"/work/form.xfdf","what":"all"}}
{"tool":"form_reset","args":{"doc":1}}
{"tool":"doc_import_data","args":{"doc":1,"path":"/work/form.xfdf"}}
{"tool":"doc_save","args":{"doc":1,"path":"/work/form-filled.pdf"}}
```

A number for a text field is silently coerced to text; verify with
`form_fields`. Export `.csv` only with `what:"fields"`.

## 6. Build a form from scratch

```json
{"tool":"doc_create","args":{"from":"blank","pages":1,"width":400,"height":500}}
{"tool":"form_add_field","args":{"doc":1,"page":1,"type":"text","name":"fullname","rect":[40,60,300,80]}}
{"tool":"form_add_field","args":{"doc":1,"page":1,"type":"checkbox","name":"agree","rect":[40,100,60,120]}}
{"tool":"form_add_field","args":{"doc":1,"page":1,"type":"combo","name":"color","options":["red","green","blue"],"rect":[40,140,200,160]}}
{"tool":"doc_save","args":{"doc":1,"path":"/work/new-form.pdf"}}
```

`form_add_field` also supports `date`, `radio` (with `group`/`export`), `list`,
`button`, `image`, `signature`. `form_set_props` changes flags/fonts/options;
`form_flatten` bakes appearances.

## 7. Safe redaction workflow

```json
{"tool":"redact_mark","args":{"doc":1,"find":"Total due"}}
{"tool":"doc_audit_redactions","args":{"doc":1}}
{"tool":"redact_apply","args":{"doc":1}}
{"tool":"doc_audit_redactions","args":{"doc":1}}
{"tool":"text_extract","args":{"doc":1}}
```

**0.10.1 bug:** applying a `find` mark can leave adjacent glyphs extractable and
the post-apply audit then flags the app's own box. When `count>0`, mark the
reported rects (slightly expanded) and apply again until the audit is `count:0`:

```json
{"tool":"redact_mark","args":{"doc":1,"page":1,"rect":[36,74,108,98]}}
{"tool":"redact_apply","args":{"doc":1}}
{"tool":"doc_audit_redactions","args":{"doc":1}}
```

Then save to a **new** path and confirm with `pdftotext` and
`pdfcraft-cli audit` (which exits nonzero on findings).

## 8. Protect / unprotect

```json
{"tool":"doc_protect","args":{"doc":1,"open_password":"secret",
 "permissions_password":"owner","printing":"low","changes":"none",
 "copy":false,"accessibility":false}}
{"tool":"doc_save","args":{"doc":1,"path":"/work/protected.pdf"}}
```

Reopen with `{"password":"secret"}` for reading; restrictive permissions block
text extraction and unprotecting. Reopen with `{"password":"owner"}`, then
`doc_unprotect` and save to remove security. Never lose the owner password.

## 9. OCR a scan

```json
{"tool":"ocr_status","args":{}}
{"tool":"ocr_recognize","args":{"doc":1,"pages":[1],"language":"en","dpi":200}}
{"tool":"text_extract","args":{"doc":1}}
{"tool":"doc_save","args":{"doc":1,"path":"/work/searchable.pdf"}}
```

Pages with text are skipped. The image is unchanged; text is invisible. Batch:
`ocr_recognize_files` or `pdfcraft-cli batch … --steps ocr`.

## 10. Save as PDF/A

```json
{"tool":"pdfa_verify","args":{"doc":1,"level":"2b"}}
{"tool":"pdfa_convert","args":{"doc":1,"level":"2b"}}
{"tool":"pdfa_verify","args":{"doc":1,"level":"2b"}}
{"tool":"doc_save","args":{"doc":1,"path":"/work/archive.pdf"}}
```

Reopen and verify again; `issues` lists anything not fixable (often fonts).

## 11. Export to Word/PowerPoint/HTML/text/images

```json
{"tool":"doc_export_text","args":{"doc":1,"path":"/work/out.txt","pages":[1,2]}}
{"tool":"doc_export_office","args":{"doc":1,"path":"/work/out.docx"}}
{"tool":"doc_export_office","args":{"doc":1,"path":"/work/out.pptx"}}
{"tool":"doc_export_images","args":{"doc":1,"folder":"/work/pages","format":"png","dpi":150,"pages":[1]}}
```

Only `.docx/.pptx/.html/.rtf` are accepted. Image export returns a count, not
names — list the folder. For a PDF as a single image, use `page_render`.

## 12. Compare two versions

```json
{"tool":"doc_open","args":{"path":"/work/new.pdf"}}
{"tool":"doc_open","args":{"path":"/work/old.pdf"}}
{"tool":"doc_compare","args":{"doc":1,"other":2,"visual":true}}
{"tool":"doc_compare_report","args":{"doc":1,"other":2,"path":"/work/compare.pdf"}}
{"tool":"doc_compare_mark","args":{"doc":1,"other":2}}
```

`other` is the **older** document. Marking adds comments authored “Compare”.

## 13. Print-ready PDF (booklet / N-up)

```json
{"tool":"doc_print","args":{"doc":1,"path":"/work/booklet.pdf",
 "layout":"booklet","pages":"1-3","binding":"left","booklet_subset":"both"}}
{"tool":"doc_print","args":{"doc":1,"path":"/work/2up.pdf",
 "layout":"multiple","per_sheet":2,"border":true,"pages":"1-3"}}
```

Returns `pages` (source) and `sheets` (output). Check with `pdfinfo`.

## 14. Header, footer, watermark, background, labels, measures

```json
{"tool":"doc_header_footer","args":{"doc":1,"header_center":"Confidential",
 "footer_right":"Page <<1>> of <<n>>","font_size":9,"pages":[1,2]}}
{"tool":"doc_watermark","args":{"doc":1,"text":"DRAFT","opacity":0.3,"rotation":45,"pages":[1]}}
{"tool":"doc_background","args":{"doc":1,"color":"#FFF2CC","pages":[2]}}
{"tool":"page_number","args":{"doc":1,"from":1,"to":2,"prefix":"A-","start":1,"style":"lower-roman"}}
{"tool":"measure_scale","args":{"doc":1,"page":1,"rect":[20,20,200,200],"units_per_point":0.5,"unit":"in","name":"Scale A"}}
{"tool":"measure_distance","args":{"doc":1,"page":1,"points":[[30,30],[130,30]],"label":"Width"}}
{"tool":"measure_export","args":{"doc":1,"out":"/work/measure.csv"}}
```

Page labels `A-i`, `A-ii` were verified from `page_number`. `doc_remove_marks`
needs `kind` (`watermark`, `header`, `footer`, `background`, …); an unknown kind
errors.

## 15. Batch with the CLI

```sh
pdfcraft-cli batch /work/inbox --steps convert,ocr,optimize \
  --out-dir /work/out --recursive --root /work --ppi 150 --quality 60
pdfcraft-cli check /work/out --json /work/check.json
pdfcraft-cli audit /work/out/report.pdf
```

`batch` preserves relative paths, skips unsupported files and never overwrites
existing outputs (per help). Use `--stop-on-error` when partial output is worse
than none.

## 16. Drive the GUI (highlight + save + quit)

```sh
CTRL=~/.config/pdfcraft/control-x.json
pdfcraft --control "$CTRL" /work/doc.pdf &
sleep 5
pdfcraft-cli ui --control "$CTRL" state            # note pages_on_screen rect
pdfcraft-cli ui --control "$CTRL" click label="Highlight"
pdfcraft-cli ui --control "$CTRL" state            # re-read: zoom may change
# compute from page points, then:
pdfcraft-cli ui --control "$CTRL" drag from='[410.3,240.8]' to='[504.1,263.3]'
pdfcraft-cli ui --control "$CTRL" command id=file.save
pdfcraft-cli ui --control "$CTRL" quit
```

If unsaved, quit returns `needs_confirmation:true`; click Cancel to stay or
choose Save. `ui.command` ignores params; `ui.open` may hang pending. Widget ids
change every frame — use labels or coordinates.

## 17. Undo, redo, revision-safe edits

```json
{"tool":"edit_undo","args":{"doc":1}}
{"tool":"edit_redo","args":{"doc":1}}
{"tool":"doc_revisions","args":{"doc":1}}
```

All edits are one undo step each; a save does not clear undo. Incremental saves
add revisions; a no-op save does not.

## 18. Accessibility pass

```json
{"tool":"accessibility_check","args":{"doc":1}}
{"tool":"accessibility_report","args":{"doc":1,"path":"/work/a11y.html"}}
```

On an untagged document expect failures such as “document has no tags”; use the
`tag_*`/`accessibility_*` tools to fix, then re-check. The report is HTML.
