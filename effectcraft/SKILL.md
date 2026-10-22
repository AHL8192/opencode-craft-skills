---
name: effectcraft
description: Use whenever working with EffectCraft on this machine — the Rust motion-graphics and VFX compositor and After Effects alternative — including building or animating compositions, layers, keyframes, effects, masks, shape layers, text, expressions, 3D cameras/lights and the render queue, exporting .ecproj/Lottie/MP4/ProRes/WebM/PNG/EXR/GIF, driving the live desktop window, or using its MCP server, `effectcraft-cli` or JSON control channel. Triggers on "EffectCraft", "effectcraft-cli", "effectcraft mcp", "EffectCraft MCP", "make a motion graphic/title card/lower third", "animate this in EffectCraft", "add a glow/blur/particle effect", "keyframe this property", "render this comp to MP4/ProRes/GIF", "export Lottie from EffectCraft", "take an EffectCraft screenshot". Invoke with @effectcraft.
---

# EffectCraft — agent operation

EffectCraft is a native Rust compositor in the After Effects mould: compositions of
layers, properties with keyframes and expressions, 307 effects, masks, shapes,
text, 3D cameras/lights, a render queue, Lottie both ways, and a `.ecproj`
project that is readable JSON. **Every menu item, drag and property edit is one
engine command with an id.** The GUI, `effectcraft-cli`, the JSON control channel
and the MCP server all drive that same command engine.

## Machine snapshot (verified 2026-10-22)

| Thing | Value |
|---|---|
| App | `/usr/bin/effectcraft` — `effectcraft 0.13.0` |
| CLI | `/usr/bin/effectcraft-cli` — `0.13.0` |
| App flags | `--control PORT`, `--version`, `--project F`, `--demo`, `--empty`; `--help` is *not* a flag (error, exit 1) |
| Env | `EFFECTCRAFT_CONTROL_PORT`, `EFFECTCRAFT_CONFIG_DIR`, `EFFECTCRAFT_FONT_DIRS` |
| Config dir | `~/.config/effectcraft/` (`Logs/`, `window.json`, `workspaces.json`) |
| Control port | `9877` by convention; **unauthenticated**, loopback only |
| Commands | **731** in 55 namespaces |
| Effects | **307** (280 GPU-capable) — the README's "306" is stale |
| MCP tools | 27 headless, **36** bridged to a window (adds `screenshot`, `ui_*`, `control`) |
| MCP resources | `effectcraft://document`, `effectcraft://commands` (no prompts) |
| Project schema | `.ecproj`, `schema: 2`, `savedBy` version, `next_id` |

**Version drift is expected** — this is an alpha (first commit 2026-10-01);
re-check counts and flags before trusting them.

## Mental model

- A **project** holds items: compositions, footage, solids, folders. A
  **composition** holds layers (top of the list renders last, `#1` is the top).
- A **layer** is text, solid, shape, footage, precomp, null, adjustment, camera,
  light, 3D primitive or model.
- A **property** is addressed by a path from `get_layer`/`props`:
  `transform/position`, `transform/opacity`, `effects/#1/blurriness`,
  `contents/trim/end`, `masks/#1/feather`, or a bare `@uid`. A group path is an
  error that tells you to inspect the children — correct, not a bug.
- A **command** is `{"command": "comp.new", "params": {...}}`. `list_commands`
  finds ids, `describe_command` returns the param doc and a JSON Schema,
  `execute_command` runs one, `batch` runs several as **one** undo step.
- **Times are seconds.** Keyframe tools default to **layer time**;
  `get_property`/`render_frame` take **comp time**. Pass
  `timeBase: "comp"` to key in comp seconds on offset or stretched layers.
- **Space is composition pixels**, y down, origin top-left. Effects, masks,
  paint and puppet pins use **layer/effect space**; shape and text layers have
  comp-sized bounds centred on their content.
- **Unknown parameters are rejected**, with the accepted list — no silent typo
  no-ops. Value *coercions* are the real risk (see Known bugs).

## Three connection modes

| Mode | Command / server | Use |
|---|---|---|
| Headless MCP | `effectcraft-cli mcp` → OpenCode `effectcraft` | batch work, renders, no window |
| Bridged MCP | `effectcraft --control 9877` + `effectcraft-cli mcp --bridge 9877` → `effectcraft-app` | drives and screenshots the real window |
| CLI | `effectcraft-cli exec/get/set/render/...` | one-shot scripting and CI |

```sh
# headless
effectcraft-cli mcp

# isolated live window (never touch the user's profile)
EFFECTCRAFT_CONFIG_DIR=/tmp/ec-agent effectcraft --control 9877 &
effectcraft-cli mcp --bridge 9877
```

## Minimal working example (all calls verified)

```python
# MCP: comp -> text -> keyframes -> effect -> frame -> save
execute_command {"command":"comp.new","params":{"name":"Intro","width":1920,"height":1080,"frameRate":30,"duration":4}}
execute_command {"command":"layer.newText","params":{"name":"Title","text":"Hello","size":160,"fill":"#ffffff"}}   # -> {"layer": 2}
add_keyframe {"layer":"Title","path":"transform/position","keys":[{"time":0,"value":[-300,540]},{"time":1.5,"value":[960,540]}],"interpolation":"easyEase"}
add_effect {"layer":"Title","effect":"Gaussian Blur","values":{"blurriness":8}}
render_frame {"time":1.5,"max_side":960}          # PNG image content
save_project {"path":"/abs/path/intro.ecproj"}
```

CLI equivalent: `effectcraft-cli run --empty comp.new '{...}' layer.newText '{...}'
--save-as intro.ecproj`, then `effectcraft-cli render-frame intro.ecproj --comp Intro
--time 0 --out f.png`.

## Safest default workflow

1. **Orient:** `get_state` (`app.version`, counts, `state.active_comp`) →
   `get_project` (items, `dirty`, `path`) → `get_comp {}`.
2. **Discover, never guess:** `list_commands {"filter":"mask"}` →
   `describe_command {"command":"mask.new"}`.
3. **Build in one undo step where possible:** `batch` with `"$1.layer"`
   references; it rolls back entirely on a bad step.
4. **Verify by reading back:** `get_property` (value + `evaluated`), `get_layer`
   (`flat:true` for every path), `render_frame` to look at pixels.
5. **Save a copy:** `save_project {"path": …}`. Headless keeps work in memory
   only — use `mcp --autosave` or save after each milestone.
6. **Render:** `renderQueue.add` + `renderQueue.render {"wait":true}`, or
   `effectcraft-cli render --out …`.

## Tools (27 headless)

| Tool | Purpose |
|---|---|
| `list_commands`, `describe_command`, `execute_command`, `batch` | the engine |
| `command_list`, `command_run`, `command_batch` | aliases (same engine, per-step undo for `command_batch`) |
| `get_state`, `get_project`, `get_comp`, `get_layer`, `get_property`, `set_property`, `add_keyframe` | inspect/edit |
| `add_effect`, `list_effects`, `list_fonts`, `render_frame` | effects, fonts, PNG frame |
| `open_project` (`path`/`demo`/`new`), `save_project` | files |
| `undo`, `redo`, `history` | history, including branch jumps |
| `run_script`, `script_ui` | After Effects-style JS and the dialogs it opens |
| `doc_inspect` | project + active comp in one call |

Bridged servers add `screenshot {path,panel?,id?}`, `ui_inspect`, `ui_elements
{prefix?}`, `ui_click`, `ui_drag`, `ui_key`, `ui_type`, `ui_set`, `control`.

Resources: `effectcraft://document` (= `doc_inspect`), `effectcraft://commands`
(= full catalog).

## Conventions that bite

- **Layer references:** id (`2`), `"#n"` (1-based from the top), or name. An
  all-digit string that matches no name is taken as an id. Names must be unique
  in practice — duplicates resolve to an arbitrary match.
- **Deleting is `edit.clear`**, not `layer.delete` (which does not exist).
  `edit.duplicate` is Cmd+D. `layer.rename` is Enter.
- **`prop.set` needs a `value`**; `set_property` takes `value` and/or
  `expression` (the MCP way). Syntax errors are kept but disabled and reported in
  `expressionError`; `value` still renders.
- **Command params are the contract.** Extra keys are errors; missing keys
  default. `comp.new {}` makes 1920×1080, 29.97 fps, 10.01 s.
- **Undo depth is 32** by default (`history` shows 33 states). A property set to
  its current value records no step. `history {"goto": id}` moves across branches.
- **`layer.select` with a bad reference returns `[]`**, unlike every other
  command (documented as "never a silent no-op").
- **Save ignores the extension**: `save_project {"path":"x.txt"}` writes
  `.ecproj` JSON with no warning.
- **Render format beats the extension**: `render --format png --out x.mp4` writes
  `x_[#####].png`; `--format aiff --out a.aiff` writes `a.aif`. CLI `render`
  creates output folders; `render_frame` does not (it errors; relative paths use
  the server CWD). Relative `renderQueue` outputs use the **project's folder**;
  CLI `--out` uses the CWD.
- **EXR is 16-bit half by default**, even at 16 bpc — there is no 32-bit float
  switch in 0.13.0. Use `comp.saveFrameAsExr` for multi-layer channels.
- **Image import treats one numbered still as its whole run**; pass
  `sequence:false` for a single still.

## Verify

`get_property` for a value at a time, `get_layer {"flat":true}` for the tree,
`render_frame`/`screenshot` to see it, `history` for what was recorded. For files
use `effectcraft-cli info` plus `file`, `identify`, PIL and a JSON/MP4 parser
(there is no ffprobe here).

## Known bugs and workarounds (0.13.0)

- **`ui.resize` is a silent no-op** on this Wayland session: returns null, window
  unchanged (≈1912×1004). Don't rely on it; screenshots use the live size.
- **GUI text fields don't select-all with `Ctrl+A`/`Cmd+A`.** Click with
  `{"id":"dialog.comp.name","fx":1.0}`, send Backspace × length, then `ui_type`.
- **`prop.set` coerces booleans**: `true` on opacity yields `1.0`, and `150`
  clamps to `100`, both silently. Validate ranges yourself.
- **Unknown font names are accepted and stored**; rendering falls back with no
  warning (`NoSuchFontFamily` renders byte-identically to the fallback).
- **`file.findMissing` can report `items: []` while `footage.check` reports
  `missing: 1`** (whole footage folder gone). Trust `footage.check`.
- **`command_batch` stops at the first error and keeps earlier steps**; `batch`
  rolls the whole set back.
- **`layer.newPrecomp` does not exist** — use `layer.precompose {layers, name}`.

Full reproductions: `references/bugs-and-workarounds.md`.

## CLI in 30 seconds

```sh
effectcraft-cli info --json                       # project + engine summary
effectcraft-cli commands --filter keys --json     # catalog (731)
effectcraft-cli exec --list --schemas --json      # every id + JSON Schema
effectcraft-cli exec comp.new --params '{"name":"Main"}' --empty --save-as main.ecproj
effectcraft-cli props Main '#1' --project main.ecproj          # flat property paths
effectcraft-cli set Main '#1' transform/opacity 40 main.ecproj --save
effectcraft-cli render-frame main.ecproj --comp Main --time 1 --out f.png
effectcraft-cli render main.ecproj --comp Main --out out.mp4 --format h264 --start 0 --end 3
effectcraft-cli script job.jsx main.ecproj        # AE-style JS
effectcraft-cli mcp [--autosave] [--bridge 9877]
```

`references/cli.md` has every subcommand, option and exit-code rule.

## Reference files

`references/`: `commands.md` (namespaces, params), `mcp-and-control.md`
(handshake, tools, control, UI), `cli.md`, `scripting.md`, `recipes.md`,
`formats-and-roundtrip.md`, `bugs-and-workarounds.md`, `maintenance.md`.
`scripts/`: `probe.sh`, `dump-commands.sh`, `smoke-test.sh`.

## Maintenance

```sh
bash ~/.config/opencode/skills/effectcraft/scripts/probe.sh
bash ~/.config/opencode/skills/effectcraft/scripts/dump-commands.sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/effectcraft
```

`dump-commands.sh` diffs the live catalog against `references/command-index.txt`.
When a release changes ids, params or counts, update this file and the
references rather than trusting this snapshot.

## What was not tested

GPU (`--gpu`) and advanced-3D rendering, motion/face tracking and Roto Brush
(model downloads), WASM effect plug-ins, ScriptUI, render-queue templates,
multi-viewer workspaces, audio waveforms, Wayland drag-and-drop (broken
upstream), 4K and long renders. Windows/macOS are out of scope here.
