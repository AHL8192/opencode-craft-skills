# Bugs and workarounds — VectorCraft 0.14.0

Every item below was reproduced on this machine on 2026-10-22. Reproductions use
headless MCP unless stated. "Silent" means the call reports success with no
warning, even when the result is not what was asked for.

## 1. CLI `run --cmd` rejects MCP tool names and aborts on the first failure

```sh
vectorcraft-cli run --cmd file.new \
  --cmd draw_shape --params '{"shape":"rectangle",…}' \
  --export /tmp/out.png
```

```
vectorcraft-cli: draw_shape: unknown command `draw_shape`
```

Exit 1, **no `/tmp/out.png`** — `--export` steps never run. Same for
`doc_inspect`, `command_run`, `command_batch`.

`--cmd` accepts **engine ids** plus the host commands `file.open`, `file.save`
and `file.export` (verified: a run ending in `file.export {path:"x.png"}` exited
0 and wrote the PNG). `document.save`/`document.export` also work.

**Workaround:** use engine ids or the three host commands, or use MCP. Run one
step per invocation while debugging.

## 2. Validation is strict — bad ids, params and types error (not silent)

Re-tested 2026-10-22 with a live 0.14.0 server; all four cases **fail loudly**:

| Call | Result |
|---|---|
| `command_run {id:"definitely.not.a.command"}` | `unknown command \`definitely.not.a.command\`` |
| `command_run {id:""}` | `missing string argument \`id\`` |
| `shape.rectangle {x:0,y:0,widht:10,height:10}` | `unknown parameter \`widht\`; did you mean \`width\`?` |
| `shape.rectangle {x:0,y:0,width:"ten",height:10}` | `missing number \`width\`` |
| `shape.rectangle {…, fill:"#f00"}` | `unknown parameter \`fill\`; the command takes: x, y, width, height, radius, rotation` |
| `paint.setFill {color:"notacolor"}` | `invalid parameters for \`paint\`: bad color "notacolor"` |
| `apply_effect {effect:"bogus.effect"}` | `unknown effect \`bogus.effect\`` |
| `shape.rectangle {x:1e9,…}` | `result would exceed the canvas (coordinates out of range)` |

**Consequence:** do not write retry loops for "the engine may have ignored it" —
if the call returns, the command ran. Still read back for value-level coercion
(see 3–8) and because a successful command can be a no-op on an empty selection.

## 3. Empty and zero-size objects are accepted

```json
{"tool":"add_text","args":{"text":"","x":10,"y":120}}          → {"id":3}  (0 chars, width 0)
{"tool":"add_text","args":{"text":"zero","x":10,"y":240,"size":0}} → {"id":8}
{"id":"shape.rectangle","params":{"x":10,"y":200,"width":0,"height":10}} → {"id":7}
```

No warning; the objects exist and export. **Workaround:** assert the returned
geometry (or `doc_inspect.nodes[].bounds.width > 0`) when building UI-like tools.

## 4. `set_paint` with a nonexistent id reports success

```json
{"tool":"set_paint","args":{"ids":[9999],"fill":"#123456"}}
→ {"applied":{"fill":"#123456"}}
```

No object 9999 exists. The existing rectangle keeps `#ff0000`, the undo history
gains `Fill Color`, and `doc_inspect.paint.fill` becomes `#123456` — the call
applied the paint to the **new-art default**, not to an object. `ids:[]` falls
back to the current selection.

**Workaround:** `select.set {ids}` first (it validates and errors on bad ids),
or read back the targeted nodes.

## 5. Negative stroke width is "applied" as zero

```json
{"tool":"set_paint","args":{"ids":[2],"strokeWidth":-5}}
→ {"applied":{"strokeWidth":-5.0}}
```

`doc_inspect` shows `strokeWidth: 0.0`.

## 6. Export format and extension can disagree silently

```json
{"tool":"export","args":{"path":"…/mismatch.svg","format":"png"}}
→ {"format":"png","bytes":1857,"warnings":[…]}
```

`file` reports **PNG** bytes and `xxd` starts `89 50 4e 47` in `mismatch.svg`.
There is no extension check when `format` is explicit. With `format` omitted the
extension decides correctly.

**Workaround:** derive `format` from the extension, or keep them consistent.

## 7. `export` scale 0 / negative is ignored (1× output)

```json
{"tool":"export","args":{"path":"…/scale0.png","scale":0}}    → success, 400×300
{"tool":"export","args":{"path":"…/scaleneg.png","scale":-2}}  → success, 400×300
```

On a 400×300 document both produce identical 400×300 PNGs — the invalid scale is
coerced to 1, with no warning. **Workaround:** validate `scale > 0`; assert
dimensions with `identify` after export.

## 8. Silent font substitution

```json
{"tool":"add_text","args":{"text":"Hi","font":"NoSuchFont"}} → {"id":4}
```

The unknown family is replaced without a warning at creation time. Export later
warns (`fonts that aren't available were written in the fallback font, Source
Sans 3: NoSuchFont`) and `vectorcraft-cli info` shows
`fonts[].status: "substitute"`. Check with `fc-match NoSuchFont` before relying
on a family.

## 9. `file.export` is invokable but missing from two catalogues

`vectorcraft-cli commands` lists `file.export` ("Export…"); `ui.menu.list` and
`engine.commands` do not. Yet it works:

```json
{"tool":"command_run","args":{"id":"file.export","params":{"path":"…/b.png"}}}
→ {"format":"png","bytes":1857,"path":"…/b.png"}
{"tool":"command_run","args":{"id":"file.export","params":{}}}
→ {"format":"png","dataBase64":"…"}
```

**Workaround:** prefer `document.export` (with a path) or the menu id
`file.exportAs`; treat `engine.commands` as a menu-visible subset, not the whole
invokable surface.

## 10. SVG `<filter>` is dropped during import without a warning

A foreign SVG with `<filter><feGaussianBlur stdDeviation="4"/></filter>` on a
green rect opens with no effects; the rendered pixel at the rect centre is pure
`#00aa00`. The open result warns only about a missing linked image.

**Workaround:** compare a render to the source; re-apply effects with
`apply_effect`.

## 11. GUI state lags synthetic input; Escape does not deselect

Reading immediately after input shows the previous state:

```
ui.click {rect}      ; document.inspect → []          # stale
sleep 0.6            ; document.inspect → [2]         # correct
```

At 4–30 fps the click lands on a later frame. Also:

- `ui.key {key:"Shift"}` → `unknown or missing key`; modifiers are flags.
- `Escape` leaves the selection intact; use `select.none` (⌘⇧A).
- Clicking an object that is already part of a multi-selection keeps the
  selection (useful before dragging, but not Illustrator's reduce-to-one).

**Workaround:** sleep ≥0.5 s before inspecting; poll until the expected state or
a 2 s timeout.

## 12. Native save/export dialogs cannot be completed over the control channel

```
ui.menu.invoke {command:"file.exportAs"}   → dialog {kind:"exportAs", fields:{…}}
ui.dialog.set {field:"path", value:"…/x.png"}
ui.dialog.confirm                            → {"ok":false,"error":"cancelled"}
```

On Linux the OS file chooser is external; the confirm returns `cancelled` and no
file is written. `ui.dialog.cancel` behaves the same as always.

**Workaround:** pass explicit paths to `export`, `save_file`, `document.export`,
`document.save`. Dialog automation works for non-file dialogs (verified with the
`rotate` dialog: angle 30 applied, bounds changed, history gained "Rotate").

## 13. `command_batch` limits and step shape

- More than 256 steps: `\`steps\` holds 2000 steps; at most 256` (clear error).
- `{command, params}` instead of `{id, params}`:
  `completed:0, failed:1, results:[{error:"unknown step argument (expected id, params)"}]`.
- Each batch is fast: 250 rects in 43–269 ms; 2,000 distinct rects across 8
  batches took ~0.9 s of command time (1.96 s including save + PNG export).

## 14. `doc_inspect.objects` is a row count

An **empty** document reports `objects: 1` (the layer). One rectangle →
`objects: 2`. Use `total` (filtered count) or `nodes.length`.

## 15. `open_file` returns no path

```json
{"format":"vectorcraft","index":2,"title":"idtest.vectorcraft","warnings":[]}
```

No `path` field, so you cannot confirm which file was opened from the result.
Use the title or `document.inspect` (`path` is present there in app mode).

## 16. PDF export of a single artboard drops editing data with a warning

```
export {path:"only2.pdf", format:"pdf", artboard:1}
→ warnings: ["Preserve editing was left out: it needs a PDF of every artboard, in order …"]
```

Use `range:"1-2"` (or omit `artboard`) when the PDF must round-trip through
VectorCraft. EPS and `.ai` do not have this limitation.

## 17. `scale` sign is ignored by `transform`

`{"tool":"transform","args":{"ids":[2],"scale":-50}}` half-sized the rectangle
(`applied:["scale"]`) instead of reflecting it; use `reflect` for mirrors.

## 18. `open_file` on an empty native file vs empty SVG

Empty `.vectorcraft` → `not a VectorCraft file: EOF while parsing a value…`.
Empty/truncated `.svg` → `SVG parse error: unexpected end of stream`.
Both fail cleanly; neither leaves a partial document.
