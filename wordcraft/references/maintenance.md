# Keeping this skill current

WordCraft is an **alpha, actively changing** Rust application. Command ids,
parameters, counts, MCP tool names, defaults and file-format fidelity can change
between releases. This skill was verified against **0.9.0 on 2026-10-21**.

## Signals that the skill may be stale

- `wordcraft --version` is newer than 0.9.0.
- `wordcraft-cli commands --json` count differs from 633.
- `list_commands` returns ids not in `command-index.md`, or known ids are gone.
- MCP `tools/list` no longer matches the 16-tool table.
- A documented parameter is rejected or silently ignored.
- Parity differs from 492/507 (97%).

## Refresh in four commands

```sh
bash ~/.config/opencode/skills/wordcraft/scripts/probe.sh
bash ~/.config/opencode/skills/wordcraft/scripts/dump-commands.sh
bash ~/.config/opencode/skills/wordcraft/scripts/refresh-docs.sh
node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs \
  ~/.config/opencode/skills/wordcraft
```

- `probe.sh` prints installed versions, package, control-channel state, MCP
  handshake, tool list, command count and parity.
- `dump-commands.sh` writes the live catalog and diffs ids against
  `references/command-index.md`. Pass `--update-skill` to regenerate the index:
  `bash scripts/dump-commands.sh /tmp/wordcraft-commands.json --update-skill`.
- `refresh-docs.sh` fetches the current README and protocol docs to
  `/tmp/opencode/wordcraft-upstream` and prints the latest release.

## Upstream sources

| What | URL |
|---|---|
| Repository / README | https://github.com/storytold/wordcraft |
| Raw README | https://raw.githubusercontent.com/storytold/wordcraft/main/README.md |
| MCP server docs | https://raw.githubusercontent.com/storytold/wordcraft/main/docs/mcp.md |
| Control protocol | https://raw.githubusercontent.com/storytold/wordcraft/main/docs/control-protocol.md |
| Feature parity checklist | https://raw.githubusercontent.com/storytold/wordcraft/main/docs/parity-checklist.md |
| Known gaps | https://raw.githubusercontent.com/storytold/wordcraft/main/docs/gaps.md |
| Roadmap | https://raw.githubusercontent.com/storytold/wordcraft/main/ROADMAP.md |
| Releases page | https://github.com/storytold/wordcraft/releases |
| Latest release JSON | https://api.github.com/repos/storytold/wordcraft/releases/latest |
| Command source (engine) | https://github.com/storytold/wordcraft/tree/main/crates/engine |
| MCP source/tests | https://github.com/storytold/wordcraft/tree/main/crates/mcp |

## What to update, in order

1. **Version and counts** in `SKILL.md` (machine snapshot, command count, parity).
2. **Tool table** in `SKILL.md` and `references/mcp-and-control.md` if
   `tools/list` changed.
3. **Command index** via `dump-commands.sh --update-skill`; review added/removed
   ids and update `references/commands.md` for important families.
4. **Properties** in `references/properties.md` if `CharProps`/`ParaProps`
   changed in `docs/mcp.md`.
5. **CLI** in `references/cli.md` if `wordcraft-cli --help` changed.
6. **Recipes** — retest the snippets you rely on; commands can change shape even
   when ids stay.
7. **Maintenance** — update the verified-on date at the top of this file and in
   `SKILL.md`.

## Checking a new release before adopting it

```sh
# What is installed and what is newest?
dpkg -s wordcraft | grep Version
curl -sSL https://api.github.com/repos/storytold/wordcraft/releases/latest \
  | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["tag_name"], d["published_at"])'

# Read release notes for breaking changes to commands or MCP.
curl -sSL https://api.github.com/repos/storytold/wordcraft/releases/latest \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("body",""))' | less

# After upgrading, regenerate and diff.
bash scripts/dump-commands.sh /tmp/wordcraft-commands.json
```

WordCraft's docs explicitly describe it as alpha, with known gaps; a catalogued
command may still be partial. Verify document fidelity by reading the file back
with `inspect_document` or `wordcraft-cli inspect`, and check `docs/gaps.md`
before promising Word-perfect output.
