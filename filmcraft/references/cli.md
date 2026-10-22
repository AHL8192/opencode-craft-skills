# filmcraft-cli 0.10.0

`filmcraft-cli` drives the engine with no window (or with `--bridge`, the live
app). Verified 2026-10-22. `filmcraft-cli --version` → `filmcraft-cli 0.10.0`.

## Subcommands

| Command | What it does |
|---|---|
| `exec <id> [key=value …]` | run one command, print its result as JSON |
| `exec <id> '<json params>'` | same, params as one JSON object |
| `run <script.jsonl | ->` | one `{"id","params"}` per line (`#` comments allowed) |
| `commands [filter] [--json]` | list commands (id, label, shortcut, params) |
| `describe <id>` | one command as JSON, including whether it is enabled now |
| `inspect [project|sequence]` | project tree or active sequence (default: both) |
| `import <file>…` | import media into the project |
| `export <out> [flags]` | render the active sequence and wait |
| `export --list-presets [query]` | 39 built-in/user presets as JSON |
| `render --seconds S --out f.png [--scale 0.5] [--allow-offline]` | one frame |
| `probe <media> [--image-sequence]` | media info JSON (MXF, Ogg, BWF details) |
| `bench-decode <media> [--frames N]` | decoder benchmark |
| `mcp` | MCP server on stdio (`--bridge` for the app) |
| `help` / `--version` | usage / version |

Global options: `--project p.fcproj`, `--demo`, `--save`, `--save-as p.fcproj`,
`--bridge 127.0.0.1:PORT`, `--data-dir dir`, `--keep-going`, `--compact`.

## Value parsing

`key=value` parses the value as JSON when it can (`3.5`, `true`, `[1,2]`,
`{"a":1}`), otherwise as a string. So `exec timeline.razor seconds=3.5` passes a
number and `exec file.newBin name=Selects` a string. For anything with spaces or
nesting, use the single-JSON-argument form:

```sh
filmcraft-cli --project p.fcproj exec timeline.place '{"item":1,"track":"V1","seconds":0}'
```

Times: 254016000000 ticks per second; most commands also take `seconds`, `frame`
or `timecode`.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success |
| 1 | a command failed, **or** export/render drew offline media without `--allow-offline` |
| 2 | usage error |

`run` prints one JSON object per line:
`{"id":…,"line":n,"ok":true,"result":…}` or
`{"error":"…","id":…,"line":n,"ok":false}`. Default: stop at the first failure.
`--keep-going` continues, **but the exit code is still 1** if any line failed
(verified). Scripts must parse the line results, not rely on the exit code.

## Export

```sh
filmcraft-cli --project p.fcproj export out.mp4                       # format from extension
filmcraft-cli --project p.fcproj export out.mov --format prores
filmcraft-cli --project p.fcproj export out.mp4 --preset "YouTube 1080p Full HD"
filmcraft-cli --project p.fcproj export out.mp4 --format h264 \
  --range custom --start 1 --end 2.5
filmcraft-cli --project p.fcproj export out.mp4 --format h264 --scale 0.5 --quality 70
filmcraft-cli --project p.fcproj export out.mp4 --format h264 --queue
```

Flags: `--preset`, `--format` (`h264|hevc|prores|dnxhr|apv|mjpeg|mxf-op1a|
mxf-opatom|png|tiff|bmp|gif|wav|aiff|aac`, or guessed from the extension),
`--range entire|inOut|workArea` or `--start/--end` seconds, `--settings <json>`
(merged over the preset), `--scale`, `--quality 0-100`, `--no-audio`,
`--queue`, `--gpu-rendering auto|off`, `--allow-offline`.

- The written **path is authoritative**: a mismatched extension gets the format's
  extension appended (`out.mp4` + ProRes → `out.mp4.mov`).
- **Never give a directory** as the output: the export hangs (bug).
- `--list-presets` returns 39 entries (Match Source adaptive H.264 ×3, High
  Quality 1080p/4K, YouTube/Vimeo 1080p/4K, Social Vertical, Apple ProRes 422
  HQ/422/Proxy/LT, DNxHR, MXF, audio and still presets) with `format`,
  `extension`, `category`, `description`, `frameSize`.

## Offline media

Verified by moving a clip's file away and exporting:

```
$ filmcraft-cli --project offline.fcproj export out.mp4 --format h264
{"job":1,"offlineMedia":[{"item":1,"name":"media.mp4",
  "path":"…/samples/media.mp4","status":"missing",
  "error":"media offline: No such file or directory (os error 2)"}],
 "path":"…/out.mp4","result":{"bytes":140721,"frames":48,…}}
filmcraft-cli: warning: 1 offline media item(s) rendered as placeholder frames:
  item 1 media.mp4 (missing): …/samples/media.mp4
filmcraft-cli: export: …/out.mp4 has placeholder frames for offline media;
  relink it (exec media.relink …) or pass --allow-offline
exit 1
```

With `--allow-offline` the same export exits **0** (writer frames stay). In MCP,
`file.exportMedia` returns `isError:false` and lists the items in
`offlineMedia` — the caller must check it. `media.status` reports
`missing|offline|unreadable|online|generated`; `media.findMissing` lists all.
Repair with `media.relink {item, path, relinkOthers:true}` or
`media.autoRelink {from, to}`.

## Render / probe / bench

```sh
filmcraft-cli --project p.fcproj render --seconds 1.5 --out frame.png --scale 0.5
filmcraft-cli probe clip.mp4            # JSON: container, codecs, duration, tracks, BWF/MXF details
filmcraft-cli bench-decode clip.mp4 --frames 120
```

`render` and `probe` never modify the project. `render` writes a placeholder for
offline media and exits 1 unless `--allow-offline`.

## MCP from the shell

```sh
filmcraft-cli mcp --demo                       # headless server on stdio
filmcraft-cli mcp --bridge 127.0.0.1:7991       # the running app
```

`filmcraft-cli --bridge 127.0.0.1:7991 exec file.exportMedia path=… wait=true`
blocks the same way and drives the app's job queue. A bridge export keeps the
app responsive and shows progress in its status bar.

## Scripting pattern

```sh
set -e
P=/tmp/work/p.fcproj
filmcraft-cli exec file.newProject name=Work
filmcraft-cli --save-as "$P" exec file.newSequence '{"name":"Main","width":1920,"height":1080,"fps":24}'
filmcraft-cli --project "$P" --save exec file.import '{"paths":["/abs/a.mp4"]}'
filmcraft-cli --project "$P" --save exec timeline.place '{"item":1,"track":"V1","seconds":0}'
filmcraft-cli --project "$P" export out.mp4 --format h264
```

`--save` writes back to `--project`, `--save-as` writes a copy when the session
ends. Prefer explicit `file.saveAs` inside scripts: it fails loudly if the parent
directory does not exist, whereas a missing parent at exit is easier to miss.
