# Bugs and workarounds — DeckCraft 0.9.0 (2026-10-22)

Everything here was reproduced with a raw call. "Silent success" means the call
returned success (or a neutral `null`) and did nothing, or did something other
than what was asked.

## Silent successes — check the result, never the status

### 1. Unknown command parameter is ignored
```json
{"command":"slide.new","params":{"titel":"Typo Title","layout":"titleOnly"}}
→ {"id":258,"index":1}          // slide has an empty title
```
A typo inside `run_command.params` is never reported. Only **tool** arguments
are schema-checked (`add_shape` with `bogus` is refused). Workaround: read
`deckcraft-cli describe ID` (or `commands.list`) and verify with `inspect_slide`.

### 2. Wrong-typed values are dropped, not rejected
```json
{"command":"slide.new","params":{"layout":"titleOnly","title":123}}   → ok, title ""
{"command":"shape.move","params":{"dx":"abc"}}                        → ok, shape did not move
{"command":"shape.rotate","params":{"deg":"abc"}}                     → ok, rotation unchanged
```
Use numbers, not numeric strings. A real string enum/colour is validated
(`shape.fill {"color":"notacolor"}` errors; `"#GGGGGG"` errors).

### 3. Malformed `rect` falls back to a centred 72×72 default
```json
{"command":"shape.insert","params":{"preset":"rect","rect":"100,100,200,200"}}
{"command":"shape.insert","params":{"preset":"rect","rect":[100,100]}}
→ both ok, shape box [444,234,72,72]
```
Always pass four numbers. This is the most dangerous silent success for layout
work: shapes land in the middle of the slide instead of failing.

### 4. Zero-size table and unknown chart type are coerced
```json
{"tool":"insert_table","args":{"rows":0,"cols":0}}      → 1×1 table
{"tool":"insert_chart","args":{"type":"banana", …}}      → "Clustered Column"
```
Validate the result with `inspect_slide` (table rows/cols, chart type).

### 5. Unknown table style is stored verbatim
```json
{"command":"table.style","params":{"style":"no-such-style"}} → 1
```
The deck now contains `"style":"no-such-style"`. Rendering falls back to a
default, and other apps may do something else. Stick to ids from the docs
(`medium2-accent1`, `light1-accent2`, `dark1-tx1`, `grid`, `none`).

### 6. `slide.hide` accepts an out-of-range index
```json
{"command":"slide.hide","params":{"index":999}} → {"hidden":true}
```
No slide is hidden (`inspect_document` shows all `hidden:false`). Check
`inspect_document` afterwards.

### 7. `edit.delete` with nothing selected returns `null`
Harmless, but it is not an error — do not treat `null` as "deleted".

### 8. `smartArt.*` with a wrong id silently uses the selection
```json
{"command":"smartArt.nodes","params":{"id":267}}   // 267 does not exist
→ {"id":271, …}                                     // operated on the selected SmartArt
```
Always read the returned `id` and use that.

## Wrong file format written, with a success status

### 9. `file.export` to an unsupported extension writes deckcraft bytes
```json
{"command":"file.export","params":{"path":"out/bad.docx"}}
→ {"path":"…/bad.docx","bytes":5098}
$ file out/bad.docx
Zip data (MIME type "application/vnd.storyteller.deckcraft+zip")
```
The CLI `convert` **does** refuse `.docx`; the command does not. Workaround:
pass an explicit `format`, and undo the file if it already exists.

### 10. `file.save` lets `format` override the extension
```json
{"command":"file.save","params":{"path":"x.pdf","format":"pdf"}}       → real PDF (format not in the documented enum)
{"command":"file.save","params":{"path":"x.pptx","format":"deckcraft"}}→ deckcraft ZIP named .pptx
```
Validate with `file`/`unzip` or use `save_presentation` (extension only).

## GUI control channel

### 11. `ui.dialog.open` with an unknown id "opens" it
```json
{"tool":"call_app","args":{"method":"ui.dialog.open","params":{"id":"noSuchDialog"}}}
→ null, and ui.inspect now reports "dialog":"noSuchDialog"
```
No visible dialog, but the state is set. Close it with
`ui.dialog.close {"id":"noSuchDialog"}`; otherwise later inspection is confusing.

### 12. `ui.key` Escape/Enter does not dismiss a command-opened dialog
```json
{"command":"insert.dateTime","params":{}}          → dialog "dateTime" opens
{"tool":"call_app","args":{"method":"ui.key","params":{"key":"Escape"}}} → {"handled":true}
ui.inspect                                          → "dialog":"dateTime"   (still open)
{"tool":"call_app","args":{"method":"ui.key","params":{"key":"Enter"}}}  → {"handled":true}
ui.inspect                                          → "dialog":"dateTime"   (still open)
```
Workaround: `ui.dialog.close {"id":"dateTime"}`. Also note that commands still
run while the dialog is open (a `view.slideMaster` command worked "under" it),
so dialogs are not modal for the control channel. Prefer calling commands with
full parameters over driving dialogs.

### 13. `ui.set` ignores an invalid zoom silently
```json
{"tool":"call_app","args":{"method":"ui.set","params":{"zoom":"huge"}}}
→ {"zoom":null}     // canvasScale unchanged
```
Read back `ui.inspect` (`canvasScale`, `ui.zoom`) after `ui.set`.

### 14. Two different pointer coordinate systems
`ui.pointer`/`pointer` take slide points; `ui.click`/`ui.move`/`ui.drag` take
screen points. At zoom 2 the slide rect is larger than the window
(`[-123,-67,1921,1081]`), so a screen-space click can miss the canvas entirely.
Map through `slideRect` from `ui.inspect`, or stay in slide points.

### 15. A drag is not pixel-exact
Drag from (150,160) to (250,210) moved a box from `[100,120]` to `[198,168]`
(a ~2 pt difference). Assert with a tolerance, or use `shape.setBounds` for exact
geometry.

## Semantics that surprise

### 16. `slide.new` inserts after the **current** slide
Not at the end. With `--sample` the current slide is 0, so a new slide is index 1
in a 9-slide deck. Use `"at":N` or `slide.go` first.

### 17. Shape ids are slide-scoped; inspection is too
`shape.inspect {id}` and `format.*` act on the **current slide**; an id from
another slide reports `no shape 262`. `go_to_slide` first. Slide/layout ids are
stable across native save/reload, but change after a `.pptx` import.

### 18. `comment.list` defaults to the current slide
A deck with a comment on slide 1 returns `[]` while slide 0 is current. Pass
`{"slide":1}`.

### 19. Hidden slides disappear from exports
PDF, GIF, `all:true` PNG and the outline skip hidden slides. `includeHidden`
exists only on the PDF/export schema; there is no equivalent for the outline.

### 20. `all:true` PNG ignores your exact filename
`e-all.png` → `e-all1.png`, `e-all2.png`. Base names get a 1-based counter.

### 21. `.md` export is not Markdown
`file.export {path:"outline.md"}` and `.txt` produce identical outline text with
tab-indented levels.

### 22. Negative and off-slide geometry is allowed
`shape.insert … rect:[-20,-30,60,40]` and `[900,500,300,300]` are accepted
without clipping. That is useful for bleeds, but nothing warns you that a shape
is invisible in the show.

### 23. A deck can have zero slides
`slide.delete` on the only slide returns `{"deleted":1,"remaining":0}`, and
`slide.duplicate` then fails with `no slides`. Guard against deleting the last
slide. `inspect_document` on a fresh server (nothing open) errors with
`command document.inspect is not available right now: no presentation open`.

### 24. Negative index error message is misleading
`slide.go {"index":-1}` → `missing \`index\``. The index was present, just
negative. Treat it as "out of range".

## Import / export warnings

### 25. Reopen is the only fidelity report
`open_presentation` returns `lostSlides`, `damagedMedia`, `missingFonts`.
Charts default to **Arial**, so a deck using Inter/Merriweather reports
`missingFonts:["Arial"]` after reopening. Nothing fails; the export may use an
Arial fallback for chart text.

### 26. LibreOffice-produced `.pptx` imports with duplicated layout names
The converted deck showed two layouts named "Title Slide" and layout ids
86/87 instead of 12/18. Do not assume layout ids are portable across producers;
use layout **names** in `slide.layout`/`add_slide` and read `inspect_document`.

### 27. Pre-rename native files are refused
Repo `assets/app-icon/icon-source.deckcraft` is a `slidecraft` file:
`not a DeckCraft file: slidecraft`. No migration command exists in 0.9.0.

### 28. The control server has no authentication
Bound to `127.0.0.1`, no token/key file. Any local process can drive the window,
open files, export and quit. Start it only when needed, on an explicit port,
with an isolated `XDG_CONFIG_HOME` when testing.

## Reporting

When something looks wrong, capture the exact JSON-RPC call, the reply, and a
read-back (`inspect_slide`/`slide.inspect`/`file.info`). A screenshot alone does
not show whether the model or the renderer is at fault.
