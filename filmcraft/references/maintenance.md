# Maintenance — keep this skill true

FilmCraft moves fast; the docs in the repository describe design intent, and the
binary is the truth. Re-verify before trusting any claim here.

## 1. Version and identity

```sh
filmcraft --version            # filmcraft 0.10.0
filmcraft-cli --version        # filmcraft-cli 0.10.0
dpkg-query -W -f='${Version}\n' filmcraft
dpkg -S /usr/bin/filmcraft
```

If either version changed, re-run the checks below and update the snapshot table
in `SKILL.md`, the command catalog and any behaviour that moved.

## 2. Handshake and tool surface

```sh
bash scripts/probe.sh
```

It starts `filmcraft-cli mcp --demo`, does `initialize`, `tools/list`,
`resources/list`, prints the version, tool count and command count, and exits
non-zero if the handshake or the expected 17 tools are missing. Re-run after every
upgrade.

## 3. Command catalog

```sh
bash scripts/dump-commands.sh /tmp/fc-commands
```

Writes `commands.json` (the full `command_list`), `commands.md` (grouped by
namespace) and `summary.txt`. Compare namespace counts with the table at the top
of `references/commands.md`; replace the file when ids or params change.
The current numbers: **701 commands / 42 namespaces**, 130 video effects, 112
video transitions, 3 audio transitions, 18 Lumetri presets, 39 export presets.

## 4. Behaviour checklist (10 minutes)

Run these against a throwaway project; all are cheap. The expected values are what
this skill documents.

1. `file.newProject` → `file.importDemoFootage {scene:"CityNight"}` →
   `file.newSequence` → `timeline.place` returns **two** clip ids (video + audio).
2. `timeline.razor` on the pair cuts both; `edit.undo` restores one step.
3. `timeline.trim {clip,edge:"out",delta:-SEC}` changes `duration`; the same call
   with `seconds` changes nothing (param-name footgun).
4. Apply a Gaussian Blur, `effects.setParam {param:"blurriness",value:12}`, read
   back `"Float(12.0)"`.
5. Apply a Cross Dissolve and find it in
   `sequence_inspect.video[0].transitions[]` (not on the clip).
6. Render at a time inside the transition and outside it; the images differ.
7. `captions.newTrack {format:"bogus"}` → read back `format:"Subtitle"`.
8. Export a 1 s H.264 file to a **full file path**, check `file`/GStreamer.
9. Export to a directory path with a 30 s timeout; it should still hang (bug 1).
10. `file.exportInterchange {format:"fcpxml"}` with demo media → clips become
    `<gap>`; repeat with a real MP4 → `<asset-clip>` (limitation 15).

If any of these changed, update `references/bugs-and-workarounds.md` and the
recipes before anything else.

## 5. Docs refresh

The fetched copies used for this skill were saved under the probe tree in `docs/`
(`README.md`, `docs_agents.md`, `docs_control-protocol.md`,
`docs_project-files.md`, `docs_file-format-parity.md`, `docs_codec-parity.md`,
`docs_captions.md`, `docs_graphics.md`, `docs_architecture.md`, `docs_gaps.md`,
`docs_roadmap.md`, `docs_testing.md`). Re-fetch from the project repository when
you need the current text:

```sh
gh api repos/storytold/filmcraft/contents/docs/agents.md --jq .content \
  | base64 -d > docs_agents.md
```

Known doc-vs-binary deltas found on 0.10.0 (keep this list honest):

| Doc claim | Observed |
|---|---|
| `prefs.set` changes `<data dir>/preferences.json` | headless `prefs.set` is session-scoped; nothing written |
| strict args example (`filtr`) | correct for **tool** args; command params still ignore unknown keys |
| control port examples use 9876 | any free port works (7991 used here) |
| `jobs.list` described next to tools | it is a command, not an MCP tool |
| ui.scroll `{panel}` | rejected; needs `id` or `x,y` |
| HEVC export is listed as a format | unavailable here ("no encoder registered") |

## 6. Isolation and cleanup

- Give the app its own port: `filmcraft --control 7991 --control-input-only`.
- Use `--data-dir /tmp/fc-…` for headless runs and (when the user may have an
  instance open) for the GUI, so preferences/recovery/models do not collide.
  Data dir: `~/.local/share/filmcraft` by default (`$XDG_DATA_HOME/filmcraft`).
- The GUI writes `Recovery/<epoch>-<pid>/`. Close **your** instance and delete
  only your own directory; never kill or clean another agent's process.
- Preview renders land in `/tmp/FilmCraft Previews/<project>-<pid>-<hash>/`;
  narration in `/tmp/FilmCraft/Narrations/`. Safe to delete after your run.
- Logs rotate at `~/.local/share/filmcraft/Logs/filmcraft.log` (+ `.1`, `.2`).
- No ffmpeg/ffprobe/mediainfo on this machine. Validate with `file`,
  `gst-discoverer-1.0`, ImageMagick (`identify`, `compare`), Python (`struct`,
  `aifc`, `wave`) and VLC's decoder (`cvlc --video-filter=scene`).

## 7. Updating this skill

1. Edit `references/commands.md` only by regenerating it (the header block is
   hand-written at the top; the rest is generated).
2. Keep `SKILL.md` body under 12,000 bytes (the checker warns above that).
3. Every `references/…` or `scripts/…` path mentioned in `SKILL.md` must exist.
4. Re-run the checker:

```sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/filmcraft
```

5. Re-run `bash scripts/smoke-test.sh` for an end-to-end sanity check.
