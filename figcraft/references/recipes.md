# Recipes — FigCraft 0.8.0

Each recipe was run against 0.8.0 unless marked otherwise. Coordinates are page units (y down);
`x`/`y` are relative to the parent frame. All commands can be sent with
`run_command {command, params}` or `batch`, or written to a JSON array for `figcraft-cli run`.

## 1. A blank document with a phone screen and auto layout

```jsonc
{"command":"file.new","params":{}}
// screen frame on the page
{"command":"node.create","params":{"type":"frame","name":"Login","x":0,"y":0,"width":390,"height":844,
  "props":{"fill":"#FFFFFF","cornerRadius":24}}}
// vertical auto layout, 24 padding, 16 gap (ids: the frame from step 0)
{"command":"layout.add","params":{"ids":[{"$step":0}],"direction":"vertical"}}
{"command":"node.set","params":{"ids":[{"$step":0}],"gap":16,"padding":24,"mainAlign":"center","crossAlign":"min"}}
// children flow: no x/y needed; fill the width
{"command":"node.create","params":{"type":"text","parent":{"$step":0},"text":"Welcome back",
  "props":{"fontSize":32,"sizingH":"fill"}}}
{"command":"node.create","params":{"type":"text","parent":{"$step":0},
  "text":"Sign in to continue","props":{"fontSize":16,"fill":"#666666","sizingH":"fill"}}}
{"command":"node.create","params":{"type":"rectangle","parent":{"$step":0},"height":48,
  "props":{"fill":"#3B5BDB","cornerRadius":10,"sizingH":"fill","name":"Sign in button"}}}
```

Read back with `get_node {id:<frame>, depth:2}`: auto-layout children have positions but you should
change `gap`/`padding`, not their `x`/`y`. `sizingH:"fill"` makes a child fill the cross axis;
`sizingV:"hug"` on the parent makes the frame fit its content.

## 2. A card row (frames + group + alignment)

```jsonc
{"command":"node.create","params":{"type":"frame","name":"Cards","x":0,"y":0,"width":960,"height":300,
  "props":{"fill":"#F5F5F5"}}}
{"command":"layout.add","params":{"ids":[{"$step":0}],"direction":"horizontal"}}
{"command":"node.set","params":{"ids":[{"$step":0}],"gap":24,"padding":24,"crossAlign":"center"}}
{"command":"node.create","params":{"type":"frame","parent":{"$step":0},"width":280,"height":220,
  "props":{"fill":"#FFFFFF","cornerRadius":16,"layout":"vertical","gap":12,"padding":20}}}
{"command":"node.create","params":{"type":"text","parent":{"$step":2},"text":"Card title",
  "props":{"fontSize":22,"sizingH":"fill"}}}
{"command":"node.create","params":{"type":"text","parent":{"$step":2},"text":"Body copy wraps in the card width.",
  "props":{"fontSize":14,"fill":"#555555","sizingH":"fill"}}}
```

Copy the card with `edit.duplicate {ids:[<card>]}` (frames go to the right with a 100 gap by
default) or build the second one explicitly.

## 3. Component set with two variants and an instance

```jsonc
// two components, then combine them into one set
{"command":"node.create","params":{"type":"component","name":"Button/Primary","x":0,"y":0,
  "width":140,"height":44,"props":{"fill":"#3B5BDB","cornerRadius":10}}}
{"command":"node.create","params":{"type":"component","name":"Button/Ghost","x":0,"y":80,
  "width":140,"height":44,"props":{"fill":"#FFFFFF","stroke":"#3B5BDB","strokeWeight":2,"cornerRadius":10}}}
{"command":"component.combineVariants","params":{"ids":[{"$step":0},{"$step":1}]}}   // → {id: set}
{"command":"component.properties","params":{"id":{"$step":0}}}
// → properties:[{name:"Property 1", options:["Default","Variant2"], default:"Default"}]
// an instance of the default variant, 400 to the right
{"command":"instance.create","params":{"component":{"$step":0},"x":400,"y":0}}
// switch it by property name; unknown names are rejected with the known list
{"command":"instance.setProperties","params":{"ids":[{"$step":3}],
  "properties":{"Property 1":"Variant2"}}}
```

Name variants up front with `component.addVariant {id, property:"State", value:"Hover"}` (duplicates
the variant) or `component.editProperty` (renames the auto-generated `"Property 1"`). Main component
duplicates are instances; detach with `component.detach`.

## 4. Paint/text styles and a variable collection with modes

```jsonc
{"command":"style.create","params":{"type":"paint","name":"Brand/Primary",
  "value":[{"type":"solid","color":"#E8590C"}]}}
{"command":"style.apply","params":{"ids":[<frame>],"style":"Brand/Primary","target":"fill"}}
{"command":"style.create","params":{"type":"text","name":"Display",
  "value":{"fontSize":40,"fontFamily":"Inter","fontStyle":"Bold"}}}
{"command":"style.apply","params":{"ids":[<text>],"style":"Display"}}

{"command":"variable.createCollection","params":{"name":"Theme","modes":["Light","Dark"]}}
{"command":"variable.create","params":{"collection":"Theme","name":"surface","type":"color",
  "values":{"Light":"#FFFFFF","Dark":"#101010"}}}
{"command":"variable.bind","params":{"ids":[<frame>],"field":"fills/0/color","variable":"surface"}}
{"command":"variable.setMode","params":{"ids":[<frame>],"collection":"Theme","mode":"Dark"}}
{"command":"variable.export","params":{"format":"json","path":"/tmp/theme.json"}}
```

`variable.set {variable:"surface", mode:"Dark", value:"#101010"}` changes the value in that mode
for every layer using it. Bindings survive save/reload; `style.bind` does the same for a style's
field. Switch a whole page's modes with `variable.setMode {collection:"Theme", mode:"Dark"}`.

## 5. Prototype flow and expression check

```jsonc
{"command":"proto.flow.add","params":{"start":<frameA>,"name":"Onboarding"}}
{"command":"proto.interaction.add","params":{"id":<buttonInFrameA>,
  "trigger":{"type":"onClick"},
  "action":{"type":"navigate","dest":<frameB>},
  "transition":{"type":"smartAnimate"},"durationMs":300,"easing":"easeInOut"}}
{"command":"proto.evaluate","params":{"expression":"count + 1"}}      // → {value,type,text}
{"command":"proto.evaluate","params":{"expression":"mode(Theme) == 'Dark'"}}
```

Read the interaction back from `get_node {id:<button>}` (`interactions`) — do not rely on
`proto.present`/`proto.preview` in headless mode. Conditional actions:
`proto.interaction.add` with `action.type:"conditional"` and `blocks`, then
`proto.conditional.addBlock|setCondition`. Variables used in expressions must exist in the file.

## 6. Batch build with `$step`, then save and check

```sh
cat > /tmp/build.json <<'JSON'
[
 {"command":"node.create","params":{"type":"frame","name":"Dashboard","x":0,"y":0,"width":1200,"height":800,
   "props":{"fill":"#0E0E10"}}},
 {"command":"node.create","params":{"type":"text","parent":{"$step":0},"x":48,"y":40,
   "text":"Overview","props":{"fontSize":40,"fill":"#FFFFFF"}}},
 {"command":"node.create","params":{"type":"frame","parent":{"$step":0},"x":48,"y":120,"width":1104,"height":240,
   "props":{"fill":"#1A1A1E","cornerRadius":16,"layout":"horizontal","gap":16,"padding":20}}}
]
JSON
figcraft-cli run /tmp/build.json --out /tmp/build.figcraft
figcraft-cli info /tmp/build.figcraft
figcraft-cli export /tmp/build.figcraft -o /tmp/build.png --node "Dashboard" --scale 1
identify /tmp/build.png
```

`{"$step": n}` refers to the id returned by step n. A failing step aborts the script, writes no
output and exits 1 — verified with an invalid node id. `batch` behaves the same inside MCP and is
one undo step.

## 7. Handoff export

```jsonc
// PNG at 2x (600×400 for a 300×200 frame)
{"command":"file.export","params":{"ids":[<frame>],"format":"png","scale":2,"path":"/tmp/shot@2x.png"}}
// or by width
{"command":"file.export","params":{"ids":[<frame>],"format":"png","size":"512w","path":"/tmp/shot-512.png"}}
// SVG with real, selectable text (the default outlines text)
{"command":"file.export","params":{"ids":[<frame>],"format":"svg","svgOutlineText":false,"path":"/tmp/shot.svg"}}
// one PDF page per top-level frame on the page
{"command":"file.exportFramesPdf","params":{"path":"/tmp/all-frames.pdf"}}
// one file per export setting
{"command":"export.add","params":{"ids":[<frame>],"setting":{"size":"2x","format":"png","suffix":"@2x"}}}
{"command":"file.exportLayers","params":{"ids":[<frame>],"dir":"/tmp/export"}}
// experimental whole-file .fig
{"command":"file.export","params":{"format":"fig","path":"/tmp/file.fig"}}
```

The default format is PNG; `scale` is capped at 64. Without `ids`, export uses the selection, then
the page — deselect (`select.none`) when you mean the page. PDF with `ids` is one page; use
`file.exportFramesPdf` or the CLI for multi-page. Validate outside FigCraft: `identify`,
`pdfinfo`, `pdftotext`, `file`, `unzip -l`.

## 8. Import an SVG or an image, then edit it

```jsonc
{"command":"file.import","params":{"path":"/tmp/shapes.svg","x":700,"y":700}}
// → an editable frame named after the file, with shapes/text/gradients/masks (warnings list what was dropped)
{"command":"file.placeImage","params":{"path":"/tmp/photo.png","x":0,"y":300}}
// → {id, image:"<hash>", width, height, imageProfile}
{"command":"fill.set","params":{"ids":[<frame>],"paint":{"type":"image","image":"<hash>","scaleMode":"fill"}}}
{"command":"image.adjust","params":{"ids":[<frame>],"preset":"vivid"}}
```

`file.import` also accepts base64 (`data` + `name`), `.figcraft`, FigCraft/REST `.json`, and `.fig`
best effort. Images open as a document when passed to `open_file`; use `file.placeImage` inside the
current document.

## 9. Code handoff

```jsonc
{"command":"inspect.code","params":{"id":<frame>,"language":"react"}}
{"command":"inspect.code","params":{"id":<frame>,"language":"css","unit":"rem","rootFontSize":16}}
{"command":"inspect.properties","params":{"id":<frame>,"colorFormat":"rgb"}}
{"command":"inspect.assets","params":{"ids":[<frame>]}}
{"command":"inspect.componentCode","params":{"id":<component>,"language":"react"}}
{"command":"node.set","params":{"ids":[<frame>],"devStatus":"readyForDev"}}
{"command":"inspect.readyForDev","params":{}}
```

`language` is the key. `format:"react"` is silently ignored and returns CSS. `html`, `react` and
`leptos` render the whole layer tree; `css` and `swiftui`/`compose` work per layer. `inspect.assets`
lists export settings, small vector icons and images; `file.exportLayers {assets:true}` writes them.

## 10. Drive the live window (attached mode)

```sh
ss -ltn | grep 47801 || figcraft --control 47801 &     # start only if the port is free
# in MCP: figcraft-cli mcp --attach 47801
```

```jsonc
{"name":"inspect_ui","arguments":{}}                    // windows, panels, tool, view, timings
{"name":"screenshot","arguments":{"window":true}}       // 1440×900 PNG of the app window
// click the middle of a frame at page (200,200)-(440,360)
{"name":"pointer","arguments":{"kind":"click","x":260,"y":260}}
{"name":"pointer","arguments":{"kind":"click","x":560,"y":260,"shift":true}}   // add to selection
// drag: from page point to page point, `to` is an [x, y] array
{"name":"pointer","arguments":{"kind":"drag","x":260,"y":260,"to":[340,300],"steps":10}}
// keyboard shortcut then click creates a rectangle with the rectangle tool
{"name":"key","arguments":{"key":"R"}}
{"name":"pointer","arguments":{"kind":"click","x":900,"y":600}}
// text tool: click, type, commit
{"name":"pointer","arguments":{"tool":"text","kind":"click","x":900,"y":700}}
{"name":"type_text","arguments":{"text":"Typed on canvas"}}
{"name":"key","arguments":{"key":"Escape"}}
```

Verified on a fresh window: click selected `[2]`; shift-click `[2,3]`; marquee selected both; a
drag of (80,40) moved the frame exactly 80/40; at 50% zoom the same page coordinates still hit the
frame; `R`+click created a rectangle; the text tool + `type_text` + `Escape` created a text layer;
`Delete` removed the selected frame; `Cmd+,` opened preferences and `Escape` returned to the canvas.

If the very first click after launch selects nothing, repeat it once before suspecting the
coordinates: in one run the first click was swallowed (probably window activation), and identical
clicks immediately afterwards worked.

**Wayland warning:** if the window is covered or minimised the compositor stops drawing it and
UI-dependent requests wait, then fail with `timed out waiting for the UI: screenshots and input need
the FigCraft window on screen (is it minimised or covered?)`. In one run, after such a timeout, the
control channel stopped answering even `initialize` until the app was restarted. Keep the window in
front, or stay headless. Never kill a FigCraft you did not start.

## 11. Template → edit → save a copy (safe)

```jsonc
{"command":"template.list","params":{}}                       // 8 templates
{"command":"file.newFromTemplate","params":{"template":"mobile-app"}}   // → {index, template}
{"command":"select.byName","params":{"query":"Welcome"}}
{"command":"text.set","params":{"id":<title>,"characters":"Your trip"}}
{"command":"file.saveAs","params":{"path":"/tmp/my-mobile-app.figcraft"}}
```

Templates: `mobile-app` (4 screens, components, prototype flow), `landing-page`, `dashboard`,
`design-system`, `wireframe-kit`, `social-posts`, `slides`, `icon-set`. All eight opened, saved and
rendered in the test run (110–986 ms each). `file.newFromTemplate` opens a new unsaved document;
save to a new path or you will be editing the template in memory only. `file.new` also opens a new
tab instead of resetting the current document.

## 12. Reopen and verify what you saved

```sh
figcraft-cli info /tmp/build.figcraft --json     # nodes, pages, frames, styles, variables, missingFonts
unzip -l /tmp/build.figcraft                      # document.json + thumbnail.png
figcraft-cli render /tmp/build.figcraft -o /tmp/check.png
identify /tmp/check.png
```

```jsonc
{"name":"open_file","arguments":{"path":"/tmp/build.figcraft"}}   // → {document, opened:{index, summary, repairs}}
{"name":"inspect_document","arguments":{"allPages":true}}
{"name":"save_file","arguments":{"path":"/tmp/build-copy.figcraft"}}
```

Ids, styles and variables survive a native save/reopen (verified: same frame id and name, 1 style,
1 variable collection). Opening a file that is already open returns only its `index` — no summary.
