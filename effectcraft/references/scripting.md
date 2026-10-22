# Scripting — EffectCraft 0.13.0

EffectCraft runs ExtendScript-style JavaScript against an After Effects-shaped
object model. It is available three ways:

```sh
effectcraft-cli script job.jsx [project.ecproj]
effectcraft-cli script --eval 'writeLn(app.project.activeItem.name)' --empty
```

```json
{"tool":"run_script","code":"var c=app.project.activeItem; c.layers.addText('Hi');"}
```

The CLI prints `writeLn` output and the script's return value; a runtime error
exits **1** with `file:line:col`:

```text
effectcraft-cli script: bad.jsx:2:1: ReferenceError: notAFunction is not defined
```

MCP `run_script` returns `{ok, result, output, error}` — `output` is everything
`writeLn` produced, and `result` is the script's final expression value.

## Verified object model

`app.version` answers with the After Effects compatibility string:
`26.0 (EffectCraft 0.13.0)`.

```js
// project and comps
app.project.items.addComp("S", 320, 180, /*pixelAspect*/1, /*duration*/3, /*fps*/30);
app.project.activeItem            // the comp created/opened most recently
comp.name, comp.numLayers, comp.time, comp.frameRate, comp.duration
comp.layer("Name"), comp.layer(1) // by name or 1-based index
comp.layers.addText("Scripted")
comp.layers.addSolid([r,g,b], "Red", w, h, pixelAspect)
comp.layers.addNull, addShape, addCamera, addLight  // all functions

// layers and properties
layer.name, layer.inPoint, layer.outPoint   // in/out are writable (trim)
layer.property("Position").setValue([160, 90]);
layer.property("Opacity").setValueAtTime(0, 0);
layer.property("Opacity").setValueAtTime(1, 100);
layer.property("Opacity").numKeys
layer.property("Opacity").value
layer.property("Opacity").expression = "time*10";   // get/set
layer.property("Position").keyValue(1)              // -> "0,90,0"
layer.property("Transform").name
layer.property("Effects")                            // [object PropertyGroup]
layer.property("Effects").addProperty("Gaussian Blur");
app.project.save("/abs/path/out.ecproj");            // returns true
app.beginUndoGroup(); app.endUndoGroup();            // present
comp.markerProperty                                  // object
```

Property names are the UI names (`Position`, `Opacity`, `Scale`, `Transform`,
`Effects`); effects take their display name (`"Gaussian Blur"`). `keyValue(n)` is
1-based and returns a comma-joined string for vectors.

## Semantics that matter

- **Script edits are real edits.** They mutate the same project, appear in
  `get_project`, and are saved by `save_project`/`app.project.save`. They are
  undoable: `run_script` creates history entries (undo restores the state).
- `app.project.activeItem` is the comp created by `addComp` in the same script
  even when the project started empty. In a bridged session it is the comp open
  in the GUI.
- `writeLn` goes to the `output` field, not stdout, under MCP.
- `app.project.save` accepts a path and writes `.ecproj` JSON; it also marks the
  project clean. Without a path it saves to the current project path.
- Scripts can be given a project and run headlessly (`script FILE.jsx F.ecproj`)
  but do **not** get an implicit `--save`; use `app.project.save()` or pass
  `--save` to the CLI.
- `run_script` is not sandboxed: it can read/write files the process can. Use
  `--automation-read-root` / `--automation-write-root` on `mcp` to confine file
  access; scripts are refused outside those roots.

## ScriptUI

`script_ui` exposes ScriptUI windows created by a script in a bridged app
(headless returns an error/empty). It was **not exercised** in this build; treat
dialog automation as untested and prefer engine commands.

## When to script vs. command

| Use scripts for | Use commands for |
|---|---|
| loops over many layers/comps | anything the GUI does, one action |
| reading complex structures quickly | undo-step control (`batch`) |
| porting AE expressions/scripts | renders, imports, exports |
| exploratory math | reproducible recipes (params are schema-checked) |

A pragmatic pattern is a script that computes values and writes them through
`layer.property(...).setValue(...)`, followed by `get_property` verification and
a render. Prefer `batch` when you need atomic rollback; scripts do not roll back
on error.
