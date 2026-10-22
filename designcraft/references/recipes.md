# DesignCraft recipes

All examples are raw MCP tool calls (`execute` = one command). They were run
against 0.10.0 on this machine. Coordinates are points, `[x0,y0,x1,y1]`, y down.

---

## 1. Create a print-ready A4 document

```json
new_document {"preset":"A4","pages":2,"facingPages":false,"margins":48}
execute {"command":"file.new","params":{"preset":"Letter","intent":"print",
         "margins":{"top":36,"bottom":36,"inside":42,"outside":36},"bleed":3}}
```

`new_document`/`file.new` returns `{index}`, not a document id — later commands act
on "the active document". Defaults from `prefs.json` apply: facing pages is **on**
unless you pass `facingPages:false`, so 100 pages become 51 spreads.

## 2. Headline + body with real styles

```json
execute {"command":"frame.create","params":{"rect":[48,48,547,150],"content":"text",
         "text":"Quarterly Report","caret":true}}
execute {"command":"text.select","params":{"story":10,"anchor":0,"focus":16}}
execute {"command":"style.paragraph.create","params":{"name":"Display",
         "para":{"align":"left","spaceAfter":18}}}
execute {"command":"type.char","params":{"attrs":{"size":36}}}
execute {"command":"style.paragraph.apply","params":{"name":"Display"}}
```

Read back with `execute type.selectionAttrs {}` → `{paragraphStyle:"Display",
chars:{size:36.0,…}}`. Style names are document-scoped; duplicates auto-rename
(`Dup`, `Dup 2`).

## 3. Flowing body copy into threaded frames

```json
execute {"command":"frame.create","params":{"rect":[48,180,290,760],"content":"text",
         "text":"Long copy …"}}
execute {"command":"frame.create","params":{"rect":[310,180,547,760],"content":"text"}}
execute {"command":"text.thread","params":{"from":11,"to":13}}
get_story {"frame":11}       # frames:[11,13], one story, overset: null|byte offset
```

`get_story.overset` is `null` when everything fits, otherwise the UTF-8 byte
offset where the hidden text starts.

## 4. Table in a text story

```json
execute {"command":"frame.create","params":{"rect":[48,180,547,600],"content":"text",
         "text":"Data","caret":true}}
execute {"command":"text.move","params":{"dir":"storyEnd"}}
execute {"command":"table.insert","params":{"rows":3,"cols":2,"headerRows":1}}
execute {"command":"table.get","params":{"table":10}}
```

`rows` means **body rows**; `headerRows` adds on top (3 body + 1 header = 4 rows).
Cells are addressed via `table.select {table, rows:[a,b], cols:[a,b]}`. After a
save/reopen the caret is gone, so address the table by its **id** (`table:10`),
not by `story`.

## 5. Swatches, fills and strokes

```json
execute {"command":"swatch.create","params":{"name":"Brand","color":"#1a6fb5"}}
execute {"command":"object.fill","params":{"swatch":"Brand","ids":[11]}}
execute {"command":"object.stroke","params":{"swatch":"[Black]","weight":2,
         "align":"outside","ids":[11]}}
```

Built-in swatches: `[None]`, `[Paper]`, `[Black]`, `[Registration]`, plus CMYK
process names such as `C=100 M=0 Y=0 K=0`. A nonexistent swatch is a clean error.

## 6. Place an image (and crop-fit it)

```json
place_image {"path":"/abs/path/photo.png","x":320,"y":180,"width":180}
execute {"command":"object.fit","params":{"mode":"fillProportionally","ids":[15]}}
execute {"command":"object.textWrap","params":{"mode":"boundingBox","offset":12,
         "ids":[15]}}
```

`place_image` is an **MCP tool**, not a command (`engine.execute place_image`
fails with `unknown command`). It returns `{id, asset}`. Native save embeds the
image bytes under `assets/`; the file is self-contained.

## 7. Pages, parents and margins

```json
execute {"command":"layout.pages.insert","params":{"count":2,"after":0}}
execute {"command":"layout.marginsAndColumns","params":{"margins":54,"columns":3,
         "gutter":14}}
execute {"command":"layout.parents.new","params":{"prefix":"B","name":"Feature"}}
execute {"command":"layout.pages.applyParent","params":{"pages":[0,1],"parent":"B-Parent"}}
```

Page indices here are 0-based. `layout.selectPage` and `layout.pageSize.pages`
take 1-based page numbers — do not mix them.

## 8. Export and verify

```json
execute {"command":"file.exportPdf","params":{"path":"out/report.pdf",
         "standard":"x4","bleed":true,"marks":true}}
execute {"command":"file.exportIdml","params":{"path":"out/report.idml"}}
execute {"command":"file.exportPptx","params":{"path":"out/report.pptx"}}
export_png {"page":0,"path":"out/page1.png","scale":2}
```

Then outside the app:

```sh
pdfinfo out/report.pdf | grep -E 'Pages|Page size|Producer'
pdftotext -f 1 -l 1 out/report.pdf - | head
unzip -l out/report.idml | head
identify out/page1.png
```

## 9. Save, reopen, prove persistence

```json
save_document {"path":"/abs/out.designcraft"}
open_document {"path":"/abs/out.designcraft"}     # fresh process is strongest
inspect_document {}
get_story {"frame":11}
```

Native ids are stable across save/reload. `inspect_document` after reopen has
`dirty:false` and `path` set. The native file is a ZIP:

```
mimetype       application/vnd.designcraft+zip
meta.json      {"format":"designcraft","generator":"DesignCraft 0.10.0","version":2}
preview.png    page-1 thumbnail
document.json  the document
assets/N.png   embedded images
```

## 10. GUI: create a text frame with the real tools

```text
select_tool {"tool":"type"}
pointer {"events":[{"kind":"down","x":140,"y":180},
                   {"kind":"drag","x":520,"y":300},
                   {"kind":"up","x":520,"y":300}]}
type_text {"text":"Hello from the GUI"}
key {"key":"Escape"}
inspect_document {}      # one <text frame> at [140,180,520,300], story length 18
```

`pointer` coordinates are **document (spread) points** by default. Wait 0.5–1.5 s
after a gesture before reading state; input is queued across frames. The
`click`/`drag` tools use **screen points** (window top-left = 0,0) and reach
menus and dialogs; map document→screen with:

```
screen_x = canvasRect.x0 + (doc_x - view.origin.x) * view.zoom
screen_y = canvasRect.y0 + (doc_y - view.origin.y) * view.zoom
```

## 11. GUI: dialog that really applies

```text
# raw control channel, not engine.execute
{"method":"ui.menu.invoke","params":{"command":"layout.documentSetup"}}
→ {"dialog":"documentSetup"}

dialog_set {"field":"width","value":"250 mm"}
dialog_set {"field":"height","value":"300 mm"}
dialog_confirm {}
```

Then `inspect_document.settings.pageWidth == 708.66` (250 mm in points) and
`dialog == null`. `dialog_cancel` leaves the document unchanged. Note that
`engine.execute layout.documentSetup {}` applies without opening a dialog.

## 12. Undo safely

```json
execute {"command":"transform.move","params":{"dx":25,"dy":0}}
key {"key":"Z","cmd":true}          # real shortcut path (app mode)
# or: execute {"command":"edit.undo"}
```

Undo works; after a new action a redo is rejected with
`command edit.redo is not available right now: nothing to redo`. Bulk operations
are a single undo step per command.

## 13. Find and change

```json
execute {"command":"find.find","params":{"find":"alpha"}}          # → [{story,start,end,text}]
execute {"command":"find.find","params":{"find":"alpha","change":"gamma"}}
# ↑ `change` is documented as IGNORED here — no replacement happens
execute {"command":"find.change","params":{"find":"alpha","change":"gamma"}}
# → {count:2}, text becomes "gamma beta gamma"
```

## 14. Batch with references

```json
batch {"commands":[
  {"command":"file.new","params":{"preset":"A4","pages":1}},
  {"command":"frame.create","params":{"rect":[36,36,400,200],"content":"text",
   "text":"Batch one"}},
  {"command":"frame.create","params":{"rect":[36,220,400,400],"content":"text",
   "text":"$1.story"}}
]}
```

`$N.path` resolves a field of step N's result (0-based, comments not counted);
`${N.path}` interpolates inside a longer string. `batch` stops at the first error
unless the script is run with `--keep-going`.
