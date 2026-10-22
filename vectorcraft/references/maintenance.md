# Maintenance

VectorCraft ships frequently and the catalogues drift. Re-verify before trusting
any count or id in this skill.

## Quick refresh

```sh
bash scripts/probe.sh                  # versions, package, port, handshake, counts
bash scripts/smoke-test.sh /tmp/vc-smoke
bash scripts/dump-commands.sh 0.14.0 > /tmp/cmds.json
```

## What to compare after an update

| Thing | Where | 0.14.0 baseline |
|---|---|---|
| Version | `vectorcraft --version`, `vectorcraft-cli --version` | `0.14.0` |
| Package | `dpkg-query -W -f='${Version}' vectorcraft` | `0.14.0-1` |
| CLI catalog | `vectorcraft-cli commands` | 792 entries |
| Engine catalog (doc open) | MCP `command_list` | 1090 |
| Menu items / unique ids | control `ui.menu.list` | 902 / 336 |
| MCP tools | `tools/list` | 32 (4 alias pairs) |
| Resources / prompts | `resources/list`, `prompts/list` | 3 / 5 (+4 templates) |
| MCP protocol | `initialize` | `2025-06-18` |
| Native format | `document.save` JSON | `version: 4` |

## Version diff

```sh
# old vs new catalogues
bash scripts/dump-commands.sh 0.14.0 > /tmp/old.json
bash scripts/dump-commands.sh "$(vectorcraft-cli --version | awk '{print $2}')" > /tmp/new.json
python3 - <<'PY'
import json
a={c['id']:c for c in json.load(open('/tmp/old.json'))}
b={c['id']:c for c in json.load(open('/tmp/new.json'))}
print('added', sorted(set(b)-set(a)))
print('removed', sorted(set(a)-set(b)))
print('params changed', [i for i in a.keys()&b.keys() if a[i].get('params')!=b[i].get('params')])
PY
```

Re-test these first, because they are the fragile spots:

1. `command_run` unknown-id and bad-param behaviour (0.14.0: explicit errors).
2. Value-level coercions: negative stroke width, `scale:0`, empty text,
   zero-size shapes, `transform scale:-50` (0.14.0: silent).
3. `set_paint` with bad ids (0.14.0: applies to the new-art default).
4. Export extension/format mismatch (0.14.0: writes the requested format).
5. `command_batch` step schema and 256 cap.
6. SVG/PDF/AI/EPS round-trip RMSE (see `formats-and-roundtrip.md`).
7. GUI dialog confirm on Linux (`exportAs` cancellation) and input lag.

## Updating this skill

- Keep `SKILL.md` under 12,000 bytes (`node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs ~/.config/opencode/skills/vectorcraft`).
- Put new evidence in the right reference, with the version and the exact call.
- Mark anything unverified as unverified; do not inherit "works" claims.
- If the local port changes, update `SKILL.md`, `scripts/probe.sh`, and the
  OpenCode `vectorcraft-app` entry together (7979 GridCraft, 7981 WordCraft,
  7983 VectorCraft on this machine).

## Isolated profile hygiene

`VECTORCRAFT_CONFIG_DIR` keeps preferences, logs and the instance lock out of
`~/.config/vectorcraft`. Delete test profiles when done; never point a test
profile at the user's config directory. Screen captures and exports belong under
a test root such as `/tmp/opencode/skill-tests/vectorcraft/<run>`.
