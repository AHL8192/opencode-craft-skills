# `photocraft-cli` — headless CLI

```
photocraft-cli 0.11.1 (46e538b3a, 2026-10-20)
```

Subcommands: `convert`, `info`, `run`, `batch`, `droplet`, `commands`, `mcp`,
`serve`, `version`. There is no per-subcommand help: `photocraft-cli <cmd> --help`
prints the same global usage text, and an unknown flag is an error.

Unlike the MCP server, the CLI is **not** sandboxed: it reads and writes any path
the user can.

## convert

```sh
photocraft-cli convert in.pcraft out.png
photocraft-cli convert in.psd out.tif --tiff-layers
photocraft-cli convert in.png out.webp --quality 90     # quality => lossy
photocraft-cli convert in.png out.webp                  # no quality => lossless
photocraft-cli convert in.png out.tga --tga-bits 32
photocraft-cli convert in.exr out.png
```

- The output format comes from the extension; `--format png` forces the **codec**
  but does not change the filename. `convert in.png out.jpg --format png` writes
  a PNG payload called `out.jpg` (verify with `identify`).
- Flat formats flatten and warn
  (`warning: N layer(s) flattened; layers, masks and blend modes are not kept`).
  `.psd`, `.psb`, `.pcraft`, `.ora`, and `.tif` with `--tiff-layers` keep layers.
- 16-bit → 8-bit formats warn (`warning: 16-bit will be reduced to 8-bit`) and
  lossy codecs also warn (`warning: lossy compression`).
- Errors exit non-zero: `error: unknown file format: xyz`,
  `error: I/O: missing.png: No such file or directory (os error 2)`,
  `error: codec: Png: malformed data: unexpected end of file`.

## info

```sh
photocraft-cli info doc.pcraft            # pretty JSON
photocraft-cli info doc.pcraft --compact  # one line
```

JSON: size, mode, depth, `layers` (tree with ids, kinds, bounds, masks,
adjustment params), selection, channels. Flat images report a single
`Background` layer.

## run

```sh
photocraft-cli run in.psd \
  --cmd filter.sharpen.smartSharpen --params '{"amount":80}' \
  --cmd layer.newAdjustmentLayer.curves --params '{"points":[[0,0],[64,48],[192,212],[255,255]]}' \
  --out out.png
```

- `(<file> | --new <json>)` — a new document needs JSON, e.g.
  `--new '{"width":640,"height":480,"mode":"rgb","depth":8,"background":"white"}'`.
- Each `--cmd` is followed by its own `--params` (the params belong to the
  preceding command). Commands run in order and print one JSON line each:
  `{"command":"edit.fill","result":{"contents":"color"}}`.
- `--out` saves at the end (format from the extension). Without `--out` nothing
  is written.
- A bad id prints `error: `<id>`: unknown command `<id>`` and the run stops.

## batch

```sh
photocraft-cli batch --actions grade.json --in ./raw --out ./graded
photocraft-cli batch --actions set.atn --action "My Action" --in ./raw --out ./graded
photocraft-cli batch --actions grade.json --in ./raw --out ./raw --in-place
```

`actions.json` accepts any of:

```json
[["image.adjustments.invert", {}], ["filter.blur.gaussianBlur", {"radius": 2}]]
[{"command": "image.adjustments.invert", "params": {}}]
["image.adjustments.invert"]
{"steps": [ … ]}
{"actions": [{"name": "grade", "steps": [ … ]}]}
```

- Photoshop `.atn` action sets play with `--action <name>` (needed when the set
  holds several actions).
- `--out` equal to `--in` is refused (`--out bin is the --in folder, so the
  results would replace the originals`) unless `--in-place`.
- Per-file failures are reported and the run exits non-zero:
  `FAIL  bin/img1.png: `nope.nope`: unknown command `nope.nope``.
- The format is taken from `--format` or the input extension; `--quality`,
  `--tiff-layers`, `--tga-bits`, `--dpx-bits` pass through.

## droplet

```sh
photocraft-cli droplet my.pcdroplet ./images --out ./out
```

Runs a droplet created by File › Automate › Create Droplet.

## commands

```sh
photocraft-cli commands                 # aligned table: id, label, menu
photocraft-cli commands --json          # full registry (918 entries, ~350 KB)
photocraft-cli commands --filter save   # id/label/keywords substring
```

Use `--json` for scripts and `--filter` when looking for an id by name.

## mcp

```sh
photocraft-cli mcp --automation-read-root DIR --automation-write-root DIR
photocraft-cli mcp --bridge 127.0.0.1:7878 --control-token-file TOKEN
```

Flags: `--bridge`, `--control-token`, `--control-token-file`,
`--automation-read-root`, `--automation-write-root`. `--connect` is not accepted.
See `mcp-and-control.md`.

## serve

```sh
printf '%s\n' '{"id":1,"method":"methods","params":{}}' | photocraft-cli serve
photocraft-cli serve --port 7890 --automation-read-root DIR --automation-write-root DIR
```

Long-lived headless session, JSON lines on stdio or loopback. Methods:
`engine.execute`, `jobs.list`, `jobs.cancel`, `engine.commands`, `session.list`,
`doc.open`, `doc.place`, `doc.new`, `doc.save`, `doc.exportLayers`,
`doc.exportDataSets`, `doc.importDataSets`, `doc.inspect`, `doc.render`,
`doc.select`, `doc.close`, `batch`, `methods`.

## Shell patterns

```sh
# probe the surface
photocraft-cli version; photocraft-cli commands --json | python3 -c 'import json,sys;print(len(json.load(sys.stdin)))'

# verify a render without a viewer
photocraft-cli convert out.pcraft out.png
identify out.png
convert out.png -format 'mean=%[fx:mean] sd=%[fx:standard_deviation]\n' info:
convert out.png -crop 1x1+10+10 -depth 8 txt:-   # one pixel

# compare two renders
compare -metric AE a.png b.png null: 2>&1
```
