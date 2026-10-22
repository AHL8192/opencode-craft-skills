---
name: PdfCraft
description: Use whenever working with PdfCraft on this machine — the Rust PDF editor and Acrobat alternative — including opening, editing, commenting, form filling, redacting, protecting, OCR, PDF/A, printing or converting PDFs, driving the running desktop window, or using its MCP server, CLI or control channel. Triggers on "PdfCraft", "pdfcraft-cli", "pdfcraft mcp", "PdfCraft MCP", "edit this PDF", "redact this PDF", "fill this form", "OCR this scan", "make this PDF searchable", "save as PDF/A", "merge/split PDFs", "add comments/highlights to a PDF", "take a PdfCraft screenshot", and requests to automate PDF work or PdfCraft itself. Invoke with @pdfcraft.
---

# PdfCraft — agent operation

PdfCraft is a native Rust PDF editor with an Acrobat-style UI, a headless engine,
a CLI, a JSON control channel and an MCP server. Every menu action is a
**registry command** (201 in 0.10.1); 171 MCP tools wrap the same engine.

## Machine snapshot (verified 2026-10-22)

| Thing | Value |
|---|---|
| App / CLI | `/usr/bin/pdfcraft`, `/usr/bin/pdfcraft-cli` — both `0.10.1` |
| Install | Debian `pdfcraft 0.10.1-1` |
| Headless MCP | `pdfcraft-cli mcp` → OpenCode server `pdfcraft` |
| GUI MCP | **n/a** — no `--connect`; drive the window with `pdfcraft-cli ui` |
| Control | `pdfcraft --control FILE [file.pdf]`; FILE gets `{pid,port,token}` (0600) |
| Tools | **171**; `--compact` gives **17** incl. `tool_search`/`tool_call` |
| Commands | **201** in 24 namespaces; 91 tools carry a command id |
| Resources | `pdfcraft://document`, `pdfcraft://commands`, `pdfcraft://doc/{doc}/{info,text}`, `…/page/{n}/{text,image}` |
| Protocol | MCP `2025-06-18`, JSON-RPC over stdio |
| Config | `~/.config/opencode/opencode.json` → `mcp.servers.pdfcraft` |
| Prefs / control | `~/.config/pdfcraft/app.ron`, `control-*.json` |

OpenCode runs only the headless server. The app is a separate process and has no
MCP bridge; its port is dynamic.

## Mental model

- A **document** is a PDF with pages, annotations, fields, outline, links,
  attachments, layers and metadata. `doc_open` returns a **session-local id**
  (1, 2, 3…); ids are never reused, and a reopen gets a new id. A stale id fails
  with `no open document with id N (see doc_list)`.
- **Pages are 1-based.** Rects are points (72/inch), origin **top-left of the
  displayed page**, y down — the same frame as `text_find`, `comment_*` and
  `page_add_text`.
- **Edits are undoable** until saved. `doc_save` writes; `doc_save {path}` is
  Save As. `doc_close` errors on unsaved changes unless `discard_changes:true`.
- **Save ≠ export.** Native save writes PDF only; `doc_export_*` writes
  docx/pptx/html/rtf/txt/images/xfdf/csv separately.
- **Verify by reading back** (`doc_info`, `text_extract`, `form_fields`,
  `comment_list`) and externally (`pdfinfo`, `pdftotext`), not by OK status.

## Surfaces

| Surface | Start | Use for |
|---|---|---|
| Headless MCP | `pdfcraft-cli mcp` (configured) | all document work, batch, OCR, exports |
| CLI | `pdfcraft-cli <verb>` | scripts, info/text/render, batch, audit, UI |
| GUI control | `pdfcraft --control FILE doc.pdf`, then `pdfcraft-cli ui --control FILE …` | state, click/type/drag, screenshots |

```sh
pdfcraft-cli mcp                                     # headless MCP
CTRL=~/.config/pdfcraft/control-skilltest-$(date +%s).json
pdfcraft --control "$CTRL" /path/doc.pdf &           # no "--" before the PDF
pdfcraft-cli ui --control "$CTRL" state
pdfcraft-cli ui --control "$CTRL" screenshot --out /tmp/shot.png
```

The app writes `{pid,port,token}` to `CTRL` (0600). Kill only your PID; remove
only your control file.

## Standard workflow

1. **Probe:** `doc_list`, `doc_info`, `text_find`, `form_fields`,
   `comment_list`; `command_list` for ids not wrapped as tools.
2. **Open/create:** `doc_open {path,password?}` or `doc_create {from:"blank",
   pages, width, height}` (`from` is required: `blank|images|text`).
3. **Edit:** page ops, content, comments, forms, marks. Keep ordered edits in one
   session; use `command_batch` for many steps.
4. **Read back:** `text_extract`, `doc_info`, `form_fields`, `comment_list`;
   `page_render` returns PNG image content.
5. **Save a copy:** `doc_save {doc,path}`; same path to overwrite. Destructive
   work: new path or a backup.
6. **Close:** `doc_close {doc}` / `{discard_changes:true}`.
7. **Validate externally:** `pdfinfo`, `pdftotext`, `unzip -l` (docx/pptx),
   `soffice --headless --convert-to txt`.

## Tools (171)

Full args and descriptions: `references/commands.md`. Registry ids:
`references/command-index.md`.

Documents (38): `doc_open/create/info/save/close/list`, `doc_protect`,
`doc_unprotect`, `doc_compare`, `doc_print`, `doc_revisions`, `doc_export_*`.
Pages (17): `page_rotate/move/delete/insert_blank/insert_file/replace/extract/
split/render/set_box/number`. Text/content (13): `text_extract/find/
word_count`, `page_add_text/image`, `content_list/update/delete`. Comments (9),
forms (13), redaction (3), security (5), PDF/A (2), accessibility (18), OCR (3),
export (7), bookmarks (7), links (5), measure (8), signatures (6), JS (4),
commands (3).

## MCP quirks that matter

- **Return shape is mixed.** Most edit tools fill `structuredContent`; most read
  tools (`doc_info`, `bookmark_list`, `pdfa_verify`, `accessibility_check`,
  `doc_revisions`, `js_run`, `action_run`, …) put JSON only in
  `content[0].text`. A `{}` in a client can be data — parse the text.
- **Unknown arguments are rejected loudly** (`unknown argument "angle"
  (expected: degrees, …)`). Exception: `command_run` ignores unknown `params`
  keys with warnings.
- **Plural `pages`** is used by page-op tools (`page_rotate/move/delete/extract/
  set_box`); single-page reads use `page`. Rotation is `degrees` (multiples of 90).
- **Required but not in the prose:** `doc_create.from`, `page_number.from`,
  `text_find.query`, `doc_compare.other`, `comment_add.type`. MCP `page_render`
  has no `out` (returns an image); the CLI puts `out` beside `args`.
- **`doc_save` never converts**; it writes PDF bytes whatever the extension.

## Pitfalls

- **Redaction can leave readable text.** `redact_mark {find:"Total due"}` +
  `redact_apply` left `": 42"` extractable, and `doc_audit_redactions` then
  flagged the app's **own** box; the apply did not fail. Always audit after
  applying, re-mark reported rects (slightly larger), repeat until `count:0`,
  save to a new path, and confirm with `pdftotext` / `pdfcraft-cli audit`.
- **`js_run` errors are data.** A syntax error returns `isError:false` with
  `result.error`. Setting `this.info.Title` did not change saved metadata — use
  `doc_set_info` and verify with `pdfinfo`.
- **No URL validation:** `link_add` accepts `not a url` (stored as
  `not%20a%20url`) and `javascript:alert(1)`.
- **Text is not clipped to the page.** Negative `at` and arbitrary length are
  accepted. A 50k-char test gave `text_extract` 52,001 chars but external
  `pdftotext` 8,547 — keep text on-page and verify externally.
- **Silent corrections:** `doc_create {pages:0}` makes 1 page; `page_move`'s
  error for a 2-page doc says “between 1 and 3” (still refuses); a number in a
  text field is coerced; `doc_save` to `.xyz` writes a PDF.
- **Missing output lists:** `page_extract`/`doc_split` with `out_dir` may return
  `{}` though files exist; `doc_export_images` returns only `count`. List the
  folder.
- **Ids, indices, paths:** reopening changes doc ids; comment indices are
  unstable (use `id`); bookmark `parent`/`path` are `[1]`-style integer arrays
  (not titles); `bookmark_move` uses `position`.
- **Comment geometry is type-specific:** note=`at`, callout=`to`, cloud=
  `points`, highlight/underline=`find` or `quads` (a bare `rect` errors).
- **Forms/security:** unknown fields and bad radio options error; `doc_close`
  protects unsaved work; restrictive permissions block text extraction and
  unprotect — reopen with the owner password.

## GUI control (verified)

`pdfcraft-cli ui --control FILE <method>`: `state`, `inspect`,
`screenshot --out`, `click x=|id=|label=`, `drag from=[x,y] to=[x,y]`, `focus`,
`type text=`, `key key= modifiers='["command"]'`, `set key= value=`,
`command id=`, `open path=`, `quit`.

- **Map points to screen** from `state.active.pages_on_screen[0].rect`:
  `sx = x + px*width/page_width`; same for y. Re-read `state` after choosing a
  tool (zoom can change) and after scroll. A computed drag over “Total due”
  produced the exact highlight rect `[40,78.88,98.35,92.88]`.
- **Widget ids change every frame.** Old ids fail with “run ui.inspect again”;
  duplicate labels (“Close”) are ambiguous — use a fresh `inspect` and
  coordinates.
- **`ui.command` ignores params** (calls `host.command(id)` only), so
  `file.open` via it is a no-op; `file.save` works. **`ui.open`** returns
  `{accepted,pending:true}` and never completed in 0.10.1 — open by argv.
- **Properties (Ctrl+D)** applies on **OK**, discards on **Cancel**; it switches
  from `Close` to `OK`/`Cancel` after the first edit. Typing appends.
- **Unsaved quit** returns `{quitting:false,needs_confirmation:true}` and
  `state.close_prompt:true`; Cancel keeps the app, Ctrl+S saves, then quit
  succeeds.
- Screenshots are PNGs a text-only agent cannot see; use `state`/`inspect` plus
  file validation. Screenshot and control evidence were captured in testing.

## CLI in 30 seconds

Full reference: `references/cli.md`.

```sh
pdfcraft-cli info doc.pdf                 # JSON summary
pdfcraft-cli text doc.pdf                 # text, form feeds between pages
pdfcraft-cli render doc.pdf --page 1 --dpi 96 --out p.png
pdfcraft-cli edit in.pdf --out out.pdf --rotate 1:90 --delete 2 --title T
pdfcraft-cli extract in.pdf --pages 1,3-5 --out part.pdf
pdfcraft-cli split in.pdf --every 10 --out-dir parts
pdfcraft-cli combine a.pdf b.pdf --out both.pdf
pdfcraft-cli audit doc.pdf                # faux redactions; fails on findings
pdfcraft-cli check docs/ --json report.json
pdfcraft-cli batch docs/ --steps convert,ocr,optimize --out-dir out
pdfcraft-cli tools                        # 171 schemas
pdfcraft-cli run --script steps.json --root DIR --report
pdfcraft-cli mcp [--root DIR] [--compact]
pdfcraft-cli ui --control FILE state
```

Scripts are `[{"tool":"doc_open","args":{…}}, …]`. `page_render` needs `"out"`
beside `"args"`, not inside. `--root` confines reads **and** writes (an outside
path errors); MCP also supports `--automation-read-root`/`-write-root`, where an
omitted side grants no access.

## References and maintenance

`references/`: `commands.md`, `command-index.md`, `mcp-and-control.md`,
`cli.md`, `recipes.md`, `formats-and-roundtrip.md`,
`bugs-and-workarounds.md`, `maintenance.md`.
`scripts/`: `probe.sh`, `dump-commands.sh`, `smoke-test.sh`.

PdfCraft moves fast; the snapshot is **2026-10-22 / 0.10.1**. Re-verify before
trusting a detail:

```sh
bash ~/.config/opencode/skills/pdfcraft/scripts/probe.sh
bash ~/.config/opencode/skills/pdfcraft/scripts/dump-commands.sh
bash ~/.config/opencode/skills/pdfcraft/scripts/smoke-test.sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/pdfcraft
```

Update this file and the references when the binary differs; keep the body under
12,000 bytes so the checker stays clean.
