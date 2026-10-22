# Bugs, silent successes and workarounds — 0.13.0

Ordered by how likely they are to cost an agent time. Each item lists a minimal
reproduction and what was observed on 2026-10-22.

## 1. `file.findMissing` lies when media is gone

```python
execute_command {"command":"file.import","params":{"paths":["/abs/media/clip_0000.png"]}}
execute_command {"command":"project.select","params":{"items":[1]}}
execute_command {"command":"file.newCompFromSelection","params":{"single":true}}
save_project {"path":"/abs/foot.ecproj"}
# move the whole media/ folder away, reopen, then:
execute_command {"command":"footage.check","params":{"wait":true}}     # {"checked":1,"missing":1,"probed":0}
execute_command {"command":"file.findMissing","params":{"what":"footage"}}  # {"items":[]}
```

Observed twice. Also note: moving **one** frame of a sequence away still reports
`missing:0`; the check only flags a sequence when every frame is unavailable.
Workaround: use `footage.check` and treat a non-zero `missing` as truth; render a
frame to confirm placeholders. `file.findMissing`'s schema/doc is otherwise valid.

Severity: high for relinking/QA workflows.

## 2. `ui.resize` is a no-op on this Wayland session

```python
control {"method":"ui.inspect"}                 # window [1912,1016]
control {"method":"ui.resize","params":{"width":1200,"height":800}}   # null
control {"method":"ui.inspect"}                 # window [1912,1016]
```

Returns null, no error, no resize. Do not size the window for deterministic
screenshots; crop with `ui.screenshot {panel|id}` or accept the live size and
record it from `ui_inspect`.

## 3. Text fields ignore `Ctrl+A` / `Cmd+A`

In the New Composition dialog (and others), sending `Ctrl+A` then `ui_type` appends
or edits at the caret instead of replacing. Verified in the GUI:

```python
control {"method":"ui.menu.invoke","params":{"id":"comp.new"}}
ui_click {"id":"dialog.comp.name","fx":1.0}
ui_key   {"key":"Backspace"}      # repeat for the current name's length
ui_type  {"text":"GUI Verified"}
ui_click {"id":"dialog.comp.ok"}
```

Workaround: click with `fx:1.0` (caret at end), Backspace × length, then type.
Alternatively set the field through the engine and skip the dialog.

## 4. Value coercion in `prop.set` / `set_property`

```python
set_property {"layer":"T","path":"transform/opacity","value":150}   # -> value 100.0
set_property {"layer":"T","path":"transform/opacity","value":true}  # -> value 1.0
```

Both succeed. `150` is clamped to the legal 0–100; `true` becomes `1.0` because the
target is scalar. No warning is returned. Validate ranges and types yourself, and
read the property back after writing.

## 5. Unknown fonts are accepted and silently fall back

```python
layer.setText {"layer":"T","font":"NoSuchFontFamily"}   # -> null
render_frame …                                          # identical to the pre-change render
```

Verified by MD5: the default font and `NoSuchFontFamily` rendered byte-identically;
a real family (`DejaVu Sans`) produced a different hash. There is no error and the
font may still be stored in the project. Check `list_fonts {count:288, families:[…]}`
before setting a family, or compare a rendered frame.

## 6. Keyframes snap to comp frames and silently collapse

```python
add_keyframe {"layer":"Z","path":"transform/opacity",
              "keys":[{"time":i*0.01,"value":i%100} for i in range(500)]}
get_property …   # 151 keys, spaced 1/30 s, last at 5.0
```

Frames at 30 fps → 0.0333 s resolution; 500 keys requested over 0–4.99 s became 151
unique times. This is correct compositing behaviour but is not reported. If you
need N distinct keys, space them at least one frame apart and check the returned
`keys` array.

## 7. Save ignores the extension

```python
save_project {"path":"/abs/notes.txt"}    # -> {"path":"/abs/notes.txt","dirty":false}
```

The file contains `.ecproj` JSON. No warning, no extension check. Always pass
`.ecproj`, and do not use `save_project` to write other formats.

## 8. Render format overrides the requested extension

```sh
effectcraft-cli render p.ecproj --out out.mp4 --format png
# writes out_[#####].png, no out.mp4
effectcraft-cli render p.ecproj --out a.aiff --format aiff
# writes a.aif
```

Sequence formats always append `_[#####]`. Conversely, `render_frame` always writes
PNG no matter what extension you pass. Trust the returned/logged path, not the path
you requested.

## 9. Output-folder creation is inconsistent

- CLI `render --out newdir/a.mp4` **creates** `newdir/` (verified).
- MCP `render_frame {path:"newdir/a.png"}` and `comp.saveFrameAs*` **fail** with
  `cannot write … No such file or directory (os error 2)`.

Create directories first when using MCP or frame saves.

## 10. Relative paths resolve against three different bases

| Call | Base |
|---|---|
| `renderQueue.add {output:"rel/out.mp4"}` | the **project file's folder** |
| CLI `render --out rel/out.mp4` | the **CWD** |
| MCP `render_frame {path:"rel.png"}` | the MCP **server's CWD** |

Mixing them produces the classic `out/out/out.mp4`. Use absolute paths.

## 11. `layer.select` is the one silent reference

```python
layer.select {"layers":["NoSuch"]}   # -> []
prop.set     {"layer":"NoSuch", …}   # -> error: no layer "NoSuch"
```

Docs say a bad reference is “never a silent no-op”; that is true for property,
tree and edit commands, but `layer.select` returns an empty selection. Check the
return value and the selection in `get_state` if selection matters.

## 12. `command_batch` is not atomic and its error is nested JSON

`batch` (alias of the same engine) rolls back all steps on failure and returns
`{steps, results}`. `command_batch` takes `{steps:[{id, params}]}` (different key!),
records one undo step per edit, keeps earlier steps when one fails, and the failure
text contains a JSON string inside the error. Use `batch` for build operations;
use `command_batch` only when you deliberately want partial progress.

## 13. `file.import` silently ignores JSON

```python
file.import {"paths":["/abs/anim.json"]}   # -> null, no item, no error
file.importLottie {"path":"/abs/anim.json"}  # correct: {comp, items, warnings}
```

Use `file.importLottie` for Lottie and `file.import` for media/PSD/PDF/vector.

## 14. Import needs a real project-panel selection

```python
file.newCompFromSelection {"single":true}
# error: not available right now: select an item in the Project panel first
```

`project.select {items:[id]}` returns the selected ids, but `get_project`'s
selection field may be absent/null; the command still works if the ids are valid.
Select immediately before the call.

## 15. Undo is capped

`history` showed 33 states (`index 0…32`) after 40 edits; `undo {steps:32}` is the
practical maximum. History is branch-aware (`branches` count, `goto`), but the
oldest states are dropped. Save milestones instead of relying on deep undo.

## 16. `ui.menu.invoke` returns null even when it opens a dialog

This is normal: it returns the frontend hand-off, not the dialog result. Confirm
via `ui.inspect.dialog` and the resulting project state. Do not treat null as
failure.

## Silent-success cheat sheet

| Looks successful | Actually |
|---|---|
| `save_project` with any extension | writes ecproj JSON |
| `render --format png --out x.mp4` | writes `x_[#####].png` |
| `render --format aiff --out a.aiff` | writes `a.aif` |
| `prop.set` opacity 150 / `true` | clamps to 100 / coerces to 1.0 |
| `layer.setText` with an unknown font | accepted, fallback rendered |
| `file.findMissing` | may return `items: []` despite missing media |
| `ui.resize` | returns null, does not resize |
| `layer.select` with a bad ref | returns `[]` |
| `file.import` a `.json` | returns null, imports nothing |
| `keys.copy` with no selection | returns 0/does nothing |
| Missing frames in a sequence | warning, placeholders, not an error |

## Errors that are genuinely good

- Unknown command: `unknown command "…"` (and `add_keyframe` is an **MCP tool**,
  not an engine command — use `prop.addKey` through `execute_command`).
- Unknown parameter: lists every accepted key.
- Unknown property path: tells you to inspect the children of a group.
- Corrupt project: exact JSON parser position.
- Effect parameter failure: entire apply rolls back; names the bad field.
- Script errors: `file:line:col` with the message and exit 1.
