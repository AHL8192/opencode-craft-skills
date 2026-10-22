# PhotoCraft command reference

918 commands in 36 namespaces, all reachable by id through the CLI, MCP
(`command_run` / `command_batch`) and the control channel (`engine.execute`).
`photocraft-cli commands --json` has the authoritative list; each entry carries
`id`, `label`, `menu`, `shortcut`, `enabled`, `disabledReason`, `needsDocument`
and a human-readable `params` string (not a JSON schema).

## Namespaces (0.11.1)

| Namespace | # | What lives there |
|---|---:|---|
| `layer` | 215 | create/duplicate/delete/arrange, masks, vector masks, styles, smart objects/filters, alignment |
| `filter` | 124 | blur, sharpen, noise, distort, stylize, pixelate, render, gallery, liquify, camera raw |
| `edit` | 79 | fill, stroke, transform, clipboard, purge, preferences entry points |
| `image` | 66 | size/canvas/trim/rotate, mode, depth, adjustments, analysis |
| `type` | 66 | create/edit/style, warps, on-path, styles, font resolution |
| `file` | 58 | new, open/place, export (layers, artboards, presets, Save for Web), import |
| `select` | 35 | marquees, lasso, wand, subject/object/sky, modify, save/load, quick mask |
| `view` | 31 | guides, proofing, gamut warning, samplers, slices, layer-mask view |
| `paint` | 26 | stroke, pencil, eraser, gradient, bucket, clone, healing, dodge/burn |
| `channel` | 22 | new/duplicate/delete/rename/target/visibility, split/merge, spot |
| `path` | 21 | list/set/delete, selection, fill/stroke, anchors, clipping path |
| `actions`, `brush`, `layerComp`, `gradient`, `swatches`, `document`, `pattern`, `tools`, `shape`, `history`, `count`, `slice`, `timeline`, `style`, `tool`, `cloneSource`, `plugin`, `notes`, `prefs`, `measurementLog`, `jobs`, `session`, `command`, `color`, `variables` | 1–18 each | everything else |

`session.inspect` and `command` are the only odd ones out; treat unknown ids as
typos and read the error — it names the command and usually the bad key.

## Conventions

- Ids are `namespace.action` (`layer.newAdjustmentLayer.curves`).
- **One command = one history step.** `command_batch` still produces one step per
  command.
- Params are a JSON **object**. Arrays, strings, numbers or booleans are rejected
  with "params must be a JSON object".
- Unknown **keys** are usually ignored (see `bugs-and-workarounds.md`), unknown
  **values** are usually rejected with a useful message.
- `layer.new.layer` `opacity` is 0–1. Blend/style parameters (`blendingOptions`,
  `layerStyle.*`, `fill`) are 0–100. `doc_inspect` always reports 0–1.
- Colours: `"#rrggbb"` or `"rrggbb"`; `[r,g,b]` 0–1 also works for fills. Invalid
  colours are **not** reliably rejected by `edit.fill`.
- `layer` params take a numeric id **or a name**; duplicated names need
  `occurrence` (0-based). `layers` takes an array of ids.

## Files, documents, export

| Id | Params (abridged) |
|---|---|
| `file.new` | `{width:1..300000=1920, height=1080, mode:"rgb\|gray\|cmyk\|lab"=rgb, depth:8\|16\|32=8, background:"white\|black\|backgroundColor\|transparent\|#rrggbb", resolution=72, name}` |
| `file.openAs` | `{path, as:"psd\|png\|jpg\|tiff\|…"}` — force a decoder |
| `file.placeEmbedded` / `file.placeLinked` | `{path, scale?, fit?, center?, smartObject?}` |
| `file.saveACopy` | `{path, quality:0..12?, layers:true, overwrite:false, tiffLayers:false, tgaBits, dpxBits}` |
| `file.revert` | `{}` (reloads the saved file as one undoable step) |
| `file.close` / `file.closeAll` / `file.closeOthers` | `{document?}` |
| `file.export.layersToFiles` | `{dir, format:"png"=default, prefix, visibleOnly=true, quality, tiffLayers}` |
| `file.export.artboardsToFiles` | `{dir, format, prefix, artboards:[id]?, quality}` |
| `file.export.artboardsToPdf` | `{path, artboards?, quality:0..12}` |
| `file.export.quickExport` | `{path?}` → `{path, format, bytes, warnings}` |
| `file.export.saveForWebLegacy` | `{preset?, format:"png24"=default, palette, colors, quality, …}` |
| `file.export.presets.save` | `{name, settings:{format, quality, scale, width, height, metadata, profile}}` |
| `image.duplicate` | `{name, mergedOnly}` |
| `image.imageSize` | `{width, height, percent, resolution, keepPrintSize, resample}` → `{width,height}` |
| `image.canvasSize` | `{width, height, relative, anchor, extensionColor}` |
| `image.trim` | `{basedOn:"transparent\|topLeft\|bottomRight", top, bottom, left, right}` |
| `image.revealAll` | `{}` |
| `image.mode.rgb/gray/cmyk/lab` | `{profile, intent, bpc}` (converts) |
| `image.mode.bits8/16/32` | `{}` |
| `image.imageRotation.90cw/90ccw/180` | `{}` |
| `image.imageRotation.flipCanvasHorizontal/Vertical` | `{}` |

Commands in this table that take a raw **path** (`file.saveACopy`,
`file.export.*`, `file.placeEmbedded`/`placeLinked`,
`layer.smartObjects.replaceContents`/`exportContents`) work in the GUI and the
CLI but are **refused under MCP automation** with `… uses ambient filesystem
paths and is disabled; use capability-scoped document methods`. Use `doc_save`,
`doc_export`, `doc_export_layers`, `doc_place`, or the CLI for those.

**Saving is not an engine command.** Use MCP `doc_save`/`doc_export`, `serve`
`doc.save`, or the CLI `--out const`. `file.save` and `file.saveAs` do **not**
exist.

## Layers

| Id | Notes |
|---|---|
| `layer.new.layer` | `{name?, clipToPrevious?, color?}` → `{layer:id}` |
| `layer.new.group` / `layer.groupLayers` | `{name?, layer?}` |
| `layer.duplicate` | `{layer?, name?, document:index\|"new"=same, documentName?}` |
| `layer.delete` | `{layer?}` (no layer = every selected layer) |
| `layer.select` | `{layer:id\|name, occurrence?, mode}` |
| `layer.moveTo` | `{layer?, target, position:"above\|below\|into"=above, copy}` |
| `layer.arrange.bringForward/sendBackward/bringToFront/sendToBack` | `{layer?}` |
| `layer.mergeDown` / `layer.mergeLayers` / `layer.mergeVisible` / `layer.flattenImage` | `{layer?}` |
| `layer.rasterize.layer/type/shape/layerStyle/smartObject` | `{layer?}` |
| `layer.createClippingMask` / `layer.releaseClippingMask` | `{layer?}` |
| `layer.new.layerViaCopy` / `…ViaCut` | `{}` (uses the selection) |
| `layer.new.layerFromBackground` | `{ifPresent?}` |
| `layer.new.artboard` | `{rect?, preset?, name?, background?}` |
| `layer.layerMask.revealAll/hideAll/revealSelection/hideSelection` | `{layer?}` |
| `layer.layerMask.delete/apply/fromTransparency/enabled/linked` | `{layer?, …}` |
| `layer.vectorMask.currentPath/add/edit/delete/enabled/linked` | `{layer?, path?, …}` |
| `layer.smartObjects.convertToSmartObject` | `{layer?}` (no layer = combine selection) |
| `layer.smartObjects.replaceContents` / `exportContents` | `{layer?, path}` |
| `layer.newFillLayer.solidColor` | `{color, path?}` |
| `layer.newFillLayer.gradient` | `{from, to, angle, style, reverse}` |
| `layer.layerStyle.blendingOptions` | `{layer?, blend?, opacity?, fillOpacity?, blendIf?}` |

## Adjustment layers (non-destructive) vs image adjustments (destructive)

`layer.newAdjustmentLayer.*` creates a live layer, optionally masked by the
current selection or a path:

| Id | Key params |
|---|---|
| `…curves` | `{points:[[in,out],…] (0..255, 2..19), red, green, blue, pencil, smooth, eyedropper}` |
| `…levels` | `{inBlack, gamma, inWhite, outBlack, outWhite, red, green, blue}` |
| `…brightnessContrast` | `{brightness:-150..150, contrast:-50..100, legacy}` |
| `…exposure` | `{exposure:-20..20, offset:-0.5..0.5, gamma}` |
| `…vibrance` | `{vibrance:-100..100, saturation:-100..100}` |
| `…hueSaturation` | `{hue, saturation, lightness, colorize, reds…}` |
| `…blackWhite`, `…photoFilter`, `…channelMixer`, `…gradientMap`, `…selectiveColor`, `…colorLookup` | see `command_list` |
| `…invert`, `…posterize`, `…threshold` | `{}`, `{levels}`, `{level}` |

The destructive twins are `image.adjustments.*` with the same params.
`layer.setAdjustment` edits an existing adjustment layer's params.

## Selection

| Id | Params |
|---|---|
| `select.all` / `select.deselect` / `select.inverse` / `select.reselect` | `{}` |
| `select.rect` | `{x, y, width, height, mode:"replace\|add\|subtract\|intersect", ellipse?, line?, antiAlias, feather}` |
| `select.lasso` | `{points:[[x,y],…], mode, antiAlias, feather}` |
| `select.magicWand` | `{x, y, tolerance:0..255, contiguous, antiAlias, sampleAllLayers, mode}` |
| `select.subject` | `{sampleAllLayers=true, mode}` |
| `select.object` | `{rect\|point, mode, sampleAllLayers}` |
| `select.quick` | `{points, size, mode, sampleAllLayers, enhanceEdge}` |
| `select.sky` | `{mode, sampleAllLayers, threshold, softness, …}` |
| `select.colorRange` | `{select:"sampledColors\|reds\|…", …}` |
| `select.modify.feather/expand/contract/smooth/border` | `{radius, applyAtCanvasBounds?}` |
| `select.saveSelection` / `select.loadSelection` | `{name?, channel, operation}` |
| `select.toWorkPath` | `{tolerance}` |
| `select.editInQuickMaskMode` | `{on?}` |
| `select.transformSelection` | `{rect?, quad?}` |

Selection bounds in `doc_inspect` are `[x, y, w, h]`.

## Type and shapes

| Id | Params |
|---|---|
| `type.create` | `{x, y, text, size, color, box:[x,y,w,h]?, name?, align?, font?}` → `{layer, bounds}` |
| `type.edit` | `{layer?, text?, replace?, runs?, box?}` |
| `type.setStyle` | `{layer?\|layers?, range?, size?, font?, color?, leading?, tracking?, align?, …}` |
| `type.info` | `{layer?}` → text, runs, laid-out lines, bounds |
| `type.fonts` | `{family?}` |
| `type.rasterize` / `type.createSelection` | `{layer?}` |
| `type.warpText` / `type.attachToPath` | `{layer?, style?, …}` |
| `shape.create` | `{kind:"rect\|roundedRect\|ellipse\|polygon\|star\|line\|path", rect:[x,y,w,h], fill, stroke, radii?, sides?, starRatio?}` → `{layer, bounds, live}` |
| `shape.edit` | `{layer?, kind?, rect?, path?, …}` |
| `shape.info` | `{layer?}` |
| `shape.presets.place` | `{preset, group?, rect?, fill?, stroke?}` |

A missing font produces a warning in the result, not an error.

## Paths

`path.list`, `path.set {name, path, op}`, `path.delete`, `path.toSelection`,
`path.fill`, `path.stroke`, `path.addAnchor`, `path.deleteAnchor`,
`path.convertPoint`, `path.moveAnchors`, `path.transform`,
`path.clippingPath.set`.

## Filters

`filter.blur.gaussianBlur {radius:0.1..1000}`, `filter.blur.motionBlur`,
`filter.blur.radialBlur`, `filter.blur.lensBlur`, `filter.blurGallery.*`,
`filter.sharpen.unsharpMask {amount, radius, threshold}`,
`filter.sharpen.smartSharpen`, `filter.noise.reduceNoise`,
`filter.noise.addNoise {amount, distribution, monochromatic, seed}`,
`filter.distort.twirl/wave/ripple/pinch/spherize/polarCoordinates`,
`filter.stylize.*`, `filter.pixelate.mosaic`, `filter.render.*`,
`filter.other.highPass/minimum/maximum/offset`, `filter.gallery.spatter`.

Filters are destructive on pixel layers; on Smart Objects they become editable
`layer.smartFilter.*` entries.

## History, state, preferences

| Id | Params |
|---|---|
| `edit.undo` / `edit.redo` | `{}` |
| `history.selectState` | `{state}` (0 = oldest) |
| `history.deleteState` | `{state?}` (removes it and everything later) |
| `history.newSnapshot` / `selectSnapshot` / `deleteSnapshot` | `{name?, from?, snapshot}` |
| `prefs.get` | `{path?}` (`"performance.historyStates"`, `"colorSettings.workingRgb"`) |
| `prefs.set` | `{path, value}` or `{values:{…}}` (validated; all or nothing) |
| `jobs.list` / `jobs.cancel` | `{job?}` (long filters, file opens/saves) |

## Shell-only surface

Some things are **not** in the 918-command registry and must go through the
control channel (bridge mode):

- Tool selection: `ui.set {tool: "<internal id>"}` — `brush`, `rectMarquee`,
  `ellipseMarquee`, `lasso`, `magicWand`, `crop`, `type`, `move`, `hand`,
  `zoom`, `eraser`, `paintBucket`, `gradient`, `shape` tools use
  `rectangle`/`ellipseShape`/`polygon`/`line`/`customShape`, and so on. Display
  names (`"Rectangular Marquee"`) are rejected.
- Zoom/pan/theme/panels: `ui.set {zoom, center, fit, theme, panels, dock…}`.
- Dialogs: `ui.dialog.open/set/confirm/cancel`; menus: `ui.menu.invoke`.
- Pointer input: `ui.pointer` in **document** coordinates.

Details in `mcp-and-control.md`.
