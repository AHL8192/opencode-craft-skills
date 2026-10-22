# Maintenance and re-verification

This skill was verified against **0.11.1** (`46e538b3a`, 2026-10-20). PhotoCraft
moves quickly; re-run the probes after any upgrade and update the snapshot table
in `SKILL.md`.

## 1. Version probe

```sh
photocraft --version
photocraft-cli version
dpkg-query -W -f='${Version}\n' photocraft 2>/dev/null || rpm -q photocraft
photocraft-cli commands --json | python3 -c 'import json,sys;d=json.load(sys.stdin);print(len(d),"commands in",len({c["id"].split(".")[0] for c in d}),"namespaces")'
```

Record all four values. A build-hash change with the same version number still
means a different binary — trust the hash, not the version.

## 2. Catalog diff

```sh
./scripts/dump-commands.sh            # writes a timestamped snapshot + summary
./scripts/dump-commands.sh --diff     # diff against the newest earlier snapshot
```

The script stores the full registry (`id`, `label`, `menu`, `shortcut`, `params`,
`enabled`, `needsDocument`) plus a per-namespace count table. A diff reports:

- added / removed command ids → update `references/commands.md`;
- parameter-string changes → any recipe using that command may need new keys;
- namespace count changes → update the table.

Parameter **strings** are human text, not schemas; they change without notice.
When a recipe matters, re-run it instead of only diffing.

## 3. Behaviour probes

```sh
./scripts/probe.sh       # environment, versions, MCP handshake, tool/resource counts,
                         # catalog totals, filesystem-authority checks
./scripts/smoke-test.sh  # end-to-end: new → edit → save/reopen → render → pixel compare
```

`smoke-test.sh` fails loudly if the render is blank, the layer count changes on
reopen, or `doc_save` starts returning warnings it did not return before. It uses
its own temporary root and never touches user files.

Re-test these after an upgrade, because they encode the parts most likely to
regress:

1. `edit.fill` colour handling (invalid colour → black or error?).
2. Unknown-parameter behaviour (ignored vs rejected).
3. The automation gate on path-taking commands (`file.*`, smart-object replace).
4. `.ora` adjustment-layer warning and `.exr` linear encoding.
5. History cap (`prefs.get {"path":"performance.historyStates"}`).
6. Bridge handshake: `--bridge` + token + `ui.inspect`.

## 4. Docs refresh

The upstream docs live in the repository (`README.md`,
`docs/control-protocol.md`, `docs/parity-checklist.md`,
`docs/file-format-parity.md`, `docs/gaps.md`, `AGENTS.md`). They describe intent
and are occasionally ahead of or behind the binary. Known mismatches already
recorded:

| Doc claim | Binary reality |
|---|---|
| README: “500+ commands” | 918 in 36 namespaces |
| parity checklist: 631/631 menu items live | measures menu wiring, not behaviour |
| `--connect` mentioned elsewhere | PhotoCraft accepts `--bridge` only |
| commands like `file.saveACopy` advertise filesystem paths | disabled under MCP automation |
| `ui.screenshot {path, maxSide}` implied | control rejects `maxSide`; MCP uses `max_side` |

Rule: a feature is “available” only after a raw call, a read-back and (for files)
a reopen.

## 5. Config maintenance

The OpenCode entries are:

```json
"photocraft":     {"type":"local","command":["/usr/bin/photocraft-cli","mcp",
                   "--automation-read-root","/home/<user>",
                   "--automation-write-root","/home/<user>"]},
"photocraft-app": {"type":"local","command":["/usr/bin/photocraft-cli","mcp",
                   "--bridge","127.0.0.1:7878","--control-token-file",
                   "/home/<user>/.config/photocraft/control-7878.token"]}
```

- Edit `~/.config/opencode/opencode.json` with an exclusive lock, a timestamped
  backup, a merge of **only** these two keys, and an atomic replace — several
  other apps (WordCraft, PdfCraft, GridCraft, VectorCraft, Chrome, Responsively)
  keep entries in the same file.
- Validate after writing: `python3 -m json.tool ~/.config/opencode/opencode.json`.
- The bridge entry only works while an app is listening on 7878 with that token
  file. If the entry fails, the app is not running with the expected token.
- To scope the headless server tighter, narrow the two root flags (for example
  to a single project directory). The agent then cannot read or write outside it.

## 6. Running / stopping the desktop app

```sh
# start (own instance, stable token, scoped files)
DISPLAY=:1 WAYLAND_DISPLAY= \
setsid nohup photocraft --control 7878 \
  --control-token-file ~/.config/photocraft/control-7878.token \
  --automation-read-root ~/work --automation-write-root ~/work \
  --new-instance ~/work/scratch.pcraft \
  > ~/.cache/photocraft-control.log 2>&1 &
echo $! > ~/.cache/photocraft-control.pid

# health
ss -ltn | grep 7878
python3 - <<'PY'
import json,socket
tok=open("/home/<user>/.config/photocraft/control-7878.token").read().strip()
s=socket.create_connection(("127.0.0.1",7878)); f=s.makefile("rw")
f.write(json.dumps({"id":0,"method":"auth","params":{"token":tok}})+"\n"); f.flush()
print(f.readline().strip())
f.write(json.dumps({"id":1,"method":"ui.inspect","params":{}})+"\n"); f.flush()
print(f.readline()[:120])
PY

# stop only the instance you started
kill "$(cat ~/.cache/photocraft-control.pid)"
```

- Use a unique port per instance; a second app on the same port fails to bind.
- `ui.inspect` returning `ok:false` usually means the token is wrong
  (`authentication required`) or the app is on another port.
- On Wayland the control drain runs on compositor frame callbacks; a hidden or
  occluded window can time out. XWayland (`WAYLAND_DISPLAY=`) was reliable.
- Token rotation: stop the app, delete the token file, restart with
  `--control-token-file`; update the MCP entry to the same path. Mode must stay
  `0600`.

## 7. What to change in this skill

| If you observe | Update |
|---|---|
| new/removed commands | `references/commands.md` + catalog snapshot |
| new MCP tool or parameter | `references/mcp-and-control.md`, `SKILL.md` table |
| changed CLI flags | `references/cli.md`, `scripts/probe.sh` |
| new format support | `references/formats-and-roundtrip.md` matrix |
| fixed silent success | remove from `references/bugs-and-workarounds.md`, note the version |
| new silent success | add a repro row and a workaround before anything else |

Keep `SKILL.md` under 12,000 bytes and re-run:

```sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/photocraft
```
