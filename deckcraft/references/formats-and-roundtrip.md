# Formats and round-trip — DeckCraft 0.9.0

All results below were produced with raw commands, then checked with an
independent tool (`pdfinfo`, `pdftotext`, `unzip`, ImageMagick `identify`,
LibreOffice headless). Test day 2026-10-22.

## What the native file is

`.deckcraft` is a ZIP:

```
mimetype          application/vnd.storyteller.deckcraft+zip
presentation.json  the whole deck (slides, shapes, theme, media refs)
media/<id>         embedded pictures / audio / video
```

It is **not** JSON at the top level: `unzip -p file.deckcraft presentation.json`
then read `slides`. Older files with a `slidecraft` mimetype are refused:
`not a DeckCraft file: slidecraft` (the shipped `assets/app-icon/icon-source.deckcraft`
in the repo is one of those). There is no conversion path in the CLI.

A `.deckcraft` save is deterministic: converting the same input three times gave
an identical SHA-256.

## Format matrix (verified)

| Path | Direction | Result |
|---|---|---|
| `.deckcraft` | save/open | Full fidelity. Shape, slide and layout ids survive; notes, comments, sections, hidden flags, transitions, animations and media survive. `file.info` reports `dirty:false` after save. |
| `.pptx` | export | Valid OOXML. Gradient fills, outlines with dash + arrowheads, glow/shadow/soft-edge effects, tables, charts, hyperlinks, notes slides, comments (legacy + modern), transitions (`p:transition`, morph), animation timing, media and hidden slides are all present. Opens in LibreOffice: correct page count and text. |
| `.pptx` | import | Works, including foreign files rewritten by LibreOffice. Reports `lostSlides`, `damagedMedia`, `missingFonts`. Layouts are re-created (ids change) and LibreOffice's output had two layouts both named “Title Slide”. |
| `.pdf` | export | `Creator/Producer: DeckCraft`, page size **960×540 pt**, selectable text (`pdftotext` returns titles, table cells, chart labels). Layouts: `slides` (default), `notes` (letter 612×792 with slide + notes), `handouts` with `perPage` 1/2/3/4/6/9 and `paper` letter/a4/legal/a3, `orientation` portrait/landscape. |
| `.png` | export | `scale` = px per point. `slide:1,scale:1` → 960×540; `all:true` → `<base>1.png`, `<base>2.png` (1-based suffix, base name not used verbatim). `transparentBackground:true` keeps an alpha channel (TrueColorAlpha). |
| `.jpg` | export | Default 1920×1080 (scale 2). |
| `.gif` | export | One frame per **visible** slide; `width` `small`→640×360, `medium`→960×540, `large`/`extraLarge` larger; `secondsPerSlide`, `loop`. A deck with one hidden slide produced 1 frame from 2 slides. |
| `.md` / `.txt` | export/converter | Both are the **same outline text**: tabs for levels, one line per paragraph, table cell text and SmartArt text included. `.md` is not Markdown. |
| `.potx` / `.ppsx` | convert only | Accepted by `deckcraft-cli convert`. The `file.export` format enum is `png|jpeg|pptx|deckcraft|outline|pdf|gif`. |

## Hidden slides

Hidden slides are **excluded by default** from PDF, GIF, `all:true` PNG exports
and the outline. Only `includeHidden:true` brings them back, and it applies to the
PDF path (2 pages instead of 1 in the test). A `slide.hide` on a slide that does
not exist returns success without hiding anything (see bugs).

## Fidelity checks that mattered

- **deckcraft → pptx → deckcraft**: 2 slides, all 5 shapes preserved, including
  a table (3×3 cells, style id) and a chart (categories/series title/type).
  Layout ids changed (12 → 269) and shape ids were renumbered; slide-level ids
  are stable only while the deck stays native.
- **Charts** default their text to **Arial**; reopening a deck with charts reports
  `missingFonts:["Arial"]` even when the deck's theme uses Inter/Merriweather.
  It is a warning, not a failure.
- **Table styles** are stored by id. `table.style {"style":"no-such-style"}` is
  accepted and the bogus id is written into the deck (see bugs), so a later
  renderer decides what it looks like.
- **Speaker notes** create `ppt/notesSlides/notesSlideN.xml` on export; they
  survive native save/open and appear in the notes PDF.
- **Comments** create `ppt/comments/comment1.xml`,
  `modernComment1.xml` and `commentAuthors.xml`. `inspect_slide` counts them;
  `comment.list` shows them for the **current** slide only.

## Import failures (all clean)

| Input | Result |
|---|---|
| truncated `.pptx` | `not a presentation DeckCraft can read` |
| empty `.pptx` | same |
| Markdown renamed `.pptx` | same |
| random bytes `.pptx` | same |
| missing path | `…: No such file or directory (os error 2)` |
| a `slidecraft`-era `.deckcraft` | `not a DeckCraft file: slidecraft` |

Nothing is half-written on import failure: the previously open deck stays open.

## Export failures

| Attempt | Result |
|---|---|
| `save_presentation` to `/nonexistent-dir/x.deckcraft` | tool error `No such file or directory (os error 2)` |
| `export` `slide:99` on a 2-slide deck | `invalid parameters for file.export: no slide 99` |
| GIF `width:"banana"` | `width must be a whole number…` |
| `convert out.docx` | CLI refuses by extension |
| `file.export` to `out.docx` | **silently writes a deckcraft ZIP named `.docx`** (see bugs) |
| `file.save {path:"x.pdf", format:"pdf"}` | writes a real PDF (undocumented format) |
| `file.save {path:"x.pptx", format:"deckcraft"}` | writes deckcraft bytes with a `.pptx` name |

## LibreOffice cross-check

```sh
flock -x /tmp/opencode/craft-heavy.lock -c \
  "soffice --headless -env:UserInstallation=file://$TMP/lo-profile \
   --convert-to pdf --outdir $TMP $DECK.pptx"
```

DeckCraft's `.pptx` opened with the expected slide count, its text and its chart
axes. LibreOffice's `.pptx` — built by converting DeckCraft's export through
`.odp` and back — re-opened in DeckCraft with both slides and the hidden flag
intact. Use a unique `-env:UserInstallation` per concurrent run; DeckCraft's PDF
writer is independent of LibreOffice, so the only heavy job is the LO check.
