# EffectCraft commands — 0.13.0

Snapshot: 2026-10-22, `effectcraft-cli commands --json` → **731 commands in 55
namespaces**. Live schema is the only truth:

```sh
effectcraft-cli commands --json                    # id, label, menu, shortcut, enabled
effectcraft-cli exec --list --schemas --json       # + params and JSON Schema
```

MCP equivalents: `list_commands {filter?, enabledOnly?}`,
`describe_command {command}` → `{id,label,menu,shortcut,params,schema,enabled,why,undoable}`,
`execute_command {command, params?}`.

## How a command behaves

- Params are a strict contract: **unknown keys are rejected** with the accepted
  list; absent keys take defaults. This makes typos loud — use it.
- Results are command-specific objects (`{"comp":1}`, `{"layer":2}`,
  `{"comps":[…]}`) or `null`. Query commands (`project.summary`, `get_*`) are not
  journaled.
- `undoable: true` means one history step. A set to the same value records
  nothing. `batch` = one step, atomic; `command_batch` = one step per sub-command
  and stops at the first error, keeping earlier ones.
- `enabled:false` + `why` is the context rule (e.g. layer commands need an open
  comp; `file.newCompFromSelection` needs a project-panel selection).
- Every id also works through `effectcraft-cli exec ID --params JSON` and the
  control channel's `engine.execute`.

## Namespaces

| Namespace | # | Covers |
|---|---|---|
| `layer` | 121 | create text/solid/shape/null/adjustment/camera/light/3D/model, masks, styles, text animators, parenting, timing, precompose, track matte |
| `view` | 78 | zoom, resolution, guides, grids, channels, viewers, overlays |
| `file` | 61 | new/open/save/import/export, Lottie, XML, project settings, recent |
| `keys` | 36 | select, copy/paste, nudge, interpolation, easing, hold, reverse, labels |
| `comp` | 31 | new, settings, duplicate, open, close, frame saves (PNG/EXR/PSD) |
| `edit` | 27 | undo/redo/history, clear, duplicate, cut/copy/paste, split, purge |
| `track` | 22 | motion tracking / stabilization (models not exercised) |
| `essential` | 22 | Essential Graphics templates |
| `renderQueue` | 20 | add/remove/duplicate items, settings, output modules, render |
| `camera` | 19 | camera create/orbit/dolly/focus/DOF |
| `effect` | 19 | apply/remove/move/reorder/enable, presets |
| `prop` | 18 | set value, keyframes, expression, reset, dimensions, separate |
| `mask` | 17 | new, shape, mode, feather, opacity, expansion, tracks |
| `time` | 17 | set time/frame/timecode, shift, work area |
| `roto` | 14 | Roto Brush (model downloads; untested) |
| `text` | 13 | insert, style, paragraph, animators |
| `project` | 13 | select, summary, search, folders, item settings |
| `app` | 12 | preferences, quit, about, links |
| `footage` | 12 | import/probe/check/reload/replace, interpretation |
| `puppet` | 10 | pins and starch (untested) |
| `anim` | 9 | presets, keyframe assistants |
| `shape` | 8 | shape primitives and boolean ops |
| `shortcuts` | 7 | shortcut editor/export |
| `path` | 6 | roto/vector path operations |
| `paint` | 6 | brush, eraser, clone |
| `face` | 5 | face tracking (models; untested) |
| `markers` | 5 | comp/layer markers |
| `objectMatte` | 5 | object matte (models; untested) |
| `prefs` / `learn` / `templates` | 5 each | settings, tutorials, templates |
| `render` (4), `material` (4), `script` (4), `light` (3), `paths` (3), `warp` (3), `jobs` (3), `storage` (3), `command` (2), `liquify` (2), `expr` (2), `contentFill` (2) | | helpers, render engine, materials, scripts, lights, warps, background jobs |
| `cache`, `motion`, `editor`, `engine`, `effects`, `item`, `scopes` | 1 each | assorted |

Full id list with labels/shortcuts: `command-index.txt`.

## Core commands and params (verified)

### Compositions and project

```text
comp.new {name?, width?, height?, frameRate?, duration? s, startTime? | startTimecode?,
          background? [r,g,b]|#hex, pixelAspect?, shutterAngle?, motionBlurSamples?,
          adaptiveSampleLimit? 16–256, preserveFrameRate?, preserveResolution?,
          renderer? classic3D|advanced3D, anchor?, open?}          -> {comp}
comp.settings / comp.duplicate / comp.open {comp} / comp.close
project.summary {}                    -> {items:[{id,name,type,...}], ...}
project.select {items:[id|name], add?}-> [ids]
file.newCompFromSelection {duration?, single?, dimensionsFrom?, sequence?, overlap?,
          transition? off|dissolveFront|crossDissolve, addToRenderQueue?} -> {comps}
```

Defaults for `comp.new {}`: 1920×1080, 29.97 fps, duration 10.01 s.

### Layers

```text
layer.newText {text?, name?, position?, box? [x,y,w,h], vertical?, font?, style?, size?,
   fill?, stroke?, applyFill?, applyStroke?, strokeWidth?, tracking?, leading?,
   baselineShift?, hScale?, vScale?, fauxBold?, fauxItalic?, allCaps?, smallCaps?,
   justify?, indent*, spaceBefore?, spaceAfter?, direction?, composer?, …}  -> {layer}
layer.newSolid {name?, color?, width?, height?, pixelAspect?}
layer.newShape {kind? rect|rounded|ellipse|star|polygon|none, name?, size?, fill?,
   fillType?, fillOpacity?, stroke?, strokeType?, strokeOpacity?, strokeWidth?, position?}
layer.newNull {} / layer.newAdjustment {} / layer.newCamera {…} / layer.newLight {…}
layer.addShapeItem {layer?, kind: group|rect|ellipse|star|polygon|path|fill|stroke|
   gfill|gstroke|trim|repeater|round|offset|pucker|twist|zigzag|wiggle|merge|
   frontColor|bevelColor|sideColor|backColor, group?}  -> {uid, path}
layer.setText {layer?, range? [start,end], text?, font?, size?, fill?, stroke?,
   tracking?, leading?, baselineShift?, justify?, box?, vertical?, …}
text.insert {layer?, text, range?, merge?}
layer.rename {layer?, name}      layer.arrange {layers?, to: front|forward|backward|back, index?, above?}
layer.timing {layers?, op? moveInToTime|moveOutToTime|moveInToStart|moveOutToEnd|
   trimInToTime|trimOutToTime, delta?, start?, in?, out?, inDelta?, outDelta?, merge?}
layer.precompose {layers?, name?, mode? move|leave, adjustDuration?, open?}   -> {comp, layers?}
layer.setTrackMatte {layer?, matte: layer|null, kind? alpha|alphaInverted|luma|lumaInverted}
layer.setBlendMode {layers?, mode?, step? ±1}
layer.addTextAnimator {layer?, properties:[position|scale|rotation|opacity|tracking|blur|fillColor|…], name?}
layer.style.add {style: dropShadow|innerShadow|outerGlow|innerGlow|bevelEmboss|satin|
   colorOverlay|gradientOverlay|stroke, layers?}
edit.clear {layers?}          # Delete — there is NO layer.delete
edit.duplicate {layers?}      # Cmd+D
```

### Properties, keyframes, expressions

```text
prop.set {layer?, path|prop, value, time?, timeBase? layer|comp, merge?,
          selected?, offset?, proportional?, dims?}
prop.addKey {layer?, path|prop, time?, timeBase?, value?}
prop.setExpression {layer?, path|prop?, expression?, enabled?}
prop.reset {layer?, path|prop, default?}          # removes expression, sets value
keys.select {keys:[{layer, prop: uid|path, time?}], timeBase?, add?, toggle?, selectProperties?}
keys.set {layer?, path|prop, time, newTime?, timeBase?, value?, merge?}
keys.copy {}            keys.paste {layers?, prop?|path?, time?}
keys.interpolation {…}  keys.easyEase / easyEaseIn / easyEaseOut / smooth / toggleHold
keys.delete {}          keys.selectAll {}          keys.nudge* / move / timeReverse
```

`keys.copy` copies the **selected keyframes** and refuses silently if none are
selected; select first with `keys.select` or by clicking. `keys.paste` needs a
`time` on the target property (or selection) — pasting at the CTI works.

### Effects, masks, paint

```text
effect.apply {effect: id|name, layers?}      effect.remove {layer?, effect: index|uid|name}
effect.enable / effect.move / effect.reorder / effect.preset.*
```

The **engine** `effect.apply` takes no values; set parameters afterwards with
`prop.set {path:"effects/#1/blurriness"}` / CLI `set`. The MCP `add_effect`
tool is a convenience wrapper that accepts `values` and applies them in one call.
layer.addMask {layer?, shape? rect|ellipse|rounded|polygon|star, rect? [x,y,w,h] layer space, mode?}
layer.mask.set {layer?, mask?, field: feather|opacity|expansion, value}
mask.* (17)  — shape, mode, track, invert, lock, delete
paint.* (6)  — brush, eraser, clone (not exercised)
```

Applying an effect with a bogus value rolls back cleanly and names the bad field.

### Render queue and frame saves

```text
renderQueue.add {comp?, template?, format? h264|hevc|av1|prores|uncompressed|webm|
   png|jpeg|tiff|exr|gif|wav|aiff, output?, log?, quality?, resolution? full|half|third|
   quarter|scale, timeSpan? workArea|comp|custom, start?, end?, duration?, frameRate?,
   channels? rgb|rgba|alpha, color?, bitrate?, proresProfile?, audio?, sampleRate?, …}
renderQueue.render {wait? true}              -> written files / job
renderQueue.showQueue / clear / remove / itemSettings / outputModule / …
comp.saveFrameAs {path .png, time?, scale?, queue?}
comp.saveFrameAsExr {path .exr, comp?, time?, scale?}   # multi-layer EXR
comp.saveFrameAsPsd {path .psd, comp?, time?, scale?}   # one layer per comp layer
file.exportLottie {comp?, path .json|.lottie, includeExpressions?, textAsShapes?}
file.importLottie {path .json|.lottie}                  -> {comp, items, warnings}
file.saveCopyAsXml {path .ecprojx}
file.import {paths, sequence?, alphabetical?, frameRate?, importAs?, layer?, page?, drag?,
             addToComp?, time?, index?, position?, background?}
file.findMissing {what: footage|effects|fonts}          # unreliable — see bugs
footage.check {wait?}                                   # authoritative missing-media check
```

## Discovering by intent

```sh
effectcraft-cli commands --filter "text" --json
effectcraft-cli commands --filter "matte" --json
```

`list_commands` also accepts `enabledOnly:true`, which is the quickest way to see
what is legal in the current context. The catalog includes UI-only families
(`view.*`, `window.*`, `playback.*`, `timeline.*`) that fall through to the menu
dispatcher under `engine.execute`; through MCP prefer `ui_*` tools for those.
