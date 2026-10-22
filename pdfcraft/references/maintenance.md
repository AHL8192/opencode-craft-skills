# Maintaining this skill

Snapshot: **PdfCraft 0.10.1**, verified **2026-10-22**. PdfCraft ships quickly;
descriptions and counts drift. Trust the installed binary over this skill and
over upstream prose.

## Sources

- App / CLI: `pdfcraft --version`, `pdfcraft-cli --version`,
  `dpkg -s pdfcraft` (packaged as `0.10.1-1`).
- Tool schemas: `pdfcraft-cli tools` (171 JSON schemas).
- Command registry: MCP `command_list` or `pdfcraft://commands` (201 ids).
- Upstream repository: <https://github.com/storytold/pdfcraft> — `README.md`,
  `docs/mcp.md`, `docs/cli-batch.md`, `docs/file-format-parity.md`,
  `docs/gaps.md`, `docs/editing-*.md`.
- Product pages: <https://getartcraft.com/apps/pdfcraft>,
  <https://discord.gg/artcraft>.

Record the fetch date and version beside any new claim. A raw call plus a
read-back (and ideally an external check) is the minimum bar.

## Checklist for a new release

1. **Versions.** `pdfcraft --version`, `pdfcraft-cli --version`, `dpkg -s pdfcraft`.
2. **Counts.** `pdfcraft-cli tools | python3 -c 'import json,sys;d=json.load(sys.stdin);d=d.get("tools",d);print(len(d))'`
   and the compact count:
   `printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"1"}}}' '{"jsonrpc":"2.0","method":"notifications/initialized"}' '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | pdfcraft-cli mcp --compact | tail -1`
   (or use `scripts/probe.sh`).
3. **Registry.** Read `pdfcraft://commands` and compare ids; note added,
   renamed and removed commands and any new `tool` mappings.
4. **Tool deltas.** Diff the JSON from `scripts/dump-commands.sh` against the
   previous snapshot. Renamed arguments are the usual breakage.
5. **Smoke test.** `scripts/smoke-test.sh` creates, edits, saves, reopens and
   externally validates a PDF. It also checks the redaction audit behaviour.
6. **GUI.** Start a private instance with a fresh control file, then check
   `state`, `inspect`, `screenshot`, a tool click, a drag and quit. Confirm the
   control-file format and method list. Never reuse a user's control file.
7. **Regenerate references.** `commands.md` and `command-index.md` are derived;
   regenerate them from live data rather than editing them by hand.
8. **Update this skill.** Refresh the snapshot table, counts, pitfalls and any
   changed argument names. Keep `SKILL.md` body under 12,000 bytes.
9. **Check.** `node ~/.config/opencode/skills/creating-skills/scripts/check-skill.mjs ~/.config/opencode/skills/pdfcraft`
   → expect exit 0 and no errors/warnings.
10. **Clean up.** Remove only your own control files, test roots and processes.

## Things that change most often

- Required arguments missing from descriptions (`doc_create.from`,
  `page_number.from`).
- Argument renames (`text_find text→query`, `page_rotate angle→degrees`,
  singular `page`→plural `pages` for page operations).
- Which read tools return JSON as text vs `structuredContent`.
- Command count and tool↔command mappings (201 vs 171 vs 91 mapped in 0.10.1).
- GUI widget ids, dialog button order and control methods.

## Regenerating the reference files

`scripts/dump-commands.sh` writes:

- `/tmp/opencode/pdfcraft-skill/tools.json` — `pdfcraft-cli tools`
- `/tmp/opencode/pdfcraft-skill/commands.json` — registry via MCP
- `/tmp/opencode/pdfcraft-skill/versions.txt`

Then rebuild `references/commands.md` (one entry per tool, required args marked)
and `references/command-index.md` (id/menu/label/tool table). Keep the generated
headers’ verification date current.

## Upstream documents are not the binary

Observed mismatches in 0.10.1:

- Prose says “every action is a tool”; 201 commands vs 171 tools, 91 carrying a command id.
- Prose implies an app MCP bridge; `pdfcraft-cli mcp` has no `--connect`.
- Tool descriptions omit some required arguments.
- Some docs use singular `page`/`angle`/`text` where the schema uses
  `pages`/`degrees`/`query`.
- The README's feature counts and “last updated” dates lag the build.

When prose and a live schema disagree, the schema wins; record the discrepancy
in `bugs-and-workarounds.md`.

## Safety rules for maintenance

- Save copies before destructive tests; report through new paths.
- Use a private control file and a test PDF; kill only your PID.
- Do not touch other Craft apps, their ports, or the user's control files.
- Use `--root`/automation roots for untrusted files, never `$HOME`.
- Do not print, sign with a real certificate, or upload anything without the
  user's explicit consent.
- Redaction tests: use generated text, and always audit + `pdftotext` the result.
