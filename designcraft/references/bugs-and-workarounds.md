# Bugs, silent successes and docs drift — DesignCraft 0.10.0

All reproductions below were run on 2026-10-22 against
`designcraft 0.10.0` / `designcraft-cli 0.10.0` (`designcraft 0.10.0-1`).
Raw results live in `/tmp/opencode/skill-tests/designcraft/dc-20261022-001/artifacts/`.

Severity: **H** breaks trust in results, **M** surprising but recoverable,
**L** cosmetic/documentation.

---

## 1. H — Nonexistent object ids report success and change nothing

```json
new_document {"preset":"A4","pages":1}
execute {"command":"object.fill","params":{"swatch":"[Black]","ids":[9999]}}
→ {"changed": 1}
execute {"command":"object.rename","params":{"id":9999,"name":"Ghost"}}
→ {"changed": 1}
execute {"command":"edit.clear","params":{"ids":[9999]}}
→ {"deleted": 1}
```

`inspect_document` shows no objects before or after. **Workaround:** take ids from
`inspect_document`/`frame.create` and verify the object exists before mutating;
never use the returned counts as evidence.

## 2. H — Inverted or degenerate rects create a 0.5×0.5 pt sliver

```json
execute {"command":"frame.create","params":{"rect":[110,60,10,20],"content":"graphic"}}
→ {"id":8}   bounds: [110.0, 60.0, 110.5, 60.5]
execute {"command":"frame.create","params":{"rect":[10,60,110,20],"content":"graphic"}}
→ bounds: [10.0, 60.0, 110.0, 60.5]
```

The app neither normalizes nor rejects. **Workaround:** sort x and y before
sending (`x0=min(x0,x1)` etc.); reject zero-area rects in your client.

## 3. H — Invalid enum/type values are silently ignored or coerced

| Input | Actual | Result |
|---|---|---|
| `frame.create {content:"txt"}` | rectangle (graphic) | no error, no `story` |
| `frame.create {content:"text", shape:"hexagon"}` | shape ignored, text frame created | no error |
| `object.stroke {weight:"thick"}` | weight unchanged (5.0) | `{"changed":1}` |
| `type.char {attrs:{size:"big"}}` | size unchanged | success |
| `object.stroke {align:"sideways"}` | accepted | `{"changed":1}` |
| `object.opacity {opacity:2.5}` / `-1` | accepted (not inspectable) | `{"changed":1}` |
| `new_document {pages:"three"}` / `{pages:0}` | 1 page | success |
| `object.arrange {to:"sideways"}` | no visible change | `null` (also for valid values) |
| `text.select {anchor:99, focus:120}` on an 6-byte story | accepted | `null` |

**Workaround:** validate enums and ranges yourself; read back the property
(`object.inspect` is limited, so use `type.selectionAttrs` for text and
`inspect_document.spreads[].items[]` for fills/strokes/weights).

## 4. M — `layout.pages.delete` ignores out-of-range indices

```json
new_document {"preset":"A4","pages":2}
execute {"command":"layout.pages.delete","params":{"pages":[99]}}   → null
execute {"command":"layout.pages.delete","params":{"pages":[-1]}}   → null
inspect_document.pageCount                                           → 2 (unchanged)
```

**Workaround:** check `pageCount` before and after; treat a delete as successful
only if the count dropped.

## 5. H — `ui.menu.invoke` silently does nothing for `ui:*` menu ids

```json
{"id":1,"method":"ui.menu.invoke","params":{"command":"ui:view.fitPage"}}
→ {"ok":true,"result":{"dialog":null}}      # zoom unchanged
{"id":2,"method":"ui.menu.invoke","params":{"command":"ui:app.preferences"}}
→ {"ok":true,"result":{"dialog":null}}      # no dialog, no panel
{"id":3,"method":"ui.menu.invoke","params":{"command":"ui:help.about"}}
→ {"ok":true,"result":{"dialog":null}}      # ui.about stays false
```

Panel and screen-mode `ui:*` items behave the same. **Workaround:** use `ui_set`
for panels/zoom/screen mode, `click` on the real menu coordinates for UI-only
dialogs, and `cmd:*` ids for engine commands (`cmd:layout.documentSetup` opens its
dialog correctly).

## 6. M — `engine.execute` cannot open parameter dialogs

`execute {"command":"layout.documentSetup","params":{}}` applies the current setup
and returns it; no dialog opens, so `dialog_confirm` fails with `no dialog open`.
Opening requires the control method
`ui.menu.invoke {"command":"layout.documentSetup"}`. This is a design limit rather
than a bug, but it is not obvious from the MCP tool list.

## 7. M — `dialog_set` accepts unknown fields and unparseable values

```
dialog_set {"field":"width","value":"wide"}        → fields.width = "wide"
dialog_set {"field":"nosuchfield","value":"1 mm"}  → fields.nosuchfield = "1 mm"
dialog_confirm {}                                  → error: width: not a measure
```

The bad field persists in the dialog and the dialog stays open. **Workaround:**
only set fields listed by `ui_inspect.dialog.fields`; validate measures client-side
(`/^\d+(\.\d+)?\s*(pt|mm|cm|in|pica|px)?$/`); cancel after a failed confirm.

## 8. M — Export does not validate the extension; save appends instead of replacing

```json
execute {"command":"file.exportPdf","params":{"path":"x.docx"}}
→ {"path":"x.docx","bytes":14407}      # begins with %PDF
execute {"command":"file.save","params":{"path":"weird.pdf"}}
→ {"path":"weird.pdf.designcraft"}     # .designcraft appended
```

**Workaround:** enforce the extension you expect and confirm with
`file`/`pdfinfo`/`unzip -l`.

## 9. M — Tables can only be read by `story` while the caret is inside; after reopen use the table id

```json
execute {"command":"table.get","params":{"story":9}}
→ error: place the insertion point in a table
execute {"command":"table.get","params":{"table":10}}   # works after reopen
```

Selections/carets are not restored on reopen. **Workaround:** capture the table id
from `table.insert` (`{story, table}`) and persist it in your script; address
`table.get`/`table.select` by `table`.

## 10. L — `overset` has two types

`inspect_document.stories[].overset` is `false` when nothing is hidden (or a byte
offset), while `get_story.overset` is `null` (or a byte offset). Normalize:
`bool(v) if v is not None else False`.

## 11. L — `inspect_document` has no top-level `pages`

The docs describe "pages (index, name, bounds, margins, columns)" and "spreads with
items"; in 0.10.0 pages are nested at `spreads[].pages[]`. Use
`sum(len(s["pages"]) for s in spreads)` and `pageCount` for totals.

## 12. L — `--help` launches the GUI

```sh
$ designcraft --help
# opens the window; stderr: WARN designcraft: --help: No such file or directory
```

Use `designcraft --version`; use `designcraft-cli --help` for CLI usage.

## 13. L — `ui_set {"zoom": 100}` clamps to 40

`zoom` is a factor (`1.0` = 100%). Passing 100 produced `view.zoom = 40.0` (the
maximum). Use `{"zoom":1.0}` or `{"fit":"page"}`.

## 14. L — `find.find` ignores `change`

Documented in its own params (`change?|first?|attrs?: ignored (find.change takes
them)`), so this is intended, but easy to miss: `find.find {find, change}` returns
matches and changes nothing. Use `find.change {find, change}` → `{count}`.

## 15. L — `ui_set {"panel":"layers"}` reported no change

`openPanel` stayed `null` for `layers` while `textWrap` reported correctly. The
Layers panel is likely part of an already-visible dock. Verify panels visually
(`screenshot`) rather than trusting `openPanel` for every id.

---

## Docs-versus-binary drift

| Documented claim | Actual 0.10.0 | Evidence |
|---|---|---|
| `docs/agents.md`: "Most commands ignore parameters they don't know instead of rejecting them" | Engine/MCP/control **reject** unknown or wrong-case parameters with a did-you-mean | `frame.create {bogusParam:true}` → `-32602 unknown parameter` |
| README: every menu item "can be driven over a JSON control channel" | `ui:*` menu items return success and do nothing; only `cmd:*` work | bug 5 above |
| `docs/control-protocol.md`: `ui.menu.invoke` without params opens the command's dialog | True for `cmd:*` (`layout.documentSetup`), not for `ui:*` | bug 5/6 |
| `inspect_document` description mentions top-level pages | Pages are nested under spreads | bug 11 |
| README/docs imply a single command count | 521 headless, 685 in the app (164 UI-only) | `commands` vs `engine.commands` |
| `docs/mcp.md` (26 tools, protocol 2025-06-18) | Verified exactly | `tools/list` |
| README download/formats list | `.designcraft`, IDML in/out, INDD in, PDF/PNG/EPUB/PPTX out all verified; INDD not tested | export matrix |
