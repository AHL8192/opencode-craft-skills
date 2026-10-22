# PdfCraft bugs, silent successes and workarounds (0.10.1)

Observed on 2026-10-22 with the installed binary. Each item has a reproducible
call or a test result. Re-test after upgrading; do not treat this list as
permanent.

## High impact

### 1. `redact_apply` can leave readable text — and the audit flags its own box

**Repro:** on `"Total due: 42"`:

```
redact_mark {doc:1, find:"Total due"}
redact_apply {doc:1}            → applied:1
text_extract {doc:1}            → "PDFCraft connection proof\n: 42"
doc_audit_redactions {doc:1}    → count:1, kind:"covered-text", covered_text:": 42"
```

The tool contract says the apply pass “fails the operation if anything readable
remains”; it did not fail, and the app's own painted box is then reported as a
faux redaction. This is a **fail-open risk** if you trust `redact_apply`.

**Workaround:** always audit after applying. While `count>0`, re-mark the
reported rect with a small margin, apply again, and repeat:

```
redact_mark {doc:1, page:1, rect:[36,74,108,98]}
redact_apply {doc:1}
doc_audit_redactions → count:0
```

Then save to a new file, run `pdfcraft-cli audit` (nonzero exit on findings) and
`pdftotext` for an independent check. Expect the expanded rect to clip adjacent
glyphs (`onnection proof` in the test) — choose margins deliberately.

### 2. `js_run` errors are data; metadata edits may not persist

A syntax error returns a successful tool call with:

```json
{"alerts":[],"console":[],"error":"SyntaxError: …","requests":[],"result":null}
```

Check `result.error` — `isError` stays false. In the test, `js_run
{script:"this.info.Title = 'JS set title'"}` printed no error and console output
worked, but after `doc_save` and `pdfinfo` the Title was unchanged. Prefer
`doc_set_info {key:"Title",value:…}` and verify with `pdfinfo`.

### 3. No URL validation in `link_add`

`link_add {url:"not a url"}` is accepted and stored as `not%20a%20url`; a
`javascript:alert(1)` URL is also accepted. Nothing warns. Validate schemes
yourself and avoid exporting untrusted links.

### 4. `doc_save` ignores the extension

`doc_save {path:"/tmp/out.xyz"}` writes a valid PDF (8561 B in the test). It does
not convert and does not warn. Use the `doc_export_*` tools for other formats.

### 5. Clipped/off-page text: PdfCraft and poppler disagree

`page_add_text` accepts negative `at` and arbitrary length without clipping the
model. A 50,000-character text plus a 2,000-character unbroken token produced:

- PdfCraft `text_word_count`: 52,001 characters, 10,001 words
- PdfCraft `text_extract` after reopen: 52,001 characters
- external `pdftotext`: 8,547 characters

Text beyond the page is not what an external consumer sees. Keep text inside the
page, split long content across pages, and validate with `pdftotext` when interop
matters.

## GUI

### 6. `ui.open` hangs pending

`pdfcraft-cli ui open path=…` returned `{accepted:…, pending:true}` and never
completed (even with a document already open). Open by argv when starting the
app, or open a second instance; do not block on `ui.open`.

### 7. `ui.command` drops parameters

The control source calls `host.command(id)` only. `ui command id=file.open` is a
silent no-op. Use dedicated methods (`ui.open` or argv) for parameterised
actions; `file.save`, `file.print`, etc. take no params and work.

### 8. Widget ids are per-frame; duplicate labels are ambiguous

Ids from an old `inspect` produce
`no widget with id … on screen (run ui.inspect again)`. Two widgets labelled
`Close` produce
`ui.click: 2 widgets are labelled "Close"; click one by id`. Use a fresh
`inspect` and click coordinates, or a unique label.

### 9. Properties dialog applies on OK only

Ctrl+D → edit a field → the dialog changes from `Close` to `OK`/`Cancel`.
`dirty` stays false while editing; **OK** applies, **Cancel** discards. Typing
appends to the existing value; clear the field first if replacing.

### 10. Quit needs an explicit decision

Unsaved `ui quit` returns `{quitting:false,needs_confirmation:true}` with
`state.close_prompt:true`. Choose Don't save / Cancel / Save from the prompt.
`Ctrl+S` (`key=S modifiers='["command"]'`) saves and then quit succeeds.

## Silent or surprising successes

| Behaviour | Evidence | What to do |
|---|---|---|
| `form_fill` coerces a number into a text field | `123` accepted, `form_fields` shows `"123"` | Validate types and read back |
| `doc_create {pages:0}` creates 1 page | returns `pages:1` | Ask for ≥1 explicitly |
| `page_add_text` off-page accepted | `at:[-10,-10]` OK; text_find rect at x≈496 | Keep `at` inside page bounds |
| `page_extract`/`doc_split` may return `{}` | files written (`pages-page1.pdf`, `<name>-partK.pdf`) | List the output folder |
| `doc_export_images` returns only `count` | 1 file, no path list; creates the folder even on bad format | List the folder |
| `doc_export_data .csv` + `what:"all"` errors | “comments travel as .xfdf or .fdf…” | Use `what:"fields"` for CSV |
| `action_run` failures can be a tool error with `{}` structured | `No Such Action` errors; step failures appear in `results` | Parse `content[0].text` |
| `doc_save` no-op adds no revision | five saves, `doc_revisions` still 1 | Do not use revisions as a save counter |
| `doc_print` on a machine with no printers | `printers: count 0`; saving to `path` still works | Use `path` for print-ready PDFs |
| Arabic text accepted | `page_add_text` + `text_extract` round-tripped `مرحبا` | Fonts are bundled; other scripts may still be refused |
| `command_batch` with `stop_on_error:false` still `isError` | `completed:0, failed:2, results:[…]` | Read `results` from the error payload |

## API shape / docs drift

### 11. Some read tools return JSON only in text content

`doc_info` (full), `bookmark_list`, `link_list`, `measure_list`,
`doc_hidden_info`, `doc_audit_space`, `doc_audit_redactions`, `pdfa_verify`,
`pdfa_convert`, `print_readiness`, `accessibility_check`, `accessibility_report`,
`ocr_status`, `ocr_recognize`, `doc_revisions`, `js_run`, `js_enabled`,
`js_document_scripts`, `doc_compare`, `doc_compare_mark`, `action_run`,
`sign_list`, `printers`, `command_list` return their payload in
`content[0].text`. A client that only shows `structuredContent` displays `{}`.
Parse the text.

### 12. Argument names that differ from what the prose suggests

| Prose / old note | Actual argument |
|---|---|
| `text_find {text}` | `{query}` |
| `page_rotate {angle}` | `{degrees}` (multiple of 90) |
| `page_set_box {page}` | `{pages}` (plus `box`, `rect`/`margins`) |
| `page_move {page,to}` | `{pages,to}` |
| `page_delete {page}` | `{pages}` |
| `page_extract {page}` | `{pages}` |
| `bookmark_move {to}` | `{position}` (and `path` is `[1]`, not a title) |
| `page_render` with `out` | MCP returns image content; CLI uses `out` **beside** `args` |

Unknown argument names are rejected with the expected list
(`page_rotate: unknown argument "angle" (expected: degrees, …)`); read that
message rather than guessing.

### 13. Required arguments the descriptions omit

`doc_create.from` (`blank|images|text`), `page_number.from`,
`text_find.query`, `doc_compare.other`, `comment_add.type`. Missing them errors
with `missing argument …`.

### 14. Counts and wrappers

171 MCP tools, 201 registry commands; 91 tools carry a command id.
`command_list`/`command_run` reach the rest. `--compact` exposes 17 tools.
Upstream text that says “all commands are tools” is inaccurate for 0.10.1.

### 15. Error-message oddities

- `page_move {pages:[1],to:99}` on a 2-page document:
  `to must be between 1 and 3 (the document has 2 pages)` — upper bound is off
  by one, though the move is still refused.
- `page_number {style:"arabic"}`: `unknown style "arabic"`; valid styles are
  `decimal`, `upper-roman`, `lower-roman`, `upper-alpha`, `lower-alpha`, `none`.
- `comment_image_preview` on a highlight:
  `choose an image signature or initials` — preview is for signature/initials
  images, not arbitrary annotations.

### 16. GUI app has no MCP bridge

There is no `pdfcraft-cli mcp --connect`; `pdfcraft-cli ui` is the only window
transport, and the control file has a dynamic port. Do not add an “app” MCP
server entry that pretends otherwise.

## Environment-dependent

- **No CUPS printers** on this machine (`printers: count 0`); printing was tested
  only to a PDF path.
- **OCR models were present** (`/usr/share/pdfcraft/models`, language `en`, shipped by the package). A source build
  may download them on first use; `ocr_status.available` is the check.
- **PDF/A verification** only proves PdfCraft's own rule set; external
  validators (veraPDF) were not installed.
