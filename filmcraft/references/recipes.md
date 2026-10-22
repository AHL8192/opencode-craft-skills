# FilmCraft recipes (verified on 0.10.0, 2026-10-22)

Every block below was run against the real engine (headless unless marked
**bridge**) and the result is what the engine returned. Times are ticks unless a
key says `seconds`/`frame`; `SEC = 254016000000`.

Common helper used throughout:

```python
def run(id, params=None):        # command_run over MCP stdio
    return call("command_run", {"id": id, "params": params or {}})   # unwrap text JSON
def sq(): return call("sequence_inspect", {})
def proj(): return call("project_inspect", {})
```

## 1. New project → sequence → first clip → render → export

```jsonc
{"id":"file.newProject","params":{"name":"Demo"}}                       // null
{"id":"file.importDemoFootage","params":{"scene":"CityNight"}}          // {"items":[1]}
{"id":"file.newSequence","params":{"name":"Main","width":1280,"height":720,"fps":24,"video":3,"audio":2}}
                                                                        // {"sequence":7}  (and it is now active)
{"id":"timeline.place","params":{"item":1,"track":"V1","seconds":0,"duration":1016064000000}}
                                                                        // {"clips":[9,10]}  video 9 + linked audio 10
```

`render_frame {seconds: 1.0, max_side: 640}` → PNG content block (640×360).
`file.exportMedia {path:"/abs/out.mp4","format":"h264","wait":true}` →
`{job,path,offlineMedia:[],result:{bytes,frames,render_fps,seconds}}`; the job's
`path` is authoritative (extension may be corrected).

Demo scenes: `OceanSunset | Aurora | CityNight | Dunes | Plasma | Forest`
(each synthetic, ~14 s, 1280×720; `media.status` reports `"status":"generated"`).

## 2. Real media, bins, save and reopen

```jsonc
{"id":"file.import","params":{"paths":["/abs/proof.mp4","/abs/audio.wav"]}}   // {"errors":[],"items":[1,2]}
{"id":"file.newBin","params":{"name":"Selects"}}                             // {"bin":3}
{"id":"project.moveToBin","params":{"items":[1],"bin":3}}                    // {"moved":1}
{"id":"file.saveAs","params":{"path":"/abs/proj.fcproj"}}                    // parent dir must exist
{"id":"file.open","params":{"path":"/abs/proj.fcproj"}}                      // damages -> error names the column
```

`project_inspect` after save: `dirty:false`, `path`, `revision`. A damaged
project fails cleanly: `…: project file is damaged: EOF while parsing an object
at line 1 column 18`. A `.fcproj` that is valid JSON but not a project is
refused with a schema/format error.

## 3. Cutting: razor, trim, slip, move, delete

```jsonc
{"id":"playhead.set","params":{"frame":48}}                 // exact; seconds snap
{"id":"timeline.razor","params":{"track":"V1","time":1016064000000}}   // {"cuts":[ ... ]}
{"id":"timeline.trim","params":{"clip":9,"edge":"out","mode":"regular","delta":-254016000000}}  // {"delta":…}
{"id":"timeline.slip","params":{"clip":9,"delta":127008000000}}        // null; sourceIn += delta
{"id":"timeline.rateStretch","params":{"clip":9,"edge":"out","delta":254016000000}}  // {"speed":0.8}
{"id":"timeline.move","params":{"moves":[{"clip":9,"track":"V2","time":508032000000}],"linked":true}}  // null
```

- A razor on a linked pair cuts both (audio follows).
- `timeline.trim` takes **`delta`** (or `deltaFrames`), never `seconds`; a wrong
  key is ignored and nothing changes.
- Move with `"insert":true` ripples; without it, overwrite semantics apply and the
  clip underneath can be split/overwritten.
- `edit.clear {clips:[id]}` (Backspace) deletes and **leaves a gap**.
  `edit.rippleDelete {clips:[id]}` deletes and **closes the gap**.
  `sequence.lift` / `sequence.extract` act on sequence in/out marks.
- `edit.undo` / `edit.redo` return `{"undone":"Trim"}` etc. Every placement is
  its own undo step — count carefully when scripting undos.
- After a drag/split, **clip ids change**: the remainder gets a new id. Re-read
  `sequence_inspect` before the next command.

## 4. Selection

```jsonc
{"id":"timeline.select","params":{"clips":[9]}}        // {"selection":[9,10]}  linked audio too
{"id":"timeline.select","params":{"clips":[9],"linked":false}}   // only 9
{"id":"edit.deselectAll","params":{}}                 // null
{"id":"edit.clear","params":{}}                       // errors: nothing selected
```

`sequence_inspect.selection` lists selected **clip** ids. Commands that take
`clips` default to the selection when the key is omitted. Gated commands say so:
`command 'edit.undo' is not available right now: nothing to undo`.

## 5. Effects and parameters

```jsonc
{"id":"effects.apply","params":{"clips":[9],"effect":"Gaussian Blur"}}          // null
{"id":"effects.setParam","params":{"clip":9,"effect":"gaussian_blur","param":"blurriness","value":12}}
                                                                                // {"keyframes":0}
{"id":"effects.setParam","params":{"clip":9,"effect":"gaussian_blur","param":"dimensions","value":"Horizontal"}}
{"id":"effects.addKeyframe","params":{"clip":9,"effect":"gaussian_blur","param":"blurriness","time":0}}   // null
{"id":"effects.setKeyframe","params":{"clip":9,"effect":"gaussian_blur","param":"blurriness","mediaTime":0,"value":30}}
{"id":"effects.remove","params":{"clip":9,"index":0}}
```

- `effects.apply` accepts the display name or the id (`"Gaussian Blur"`,
  `"gaussian_blur"`). Param names are the engine's snake_case (`blurriness`,
  `dimensions`, `repeat_edge`); read them from `effects.list {detail:true}` or from
  `sequence_inspect.video[i].items[j].effects[k].params`.
- Values arrive typed in read-back: `"Float(12.0)"`, `"Choice(1)"`,
  `"Bool(false)"`, curves as `"Curve([[...]])"`.
- Unknown param → clean error; wrong value type → clean error; wrong **key** →
  ignored.
- Built-ins `motion`, `opacity`, `time_remap` are on every clip; indices shift as
  effects are added/removed, so identify by id/name, not index, when scripting.

## 6. Transitions (video and audio)

```jsonc
{"id":"sequence.applyVideoTransition","params":{"clip":9,"effect":"Cross Dissolve","frames":12,"edge":"out"}}
                                                                      // {"transition":16}
{"id":"sequence.setTransition","params":{"transition":16,"frames":24,"align":"start"}}
                                                                      // {duration:254016000000, align:"start", start:…}
{"id":"sequence.applyAudioTransition","params":{"clip":10,"effect":"Constant Power","frames":12,"edge":"out"}}
                                                                      // {"transition":15}
{"id":"sequence.removeTransition","params":{"transitions":[16]}}       // {"removed":1}
```

Read back from the **track**, not the clip or the top level:

```json
"transitions": [{"id":16,"effect":"cross_dissolve","from":9,"to":12,
                 "start":444528000000,"duration":127008000000,
                 "align":"center","reverse":false,"params":{}}]
```

Proof that it renders (not just bookkeeping): with a 12-frame dissolve at 2 s,
`render_frame` at 1.9 s gave a blended frame (mean brightness 0.166) while the same
project with the transition removed matched the no-transition render **exactly**
(RMSE 0). `aligned:"start"` + 24 frames moved `start` from 1.75 s to 2.0 s, i.e.
the transition was rebuilt from the new duration.

## 7. Colour: Lumetri, presets, sequence colour settings

```jsonc
{"id":"effects.apply","params":{"clips":[9],"effect":"Lumetri Color"}}        // null
{"id":"lumetri.presets","params":{}}                                          // 18 presets in 4 folders
{"id":"lumetri.applyPreset","params":{"name":"Golden Dusk","clips":[9]}}      // {"clips":1,"preset":"Golden Dusk"}
{"id":"lumetri.setSection","params":{"clip":9,"section":"basic","on":true}}   // {"on":true,"param":"basic_on"}
{"id":"effects.setParam","params":{"clip":9,"effect":"lumetri","param":"exposure","value":0.5}}
{"id":"sequence.colorSettings","params":{"workingSpace":"rec2100-pq"}}
                                                                              // {workingSpace:"rec2100-pq",wideGamut:false,autoToneMap:true,label:"Rec. 2100 PQ"}
```

- Presets: Cinematic (Teal Shadows Warm Skin, Night Exterior, Golden Dusk, Steel
  Blue, Hard Sun), Film Emulation, Monochrome, Technical.
- `lumetri.setLook` wants a LUT id (`"builtin:<id>"`/`"lib:<id>"`), **not** a
  preset name — `"Golden Dusk"` is rejected. Use `lumetri.applyPreset`.
- `applyPreset` **appends** a Lumetri effect; applying a second preset stacks a
  second effect. Render check: Golden Dusk changed the frame (RMSE 0.065 vs
  before), so it is applied.
- `sequence.colorSettings` validates its enum: `unknown working space 'bogus'`.

## 8. Markers

```jsonc
{"id":"markers.add","params":{"time":254016000000,"name":"Mark A","comment":"first","color":"Rose"}}
                                                                      // {"marker":11}
{"id":"markers.addRange","params":{"seconds":1,"durationFrames":24,"name":"Range","color":"Mango"}}
{"id":"markers.exportCsv","params":{"path":"/abs/markers.csv"}}
{"id":"markers.clearAll","params":{"target":"program"}}
```

Names are `Violet, Iris, Caribbean, Lavender, Cerulean, Forest, Rose, Mango,
Purple, Blue, Teal, Magenta, Tan, Green, Brown, Yellow`; an unknown name errors
with that list. Negative time errors. `markers.add` returns `{"marker":id}`;
read them from `sequence_inspect.markers[]` (`{id,name,comment,color,start,duration,kind}`).
`markers.list` does not exist — the markers are in `sequence_inspect`.

## 9. Captions

```jsonc
{"id":"captions.newTrack","params":{"format":"Subtitle","name":"C1"}}   // {"track":12}
{"id":"captions.add","params":{"track":"C1","text":"Caption one","seconds":0.5,"durationSeconds":1}}
                                                                        // {"caption":13}
{"id":"captions.list","params":{"track":"C1"}}                          // track + cues (ids, in/out, duration)
{"id":"captions.export","params":{"path":"/abs/caps.srt","format":"srt","track":"C1"}}
{"id":"file.exportMedia","params":{"path":"/abs/withcaps.mp4","format":"h264","burnCaptions":true,"wait":true}}
```

- `captions.newTrack` accepts `Subtitle | CEA-608 | CEA-708 | Teletext`; **any
  other string is silently coerced to `Subtitle`** (verified with `SCC2`, `scc`,
  `bogus`, `""`).
- Cues are **not** in `sequence_inspect`; only `captions.list` shows them.
- `captions.export` formats: `srt, vtt, scc, mcc, stl, ttml, dfxp` (extension
  decides when omitted). Exported SRT was valid:
  `1 / 00:00:00,500 --> 00:00:01,500 / Caption one`.

## 10. Graphics and titles

```jsonc
{"id":"graphics.newText","params":{"text":"Probe Title","position":[640,360],"size":90,
                                   "seconds":5,"time":0,"track":1,"font":"Inter"}}   // {"clip":15,"layer":0}
{"id":"graphics.set","params":{"clip":15,"props":{"size":120,"fill_color":"#ffcc00"}}}  // null
{"id":"graphics.newShape","params":{"shape":"rectangle","position":[640,500],
                                    "size":[400,120],"clip":15}}                    // {"layer":1}
{"id":"graphics.list","params":{"clip":15}}                                             // layers, bounds, text
{"id":"masks.add","params":{"clip":9,"effect":"opacity","shape":"ellipse"}}
                                                                                        // {"clip":9,"effect":2,"mask":0,
                                                                                        //  "name":"Mask (1)"}
```

- `graphics.newText` creates a **graphic clip** on a video track (default: above
  the clips at the playhead) — it is a separate clip, not a filter.
- `graphics.set` takes a `props` object; a bad property errors
  (`no property 'nonsense'`), but property **names** are the graphics model's
  (`size`, `fill_color`, `position`, …) — dump `graphics.list` to see them.
- Masks attach to an effect (`opacity` by default) and are listed by `masks.list`.
- Text/graphics are drawn by the compositor: verify with `render_frame`.

## 11. Audio: gain, mixer, TTS

```jsonc
{"id":"clip.audioGain","params":{"clips":[10],"mode":"set","db":-6}}
                                    // {"clips":1,"gainDb":[{"clip":10,"gainDb":-6.0}],"mode":"set"}
{"id":"mixer.setStrip","params":{"strip":"A1","volumeDb":-3,"muted":true}}   // strip state
{"id":"tts.create","params":{"text":"Hello from FilmCraft","voice":"basic-female","dir":"/abs/voice"}}
                                    // {"clip":9,"item":8,"path":"…/Narration 1.wav",
                                    //  "duration":388898496000,"sampleRate":24000}
```

- TTS works with the built-in `basic-female` voice; without `dir` it writes to
  `/tmp/FilmCraft/Narrations/`. `tts.voices` reports `package.available:false`
  (Kokoro natural voices are not installed, 335 MB) but the basic voice is local.
- `transcript.generate` is **not available in this build**: "speech-to-text is not
  available in this build (built without the `whisper` feature); import a
  transcript with `transcript.set` instead". `transcript.models` confirms
  `available:false`.
- `mixer` / `clipMixer` strips are addressed by track name (`A1`) or id.

## 12. Proxies

```jsonc
{"id":"media.proxyPresets","params":{}}                     // prores_proxy_quarter/half/lt, h264_quarter/half
{"id":"media.createProxies","params":{"items":[1],"preset":"h264_quarter","attach":true,"wait":true}}
        // [{"job":1,"outputs":[{"item":1,"path":"<media dir>/Proxies/proof_Proxy.mp4"}],"skipped":[]}]
{"id":"media.status","params":{"item":1}}
        // [{"status":"online","proxy":{"online":true,"path":"…/Proxies/proof_Proxy.mp4"}}]
{"id":"media.toggleProxies","params":{"enabled":true}}      // {"enabled":true,"clipsWithProxies":1}
{"id":"media.detachProxies","params":{"items":[1]}}         // {"detached":1}
```

Proxies are written next to the media in `Proxies/` unless `destination` is given.
`media.status` statuses: `online | offline | missing | generated | unreadable`.

## 13. Multicam

```jsonc
{"id":"clip.createMulticam","params":{"items":[1,2],"name":"MC1","method":"in"}}
   // {"sequence":7,"cameras":["proof.mp4","proof.mp4"],
   //  "clips":[{"item":1,"angle":0,…},{"item":2,"angle":1,…}]}
{"id":"timeline.place","params":{"item":7,"track":"V1","seconds":0,"duration":762048000000}}
   // {"clips":[22,23]}
{"id":"multicam.inspect","params":{}}                        // angle, cameras, sourceTime, recorder
{"id":"multicam.switchAngle","params":{"camera":2,"time":254016000000}}   // {"angle":1,"changed":1}
{"id":"multicam.cutToCamera","params":{"camera":1,"time":381024000000}}   // {"angle":0,"changed":1}
```

`createMulticam` makes a project item of type `Multi-Camera Source Sequence`;
placing it creates one clip that `multicam.inspect` sees. `switchAngle` changes
the angle at the playhead/time; `cutToCamera` writes a cut (the clip list grows,
new ids). `multicam.recordStart/recordStop` and the camera-select commands exist
for recorded switching.

## 14. Export

```jsonc
{"id":"file.exportMedia","params":{"path":"/abs/out.mp4","format":"h264","range":"entire","wait":true}}
{"id":"file.exportMedia","params":{"path":"/abs/out.mov","format":"prores","proresProfile":"hq",
                                    "width":1280,"height":720,"wait":true}}
{"id":"file.exportMedia","params":{"path":"/abs/sub.mp4","format":"h264","range":"custom",
                                    "startSeconds":1,"endSeconds":2.5,"wait":true}}   // 36 frames
{"id":"file.exportMedia","params":{"path":"/abs/frames.png","format":"png","wait":true}}
{"id":"file.exportFrame","params":{"path":"/abs/frame.png","format":"png","time":508032000000,
                                    "target":"program"}}   // {width,height,depth,time,target,path}
{"id":"file.exportInterchange","params":{"format":"xml","path":"/abs/cut.xml"}}
```

- Custom range honoured exactly: 1.0–2.5 s at 24 fps → **36 frames**.
- `inOut` with no marks → **entire sequence** (144 frames for a 6 s sequence).
- Formats: `h264, hevc, prores, dnxhr, apv, mjpeg, mxf-op1a, mxf-opatom, png,
  tiff, bmp, jpg, tga, dpx, exr, gif, wav, aiff, aac, flac`. HEVC here:
  `H.265 (HEVC) export is not available (no encoder registered)`.
- Profiles: `proresProfile` proxy/lt/standard/hq/4444/4444xq; `dnxProfile`
  lb/sq/hq/hqx; `mxfVideoCodec` dnxhr/proRes/h264.
- MXF OP-Atom writes one file per audio track in addition to the video file
  (verified `out_opatom_A1.mxf`, `out_opatom_A2.mxf`).
- `~60 s` for 1920 frames at 480×270 H.264 on this machine; expect slower for
  1080p and effects-heavy timelines (a 144-frame 640×360 demo export took 25 s).
- Offline media: see `references/cli.md` §Offline.

## 15. GUI (bridge) recipes

```jsonc
{"id":"ui_inspect"}                                          // tool, workspace, selection, dialog, playback, 227 elements
{"id":"ui_click","params":{"id":"tools.Razor"}}              // tool becomes "Razor"
{"id":"ui_key","params":{"key":"Space"}}                     // playback.playing true/false
{"id":"ui_elements","params":{"prefix":"timeline.clip."}}    // [{id:"timeline.clip.29",rect:[x,y,w,h],…}]
{"id":"ui_click","params":{"id":"timeline.clip.29"}}         // selects clip + linked partner
{"id":"ui_drag","params":{"from":{"x":912,"y":784},"to":{"x":972,"y":784},"steps":12}}
                                                             // moved clip 1.79 s; overwrite split produced new clip id
{"id":"command_run","params":{"id":"file.newSequence"}}      // opens the Sequence Settings dialog
{"id":"ui_click","params":{"id":"sequenceSettings.ok"}}      // creates "Sequence 03" and makes it active
{"id":"ui_key","params":{"key":"Escape"}}                    // cancels the dialog, no item created
{"id":"ui_key","params":{"key":"Cmd+Z"}}                     // undoes the creation
{"id":"command_run","params":{"id":"window.workspace.color"}}// {"workspace":"Color"} (bridge-only command)
{"id":"ui_control","params":{"method":"ui.set","params":{"workspace":"Editing"}}}
{"id":"command_run","params":{"id":"file.saveAs","params":{"path":"/abs/gui.fcproj"}}}  // dirty -> false
```

- `ui_inspect.elements` is a **count**; use `ui_elements` for the list.
- Element ids are stable within a session: `tools.*`, `timeline.clip.<clipId>`,
  `timeline.transition.<txId>`, `timeline.tab.<seqId>`, `sequenceSettings.ok`.
- Dialog flow: command without params opens the dialog; `ui_click` the OK id or
  `ui_key Escape`; `ui_control {"method":"ui.set","params":{…}}` can fill fields.
- `ui_drag` coordinates are window points; with `--control-input-only` the real
  mouse is untouched.
- Screenshots via `ui_screenshot {panel?}` return image content blocks; save the
  base64 `data` to a file.
- The GUI writes recovery journals into `<data dir>/Recovery/<epoch>-<pid>/`;
  close the app when done and remove only your own entry.
