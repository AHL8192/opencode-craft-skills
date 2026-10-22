# Bugs, footguns and workarounds

Reproduced on `filmcraft 0.10.0` / `filmcraft-cli 0.10.0`, 2026-10-22. Each entry
gives the smallest reproduction and the workaround. Severity is from an agent's
point of view.

## 1. CRITICAL — `file.exportMedia` with a directory hangs forever

**Repro**

```sh
timeout 45 filmcraft-cli --demo exec file.exportMedia \
  '{"path":"/tmp","format":"h264","wait":true}'
echo $?        # 124 (killed; no output, no error, no file)
```

Also reproduced through MCP: `command_run {id:"file.exportMedia", params:{path:
"<existing dir>", format:"h264", wait:true}}` did not return after **more than
3 minutes**. A second, independent run behaved identically.

**Why it matters:** a script or agent that computes `path = out_dir` (instead of
`out_dir + "/name.mp4"`) blocks the MCP session and any `wait:true` call. The
process stays at high CPU.

**Workaround:** always pass a full file path. Validate before exporting:
`[ -d "$OUT" ] && OUT="$OUT/name.mp4"`. Wrap agent-side waits in a timeout and
recover with `jobs.cancel`/process kill.

## 2. HIGH — an export silently rewrites the file name

**Repro**

```jsonc
{"id":"file.exportMedia","params":{"path":"/abs/mismatch.mp4","format":"gif","wait":true}}
```

**Observed:** `GIF image data` written to `/abs/mismatch.mp4.gif`; the result JSON
contains the real path. ProRes with `out.mp4` → `out.mp4.mov`; `out.mxf` with
`format:"prores"` → `out.mxf.mov`.

**Workaround:** read `result.path` from the return value; never assume the path
you passed.

## 3. HIGH — command parameters are lenient: unknown keys and wrong types are dropped

**Repro**

```jsonc
{"id":"timeline.trim","params":{"clip":9,"edge":"out","seconds":-1}}   // wrong key
{"id":"timeline.place","params":{"item":1,"track":"V1","seconds":"2"}} // string, not number
{"id":"file.newSequence","params":{"name":"F","fps":"fast"}}           // bad number
```

**Observed:** all three return success. Trim returns `{"delta":0}` and changes
nothing (the key is `delta`/`deltaFrames`); place puts the clip at **0**, not 2;
newSequence silently uses the default **24000/1001**. Some commands *do* validate
(`graphics.set {fill_color:"notacolor"}` → `value has the wrong type`;
`markers.add` rejects a bad colour), so the behaviour is inconsistent
per command.

**Workaround:** copy parameter names and types from `references/commands.md` (or
`command_list`), and always verify with `sequence_inspect`. Treat `null`/`{}` as
"the command ran", not "it changed something".

## 4. HIGH — `file.newSequence` switches the active sequence

**Repro:** build a sequence, then `file.newSequence {name:"S2"}`; afterwards
`timeline.place` lands in S2, not the timeline you inspected a moment ago.

**Observed:** the new sequence is active and returned as `{sequence:id}`; the
previous sequence keeps its clips. `sequence.open` then needs `{item:id}`, not
`{sequence:id}` (passing `sequence` errors: `need 'item'`).

**Workaround:** call `sequence.open {item:<id>}` after creating anything, and
re-read `sequence_inspect` before editing.

## 5. HIGH — `timeline.place` with an over-long duration freezes the last frame

**Repro:** import a 3 s file, place it with `duration: 10*SEC`.

**Observed:** a 10 s clip is created without warning; rendering at 4 s and 8 s
produced **identical** frames (RMSE 0), i.e. a 7 s freeze. Frames at 2.8 s and 4 s
differ (RMSE 0.016).

**Workaround:** clamp `duration` to the source duration (or deliberately use
`clip.frameHold`). For stills, `prefs timeline.stillImageDuration` is the
documented default duration.

## 6. MEDIUM — `captions.newTrack` accepts any format string

**Repro**

```jsonc
{"id":"captions.newTrack","params":{"format":"SCC2"}}   // {"track":9}
```

**Observed:** a track is created with `format:"Subtitle"`. Verified with `SCC2`,
`scc`, `bogus` and `""` — all silently become Subtitle. Valid values:
`Subtitle`, `CEA-608`, `CEA-708`, `Teletext`.

**Workaround:** read the created track back with `captions.list` and check
`format`; do not trust the request.

## 7. MEDIUM — `command_batch` marks partial success as an error and double-encodes its report

**Repro**

```jsonc
{"steps":[
  {"id":"playhead.set","params":{"seconds":1}},
  {"id":"no.such.command","params":{}},
  {"id":"playhead.set","params":{"seconds":2}}],
 "stop_on_error":false}
```

**Observed:** `isError:true`, and the text content is a JSON **string**:
`"{\"completed\":2,\"failed\":1,\"results\":[…]}"`. All three steps ran, the
playhead ended at 2 s. With `stop_on_error:true` it stops after the failure but is
still `isError:true`.

**Workaround:** parse the text content a second time; treat `failed>0` as a
per-step issue rather than a failed batch, and check the `results` array. In CLI
`run`, `--keep-going` still exits 1 when any line failed.

## 8. MEDIUM — `lumetri.applyPreset` appends instead of replacing

**Repro:** apply Lumetri, then `lumetri.applyPreset {name:"Golden Dusk"}` twice
(second: `Night Exterior`).

**Observed:** the clip's `effects[]` grows by one `lumetri` entry per preset
(3 built-ins → 4 → 5 → 6). Presets therefore stack, and read-back cannot tell
them apart by name (all show `effect:"lumetri"`).

**Workaround:** remove the previous Lumetri effect (`effects.remove`) before
applying another preset, or set the parameters directly with `effects.setParam`.

## 9. MEDIUM — GUI-only commands are missing from `command_list`

**Repro (bridge):** `command_run {id:"window.workspace.color"}` → success
`{workspace:"Color"}`. `command_list {filter:"workspace"}` → `[]`;
`command_list {namespace:"window"}` → empty.

**Verified bridge-only ids:** `window.workspace.{editing,assembly,color,effects,
audio}`, `window.workspace.reset`, `window.toggleFullScreen`, `app.about`.
Headless rejects them as `unknown command`.

**Workaround:** use `ui_control ui.set {workspace:…}` or the ids above; do not
rely on `command_list` to enumerate GUI capabilities.

## 10. MEDIUM — `prefs.set` does not persist in headless sessions

**Repro**

```sh
filmcraft-cli --data-dir /tmp/fcd mcp   # prefs.set timeline.stillImageDuration = 7.5
filmcraft-cli --data-dir /tmp/fcd mcp   # prefs.get -> 5.0 (default)
```

**Observed:** the value changes within the session (read-back 7.5) but no file is
written to the data dir, and a new session sees the default. The docs say
`prefs.*` "read and change" `<data dir>/preferences.json`.

**Workaround:** treat headless `prefs.set` as session state. For durable
preferences use the app (bridge) or edit `preferences.json` with the app closed.

## 11. LOW — `project.delete` with a nonexistent id gives a misleading error

**Repro:** `project.delete {items:[999999]}`

**Observed:** `command 'project.delete' is not available right now: select an item
in the Project panel` — as if no `items` had been passed, instead of "no such
item". Deleting a valid id works.

**Workaround:** resolve ids from `project_inspect` first; treat the message as
"nothing valid to delete".

## 12. LOW — `timeline.razor` accepts negative times as a no-op

**Repro:** `timeline.razor {seconds:-3}` → `{"cuts":0}` with `isError:false`.
Compare `markers.add {time:-…}` which correctly errors "time must not be
negative".

**Workaround:** clamp and validate times before cutting; check `cuts>0`.

## 13. LOW — `ui_inspect.elements` is a number, `ui_elements` is the list

`ui_inspect {elements: 227}` but `ui_elements` returns `[{id,label,rect}]`. Easy
to write `len(ui_inspect["elements"])` and crash.

**Workaround:** use the count only as a health signal; call `ui_elements` for data.

## 14. LOW — `ui.scroll` does not accept the documented `panel` argument

**Repro:** `ui_control {method:"ui.scroll", params:{panel:"timeline", dx:100}}` →
`app: need 'id' or 'x','y'`. It needs a target element id or coordinates.

**Workaround:** pass `{id:"timeline", dx:…}` or `{x,y,dx,dy}`; or use
`ui.set {timeline:{scroll:…}}`.

## 15. LIMITATION — synthetic demo media breaks FCPXML/AAF/OMF interchange

**Repro:** build a timeline only from `file.importDemoFootage`, export FCPXML,
re-import.

**Observed:** the FCPXML writes clips as `<gap>` with **no `<asset>`/`<asset-clip>`**
and the re-import is an empty sequence (duration 0). Same for AAF/OMF. With real
files on disk, all three round-trip correctly (see
`references/formats-and-roundtrip.md`).

**Workaround:** test interchange with real media; do not use demo footage to judge
format support.

## 16. ENVIRONMENT — HEVC export is unavailable

`file.exportMedia {format:"hevc"}` → `H.265 (HEVC) export is not available (no
encoder registered)`. The docs say HEVC export exists only with a hardware/OS
encoder (VideoToolbox/NVENC). Use H.264, ProRes or DNxHR here.

## 17. NOTE — MXF OP-Atom writes one file per audio track

Exporting `mxf-opatom` produced `out_opatom.mxf` plus `out_opatom_A1.mxf` and
`out_opatom_A2.mxf`. That is correct OP-Atom behaviour but surprises scripts that
expect a single file; collect all files matching the base name.

## 18. NOTE — `sequence_inspect` is an MCP tool, not a command

`command_run {id:"sequence_inspect"}` → `unknown command`. The same is true for
`project_inspect`, `doc_inspect`, `render_frame`, `render_preview`,
`media_import`, `command_list`, `command_run` and `command_batch`. Use the tools
for those; use `sequence.inspect`/`project.inspect` only where they exist as
commands (`sequence.inspect {item?}`, `project.inspect`). Note the different
names and shapes (`project_inspect` tool vs `project.inspect` command).

## 19. NOTE — clipboard and undo are engine-wide

`edit.undo` can undo a placement, a trim, a dialog-created sequence or a clip
deletion, and each placement is its own step. After a scripted sequence of edits,
`edit.undo` may remove something you did not intend. Prefer building in a fresh
project or saving before a risky undo, and read the returned
`{"undone":"Trim"}` label.
