# FilmCraft 0.10.0 command reference

701 commands in 42 namespaces, read from the running engine (`command_list`) on 2026-10-22.
Params are shown exactly as the engine reports them; `?` marks an optional key.

## Key commands by task (start here)

| Task | Command | Params |
|---|---|---|
| new/open/save project | `file.newProject`, `file.open`, `file.saveAs` | `{name}`, `{path}`, `{path}` |
| import media | `file.import`, `media_import` (tool) | `{paths:[…], bin?, imageSequence?}` |
| demo footage | `file.importDemoFootage` | `{scene:"OceanSunset|Aurora|CityNight|Dunes|Plasma|Forest"}` |
| new sequence | `file.newSequence` | `{name,width,height,fps,sampleRate,video,audio,mix?}` |
| switch sequence | `sequence.open` | `{item}` (sequence id) |
| place clip | `timeline.place` | `{item, track:"V1", seconds|frame|time, duration?, sourceIn?, insert?, video?, audio?}` |
| select | `timeline.select` | `{clips:[id], linked?}` |
| razor | `timeline.razor` | `{time|frame|seconds, track?, clip?}` |
| trim / slip / slide / roll | `timeline.trim`, `timeline.slip`, `timeline.slide`, `timeline.roll` | `{clip, edge, delta|deltaFrames}` |
| rate stretch | `timeline.rateStretch` | `{clip, edge, delta}` |
| move | `timeline.move` | `{moves:[{clip,track,time}], insert?, linked?, copy?}` |
| delete | `edit.clear` (gap), `edit.rippleDelete` (closes gap) | `{clips?}` |
| undo/redo | `edit.undo`, `edit.redo` | `{}` |
| playhead | `playhead.set`, `playhead.step` | `{time|frame|seconds|timecode}`, `{frames}` |
| effect | `effects.apply`, `effects.setParam`, `effects.remove` | `{clips,effect}`, `{clip,effect,param,value,time?,keyframe?}`, `{clip,index}` |
| transition | `sequence.applyVideoTransition`, `sequence.setTransition`, `sequence.removeTransition` | `{clip,effect,frames,edge}`, `{transition,frames|duration,align}`, `{transitions:[id]}` |
| colour | `lumetri.applyPreset`, `lumetri.setSection`, `sequence.colorSettings` | `{name,clips}`, `{clip,section,on}`, `{workingSpace,…}` |
| markers | `markers.add`, `markers.addRange`, `markers.exportCsv` | `{time,name,comment,color}`, `{…,durationFrames}`, `{path}` |
| captions | `captions.newTrack`, `captions.add`, `captions.export` | `{format,name}`, `{track,text,seconds,durationSeconds}`, `{path,format,track}` |
| graphics | `graphics.newText`, `graphics.set`, `graphics.newShape`, `graphics.list` | `{text,position,size,…}`, `{clip,props}`, `{shape,position,size,…}` |
| masks | `masks.add`, `masks.list`, `masks.set` | `{clip,effect,shape,…}` |
| audio gain | `clip.audioGain`, `mixer.setStrip` | `{clips,mode,db}`, `{strip,volumeDb,muted}` |
| proxies | `media.createProxies`, `media.toggleProxies` | `{items,preset,attach,wait}`, `{enabled}` |
| multicam | `clip.createMulticam`, `multicam.inspect`, `multicam.cutToCamera` | `{items,name,method}`, `{}`, `{camera,time}` |
| TTS | `tts.create`, `tts.voices` | `{text,voice,dir,time,track}` |
| export | `file.exportMedia`, `file.exportFrame`, `file.exportInterchange` | see `references/recipes.md` §14 |
| jobs | `jobs.list`, `jobs.cancel` | `{}`, `{job}` |
| preferences | `prefs.get`, `prefs.set`, `prefs.schema` | `{key}`, `{key,value}`, `{category?}` |
| GUI only | `window.workspace.{editing,assembly,color,effects,audio}`, `window.toggleFullScreen` | `{}` |

MCP-only tools (not commands): `doc_inspect`, `project_inspect`,
`sequence_inspect`, `render_frame`, `render_preview`, `media_import`,
`command_list`, `command_run`, `command_batch`, and the `ui_*` tools.

## Namespaces

| namespace | n | covers |
|---|---|---|
| `audio` | 5 | audio settings |
| `captions` | 22 | caption tracks and cues |
| `clip` | 57 | clip properties, speed, enable, labels, nesting |
| `clipMixer` | 4 | per-clip mixer |
| `color` | 1 | color workspace |
| `command` | 1 | command palette |
| `edit` | 39 | selection, clipboard, undo helpers, delete/ripple |
| `effects` | 16 | video/audio effects |
| `essentialSound` | 9 | Essential Sound panel |
| `events` | 2 | event log |
| `export` | 19 | export queue/presets |
| `file` | 57 | projects, bins, import, save/open, export and interchange |
| `fonts` | 1 | font list |
| `graphics` | 82 | titles, shapes, masks, text layers |
| `help` | 1 | help |
| `history` | 1 | undo history |
| `jobs` | 2 | background job queue (export/render) |
| `labels` | 4 | label colours |
| `lumetri` | 7 | Lumetri colour |
| `lut` | 4 | LUTs |
| `markers` | 32 | sequence and clip markers |
| `masks` | 12 | masks |
| `media` | 17 | media status, relink, proxies |
| `mediaBrowser` | 10 | media browser |
| `mediaCache` | 2 | cache management |
| `metadata` | 2 | clip metadata |
| `mixer` | 20 | track/clip audio mixer |
| `multicam` | 35 | multicam sync and switching |
| `perf` | 1 | engine counters |
| `playhead` | 14 | playhead move/seek |
| `prefs` | 4 | preferences |
| `presets` | 7 | effect presets |
| `project` | 40 | project tree, bins, items, search, delete |
| `scopes` | 1 | scopes |
| `sequence` | 45 | sequence settings, tracks, transitions, nesting |
| `shortcuts` | 16 | keyboard shortcuts |
| `source` | 7 | source monitor |
| `state` | 1 | document state |
| `timeline` | 56 | timeline editing: place, razor, move, snap, zoom |
| `transcript` | 14 | transcripts |
| `trim` | 24 | trim, slip, slide, roll, rate stretch |
| `tts` | 7 | text to speech |

## All commands

### audio (5)

- `audio.toggleScrubbing` {}  (Shift+S)
- `audio.voiceover.settings` {"source":str?,"inputChannel":n?,"name":str?,"countdownSoundCues":bool?,"prerollSeconds":f64?,"postrollSeconds":f64?}
- `audio.voiceover.start` {"track":"A1"|id?,"time":ticks?,"preroll":seconds?}
- `audio.voiceover.stop` {"time":ticks?,"dir":str?,"discard":bool?}
- `audio.voiceover.sync` {"time":ticks?}

### captions (22)

- `captions.add` {"track":id|"C1"?,"text":str?,"time":ticks?,"seconds":f64?,"durationSeconds":f64=3}  (Cmd+Alt+C)
- `captions.delete` {"captions":[id]?,"ripple":bool=false}
- `captions.deleteTrack` {"track":id|"C1"}
- `captions.export` {"path":str,"format":"srt|vtt|scc|mcc|stl|ttml|dfxp"? (default: from the extension),"track":id|"C1"?,"dropFrame":bool=true}
- `captions.goTo` {"caption":id}
- `captions.hideAll` {}
- `captions.import` {"path":str,"name":str?}
- `captions.list` {"track":id|"C1"?}
- `captions.merge` {"captions":[id]?}
- `captions.move` {"captions":[id]?,"delta":ticks|"deltaFrames":i64}
- `captions.newTrack` {"format":"Subtitle|CEA-608|CEA-708|Teletext","name":str?,"language":str?}  (Cmd+Alt+A)
- `captions.next` {}  (Cmd+Alt+Down)
- `captions.previous` {}  (Cmd+Alt+Up)
- `captions.select` {"captions":[id],"add":bool?}
- `captions.setStyle` {"track":id|"C1","font":str?,"size":f32?,"color":"#rrggbb[aa]"?,"background":bool?,"backgroundColor":"#rrggbbaa"?,"align":"left|center|right"?,"anchor":"top|middle|bottom"?,"margin":0..0.45 (fraction of frame height)?,"lineSpacing":f32?,"outline":f32?,"outlineColor":str?,"reset":bool?}
- `captions.setText` {"caption":id?,"text":str?,"speaker":str|null?}
- `captions.setTimes` {"caption":id?,"startTime|startFrame|startSeconds|startTimecode":…,"endTime|endFrame|endSeconds|endTimecode":…}
- `captions.setTrack` {"track":id|"C1","name":str?,"format":str?,"language":str?,"enabled":bool?,"locked":bool?,"syncLock":bool?}
- `captions.showActiveOnly` {"track":id|"C1"?}
- `captions.showAll` {}
- `captions.split` {"caption":id?,"time":ticks?}
- `captions.trim` {"caption":id,"edge":"in|out","delta":ticks|"deltaFrames":i64}

### clip (57)

- `clip.audioChannels` {"items":[id]?,"format":"mono|stereo|5.1|adaptive","clips":[[channel]]?,"channels":[channel]?}  (Shift+G)
- `clip.audioGain` {"clips":[id]?,"mode":"set|adjust|normalizeMax|normalizeAll"?,"db":f64,"relative":bool?}  (G)
- `clip.audioPeak` {"clips":[id]?}
- `clip.automateToSequence` {"items":[id]?,"ordering":"sort|selection","placement":"sequentially|unnumberedMarkers","method":"insert|overwrite","overlapFrames":n=30,"stillFrames":n?,"videoTransition":bool=true,"audioTransition":bool=true,"ignoreAudio":bool=false,"ignoreVideo":bool=false}
- `clip.breakoutToMono` {"items":[id]?}
- `clip.clearPosterFrame` {"item":id?}  (Alt+P)
- `clip.createMulticam` {"items":[id]?,"name":str?,"method":"in|out|timecode|marker|audio","ignoreHours":bool?,"marker":str?,"offset":frames?,"audio":"camera1|all|switch","cameraNames":"clip|track|metadata","processedBin":bool?,"reference":item?}
- `clip.editOffline` {"item":id?,"mediaName":str?,"tapeName":str?,"description":str?,"scene":str?,"shot":str?,"logNote":str?}
- `clip.editSubclip` {"item":id?,"start":ticks?,"end":ticks?,"startFrame":i64?,"endFrame":i64?,"restrictTrims":bool?,"convertToMaster":bool?}
- `clip.enable` {"clips":[id]?}  (Shift+E)
- `clip.extractAudio` {"items":[id]?,"dir":str?}
- `clip.fieldOptions` {"clips":[id]?,"reverseFieldDominance":bool=false,"processing":"none|alwaysDeinterlace|flickerRemoval"}
- `clip.fillFrame` {"clips":[id]?}
- `clip.fitToFrame` {"clips":[id]?}
- `clip.frameHold` {"clips":[id]?,"time":ticks?}
- `clip.frameHoldOptions` {"clips":[id]?,"enabled":bool=true,"holdOn":"sourceTimecode|sequenceTime|in|out|playhead","time":ticks?,"timecode":str?,"holdFilters":bool=false}
- `clip.generateAudioWaveform` {"items":[id]?}
- `clip.group` {}  (Cmd+G)
- `clip.insertFrameHoldSegment` {"clip":id?,"time":ticks?,"seconds":f64=2}
- `clip.interpretFootage` {"items":[id]?,"colorSpace":"auto"|"<color space id>"?,"pixelAspect":[num,den]|"file"?}
- `clip.link` {"clips":[id]?}  (Cmd+L)
- `clip.makeSubclip` {"item":id?,"clip":id?,"name":str?,"start":ticks?,"end":ticks?,"startFrame":i64?,"endFrame":i64?,"restrictTrims":bool=true}  (Cmd+U)
- `clip.mergeClips` {"items":[id]?,"method":"in|out|timecode|marker|audio","name":str?,"removeVideoAudio":bool?,"ignoreHours":bool?,"marker":str?,"offset":frames?}
- `clip.modifyTimecode` {"item":id?,"timecode":"HH:MM:SS:FF"?,"frame":i64?,"tapeName":str?,"reset":bool?}
- `clip.multicamEnable` {"clips":[id]?,"enabled":bool?}
- `clip.multicamFlatten` {"clips":[id]?}
- `clip.nest` {"name":str}
- `clip.nudgeVolumeDown1` {}
- `clip.nudgeVolumeDown3` {}
- `clip.nudgeVolumeUp1` {}
- `clip.nudgeVolumeUp3` {}
- `clip.remix` {"clip":id?,"duration":ticks?,"seconds":f64?,"frame":n?,"timecode":str?,"segments":0..100?,"variations":0..100?}
- `clip.remix.enable` {"clip":id?}
- `clip.remix.properties` {"clip":id?,"duration":ticks?,"seconds":f64?,"frame":n?,"timecode":str?,"segments":0..100?,"variations":0..100?}
- `clip.remix.revert` {"clip":id?}
- `clip.rename` {"clip":id?,"item":id?,"name":str}
- `clip.replaceFromBin` {"clips":[id]?,"item":id?,"keepSourceIn":bool=false}
- `clip.replaceFromSource` {"clips":[id]?}
- `clip.replaceFromSourceMatchFrame` {"clips":[id]?}
- `clip.restoreCaptionsFromSource` {}
- `clip.revealInProject` {"clip":id?}
- `clip.scaleToFrameSize` {}
- `clip.sceneEditDetection` {"clips":[id]?,"sensitivity":0..100=50,"minShotFrames":n=6,"applyCuts":bool=true,"createSubclips":bool=false,"generateMarkers":bool=false,"wait":bool=false}
- `clip.setPosterFrame` {"item":id?,"time":ticks?}  (Cmd+P)
- `clip.setTimeInterpolation` {"clips":[id]?,"mode":"frameSampling|frameBlending|opticalFlow"}
- `clip.sourceSettings` {"item":id?}
- `clip.speedDuration` {"clips":[id]?,"speed":percent=100,"reverse":bool,"ripple":bool,"interpolation":"frameSampling|frameBlending|opticalFlow"?}  (Cmd+R)
- `clip.synchronize` {"method":"in|out|timecode|marker|audio","clips":[id]?,"reference":clip?,"track":"V1"|"A1"?,"ignoreHours":bool?,"marker":str?,"offset":frames?}
- `clip.timeInterpolation.frameBlending` {"clips":[id]?}
- `clip.timeInterpolation.frameSampling` {"clips":[id]?}
- `clip.timeInterpolation.opticalFlow` {"clips":[id]?}
- `clip.ungroup` {}  (Cmd+Shift+G)
- `clip.updateMetadata` {"items":[id]?}
- `clip.volumeDown` {}  ([)
- `clip.volumeDownMany` {}  (Shift+[)
- `clip.volumeUp` {}  (])
- `clip.volumeUpMany` {}  (Shift+])

### clipMixer (4)

- `clipMixer.release` {"track":"A1"|id,"lane":"volume|pan","time":ticks?}
- `clipMixer.set` {"clip":id,"effect":"volume"|"panner","param":"level"|"balance","value":f64,"keyframe":bool?,"time":ticks?,"begin":bool?}
- `clipMixer.setMode` {"track":"A1"|id,"mode":"Off|Read|Latch|Touch|Write"}
- `clipMixer.touch` {"track":"A1"|id,"lane":"volume|pan","value":f64,"time":ticks?}

### color (1)

- `color.spaces` {}

### command (1)

- `command.list` {}

### edit (39)

- `edit.clear` {"clips":[id]?}  (Backspace)
- `edit.consolidateDuplicates` {}
- `edit.copy` {}  (Cmd+C)
- `edit.cut` {}  (Cmd+X)
- `edit.deselectAll` {}  (Cmd+Shift+A)
- `edit.duplicate` {}  (Cmd+Shift+/)
- `edit.editOriginal` {"items":[id]?}  (Cmd+E)
- `edit.find` {"scope":"project|timeline"?,"column":str?,"operator":"contains|matches|beginsWith|endsWith|doesNotContain"?,"text":str?,"rows":[{"column":str,"operator":str,"text":str}]?,"matchAll":bool=true,"caseSensitive":bool=false,"in":"all|clips|markers"?}  (Cmd+F)
- `edit.findNext` {}
- `edit.label` {"label":"Violet|Iris|…"}
- `edit.label.blue` {"items":[id]?,"clips":[id]?}
- `edit.label.brown` {"items":[id]?,"clips":[id]?}
- `edit.label.caribbean` {"items":[id]?,"clips":[id]?}
- `edit.label.cerulean` {"items":[id]?,"clips":[id]?}
- `edit.label.forest` {"items":[id]?,"clips":[id]?}
- `edit.label.green` {"items":[id]?,"clips":[id]?}
- `edit.label.iris` {"items":[id]?,"clips":[id]?}
- `edit.label.lavender` {"items":[id]?,"clips":[id]?}
- `edit.label.magenta` {"items":[id]?,"clips":[id]?}
- `edit.label.mango` {"items":[id]?,"clips":[id]?}
- `edit.label.purple` {"items":[id]?,"clips":[id]?}
- `edit.label.rose` {"items":[id]?,"clips":[id]?}
- `edit.label.tan` {"items":[id]?,"clips":[id]?}
- `edit.label.teal` {"items":[id]?,"clips":[id]?}
- `edit.label.violet` {"items":[id]?,"clips":[id]?}
- `edit.label.yellow` {"items":[id]?,"clips":[id]?}
- `edit.paste` {}  (Cmd+V)
- `edit.pasteAttributes` {"clips":[id]?,"motion":bool=true,"opacity":bool=true,"timeRemapping":bool=true,"volume":bool=true,"channelVolume":bool=true,"panner":bool=true,"effects":bool|[effectId]=true,"scaleTimes":bool=true}  (Cmd+Alt+V)
- `edit.pasteInsert` {}  (Cmd+Shift+V)
- `edit.pasteMedia` {"paths":[str],"insert":bool?,"place":bool=true,"bin":binId?}
- `edit.redo` {}  (Cmd+Shift+Z)
- `edit.removeAttributes` {"clips":[id]?,"motion":bool=true,"opacity":bool=true,"timeRemapping":bool=true,"volume":bool=true,"channelVolume":bool=true,"panner":bool=true,"effects":bool|[effectId]=true}
- `edit.removeUnused` {}
- `edit.rippleDelete` {"clips":[id]?}  (Shift+Delete)
- `edit.rippleDeleteHead` {"clips":[id]?,"clip":id?}
- `edit.selectAll` {}  (Cmd+A)
- `edit.selectAllMatching` {"clips":[id]?}
- `edit.selectLabelGroup` {}
- `edit.undo` {}  (Cmd+Z)

### effects (16)

- `effects.addKeyframe` {"clip":id,"effect":str|index,"param":str,"mask":n?,"time":ticks?}
- `effects.apply` {"clips":[id]?,"effect":"gaussian_blur|Gaussian Blur|…"}
- `effects.deleteKeyframe` {"clip":id,"effect":str|index,"param":str,"mediaTime":ticks}
- `effects.list` {"kind":"Video"|"Audio"|"VideoTransition"|"AudioTransition"?,"folder":"Video Transitions/Wipe"?,"detail":bool?}
- `effects.moveKeyframe` {"clip":id,"effect":str|index,"param":str,"mediaTime":ticks,"to":ticks,"value":any?,"merge":bool?,"begin":bool?}
- `effects.moveKeyframes` {"keyframes":[{"clip":id,"effect":index,"param":str,"mask":n?,"time":mediaTicks}],"delta":timelineTicks}
- `effects.remove` {"clip":id,"index":n}
- `effects.reset` {"clip":id,"index":n}
- `effects.resetParam` {"clip":id,"effect":str|index,"param":str}
- `effects.select` {"clip":id,"effect":index|id}|{"none":true}
- `effects.setDefaultTransition` {"effect":"constant_power|constant_gain|exponential_fade|<video transition>"}
- `effects.setInterpolation` {"clip":id,"effect":str|index,"param":str,"mediaTime":ticks,"interpolation":"linear|bezier|autoBezier|continuousBezier|hold|easeIn|easeOut"}
- `effects.setKeyframe` {"clip":id,"effect":str|index,"param":str,"mediaTime":ticks,"value":any?,"inInfluence":0..1?,"outInfluence":0..1?,"merge":bool?,"begin":bool?}
- `effects.setParam` {"clip":id,"effect":"motion"|index,"param":str,"mask":n?,"value":num|[x,y]|"#rrggbb"|bool|path|"option name" (a choice takes its index or its name),"time":ticks? (where the keyframe goes when the parameter is animated, kept there even outside the clip; default: the playhead, pinned to the clip; a parameter that is not animated gets a new static value whatever the time),"keyframe":bool? (true: write a keyframe at `time` and animate the parameter),"merge":bool|key?,"begin":bool?}
- `effects.toggleAnimation` {"clip":id,"effect":str|index,"param":str,"mask":n?}
- `effects.toggleEnabled` {"clip":id,"index":n}

### essentialSound (9)

- `essentialSound.applyPreset` {"clips":[id]?,"preset":str,"type":"dialogue|music|sfx|ambience"?}
- `essentialSound.autoMatch` {"clips":[id]?,"target":lufs?}
- `essentialSound.clearType` {"clips":[id]?}
- `essentialSound.deletePreset` {"name":str,"type":"dialogue|music|sfx|ambience"?}
- `essentialSound.generateDucking` {"clips":[id]?}
- `essentialSound.inspect` {"clips":[id]?}
- `essentialSound.savePreset` {"clips":[id]?,"name":str}
- `essentialSound.set` {"clips":[id]?,"key":"repair.noise.on|repair.noise.amount|repair.humHz|clarity.eqPreset|creative.reverbPreset|ducking.reduceDb|volume.levelDb|mute|…","value":any,"values":{key:value}?,"begin":bool?}
- `essentialSound.setType` {"clips":[id]?,"type":"dialogue|music|sfx|ambience"}

### events (2)

- `events.clear` {}
- `events.list` {"level":"info|warning|error"?,"since":id?}

### export (19)

- `export.formats` {}
- `export.presets.delete` {"name":str}
- `export.presets.export` {"path":str,"names":[str]?}
- `export.presets.favorite` {"name":str,"favorite":bool?}
- `export.presets.get` {"name":str}
- `export.presets.import` {"path":str}
- `export.presets.list` {"query":str?,"category":str?,"format":str?,"favorites":bool?}
- `export.presets.save` {"name":str,"from":str?,"settings":ExportSettings?,"category":str?,"description":str?,"overwrite":bool=true, …flat overrides}
- `export.queue.add` {…settings params,"path":str|dir?,"sequences":[id]?,"ranges":[range]?,"start":bool?,"wait":bool?}  (Alt+Shift+M)
- `export.queue.cancel` {"id":id?,"wait":bool?}
- `export.queue.clear` {"all":bool=false}
- `export.queue.list` {}
- `export.queue.move` {"id":id,"to":index?,"by":int?}
- `export.queue.remove` {"id":id}
- `export.queue.retry` {"id":id,"start":bool?,"wait":bool?}
- `export.queue.start` {"wait":bool=false}
- `export.queue.stop` {}
- `export.quick` {"preset":str?,"path":str?,"wait":bool?, …settings params}
- `export.resolve` {…settings params, "path":str?}

### file (57)

- `file.autoSaveNow` {}
- `file.autoSaveStatus` {}
- `file.close` {"item":id?}  (Cmd+W)
- `file.closeAllOtherProjects` {}
- `file.closeAllProjects` {"force":bool?}
- `file.closeProject` {"force":bool?}  (Cmd+Shift+W)
- `file.discardRecovery` {"id":str?,"all":bool?}
- `file.exportAaf` {"path":str,"sequence":id?,"mixdownVideo":bool?,"mixdownFormat":"mov|mxf"?,"breakoutToMono":bool?,"audio":"embedded|separate|linked"?,"audioFormat":"wav|aiff|mxf"?,"sampleRate":int?,"bitDepth":"16|24"?,"trimAudio":bool?,"handles":frames?,"renderAudioEffects":bool?,"smallSectors":bool?}
- `file.exportAle` {"path":str,"items":[id]?}
- `file.exportEdl` {"path":str}
- `file.exportFcp7Xml` {"path":str}
- `file.exportFcpxml` {"path":str}
- `file.exportFrame` {"path":str?,"format":"png|jpeg|tiff|bmp"?,"depth":8|16?,"import":bool?,"target":"source|program"?,"item":id?,"sequence":id?,"time":ticks?}
- `file.exportGraphicsTemplate` as graphics.template.export
- `file.exportInterchange` {"format":"edl|xml|fcpxml|otio|aaf|omf"=xml,"path":str,"sequence":id?}
- `file.exportMedia` {"path":str,"preset":str?,"settings":ExportSettings?,"format":"h264|hevc|prores|dnxhr|apv|mjpeg|mxf-op1a|mxf-opatom|png|tiff|bmp|jpg|tga|dpx|exr|gif|wav|aiff|aac|flac"?,"audioCodec":"auto|aac|pcm|flac"?,"flacLevel":0..8=5,"width":u32?,"height":u32?,"fps":f64?,"bitrateKbps":u32?,"bitrateMode":"cbr|vbr1Pass|vbr2Pass|crf"?,"crf":0..51=23,"hardwareEncoding":"off|auto"?,"scale":f32=1,"audio":bool=true,"quality":0..100,"burnCaptions":bool=false,"alpha":bool=false,"exrCompression":"none|rle|zips|zip"?,"captionSidecar":"srt|vtt"?,"loudnessLufs":f64?,"proresProfile":"proxy|lt|standard|hq|4444|4444xq"?,"dnxProfile":"lb|sq|hq|hqx"?,"apvProfile":"422-10|422-12|444-10|444-12"?,"mxfVideoCodec":"dnxhr|proRes|h264"?,"sequence":id?,"range":"entire|inOut|workArea|custom"?,"startSeconds":f64?,"endSeconds":f64?,"wait":bool=false}
- `file.exportOmf` {"path":str,"sequence":id?,"title":str?,"audio":"embedded|separate"?,"audioFormat":"wav|aiff"?,"sampleRate":int?,"bitDepth":"16|24"?,"trimAudio":bool?,"handles":frames?,"renderAudioEffects":bool?,"breakoutToMono":bool?}
- `file.exportOtio` {"path":str}
- `file.exportSelectionProject` {"path":str,"items":[id]?}
- `file.import` {"paths":[str],"bin":binId?,"imageSequence":bool?,"replace":bool?}  (Cmd+I)
- `file.importAaf` {"path":str}
- `file.importDemoFootage` {"scene":"OceanSunset|Aurora|CityNight|Dunes|Plasma|Forest"}
- `file.importFromMediaBrowser` {"paths":[str]?,"imageSequence":bool?}  (Cmd+Alt+I)
- `file.importImageSequence` {"path":str,"bin":binId?}
- `file.listAutoSaves` {}
- `file.mediaProperties` {"items":[id]?}  (Cmd+Shift+H)
- `file.mediaPropertiesFile` {"path":str}
- `file.newAdjustmentLayer` {"seconds":f64=5}
- `file.newBarsAndTone` {"seconds":f64=10}
- `file.newBin` {"name":str,"parent":binId?}  (Cmd+B)
- `file.newBinFromSelection` {"items":[id]?,"name":str?}  (Shift+B)
- `file.newBlackVideo` {"seconds":f64}
- `file.newColorMatte` {"color":"#rrggbb","seconds":f64}
- `file.newCountingLeader` {}
- `file.newOfflineFile` {"name":str?,"fileName":str?,"tapeName":str?,"video":bool=true,"audio":bool=true,"width":u32?,"height":u32?,"fps":f64?,"sampleRate":u32=48000,"channels":u32=2,"timecode":"HH:MM:SS:FF"?,"seconds":f64=10,"description":str?}
- `file.newProject` {"name":str}  (Cmd+Alt+N)
- `file.newProjectFromTemplate` {"template":name|path,"name":str?}
- `file.newSearchBin` {"name":str?,"column":str?,"operator":str?,"text":str?,"rows":[..]?,"matchAll":bool?,"caseSensitive":bool?}
- `file.newSequence` {"name":str,"width":u32=1920,"height":u32=1080,"fps":f64=23.976,"sampleRate":u32=48000,"video":n=3,"audio":n=3,"mix":"Stereo|Mono|5.1|Adaptive"?,"trackType":"Standard|Mono|5.1|Adaptive"?,"fromItem":itemId?,"fromItems":[itemId]?}  (Cmd+N)
- `file.newSequenceFromClip` {"items":[id]?}
- `file.newTransparentVideo` {}
- `file.open` {"path":str}  (Cmd+O)
- `file.openDemoProject` {}
- `file.projectManager` {"destination":str,"mode":"collect|consolidate","sequences":[id]?,"excludeUnused":bool=true,"handles":frames=30,"preset":"prores_lt|prores_hq|h264|…","includeProxies":bool,"includePreviews":bool=false,"projectName":str?,"dryRun":bool=false,"overwrite":bool=false,"wait":bool=false}
- `file.projectSettings.general` {"renderer":"gpu|software"?,"videoDisplay":"timecode|feet35|feet16|frames"?,"audioDisplay":"samples|milliseconds"?,"captureFormat":"DV|HDV"?,"titleSafe":[h,v]?,"actionSafe":[h,v]?}
- `file.projectSettings.scratchDisks` {"captured":path|null?,"videoPreviews":path|null?,"audioPreviews":path|null?,"autoSave":path|null?}
- `file.recover` {"id":str?}
- `file.recoveryList` {}
- `file.replaceFonts` {"from":family|{"family","style"?},"to":family|{"family","style"?},"toStyle":str?}
- `file.reveal` {"items":[id]?}
- `file.revert` {}
- `file.save` {"path":str?}  (Cmd+S)
- `file.saveAll` {}
- `file.saveAs` {"path":str}  (Cmd+Shift+S)
- `file.saveAsTemplate` {"name":str?,"path":str?}
- `file.saveCopy` {"path":str}  (Cmd+Alt+S)
- `file.templates` {}

### fonts (1)

- `fonts.list` {"system":bool=true (scan the system font folders)}

### graphics (82)

- `graphics.align` {"clip":id?,"layers":[n]?,"align":"left|hcenter|right|top|vcenter|bottom","to":"frame|group|selection"="frame" (frame: each layer; group: the layers' union; one layer always aligns to the frame)}
- `graphics.alignFrame.bottom` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignFrame.hcenter` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignFrame.left` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignFrame.right` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignFrame.top` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignFrame.vcenter` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignGroup.bottom` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignGroup.hcenter` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignGroup.left` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignGroup.right` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignGroup.top` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignGroup.vcenter` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignSelection.bottom` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignSelection.hcenter` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignSelection.left` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignSelection.right` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignSelection.top` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignSelection.vcenter` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.alignTextCenter` {}  (Cmd+Shift+C)
- `graphics.alignTextLeft` {}  (Cmd+Shift+L)
- `graphics.alignTextRight` {}  (Cmd+Shift+R)
- `graphics.arrangeLayer` {"clip":id?,"layer":n?,"to":"front|back|forward|backward"|index}
- `graphics.bringForward` {"clip":id?,"layer":n?}  (Cmd+])
- `graphics.bringToFront` {"clip":id?,"layer":n?}  (Cmd+Shift+])
- `graphics.deleteLayer` {"clip":id?,"layer":n?}
- `graphics.distribute` {"clip":id?,"layers":[n] (3 or more)?,"axis":"horizontal|vertical","space":bool=false (equal gaps instead of equal centre spacing)}
- `graphics.distributeHorizontally` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.distributeSpaceHorizontally` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.distributeSpaceVertically` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.distributeVertically` {"clip":id?,"layers":[n]? (default: the selected layers; selected video clips move by Motion Position)}
- `graphics.fontSizeDown` {}  (Cmd+Alt+Left)
- `graphics.fontSizeDown5` {}  (Cmd+Alt+Shift+Left)
- `graphics.fontSizeUp` {}  (Cmd+Alt+Right)
- `graphics.fontSizeUp5` {}  (Cmd+Alt+Shift+Right)
- `graphics.fonts.used` {}
- `graphics.leadingDown` {}  (Alt+Down)
- `graphics.leadingDown5` {}  (Alt+Shift+Down)
- `graphics.leadingUp` {}  (Alt+Up)
- `graphics.leadingUp5` {}  (Alt+Shift+Up)
- `graphics.list` {"clip":id?}
- `graphics.newEllipse` {"position":[x,y]?,"size":[w,h]=[400,200],"clip":id?,"seconds":f64=5,"track":index?,"time":ticks?}  (Cmd+Alt+E)
- `graphics.newFromFile` {"path":str,"time":ticks?,"track":index?} (imports the image or video and places it above the clips at the playhead)
- `graphics.newPolygon` {"position":[x,y]?,"size":[w,h]=[300,300],"sides":n=6,"clip":id?,"seconds":f64=5,"track":index?,"time":ticks?}
- `graphics.newRectangle` {"position":[x,y]?,"size":[w,h]=[400,200],"clip":id?,"seconds":f64=5,"track":index?,"time":ticks?}  (Cmd+Alt+R)
- `graphics.newShape` {"shape":"rectangle|ellipse|polygon|path","position":[x,y]? (the shape's centre),"size":[w,h]=[400,200],"points":[[x,y],…]?,"clip":id? (add the shape to this graphic),"seconds":f64=5,"track":index?,"time":ticks?}
- `graphics.newText` {"text":str="New Text","position":[x,y]? (point text: its alignment point on the first baseline; with `box`: the box's top-left corner),"box":[w,h]? (paragraph text wrapped in a box this size),"clip":id?,"newClip":bool?,"vertical":bool=false,"size":px=100,"font":str?,"fontStyle":str?,"seconds":f64=5,"track":index?,"time":ticks?}  (Cmd+T)
- `graphics.newVerticalText` {"text":str="New Text","position":[x,y]?,"clip":id?,"size":px=100,"seconds":f64=5,"time":ticks?}
- `graphics.nudgeDown` {}
- `graphics.nudgeDown5` {}
- `graphics.nudgeLeft` {}
- `graphics.nudgeLeft5` {}
- `graphics.nudgeRight` {}
- `graphics.nudgeRight5` {}
- `graphics.nudgeUp` {}
- `graphics.nudgeUp5` {}
- `graphics.pin` {"clip":id?,"layer":n|name?,"to":"frame"|"none"|layer index|layer name,"edges":["left","top","right","bottom"]|"all"="all"}
- `graphics.resetAllParameters` {"clip":id?,"layers":[n]? (default: the selected layers, else all)}
- `graphics.resetDuration` {"clip":id?,"seconds":f64=5 (the default graphic duration; limited by the next clip on the track)}
- `graphics.selectLayer` {"clip":id?,"layers":[n]}
- `graphics.selectNextGraphic` {}
- `graphics.selectNextLayer` {}  (Cmd+Alt+])
- `graphics.selectPreviousGraphic` {}
- `graphics.selectPreviousLayer` {}  (Cmd+Alt+[)
- `graphics.sendBackward` {"clip":id?,"layer":n?}  (Cmd+[)
- `graphics.sendToBack` {"clip":id?,"layer":n?}  (Cmd+Shift+[)
- `graphics.set` {"clip":id?,"layer":n|name?,"props":{"font":"Inter","font_style":"Bold","size":120,"align":"center","tracking":50,"leading":0,"fill_color":"#ffcc00","stroke":true,"stroke_width":6,"background":true,"shadow":true,"position":[x,y],"scale":100,"rotation":0,"opacity":100,…},"time":ticks?,"merge":bool?,"begin":bool?}
- `graphics.setCharStyle` {"clip":id?,"layer":n|name?,"start":char=0,"end":char=len,"style":{"font":str,"fontStyle":str,"size":px,"color":"#rrggbb","bold":bool,"italic":bool,"underline":bool,"tracking":n,"baselineShift":px,"caps":"normal|all caps|small caps"},"clear":bool? (remove styles from the range),"merge":bool?,"begin":bool? (start a new undo gesture)}
- `graphics.setResponsiveTime` {"clip":id?,"introFrames":n?,"outroFrames":n? (or introSeconds / outroSeconds, or ticks as intro / outro)}
- `graphics.setRoll` {"clip":id?,"mode":"off|roll|crawlLeft|crawlRight"?,"startOffScreen":bool?,"endOffScreen":bool?,"prerollFrames":n?,"easeInFrames":n?,"easeOutFrames":n?,"postrollFrames":n? (or …Seconds, or ticks as preroll/easeIn/easeOut/postroll)}
- `graphics.setText` {"clip":id?,"layer":n|name?,"text":str,"merge":bool? (coalesce with the previous Edit Text undo step)}
- `graphics.setTextType` {"clip":id?,"layer":n|name?,"type":"point|paragraph" (point: no box, handles scale the text; paragraph: the text wraps in a box that handles resize)}
- `graphics.template.apply` {"template":id|name|path,"values":{control id or name: value}?,"time":ticks?,"track":index?}
- `graphics.template.controls` {"clip":id?}
- `graphics.template.export` {"clip":id?,"name":str,"category":str="My Templates","description":str?,"controls":[{"layer":n|name,"param":"text|fill_color|size|font|position|enabled|…","name":str?,"kind":"text|color|slider|checkbox|font|position"?,"min":f64?,"max":f64?,"id":str?}]? (default: each text layer's text),"path":str? (default: the user templates folder),"embedFonts":bool=false,"fontLicense":str?}
- `graphics.template.install` {"path":str (a .fcgt file; Adobe .mogrt files are refused)}
- `graphics.template.list` {"query":str? (search names, categories, descriptions, tags),"category":str?,"source":"builtin|user"?}
- `graphics.template.remove` {"template":id|name (a user template)}
- `graphics.template.set` {"clip":id?,"control":id|name,"value":any} or {"clip":id?,"values":{control: value}}
- `graphics.template.thumbnail` {"template":id|name|path,"width":px=320,"path":str? (write a PNG there; else returned as pngBase64)}
- `graphics.upgradeCaption` {"captions":[id]? (default: the selected captions, else the one under the playhead)}
- `graphics.upgradeToSourceGraphic` {"clip":id?}

### help (1)

- `help.systemReport` {}

### history (1)

- `history.list` {}

### jobs (2)

- `jobs.cancel` {"job":id}
- `jobs.list` {}

### labels (4)

- `labels.deletePreset` {"name":str}
- `labels.exportPreset` {"path":str}
- `labels.importPreset` {"path":str}
- `labels.presets` {}

### lumetri (7)

- `lumetri.applyMatch` {"clip":id?,"referenceTime":ticks?|"referenceFrame":n?|"referenceTimecode":str?,"faceDetection":bool=true}
- `lumetri.applyPreset` {"name":str,"clips":[id]?}
- `lumetri.presetThumbnails` {"folder":str?,"names":[str]?,"width":n=160,"columns":n=4,"path":str?}
- `lumetri.presets` {"folder":str?}
- `lumetri.setInputLut` {"clip":id?,"lut":"lib:<id>"|"builtin:<id>"|""?,"path":str?}
- `lumetri.setLook` {"clip":id?,"lut":"lib:<id>"|"builtin:<id>"|""?,"path":str?}
- `lumetri.setSection` {"clip":id?,"section":"basic"|"creative"|"curves"|"wheels"|"hsl"|"vignette","on":bool?}

### lut (4)

- `lut.export` {"lut":"lib:<id>"|"builtin:<id>","path":str,"format":"cube"|"3dl"?}
- `lut.import` {"path":str,"name":str?}
- `lut.list` {}
- `lut.remove` {"id":str}

### markers (32)

- `markers.add` {"target":"program|source","time":ticks?,"name":str?,"comment":str?,"color":label?,"durationFrames":i64?}  (M)
- `markers.addChapter` {"time":ticks?,"name":str?,"comment":str?,"color":label?}
- `markers.addFlashCue` {"time":ticks?,"name":str?,"comment":str?,"color":label?}
- `markers.addRange` {"time":ticks?,"durationFrames":i64=1s,"duration":ticks?,"name":str?,"comment":str?,"color":label?}
- `markers.addRangeInOut` {"name":str?,"comment":str?,"color":label?}  (Ctrl+M)
- `markers.clearAll` {"target":"program|source"}  (Cmd+Alt+Shift+M)
- `markers.clearCurrent` {"target":"program|source"}  (Cmd+Alt+M)
- `markers.clearIn` {"target":"program|source"}  (Cmd+Shift+I)
- `markers.clearInOut` {"target":"program|source"}  (Cmd+Shift+X)
- `markers.clearOut` {"target":"program|source"}  (Cmd+Shift+O)
- `markers.copyPasteIncludesSequenceMarkers` {"on":bool?}
- `markers.edit` {"target":"program|source","marker":id,"name":str?,"comment":str?,"color":label?,"durationFrames":i64?}
- `markers.exportCsv` {"path":str} (all markers in the active sequence)
- `markers.filterColors` {"hidden":[label]}|{"color":label,"visible":bool?}
- `markers.goNext` {"target":"program|source"}  (Shift+M)
- `markers.goPrev` {"target":"program|source"}  (Cmd+Shift+M)
- `markers.goToIn` {"target":"program|source"}  (Shift+I)
- `markers.goToOut` {"target":"program|source"}  (Shift+O)
- `markers.goToSplitAudioIn` {"target":"program|source"}
- `markers.goToSplitAudioOut` {"target":"program|source"}
- `markers.goToSplitVideoIn` {"target":"program|source"}
- `markers.goToSplitVideoOut` {"target":"program|source"}
- `markers.markClip` {}  (X)
- `markers.markIn` {"time":ticks?,"frame":i64?,"seconds":f64?,"timecode":str?,"target":"program|source"}  (I)
- `markers.markOut` {"time":ticks?,"frame":i64?,"seconds":f64?,"timecode":str?,"target":"program|source"}  (O)
- `markers.markSelection` {}  (/)
- `markers.markSplitAudioIn` {"time":ticks?,"frame":i64?,"seconds":f64?,"timecode":str?,"target":"program|source"}
- `markers.markSplitAudioOut` {"time":ticks?,"frame":i64?,"seconds":f64?,"timecode":str?,"target":"program|source"}
- `markers.markSplitVideoIn` {"time":ticks?,"frame":i64?,"seconds":f64?,"timecode":str?,"target":"program|source"}
- `markers.markSplitVideoOut` {"time":ticks?,"frame":i64?,"seconds":f64?,"timecode":str?,"target":"program|source"}
- `markers.rippleSequenceMarkers` {"on":bool?}
- `markers.showAllMarkerColors` {}

### masks (12)

- `masks.add` {"clip":id?,"effect":index|id?="opacity","shape":"ellipse"|"polygon"|"rectangle"|"bezier","path":[[x,y]…]|{vertices}?,"center":[x,y]?,"size":[w,h]?,"cornerRadius":px?}
- `masks.addVertex` {"clip":id?,"effect":index|id?,"mask":n?,"after":n,"at":[x,y]}
- `masks.list` {"clip":id?,"time":ticks?}
- `masks.moveVertex` {"clip":id?,"effect":index|id?,"mask":n?,"vertex":n,"handle":"point"|"in"|"out"?,"to":[x,y]?|"delta":[dx,dy]?,"breakHandles":bool?,"merge":key?}
- `masks.remove` {"clip":id?,"effect":index|id?,"mask":n?}
- `masks.removeVertex` {"clip":id?,"effect":index|id?,"mask":n?,"vertex":n}
- `masks.roundCorners` {"clip":id?,"effect":index|id?,"mask":n?,"radius":px,"vertices":[n]?}
- `masks.select` {"clip":id,"effect":index|id,"mask":n}|{"none":true}
- `masks.set` {"clip":id?,"effect":index|id?,"mask":n?,"name":str?,"inverted":bool?,"mode":"none|add|subtract|intersect|lighten|darken|difference"?,"trackMethod":"position|positionRotation|positionScaleRotation"?,"feather":px?,"opacity":pct?,"expansion":px?,"path":path?,"time":ticks?,"merge":key?}
- `masks.toggleVertexSmooth` {"clip":id?,"effect":index|id?,"mask":n?,"vertex":n}
- `masks.track` {"clip":id?,"effect":index|id?,"mask":n?,"direction":"forward"|"backward"?,"frames":n?,"method":"position|positionRotation|positionScaleRotation"?,"wait":bool?}
- `masks.translate` {"clip":id?,"effect":index|id?,"mask":n?,"delta":[dx,dy],"merge":key?}

### media (17)

- `media.attachProxies` {"item":id,"path":str}|{"items":[id],"paths":[str]},"force":bool=false
- `media.autoRelink` {"from":str,"to":str}|{"folder":str} + match options
- `media.colorInfo` {"item":id}
- `media.createProxies` {"items":[id]?,"preset":"prores_proxy_quarter|prores_proxy_half|prores_lt_half|h264_quarter|h264_half","destination":str?,"attach":bool=true,"wait":bool=false}
- `media.detachProxies` {"items":[id]?}
- `media.findMissing` {}
- `media.linkMedia` {}  (opens the Link Media dialog; agents use media.relink / media.autoRelink)
- `media.makeOffline` {"items":[id]?,"deleteFiles":bool=false}
- `media.offlineAll` {}  (leave every missing file offline and close the Link Media dialog)
- `media.proxyPresets` {}
- `media.reconnectFullRes` {"item":id,"path":str}
- `media.refreshChanged` {}
- `media.relink` {"item":id,"path":str,"force":bool=false,"relinkOthers":bool=true,"alignTimecode":bool=false,"match":{"fileName":bool,"extension":bool,"clipId":bool,"duration":bool,"mediaStart":bool,"metadata":bool}?}
- `media.replaceFootage` {"item":id,"path":str}
- `media.search` {"folder":str,"item":id?,"exactName":bool=true}
- `media.status` {"item":id?}
- `media.toggleProxies` {"enabled":bool?}

### mediaBrowser (10)

- `mediaBrowser.clearRecent` {}
- `mediaBrowser.favorite` {"path":str?,"remove":bool?}
- `mediaBrowser.import` {"paths":[str]?,"bin":binId?,"imageSequence":bool?}
- `mediaBrowser.list` {"path":str?,"fileTypes":str?}
- `mediaBrowser.navigate` {"path":str} | {"back":true} | {"forward":true} | {"up":true}
- `mediaBrowser.openInSource` {"path":str?}
- `mediaBrowser.probe` {"path":str}
- `mediaBrowser.roots` {}
- `mediaBrowser.select` {"paths":[str]}
- `mediaBrowser.settings` {"fileTypes":"all|video|audio|image|project|caption|<ext>"?,"view":"list|thumbnails"?,"columns":[str]?,"importAsImageSequence":bool?,"hoverScrub":bool?,"thumbnailSize":f32?}

### mediaCache (2)

- `mediaCache.clean` {"all":bool?}
- `mediaCache.info` {}

### metadata (2)

- `metadata.get` {"item":id?,"clip":id?}
- `metadata.set` {"item":id?,"clip":id?,"field":"Name|Label|Description|Scene|Shot|Log Note|Comment|Tape Name|Client|Camera Angle|…","value":str} | {"item":id?,"fields":{name:str}}

### mixer (20)

- `mixer.addInsert` {"strip":"A1"|"S1"|"Mix"|id,"effect":str,"slot":n?,"postFader":bool?}
- `mixer.addSend` {"strip":"A1"|"S1"|id,"target":"S1"|id,"levelDb":f64?,"preFader":bool?,"pan":f64?}
- `mixer.addSubmix` {"name":str?,"channels":"Mono|Stereo|5.1"?}
- `mixer.clearLane` {"strip":"A1"|"S1"|"Mix"|id,"lane":str?}
- `mixer.deleteKeyframe` {"strip":"A1"|"S1"|"Mix"|id,"lane":str?,"time":ticks}
- `mixer.deleteSubmix` {"strip":"S1"|id}
- `mixer.inspect` {"time":ticks?}
- `mixer.moveKeyframe` {"strip":"A1"|"S1"|"Mix"|id,"lane":str?,"time":ticks,"newTime":ticks?,"value":f64?}
- `mixer.recordStart` {"time":ticks?}
- `mixer.recordStop` {"time":ticks?}
- `mixer.release` {"strip":"A1"|"S1"|"Mix"|id,"lane":str?,"time":ticks?}
- `mixer.removeInsert` {"strip":"A1"|"S1"|"Mix"|id,"slot":n}
- `mixer.removeSend` {"strip":"A1"|"S1"|id,"send":n}
- `mixer.setInsert` {"strip":"A1"|"S1"|"Mix"|id,"slot":n,"enabled":bool?,"postFader":bool?,"params":{id:value}?}
- `mixer.setKeyframe` {"strip":"A1"|"S1"|"Mix"|id,"lane":str?,"time":ticks?,"value":f64}
- `mixer.setSend` {"strip":"A1"|"S1"|id,"send":n,"levelDb":f64?,"pan":f64?,"preFader":bool?,"muted":bool?,"target":"S1"?}
- `mixer.setStrip` {"strip":"A1"|"S1"|"Mix"|id,"name":str?,"volumeDb":f64?,"pan":f64?,"muted":bool?,"solo":bool?,"recordArm":bool?,"soloSafe":bool?,"mode":"Off|Read|Latch|Touch|Write"?,"output":"Mix"|"S1"?,"inputMap":"Stereo|Left|Right|Swap|Mono"?,"channels":"Mono|Stereo|5.1"?}
- `mixer.setValue` {"strip":"A1"|"S1"|"Mix"|id,"lane":"volume|pan|mute|send.<i>.level|fx.<slot>.<param>","value":f64,"time":ticks?}
- `mixer.touch` {"strip":"A1"|"S1"|"Mix"|id,"lane":"volume|pan|mute|send.<i>.level|fx.<slot>.<param>","value":f64,"time":ticks?}
- `mixer.writeAutomation` {"strip":"A1"|"S1"|"Mix"|id,"lane":str?,"points":[[ticks,value]],"tolerance":f64?}

### multicam (35)

- `multicam.audioFollowsVideo` {"enabled":bool?}
- `multicam.autoAdjustQuality` {"enabled":bool?}
- `multicam.cut` {"camera":1..16|"angle":0-based,"time":ticks?,"videoOnly":bool?}
- `multicam.cutToCamera` {"camera":1..16|"angle":0-based,"time":ticks?,"videoOnly":bool?}
- `multicam.cutToCamera1` {"videoOnly":bool?}  (Ctrl+1)
- `multicam.cutToCamera2` {"videoOnly":bool?}  (Ctrl+2)
- `multicam.cutToCamera3` {"videoOnly":bool?}  (Ctrl+3)
- `multicam.cutToCamera4` {"videoOnly":bool?}  (Ctrl+4)
- `multicam.cutToCamera5` {"videoOnly":bool?}  (Ctrl+5)
- `multicam.cutToCamera6` {"videoOnly":bool?}  (Ctrl+6)
- `multicam.cutToCamera7` {"videoOnly":bool?}  (Ctrl+7)
- `multicam.cutToCamera8` {"videoOnly":bool?}  (Ctrl+8)
- `multicam.cutToCamera9` {"videoOnly":bool?}
- `multicam.editCameras` {"sequence":id?,"cameras":[{"angle":0-based,"name":str?,"enabled":bool?}]?,"audio":"camera1|all|switch"?}
- `multicam.grid` {"time":ticks?,"playing":bool?,"cellPixels":f32?,"playbackScale":f32?}
- `multicam.gridLayout` {"layout":"auto|2x2|3x3|4x4"}
- `multicam.inspect` {"time":ticks?}
- `multicam.nextPage` {}
- `multicam.page` {"page":0-based|"next"|"prev"}
- `multicam.prevPage` {}
- `multicam.recordStart` {"time":ticks?}
- `multicam.recordStop` {"time":ticks?}
- `multicam.selectCamera1` {"videoOnly":bool?}  (1)
- `multicam.selectCamera2` {"videoOnly":bool?}  (2)
- `multicam.selectCamera3` {"videoOnly":bool?}  (3)
- `multicam.selectCamera4` {"videoOnly":bool?}  (4)
- `multicam.selectCamera5` {"videoOnly":bool?}  (5)
- `multicam.selectCamera6` {"videoOnly":bool?}  (6)
- `multicam.selectCamera7` {"videoOnly":bool?}  (7)
- `multicam.selectCamera8` {"videoOnly":bool?}  (8)
- `multicam.selectCamera9` {"videoOnly":bool?}  (9)
- `multicam.selectionTopDown` {"enabled":bool?}
- `multicam.showPreviewMonitor` {"enabled":bool?}
- `multicam.switchAngle` {"camera":1..16 (shown order)|"angle":0-based,"clips":[id]?,"time":ticks?,"videoOnly":bool?,"audioOnly":bool?}
- `multicam.transmitView` {"enabled":bool?}

### perf (1)

- `perf.stats` {}

### playhead (14)

- `playhead.end` {}  (End)
- `playhead.nextEdit` {}  (Down)
- `playhead.nextEditAnyTrack` {}  (Shift+Down)
- `playhead.prevEdit` {}  (Up)
- `playhead.prevEditAnyTrack` {}  (Shift+Up)
- `playhead.selectedClipEnd` {}  (Shift+End)
- `playhead.selectedClipStart` {}  (Shift+Home)
- `playhead.set` {"time":ticks|"frame":i64|"seconds":f64|"timecode":str}
- `playhead.start` {}  (Home)
- `playhead.step` {"frames":i64}
- `playhead.stepBack` {}  (Left)
- `playhead.stepBack5` {}  (Shift+Left)
- `playhead.stepForward` {}  (Right)
- `playhead.stepForward5` {}  (Shift+Right)

### prefs (4)

- `prefs.get` {"key":str?}
- `prefs.reset` {"category":str?}
- `prefs.schema` {"category":str?}
- `prefs.set` {"key":str,"value":any}|{"values":{key:value}}

### presets (7)

- `presets.apply` {"preset":str,"clips":[id]?}
- `presets.delete` {"name":str}
- `presets.export` {"path":str,"names":[str]?}
- `presets.import` {"path":str}
- `presets.list` {}
- `presets.rename` {"name":str,"to":str}
- `presets.save` {"clip":id?,"effects":[index]?,"name":str,"description":str?,"keyframes":"scale"|"anchorIn"|"anchorOut"|"none"?}

### project (40)

- `project.columns.list` {}
- `project.columns.resize` {"column":str,"width":f32}
- `project.columns.set` {"columns":[name|{"name":str,"width":f32}]}
- `project.delete` {"items":[id]?}  (Delete)
- `project.deleteSearchBin` {"bin":id}
- `project.deselectAll` {}
- `project.editSearchBin` {"bin":id,"name":str?,"column":str?,"operator":str?,"text":str?,"rows":[..]?,"matchAll":bool?,"caseSensitive":bool?}
- `project.freeform.alignToGrid` {"bin":binId?,"grid":f32?}
- `project.freeform.arrangements` {"bin":binId?}
- `project.freeform.deleteArrangement` {"name":str,"bin":binId?}
- `project.freeform.layout` {"bin":binId?,"width":f32?}
- `project.freeform.move` {"items":[id]?,"x":f32,"y":f32,"snap":bool?} | {"positions":{"<id>":[x,y]}}
- `project.freeform.options` {"grid":f32?,"snap":bool?,"showNames":bool?,"showDurations":bool?,"cardSize":f32?}
- `project.freeform.reset` {"bin":binId?}
- `project.freeform.resize` {"items":[id]?,"size":f32?,"step":1|-1?}
- `project.freeform.restoreArrangement` {"name":str,"bin":binId?}
- `project.freeform.saveArrangement` {"name":str,"bin":binId?}
- `project.freeform.stack` {"items":[id]?}
- `project.freeform.unstack` {"items":[id]?}
- `project.ingestSettings` {"enabled":bool?,"action":"copy|transcode|createProxies|copyAndCreateProxies"?,"destination":str?,"preset":str?}
- `project.inspect` {}
- `project.items` {"bin":binId?,"recursive":bool?}
- `project.matteColor` {"item":id?,"color":"#rrggbb"}
- `project.moveToBin` {"items":[id|binId]?,"bin":binId|null}
- `project.notes` {}
- `project.renameBin` {"bin":binId,"name":str}
- `project.searchBinItems` {"bin":id}
- `project.select` {"items":[id]}
- `project.selectAll` {"bin":binId?,"expanded":[binId]?}
- `project.setMarks` {"item":id,"in":ticks?|null,"out":ticks?|null}
- `project.setNotes` {"text":str,"merge":str?}
- `project.sort` {"column":str,"descending":bool?}
- `project.view.get` {}
- `project.view.set` {"view":"list|icon|freeform"?,"iconSize":f32?,"fontSize":"small|medium|large|extraLarge"?,"previewArea":bool?,"thumbnails":bool?,"thumbnailsShowEffects":bool?,"hoverScrub":bool?,"thumbnailControlsAllDevices":bool?,"iconSort":column|{"column":str,"descending":bool}?}
- `project.viewPreset.delete` {"slot":1..10}
- `project.viewPreset.list` {}
- `project.viewPreset.rename` {"slot":1..10,"name":str}
- `project.viewPreset.restore` {"slot":1..10}
- `project.viewPreset.save` {"slot":1..10?,"name":str?}
- `project.viewPreset.saveAs` {"name":str?,"slot":1..10?}

### scopes (1)

- `scopes.read` {"scopes":["waveform","parade","histogram","vectorscopeYuv","vectorscopeHls"]?,"waveformType":"rgb|luma|yc|ycNoChroma"?,"paradeType":"rgb|yuv|rgbWhite"?,"colorSpace":"auto|601|709|2100"?,"clamp":bool=true,"columns":n=8,"peaks":n=8,"bins":bool=true,"scale":0.5,"time":ticks?|"frame"|"seconds"|"timecode"}

### sequence (45)

- `sequence.addEdit` {"time":ticks?}  (Cmd+K)
- `sequence.addEditAllTracks` {"time":ticks?}  (Cmd+Shift+K)
- `sequence.addTracks` {"video":n=1,"audio":n=0,"submix":n=0,"videoAfter":"first"|"V2"|n?,"audioAfter":"first"|"A2"|n?,"submixAfter":"first"|"S1"|n?,"audioType":"standard|5.1|adaptive|mono"?,"submixType":"stereo|5.1|adaptive|mono"?}
- `sequence.applyAudioTransition` {"clip":id?,"effect":"constant_power|Constant Power|…"?,"frames":i64?,"edge":"in"|"out"?,"params":{param:value}?,"reverse":bool?}  (Cmd+Shift+D)
- `sequence.applyVideoTransition` {"clip":id?,"effect":"cross_dissolve|Cross Dissolve|…"?,"frames":i64?,"edge":"in"|"out"?,"params":{param:value}?,"reverse":bool?}  (Cmd+D)
- `sequence.close` {"item":id?}  (Cmd+W)
- `sequence.closeGap` {"track":"V1"|id?,"time":ticks?}
- `sequence.closeOthers` {"item":id?}
- `sequence.colorSettings` {"workingSpace":"rec709"|"rec2100-pq"|"rec2100-hlg"?,"wideGamut":bool?,"autoToneMap":bool?}
- `sequence.deleteRenderFiles` {}
- `sequence.deleteRenderFilesInToOut` {}
- `sequence.deleteTrack` {"track":"V3"|id}
- `sequence.deleteTracks` {"video":"empty"|"V2"|id?,"audio":"empty"|"A2"|id?,"captions":"empty"|"C2"|id?}
- `sequence.extract` {}  (')
- `sequence.goToNextGap` {}  (Shift+;)
- `sequence.goToNextGapInTrack` {"track":"V1"|id?}
- `sequence.goToPrevGap` {}  (Cmd+Shift+;)
- `sequence.goToPrevGapInTrack` {"track":"V1"|id?}
- `sequence.inspect` {"item":id?}
- `sequence.joinThroughEdits` {"clips":[id]?,"cut":[id,id]?,"all":bool?}
- `sequence.lift` {}  (;)
- `sequence.linkedSelection` {"on":bool?}
- `sequence.makeSubsequence` {"name":str?}  (Shift+U)
- `sequence.matchFrame` {}  (F)
- `sequence.moveTab` {"item":id?,"index":int}
- `sequence.nestSequences` {"on":bool?}
- `sequence.normalizeMixTrack` {"db":f64=0}
- `sequence.open` {"item":id}
- `sequence.removeTransition` {"transitions":[id]?}
- `sequence.renderAudio` {"wait":bool=false}
- `sequence.renderBar` {}
- `sequence.renderEffectsInToOut` {"wait":bool=false}  (Enter)
- `sequence.renderInToOut` {"wait":bool=false}
- `sequence.renderSelection` {"wait":bool=false}
- `sequence.revealInProject` {"item":id?}
- `sequence.revealNested` {}  (Cmd+Alt+F)
- `sequence.reverseMatchFrame` {}  (Shift+R)
- `sequence.selectionFollowsPlayhead` {"on":bool?}
- `sequence.setTransition` {"transition":id,"params":{param:value}?,"reverse":bool?,"reset":bool?,"duration":ticks?|"frames":n?,"align":"center"|"start"|"end"?|"start":ticks?,"merge":bool?,"begin":bool?}
- `sequence.settings` {"width":u32?,"height":u32?,"fps":f64?,"name":str?,"sampleRate":u32?,"mix":"Stereo|Mono|5.1|Adaptive"?,"dropFrame":bool?,"maxRenderQuality":bool?,"workingSpace":"rec709"|"rec2100-pq"|"rec2100-hlg"?,"wideGamut":bool?,"autoToneMap":bool?,"scaleMotion":bool=false}
- `sequence.showThroughEdits` {"on":bool?}
- `sequence.simplify` {"name":str?,"removeDisabled":bool=true,"removeEmptyTracks":bool=true,"closeGaps":bool=false,"moveClipsDown":bool=false,"removeVideoEffects":bool=false,"removeAudioEffects":bool=false,"removeText":bool=false,"keep":"both|video|audio"}
- `sequence.snap` {"on":bool?}  (S)
- `sequence.throughEdits` {}
- `sequence.transcribe` {"track":"mix"|"A1"|id?,"language":"en|auto"?,"diarize":bool?,"maxSpeakers":n?,"model":str?}

### shortcuts (16)

- `shortcuts.audit` {}
- `shortcuts.clear` {"command":id,"keys":str?,"panel":str?}
- `shortcuts.conflicts` {"platform":"mac|windows|linux"?}
- `shortcuts.deletePreset` {"name":str}
- `shortcuts.export` {"path":str}
- `shortcuts.forKey` {"key":"K","platform":str?}
- `shortcuts.get` {"command":id,"platform":str?}
- `shortcuts.import` {"path":str,"activate":bool=true}
- `shortcuts.list` {"query":str?,"panel":str?,"assigned":bool?,"platform":"mac|windows|linux"?}
- `shortcuts.loadPreset` {"name":str}
- `shortcuts.presets` {}
- `shortcuts.redo` {}
- `shortcuts.resolve` {"keys":str,"panel":str?,"platform":str?}
- `shortcuts.savePreset` {"name":str}
- `shortcuts.set` {"command":id,"keys":"Cmd+Shift+K","panel":str?,"add":bool?,"keepConflicts":bool?}
- `shortcuts.undo` {}

### source (7)

- `source.close` {}
- `source.closeAll` {}
- `source.insert` {}  (,)
- `source.inspect` {}
- `source.open` {"item":id?,"clip":id?}
- `source.overwrite` {}  (.)
- `source.setPlayhead` {"time":ticks|"frame":i64|"seconds":f64}

### state (1)

- `state.inspect` {}

### timeline (56)

- `timeline.move` {"moves":[{"clip":id,"track":id|"V2"|"new" (after the last of its kind),"time":ticks}],"insert":bool,"linked":bool?,"copy":bool?}
- `timeline.moveAudioTargetsDown` {}
- `timeline.moveAudioTargetsUp` {}
- `timeline.moveVideoTargetsDown` {}
- `timeline.moveVideoTargetsUp` {}
- `timeline.nudgeDown` {}
- `timeline.nudgeLeft` {}
- `timeline.nudgeLeft5` {}
- `timeline.nudgeRight` {}
- `timeline.nudgeRight5` {}
- `timeline.nudgeUp` {}
- `timeline.place` {"item":id|"items":[id] (back to back, one undo step),"track":"V1"|id|"A1" (sound only)|"new" (a video track after the last)?,"audioTrack":"A1"|id|"new"?,"time":ticks|"frame":i64|"seconds":f64,"insert":bool,"sourceIn":ticks?,"duration":ticks?,"video":bool=true,"audio":bool=true}
- `timeline.rateStretch` {"clip":id,"edge":"in|out","delta":ticks}
- `timeline.razor` {"time":ticks,"track":"V1"|id?,"clip":id?}
- `timeline.roll` {"left":id,"right":id,"delta":ticks|"deltaFrames":i64,"followLinks"?:bool}
- `timeline.select` {"clips":[id],"transitions":[id]?,"add":bool,"toggle":bool,"linked":bool?}
- `timeline.selectClipAtPlayhead` {}  (D)
- `timeline.selectGap` {"track":"V1"|id,"time":ticks|"frame":n|"seconds":f}
- `timeline.selectNextClip` {}  (Cmd+Down)
- `timeline.selectPrevClip` {}  (Cmd+Up)
- `timeline.setTargeting` {"track":"V1"|id,"targeted":bool?,"sourcePatch":bool?}
- `timeline.setTrack` {"track":"V1"|id,"locked":bool?,"syncLock":bool?,"enabled":bool?,"muted":bool?,"solo":bool?,"name":str?,"volumeDb":f64?,"pan":f64?,"label":"Violet|Iris|…"|""|null?}
- `timeline.slide` {"clip":id,"delta":ticks|"deltaFrames":i64}
- `timeline.slideLeft` {}
- `timeline.slideLeft5` {}
- `timeline.slideRight` {}
- `timeline.slideRight5` {}
- `timeline.slip` {"clip":id,"delta":ticks|"deltaFrames":i64}
- `timeline.slipLeft` {}
- `timeline.slipLeft5` {}
- `timeline.slipRight` {}
- `timeline.slipRight5` {}
- `timeline.toggleAllAudioTargets` {}  (Cmd+9)
- `timeline.toggleAllSourceAudio` {}  (Cmd+Alt+9)
- `timeline.toggleAllSourceVideo` {}  (Cmd+Alt+0)
- `timeline.toggleAllVideoTargets` {}  (Cmd+0)
- `timeline.toggleMuteTargetedAudio` {}
- `timeline.toggleOutputTargetedVideo` {}
- `timeline.toggleSoloTargetedAudio` {}
- `timeline.toggleTargetA1` {}
- `timeline.toggleTargetA2` {}
- `timeline.toggleTargetA3` {}
- `timeline.toggleTargetA4` {}
- `timeline.toggleTargetA5` {}
- `timeline.toggleTargetA6` {}
- `timeline.toggleTargetA7` {}
- `timeline.toggleTargetA8` {}
- `timeline.toggleTargetV1` {}
- `timeline.toggleTargetV2` {}
- `timeline.toggleTargetV3` {}
- `timeline.toggleTargetV4` {}
- `timeline.toggleTargetV5` {}
- `timeline.toggleTargetV6` {}
- `timeline.toggleTargetV7` {}
- `timeline.toggleTargetV8` {}
- `timeline.trim` {"clip":id,"edge":"in|out","mode":"regular|ripple","delta":ticks|"deltaFrames":i64}

### transcript (14)

- `transcript.createCaptions` {"maxChars":n?,"lines":1|2?,"minSeconds":f?,"maxSeconds":f?,"gapFrames":n?,"format":str?,"name":str?}
- `transcript.delete` {"items":[id]?}
- `transcript.downloadModel` {"model":"whisper-base"?}
- `transcript.extract` {"from":word,"to":word?}
- `transcript.generate` {"items":[id]?,"model":"whisper-base"?,"language":"en|auto"?,"diarize":bool?,"maxSpeakers":n?}
- `transcript.inspect` {"paragraphGapSeconds":f?}
- `transcript.lift` {"from":word,"to":word?}
- `transcript.models` {}
- `transcript.removeFillers` {"fillers":[str]?}
- `transcript.removePauses` {"minSeconds":f?,"keepSeconds":f?}
- `transcript.renameSpeaker` {"speaker":"Speaker 1"|index,"name":str,"item":id?}
- `transcript.search` {"query":str}
- `transcript.select` {"from":word,"to":word?}
- `transcript.set` {"item":id,"transcript":{"language":str,"speakers":[{"name":str}],"words":[{"text":str,"start":tick,"end":tick,"speaker":n?}]}}

### trim (24)

- `trim.applyDefaultTransition` {"clips":[id]?}  (Shift+D)
- `trim.backward` {}  (Alt+Left)
- `trim.backwardMany` {}  (Alt+Shift+Left)
- `trim.cancelDynamic` {}
- `trim.clear` {}
- `trim.edit` {}  (Shift+T)
- `trim.extendNextEdit` {}  (Shift+W)
- `trim.extendPreviousEdit` {}  (Shift+Q)
- `trim.extendToPlayhead` {}  (E)
- `trim.forward` {}  (Alt+Right)
- `trim.forwardMany` {}  (Alt+Shift+Right)
- `trim.monitor` {}
- `trim.next` {}  (Alt+W)
- `trim.nudge` {"frames":i64}
- `trim.playAround` {"clock":seconds,"loop":bool=true,"toggle":bool?}
- `trim.previous` {}  (Alt+Q)
- `trim.rippleNext` {}  (W)
- `trim.ripplePrevious` {}  (Q)
- `trim.selectEditPoint` {"clip":id,"edge":"in|out","kind":"trim|ripple|roll","add":bool?}
- `trim.selectNearest` {"kind":"rippleIn|rippleOut|roll|trimIn|trimOut"}
- `trim.shuttle` {"direction":"forward|reverse","slow":bool?,"clock":seconds}
- `trim.shuttleStop` {"clock":seconds?}
- `trim.tick` {"clock":seconds}
- `trim.toggleType` {}

### tts (7)

- `tts.create` {"text":str,"voice":str?,"pitch":"extraLow|low|default|high|extraHigh"?,"pace":0.5..2?,"time":ticks?,"track":"A1"|id?,"dir":str?}
- `tts.downloadVoices` {"wait":bool?}
- `tts.edit` {"clip":id?,"text":str?,"voice":str?,"pitch":str?,"pace":f64?,"dir":str?}
- `tts.inspect` {"clip":id?,"item":id?}
- `tts.preview` {"text":str?,"voice":str?,"pitch":"default"?,"pace":f64?,"sample":bool?,"clip":id?,"path":str?}
- `tts.render` {"text":str?,"voice":str?,"pitch":str?,"pace":f64?,"sample":bool?,"clip":id?,"wait":bool?}
- `tts.voices` {}
