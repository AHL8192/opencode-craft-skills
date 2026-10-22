# WordCraft CLI and desktop flags

## Installed binaries

| Binary | Purpose |
|---|---|
| `/usr/bin/wordcraft` | desktop GUI |
| `/usr/bin/wordcraft-cli` | conversion, inspection, commands, MCP, Zotero |

Version 0.9.0, Debian package `wordcraft 0.9.0-1`.

```sh
wordcraft [--sample] [--control PORT] [FILE…]
wordcraft --version
wordcraft -h
```

- `--sample` opens the built-in sample document.
- `--control PORT` starts the loopback control server (or set
  `WORDCRAFT_CONTROL_PORT`). Invalid/missing port → error, exit status 2.
- A file argument opens that document.
- Wayland: runs through XWayland by default; `WORDCRAFT_WAYLAND=1` uses native
  Wayland (sharper fractional scaling, loses file drag-and-drop).

## CLI subcommands

```text
wordcraft-cli convert <in> <out> [--markup] [--update-fields]
                                 [--format wordml2003|flatopc]
wordcraft-cli info <file>
wordcraft-cli text <file>
wordcraft-cli inspect <file>
wordcraft-cli render <file> <out.png> [--page N] [--scale S]
wordcraft-cli run [--file F | --template T] [--script FILE|-]
                  --cmd 'id={json}' … [--save OUT] [--print] [--author NAME]
wordcraft-cli commands [--json]
wordcraft-cli parity [--markdown]
wordcraft-cli mcp [--connect HOST:PORT | --author NAME]
                  [--automation-read-root DIR] [--automation-write-root DIR]
wordcraft-cli zotero <command> <file> [--cmd 'id={json}' …] [--save OUT]
                  [--trace] [--port P]
wordcraft-cli --version
```

### Formats

Read: `.docx`, legacy `.doc` (read only), `.odt`, `.rtf`, `.html`, `.md`,
`.tex`, `.txt`, `.json`, `.xml` (Word XML / Flat OPC).
Write: `.docx`, `.pdf`, `.odt`, `.rtf`, `.html`, `.md`, `.tex`, `.txt`, `.json`,
`.png`, `.xml` (Flat OPC, or Word 2003 XML with `--format wordml2003`).

`--markup` = Print Markup for PDF/PNG/HTML/MD/TXT: comments beside pages, tracked
changes shown (comments and replies appear in the PDF text layer). `--update-fields` refreshes unlocked fields before saving; it also
fills body `PAGE`/`SECTIONPAGES` results that `references.updateFields` can leave
empty until export.

### Inspect and render

```sh
wordcraft-cli info report.docx       # pages, words, paragraphs, properties (JSON)
wordcraft-cli text report.docx       # plain text
wordcraft-cli inspect report.docx    # structure JSON
wordcraft-cli render report.docx p1.png --page 1 --scale 2
```

`info` sample:

```json
{"comments":1,"dirty":false,"encrypted":false,"layoutMs":173.7,"pages":1,
 "paragraphs":19,"properties":{"created":"…","lastModifiedBy":"WordCraft User", …},
 "sections":1,"trackChanges":false,"words":66}
```

### `run` — headless commands and multi-format save

```sh
wordcraft-cli run --template letter \
  --cmd 'document.setText={"text":"Dear Alex,\n\nHello."}' \
  --cmd caret.docStart \
  --cmd 'select.text={"text":"Dear Alex,"}' \
  --cmd format.bold \
  --save letter.docx --save letter.pdf --author "OpenCode"
```

Script file (`--script job.json`, or `-` for stdin):

```json
{"file": "input.docx",
 "template": "letter",
 "commands": [
   {"command":"select.text","params":{"text":"Membership"}},
   {"command":"format.bold"},
   "caret.docEnd"
 ],
 "save": ["out.docx", "out.pdf", "out.md"]}
```

Rules:
- `file` and `template` are optional; `--file`/`--template` on the command line
  win.
- A command is `{"command": id, "params": {…}}` or just the id string.
- `--cmd` flags run after the script's commands; `--save` after its outputs.
- Relative `file` and `save` paths resolve against the script's folder (the
  working folder for stdin). **Paths inside command params** (pictures, CSVs)
  resolve against the working folder instead.
- Every output is validated (known extension, existing folder) before the first
  write.
- A failing command stops the run with `command N (id): …`, exit status 1, and
  **nothing is saved**.
- Scripts are capped at 4 MiB.
- `--author` names tracked changes/comments (default `WordCraft User`).

Verified: one run produced `script-out.docx`, `script-out.md` and
`script-out.pdf`.

### `commands` and `parity`

```sh
wordcraft-cli commands --json > commands.json   # 633 in 0.9.0
wordcraft-cli parity                             # JSON coverage
wordcraft-cli parity --markdown                  # same as a report
```

Each command entry has `id`, `label`, `location`, `mutates`, `params`,
`shortcut`. `params` is a human-readable schema string, not JSON Schema.
`commands` lists engine commands only; UI-only control methods (`ui.click` etc.)
are not in it.

### `mcp`

```sh
wordcraft-cli mcp
wordcraft-cli mcp --author "OpenCode (copyedit)"
wordcraft-cli mcp --automation-read-root DIR --automation-write-root DIR
wordcraft-cli mcp --connect 127.0.0.1:7981
```

See `references/mcp-and-control.md`. `--connect` with automation roots is an
error. Roots must exist.

### `zotero`

Runs Zotero commands on a document; Zotero must be running.

```sh
wordcraft-cli zotero addEditCitation doc.docx --cmd 'caret.docEnd'
wordcraft-cli zotero addEditBibliography doc.docx
wordcraft-cli zotero refresh doc.docx
wordcraft-cli zotero removeCodes doc.docx
wordcraft-cli zotero setDocPrefs doc.docx
wordcraft-cli zotero addNote doc.docx
```

Options: `--cmd` runs first (e.g. `caret.docEnd`), `--save OUT`, `--trace`,
`--port P`.

## Password-protected files

```sh
wordcraft-cli convert secret.docx out.pdf --password PASS
wordcraft-cli convert secret.docx out.pdf --password-file PATH
WORDCRAFT_PASSWORD=… wordcraft-cli text secret.docx
```

A file opened with a password is written with it again, as the app does.
Exports that cannot carry a password (PDF, HTML, TXT) stay plain.

## Paper and region

Documents created by the CLI, and HTML/Markdown/text (which carry no page size),
use the system region's paper (A4, or Letter in the US and other Letter regions),
read from `LC_ALL`, `LC_PAPER`, `LANG`. Set `WORDCRAFT_REGION=en-US` for
reproducible output.

## Logs and preferences

- Preferences: `$XDG_CONFIG_HOME/wordcraft` (default `~/.config/wordcraft`) on
  Linux. Contains `ui.json`, `logs/`, `recovery/`, control key files.
- Log: `logs/wordcraft.log`; each launch rotates `.log` → `.1.log` → `.2.log`.
  Capped at 16 MiB. `--version` writes no file.
- `WORDCRAFT_NO_PREFS` (agent test runs) logs to stderr only.
- `RUST_LOG` uses env_logger directives, e.g. `RUST_LOG=debug`,
  `RUST_LOG=warn,wordcraft_docx=trace`, `RUST_LOG=wordcraft*=debug`.
- The desktop app launched from a menu has no terminal — attach the log file to
  bug reports. Document text is never logged.

## Environment variables

| Variable | Effect |
|---|---|
| `WORDCRAFT_CONTROL_PORT` | control port when `--control` is not given |
| `WORDCRAFT_CONTROL_KEY` | key for the bridge when connecting |
| `WORDCRAFT_PROFILE_DIR` | alternate profile folder, including recovery |
| `WORDCRAFT_PASSWORD` | password for protected documents |
| `WORDCRAFT_REGION` | paper region, e.g. `en-US` |
| `WORDCRAFT_NO_PREFS` | don't read/write preferences |
| `WORDCRAFT_WAYLAND` | use native Wayland backend |
| `RUST_LOG` | log filtering |
| `WGPU_BACKEND` | graphics backend override (mainly Windows troubleshooting) |

## Updating on this machine

The installed package is a Debian package. Replace it with a newer release
package, AppImage, Flatpak or tarball from
<https://github.com/storytold/wordcraft/releases>. Check the installed version
first:

```sh
dpkg -s wordcraft | grep Version
wordcraft --version
```

Do not assume config or command ids survive an upgrade — re-run
`scripts/probe.sh` and `scripts/dump-commands.sh`.
