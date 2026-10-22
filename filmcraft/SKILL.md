---
name: FilmCraft
description: Use whenever working with FilmCraft on this machine — the Rust video editor and Premiere Pro alternative — including creating, editing, trimming, colouring or exporting sequences and projects (.fcproj, MP4/MOV/MXF, PNG/TIFF/GIF, WAV/AIFF/AAC, XML/FCPXML/OTIO/EDL/AAF/OMF, SRT/VTT/SCC), driving the running desktop window, or using its MCP server, filmcraft-cli or control channel. Triggers on "FilmCraft", "filmcraft-cli", "filmcraft mcp", "FilmCraft MCP", "edit this video", "build a sequence", "cut this clip", "add a transition/effect/caption", "export to MP4/ProRes/DNxHR", "export XML for Premiere", "take a FilmCraft screenshot", "drive the FilmCraft window", and requests to automate video editing or FilmCraft itself. Invoke with @filmcraft.
---

# FilmCraft — agent operation

FilmCraft is a native Rust video editor (Premiere Pro-class) whose agent interface
is built in: **every action is a command with an id**. Menus, shortcuts, panels,
timeline gestures, the CLI, the control channel, the MCP server and the GUI all
drive one engine. Everything below was verified against **0.10.0** on 2026-10-22;
treat the docs in the repository as design notes and re-check with *Maintenance*.

## Machine snapshot (verified 2026-10-22)

| Thing | Value |
|---|---|
| App | `/usr/bin/filmcraft` — `filmcraft 0.10.0` |
| CLI | `/usr/bin/filmcraft-cli` — `filmcraft-cli 0.10.0` |
| Install | Debian package `filmcraft` `0.10.0-1` (`dpkg -S /usr/bin/filmcraft`) |
| Data dir | `~/.local/share/filmcraft` — `preferences.json`, `workspaces.json`, `Recovery/`, `Logs/`, `models/` |
| Log | `~/.local/share/filmcraft/Logs/filmcraft.log` (+ `.1`, `.2`) |
| Preview cache | `/tmp/FilmCraft Previews/<project>-<pid>-<hash>/` |
| TTS output | `/tmp/FilmCraft/Narrations/` by default |
| Control port | loopback only; docs use 9876, the probes here used **7991** |
| Commands | **701 in 42 namespaces** |
| Effects | **130 video effects**, **112 video transitions**, 3 audio transitions |
| Validators here | no ffmpeg/ffprobe/mediainfo — GStreamer, ImageMagick, `file`, PIL, VLC |

## Mental model

- A **project** (`.fcproj`, JSON) holds bins and items: `Movie`, `Audio`, `Image`,
  `Sequence`, `Multi-Camera Source Sequence`. `project_inspect` returns the tree,
  `activeSequence` and the dirty flag. One sequence is **active**; commands act on it.
- A **sequence** has `video[]` and `audio[]` track arrays, each
  `{id, name, items[], transitions[], muted, locked, ...}`. A **clip** is
  `{clip, item, name, start, duration, startFrame, durationFrames, sourceIn,
  sourceOut, speed, reverse, enabled, link, gainDb, effects[]}` — all times in ticks.
- **Placing** a movie creates **two linked clips** (video + audio) with different
  ids and `link` pointing at each other. Selecting one selects both by default.
- **Time** is integer ticks, **254,016,000,000 per second** (also 48000×5292).
  `seconds` and `frame` are snapped to the frame grid; `frame` and `timecode`
  (e.g. `"00:00:02:12"`, or `;` for drop-frame) map exactly. Prefer `frame` when
  you need an exact cut.
- A **command** is `{"id": "timeline.razor", "params": {...}}`. `command_list`
  finds ids and parameter docs; `command_run` executes one (undoable);
  `command_batch` runs several. Invalid parameter *types* and unknown commands
  fail; unknown parameter *names* are silently ignored (see *Pitfalls*).
- **Verify by reading back** (`sequence_inspect`, `project_inspect`,
  `captions.list`, `media.status`, `jobs.list`) or by rendering (`render_frame`,
  `file.exportFrame`). A `null` result means "ran", not "did what you meant".

## Two connection modes

| Mode | Start | Use for |
|---|---|---|
| Headless | `filmcraft-cli mcp` (`--demo`, `--project p.fcproj`, `--data-dir d`) | no window, batch builds, exports, scripts |
| App bridge | `filmcraft --control 7991 --control-input-only` + `filmcraft-cli mcp --bridge 127.0.0.1:7991` | the real window: UI state, screenshots, clicks, keys, drags, GUI-only commands |

Both are registered in `~/.config/opencode/opencode.json` as `filmcraft` and
`filmcraft-app`; in OpenCode they appear as `tools.filmcraft.*` and
`tools["filmcraft-app"].*`. `--control-input-only` makes the app accept widget
input **only** from the control server, so the agent can click safely without
taking over the user's mouse. Give the app its own port and (ideally)
`--data-dir` when the user's instance may be running.

```sh
filmcraft --control 7991 --control-input-only &
filmcraft-cli mcp --bridge 127.0.0.1:7991      # MCP to that window
ss -ltn | grep 7991                            # is it up?
```

## The 17 MCP tools

| Tool | Purpose |
|---|---|
| `command_list` | every command (`filter`, `enabled_only`) |
| `command_run` | run one `{id, params}` |
| `command_batch` | run `{steps:[{id,params}], stop_on_error}` → `{completed, failed, results}` |
| `doc_inspect` | project tree + active sequence in one call |
| `project_inspect` | tree, items, active sequence, dirty |
| `sequence_inspect` | active sequence: settings, tracks, clips, transitions, markers |
| `media_import` | import files by absolute path (`paths`, `bin`, `image_sequence`) |
| `render_frame` | PNG at `seconds` (or playhead), `max_side` |
| `render_preview` | same as `render_frame` (bridge: Program monitor) |
| `ui_inspect` | window/UI state (tool, workspace, selection, dialog, playback, elements count) |
| `ui_elements` | on-screen elements with id, label and rect (`prefix`) |
| `ui_click` | click by `id` or `x,y` (`button`, `count`, `modifiers`) |
| `ui_drag` | press–move–release between points or element ids (`steps`) |
| `ui_key` | key or shortcut (`Space`, `Cmd+Z`, `Shift+Delete`) |
| `ui_type` | type into the focused field |
| `ui_screenshot` | PNG of the window or one `panel` |
| `ui_control` | any control method: `ui.set`, `ui.menu.list`, `ui.playback`, … |

Resources: `filmcraft://document` (48 KB JSON: project + sequence) and
`filmcraft://commands` (192 KB catalog). No prompts.

## Standard workflow

1. **Probe.** `project_inspect` / `doc_inspect`; headless starts empty unless
   `--demo` or `--project`. `ui_inspect` first in bridge mode.
2. **Build.** `file.newProject` → `file.import` (absolute paths) or
   `file.importDemoFootage` → `file.newSequence` → `timeline.place`.
3. **Cut.** `playhead.set` + `timeline.razor`, `timeline.trim`, `timeline.slip`,
   `timeline.move`, `edit.clear` / `edit.rippleDelete`.
4. **Style.** `effects.apply` + `effects.setParam`; `sequence.applyVideoTransition`;
   `lumetri.applyPreset`; `graphics.newText`; `markers.add`; `captions.add`.
5. **Verify.** Read `sequence_inspect`/`captions.list`; `render_frame` at a
   telling time and look at the PNG (this catches wrong clips, black frames and
   missing transitions that no read-back shows).
6. **Export.** `file.exportMedia` with `wait:true` (check `offlineMedia` and the
   written file); `file.exportInterchange` for NLE round-trips.
7. **Save.** `file.saveAs` (creates dirs? **no** — the parent must exist); then
   re-read `project_inspect.dirty` (false after save).

## Finding commands

`command_list {filter:"razor"}` matches id, label, menu and params. `filmcraft-cli
commands razor`, `describe <id>` and `filmcraft-cli inspect` do the same from a
shell. All 701 ids with their parameter docs are in `references/commands.md`;
verified step-by-step JSON is in `references/recipes.md`.

Start with: `file.newProject`, `file.import`, `file.newSequence`,
`timeline.place`, `timeline.razor`, `timeline.trim`, `timeline.slip`,
`timeline.move`, `timeline.select`, `edit.clear`, `edit.rippleDelete`,
`edit.undo`, `effects.apply`, `effects.setParam`,
`sequence.applyVideoTransition`, `sequence.setTransition`, `markers.add`,
`captions.newTrack`, `captions.add`, `graphics.newText`, `file.exportMedia`,
`file.exportInterchange`, `file.exportFrame`, `file.saveAs`.

## Pitfalls that cost time

1. **Command params are lenient — unknown keys and some wrong types are
   silently dropped.** `timeline.trim {seconds:-1}` returns `{"delta":0}` (the
   key is `delta`); `timeline.place {seconds:"2"}` places at 0; `fps:"fast"`
   falls back to 23.976. Some commands do validate (`graphics.set`,
   `markers.add`), so never rely on an error to catch a bad param. Read the
   param doc, then read the state back.
2. **`file.newSequence` switches the active sequence** and returns
   `{sequence: id}`. `sequence.open` wants `{item: id}` — passing `sequence` or a
   clip id errors. After any open/new, re-read `sequence_inspect`.
3. **Transitions are not on the clip.** They live in
   `sequence_inspect.video[i].transitions[]` as
   `{id, effect, from, to, start, duration, align, reverse, params}`.
   `sequence.removeTransition {transitions:[id]}`; `sequence.setTransition` edits
   duration/align/params.
4. **Captions are not in `sequence_inspect`.** Use `captions.list`; cues carry
   `id, start, end, text`. `captions.newTrack` silently falls back to `Subtitle`
   for any unknown format string.
5. **Never pass a directory to `file.exportMedia`.** It hangs indefinitely
   (reproduced twice, >3 min, no output). Use a full file path.
6. **The format wins over the extension.** `format:"gif"` with `out.mp4` writes
   `out.mp4.gif`; ProRes with `out.mp4` writes `out.mp4.mov`. The result's `path`
   is authoritative.
7. **`timeline.place` with `duration` longer than the source holds the last
   frame** for the rest of the clip, without warning. Trim with media in mind.
8. **`range:"inOut"` with no marks exports the whole sequence**, silently.
   `range:"custom"` + `startSeconds`/`endSeconds` is the reliable sub-range.
9. **`jobs.list` is a command, not a tool.** `command_run {id:"jobs.list"}`;
   `jobs.cancel {job}` removes the partial file. `wait:false` exports return
   `{job, path, poll, cancel}`.
10. **Demo footage is synthetic.** Interchange exports (FCPXML/AAF/OMF) of demo
    media lose clips; with real on-disk media they round-trip (see
    `references/formats-and-roundtrip.md`).
11. **`edit.clear` (Backspace) leaves a gap; `edit.rippleDelete` closes it.**
    `sequence.lift`/`extract` need sequence in/out marks, not a selection.
12. **`lumetri.applyPreset` appends a new Lumetri effect** each time instead of
    replacing the previous look. Remove the old effect or set params directly.
13. **GUI-only commands are invisible to `command_list`**: `window.workspace.
    {editing,assembly,color,effects,audio}`, `window.workspace.reset`,
    `window.toggleFullScreen`, `app.about`. They exist only on the bridge.
14. **HEVC export is unavailable here** ("no encoder registered"). H.264,
    ProRes, DNxHR, MJPEG, MXF, image sequences and audio all work.
15. **`prefs.set` in a headless session is session-scoped** — it did not persist
    across two `--data-dir` sessions. Use the GUI for durable preferences.
16. **MCP tool arguments are strict** (unknown key → JSON-RPC `-32602`; wrong
    type → `isError` with a deserialize message), but `command_run.params` is
    passed through untouched.

## Reference map

| File | Contents |
|---|---|
| `references/recipes.md` | verified JSON for build, cut, effects, colour, captions, graphics, proxies, multicam, TTS, export, GUI |
| `references/commands.md` | all 701 commands, grouped by namespace, with parameter docs |
| `references/mcp-and-control.md` | MCP details, error shapes, resources, control methods, GUI-only commands |
| `references/cli.md` | `filmcraft-cli` subcommands, flags, exit codes, offline media, headless jobs |
| `references/formats-and-roundtrip.md` | export matrix + independent validation, interchange round-trips |
| `references/bugs-and-workarounds.md` | every reproduced defect with a minimal reproduction |
| `references/maintenance.md` | re-verify the version, dump commands, refresh this skill |
| `scripts/probe.sh` | MCP handshake + tool count + version |
| `scripts/dump-commands.sh` | regenerate the command catalog |
| `scripts/smoke-test.sh` | build → render → export → independent validation |

Community: <https://discord.gg/artcraft> · <https://getartcraft.com/apps/filmcraft>
· <https://github.com/storytold/filmcraft>.
