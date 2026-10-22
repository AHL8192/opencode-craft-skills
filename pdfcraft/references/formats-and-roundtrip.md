# Formats, exports and verified round-trips — PdfCraft 0.10.1

All claims below were tested on 2026-10-22 with the installed build and checked
where possible with independent tools (`pdfinfo`, `pdftotext`, `unzip`,
`soffice`).

## Native format

PdfCraft edits **PDF** only. `doc_save` always writes PDF bytes; the extension
does not select a converter. Use `doc_export_*` for other formats.

| Operation | Behaviour |
|---|---|
| `doc_open {path}` | PDF, including password-protected (prompt is an error, not a dialog) |
| `doc_open {path,password}` | user password opens read-only under restrictive permissions; owner password allows changes |
| `doc_save {doc}` | save in place; incremental update when the path is unchanged |
| `doc_save {doc,path}` | Save As, full rewrite (`incremental:false`) |
| repeated `doc_save` with no edits | succeeds, but adds **no** revision (no-op) |
| `doc_revisions` | one entry per incremental update, with byte ranges and signing info |
| `doc_close {discard_changes:true}` | discard edits; otherwise unsaved edits are an error |

Encrypted reopen assigns a **new document id**; always use the id returned by
that `doc_open`.

## Exports

### Office / text (`doc_export_office`, `doc_export_text`)

`doc_export_office` chooses by extension: `.docx`, `.pptx`, `.html`, `.rtf`.
Anything else errors:
`unsupported extension "xyz" (docx, pptx, html or rtf)`.

Verified on a 3-page text PDF:

| Output | Size | Structure check |
|---|---|---|
| `core.txt` | 42 B | form feeds between pages; reading order |
| `core.docx` | 2282 B | valid zip, 6 parts; `soffice` converted it back to text |
| `core.pptx` | 6819 B | 16 parts, `slide1..3.xml` (one slide per page) |
| `core.html` | 485 B | self-contained; inline `<hr>` per page |
| `core.rtf` | 188 B | opens as RTF |

Word/HTML merge wrapped lines into one paragraph (`Alpha line one Beta line
two`); page breaks become `<hr>`/new paragraphs. Positioned shapes are used only
on pages with artwork, rotated or large text (per tool description; not tested
with artwork).

### Images (`doc_export_images`, `doc_export_all_images`)

```json
{"doc":1,"folder":"/tmp/pages","format":"png","dpi":96,"pages":[1]}
```

- Writes `<document-stem>_page_<n>.png|jpg|tif` **directly in `folder`**.
- Returns only `{"count":N}` — no file list. List the folder to confirm.
- `format` accepts `png`, `jpeg`, `tiff` (also `jpg`/`tif`); `gif` errors with
  `unknown format "gif" (png, jpeg, tiff)`. The folder is created even when the
  format later fails.
- JPEG/TIFF are flattened on white; PNG keeps alpha.
- `doc_export_all_images` extracts embedded images (`<name>_Page_<n>_Image_<k>`),
  each once; returns `count` and `skipped` for JPEG 2000/JBIG2/CCITT.

### Data (`doc_export_data`, `doc_import_data`)

| Extension | Contents |
|---|---|
| `.xfdf`, `.fdf` | comments and/or fields (`what`: all / comments / fields) |
| `.xml` | form data (XFA data for XFA forms; `.xdp` for the package) |
| `.csv`, `.txt` | **form data only** — `what:"all"` with `.csv` errors: *“comments travel as .xfdf or .fdf; .xml, .csv and .txt hold form data (use what: fields)”* |

Verified round-trips:

- **Comments:** 17 annotations → `comments.xfdf` (6241 B) → imported into a
  clean 2-page PDF → `comment_list` 17 → saved 7628 B.
- **Forms:** 3 fields (text/checkbox/combo) filled → XFDF (322 B) and CSV
  (44 B) → `form_reset` (values `null`/`false`) → `doc_import_data` → values
  restored → saved 2099 B → reopened, values still there.
- CSV is a simple header row plus values (`fullname,agree,color` /
  `Ada Lovelace,Yes,green`); no quoting metadata, so use XFDF for fidelity.

## Standards and security

- **PDF/A:** `pdfa_verify` before conversion on a plain PDF returned
  `compliant:false` with two fixable issues (no XMP metadata; no output intent).
  `pdfa_convert {level:"2b"}` returned `compliant:true` with declared
  `PDF/A-2b` and sRGB intent; after `doc_save`, reopening the file and verifying
  again still returned `compliant:true`. The file has an XMP metadata stream.
- **Protection:** `doc_protect` with `open_password:"secret"` and
  `permissions_password:"owner"`, printing `low`, changes `none`, copy and
  accessibility off. After save:
  - open without password → `the document is protected by a password`
  - wrong password → `the password is incorrect`
  - open with the user password → works, but `text_extract` and `doc_unprotect`
    refuse: *“security settings don't allow copying/changing security; open it
    with the owner password”*
  - open with the owner password → `doc_unprotect` succeeds; save shrinks the
    file (1803 → 1096 B) and `pdfinfo` reports `Encrypted: no`.
- **Hidden information:** `doc_hidden_info` counts metadata, attachments,
  comments, form fields, hidden text, layers, bookmarks, links/actions/scripts
  and private data. `doc_remove_hidden` with no categories sanitizes all;
  with `categories:[…]` removes only those. Flattens fields so values stay
  visible.
- **Redaction:** see the bug/workaround below. A correct redaction removes the
  glyphs and paints a box; a faux redaction (box over still-extractable text) is
  reported by `doc_audit_redactions` and by `pdfcraft-cli audit` (which fails).

## OCR

`ocr_status` on this machine: `available:true`, language `en`; models found in
`/usr/share/pdfcraft/models` (`text-detection.rten`, `text-recognition.rten`;
shipped by the Debian package. A source build may download them).

Test: rendered a text page to PNG at 200 dpi → placed it on a blank page with
`page_add_image` → `text_extract` empty → `ocr_recognize {pages:[1],language:"en",
dpi:200}` returned `words:6` and text `PDFCraft connection proof Total due: 42`
→ after save, external `pdftotext` returned the same two lines. The image is
unchanged; recognised words are invisible text.

Pages that already have text are skipped unless `skip_text_pages:false`; words
already present are counted in `already_on_page`.

## Printing

`doc_print` renders print-ready PDFs when given `path` (no printer needed):

- `layout:"booklet"`, pages `"1-3"`, binding left → 3 source pages, **2 output
  pages**, `sheets:2`.
- `layout:"multiple"`, `per_sheet:2`, border → 2 output pages, `sheets:2`.
- unknown layout errors (`unknown layout "banana"`).
- `printers` returned `count:0` on this machine (no CUPS printers). Do not send
  a real print job without the user's printer and consent.

## Comparison, optimization, actions

- `doc_compare {doc:newer, other:older}` returns text changes with old/new
  rects; `doc_compare_report` wrote a 969 B PDF; `doc_compare_mark` added 3
  comments to the newer document.
- `doc_optimize`/`doc_reduce` on a 6058 B test PDF wrote 2534 B copies.
  `doc_reduce` returned `written:true`; both returned byte counts and merged
  object counts. If the result would not be smaller, `doc_reduce` reports
  `written:false` and writes nothing (per tool contract).
- `action_run` accepts a built-in name (`Add Page Numbers`, `Mark as
  Confidential`, `Prepare for Distribution`, `Optimize Scanned Documents`,
  `Sanitize Documents`) or custom `steps:[{step,arg}]`, writes outputs under the
  same basename into `folder`, and returns per-file `log`/`output`/`error`.
  Footer text (`Page 3 of 3`) and a custom watermark were verified in the
  outputs.

## Accessibility

`accessibility_check` runs 32 rules in 7 categories. On an untagged text PDF it
reported 22 passed, 4 failed, 5 manual. `accessibility_report` wrote an HTML
report. Fix tools are exposed as `accessibility_*`/`tag_*` (18 tools); they were
not exhaustively exercised.

## Interop caveats

- **Text extraction is model-based.** PdfCraft's `text_extract` can return text
  that poppler does not (clipped/off-page). Always confirm with `pdftotext` when
  the consumer is another application.
- **DOCX/PPTX are simplified**: text, inferred tables, positioned shapes;
  fonts/vector graphics are limited and exact layout is not preserved.
- **Unknown save extensions are accepted silently**: `doc_save` to `.xyz`
  writes a valid PDF named `.xyz` (verified 8561 B). Do not use save for format
  conversion.
- **`page_extract`/`doc_split` may return `{}`** when `out_dir`/`separate` is
  used even though files exist; list the directory (`<name>-partK.pdf`,
  `pages-pageN.pdf`).
- **PDF/A conversion fixes what it can**; unembedded fonts may remain and are
  listed in `issues` with `fixable:false`.
