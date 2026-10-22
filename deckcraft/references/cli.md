# CLI — `deckcraft-cli` 0.9.0

Headless command-line tool for `.deckcraft` and `.pptx`. No window, no display.

```
deckcraft-cli info FILE                 slides, layouts, theme as JSON
deckcraft-cli render FILE|--sample …    PNG per slide
deckcraft-cli render-transition …       frames of a transition
deckcraft-cli convert IN OUT            format from OUT's extension
deckcraft-cli run …                     commands + save/export
deckcraft-cli commands [PREFIX]         list command ids
deckcraft-cli describe COMMAND          params + menu + shortcut
deckcraft-cli app …                     one request to a running app
deckcraft-cli mcp …                     MCP server on stdio
deckcraft-cli bench FILE|--sample       open/draw/save/export timings
deckcraft-cli links                     project links
deckcraft-cli --version | -h | help SUB
```

`-h` prints help and exits 0; unknown subcommands exit 1 and print the usage
block. `deckcraft-cli SUB --help` and `deckcraft-cli help SUB` are equivalent.

## run

```
deckcraft-cli run [--in FILE | --sample] [--cmd ID[=JSON]]… [--save OUT]
                  [--export OUT [--export-params JSON]] [--print]
```

- `--in` opens a file, `--sample` the built-in deck, neither starts a new deck
  with one empty title slide.
- Each `--cmd` is an id plus one JSON object of parameters. Quote for the shell:
  `--cmd 'shape.insert={"preset":"roundRect","rect":[80,160,320,120],"text":"Hi"}'`.
- `--print` prints each command's result (`shape.insert → {"id":262}`).
- `--save` writes `.deckcraft` (all data) or `.pptx`/`.pdf`/`.md`/`.txt` (via the
  same writer as `convert`).
- `--export` writes the current slide as PNG/JPG or the deck as PDF/PPTX/GIF;
  `--export-params` takes the `file.export` options as JSON.
- **Any failing command stops the run and saves nothing.** Success is not the
  same as "did something": unknown parameter names inside a command are ignored.

`slide.new` inserts **after the current slide** and the current slide starts at
0, so with `--sample` a new slide lands at index 1, not at the end. Use
`--cmd 'slide.go={"index":N}'` before creating, or `"at":N`.

Verified timings (this laptop): 160 commands on a 48-slide deck 0.12 s;
302 commands (300 shapes + a 10 000-character text box) 0.41 s, 197 MB RSS;
`bench --sample` → open 7 ms, render all 8 slides 67 ms, save .pptx 10 ms,
PDF export 809 ms, peak 192 MiB.

## convert

`convert IN OUT` — the extension picks the writer. Supported (from the error
message, which is wider than the README/`-h` text):
`.deckcraft .pptx .potx .ppsx .pdf .png .jpg .jpeg .gif .txt .md`.
Anything else exits 1: `unsupported output format .docx (supported: …)`.
`.md` and `.txt` are the **same outline text**, not Markdown headings.

## render

```
deckcraft-cli render (FILE | --sample) [--slide N | --all] [--scale S]
                     [--edit] [--transparent] OUT
```

- `--slide` is 0-based; `--all` treats OUT as a folder and writes
  `slide-01.png`, `slide-02.png`, … (1-based names).
- `--scale` is pixels per point, default 2 (a 960×540 slide → 1920×1080).
- `--edit` draws placeholder prompts and dashed outlines.
- An out-of-range slide errors with the valid range:
  `no slide index 5 (this deck has 2 slides, numbered 0 through 1…)`.

## info

`deckcraft-cli info FILE` prints JSON: `slides` (index, id, title, layout,
shape count, notes, transition, hidden), `layouts`, `fonts`, `sections`,
`slideSize`. For a slide's shapes, run `slide.inspect`:

```sh
deckcraft-cli run --in deck.deckcraft --print --cmd 'slide.inspect={"index":0}'
```

`info --sample` does **not** exist; use `run --sample --print --cmd document.inspect`.

## mcp

```
deckcraft-cli mcp [--connect PORT] [--sample]
                  [--automation-read-root DIR] [--automation-write-root DIR]
```

- stdio JSON-RPC. See `mcp-and-control.md` for the handshake and tool list.
- `--connect` drives a running `deckcraft --control PORT`; `PORT` may be
  `host:port`.
- The two roots confine **every** path read/written by the in-process server
  (open, pictures, audio/video, save, export, render-to-path). Missing root →
  server stops. Roots **cannot be combined with `--connect`**:

  ```
  deckcraft-cli: --automation-read-root and --automation-write-root confine the
  in-process server; a running app is not confined by them, so drop --connect …
  ```

  Errors are tool errors the model can read:
  `automation path rejected: outside the write root …` and
  `automation filesystem access is not granted: read authority is absent: …`.

## app

```
deckcraft-cli app [--port PORT] COMMAND [PARAMS]
deckcraft-cli app --method METHOD [PARAMS]
```

Sends one request to `deckcraft --control PORT` and prints the JSON answer.
**Default port is 7979** — always pass `--port 7990` on this machine (7979 is
GridCraft's bridge).

```sh
deckcraft-cli app --port 7990 shape.insert '{"preset":"star5","rect":[100,100,200,200]}'
deckcraft-cli app --port 7990 --method ui.screenshot '{"path":"/tmp/shot.png"}'
deckcraft-cli app --port 7990 --method ui.inspect
```

## bench

`bench (FILE|--sample) [--runs N] [--json]` reports median/slowest for open,
render each slide, save `.deckcraft`, save `.pptx`, reopen `.pptx`, export `.pdf`,
and peak memory. Good regression check before trusting a timing claim.

## Desktop binary

`deckcraft` (the app) accepts `--version`, `-h`, `--sample`, `--control PORT`.
`--version` writes no log file. Do not run `deckcraft --help` on a headless
machine without a timeout: the GUI binary may try to open a window. Prefer
`deckcraft --version` and the CLI's help.

## Logs and settings

`~/.config/deckcraft/` (or `$XDG_CONFIG_HOME/deckcraft/`): `prefs.json`,
`ui.json`, `logs/deckcraft.log` (+ `.1`, `.2`), recovery data. `RUST_LOG`
controls verbosity, e.g. `RUST_LOG=debug` or `RUST_LOG=info,wgpu_core=warn`.
