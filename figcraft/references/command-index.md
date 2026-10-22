# FigCraft command index — all 569 commands (0.8.0, verified 2026-10-22)

Generated from `figcraft-cli commands --json`. Format: `id` — label — `params` — shortcut.

`?` means optional. Ids are exact and case-sensitive; params are the documented shape.

Refresh with `scripts/dump-commands.sh`.


## align (6)

- `align.bottom` — Align bottom — `{ids?}` — Alt+S
- `align.hcenter` — Align horizontal centers — `{ids?}` — Alt+H
- `align.left` — Align left — `{ids?}` — Alt+A
- `align.right` — Align right — `{ids?}` — Alt+D
- `align.top` — Align top — `{ids?}` — Alt+W
- `align.vcenter` — Align vertical centers — `{ids?}` — Alt+V

## annotation (8)

- `annotation.add` — Add annotation — `{id? (default the first selected layer), label? (the note), properties?: [width|height|top|left|rotation|opacity|cornerRadius|direction|gap|padding|alignment|fontFamily|fontStyle|fontSize|lineHeight|letterSpacing|textAlign|fill|stroke|strokeWeight|effects], category? (id or name)} → {id, index}  (a note, pinned properties or both)`
- `annotation.addCategory` — Add annotation category — `{name, color? (default the first unused colour)} → {id}`
- `annotation.categories` — Annotation categories — `{} → {categories: [{id, name, color, count (annotations in it, every page)}]}` — (not undoable)
- `annotation.edit` — Edit annotation — `{id?, index, label?, properties?: [..] (replaces the pinned properties), category? (id or name; null: none)}`
- `annotation.editCategory` — Edit annotation category — `{id (id or name), name?, color?}  (rename and/or recolour)`
- `annotation.list` — List annotations — `{ids? | id? (those layers), page? (page id, or "all"; default the current page), category? (id or name, or "none": only those)} → {annotations: [{id, name, index, label, category?: {id, name, color}, properties: [{property, label, value (null when the layer has none), token?, color?}]}]}` — (not undoable)
- `annotation.remove` — Remove annotation — `{id?, index? (omit: every annotation on the layer)}`
- `annotation.removeCategory` — Delete annotation category — `{id (id or name)} → {id, uncategorized (how many annotations were in it)}  (its annotations stay, without a category)`

## app (2)

- `app.actions` — Actions — `{}` — Cmd+K — (not undoable)
- `app.preferences` — Preferences — `{}` — Cmd+, — (not undoable)

## arrange (10)

- `arrange.back` — Send to back — `{ids?}` — Shift+Cmd+[
- `arrange.backward` — Send backward — `{ids?}` — Cmd+[
- `arrange.forward` — Bring forward — `{ids?}` — Cmd+]
- `arrange.front` — Bring to front — `{ids?}` — Shift+Cmd+]
- `arrange.packH` — Pack horizontal — `{ids?}`
- `arrange.packV` — Pack vertical — `{ids?}`
- `arrange.reorder` — Reorder selection — `{ids?, source, target, swap?, fromGesture?} (insert at target's visual slot; no hierarchy changes)`
- `arrange.roundToPixels` — Round to pixels — `{ids?}`
- `arrange.spacing` — Spacing — `{ids?, horizontal?, vertical?, fromGesture?} (page units; fromGesture uses the interaction snapshot)`
- `arrange.tidy` — Tidy up — `{ids?, spacing?}` — Ctrl+Alt+Shift+T

## bool (5)

- `bool.exclude` — Exclude selection — `{ids?} — layers inside boolean groups: sets their own operation (how each combines with the operands below it); one boolean group: sets its operation (every operand follows it); otherwise wraps the layers in a new boolean group` — Alt+Shift+E
- `bool.flatten` — Flatten boolean — `{ids?}`
- `bool.intersect` — Intersect selection — `{ids?} — layers inside boolean groups: sets their own operation (how each combines with the operands below it); one boolean group: sets its operation (every operand follows it); otherwise wraps the layers in a new boolean group` — Alt+Shift+I
- `bool.subtract` — Subtract selection — `{ids?} — layers inside boolean groups: sets their own operation (how each combines with the operands below it); one boolean group: sets its operation (every operand follows it); otherwise wraps the layers in a new boolean group` — Alt+Shift+S
- `bool.union` — Union selection — `{ids?} — layers inside boolean groups: sets their own operation (how each combines with the operands below it); one boolean group: sets its operation (every operand follows it); otherwise wraps the layers in a new boolean group` — Alt+Shift+U

## branch (7)

- `branch.archive` — Archive branch — `{id?}  set the branch aside without merging (it stays in the file and can still be opened) and close its tab` — (not undoable)
- `branch.create` — Create branch — `{name?}  a copy of the file to work on separately, opened in a new tab; it remembers the file as it is now (its base) → {id, name, index (its tab)}` — (not undoable)
- `branch.list` — List branches — `{}  the branches of the file shown (or of the file a branch tab belongs to), oldest first → [{id, name, time (Unix seconds), state: active|merged|archived, index? (its open tab)}]` — (not undoable)
- `branch.merge` — Merge branch — `{id?, resolutions? ({<conflict key>: "branch" | "main"})}  merge the branch into the main file as one undo step, then archive it and show the main file; refused while a conflict has no resolution → {merged, changes, conflicts, index}` — (not undoable)
- `branch.open` — Open branch — `{id}  open the branch in a tab (or switch to its tab) → {index}` — (not undoable)
- `branch.review` — Review branch — `{id? (default: the branch tab shown)}  what changed on the branch and on the main file since the branch was made or last updated from main, and where they conflict (the same property changed on both sides, or a layer deleted on one side and edited on the other) → {id, name, state, branch: {layers, document, truncated}, main: {…}, conflicts: [{key, id?, name, property, branch, main, deletedBy?}]}` — (not undoable)
- `branch.updateFromMain` — Update from main — `{id?, resolutions? ({<conflict key>: "branch" | "main"})}  bring the main file's changes since the branch was made into the branch; refused while a conflict has no resolution. Not undoable (the branch tab's undo history starts over) → {updated, changes, conflicts}` — (not undoable)

## codeConnect (4)

- `codeConnect.export` — Export code connections — `{path? (write it there, e.g. figcraft.connect.json in the code repository)}  every component's links as {version: 1, links: [{component (its name), language, importPath, name, template}]}, sorted  → {text, links} or {path, links}` — (not undoable)
- `codeConnect.import` — Import code connections — `{json (the connect JSON as codeConnect.export writes it: an object or JSON text) | path (a figcraft.connect.json)}  links each entry to every component or set of that name (replacing its link for the language); invalid entries and unknown components are skipped with a warning  → {linked, warnings}`
- `codeConnect.remove` — Disconnect from code — `{id? (component, set or instance; default the selection), language? (omit: every language)}  → {component, removed}`
- `codeConnect.set` — Connect to code — `{id? (component, set or instance; default the selection), language?: react|leptos|swiftui|compose (default react), importPath?, name? (default the generated name), template? (default a call passing every property)}  links the component (its set, for a variant) to its code component; fields left out keep their current value. Placeholders: {property} (its name or parameter name) and {property ? "a" : "b"}; other {…} stay as written  → {component, language, code (the snippet for the layer), unknown (placeholder names that aren't properties)}`

## collab (21)

- `collab.cursor` — Show cursor at — `{x?, y? (page coordinates on the current page; omit both to hide)} → {cursor} (agents; in the app the pointer drives it): your pointer in the open file's session (null when the file isn't in one)` — (not undoable)
- `collab.cursorChat` — Cursor chat — `{text? (shown next to your cursor for everyone, at most 100 characters; empty closes it; omit to open the chat box in the app)} → {chat} (or {open}); others see it fade after 5 s without changes` — / — (not undoable)
- `collab.diff` — Show sync changes — `{against? (undo: the last undoable action, the default | saved: since the last save)} → the changes a live session would send, their count and binary size` — (not undoable)
- `collab.files` — Your online files — `{refresh? (true: ask each server once what became of its files; default false: no network)} → {files: [{server, host, file (its id), name, created, opened (seconds since 1970), shared (others get in with a code now), code, viewCode (the join codes, while shared), state: unknown | online | gone (the server no longer has it: removed or expired), expires, session, document (the session and open document it is in now, or null), hasOwnerToken: true}], problems: [{server, host, state: offline | unsupported (a server older than this request), reason}], max}: the files you published or shared without a server key, most recently opened first, as recorded on this computer with the preferences. Owner tokens and your own links are never in the result` — (not undoable)
- `collab.follow` — Follow — `{client? (a peer's id; omit to stop following)} → {follow}` — (not undoable)
- `collab.forgetFile` — Forget online file — `{file, server?} → {forgotten, file, server, onServer}: drops the file from the list on this computer only. The file stays on its server until it expires, and without its owner token it can't be managed from here again (`collab.manageFile {action: "remove"}` takes it off the server instead)` — (not undoable)
- `collab.host` — Start live session — `{port? (default 47900, else any free port), bind?: "local" (this machine, default) | "lan" (the local network) | an IP address} → the open file's session: {session, link, url (invites: they carry the secret token), address, …}; sessions are per file, so other files' sessions go on (a session this file was in ends)` — (not undoable)
- `collab.join` — Join live session — `{code: a join code (K7M-2QX-9TD from a server, asked at the server in Preferences; a longer one for the local network; spaces, dashes and case don't matter, O reads as 0 and I or L as 1) | link: figcraft://join?host=…&file=…&token=…, figcraft://join?server=ws(s)://…&file=…&token=… or ws(s)://host:port/?file=…&token=… (a session an app hosts, or a server's share link; a code here works too)} → the new session: {session, status: "connecting", …}; its file opens in a tab of its own (other files' sessions go on) and `collab.peers` tells when it's live (`sessions` lists it until then, and if it fails)` — (not undoable)
- `collab.leave` — Leave live session — `{} (the open file's session; the synced file stays open as a local copy) → {ended}` — (not undoable)
- `collab.manageFile` — Manage published file — `{file (its id), server?, owner? (the server's address and the owner token you got when you published the file without the key; each defaults to what is recorded for one of your online files, see `collab.files`), action: links | createLink {access?: view (default) | edit, label?} | revoke {link (a link's id)} | share (others get new links and join codes) | unshare (the links and codes others got are revoked; the file stays yours on the server) | rename {name} | remove (the file is deleted from the server and leaves your online files)} → {links: [{id, access, label, created}]} | {id, access, link (a new share link, shown once)} | {shared, code, viewCode, editLink, viewLink} | {done}` — (not undoable)
- `collab.openFile` — Open online file — `{file (its id, from `collab.files`), server? (when files on several servers have that id)} → {session, status: "connecting", document, alreadyOpen, file, server, name}: joins the file as its owner in a tab of its own (`collab.peers` tells when it's live; `collab.share` and `collab.stop` there start and stop its sharing); a file that is open already comes to the front instead (alreadyOpen: true)` — (not undoable)
- `collab.peers` — People in this file — `{} → the open file's session (each open file has its own or none): {available, canHost (false in the browser: it can only join), session (its id; null: this file isn't in a session), status: off|connecting|live|reconnecting|failed, reason?, role, me, name, color, fileName, pages, link, url, address, network, access: edit|view (view: a server's view link; edits are refused), readOnly (the open file can't be edited now: view only, or being published), published (a file you published: {server, file, name, edit, view}), code (the join code to give others, when the file was shared with `collab.share`; null otherwise or while it is on its way), share ({via: online|local, access, shared (false: a file of yours on a server that nobody else gets into now), editCode, viewCode, editLink, viewLink (what others join with; null when not shared)} or null), follow, syncing, document (index of the synced open document), editing (the text layer you type in: {node, layer, caret, selection}), peers: [{id, name, color, editing (theirs, same shape, or null), presence: {cursor: [page, x, y], selection, viewport: [page, x, y, w, h], editing_text}}], sessions: [{session, document (index of its open document; null for a join on its way), status, reason, role, fileName, link, peers (how many others)}] (every session of the app)}` — (not undoable)
- `collab.publish` — Publish to server — `{server: ws://host:port/?key=… or wss://host/path/?key=… (the server's address with its key; `figcraft-server key` prints it; without a key on a server open to the public), key? (when the address has none), name? (default: the file's name)} → status "connecting": the open file is uploaded as a new file and this tab syncs through the server; `collab.peers` then has `published: {server, file, name, edit, view, owner (published without a key: the owner token, shown once), expires (seconds since 1970, or null)}` and `hosting` (the server's operator, terms and idle expiry)` — (not undoable)
- `collab.recoverFile` — Recover online file — `{path (a recovery copy of one of your online files), file, server?, session, client, seq (who the app was in the file when the copy was written, and the server's last change it had: from the note beside the copy)} → {session, status: "connecting"}: joins the file again as its owner and keeps the copy until the file arrives. Then: the server has everything in the copy → nothing more; the copy has changes of yours the server never confirmed and nothing else changed there → they are applied on top as one edit ("Recovered changes", synced to everyone); anything else changed meanwhile → the copy opens beside the file as “<name> (recovered copy)”; the file can't be joined → the copy opens as an unsaved document. The session's message says which` — (not undoable)
- `collab.registerLinks` — Open invite links in FigCraft — `{on? (default: switch)} → {on, registered}: make this app the opener of figcraft:// invite links (or stop); also the Preferences checkbox` — (not undoable)
- `collab.removePerson` — Remove from session — `{client (a peer's id)} → {removed, name}: they are disconnected (they keep their copy) and can't join again from their address while the session runs; only the person hosting, or the owner of a file on a server, can do it` — (not undoable)
- `collab.report` — Report file to server operator — `{reason (a few words, at most 500 characters)} → {sent}: the file you joined on a server is reported to its operator; the session's message says when the server kept it (servers older than this app don't take reports)` — (not undoable)
- `collab.serverInfo` — Server info — `{server: ws://host:port/ or wss://host/path/} → {open (anyone may publish without the key), operator, terms (a web address), idleDays (files published without the key are deleted after this many days unopened; null: kept), maxFileMb, expires}` — (not undoable)
- `collab.share` — Share with a join code — `{via?: "online" (default: the open file is kept on the server in Preferences, `pref.publishServer`, and the server hands out the codes) | "local" (this app hosts it for people on the same network; no server), access?: "edit" (default) | "view" (online only: which code `code` is), server? (online: another server's address, with ?key=… when it needs its key), name? (online: the file's name there), port?, bind?: "lan" (default) | "local" (this machine only) | an IP address (local)} → the open file's session as `collab.peers` gives it: `code` is what others type to join (`collab.join {code}`, the Join field), `link` an invite link. Local: at once, the code carries the host's IPv4 address, port and secret (K7M2Q-…, 20 symbols). Online: status "connecting" first; once live `code` is the server's (K7M-2QX-9TD) and `share` is {via, access, shared, editCode, viewCode, editLink, viewLink}: links made for others (the file's own links in `published` stay yours); `code` stays null when the server is older than join codes (give `share.editLink` / `share.viewLink` instead). Called again while shared: only switches which code `code` is (`access`). Called after `collab.stop` on a file that is still on the server: new links and codes for that same file (nothing is published twice). `collab.stop` stops sharing` — (not undoable)
- `collab.spotlight` — Spotlight me — `{on? (default: toggle)} → {spotlighting}: everyone in the session follows your view and page until they move theirs` — (not undoable)
- `collab.stop` — Stop live session — `{} → {ended}: the open file's session ends (a session this app hosts stops for everyone; a joined one is left). A file shared online with `collab.share` is different: its sharing stops → {ended: false, shared: false}: the links and codes others got are revoked on the server, whoever joined with them is disconnected at once (they keep their copy), and you stay in the file, which stays on the server, open only to you (`collab.share` shares it again with new codes; `collab.leave` leaves it there; `collab.manageFile {action: "remove"}` with its owner token takes it off the server)` — (not undoable)

## command (1)

- `command.batch` — Run several commands — `{label?, commands: [{command, params}]} (one undo step)` — (not undoable)

## comment (14)

- `comment.add` — Add comment — `{x, y, text, page?, author?, anchor? (node id to pin to; true = innermost frame under the point)}`
- `comment.delete` — Delete comment — `{id, reply? (index: delete one reply; omit to delete the thread), author?}`
- `comment.edit` — Edit comment — `{id, text, reply? (index; omit for the first message), author?}`
- `comment.link` — Copy link to comment — `{id}` — (not undoable)
- `comment.list` — List comments — `{page? (default: current; "all" for every page), filter? (all|open|resolved|mine|unread; default all), sort? (date|page; default date), query? (search text), frame? (a top-level frame id), resolved? (false hides resolved ones), author? (whose threads and read state)}` — (not undoable)
- `comment.markRead` — Mark comment as read — `{id? | link? (omit: every thread), read? (default true; false marks it unread), author?}` — (not undoable)
- `comment.move` — Move comment — `{id, x, y, anchor? (default true: pin to the innermost frame under the point; false: to the page; or a node id)}`
- `comment.next` — Next comment — `{id? (the thread to step from; omitted: the first or last), dir? (1 next, -1 previous; default 1), page?, filter?, sort?, query? (the list, as comment.list), author?}` — (not undoable)
- `comment.open` — Open comment — `{id | link, view? (fit: zoom to the thread's frame, default; center: centre the pin; keep), author?}` — (not undoable)
- `comment.people` — People in comments — `{}` — (not undoable)
- `comment.react` — React to comment — `{id, emoji, reply? (index; omit for the first message), on? (default: toggle), author?}`
- `comment.reply` — Reply to comment — `{id, text, author?}`
- `comment.resolve` — Resolve comment — `{id, resolved? (default true)}`
- `comment.zoom` — Zoom to comments — `{ids (comment ids on the current page)}` — (not undoable)

## component (21)

- `component.addProperty` — Add component property — `{id? (component, set, or a layer inside a component: it gets bound), name, type: boolean|text|instanceSwap|variant|slot, default?, layer? (node bound to it; a frame for slots), preferred? (instance swap and slot properties: component or set ids offered first)}`
- `component.addVariant` — Add variant — `{id? (component set or variant), property?, value?}  (duplicates the variant; `property`=`value` names the new one)`
- `component.bindProperty` — Bind layer to property — `{layer?, property (null/"" unbinds), field?: visible|characters|mainComponent|slot}`
- `component.combineVariants` — Combine as variants — `{ids? (components)}`
- `component.create` — Create component — `{ids?}  (one frame/group becomes a component; several layers are wrapped in one)` — Alt+Cmd+K
- `component.createMultiple` — Create multiple components — `{ids?}`
- `component.deleteProperty` — Delete component property — `{id? (component or set), name}`
- `component.detach` — Detach instance — `{ids?}` — Alt+Cmd+B
- `component.editProperty` — Edit component property — `{id? (component or set), name, newName?, default? (variant properties: that variant takes the top-left place), value? + newValue? (rename a variant value), index? (variant properties: move to this place; the variants' names follow), preferred? (instance swap and slot properties: component or set ids offered first)}`
- `component.exposeInstance` — Expose nested instance — `{id? (an instance inside a main component), exposed? (default true)} — its properties then show on the main's instances`
- `component.goToMain` — Go to main component — `{id?}` — Ctrl+Alt+Shift+K — (not undoable)
- `component.hideWhenPublishing` — Hide when publishing — `{ids? (components, sets or layers in them; default the selection), on? (default: toggle, hiding unless all are hidden)}  keeps them out of the library this file publishes, the way a name starting with `.` or `_` does: hiding puts a `.` before the name, showing takes the leading `.` and `_` away → {ids, hidden}`
- `component.list` — List components — `{} → [{id, name, type, page, instances, folder (the Assets panel's folders: page, frames, slash names), label, library?}]` — (not undoable)
- `component.makeSlot` — Make slot — `{id? (a frame inside a main component), name? (the slot property's name; the frame's by default), preferred? [component or set ids]}  (its instances take any content there)`
- `component.playground` — Component playground — `{id? (an instance, a component or a component set; default the selection), properties? {name: value} (variant, boolean, text and instance-swap properties, as instance.setProperties takes them), language? css|html|react|swiftui|compose (default react), path? (write the preview there as a PNG), scale? (the PNG's, default 2)} → {component, properties: [{name, type, options?, value}], language, code, width, height, path?}  the component with those property values, tried on a copy: its code and its look. Nothing in the document changes` — (not undoable)
- `component.properties` — Component properties — `{id? (component, set or instance)}` — (not undoable)
- `component.pushChanges` — Push changes to main component — `{id?}`
- `component.removeSlot` — Remove slot — `{id? (a slot frame of a main component)}  (instances lose their own content in it)`
- `component.resetInstance` — Reset all changes — `{ids?}`
- `component.resetOverride` — Reset override — `{id?, group? (fills|strokes|effects|opacity|visible|name|corners|characters|textStyle|padding|gap|alignment|grids|exports|interactions|size|position|component|props|slot; all when omitted)}`
- `component.restoreMain` — Restore main component — `{id?}  (an instance whose main was deleted becomes the main again, in its place)`

## dev (4)

- `dev.compare` — Compare changes — `{id? (default the first selected layer), show? (open the compare view in the app)} → {id, name, changed, snapshot, added, removed, modified, truncated, changes: [{id, name, type, change: added|removed|changed, depth, layers, properties?: [{section, property, before, after, text}]}]}  what changed in a ready-for-dev frame or section since it was marked (`snapshot` is false when that isn't known: a file from before snapshots were kept)` — (not undoable)
- `dev.focus` — Focus view — `{id? (a top-level frame or section; default the selection) | direction?: next|previous (the next ready-for-dev one, across pages)} → {id, name, page, index, count}  show only that layer on the canvas (Escape or `dev.unfocus` ends it)` — (not undoable)
- `dev.resolveChange` — Resolve change — `{ids?, reason?} (ready-for-dev frames and sections that changed since they were marked go back to Ready for dev; the reason is kept)`
- `dev.unfocus` — Exit focus view — `{} → {focused: false}` — (not undoable)

## devResource (4)

- `devResource.add` — Add dev resource — `{id? (default the first selected layer), url (http or https), name? (default the URL without its scheme)}  a link for developers on the layer; an instance also shows its main component's → {id, index}`
- `devResource.edit` — Edit dev resource — `{id?, index (of the layer's own), url?, name?}  → {id, index}`
- `devResource.list` — List dev resources — `{id? (default the first selected layer)}  the layer's links, its own first, then inherited from its main component and that component's set → [{name, url, index? (own), from? (the layer it comes from)}]` — (not undoable)
- `devResource.remove` — Remove dev resource — `{id?, index? (omit: every dev resource of the layer's own)}  → {removed}`

## distribute (2)

- `distribute.horizontal` — Distribute horizontal spacing — `{ids?, spacing?}` — Alt+Shift+H
- `distribute.vertical` — Distribute vertical spacing — `{ids?, spacing?}` — Alt+Shift+V

## doc (5)

- `doc.home` — Home — `{}` — (not undoable)
- `doc.list` — List documents — `{}` — (not undoable)
- `doc.nextTab` — Next tab — `{}` — Ctrl+Tab — (not undoable)
- `doc.previousTab` — Previous tab — `{}` — Ctrl+Shift+Tab — (not undoable)
- `doc.switch` — Switch document — `{index}` — (not undoable)

## edit (16)

- `edit.copy` — Copy — `{ids?}` — Cmd+C — (not undoable)
- `edit.copyProperties` — Copy properties — `{id?}` — Alt+Cmd+C — (not undoable)
- `edit.cut` — Cut — `{ids?}` — Cmd+X
- `edit.delete` — Delete — `{ids?}` — Delete
- `edit.duplicate` — Duplicate — `{ids?, dx?, dy? (page offset; default: the offset of the last duplicate when ids are its copies, still selected; else top-level frames to the right with a 100 gap, everything else in place)}  a main component's copy is an instance of it (a variant stays a new variant in its set)` — Cmd+D
- `edit.findReplace` — Find and replace — `{find, replace? (text layers), layerNames? (bool), select? (default true)}` — Cmd+F
- `edit.paste` — Paste — `{parent?, x?, y? (page coordinates of the pasted top-left)}  a copied main component pastes as an instance of it within its file (cut ones, and pastes into other files, keep the component)` — Cmd+V
- `edit.pasteDesignLayers` — Paste design layers — `{html (the clipboard's HTML) | data (base64 of the clipboard's design data, at most 256 MB), parent?, x?, y?}  layers copied from another design app (a .fig canvas in the clipboard's HTML), read like a .fig file (best effort, with `warnings`), pasted as edit.paste pastes`
- `edit.pasteOver` — Paste over selection — `{}` — Shift+Cmd+V
- `edit.pasteProperties` — Paste properties — `{ids?}` — Alt+Cmd+V
- `edit.pasteReplace` — Paste to replace — `{ids?}` — Shift+Cmd+R
- `edit.pickColor` — Pick color — `{}` — I — (not undoable)
- `edit.redo` — Redo — `{}` — Shift+Cmd+Z — (not undoable)
- `edit.repeat` — Repeat last command — `{}`
- `edit.setDefaultProperties` — Set default properties — `{id?}` — (not undoable)
- `edit.undo` — Undo — `{}` — Cmd+Z — (not undoable)

## effect (4)

- `effect.add` — Add effect — `{ids?, type? (dropShadow|innerShadow|layerBlur|backgroundBlur|noise|texture|glass), effect? {..}}`
- `effect.move` — Move effect — `{ids?, from, to} (indices in the effect list, bottom first)`
- `effect.remove` — Remove effect — `{ids?, index}`
- `effect.set` — Set effect — `{ids?, index, effect {..}}`

## export (3)

- `export.add` — Add export setting — `{ids?, setting? {size: 2x|512w|512h|{by: scale|width|height, value}, suffix?, format?: png|jpg|svg|pdf|webp, bleed? (PDF: points, or with a unit: "3mm", "0.125in", "9pt"), cropMarks?, bleedMarks?, cmyk? (PDF print options)}} (without a setting: 1x, then one scale step up with an "@2x"-style suffix)`
- `export.remove` — Remove export setting — `{ids?, index}`
- `export.update` — Edit export setting — `{ids?, index, size? (2x|512w|512h|{by, value}), suffix?, format? (png|jpg|svg|pdf|webp), bleed? (PDF: points, or with a unit: "3mm", "0.125in", "9pt"), cropMarks?, bleedMarks?, cmyk? (PDF print options)}`

## file (21)

- `file.close` — Close tab — `{index?, force? (discard unsaved changes)}` — Cmd+W — (not undoable)
- `file.colorProfile` — Color profile — `{profile?: srgb|displayP3, convert? (default true: convert colour values so colours keep their appearance; false: keep the values and reinterpret them)}  without `profile`, returns the current one (and the app opens the dialog). Returns {profile, changed}`
- `file.duplicate` — Duplicate file — `{}` — (not undoable)
- `file.export` — Export — `{ids? (default selection, else the page), format? (png|jpg|svg|pdf|webp, or fig: the whole file as .fig, experimental, with `warnings` for what was left out; other apps may not open every file), scale? (default 1) | size? (2x|512w|512h or {by: scale|width|height, value}: a scale, or a width or height in pixels), path? (else returns base64 `data`), bleed? (PDF: points, or with a unit: "3mm", "0.125in", "9pt"), cropMarks?, bleedMarks?, cmyk? (PDF print options)}` — Shift+Cmd+E — (not undoable)
- `file.exportFramesPdf` — Export frames to PDF — `{path?, page? (page id, default the current page), bleed? (PDF: points, or with a unit: "3mm", "0.125in", "9pt"), cropMarks?, bleedMarks?, cmyk? (PDF print options)}  every top-level frame in reading order, one PDF page each; returns base64 `data` without a path` — (not undoable)
- `file.exportLayers` — Export layers — `{ids? (default the selection, else every layer on the page with export settings), assets? (true: the Inspect tab's assets in and under them instead: layers with export settings, icons as SVG, images as PNG), dir? (folder to write into; else each file comes back as base64 `data`), bleed? (PDF: points, or with a unit: "3mm", "0.125in", "9pt"), cropMarks?, bleedMarks?, cmyk? (PDF print options): for every PDF instead of each setting's own}  every layer once per export setting, named `<layer><suffix>.<format>` ("@2x" when a scaled export has no suffix; repeats get " 2"; slashes in a layer name make folders). Returns {files: [{name, id, bytes, path | data}], skipped (layers without settings)}` — (not undoable)
- `file.exportSvg` — Export selection as SVG — `{ids?, path?}` — (not undoable)
- `file.import` — Import — `{path | data (base64) + name, x?, y?, center? (SVG: centre it on x, y), variables? (REST: the local variables JSON as an object, JSON text or a path)}  SVG becomes an editable frame (shapes, text, gradients, masks, effects; with `warnings` for what it left out), images become image layers, .figcraft, REST API file JSON and .fig pages are appended with their variables and flows (REST and .fig: with `warnings`; those return `summary` {name, pages, layers, images} of the file read)` — Shift+Cmd+I
- `file.moveTab` — Move tab — `{from, to} (indices among open documents)` — (not undoable)
- `file.new` — New design file — `{name?}` — Cmd+N — (not undoable)
- `file.newFromTemplate` — New from template — `{template (an id from `template.list`), name? (the document's name; default the template's)}  opens a new, unsaved document built from the template → {index, template}; without `template`, returns {templates} (and the app shows them to pick from)` — (not undoable)
- `file.open` — Open — `{path | data (base64) + name (tells the format; opens as a new unsaved document), variables? (REST: the local variables JSON as an object, JSON text or a path; default `<name>.variables.json` or `variables.json` next to the file)} (.figcraft, .json: FigCraft or REST API file JSON, .fig (best effort), .svg, .png, .jpg …); REST and .fig imports return `warnings`; a file opened anew returns `summary` {name, pages, layers, images} (one that was already open just returns its `index`)` — Cmd+O — (not undoable)
- `file.openRecent` — Open recent — `{path? | index? (into the list), clear? (forget them all), remove? (a path: forget that one)}  opens a recent file; a file that no longer exists is dropped from the list. Returns the list, newest first: {files: [{path, name, exists}]} (opening returns what `file.open` does)` — (not undoable)
- `file.placeImage` — Place image — `{path | data, x?, y?}` — Shift+Cmd+K
- `file.recover` — Recover file — `{path}  open a recovery copy (written while the app runs, read back after a crash) as a document with unsaved changes and no path: saving asks where → {index}` — (not undoable)
- `file.rename` — Rename file — `{name}`
- `file.revert` — Revert to saved — `{}  leave the live session first, if any` — (not undoable)
- `file.save` — Save — `{path?} (programmatic saves need a path the first time); a .fig path writes an experimental export copy of the shown document with `warnings`, keeping the native path, unsaved changes and version preview` — Cmd+S — (not undoable)
- `file.saveAs` — Save as — `{path} (no extension adds .figcraft); a .fig path writes an experimental export copy of the shown document with `warnings`, keeping the native path, unsaved changes and version preview` — Shift+Cmd+S — (not undoable)
- `file.saveVersion` — Save to version history — `{name?, description?}  snapshot the document into the file's version history (on a branch tab: the branch's own history; kept when the file is saved); returns the version` — Alt+Cmd+S — (not undoable)
- `file.versionHistory` — Show version history — `{}  opens the panel; returns the versions like `version.list`` — (not undoable)

## fill (5)

- `fill.add` — Add fill — `{ids?, paint? (default #D9D9D9 or white for frames)}`
- `fill.move` — Move fill — `{ids?, from, to} (indices in the fill list, bottom first)`
- `fill.pattern` — Pattern fill — `{source (layer id), ids?, index? (default the top fill), tile? (grid|horizontalHex|verticalHex), scale? (1 = the source's size), spacing? [x, y], align? (start|center|end), opacity?}  the source layer tiled; it updates as the source changes`
- `fill.remove` — Remove fill — `{ids?, index}`
- `fill.set` — Set fill — `{ids?, index?, paint | color, opacity?, visible?, blend?}`

## frame (3)

- `frame.create` — Create frame — `{preset? (name from FRAME_PRESETS), x?, y?, width?, height?, parent?, name?, props?} (a preset without x/y lands to the right of the page's frames)`
- `frame.presets` — List frame presets — `{}` — (not undoable)
- `frame.swapOrientation` — Swap orientation — `{ids?} (portrait ⇄ landscape: width and height trade places)`

## grid (3)

- `grid.add` — Add layout grid — `{ids?, grid? {kind: grid|columns|rows, ..}}`
- `grid.move` — Move layout grid — `{ids?, from, to} (indices in the layout grid list, bottom first)`
- `grid.remove` — Remove layout grid — `{ids?, index}`

## guide (5)

- `guide.add` — Add guide — `{vertical (bool), offset, frame? | page?} → {index}`
- `guide.clear` — Remove all guides — `{frame? | page?}`
- `guide.move` — Move guide — `{index, offset, frame? | page?}`
- `guide.remove` — Remove guide — `{index?, frame? | page?} (no index: the selected guide)`
- `guide.select` — Select guide — `{index?, frame? | page?}  a ruler guide to delete or nudge (deselects layers; no index: none)` — (not undoable)

## help (4)

- `help.about` — About FigCraft — `{}` — (not undoable)
- `help.gettingStarted` — Getting started — `{show? (default true; false closes them)}  the Getting started tips on the home screen: shows them again (the app opens the home screen), or closes them until asked for → {shown}` — (not undoable)
- `help.page` — Help page — `{}` — (not undoable)
- `help.shortcuts` — Keyboard shortcuts — `{}` — Ctrl+Shift+? — (not undoable)

## image (5)

- `image.adjust` — Adjust image — `{ids?, target? (fill|stroke, default fill), index? (default every image paint), preset? (vivid|muted|warm|cool|blackAndWhite|fade|reset, or the name of a preset saved in the file), filters? ({exposure, contrast, saturation, temperature, tint, highlights, shadows}: each -1..1, applied over the preset)}  sets the adjustments of the layers' image paints; returns {changed}`
- `image.deletePreset` — Delete image preset — `{name}`
- `image.place` — Place image — `{data (base64) | path, x?, y?, width?, height?, parent?, mode? (fill|fit|crop|tile)} → {id, image, width, height, imageProfile (its embedded colour profile; null: taken as sRGB)}`
- `image.presets` — Image presets — `{} → {builtIn: [{id, label, filters}], saved: [{name, filters}]}` — (not undoable)
- `image.savePreset` — Save image preset — `{name, filters? (default the adjustments of the first image paint of `ids`/the selection), ids?, target?, index?}  saved in the file; a preset with the same name is replaced`

## inspect (5)

- `inspect.assets` — Inspect assets — `{ids? (default the selection)} → {assets: [{id, name, kind: export|icon|image, exports}]}  the layers in and under them to hand over as files: those with export settings, icons (small, vector shapes only; SVG) and images (PNG). Export them with `file.exportLayers {assets: true}`` — (not undoable)
- `inspect.code` — Code for layer — `{id?, language?: css|html|react|leptos|swiftui|compose (default css; html, react and leptos are the whole layer tree; components take their properties as parameters, instances pass their values; a component connected to code (codeConnect.set) gives its import and snippet instead), unit?: px|rem (CSS, HTML, React and Leptos; default px), rootFontSize? (rem: pixels per rem, default 16)} → {code, language, connected}` — (not undoable)
- `inspect.componentCode` — Component code — `{id? (component, set or instance; default the selection), language?: react|leptos|swiftui|compose (default react)} → {component, name, set, properties: [{name, param, type, default, value? (instances)}], definition, usage? (instances; the connected snippet when the component is connected to code), connected: {importPath, name, template, import, code} | null}` — (not undoable)
- `inspect.properties` — Inspect properties — `{id?, colorFormat?: hex|rgb|css|hsl|hsb (default hex)} → {sections: [{title, rows: [{label, value, color?, token?}]}]}  layout (positions from the frame around the layer), auto layout, typography, fills, strokes and effects, with style and variable names` — (not undoable)
- `inspect.readyForDev` — Ready for dev — `{status?: readyForDev|completed|any (default readyForDev), page? (page id; default every page)} → {items: [{id, name, page, status}]}  frames and sections by handoff status (set it with `node.set {devStatus}`)` — (not undoable)

## instance (8)

- `instance.create` — Create instance — `{component (component or set: its default variant), x?, y?, parent?}`
- `instance.exposed` — Exposed nested instances — `{id? (instance)} → the nested instance copies whose properties it exposes` — (not undoable)
- `instance.place` — Place instance — `{component, x, y (page point: the instance is centred there, inside the frame under it; auto layout frames insert by position)}`
- `instance.resetSlot` — Reset slot — `{id? (a slot inside an instance, or the instance with `slot`), slot?}  (back to the main's default content)`
- `instance.setProperties` — Set instance properties — `{ids?, properties {name: value}} (variant properties switch variants)`
- `instance.slotInsert` — Insert into slot — `{id? (a slot inside an instance, or the instance with `slot`), slot? (slot property name), component, index? (child index; on top when omitted), replace? (clear the slot first)}`
- `instance.swap` — Swap instance — `{ids?, component}`
- `instance.swapAt` — Swap instance at point — `{component (component or set: its default variant), x, y (page point)}  swaps the instance there (preferring one showing the same component set; Alt-drop from the Assets panel); only text layers keep their overrides (by matching names)`

## layers (1)

- `layers.collapseAll` — Collapse layers — `{}` — Alt+L — (not undoable)

## layout (4)

- `layout.add` — Add auto layout — `{ids?, direction? (horizontal|vertical|grid)}` — Shift+A
- `layout.remove` — Remove auto layout — `{ids?}` — Alt+Shift+A
- `layout.setTrack` — Set grid track size — `{ids?, axis: columns|rows, index (0-based), sizing: fixed|hug|fill, value? (fixed: px, default the track's current size; fill: fr, default 1)}`
- `layout.suggest` — Suggest auto layout — `{ids?}` — Ctrl+Alt+Shift+A

## libraries (2)

- `libraries.open` — Libraries — `{}` — Alt+3 — (not undoable)
- `libraries.publish` — Publish library… — `{}  (opens the publish form in the Assets panel)` — (not undoable)

## library (18)

- `library.acceptUpdates` — Accept library updates — `{ids? [library ids; all when omitted]}  pulls updated components, styles, variable collections and variables in (instances keep their overrides; bound layers follow)`
- `library.add` — Add library — `{path (.figcraft file published as a library, or a share link of a file on a server: a view link is enough)}`
- `library.aliasVariable` — Alias library variable — `{library, alias (id or name of a published variable of the same type), variable (a local variable), mode? (default first)}  copies the library variable in (linked, read-only) and makes the local variable's value an alias of it`
- `library.applyStyle` — Apply library style — `{library, style (id or name of a published style), ids?, target? (fill|stroke)}  copies the style in (linked, read-only) and applies it`
- `library.bindVariable` — Bind library variable — `{library, variable (id or name of a published variable), field (as variable.bind), ids?}  copies the variable in (linked, read-only) and binds it`
- `library.extendCollection` — Extend library collection — `{library, collection (id or name of a published collection), name? (default "<name> (extended)")}  → {id}: a collection of this file with the library collection's modes and variables (they follow its updates); override their values per mode with variable.set (variable.resetOverride goes back to the inherited value) and add variables of its own`
- `library.import` — Import library component — `{library, component}  → {component (local, read-only main to instantiate with instance.create)}`
- `library.importVariable` — Import library variable — `{library, variable (id or name of a published variable)}  → {variable (local, read-only linked copy to use with variable.bind, or as an alias in variable.set)}`
- `library.list` — List libraries — `{assets? (also list each library's components, styles, variable collections and variables, and what this file can publish)}  → enabled libraries (version, updates, errors) and this file's published library` — (not undoable)
- `library.place` — Place library component — `{library (id, name or path), component (id or name of a published component, set or variant), x?, y? (page point; default the view's centre)}`
- `library.publish` — Publish library — `{description?, include? [component/set ids, style ids, variable collection ids or names: exactly these], exclude? [same]}  publishes this file's components, component sets, styles and variable collections (by default all but names starting with . or _, or what the last publish offered; variables hidden from publishing stay out unless something published uses them) as a new library version; save the file so other files see it`
- `library.publishToServer` — Publish library to server — `{server? (an edit link of this file on a figcraft-server; omit while this file is in a live session on a server, or give the server's address with its key to keep the file there first), key?, description?, include?, exclude? (as library.publish)}  publishes the library as the next version of the one kept on the server under this file (per-asset versions as library.publish); files that enabled it with a link of the file see the update → {id, version, components, styles, collections, variables, file?, edit?, view? (links when the file was kept there now)}` — (not undoable)
- `library.remove` — Remove library — `{id (library id, name or path)}  (copies still in use stay; unused ones are dropped)`
- `library.setVariableMode` — Set library variable mode — `{library, collection (id or name of a published collection), mode (id or name), ids? (frames; the page when omitted)}  copies the collection in (linked, read-only) and sets its mode on the frames`
- `library.swap` — Swap library — `{from (an enabled library: id, name or path), to (another enabled library)}  re-points every component instance, style and variable copied from `from` to the published one of the same name in `to` (instances keep their overrides) → {components, styles, variables, unmatched: [names still from `from`], removed (nothing of `from` is used any more: it was removed)}`
- `library.swapAt` — Swap instance to library component — `{library, component (id or name of a published component, set or variant), x, y (page point)}  copies the component in and swaps the instance there to it (as instance.swapAt)`
- `library.updates` — Library updates — `{}  → the components, styles, variable collections and variables with a newer published version, and variables new to a library collection this file extends (listed without an `id`: no copy yet)` — (not undoable)
- `library.usage` — Library usage — `{library? (an enabled team library: id, name or link; omit for this file's library on its server)}  → what files report: {id, name, instances, files: [{name, updated, instances}], components: [{id, name, instances, files}]}` — (not undoable)

## measure (2)

- `measure.distances` — Measure distances — `{ids? (default selection), to? (layer id; default the parent)} → {lines: [{x0, y0, x1, y1, label, dashed}]} (page space; what Alt-hover shows)` — (not undoable)
- `measure.padding` — Measure auto layout padding — `{id? (an auto layout frame or a child; default the selection)} → {frame, lines} (padding and gaps; what Shift+Alt-hover shows)` — (not undoable)

## node (5)

- `node.create` — Create layer — `{type: rectangle|ellipse|polygon|star|line|arrow|vector|text|frame|section|component|slice, x?, y? (relative to the parent frame; groups don't count), width?, height?, parent? (id; default: the page), index?, name?, text? (for text), path? (SVG path data for vector), props? {node.set keys}, select? (default true)}`
- `node.get` — Get layer — `{id}` — (not undoable)
- `node.reorder` — Reorder layer — `{id, index}`
- `node.reparent` — Move layer into — `{ids?, parent, index?}`
- `node.set` — Set properties — `name, visible, locked, opacity (0-1), blend, x, y (relative to the parent frame; groups don't count), width, height, rotation (degrees), fills (paints or colours; gradients as {type: linearGradient|radialGradient|angularGradient|diamondGradient, stops: ["#hex", ...], from?, to?} too), fill (colour), strokes, stroke (colour), strokeWeight, strokeAlign (inside|center|outside), strokeSides [t,r,b,l], strokeTopWeight / strokeRightWeight / strokeBottomWeight / strokeLeftWeight (one side; turns on individual strokes), strokeCap / startCap / endCap, strokeJoin, miterAngle (degrees: sharper joins bevel; or miterLimit as a ratio), dashes [..], widthProfile (preset uniform|wedge|taper|eye|rounded|pinch, [[t, scale], ...] or null), brush (preset id, {preset, spacing, sizeJitter, rotationJitter, scatter, seed} or null), cornerRadius (n or [tl,tr,br,bl]), cornerSmoothing (0-1), effects, clip, isMask, layout (null|horizontal|vertical|grid|{...}), gap, crossGap, padding (n or [t,r,b,l]), paddingTop/Right/Bottom/Left, mainAlign (min|center|max, or the auto gaps spaceBetween|spaceAround|spaceEvenly), crossAlign (min|center|max|baseline: first text baselines, horizontal layouts), contentAlign (wrapped lines: auto = packed where crossAlign says | spaceBetween), wrap (rows of a horizontal layout, columns of a vertical one), strokesIncluded (the frame's inside stroke takes up space), reverseZ (canvas stacking: true = first on top), columnGap / rowGap (aliases of gap / crossGap), gridColumns, gridRows, columnTracks / rowTracks ([120 | "1fr" | "auto" | {sizing, value}]), gridColumn / gridRow (0-based cell anchor, null = auto), gridColumnSpan, gridRowSpan, gridAlignH / gridAlignV (a grid child's alignment in its cell: min|center|max, auto/null = the frame's), sizingH / sizingV (fixed|hug|fill), absolute (ignore auto layout; follows constraints), minWidth, maxWidth, minHeight, maxHeight (null removes), constraints {horizontal, vertical}, grids, exports, characters, fontFamily, fontStyle, fontSize, lineHeight (auto|px|"150%"), letterSpacing (px|"2%"), textAlign (left|center|right|justified), textAlignVertical, textAutoResize (widthAndHeight|height|none|truncate), textDecoration, textDecorationStyle (solid|dotted|wavy), textDecorationThickness / textDecorationOffset (auto|px|"10%" of the font size; the offset runs from the baseline down to an underline's top edge), textDecorationSkipInk (underlines break around descenders), textDecorationColor (colour, or auto/null: the text's), textCase (original|upper|lower|title|smallCaps), paragraphSpacing, paragraphIndent, listStyle (none|bulleted|numbered; with start/end: the paragraphs those chars touch), indentation (list nesting level 0-8, same range rule), listSpacing (px between list items, in place of paragraphSpacing), hangingPunctuation, hangingList (markers outside the box), leadingTrim (vertical trim: none|capHeight), maxLines, features ({tag: bool}, e.g. {"liga": false, "tnum": true}), fontVariations / variationSettings ({axis: number}, e.g. {"wght": 550, "wdth": 85}; null = none), pointCount, innerRadius, arcStart, arcSweep, arcInner, booleanOperation (a boolean group's operation, or an operand's own; null: the group's), operandOperation (a layer in a boolean group: how it combines with the operands below it; null: the group's), constrainProportions, description, interactions, overflow, pluginData {k: v}`

## object (28)

- `object.batchRename` — Batch rename — `{ids?, find? (match; empty: none), regex? (find is a regular expression), replace? (for each match), name? (pattern for the whole name), start? (where $n starts and $N stops; default 1)} codes in replace and name: $& current name (or the match), $` and $' text before and after the match, $1…$9 groups, $n up, $N down, $nnn padded; layers are numbered in stacking order, bottom first`
- `object.convertToFrame` — Convert to frame — `{ids?} (groups become frames of the same box in place, their layers staying where they are: no fill, not clipping; sections become frames that keep their fill and don't clip. Frames are left alone; instances, main components, layers inside instances and sections holding sections are refused)`
- `object.convertToGroup` — Convert to group — `{ids?} (frames become groups in place, their layers staying where they are; what only a frame has goes: auto layout, fills, strokes, corner radius, clipping, layout grids, guides and scrolling. Groups are left alone; instances, main components, layers inside instances and empty frames are refused)`
- `object.convertToSection` — Convert to section — `{ids?} (frames on the page or in a section become sections in place, keeping their fill and layers; what only a frame has goes: auto layout, clipping, layout grids, guides and scrolling. Sections are left alone; nested frames, instances and main components are refused)`
- `object.flipH` — Flip horizontal — `{ids?} (in vector edit mode without ids: the selected points)` — Shift+H
- `object.flipV` — Flip vertical — `{ids?} (in vector edit mode without ids: the selected points)` — Shift+V
- `object.frameSelection` — Frame selection — `{ids?, name?}` — Alt+Cmd+G
- `object.group` — Group selection — `{ids?, name?}` — Cmd+G
- `object.hideOthers` — Hide other layers — `{}`
- `object.mask` — Use as mask — `{ids?}` — Ctrl+Alt+M
- `object.moveToPage` — Move to page — `{ids?, page}`
- `object.opacityKeys` — Opacity from number keys — `{digits ("1"…"9": 10%…90%, "0": 100%; two digits: that percentage, "45" is 45%), ids?}`
- `object.rasterize` — Rasterize selection — `{ids?, scale? (default 2)}`
- `object.releaseMask` — Release mask — `{ids?}`
- `object.removeFill` — Remove fill — `{ids?}` — Alt+/
- `object.removeFrame` — Remove frame — `{ids?}`
- `object.removeStroke` — Remove stroke — `{ids?}` — Shift+/
- `object.rename` — Rename — `{ids?, name?} (without a name: rename the layer inline in the layers panel)` — Cmd+R
- `object.resizeToFit` — Resize to fit — `{ids?} (frames, sections and components shrink or grow to their contents; the contents stay put)` — Alt+Shift+Cmd+R
- `object.rotate180` — Rotate 180° — `{ids?} (in vector edit mode without ids: the selected points)`
- `object.rotateLeft` — Rotate 90° left — `{ids?} (in vector edit mode without ids: the selected points)`
- `object.rotateRight` — Rotate 90° right — `{ids?} (in vector edit mode without ids: the selected points)`
- `object.setThumbnail` — Set as thumbnail — `{id?}`
- `object.swapFillStroke` — Swap fill and stroke — `{ids?}` — Shift+X
- `object.toggleLock` — Lock/Unlock selection — `{ids?, locked?}` — Shift+Cmd+L
- `object.toggleVisible` — Show/Hide selection — `{ids?, visible?}` — Shift+Cmd+H
- `object.ungroup` — Ungroup selection — `{ids?}` — Shift+Cmd+G
- `object.wrapInSection` — Wrap in new section — `{ids?, name?} (layers on the page or in a section; the section wraps them with some room)`

## page (8)

- `page.add` — Add page — `{name?} (a name starting with a hyphen adds a divider)`
- `page.delete` — Delete page — `{id?}`
- `page.duplicate` — Duplicate page — `{id?}`
- `page.list` — List pages — `{}` — (not undoable)
- `page.move` — Move page — `{id?, index}`
- `page.rename` — Rename page — `{id?, name} (an empty page named with a leading hyphen becomes a divider)`
- `page.select` — Go to page — `{id | index}` — (not undoable)
- `page.setBackground` — Page background — `{id?, color}`

## paint (1)

- `paint.documentColors` — Document colours — `{page?, limit? (default 21)} → solid colours used on the page, most used first` — (not undoable)

## plugin (11)

- `plugin.close` — Close plugin panel — `{id} → {closed}` — (not undoable)
- `plugin.directory.install` — Install plugin from directory — `{id, version? (default: the latest), confirm: true (required: installing runs the plugin's code), server?, sha256? (the one shown)} downloads, checks the SHA-256 and installs or updates it → {installed, name, version, permissions, sha256, path, source, replaced}` — (not undoable)
- `plugin.directory.list` — Browse plugin directory — `{server? (ws://host:port/; default: the one browsed last), query?} → {server, plugins: [{id, name, version, description, author, api, access, commands, widget, bytes, sha256, published, versions, installed, update}]}` — (not undoable)
- `plugin.directory.publish` — Publish plugin to directory — `{path (a plugin folder or its figcraft-plugin.json) | plugin (an installed plugin's id), server (ws://host:port/?key=…)} → {published: entry, server}` — (not undoable)
- `plugin.directory.unpublish` — Unpublish plugin from directory — `{id, version? (default: every version), server (ws://host:port/?key=…)} → {id, removed: [versions]}` — (not undoable)
- `plugin.event` — Use plugin panel control — `{id, control, value? (a field's new value)} presses a button or sets a field in the plugin's open panel; the plugin is called back as one undo step → like plugin.run` — (not undoable)
- `plugin.import` — Import plugin from manifest… — `{path (figcraft-plugin.json or its folder) | manifest (object or JSON text), wasm (base64)} replaces a plugin with the same id` — (not undoable)
- `plugin.list` — List plugins — `{} → {plugins: [{id, name, version, main, permissions, commands, path, loaded}], last}` — (not undoable)
- `plugin.remove` — Remove plugin — `{id}` — (not undoable)
- `plugin.run` — Run plugin — `{id, command? (default: the first), params? (the command's parameters), fuel? (lower instruction budget)} one undo step → {output, logs, calls, fuel, panel}` — (not undoable)
- `plugin.ui` — Plugin panel — `{id?} → plugin id's open panel (without id: the one opened last) {plugin, command, title, controls, values}, or null` — (not undoable)

## plugins (2)

- `plugins.manage` — Manage plugins… — `{}  opens the plugins window; returns the list like `plugin.list`` — (not undoable)
- `plugins.runLast` — Run last plugin — `{}` — Ctrl+Alt+Shift+P — (not undoable)

## pref (13)

- `pref.autoSave` — Save files automatically — `{on?}` — (not undoable)
- `pref.highlightHover` — Highlight layers on hover — `{on?}` — (not undoable)
- `pref.keepTool` — Keep tool selected after use — `{on?}` — (not undoable)
- `pref.language` — Interface language — `{language: system|en|cs|ru|es|es-419|fr|de|pt-BR|ja|ka|ko|zh-Hans|…; else English}` — (not undoable)
- `pref.nudge` — Nudge amount — `{small?, big?}` — (not undoable)
- `pref.numberKeysOpacity` — Use number keys for opacity — `{on?}` — (not undoable)
- `pref.publishServer` — Server for online sharing — `{url?: ws://host:port/ or wss://host/path/ (no key; empty: online sharing off; omit: back to the built-in server)} → {url, default (the built-in server)}: where Share ▸ Online keeps files and where join codes are asked` — (not undoable)
- `pref.reduceMotion` — Reduce motion — `{on?}` — (not undoable)
- `pref.renameDuplicates` — Rename duplicated layers — `{on?}` — (not undoable)
- `pref.showDimensions` — Show dimensions on objects — `{on?}` — (not undoable)
- `pref.startOnHome` — Start on the Home screen — `{on?}` — (not undoable)
- `pref.uiScale` — Interface size — `{scale?: a size from 0.75 to 3 relative to the system's display scale, 1 being the system's own size, so 1.25 is 125 %, not 125 (outside the range it stops at the nearest end; "auto" is 1; omit: just read it)} → {scale}: how large the whole interface is drawn; the canvas zoom is separate` — (not undoable)
- `pref.userName` — Your name in comments — `{name (blank: the default, "You")}` — (not undoable)

## proto (20)

- `proto.action.add` — Add prototype action — `{id?, index (interaction), path? (where it goes: [n] appends to an interaction with n actions, [i, b, j] inside block b of the conditional i; default: after the last action), action {type: …, as proto.interaction.add; setVariable takes `expression` text, conditional blocks take `expression` or `condition`}} → {path}`
- `proto.action.move` — Reorder prototype action — `{id?, index, path, to (its new index in the same list)} → {path}`
- `proto.action.remove` — Remove prototype action — `{id?, index, path}  (an interaction keeps at least one action: remove the interaction instead)`
- `proto.action.set` — Edit prototype action — `{id?, index, path [action, block, action, …], action {…}}  replaces the action there`
- `proto.closePreview` — Close prototype preview — `{}` — (not undoable)
- `proto.conditional.addBlock` — Add else if / else — `{id?, index, path (a conditional action), else? bool (add the else block; default: an else if before it), expression? (text, e.g. "count >= 3") | condition? (expression JSON); default condition: the first variable equal to its value} → {block}`
- `proto.conditional.removeBlock` — Remove if / else if / else — `{id?, index, path (a conditional action), block}  removing the if when only an else (or nothing) is left removes the whole conditional action → {removedAction}`
- `proto.conditional.setCondition` — Edit condition — `{id?, index, path (a conditional action), block, expression (text) | condition (expression JSON)}  the condition must give true or false`
- `proto.evaluate` — Evaluate prototype expression — `{expression (text, e.g. "count + 1", "accent[Dark]", "mode(Theme) == 'Dark'") | expr (expression JSON), id? (the layer it runs on: variables resolve in its modes; default: the document's default modes)} → {value, type, text}  without changing anything` — (not undoable)
- `proto.flow.add` — Add flow starting point — `{start? (top-level frame id; default selection), name?}`
- `proto.flow.remove` — Remove flow — `{start}`
- `proto.flow.rename` — Rename flow — `{start, name?, description?}`
- `proto.interaction.add` — Add interaction — `{id?, trigger? {type: onClick|onHover|onPress|onDrag|mouseEnter|mouseLeave|mouseDown|mouseUp|afterDelay {ms}|keyPress {key (a key or a combination: Shift+K, Ctrl+Alt+Delete; or a controller button: Gamepad A|B|X|Y|LB|RB|LT|RT|View|Menu|LS|RS|Up|Down|Left|Right|Home)}}, action {type: navigate {preserveScroll?}|back|scrollTo {offset? [x, y] (where the layer ends up from the top-left)}|openOverlay {position?, offset? [x, y] (position manual: the overlay's top-left from the top-left of the layer that opens it; without it, right below that layer), close_on_outside? (default true), background?}|swapOverlay|closeOverlay|openUrl {url}|changeTo|setVariable {variable, value | expression (text, e.g. "count + 1")}|setVariableMode {collection, mode}|conditional {blocks [{condition? | expression? (text, e.g. "count >= 3"), actions}]}, dest?}, actions? [..], transition? {type: instant|dissolve|smartAnimate|moveIn|moveOut|push|slideIn|slideOut, direction?: left|right|top|bottom}, durationMs?, easing? linear|easeIn|easeOut|easeInOut|easeInBack|easeOutBack|easeInOutBack|gentle|quick|bouncy|slow|{customBezier {x1, y1, x2, y2}}|{customSpring {mass, stiffness, damping}}}, delayMs? (mouse enter, leave, down and up: how long after the gesture the actions run, up to 600000)} — or {id, dest} for a click-navigate. Returns {index}`
- `proto.interaction.clear` — Remove all interactions — `{ids?}`
- `proto.interaction.remove` — Remove interaction — `{id?, index}`
- `proto.interaction.set` — Edit interaction — `{id?, index, interaction {..}} replaces it; or patch fields: {id?, index, trigger?, action? (first action), actions?, transition?, durationMs?, easing?, delayMs?}`
- `proto.present` — Present — `{start? (frame id; default: the selected frame, else the first flow, else the first frame)}` — Alt+Cmd+Enter — (not undoable)
- `proto.presentOptions` — Presentation options — `{scale? fit|fitWidth|fill|actual, deviceFrame? bool, hotspotHints? bool, inspect? bool}  how the presenter sizes the prototype (Fit scales down to fit, Fit width fills the width, Fill covers the window, Actual shows it at 100%), whether it draws the device, whether a click where nothing reacts flashes the hotspots (on by default) and whether the Inspect panel shows the properties of the layer under the pointer; kept for later presentations` — (not undoable)
- `proto.preview` — Open prototype preview — `{start? (frame id; default as proto.present)}  a floating preview pane over the canvas that follows edits live` — Shift+Space — (not undoable)
- `proto.settings` — Prototype settings — `{device? (a device name, "Custom size" or "None"), background?, rotation? portrait|landscape (or 0|90; phones and tablets turn), color? (one of the device's colours by name), width?, height? (the custom size's screen, 1–10000 points; picks "Custom size"), responsive? bool (frames resize to the screen and their constraints and auto layout respond)}`

## section (1)

- `section.toggleContents` — Hide/Show section contents — `{ids?, hidden? (default: hide unless all are hidden)} (a hidden section shows only its name and outline; its layers aren't drawn or hit)`

## select (21)

- `select.add` — Add to selection — `{ids}` — (not undoable)
- `select.all` — Select all — `{}` — Cmd+A — (not undoable)
- `select.area` — Select area — `{x, y, width, height (page units; a marquee from x, y), add? (toggle like a Shift marquee), deep? (nested layers, like Cmd/Ctrl)} → {selection}; with no box: draw one from the keyboard in the app (arrows move it, Cmd/Ctrl+arrows or Shift+arrows size it, Enter selects, Escape cancels)` — Ctrl+Space — (not undoable)
- `select.byName` — Select layers by name — `{query, page? (default current; "all" for every page)}` — (not undoable)
- `select.children` — Select children — `{}` — Enter — (not undoable)
- `select.inverse` — Select inverse — `{}` — Shift+Cmd+A — (not undoable)
- `select.layersAt` — Layers at a point — `{x, y (page coordinates)} → {layers: [{id, name, type, depth}]} (every layer under the point, front-most first; what the context menu's Select layer lists)` — (not undoable)
- `select.matching` — Select matching layers — `{}` — Alt+Cmd+A — (not undoable)
- `select.next` — Select next sibling — `{}` — Tab — (not undoable)
- `select.none` — Select none — `{}` — Escape — (not undoable)
- `select.parent` — Select parent — `{}` — Shift+Enter — (not undoable)
- `select.previous` — Select previous sibling — `{}` — Shift+Tab — (not undoable)
- `select.remove` — Remove from selection — `{ids}` — (not undoable)
- `select.sameEffect` — Select same effect — `{}` — (not undoable)
- `select.sameFill` — Select same fill — `{}` — (not undoable)
- `select.sameFont` — Select same font — `{}` — (not undoable)
- `select.sameInstance` — Select same instance — `{}` — (not undoable)
- `select.sameProperties` — Select same properties — `{}` — (not undoable)
- `select.sameStroke` — Select same stroke — `{}` — (not undoable)
- `select.sameText` — Select same text properties — `{}` — (not undoable)
- `select.set` — Select — `{ids: [..]}  (replace the selection)` — (not undoable)

## selection (4)

- `selection.applyColorStyle` — Apply selection color style — `{targets, style}; applies the color style to matching fill/stroke lists (text ranges keep typography)`
- `selection.colors` — Selection colors — `{ids?} → {colors: [{paint, targets}]}; includes descendants and text ranges` — (not undoable)
- `selection.selectColor` — Select layers with color — `{targets} → {ids}; selects the layers owning these paint slots` — (not undoable)
- `selection.setPaint` — Change selection color — `{targets: [{id, fills, index, range: [start,end] | null}], paint}`

## shape (6)

- `shape.arrow` — Arrow — `{x, y, width (length), parent?, props?}`
- `shape.ellipse` — Ellipse — `{x, y, width, height, parent?, props?}`
- `shape.line` — Line — `{x, y, width (length), parent?, props? {rotation}}`
- `shape.polygon` — Polygon — `{x, y, width, height, parent?, props? {pointCount}}`
- `shape.rectangle` — Rectangle — `{x, y, width, height, parent?, props?}`
- `shape.star` — Star — `{x, y, width, height, parent?, props? {pointCount, innerRadius}}`

## shapeBuilder (4)

- `shapeBuilder.merge` — Merge regions — `{ids?, regions?: [i, ...], points?: [[x, y], ...] (page)} → {id, changed, removed, outlines, regions} — one new shape from the regions, styled like the top-most fill or stroke over the first; the shapes lose those areas (strokes of the shapes involved become outlined vectors: `outlines`)`
- `shapeBuilder.mode` — Shape builder mode — `{mode: merge|remove} (what a click does; Alt does the other)` — (not undoable)
- `shapeBuilder.regions` — Shape builder regions — `{ids?} → {sources (bottom to top), regions: [{index, path (SVG, page), sources (top-most first), parts: [{id, stroke}] (the fills and outlined strokes covering it, top-most first), bounds [x, y, w, h], point [x, y] inside}]} — visible strokes take part as their outlined areas, so stroked lines and open paths split regions` — (not undoable)
- `shapeBuilder.remove` — Remove regions — `{ids?, regions?: [i, ...], points?: [[x, y], ...] (page)} → {changed, removed, outlines, regions} — the shapes (and strokes) covering the regions lose them`

## stroke (6)

- `stroke.add` — Add stroke — `{ids?, paint? (default black)}`
- `stroke.brush` — Brush — `{ids?, preset (taper|ink|ribbon|bristle: stretched along the path; dots|stars|confetti|leaves: scattered along it | null: plain), spacing? (× weight), sizeJitter? (0-1), rotationJitter? (0-1), scatter? (0-4 × weight), seed?}  layers without a stroke get a black one`
- `stroke.move` — Move stroke — `{ids?, from, to} (indices in the stroke list, bottom first)`
- `stroke.remove` — Remove stroke — `{ids?, index}`
- `stroke.set` — Set stroke — `{ids?, index?, paint | color, opacity?, visible?, blend?}`
- `stroke.widthProfile` — Width profile — `{ids?, preset? (uniform|wedge|taper|eye|rounded|pinch) | points? [[t (0-1 along each subpath), scale (× stroke weight)], ...]} — none = uniform`

## style (10)

- `style.apply` — Apply style — `{ids?, style (id or name), target? (fill|stroke; paint styles), start?, end? (text styles: these chars; while editing text, the selected chars)}`
- `style.bind` — Bind variable in style — `{style, field, variable? (id or name; none: unbind)}  bind a variable to a field of the style's value: a paint style's `fills/<i>/color` (or `fill`: its first paint) and `fills/<i>/stops/<j>/color`, an effect style's `effects/<i>/<color|radius|spread|offsetX|offsetY|startRadius>`, a grid style's `layoutGrids/<i>/<size|count|gutter|offset>`, a text style's `fontSize|lineHeight|letterSpacing` (numbers, px) and `fontFamily|fontStyle` (strings). Every layer using the style shows the field resolved in its own modes; the style keeps it resolved in the default modes`
- `style.create` — Create style — `{type: paint|text|effect|grid, name, from? (node id; default first selected), description?, value? (paints/effects/grids/text style JSON)}`
- `style.delete` — Delete style — `{style}`
- `style.detach` — Detach style — `{ids?, which: fill|stroke|effect|grid|text, start?, end? (text: these chars; while editing text, the selected chars)}`
- `style.duplicate` — Duplicate style — `{style} → {id} (right below it, named "<name> copy")`
- `style.list` — List styles — `{type?}` — (not undoable)
- `style.move` — Move styles — `{styles [ids], before? (style id; default: the end), folder? ("Brand/Blog"; "" = no folder: the styles are renamed into it)}`
- `style.renameFolder` — Rename style folder — `{folder ("Brand/Blog"), name ("Brand/News")} (renames the styles in it)`
- `style.update` — Edit style — `{style, name?, description?, value?, from? (node id: redefine from it)}`

## template (1)

- `template.list` — List templates — `{}  the starter templates: [{id, name, description, kind (app|website|kit|media), size}]` — (not undoable)

## text (56)

- `text.alignCenter` — Align center — `{ids?}` — Alt+Cmd+T
- `text.alignJustify` — Justify — `{ids?}` — Alt+Cmd+J
- `text.alignLeft` — Align left — `{ids?}` — Alt+Cmd+L
- `text.alignRight` — Align right — `{ids?}` — Alt+Cmd+R
- `text.bold` — Bold — `{ids?}` — Cmd+B
- `text.bulletList` — Bulleted list — `{ids?}  while editing: the selected paragraphs` — Shift+Cmd+8
- `text.case` — Letter case — `{case: original|upper|lower|title|smallCaps, ids?}`
- `text.caseLower` — Lowercase — `{ids?}`
- `text.caseOriginal` — Original case — `{ids?}`
- `text.caseSmallCaps` — Small caps — `{ids?}`
- `text.caseTitle` — Title case — `{ids?}`
- `text.caseUpper` — Uppercase — `{ids?}`
- `text.create` — Text — `{text, x, y, parent?, width? (fixed width wraps), props? (fontSize, fontFamily, …)}`
- `text.decoration` — Decoration — `{decoration: none|underline|strikethrough, ids?}`
- `text.edit.begin` — Edit text — `{id, caret? (char index; default select all)}` — (not undoable)
- `text.edit.caret` — Set caret — `{index, extend?}` — (not undoable)
- `text.edit.end` — Stop editing text — `{}` — (not undoable)
- `text.edit.insert` — Type text — `{text}`
- `text.edit.key` — Text key — `{key: Backspace|Delete|Left|Right|Up|Down|Home|End|Enter|Tab|Escape|SelectAll, shift?, alt?, cmd?}  in a list, Tab nests the item and Shift+Tab, Enter on an empty item or Backspace at its start move it out`
- `text.edit.preedit` — Compose text (IME) — `{text (empty = cancel), cursor? (chars into text)}; shown at the caret, committed by text.edit.insert` — (not undoable)
- `text.edit.selectLine` — Select line — `{index}` — (not undoable)
- `text.edit.selectWord` — Select word — `{index}` — (not undoable)
- `text.edit.selection` — Text selection — `{}` — (not undoable)
- `text.endPreview` — End text preview — `{}  puts the document back as it was before text.preview → {ended}` — (not undoable)
- `text.fonts` — List fonts — `{family? (list its styles), style?, features? (the face's OpenType features), axes? (the face's variation axes and named instances)}` — (not undoable)
- `text.italic` — Italic — `{ids?}` — Cmd+I
- `text.lineHeightDown` — Decrease line height — `{ids?}` — Alt+Shift+,
- `text.lineHeightUp` — Increase line height — `{ids?}` — Alt+Shift+.
- `text.link` — Create link — `{url, ids?}` — Shift+Cmd+U
- `text.listIndent` — Indent list — `{}  while editing: the selected list items a level deeper` — Cmd+]
- `text.listOutdent` — Outdent list — `{}  while editing: the selected list items a level out` — Cmd+[
- `text.listStyle` — List style — `{style: none|bulleted|numbered, ids?}  while editing: the selected paragraphs`
- `text.loadFont` — Load font file — `{path | data (base64)}  adds a font file (.ttf, .otf, .ttc, .otc; every face of a collection) to this session's fonts without installing it; the open document's auto-sizing text in its families fits it (text.refit) → {families, refitted: [ids]}`
- `text.maxLines` — Max lines — `{lines (0 = no limit; truncates), ids?}`
- `text.missingFonts` — Missing fonts — `{}  fonts the open document names that aren't installed (text layers, styled ranges, text styles, font family variables); the app shows them → {families: [{family, layers}]}` — (not undoable)
- `text.numberList` — Numbered list — `{ids?}  while editing: the selected paragraphs` — Shift+Cmd+7
- `text.onPath` — Text on path — `{text? (text layer), path? (vector or shape layer; default: the selected text and other layer), start? (0..1 along the path), flip?}  the text follows the path and the path layer is removed → {id}`
- `text.paragraphIndent` — Paragraph indent — `{indent (px), ids?}`
- `text.paragraphSpacing` — Paragraph spacing — `{spacing (px), ids?}`
- `text.pathOptions` — Text path options — `{start? (0..1 along the path), flip?, ids?}  for text on a path`
- `text.preview` — Preview text change — `{command: style.apply|library.applyStyle|text.setVariations|text.style, params}  shows what the command would do on the canvas without an undo step (a hovered font family or style, text style or named instance, a dragged axis slider), in place of an earlier preview; text.endPreview or any other command ends it, so running the command for real commits it as one undo step` — (not undoable)
- `text.refit` — Fit text to fonts — `{ids? (these layers and the text in them; default: the whole document)}  auto-sizing text measures its box again, e.g. a box measured in a fallback font while its family was missing → {refitted: [ids whose size changed]}`
- `text.removeFromPath` — Remove text from path — `{ids?}  text on a path back to a line of auto-width text`
- `text.rescanFonts` — Rescan installed fonts — `{}  walks the system font folders again, for fonts installed while the app runs; the open document's auto-sizing text in the families that gained faces (new ones, or styles installed since) fits them (text.refit) → {added: [families that were unknown], refitted: [ids]}`
- `text.set` — Set text — `{id?, characters}`
- `text.setFeatures` — OpenType features — `{features: {tag: bool | null (font default)}, replace? (clear others first), id?/ids?}`
- `text.setVariations` — Variable font axes — `{variations: {axis: number | null (style default)}, replace? (clear others first), id?/ids?}; while editing: the selected range`
- `text.sizeDown` — Decrease font size — `{ids?}` — Shift+Cmd+,
- `text.sizeUp` — Increase font size — `{ids?}` — Shift+Cmd+.
- `text.strikethrough` — Strikethrough — `{ids?}` — Shift+Cmd+X
- `text.style` — Style text range — `{id?, start?, end?, fontFamily?, fontStyle?, fontWeight?, fontSize?, lineHeight?, letterSpacing?, textDecoration?, textCase?, hyperlink?, textFills?}`
- `text.trackingDown` — Decrease letter spacing — `{ids?}` — Alt+,
- `text.trackingUp` — Increase letter spacing — `{ids?}` — Alt+.
- `text.underline` — Underline — `{ids?}` — Cmd+U
- `text.weightDown` — Decrease font weight — `{ids?}` — Alt+Cmd+,
- `text.weightUp` — Increase font weight — `{ids?}` — Alt+Cmd+.

## tool (21)

- `tool.arrow` — Arrow — `{}` — Shift+L — (not undoable)
- `tool.comment` — Comment — `{}` — C — (not undoable)
- `tool.ellipse` — Ellipse — `{}` — O — (not undoable)
- `tool.frame` — Frame — `{}` — F — (not undoable)
- `tool.hand` — Hand — `{}` — H — (not undoable)
- `tool.line` — Line — `{}` — L — (not undoable)
- `tool.move` — Move — `{}` — V — (not undoable)
- `tool.pen` — Pen — `{}` — P — (not undoable)
- `tool.pencil` — Pencil — `{}` — Shift+P — (not undoable)
- `tool.pencilBrush` — Pencil brush — `{preset? (taper|ink|ribbon|bristle|dots|stars|confetti|leaves | null: plain), spacing?, sizeJitter?, rotationJitter?, scatter?, seed?} (the brush new Pencil strokes get; omit `preset` to read it)` — (not undoable)
- `tool.place` — Place with the tool — `{tool? (a shape or frame tool; default the current one), x?, y? (its centre, page coords; default the middle of the view)} — what a click with the tool makes, selected (Enter with the tool chosen)` — (not undoable)
- `tool.polygon` — Polygon — `{}` — (not undoable)
- `tool.rectangle` — Rectangle — `{}` — R — (not undoable)
- `tool.scale` — Scale — `{}` — K — (not undoable)
- `tool.scaleAnchor` — Scale anchor — `{anchor?: tl|t|tr|l|c|r|bl|b|br} (the point of the selection that stays put when the Scale tool scales; omit to read it)` — (not undoable)
- `tool.section` — Section — `{}` — Shift+S — (not undoable)
- `tool.set` — Choose tool — `{tool: move|scale|hand|frame|section|slice|rectangle|line|arrow|ellipse|polygon|star|pen|pencil|text|comment|shapeBuilder}` — (not undoable)
- `tool.shapeBuilder` — Shape builder — `{}` — Shift+M — (not undoable)
- `tool.slice` — Slice — `{}` — S — (not undoable)
- `tool.star` — Star — `{}` — (not undoable)
- `tool.text` — Text — `{}` — T — (not undoable)

## transform (9)

- `transform.move` — Move — `{ids?, dx, dy}  (page units)`
- `transform.moveTo` — Move to — `{ids?, x, y} (page coordinates of the selection's top-left)`
- `transform.nudge` — Nudge — `{dx, dy, big? (use the big nudge amount)} (auto layout children move one place instead: along the flow, between wrapped rows, to the next grid cell, or into the neighbouring nested auto layout frame)`
- `transform.nudgeSize` — Resize by nudge — `{dw, dh, big?} (grow or shrink the selection by the nudge amount, top-left fixed)`
- `transform.resize` — Resize — `{ids?, width?, height?, anchor? (tl|t|tr|l|c|r|bl|b|br)}`
- `transform.rotate` — Rotate — `{ids?, degrees, cx?, cy? (pivot, page coords; default the selection's rotation origin, else its centre)}`
- `transform.rotationOrigin` — Move rotation origin — `{on? (default: toggles)} — shows the selection's rotation origin to drag (Escape hides it); not saved` — Alt+R — (not undoable)
- `transform.scale` — Scale — `{ids?, factor, cx?, cy? (pivot; default top-left)} — scales size, strokes, effects, text (the K tool)`
- `transform.setRotationOrigin` — Set rotation origin — `{x, y (page coords) | reset: true} — the point the selection turns about (default its centre); kept while the selection lasts, not saved` — (not undoable)

## variable (18)

- `variable.addMode` — Add mode — `{collection, name, from? (mode id or name to duplicate; default: the default mode)}`
- `variable.bind` — Bind variable — `{ids?, field (fill|stroke (first paint)|fills/<i>/color|strokes/<i>/color|fills/<i>/stops/<j>/color (gradient stops)|effects/<i>/<offsetX|offsetY|radius|startRadius|spread|color>|layoutGrids/<i>/<size|count|gutter|offset>|componentProperties/<name> (instances: boolean/text properties; variant properties take string variables naming a value)|width|height|opacity (percent)|cornerRadius|gap|paddingHorizontal|characters|visible|fontSize…; list indices bottom first), variable (null unbinds)}`
- `variable.create` — Create variable — `{collection, name, type: color|number|string|boolean, value (default mode) | values {modeName: value}}`
- `variable.createCollection` — Create variable collection — `{name, modes? [names]}`
- `variable.delete` — Delete variable — `{variable} (bound layers keep their values; variables aliasing it take its values)`
- `variable.deleteCollection` — Delete collection — `{collection} (with its variables; bound layers keep their values)`
- `variable.duplicate` — Duplicate variable — `{variable} → {id}`
- `variable.export` — Export variables — `{collections? [ids or names; default every collection of this file, not library copies], format? (json (default): the local variables JSON that variable.import reads | css: custom properties, the default mode on :root and each other mode on [data-<collection>="<mode>"]), path? (write it there)}  → {text}, or {path} when written` — (not undoable)
- `variable.import` — Import variables — `{variables (the local variables JSON, as variable.export writes it: an object, JSON text or a path; `variableCollections` and `variables` under `meta` or at the top level)}  collections join this file's collection of the same name (values by mode name; new modes and variables are added, a variable of another type is skipped), others are added  → {collections (added), variables (added), updated, warnings (also when it holds no variables, or fewer than its collections list)}`
- `variable.list` — List variables — `{}` — (not undoable)
- `variable.moveMode` — Move mode — `{collection, mode, to (index; 0 = the default mode, layers on Auto follow it)}`
- `variable.removeMode` — Delete mode — `{collection, mode} (a collection keeps at least one mode)`
- `variable.renameCollection` — Rename collection — `{collection, name}`
- `variable.renameMode` — Rename mode — `{collection, mode, name}`
- `variable.resetOverride` — Reset variable override — `{variable (a variable of an extended collection inherited from the collection it extends), mode? (id or name; every overridden mode when omitted)}  the value follows the inherited one again`
- `variable.set` — Set variable value — `{variable, mode? (name or id; default first), value | {alias: variable} (same type, no loops)}`
- `variable.setMode` — Set variable mode — `{ids? (frames/page), collection, mode (id or name; null: Auto, inherited from the parent)}`
- `variable.update` — Edit variable — `{variable, name?, description?, scopes? ([scope ids]; null or ["ALL_SCOPES"] = every supported property, [] = hidden from pickers), hiddenFromPublishing? (left out when the file is published as a library), codeSyntax? {WEB?, iOS?, ANDROID?: name code uses ("" clears)}}`

## vector (40)

- `vector.create` — Vector — `{path (SVG path data) | points [[x,y],..], closed?, x?, y?, width?, height? (scale the path; one keeps its proportion), parent?, props?}`
- `vector.deleteHeal` — Delete and heal selection — `{vertices?} (default the selected points of every edited layer)` — Shift+Delete
- `vector.edit.addVertex` — Add point — `{segment, t (0..1)}`
- `vector.edit.begin` — Edit vector — `{id? | ids?} (default the selection; several layers are edited at once, the first active; converts shapes to vectors)` — (not undoable)
- `vector.edit.bend` — Bend segment — `{segment, t (0..1), x, y (page point the curve passes through)}`
- `vector.edit.bounds` — Selected points' bounds — `{} → {x, y (top-left in the parent's coordinates), width, height (in the vector's axes), corners (page), points}` — (not undoable)
- `vector.edit.connect` — Connect points — `{a, b} (adds a straight segment)`
- `vector.edit.cornerRadius` — Point corner radius — `{radius, vertices?}`
- `vector.edit.cut` — Cut path — `{segment, t?} | {vertex} | {from: [x, y], to: [x, y]} (page: cuts every path the line crosses; parts that come apart move to layers of their own)`
- `vector.edit.delete` — Delete points — `{vertices?, segments?} (default the selection in every edited layer)`
- `vector.edit.end` — Done editing — `{}` — (not undoable)
- `vector.edit.erase` — Erase — `{points: [[x, y], ...] (page), radius? (page units, default 8)} — removes the parts of paths the brush passes over`
- `vector.edit.lasso` — Lasso select — `{points: [[x, y], ...] (page), add?}` — (not undoable)
- `vector.edit.mirroring` — Handle mirroring — `{mode: none|angle|angleAndLength, vertices?}`
- `vector.edit.moveHandles` — Move handles — `{dx, dy (page units), handles?: [[segment, start], ...] (default the selected handles), independent?}`
- `vector.edit.moveVertices` — Move points — `{vertices?, dx, dy} (local units; default the selected points of every edited layer)`
- `vector.edit.nudge` — Nudge points — `{dx, dy} (page units; the selected points of every edited layer)`
- `vector.edit.paint` — Paint bucket — `{x, y} | {points: [[x, y], ...]} (page points: fills or unfills the closed area under the first, and does the same to the areas under the rest, like a drag)`
- `vector.edit.pen` — Pen point — `{x, y (page), dx?, dy? (handle drag)} — continues from the pen's open end; clicking a point connects to it`
- `vector.edit.penEnd` — End pen path — `{}` — (not undoable)
- `vector.edit.position` — Point position — `{x?, y?} (the selected points' top-left, in the parent's coordinates)`
- `vector.edit.resize` — Resize points — `{width?, height?, center? (about the centre; default keeps the top-left)} — scales the selected points' box in the vector's axes`
- `vector.edit.rotate` — Rotate points — `{angle (degrees, counter-clockwise), cx?, cy? (page pivot; default the box centre)}`
- `vector.edit.select` — Select points — `{vertices?: [i, ...], segments?: [i, ...], handles?: [[segment, start], ...], regions?: [i, ...] (filled regions, with their points), id? (an edited layer, made active), add?}` — (not undoable)
- `vector.edit.selectAll` — Select all points — `{} (in every edited layer)` — (not undoable)
- `vector.edit.setHandle` — Set handle — `{segment, start (bool), x, y (local), independent?}`
- `vector.edit.smooth` — Smooth or sharpen points — `{vertices?, smooth? (default true)}`
- `vector.edit.state` — Vector edit state — `{} → page-space overlay plus the local network` — (not undoable)
- `vector.edit.strokeCap` — Point stroke cap — `{cap: none|round|square|lineArrow|triangleArrow|reversedTriangle|circleFilled|diamondFilled|null (the layer's), vertices?} — where the stroke ends at these points`
- `vector.edit.strokeJoin` — Point stroke join — `{join: miter|bevel|round|null (the layer's), vertices?} — how the stroke turns at these points`
- `vector.edit.tool` — Vector edit tool — `{tool: move|pen|bend|paint|lasso|cut|eraser|width}` — (not undoable)
- `vector.edit.transform` — Transform points — `{matrix: [a, b, c, d, e, f] (page space), vertices? (default the selected points)}`
- `vector.edit.widthPoint` — Width point — `{action?: add|set|remove, index?, t? (0-1 along the path), width? (px) | scale? (× stroke weight)} — add needs t (width defaults to the current one); set moves or resizes point `index`; with `side` only that side of the path changes (looking along it): `width` is then the distance from the centre line to that edge and `scale` that side's scale (× stroke weight, as if both sides were that wide)`
- `vector.flatten` — Flatten — `{ids?}` — Alt+Shift+F
- `vector.join` — Join selection — `{ids?} (in vector edit mode: joins the selected points)` — Cmd+J
- `vector.offset` — Offset path — `{ids?, offset}`
- `vector.outlineStroke` — Outline stroke — `{ids?}` — Alt+Cmd+O
- `vector.reverse` — Reverse path direction — `{ids?}`
- `vector.simplify` — Simplify vector — `{ids?, tolerance?}`
- `vector.smoothJoin` — Smooth join selection — `{ids?} (in vector edit mode: joins the selected points smoothly)` — Shift+Cmd+J

## version (8)

- `version.autosave` — Autosave version — `{}  save an automatic checkpoint when the document has unsaved changes since the last version (with `pref.autoSave` on: changes made since it was opened); the app does this every 30 minutes; keeps the newest 20 autosaves → {saved, version?}` — (not undoable)
- `version.delete` — Delete version — `{id | index}` — (not undoable)
- `version.duplicate` — Duplicate version — `{id | index}  open the version as a new document; returns its tab `index`` — (not undoable)
- `version.exitPreview` — Back to current version — `{}  end a version preview` — (not undoable)
- `version.list` — List versions — `{}  the version history, oldest first: [{id, index, name, description, time (Unix seconds), auto?, previewing?}]` — (not undoable)
- `version.preview` — View version — `{id | index}  show the version on the canvas in place of the document (read-only; `version.restore` keeps it, `version.exitPreview` goes back)` — (not undoable)
- `version.rename` — Rename version — `{id | index, name, description?}  a titled autosave becomes a named version` — (not undoable)
- `version.restore` — Restore version — `{id | index}  replace the design with the version (one undo step; the file name and the comments stay; the design as it was is kept in the history first, unless a version of it was just saved or restored)`

## view (48)

- `view.assets` — Assets panel — `{}` — Alt+2 — (not undoable)
- `view.comments` — Comments — `{on?}` — Shift+C — (not undoable)
- `view.contextMenu` — Show context menu — `{}  the selection's context menu at its layer row (when the layers panel has the keyboard) or on the canvas; the menu takes the keyboard` — Shift+F10 — (not undoable)
- `view.design` — Design panel — `{}` — Alt+8 — (not undoable)
- `view.designPrototype` — Switch between Design and Prototype — `{}` — Shift+E — (not undoable)
- `view.devMode` — Dev Mode — `{}` — Shift+D — (not undoable)
- `view.frameOutlines` — Frame outlines — `{on?}` — (not undoable)
- `view.fullscreen` — Full screen — `{on?}  the window fills the screen (the desktop app; a no-op headless)` — F11 — (not undoable)
- `view.get` — Get view — `{}` — (not undoable)
- `view.layers` — Layers panel — `{}` — Alt+1 — (not undoable)
- `view.layoutGrids` — Layout grids — `{on?}` — Shift+G — (not undoable)
- `view.leftSidebar` — Show/Hide left sidebar — `{}` — Shift+Cmd+\ — (not undoable)
- `view.maskOutlines` — Mask outlines — `{on?}` — (not undoable)
- `view.multiplayerCursors` — Multiplayer cursors — `{on?}  others' cursors in a live session` — Alt+Cmd+\ — (not undoable)
- `view.nextFrame` — Zoom to next frame — `{}` — N — (not undoable)
- `view.nextPage` — Next page — `{}` — PageDown — (not undoable)
- `view.nextRegion` — Focus next region — `{}` — F6 — (not undoable)
- `view.outlines` — Outlines — `{on?}` — Shift+Cmd+O — (not undoable)
- `view.outlinesHiddenLayers` — Include hidden layers in outlines — `{on?}  outline mode (and outlines for the selection) outlines hidden layers too; they can be clicked there` — (not undoable)
- `view.outlinesObjectBounds` — Include object bounds in outlines — `{on?}  outline mode also draws each layer's box (groups, text, vectors); a click on a box's edge picks its layer` — (not undoable)
- `view.outlinesSelection` — Outlines for selection — `{on?}  outline mode for the selected layers only` — (not undoable)
- `view.pan` — Pan the view — `{dx, dy (arrow-key steps, e.g. 1 or -1), big? (ten times as far, like Shift)}` — (not undoable)
- `view.panelWidths` — Reset panel widths — `{left?, right? (the panels' widths in pixels, kept within their limits)}  without either, both go back to their default width (a double-click on a panel's edge does it for that panel)` — (not undoable)
- `view.pixelGrid` — Pixel grid — `{on?}` — Shift+' — (not undoable)
- `view.pixelPreview` — Pixel preview — `{on?, scale? (1|2: rendered pixels per page pixel; turns it on)}` — Ctrl+Alt+P — (not undoable)
- `view.prevFrame` — Zoom to previous frame — `{}` — Shift+N — (not undoable)
- `view.prevPage` — Previous page — `{}` — PageUp — (not undoable)
- `view.previousRegion` — Focus previous region — `{}` — Shift+F6 — (not undoable)
- `view.proofSrgb` — Soft-proof sRGB — `{on?}  mark the colours of a Display P3 file that sRGB screens and files can't show` — (not undoable)
- `view.prototype` — Prototype panel — `{}` — Alt+9 — (not undoable)
- `view.rulers` — Rulers — `{on?}` — Shift+R — (not undoable)
- `view.set` — Set view — `{zoom?, cx?, cy? (page coordinate at the centre), vw?, vh? (viewport size)}` — (not undoable)
- `view.slices` — Slices — `{on?}` — (not undoable)
- `view.snapGeometry` — Snap to geometry — `{on?}` — (not undoable)
- `view.snapObjects` — Snap to objects — `{on?}` — (not undoable)
- `view.snapPixel` — Snap to pixel grid — `{on?}` — Shift+Cmd+' — (not undoable)
- `view.themeDark` — Dark theme — `{}` — (not undoable)
- `view.themeLight` — Light theme — `{}` — (not undoable)
- `view.themeSystem` — Follow system theme — `{}` — (not undoable)
- `view.toggleUi` — Show/Hide UI — `{on?}` — Cmd+\ — (not undoable)
- `view.zoom100` — Zoom to 100% — `{}` — Shift+0 — (not undoable)
- `view.zoom200` — Zoom to 200% — `{}` — (not undoable)
- `view.zoom50` — Zoom to 50% — `{}` — (not undoable)
- `view.zoomAt` — Zoom tool — `{x, y (page point kept in place), out? (zoom out a step), width?, height? (an area to fit instead)}` — (not undoable)
- `view.zoomFit` — Zoom to fit — `{}` — Shift+1 — (not undoable)
- `view.zoomIn` — Zoom in — `{}` — Cmd+= — (not undoable)
- `view.zoomOut` — Zoom out — `{}` — Cmd+- — (not undoable)
- `view.zoomSelection` — Zoom to selection — `{}` — Shift+2 — (not undoable)

## widget (3)

- `widget.click` — Click widget — `{id (a widget or a layer in one), target (see widget.list), fuel?} calls the widget's plugin back, which redraws it; one undo step → like widget.insert` — (not undoable)
- `widget.insert` — Insert widget — `{plugin (a widget plugin's id), x?, y? (top-left; default: centred in the view), fuel?} the plugin draws it; one undo step → {id, plugin, state, targets, output, logs, calls, fuel}` — (not undoable)
- `widget.list` — List widgets — `{} → {widgets: [{id, plugin, name, page, state, targets}]}` — (not undoable)

## window (2)

- `window.focus` — Bring window to front — `{id}  a window id (control channel `window.list`)` — (not undoable)
- `window.new` — New window — `{path?, index?}  a new window with a new file, the file at `path`, or open file `index` moved into it` — (not undoable)
