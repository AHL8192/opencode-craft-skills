# Recipes that were run against 0.13.0

Every recipe below was executed on this machine (headless unless stated). Paths are
examples; use absolute paths for anything the MCP server writes.

## 1. Title card with animation, effect, and a frame render

```python
execute_command {"command":"comp.new","params":{"name":"Intro","width":1920,"height":1080,
                 "frameRate":30,"duration":4}}
execute_command {"command":"layer.newText","params":{"name":"Title","text":"EffectCraft",
                 "size":160,"fill":"#ffcc00"}}
add_keyframe {"layer":"Title","path":"transform/position",
              "keys":[{"time":0,"value":[-400,540]},{"time":1.2,"value":[960,540]}],
              "interpolation":"easyEase"}
add_effect {"layer":"Title","effect":"Gaussian Blur","values":{"blurriness":6}}
set_property {"layer":"Title","path":"transform/opacity",
              "expression":"linear(time,0,0.8,0,100)"}
render_frame {"time":1.2,"max_side":960,"path":"/abs/renders/title.png"}
save_project {"path":"/abs/intro.ecproj"}
```

Verified: text created, two keys at the requested times, effect applied, expression
stored (`expression` non-null, `evaluated` computed), PNG written, project reloads
with the same layer id and keys. `render_frame` needs the parent folder to exist.

## 2. Build atomically with `batch` and result references

```json
{"tool":"batch","label":"Build lower third","steps":[
  {"command":"comp.new","params":{"name":"Lower","width":1280,"height":720,"duration":3}},
  {"command":"layer.newShape","params":{"kind":"rounded","name":"Bar","size":[900,120],
   "fill":"#1b1f2a","position":[640,600]}},
  {"command":"layer.newText","params":{"name":"Name","text":"Ada Lovelace","size":52,
   "fill":"#ffffff","position":[640,600]}},
  {"command":"prop.addKey","params":{"layer":"$4.layer","path":"transform/opacity",
   "time":0,"value":0}},
  {"command":"prop.addKey","params":{"layer":"$4.layer","path":"transform/opacity",
   "time":0.6,"value":100}}
]}
```

`$N` is the Nth step's result; `$N.layer`, `$N.comp`, `$N.path` work. `batch`
returns `{steps, results}` and is **atomic** (`atomic` defaults true). Verified with
four steps: results `[{"comp":1},{"layer":2},1,2]`, both keys present afterwards.
`command_batch` is the non-atomic alias with a different step shape
(`{id, params}`): it keeps earlier steps when one fails.

## 3. Reuse animation with the keyframe clipboard

```python
execute_command {"command":"keys.select","params":{"keys":[
  {"layer":"Title","path":"transform/opacity","time":0},
  {"layer":"Title","path":"transform/opacity","time":1}]}}
execute_command {"command":"keys.copy","params":{}}
execute_command {"command":"time.set","params":{"time":2}}
execute_command {"command":"keys.paste","params":{}}
```

Verified: copy returned 2, paste returned 2, and the property then held four keys
at 0, 1, 2, 3 s with values 0, 100, 0, 100 — i.e. **paste offsets the copied
block to the CTI**. Select keys first; an empty selection copies nothing.

## 4. Image sequence → composition → movie

```python
execute_command {"command":"file.import","params":{"paths":["/abs/plate/plate_0000.png"]}}
execute_command {"command":"project.select","params":{"items":[1]}}
execute_command {"command":"file.newCompFromSelection","params":{"single":true}}
execute_command {"command":"renderQueue.add","params":{"comp":"plate_[0000-0002]",
                 "format":"h264","output":"/abs/renders/plate.mp4"}}
execute_command {"command":"renderQueue.render","params":{"wait":true}}
```

Verified: one numbered still imported the whole run as an `Image Sequence` item
named `clip_[0000-0002].png`; `newCompFromSelection` returned a comp containing a
footage layer; duration was frames/fps (3 frames at 30 fps → 0.1 s). The render
queue wrote an MP4 and returned `{failed:0, items:[…status:"Done"]}`.

Pass `sequence:false` when you actually want one still (`still.png` imported as
type `Image`). A missing file does not throw — it appears in `errors`/`warnings`
of the import result.

## 5. Precompose and a track matte

```python
execute_command {"command":"layer.newText","params":{"name":"Title","text":"MATTE",
                 "size":90}}
execute_command {"command":"layer.newSolid","params":{"name":"Matte","color":"#ffffff",
                 "width":1920,"height":1080}}
execute_command {"command":"layer.setTrackMatte","params":{"layer":"Title",
                 "matte":"Matte","kind":"alpha"}}
execute_command {"command":"layer.precompose","params":{"layers":["Title","Matte"],
                 "name":"Title Precomp"}}
```

Verified: `setTrackMatte` returned null and `get_comp` then reported
`trackMatte: {"kind":"Alpha Matte","layer":<matte id>}`; `layer.precompose`
returned `{comp:138, layer:139}`, created comp 138 containing both layers (matte
above, Title below with the matte attached), and replaced them in the parent with
one comp layer. There is no `layer.newPrecomp`.

## 6. Mask, feather, layer style, text animator

```python
execute_command {"command":"layer.newSolid","params":{"name":"BG","color":"#101820",
                 "width":1920,"height":1080}}
execute_command {"command":"layer.addMask","params":{"layer":"BG","shape":"ellipse",
                 "rect":[240,140,1440,800]}}
execute_command {"command":"layer.mask.set","params":{"layer":"BG","mask":1,
                 "field":"feather","value":20}}
execute_command {"command":"layer.style.add","params":{"style":"dropShadow",
                 "layers":["Title"]}}
execute_command {"command":"layer.addTextAnimator","params":{"layer":"Title",
                 "properties":["opacity","position"]}}
```

Verified returns: mask id, `{masks:1}` after the feather, a style uid, and an
animator uid. Mask rects are **layer space**; for a comp-sized solid that is the
same as comp space.

## 7. Expression-driven motion

```python
set_property {"layer":"Title","path":"transform/rotation","expression":"time*20"}
get_property {"layer":"Title","path":"transform/rotation","time":2}  # comp seconds
```

Verified: `expression` is stored verbatim; `evaluated` is 0 at t=0 and reflects the
expression at later times. Setting `expression:""` removes it. A syntax error is
kept but disabled and surfaced in `expressionError`; the static `value` still
renders. Per-property scoping: expressions see `time`, `value`, and other layer
properties as in After Effects, but not every AE global is implemented — verify
with `get_property.evaluated`.

## 8. Multi-comp batch render

```python
execute_command {"command":"renderQueue.add","params":{"comp":"Intro","format":"h264",
                 "output":"/abs/renders/intro.mp4","start":0,"end":4,"quality":80}}
execute_command {"command":"renderQueue.add","params":{"comp":"Lower","format":"prores",
                 "output":"/abs/renders/lower.mov","proresProfile":"422hq"}}
execute_command {"command":"renderQueue.render","params":{"wait":true}}
```

Verified with H.264: `add` queued with `frames:30` for a 1 s/30 fps comp and
`render` returned per-item `status:"Done"`, `render_time`, and `last_output`.
Output paths are resolved when the item is added; relative paths are relative to
the **project file's folder**. Prefer absolute paths.

## 9. Export and re-import Lottie

```python
execute_command {"command":"file.exportLottie","params":{"comp":"R",
                 "path":"/abs/out/recipe.json"}}
execute_command {"command":"file.importLottie","params":{"path":"/abs/out/recipe.json"}}
```

Verified export result includes `bytes`, `path`, and a `warnings` array naming what
was dropped (expressions without `includeExpressions`, layer styles, mask feather
semantics). Import returned `{comp, items:[…], warnings:[]}` and recreated a comp
with the right fps/duration and shape/text/solid layers. Import creates **new**
item ids; it does not overwrite the source comp.

## 10. Frame exports for compositing

```python
execute_command {"command":"comp.saveFrameAs","params":{"path":"/abs/out/frame.png",
                 "time":1,"scale":1}}
execute_command {"command":"comp.saveFrameAsExr","params":{"path":"/abs/out/frame.exr",
                 "comp":"R","time":1}}
execute_command {"command":"comp.saveFrameAsPsd","params":{"path":"/abs/out/frame.psd",
                 "comp":"R","time":1}}
execute_command {"command":"file.saveCopyAsXml","params":{"path":"/abs/out/copy.ecprojx"}}
```

Verified: multi-layer EXR (`<layer>.R/G/B/A` channels + composite) and layered PSD
(one layer per visible comp layer + merged frame) are written; EXR is 16-bit half
by default in this build. XML copy is a project copy, not an interchange format.

## 11. Drive the real GUI (bridged)

```python
ui_inspect {}                                    # window [1912,1004], dialog null
control {"method":"engine.execute","params":{"command":"comp.new",
         "params":{"name":"Agent GUI","width":960,"height":540,"duration":3}}}
execute_command {"command":"layer.newText","params":{"text":"EffectCraft","size":96}}
screenshot {"path":"/abs/shots/window.png"}
ui_menu = control {"method":"ui.menu.invoke","params":{"id":"comp.new"}}
ui_inspect {}                                    # dialog == "NewComp"
ui_click {"id":"dialog.comp.name","fx":1.0}
ui_key {"key":"Backspace"}                       # × length of the current name
ui_type {"text":"GUI Verified"}
ui_click {"id":"dialog.comp.ok"}
ui_playback = control {"method":"ui.playback","params":{"action":"play"}}
control {"method":"ui.playback","params":{"action":"status"}}
control {"method":"ui.playback","params":{"action":"stop"}}
```

Verified: the dialog opened and confirmed, the rename landed (`GUI Verified`
appeared in the project), playback advanced to ~0.7 s, screenshots were real
1912×1004 PNGs, and `viewer.locate/hit` round-tripped comp (480,270) exactly.
Text replacement needs the Backspace trick; `Ctrl+A` does not select the field.
