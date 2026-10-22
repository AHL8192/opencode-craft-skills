---
name: DesignCraft
description: Use whenever working with DesignCraft on this machine — the Rust page-layout and desktop-publishing app and InDesign alternative — including creating, editing or restyling documents (spreads, pages, parent pages, text frames, threaded stories, paragraph/character styles, tables, swatches, images), importing IDML/INDD, exporting PDF/PNG/JPG/EPUB/PPTX/HTML/IDML, driving the running desktop window, or using its MCP server, `designcraft-cli`, JSON control channel or command engine. Triggers on "DesignCraft", "designcraft-cli", "designcraft mcp", "DesignCraft MCP", "lay out this page/magazine/brochure", "make a PDF from this layout", "thread this text", "export IDML", "take a DesignCraft screenshot", "drive the DesignCraft window", and requests to automate page layout or DesignCraft itself. Invoke with @designcraft.
---

# DesignCraft — agent operation

DesignCraft is a native Rust page-layout studio (pre-alpha, 0.10.0). Every menu
item, panel control, tool gesture and dialog is a **command with an id**. The
CLI, MCP server, JSON control channel and the GUI all drive the same engine.

## Machine snapshot (verified 2026-10-22, package 0.10.0-1)

| Thing | Value |
|---|---|
| App | `/usr/bin/designcraft` — `designcraft 0.10.0` |
| CLI | `/usr/bin/designcraft-cli` — `designcraft-cli 0.10.0` |
| Install | Debian package `designcraft` `0.10.0-1` |
| Headless commands | **521** in 64 namespaces (`designcraft-cli commands`) |
| App commands | **685** (164 extra `ui:*` menu commands need a window) |
| MCP tools | **26** (`designcraft-cli mcp`) |
| MCP resources | `designcraft://document`, `designcraft://commands` (2; menus come from the `menu_list` tool) |
| Control channel | `designcraft --control PORT`, JSON lines on `127.0.0.1`, no auth |
| Profile | `~/.config/designcraft/` (`ui.json`, `prefs.json`, `logs/`, `Recovery/`) |
| Isolate a test GUI | `DESIGNCRAFT_CONFIG_DIR=/path` before launch |
| Native format | `.designcraft` = ZIP: `mimetype`, `meta.json`, `preview.png`, `document.json`, plus an `assets` directory for images |

**Gotcha:** `designcraft --help` *launches the GUI* and treats `--help` as a file
to open. Probe with `--version` only; use `designcraft-cli` for help.

## Mental model

- A **document** holds **spreads**; each spread holds **pages** and **items**
  (frames, shapes, images, groups). Page numbering: `pageCount` is total pages,
  pages are nested under `spreads[].pages[]` (there is no top-level `pages` array
  in `inspect_document`, despite the docs).
- **Stories** are separate from items: a text frame points at a `story` id.
  Threaded frames share one story. Offsets are **UTF-8 byte offsets**.
- **All lengths are points** (72 pt = 1 in). Export scale is pixels per point.
- A frame `rect` is `[x0, y0, x1, y1]` in **spread points**, y down.
- **Indices:** spread/page offsets in `layout.pages.*`, `frame.create.spread`,
  `render_page.page`, `export_png.page` are **0-based**. `layout.selectPage`,
  `layout.pageSize.pages`, `ui_set.page` and export `pages` strings are **1-based**.
- A command is `{"command":"frame.create","params":{…}}`. The MCP tool `execute`
  runs one, `batch` runs several (`"$N.path"` references earlier results).
- **Verify by reading back** (`inspect_document`, `get_story`, `table.get`,
  `render_page`), never by assuming a command worked.

## Two connection modes

| Mode | How | Use for |
|---|---|---|
| Headless | `designcraft-cli mcp` → OpenCode `designcraft` | Batch layout, import/export, scripts, CI. No window; UI tools return errors. |
| App bridge | `designcraft --control 7984` + `designcraft-cli mcp --connect 127.0.0.1:7984` → OpenCode `designcraft-app` | Screenshot, click, drag, keys, menus, dialogs, real window. |

OpenCode entries (already registered on this machine):

```json
"designcraft":      { "type": "local", "command": ["/usr/bin/designcraft-cli","mcp"] },
"designcraft-app":  { "type": "local", "command": ["/usr/bin/designcraft-cli","mcp","--connect","127.0.0.1:7984"] }
```

Start an isolated window (never hijack a user instance):

```sh
DESIGNCRAFT_CONFIG_DIR=/tmp/dc-profile designcraft --control 7984 &
ss -ltn | grep :7984          # wait for the port
designcraft-cli mcp --connect 127.0.0.1:7984
```

Port 7979 is `designcraft-cli app`'s default but is also GridCraft's configured
port; use **7984+** and check `ss` first. The `designcraft-app` MCP entry is
started with the session, so after starting or stopping the window, reload the
session (or reconnect MCP) before using it.

## Minimal working example

CLI script (headless, no MCP client needed):

```sh
cat > page.dcs <<'DCS'
file.new {"preset":"A4","pages":2,"margins":48}
frame.create {"rect":[48,48,547,140],"content":"text","text":"Quarterly Report","caret":true}
type.char {"attrs":{"size":36}}
frame.create {"rect":[48,180,547,500],"content":"text","text":"Body copy set from a script."}
DCS
designcraft-cli script page.dcs --save out.designcraft --export out.pdf
pdfinfo out.pdf | grep -E 'Pages|Page size'
```

Same thing through raw MCP tools:

```python
new_document({"preset": "A4", "pages": 2})
frame_create = execute({"command":"frame.create","params":{
    "rect":[48,48,547,140], "content":"text", "text":"Quarterly Report", "caret":True}})
get_story({"frame": frame_create["id"]})       # read back
render_page({"page":0, "scale":2, "path":"page0.png"})
save_document({"path":"out.designcraft"})
open_document({"path":"out.designcraft"})      # fresh path proves persistence
```

## Safest default workflow

1. `new_document` (or `open_document` on a **copy**) and keep the returned index.
2. Build with `frame.create` → `text.insert`/`set_story_text` → `type.*` /
   `style.*` → `table.*` / `place_image`.
3. Read back with `inspect_document`, `get_story`, `table.get`; render with
   `render_page` when appearance matters.
4. `save_document` to `.designcraft`, then **reopen in a fresh process** and
   compare text/ids. Native save embeds images inside the package (`assets` entries).
5. Export only what you need: `export_png`, `file.exportPdf`, `file.exportIdml`,
   `file.exportEpub`/`file.exportFixedEpub`, `file.exportPptx`, `file.exportHtml`.
6. Validate outside the app: `pdfinfo`/`pdftotext`, `unzip -l`, ImageMagick
   `identify`, LibreOffice for PPTX.

## Key commands (full list: `references/command-index.md`)

| Task | Command |
|---|---|
| New/open/save | `file.new`, `file.open`, `file.save`, `file.saveAs`, `file.saveACopy` |
| Frames | `frame.create {rect, content: text\|graphic\|unassigned, text, caret}`, `frame.grid` |
| Text | `text.insert`, `set_story_text`, `text.select {story,anchor,focus}`, `text.thread`, `text.move` |
| Formatting | `type.char {attrs:{size,tracking,fill,…}}`, `type.para {attrs:{…}}`, `type.bold`, `type.selectionAttrs` |
| Styles | `style.paragraph.create/apply`, `style.character.create/apply`, `style.object.create/apply` |
| Swatches | `swatch.create {name,color}`, `object.fill`, `object.stroke` |
| Tables | `table.insert {rows,cols,headerRows}` (rows = body rows), `table.get {table}`, `table.setCell` |
| Pages | `layout.pages.insert/delete/move`, `layout.marginsAndColumns`, `layout.parents.new` |
| Objects | `object.rename`, `object.arrange`, `object.group`, `transform.move/resize/set`, `object.setLayer` |
| Images | MCP `place_image {path\|base64, frame?, x, y, width}` |
| Export | `file.exportPdf {standard: none\|x4\|a2b}`, `file.exportIdml`, `file.exportPptx`, MCP `export_png` |
| Undo | `edit.undo`, `edit.redo` (redo is invalidated by a new action; redo then errors) |

## Known bugs and workarounds (0.10.0)

Details and reproductions: `references/bugs-and-workarounds.md`.

- **Inverted rects** `[x1,y1,x0,y0]` do **not** normalize: you get a 0.5×0.5 pt
  sliver at `(x0,y0)`. Normalize rects yourself before `frame.create`.
- **Nonexistent object ids** make `object.fill`/`rename`/`edit.clear` return
  `{"changed":1}` / `{"deleted":1}` while changing nothing. Check ids from
  `inspect_document`; never trust the count.
- **Invalid enum/type values are sometimes ignored**: `content:"txt"` becomes a
  rectangle, `shape:"hexagon"` is dropped, `weight:"thick"` and `size:"big"` are
  ignored, `opacity:2.5` is accepted. Validate inputs yourself.
- **`layout.pages.delete` with an out-of-range index** returns success and does
  nothing.
- **`ui.menu.invoke` on `ui:*` items** (`ui:app.preferences`, `ui:view.fitPage`,
  panel toggles, `ui:help.about`) returns `{"ok":true,"dialog":null}` and does
  nothing. Use `cmd:*` items, the MCP `ui_set`/`click` tools, or `engine.execute`.
- **`engine.execute` cannot open dialogs.** Use the control method
  `ui.menu.invoke {"command":"layout.documentSetup"}` (a `cmd:` id) to open one,
  then MCP `dialog_set`/`dialog_confirm`/`dialog_cancel`.
- **`dialog_set` accepts unknown field names** and stores them; confirm then
  fails on bad values (`width: not a measure`) and leaves the dialog open.
- **Wrong extension is not checked on export**: `file.exportPdf` to `x.docx`
  writes PDF bytes with that name.
- **Table addressing:** `table.get {story}` only works while the caret is inside
  the table. After reopen use the **table id**: `table.get {"table":10}`.
- **`inspect_document` overset is `false`/number** in the story summary while
  `get_story` returns `null`/byte offset — normalize both.
- **`--help` opens the GUI** (see above). Use `--version`.

## Safety rules

- Never edit a user's original; copy to a scratch dir first and save under a new name.
- Export/save paths are taken literally; a missing directory is an error, but a
  wrong extension is not. Always confirm the file type with `file`/`pdfinfo`/`unzip`.
- Isolate GUI runs with `DESIGNCRAFT_CONFIG_DIR` and a free control port; kill
  only the PID you started (the control port has **no authentication**).
- `edit.clear`, `layout.pages.delete`, `file.revert` and `object.releaseCompoundPath`
  are destructive and often silent. Undo depth is not documented; save a copy
  before bulk edits.
- Concurrent `soffice`/PDF rasterization is heavy: give LibreOffice its own
  `-env:UserInstallation` profile and do not run several at once.

## What was not tested

- INDD/INDT import: no sample file on this machine and no source available; the
  format is import-only in 0.10.0.
- EPUB/PDF accessibility validators (`epubcheck`, `veraPDF`, `qpdf`) are not
  installed; validation used `pdfinfo`, `pdftotext`, `unzip` and LibreOffice.
- Mac/Windows behaviours (Cocoa menu shortcuts, DirectX/Metal backends).
- Full 521-command behavioural coverage: ~120 checks were run against the core
  object, text, style, table, page, export and GUI paths. Untested commands are
  documented only by their parameter strings, not verified.
