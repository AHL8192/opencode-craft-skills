# Recipes — DeckCraft 0.9.0

Every recipe below is raw surface: MCP tool calls (`tools/call`) or
`deckcraft-cli run --cmd`. Verified 2026-10-22 against 0.9.0.

Coordinates are points on a 960 × 540 slide. Slide indices are 0-based.
`slide.new` inserts **after the current slide**, so a fresh deck's first
`slide.new` lands at index 1.

## 1. New deck with a title slide

```json
{"tool":"new_presentation","args":{"theme":"Harbor"}}
```
```json
{"tool":"add_slide","args":{"layout":"title","title":"Q3 results","body":"Prepared for the board"}}
```
`new_presentation` with no `blank` gives one empty title slide. `blank:true`
gives **0 slides** — then `add_slide` starts at index 0.

CLI:

```sh
deckcraft-cli run --cmd 'file.new={"theme":"Harbor"}' \
  --cmd 'slide.new={"layout":"title","title":"Q3 results","body":"Prepared for the board"}' \
  --save q3.deckcraft
```

## 2. Content slide with bullets and levels

`body` or `text.set` uses `\n` for paragraphs and **leading tabs** for levels.

```json
{"tool":"add_slide","args":{"layout":"titleAndContent","title":"Agenda",
  "body":"Revenue\n\tNorth\n\tSouth\nCosts\nOutlook"}}
```

## 3. Add shapes, then format them

```json
{"tool":"add_shape","args":{"preset":"roundRect","x":80,"y":160,"w":320,"h":120,"text":"Revenue"}}
{"tool":"run_command","args":{"command":"shape.fill","params":{"gradient":{"stops":[[0,"2E6FD8"],[1,"F26B1D"]],"angle":45}}}}
{"tool":"run_command","args":{"command":"shape.line","params":{"color":"1E2B3C","width":2,"dash":"dash","tail":"triangle"}}}
{"tool":"run_command","args":{"command":"shape.effects","params":{"shadow":"outer","glow":{"color":"00FFFF","radius":8}}}}
```

`add_shape` selects the new shape; the following commands act on the selection.
For other shapes use `ids:[…]` (same slide) or `edit.select {"ids":[…]}`.

## 4. Process diagram with connectors

```json
{"tool":"add_shape","args":{"preset":"roundRect","x":80,"y":220,"w":180,"h":90,"text":"Plan"}}
{"tool":"add_shape","args":{"preset":"roundRect","x":390,"y":220,"w":180,"h":90,"text":"Build"}}
{"tool":"add_shape","args":{"preset":"roundRect","x":700,"y":220,"w":180,"h":90,"text":"Ship"}}
{"tool":"run_command","args":{"command":"shape.connect","params":{"from":<id1>,"to":<id2>,"preset":"bentConnector3"}}}
```

Connectors stay glued: `shape.connect {from, to, fromSite?, toSite?}`; sites
come from `shape.sites {id}`. Merge/group with `shape.merge` / `arrange.group`.

## 5. Table with style and shading

```json
{"tool":"insert_table","args":{"rows":3,"cols":3,"data":[["Region","Q2","Q3"],["North","10","12"],["South","7","9"]],"x":80,"y":300,"w":800}}
{"tool":"run_command","args":{"command":"table.style","params":{"style":"medium2-accent1"}}}
{"tool":"run_command","args":{"command":"table.options","params":{"headerRow":true,"bandedRows":true}}}
{"tool":"run_command","args":{"command":"table.cellFill","params":{"color":"FFEEAA","cells":[[0,0],[0,1],[0,2]]}}}
{"tool":"run_command","args":{"command":"table.borders","params":{"which":"outside","color":"333333","width":2}}}
```

The table is selected after `insert_table`, so `table.*` needs no id.

## 6. Chart

```json
{"tool":"insert_chart","args":{"type":"line","categories":["Q1","Q2","Q3"],
  "series":[{"name":"Revenue","values":[10,20,30]},{"name":"Costs","values":[8,12,15]}],"title":"Trend"}}
{"tool":"run_command","args":{"command":"chart.options","params":{"legend":"b","dataLabels":true,"gridlines":true}}}
{"tool":"run_command","args":{"command":"chart.type","params":{"type":"bar"}}}
```

Unknown chart types fall back to Clustered Column **without an error**.

## 7. Text formatting without an edit caret

Select shapes (or leave the new one selected), then format. Formatting a
placeholder's text works the same way.

```json
{"tool":"add_shape","args":{"preset":"rect","x":80,"y":80,"w":400,"h":120,"text":"Headline"}}
{"tool":"run_command","args":{"command":"format.size","params":{"size":32}}}
{"tool":"run_command","args":{"command":"format.bold","params":{"on":true}}}
{"tool":"run_command","args":{"command":"format.color","params":{"color":"accent2"}}}
{"tool":"run_command","args":{"command":"format.state","params":{}}}
```

To edit inside a text box, enter edit mode first:

```json
{"tool":"run_command","args":{"command":"text.edit","params":{"id":262}}}
{"tool":"type_text","args":{"text":"new words"}}
{"tool":"run_command","args":{"command":"text.exit","params":{}}}
```

## 8. Theme, variant, background

```json
{"tool":"run_command","args":{"command":"design.theme","params":{"name":"Nocturne"}}}
{"tool":"run_command","args":{"command":"design.variant","params":{"index":2}}}
{"tool":"run_command","args":{"command":"design.background","params":{"color":"121826","all":true}}}
```

`design.themes` lists 8 themes with colour/font schemes. `design.colors` and
`design.fonts` create a custom scheme.

## 9. Notes, comments, sections

```json
{"tool":"run_command","args":{"command":"slide.notes","params":{"text":"Open with the headline number."}}}
{"tool":"run_command","args":{"command":"comment.add","params":{"text":"Check this figure","x":120,"y":170}}}
{"tool":"run_command","args":{"command":"section.add","params":{"name":"Results"}}}
{"tool":"run_command","args":{"command":"comment.list","params":{"slide":1}}}
```

`comment.list` defaults to the **current** slide. `section.add` splits after the
current slide and leaves a `Default Section` behind when the deck had none.

## 10. Transition and animation

```json
{"tool":"run_command","args":{"command":"transition.set","params":{"kind":"morph","duration":750}}}
{"tool":"run_command","args":{"command":"animation.set","params":{"effect":"fade"}}}
{"tool":"run_command","args":{"command":"animation.add","params":{"effect":"fly","start":"afterPrevious","duration":500}}}
{"tool":"run_command","args":{"command":"animation.get","params":{}}}
{"tool":"run_command","args":{"command":"transition.applyAll","params":{}}}
```

49 transitions (`transition.list`); animation effects come from
`animation.list`. `animation.set` replaces the selected shapes' animations;
`animation.add` appends.

## 11. Export everything

```json
{"tool":"export","args":{"path":"out/deck.pdf","format":"pdf"}}
{"tool":"run_command","args":{"command":"file.export","params":{"path":"out/handouts.pdf","format":"pdf","layout":"handouts","perPage":6,"paper":"a4"}}}
{"tool":"run_command","args":{"command":"file.export","params":{"path":"out/notes.pdf","format":"pdf","layout":"notes"}}}
{"tool":"run_command","args":{"command":"file.export","params":{"path":"out/slide.png","slide":1,"scale":2,"transparentBackground":true}}}
{"tool":"run_command","args":{"command":"file.export","params":{"path":"out/all.png","all":true,"scale":1}}}
{"tool":"run_command","args":{"command":"file.export","params":{"path":"out/deck.gif","format":"gif","width":"large","secondsPerSlide":2,"loop":true}}}
{"tool":"run_command","args":{"command":"file.export","params":{"path":"out/outline.md"}}}
```

Hidden slides are skipped by PDF, GIF, outline and `all` PNG unless
`includeHidden:true` (PDF only). `all:true` writes `<base>1.png`, `<base>2.png`, …
(1-based), not the exact path you gave.

## 12. Open a .pptx, change it, save as .pptx

```json
{"tool":"open_presentation","args":{"path":"incoming.pptx"}}
{"tool":"go_to_slide","args":{"index":0}}
{"tool":"set_text","args":{"id":<title id>,"text":"Revised title"}}
{"tool":"save_presentation","args":{"path":"outgoing.pptx"}}
```

`open_presentation` reports `damagedMedia`, `lostSlides` and `missingFonts`.
Read those arrays: they are the only warning that something did not survive.
Saving always writes the whole deck; there is no incremental save.

## 13. Build slides from a Markdown outline

```json
{"tool":"run_command","args":{"command":"slide.fromOutline","params":{
  "text":"# Q3\n## Revenue\n- North\n- South\n## Costs\n- Cloud","markdown":true}}}
```

Headings become slides, list items become bullets. A leading `#` level becomes
a title slide; `##` becomes title-and-content.

## 14. Verify what you made

```json
{"tool":"inspect_document","args":{}}
{"tool":"inspect_slide","args":{"index":1}}
{"tool":"run_command","args":{"command":"shape.inspect","params":{"id":262}}}
{"tool":"render_slide","args":{"slide":1,"scale":1}}
{"tool":"run_command","args":{"command":"slide.colorAt","params":{"slide":1,"x":100,"y":200}}}
```

`inspect_slide` gives boxes, text, fill kind, chart data and table cells.
`shape.inspect` gives the full model (gradient stops, effects, run formatting)
but **only for shapes on the current slide**. `slide.colorAt` reads the rendered
pixel — a cheap way to prove a fill/theme actually drew.

## 15. Drive the live window

```sh
deckcraft --control 7990 &
deckcraft-cli mcp --connect 127.0.0.1:7990
```

```json
{"tool":"call_app","args":{"method":"ui.inspect"}}
{"tool":"call_app","args":{"method":"ui.pointer","params":{"events":[{"kind":"down","x":150,"y":150},{"kind":"up","x":150,"y":150}]}}}
{"tool":"type_text","args":{"text":"typed into the selected shape"}}
{"tool":"call_app","args":{"method":"ui.set","params":{"zoom":2.0}}}
{"tool":"call_app","args":{"method":"ui.dialog.close","params":{"id":"dateTime"}}}
{"tool":"screenshot","args":{}}
```

`ui.pointer` takes **slide points**, not screen pixels, and maps through the
current zoom. `ui.click`/`ui.move`/`ui.drag` take screen points and reach every
widget. Dialogs opened by a command can be closed with `ui.dialog.close`; Escape
and Enter through `ui.key` did not dismiss them in testing (see bugs).

## 16. Batch with partial failure

```json
{"tool":"batch","args":{"commands":[
  {"command":"slide.new","params":{"title":"A"}},
  {"command":"shape.insert","params":{"preset":"nonsense","rect":[10,10,10,10]}},
  {"command":"slide.new","params":{"title":"B"}}
],"keepGoing":true}}
```

Without `keepGoing`, the batch stops at the first error. With it, keep going and
inspect every result: a failed command leaves the deck unchanged, but later ones
still run.
