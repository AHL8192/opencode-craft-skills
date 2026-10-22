# OpenCode skills for the Craft apps

Draft [OpenCode](https://opencode.ai) skills for the Craft suite — one directory per app,
each a self-contained skill (`SKILL.md` + `references/` + `scripts/`) written by driving the
real applications on Linux (verified 2026-10-22).

| App | Version covered | Skill |
|---|---|---|
| DeckCraft | 0.9.0 | [`deckcraft/`](deckcraft) |
| DesignCraft | 0.10.0 | [`designcraft/`](designcraft) |
| EffectCraft | 0.13.0 | [`effectcraft/`](effectcraft) |
| FigCraft | 0.8.0 | [`figcraft/`](figcraft) |
| FilmCraft | 0.10.0 | [`filmcraft/`](filmcraft) |
| GridCraft | 0.9.0 | [`gridcraft/`](gridcraft) |
| PdfCraft | 0.10.1 | [`pdfcraft/`](pdfcraft) |
| PhotoCraft | 0.11.1 | [`photocraft/`](photocraft) |
| VectorCraft | 0.14.0 | [`vectorcraft/`](vectorcraft) |
| WordCraft | 0.9.0 | [`wordcraft/`](wordcraft) |

## Install

```bash
git clone https://github.com/AHL8192/opencode-craft-skills.git
cp -r opencode-craft-skills/deckcraft ~/.config/opencode/skills/deckcraft
```

Each skill is inert on its own: it teaches an agent how to use the app's existing MCP
server, CLI and command engine. No patches to the apps required.

## Status

These are drafts offered upstream, not official artefacts. Each `SKILL.md` opens with a
machine snapshot (version, ports, config paths) that should be regenerated at release time —
`scripts/probe.sh` and `scripts/dump-commands.sh` do most of that work.
