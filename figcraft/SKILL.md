---
name: FigCraft
description: Use whenever working with FigCraft on this machine — the Rust interface-design and prototyping app (a Figma-class tool) — including creating or editing frames, auto layout, components and variants, styles and variables, vector networks, prototypes, Dev Mode, importing or exporting (.figcraft, .json, .fig, SVG, PNG/JPG/WebP/PDF), driving the running desktop window, or using its MCP server, `figcraft-cli`, control channel or command engine. Triggers on "FigCraft", "figcraft-cli", "figcraft mcp", "design a screen/landing page/dashboard in FigCraft", "build a component or variant", "wire a prototype flow", "export this design as PNG/SVG/PDF/fig", "take a FigCraft screenshot", "drive the FigCraft window", and requests to automate interface design or FigCraft itself. Invoke with @figcraft.
---

# FigCraft — agent operation

FigCraft is a native Rust interface-design tool: pages, frames, auto layout, components
and variants, vector networks, styles and variables, prototypes and Dev Mode. Every menu
item, tool and gesture is a **command with an id**; the UI, `figcraft-cli`, the JSON control
channel and the MCP server all drive the same engine. Files are `.figcraft` archives.

## Machine snapshot (verified 2026-10-22, 0.8.0)

| Thing | Value |
|---|---|
| Desktop app | `/usr/bin/figcraft` — `FigCraft 0.8.0 (594dc8c6cf50…)` |
| CLI | `/usr/bin/figcraft-cli` — `figcraft-cli 0.8.0` |
| Install | Debian package `figcraft 0.8.0-1` (`dpkg -S /usr/bin/figcraft`) |
| App flags | `--control PORT`, `--automation-read-root DIR`, `--automation-write-root DIR`, `--version`; **`--help` is rejected, `-h` opens the GUI** |
| MCP headless | `figcraft-cli mcp` (18 tools, protocol `2025-06-18`) |
| MCP attached | `figcraft --control 47801` + `figcraft-cli mcp --attach 47801` |
| OpenCode servers | `figcraft` (headless), `figcraft-app` (bridge to 47801) |
| Command catalog | **569 commands in 57 namespaces** (`figcraft-cli commands --json`) |
| Starter templates | 8 (`template.list`): mobile-app, landing-page, dashboard, design-system, wireframe-kit, social-posts, slides, icon-set |
| Formats | native `.figcraft` (zip: `document.json` + `thumbnail.png`), `.json` (FigCraft or REST API file JSON), `.fig` best-effort; import SVG + PNG/JPG/WebP/GIF/BMP/TIF; export PNG/JPG/WebP/SVG/PDF/`.fig` |
| No parity command | `figcraft-cli parity` does not exist |

**Alpha software**: re-verify with the scripts below.

## Mental model

- A **document** has **pages**; pages hold layers. Page 1 has id `1`; new layers usually
  start at `2` and ids keep counting up (they survive save/reload).
- **Coordinates are page units** (1 unit = 1 px at 100% zoom), x right, **y down**.
- `create_node` / `set_properties` `x`/`y` are **relative to the parent frame** (the page when
  there is none). **Groups and boolean groups have no coordinate space of their own** — a layer
  in a group is placed in the frame the group sits in. `get_node` reports `x`/`y` the same way
  plus `absoluteBounds` in page coordinates.
- **Auto layout owns its children's positions.** In an auto-layout frame set `layout`, `gap`,
  `padding`, `mainAlign`, `crossAlign`, `sizingH`/`sizingV` (`fixed|hug|fill`) and the min/max
  sizes instead of x/y. Grid: `layout:"grid"` + `gridColumns`, `columnTracks`, `gridColumn`…
- A **command** is `{"command": id, "params": {…}}`. `list_commands` finds ids and parameter
  docs; `run_command` runs one; `batch` runs many as **one undo step**.
- **Everything mutating is one undo step**, and a failing command leaves the document unchanged.
  `batch` is all-or-nothing.
- **Verify by reading back** (`get_node`, `inspect_document`), never by trusting a success reply:
  several silent-success bugs are listed below.

## Two connection modes

| Mode | Start | What it is for |
|---|---|---|
| Headless | `figcraft-cli mcp` | No window. Batch creation, rendering, export, CLI scripts, confined file access. |
| Attached | `figcraft --control 47801` then `figcraft-cli mcp --attach 47801` | Drives the real window: `screenshot {window:true}`, `pointer`, `key`, `type_text`, `inspect_ui`. |

Both speak MCP over stdio. In this OpenCode install they are configured as `figcraft` and
`figcraft-app` in `~/.config/opencode/opencode.json` (add them if missing; see
`references/mcp-and-control.md`). A direct stdio JSON-RPC client works without any config.

```sh
# headless
figcraft-cli mcp
# live window on a port you own (check: ss -ltn | grep 47801)
figcraft --control 47801 &
figcraft-cli mcp --attach 47801
```

## Minimal working example (MCP, headless)

```jsonc
// 1. a frame on the page
{"name":"create_node","arguments":{"type":"frame","name":"Card","x":0,"y":0,"width":320,"height":200,
  "props":{"fill":"#FFFFFF","cornerRadius":12}}}
// → {"id": 2, "node": {...}}
// 2. a text layer inside it (x/y relative to the frame)
{"name":"create_node","arguments":{"type":"text","parent":2,"x":24,"y":32,"text":"Hello FigCraft",
  "props":{"fontSize":28,"fill":"#1B1B1B"}}}
// 3. read it back
{"name":"get_node","arguments":{"id":3,"depth":0}}
{"name":"inspect_document","arguments":{}}
// 4. look at it
{"name":"export","arguments":{"ids":[2],"format":"png","scale":2,"path":"/tmp/card.png"}}
// 5. save
{"name":"save_file","arguments":{"path":"/tmp/card.figcraft"}}
```

The same document from the shell, without MCP:

```sh
cat > /tmp/card.json <<'JSON'
[{"command":"node.create","params":{"type":"frame","name":"Card","width":320,"height":200,
   "props":{"fill":"#FFFFFF","cornerRadius":12}}},
 {"command":"node.create","params":{"type":"text","parent":{"$step":0},"x":24,"y":32,
   "text":"Hello FigCraft","props":{"fontSize":28}}}]
JSON
figcraft-cli run /tmp/card.json --out /tmp/card.figcraft
figcraft-cli info /tmp/card.figcraft          # independent read-back
figcraft-cli export /tmp/card.figcraft -o /tmp/card.png --node "Card" --scale 2
```

## Tools (18)

| Tool | Purpose |
|---|---|
| `list_commands {filter?}` | ids, labels, menus, shortcuts, undoable, param docs |
| `run_command {command, params}` | any command (`align.left`, `layout.add`, `component.create`, `proto.*`, `inspect.*`…) |
| `batch {commands, label?}` | many commands, one undo step; `{"$step": n}` references an earlier id |
| `create_node {type, x?, y?, width?, height?, parent?, index?, name?, text?, path?, props?}` | frame, rectangle, ellipse, polygon, star, line, arrow, vector, text, section, component, slice |
| `set_properties {ids, props}` | `node.set` on layers; returns `{nodes:[…], ok:true}` |
| `inspect_document {depth?, allPages?}` | layer tree, pages, styles, selection, history; **depth 0 has no children** |
| `get_node {id, depth?}` | one layer, children to `depth` |
| `select {ids}` | replace selection (`[]` deselects) |
| `export {ids?, format, scale?/size?, path?, …}` | png/jpg/webp/svg/pdf/fig; without ids: selection, else page |
| `screenshot {ids?, scale?, maxSize?, window?}` | PNG of the design, or the app window when attached |
| `open_file {path, variables?}` / `save_file {path?}` | open `.figcraft/.json/.fig/.svg/image`; save as `.figcraft` |
| `undo` / `redo` | one command / batch / gesture per step |
| `pointer {kind, x, y, to?, steps?, tool?, shift?, alt?, cmd?}` | click/double/drag/down/move/up/hover in page coordinates; `to` is `[x, y]` |
| `key {key, shift?, alt?, cmd?}` | shortcut or key as if typed on the canvas |
| `type_text {text, id?}` | replace a text layer's characters, or type into the edit |
| `inspect_ui {}` | tool, canvas, panels, windows, status, timings (attached); **no `view`** — use `view.get` |

Resources: `figcraft://document`, `figcraft://commands` (+ `figcraft://node/{id}` and
`figcraft://command/{id}` templates). Prompts: `mobile_screen`,
`design_system`, `landing_page`, `prototype_flow`.

## Safest default workflow

1. **Probe first.** `inspect_document` for the current state; `list_commands {filter:"…"}`
   before guessing an id or parameter.
2. **Start from a template** when the task is a whole app/site:
   `run_command {command:"file.newFromTemplate", params:{template:"mobile-app"}}`, or create
   a blank document with `file.new` (this opens a **new tab**, it does not reset the old one).
3. **Build with `batch`** and `{"$step": n}` references — one undo step, all-or-nothing.
4. **Read back** each important layer (`get_node`) before styling further.
5. **Export/render to check pixels** (`export` PNG then look at it; `screenshot` for the page).
6. **Save a copy** with an explicit `.figcraft` path; confirm with `figcraft-cli info`.
7. **Only then** touch a user file, and never overwrite one without a copy in a test dir.

## Finding commands

`list_commands {filter:"auto layout"}` (the filter is a **literal, case-insensitive substring**:
`"autoLayout"` matches nothing). CLI: `figcraft-cli commands --filter "auto layout"` or
`--json`. Biggest namespaces: `text` 56, `view` 48, `vector` 40, `object` 28 (full table in
`references/commands.md`). Never guess a parameter — query it.

## Verify your work

- Numbers: `get_node`, `inspect_document`.
- Pixels: `export`/`screenshot` → `identify file.png` (`file`, `pdfinfo`, `pdftotext` for PDF).
- Saved files: `figcraft-cli info path --json`; a `.figcraft` is a zip (`unzip -l`).
- UI: `inspect_ui` (attached), `screenshot {window:true}`.

## Pitfalls (verified in 0.8.0 — details in `references/bugs-and-workarounds.md`)

- **`save_file` does not check the extension.** `save_file {path:"x.png"}` writes a `.figcraft`
  **zip** named `x.png` and reports success. Always end native saves in `.figcraft`.
- **`export` writes the format you ask for, not the one the path suggests.**
  `format:"png", path:"x.jpg"` writes PNG bytes into `x.jpg`; `file.export {format:"pdf",
  path:"x.png"}` writes a PDF named `x.png`.
- **`inspect.code` takes `language`, not `format`.** An unknown key is ignored and you silently
  get CSS.
- **`create_node` and `node.create` ignore unknown arguments**; `node.set`/`set_properties`
  reject unknown properties by name ("unknown properties: …"). Typos in props are therefore
  loud, typos in tool arguments are silent.
- **`opacity` outside 0–1 is rescaled, not rejected:** `2` → `0.02`, `-1` → `0`. Stay in 0–1.
- **Negative sizes clamp to 0** (`width:-50` → 0) with no warning.
- **`export` with no ids uses the selection**, so "nothing to export" or a one-layer export
  usually means something is still selected. `select.none` first for a whole page.
- **PDF:** one page per top-level frame only when exporting the page; with `ids` you get one page.
- **SVG outlines text by default**; pass `svgOutlineText:false` for real `<text>`.
- **`file.new` opens an additional tab**, and `open_file` on an already-open file returns
  `{opened:{index}}` with no summary.
- **`page.delete` takes its layers with it** (undoable). Sections go only on a page or in a
  section, not inside frames.
- **Attached mode on Wayland:** if the window is covered or minimised the compositor stops
  drawing it; UI work then waits and fails with "timed out waiting for the UI". A timed-out
  request was seen to wedge the control channel (even `initialize` hung) until the app was
  restarted — kill only a FigCraft you started, then relaunch.
- **`file.close` never prompts**: it errors on unsaved changes unless `{force:true}`.
- **`.fig` is best effort** (import and export); verify what came back.

## What was not tested

Live sessions/`figcraft-server`, plugins, comments/Dev Mode end-to-end, presentation player,
printing, the browser/WASM build, real Figma `.fig` files, Display P3, missing-font fallback,
i18n, accessibility, and documents beyond ~2,000 layers. Exact export checks:
`references/formats-and-roundtrip.md`.

## Reference files

`references/`: `commands.md` (ids + params by namespace), `recipes.md` (task recipes),
`mcp-and-control.md` (protocol, tools, control channel, coordinates, windows, confinement),
`cli.md`, `formats-and-roundtrip.md`, `bugs-and-workarounds.md`, `maintenance.md`.
`scripts/`: `probe.sh`, `dump-commands.sh`, `smoke-test.sh`.

## Maintenance

```sh
bash ~/.config/opencode/skills/figcraft/scripts/probe.sh          # versions, tools, counts
bash ~/.config/opencode/skills/figcraft/scripts/dump-commands.sh  # catalog snapshot + diff
bash ~/.config/opencode/skills/figcraft/scripts/smoke-test.sh     # headless end-to-end
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/figcraft
```

The snapshot above was verified on **2026-10-22 against 0.8.0**. Command ids, parameters,
counts and tool names can change between releases; confirm before relying on a detail.
