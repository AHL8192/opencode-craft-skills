# Maintenance and verification

The app is an alpha (first commit 2026-10-01) and this skill is a snapshot of
**0.13.0**. Commands, params, counts and bugs can change between builds; re-verify
before trusting the references.

## What is installed where

| Item | Path |
|---|---|
| App / CLI | `/usr/bin/effectcraft`, `/usr/bin/effectcraft-cli` (Debian package `effectcraft`) |
| Packaged README | `/usr/share/doc/effectcraft/README.md` |
| User config | `~/.config/effectcraft/` (`Logs/`, `window.json`, `workspaces.json`, `shortcuts.json`) |
| Agent profile (recommended) | `EFFECTCRAFT_CONFIG_DIR=/tmp/ec-agent …` |
| This skill | `~/.config/opencode/skills/effectcraft/` |

`effectcraft` has **no `--help`**; no-argument `effectcraft-cli` prints usage. The
GUI is a normal Wayland/window app; the control port is unauthenticated loopback.

## Routine checks

```sh
bash ~/.config/opencode/skills/effectcraft/scripts/probe.sh
bash ~/.config/opencode/skills/effectcraft/scripts/dump-commands.sh
bash ~/.config/opencode/skills/effectcraft/scripts/smoke-test.sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/effectcraft
```

- `probe.sh` — versions, package, running control port, MCP handshake, tool count,
  command/effect counts, resources.
- `dump-commands.sh` — writes the live catalog to `/tmp` and diffs ids against
  `references/command-index.txt`; `--update-skill` regenerates the index.
- `smoke-test.sh` — creates a comp, text, keyframes, effect, renders a frame and
  saves/reopens in a throwaway directory, then validates the PNG and JSON. It does
  **not** touch the user's project or config.
- The checker enforces the skill format: frontmatter, id/name match, description
  triggers, references resolving, and **SKILL.md < 12,000 bytes**. Keep links to
  files that exist, and keep the body lean — move detail into `references/`.

## When the version changes

1. `effectcraft --version` and `effectcraft-cli --version`; `dpkg -s effectcraft`.
2. `effectcraft-cli commands --json | python3 -c '…'` — recount commands,
   namespaces and effects.
3. `effectcraft-cli exec --list --schemas --json` — diff params for the commands
   used in `references/commands.md`.
4. Re-test the silent successes in `references/bugs-and-workarounds.md`; a fix
   means deleting the workaround, not necessarily the whole entry.
5. Re-run `scripts/smoke-test.sh` and one real render in each format you care
   about (the format names and extension rules are the most volatile part).
6. Update the **Machine snapshot** table in `SKILL.md`, the snapshot date, and any
   counts repeated in references.

The live catalog is always right:

```sh
effectcraft-cli commands --filter "mask" --json
effectcraft-cli exec command.describe --params '{"command":"mask.new"}' --empty --json
```

`describe_command` returns `params` (human doc), `schema` (JSON Schema), `menu`,
`shortcut`, `enabled` and `why`. When the docs and the binary disagree, the binary
wins; note the difference in `references/bugs-and-workarounds.md` under
“docs vs binary”.

## Running a GUI for agent work

```sh
export EFFECTCRAFT_CONFIG_DIR=/tmp/ec-agent        # isolated profile
mkdir -p "$EFFECTCRAFT_CONFIG_DIR"
effectcraft --control 9877 >/tmp/ec-agent.log 2>&1 &
effectcraft-cli mcp --bridge 9877
```

- Use a **free port**; `ss -ltn | grep 9877` first.
- Check readiness in the log for `first frame drawn` and on the port with
  `ui.inspect`; the app can take ~5–10 s to draw its first frame on this laptop.
- The window is ~1912×1016 at 100%; `ui.resize` does not work here.
- Kill only the PID you started (`$!`); never `pkill effectcraft` — other agents
  and the user may have windows open.
- Screenshots and renders go under your test root; do not write into
  `~/.config/effectcraft` or the user's project folders.

## Failure modes and first checks

| Symptom | Check |
|---|---|
| `Connection refused` on the control port | app closed/crashed; `pgrep -af 'effectcraft --control'`, read the log, restart |
| MCP tool not found | `effectcraft-cli mcp --bridge PORT` requires a live app; headless has no `ui_*`/`screenshot` |
| `the project is empty` | create/open a comp; many layer commands are context-disabled |
| `command … is not available right now` | read `why` in `describe_command` (selection, open comp, media missing) |
| Render writes nowhere | absolute path, existing parent folder for `render_frame`, format vs extension |
| Project won't open | the parser message names the line/column; keep a backup copy |

## Upstream material

- Packaged README: `/usr/share/doc/effectcraft/README.md`.
- Repo docs (`docs/agents.md`, `control-protocol.md`, `mcp.md`, `footage.md`,
  `plugins.md`, `web.md`, parity/gaps/architecture/testing) are the design source
  but can lag the binary. If the repo is available, read the versions that match
  `savedBy`/`0.13.0`, and prefer live `describe_command` output.
- Community: https://discord.gg/artcraft · https://getartcraft.com/apps/effectcraft
  · https://github.com/storytold/effectcraft

## Do not

- Rewrite `~/.config/opencode/opencode.json` wholesale; merge server entries.
- Attach to or quit someone else's window, or reuse their control port.
- Trust extension-based format detection, `file.findMissing`, or counts in old
  READMEs.
- Add another `SKILL.md` copy or change the `name` — the directory, id and
  frontmatter name must all stay `effectcraft`.
