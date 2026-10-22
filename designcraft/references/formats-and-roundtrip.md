# Formats and round-trip fidelity (DesignCraft 0.10.0)

Test document: A4, 2 pages, 36 pt display headline (custom paragraph style
`Display`), body text + 4×2 table, placed PNG in a filled frame, custom swatch
`Brand`, non-facing pages. Saved and exported on 2026-10-22.

## Matrix

| Format | Direction | Result | Independent check |
|---|---|---|---|
| `.designcraft` | save + reopen | **pass** — 2 pages, 3 items, `Display`, `Brand`, table 4×2, text byte-identical | `unzip -l`, `meta.json` |
| `.designcraft` | rename to `.idml` | **pass** — opens by content sniffing, not extension | `pageCount=2` |
| `.idml` | export | **pass** — 13 entries, `Stories/`, `Spreads/`, `Resources/`, correct mimetype | `unzip -l` |
| `.idml` | reimport (fresh process) | **pass** — 2 pages, 3 items, `Display` style, text intact, table as `\ue009` marker | `document.inspect` |
| `.indd` / `.indt` | import | **not tested** — no sample available; import-only, converts to IDML | — |
| PDF 1.7 | export | **pass** — 2 A4 pages, Producer `DesignCraft`, text searchable | `pdfinfo`, `pdftotext` |
| PDF/X-4 | `standard:"x4"` | **pass** — marker present, 730 kB, warning about RGB fill without output intent | `pdfinfo` |
| PDF/A-2b | `standard:"a2b"` | **pass** — `GTS_PDFA` marker, warning "CMYK colours converted to RGB" | `pdfinfo` |
| PNG | `export_png` / `render_page` | **pass** — 1191×1684 at scale 2, 595×842 at scale 1 | `identify` |
| JPEG | `export_png` path `.jpg` | **pass** — 1191×1684 JPEG | `identify` |
| EPUB reflowable | `file.exportEpub` | **pass** — 7 entries, `application/epub+zip`, container, 2 XHTML, OPF, image embedded | `unzip`, XML read |
| EPUB fixed | `file.exportFixedEpub` | **pass** — pre-paginated package | `unzip` |
| PPTX | `file.exportPptx` | **pass** — 20 entries, `[Content_Types].xml`, 2 slides, media | LibreOffice → PDF, text found |
| HTML | `file.exportHtml` | **pass** — 28 kB self-contained page, headline present | file read |
| XML | `file.exportXml` | **empty by design** unless styles have export tags (`style.exportTag`): output is `<?xml…?><Root></Root>` | file read |
| TXT / RTF / tagged text | `file.exportText` | **pass** (exports the selected story only) | file read |

## Native package

```
mimetype        application/vnd.designcraft+zip
meta.json       {"format":"designcraft","generator":"DesignCraft 0.10.0","version":2}
preview.png     first-page thumbnail
document.json   document model
assets/N.png    embedded images
```

`mimetype` is the **first** ZIP entry (stored, like OCF). A 2-page rich document
was 31,868 bytes; 100 pages + 228,000 characters was 119,788 bytes and reopened in
10 ms with byte-identical text.

## Import behaviour

- `file.open`/`open_document` **sniff content**, so a native file renamed `.idml`
  opens as native, and an IDML renamed `.zip` opens as IDML.
- Malformed input fails loudly with a specific message:
  - empty/garbage file → `not a DesignCraft document` / open error
  - ZIP without `designmap.xml` → `not an IDML package: missing designmap.xml`
  - missing file → `No such file or directory`
- `file.openBytes {name, base64}` opens native or IDML from memory.
- IDML import of the exported file preserved pages, items, styles and text; the
  table arrives as a `\ue009` marker in the story. `warnings:[]` in this case.
- Images are **embedded** in native files, so moving the source PNG does not break
  the document.

## Export behaviour and traps

- **Missing directory** is a clean error naming the path.
- **Wrong extension is not checked**: `file.exportPdf {path:"x.docx"}` writes
  `%PDF` bytes under `x.docx`; `file.exportIdml {path:"x.pdf"}` writes an IDML ZIP
  under `x.pdf`.
- **`file.save` appends, not replaces**: `path:"weird.pdf"` becomes
  `weird.pdf.designcraft`.
- Without `path`, PDF/IDML/EPUB exports return `{base64, bytes, …}` instead of
  writing a file.
- `export_png`/`render_page` reject out-of-range pages:
  `no page 99 (the document has 1 pages, indices are 0-based)`.
- EPUB warns when an image has no alt text and exports it as decorative
  (`alt=""`); set it with `object.altText {text, ids}` or
  `object.exportOptions {altText}`.
- PDF/X-4 requires a CMYK output intent for RGB artwork; the export still succeeds
  with a warning. PDF/A-2b currently converts CMYK to RGB because no CMYK output
  intent profile ships.

## Validator commands used

```sh
pdfinfo out.pdf                     # pages, size, producer
pdftotext -f 1 -l 1 out.pdf -       # text layer
unzip -l out.designcraft            # package entries
unzip -p out.designcraft meta.json
identify out/page1.png              # dimensions/format
soffice --headless -env:UserInstallation=file:///tmp/lo-profile \
        --convert-to pdf --outdir /tmp/lo out.pptx
```

Not installed on this machine: `qpdf`, `xmllint`, `epubcheck`, `veraPDF`,
`ffprobe`. PDF structure was checked with `pdfinfo`/`pdftotext` only; EPUB with
ZIP + XML inspection, not `epubcheck`.
