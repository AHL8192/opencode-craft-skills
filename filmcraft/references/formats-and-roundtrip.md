# Export formats and round-trips (0.10.0, verified 2026-10-22)

Test timeline: 640×360, 24 fps, 96 frames (4 s), two demo clips (CityNight then
Aurora) on V1 with a 12-frame cross dissolve at 2 s, a Subtitle caption track
("Caption one" at 0.5 s for 1 s) and two comment markers (1 s, 3 s).

All files were checked by tools outside FilmCraft (`file`, GStreamer
`gst-discoverer-1.0`, ImageMagick, Python parsers, VLC's own decoder) — never by
FilmCraft reading its own output.

## Matrix

| Export | File (bytes) | Independent check | Verdict |
|---|---|---|---|
| H.264 MP4 | `out.mp4` 1,769,009 | GStreamer: H.264 + AAC, 4.01 s; VLC decode vs PNG frame RMSE **0.0176** | pass |
| ProRes 422 HQ MOV | `out_prores.mov` 9,419,474 | GStreamer: QuickTime, duration 4.0 s, ProRes (no local decoder) | pass (container/duration) |
| DNxHR MOV | `out_dnxhr.mov` 10,599,560 | GStreamer: QuickTime, 4.0 s, `AVdh` (no local decoder) | pass (container/duration) |
| MJPEG MOV | `out_mjpeg.mov` 3,450,730 | GStreamer: QuickTime, 4.0 s, JPEG | pass |
| MXF OP1a | `out.mxf` 10,617,954 | `file`: "Material exchange container format"; MXF key `060e2b34…` | pass (header only — no GStreamer MXF demuxer here) |
| MXF OP-Atom | `out_opatom.mxf` 9,843,671 **plus** `out_opatom_A1.mxf` 396,951 and `out_opatom_A2.mxf` 396,951 | same | pass; note one file per audio track |
| PNG sequence | `frame000..095.png` (96 files) | `identify`: 640×360 PNG | pass |
| TIFF sequence | `frame000..095.tiff` (96 files) | `identify`: 640×360 TIFF | pass |
| GIF | `out.gif` 2,556,596 | `identify`: 96 frames, 640×360 | pass |
| WAV | `audio.wav` 768,044 | RIFF/WAVE, PCM 16-bit stereo 48 kHz | pass |
| AIFF | `audio.aiff` 768,054 | `aifc`: 2 ch, 48 kHz, 16-bit, 192,000 frames | pass |
| AAC | `audio.aac` 162,577 | ADTS AAC LC, 48 kHz, stereo | pass |
| HEVC | — | `H.265 (HEVC) export is not available (no encoder registered)` | blocked by build |
| WebM | — | `unknown format 'webm'` (export list has no WebM) | not supported |
| FCP7 XML | `cut.xml` 10,885 | 4 `<track>` elements, clipitems, transitionitem | pass; re-import full |
| FCPXML | `cut.fcpxml` 1,081 | well-formed, but clips are `<gap>` of demo media | **loses clips on re-import** (synthetic media) |
| OTIO | `cut.otio` 26,924 | JSON `OTIO_SCHEMA`, tracks | pass; re-import full |
| EDL (CMX 3600) | `cut.edl` 717 | text, `TITLE`, event list, dissolve `D 012` | imports but retimes (1.75/2.25 s) |
| AAF | `cut.aaf` 32,768 | OLE/CFB header | re-import of demo media: 0 clips |
| OMF 2.0 | `cut.omf` 3,654 | binary; audio-only format | re-import of demo media: 0 clips |
| SRT / VTT / SCC | `caps.srt` 45 / `caps.vtt` 51 / `caps.scc` 136 | `file`: SubRip / WebVTT / ASCII; SRT body correct | pass |
| Markers CSV | `markers.csv` 349 | CSV text | pass |

Artifacts live in the probe tree under `exports/` (not shipped with this skill).

## H.264 fidelity proof

`cvlc --video-filter=scene` wrote `s00001.png` (640×386 — VLC pads the height) at
1.0 s of `out.mp4`. After `convert s00001.png -resize 640x360!` it matched
FilmCraft's own `frame024.png` (the PNG sequence export of the same frame) with
**RMSE 0.0176**. Cropping instead of resizing gave 0.139, because the padding is
not symmetric — resize is the correct normalisation. It also matched a live
`render_frame` of the saved project within 0.057 (frame-exactness of VLC's capture
time is ±1 frame).

## Interchange round-trips

### Demo (synthetic) footage

| Format | Imported sequences | Video clips | Audio clips | Markers | Notes |
|---|---|---|---|---|---|
| XML | 1 | 2 (2.0 s + 2.0 s) | 2 | 2 | exact |
| OTIO | 1 | 2 | 2 | 2 | exact |
| FCPXML | 1 | 0 | 0 | 2 | sequence duration 0 |
| EDL | 1 | 2 (1.75 s + 2.25 s) | 2 | 2 | cut list splits at the dissolve; media reported offline |
| AAF | 1 | 0 | 0 | 2 | duration 0 |
| OMF | 1 | 0 | 0 | 0 | empty |

Inspection of the demo FCPXML shows why: every clip was written as
`<gap name="City_Night_Drive.mp4" …>` and there are **no `<asset>` or
`<asset-clip>` elements** — the synthetic demo media has no file on disk to
reference. AAF/OMF behave the same way for the same reason (no audio essence).

### Real on-disk media (`proof.mp4` 3 s + `audio.wav`)

| Format | Video | Audio | Markers | Import report |
|---|---|---|---|---|
| XML | 1 × 3.0 s | 1 × 3.0 s | 1 | linkedMedia 2 |
| FCPXML | 1 × 3.0 s | 1 × 3.0 s | 1 | linkedMedia 2; `<asset>` + `<asset-clip>` written |
| OTIO | 1 × 3.0 s | 1 × 3.0 s | 1 | linkedMedia 2 |
| EDL | 1 × 3.0 s | 1 × 3.0 s | 1 | "EDL has no frame rate; assumed 24 fps" |
| AAF | 1 × 3.0 s | 1 × 3.0 s | 1 | linkedMedia 2 |
| OMF | — | 1 × 3.0 s | 0 | audio-only by design |

So the demo losses are a **synthetic-media limitation, not a general round-trip
failure**. For FCPXML/AAF/OMF tests always use real files on disk.

## Sequence and marker data

- XML kept the 12-frame dissolve as a `transitionitem` and both markers with
  names/comments.
- EDL wrote events for V and A, a `D 012` dissolve and `* FROM CLIP NAME` /
  `* LOC` comments — but timings shift because EDL cannot express a centred
  dissolve; the second clip starts at 1.75 s on re-import.
- Captions are **not** carried by XML/FCPXML/OTIO/EDL/AAF/OMF exports; export
  them separately (`captions.export`) or burn them in.
- OMF has no video and does not carry markers.

## Practical rules

1. Choose **FCP7 XML or OTIO** for lossless round-trips back into FilmCraft.
2. Use **FCPXML** only with real media, and check the import report.
3. Treat **EDL** as a cut list (frame-rate assumption, dissolve timing changes).
4. **AAF/OMF** have never been validated in Avid/Pro Tools (the project's own
   docs say so); here they only round-trip back into FilmCraft.
5. Always inspect the `file.import` result:
   `{documents:[{format,linkedMedia,offlineMedia,report,sequences}],errors,items,sequences}`.
6. Export captions and markers separately if the next tool needs them.
