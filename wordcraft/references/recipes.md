# WordCraft recipes

All snippets use the MCP tools. Pick the server first:

```js
const wc = tools.wordcraft;                 // headless
// const wc = tools["wordcraft-app"];       // live window
```

Every recipe ends with verification. Adjust paths — do not overwrite an original
unless that is the explicit goal.

## 1. Formatted report from scratch

Verified end-to-end in the live window (title, subtitle, heading, bullets, table,
comment, page number, DOCX + PDF).

```js
const wc = tools["wordcraft-app"];
const run = (command, params) => wc.execute({command, params});

await wc.new_document({template:"blank"});
await wc.type_text({text:"WordCraft Report"});
await wc.select_text({text:"WordCraft Report"});
await run("para.style", {style:"Title"});
await run("caret.docEnd");
await run("text.newParagraph");

await wc.type_text({text:"Prepared by OpenCode"});
await wc.select_text({text:"Prepared by OpenCode"});
await run("para.style", {style:"Subtitle"});
await run("caret.docEnd");
await run("text.newParagraph");

await wc.type_text({text:"Findings"});
await wc.select_text({text:"Findings"});
await run("para.style", {style:"Heading 1"});
await run("caret.docEnd");
await run("text.newParagraph");

await wc.type_text({text:"Everything is driven by command ids"});
await run("para.bullets", {kind:"bullet"});
await run("text.newParagraph");
await wc.type_text({text:"Table cells accept text and Tab"});
await run("text.newParagraph");
await wc.type_text({text:"DOCX and PDF export in one run"});
await run("text.newParagraph");
await run("para.bullets", {off:true});

await wc.type_text({text:"Data"});
await wc.select_text({text:"Data"});
await run("para.style", {style:"Heading 1"});
await run("caret.docEnd");

await run("insert.table", {rows:3, cols:3});
const cells = ["Item","Status","Note","Typing","OK","MCP","Export","OK","PDF + DOCX"];
for (let i = 0; i < cells.length; i++) {
  await wc.type_text({text:cells[i]});
  if (i < cells.length - 1) await wc.key({key:"Tab"});
}
for (const h of ["Item","Status","Note"]) {
  await wc.select_text({text:h});
  await run("format.bold");
}

await wc.select_text({text:"Findings"});
await run("review.newComment", {text:"Reviewed by OpenCode over MCP."});

await run("insert.pageNumber", {position:"bottom", align:"center", format:"x of y"});
await wc.save_document({path:"/tmp/report.docx"});
await wc.save_document({path:"/tmp/report.pdf"});

const check = await wc.inspect_document();
if (!check.blocks?.some(b => b.type === "table")) throw new Error("table missing");
```

Note: `select_text` leaves a selection; `caret.docEnd` collapses it before the
next insert. Do not Tab after the last table cell (it adds a row).

## 2. Edit an existing document without touching the original

```js
const wc = tools.wordcraft;

await wc.open_document({path:"/work/in.docx"});
await wc.execute({command:"edit.replaceAll",
  params:{text:"ACME Corp", with:"Acme Corporation", matchCase:true}});
await wc.execute({command:"edit.replaceAll",
  params:{text:"2024", with:"2025"}});

const {text} = await wc.get_text();
if (text.includes("ACME Corp")) throw new Error("replace missed");

await wc.save_document({path:"/work/out.docx"});   // original untouched
```

For regex: `edit.replaceAll {text, with, regex:true, matchCase?}`.
For a single replacement: `edit.replace` with the same options.
`edit.find` + `edit.findNext` only move the selection.

## 3. Tracked edits and comments as an agent

```js
const wc = tools.wordcraft;
await wc.open_document({path:"/work/contract.docx"});
await wc.execute({command:"file.setAuthor", params:{name:"OpenCode (legal review)"}});
await wc.execute({command:"review.trackChanges", params:{value:true}});

await wc.select_text({text:"thirty (30) days"});
await wc.type_text({text:"sixty (60) days"});      // recorded as an insertion

await wc.select_text({text:"sixty (60) days"});
await wc.execute({command:"review.newComment",
  params:{text:"Check this term with counsel."}});

await wc.save_document({path:"/work/contract-reviewed.docx"});
```

To accept everything before delivering:

```js
await wc.execute({command:"review.acceptAll"});
await wc.save_document({path:"/work/contract-clean.docx"});
```

## 4. Fill a table from an array

```js
await wc.execute({command:"insert.table", params:{rows:rows+1, cols:cols}});
let first = true;
for (let r = 0; r < rows + 1; r++) {
  for (let c = 0; c < cols; c++) {
    if (!first) await wc.key({key:"Tab"});
    first = false;
    await wc.type_text({text:String(data[r][c])});
  }
}
```

The caret starts in the first cell after `insert.table`. Use `key` only with the
app bridge; headless sessions have no UI keyboard, so precompute text paragraphs
or use `text.insert` with `\t`/`\n` and `table.fromText` instead.

Headless alternative — convert tab-separated text to a table:

```js
await wc.type_text({text:"A\tB\n1\t2", paragraphs:false});
await wc.execute({command:"select.all"});
await wc.execute({command:"table.fromText", params:{separator:"tab"}});
```

## 5. Mail merge from CSV

```js
const wc = tools.wordcraft;
await wc.new_document({template:"blank"});
await wc.type_text({text:"Dear "});
await wc.execute({command:"mailings.start", params:{kind:"letters"}});
await wc.execute({command:"mailings.recipients", params:{path:"/work/contacts.csv"}});
await wc.execute({command:"mailings.insertField", params:{field:"FirstName"}});
await wc.type_text({text:",\n\n"});
await wc.type_text({text:"…body…"});
await wc.execute({command:"mailings.preview"});
await wc.execute({command:"mailings.finish", params:{path:"/work/merged.docx"}});
```

`mailings.recipients` accepts CSV/TSV/TXT and XLSX/XLSM/XLS/ODS. For a workbook
with several sheets, omit `sheet` to get `{sheets:[…], chooseSheet:true}`.
`mailings.filterRecipients` and `sortRecipients` take rule/sort arrays.
`mailings.finish` can take `from`/`to` for a subset.

## 6. Table of contents, footnotes, captions

```js
// Assumes headings already use Heading 1/2 styles.
await wc.execute({command:"caret.docStart"});
await wc.execute({command:"references.toc",
  params:{levels:3, pageNumbers:true, rightAlign:true, tabLeader:"dot",
          hyperlinks:true, title:"Contents"}});

// Insert the note at a collapsed caret: a selection is replaced by the reference.
await wc.select_text({text:"Body text for the first chapter."});
await wc.execute({command:"select.collapse"});
await wc.execute({command:"references.footnote",
  params:{text:"Source: internal analysis, 2026."}});

// The caret is now in the footnote story. Return to the body explicitly:
// select_text/get_text only see the active story.
const insp = await wc.inspect_document();
const last = insp.blocks.reduce((a, b) => (b.index > a.index ? b : a), insp.blocks[0]);
await wc.execute({command:"caret.set",
  params:{pos:{story:"body", path:[last.index], off:last.len}}});
await wc.execute({command:"text.newParagraph"});

// Caption in the body (numbering resolves once the caption is in the body story).
await wc.execute({command:"references.caption",
  params:{label:"Figure", text:"Revenue by quarter", position:"below"}});
```

Update fields before exporting:

```sh
wordcraft-cli convert report.docx report.pdf --update-fields
```

Verified in 0.9.0: TOC entries and page numbers, footnote part, and
`Figure 1: …` caption all rendered. Without `select.collapse`, the footnote
reference replaces the selected sentence; without `caret.set`, later text (and
captions) land in the footnote story.

## 7. Convert and export a bundle

```sh
wordcraft-cli convert in.docx out.pdf --update-fields
wordcraft-cli convert in.docx out.md
wordcraft-cli convert in.docx out.html
wordcraft-cli convert in.docx out.odt
wordcraft-cli convert in.docx out.tex
wordcraft-cli render in.docx page1.png --page 1 --scale 2
```

Batch directory (bash):

```sh
for f in /work/in/*.docx; do
  base=$(basename "$f" .docx)
  wordcraft-cli convert "$f" "/work/out/$base.pdf" --update-fields
done
```

`--markup` keeps comments/tracked changes visible in PDF/PNG/HTML/MD/TXT.

## 8. Drive the GUI

```js
const app = tools["wordcraft-app"];
const ui = await app.ui_inspect();
// ui.pages = [[x0,y0,x1,y1]] in window pixels
const [x0,y0,x1,y1] = ui.pages[0];
await app.click({x:(x0+x1)/2, y:(y0+y1)/2});   // click page centre
await app.key({key:"Escape"});
const shot = await app.screenshot();            // image content
```

Notes:
- `click` uses window pixels; page rectangles from `ui_inspect` are window pixels.
  Click on actual text — a click in blank page area is ignored (observed 0.9.0).
- `ui.clickText` (control protocol) uses page points and a 0-based page.
- `key`/`text` are queued; inspect before depending on the result.
- Screenshot returns base64 image content through MCP; the raw control method
  `ui.screenshot {path}` writes a file directly.

## 9. Macro: define and replay

```js
await wc.execute({command:"tools.macros", params:{define:{
  name:"SignOff",
  steps:[
    {command:"caret.docEnd"},
    {command:"text.newParagraph"},
    {command:"text.insert", params:{text:"Approved."}},
    {command:"format.bold"}
  ]}}});
await wc.execute({command:"tools.macros", params:{run:"SignOff"}});
await wc.execute({command:"tools.macros", params:{}});        // list
```

Recording an interactive sequence:

```js
await wc.execute({command:"tools.recordMacro", params:{name:"MyMacro"}});
// …run commands…
await wc.execute({command:"tools.recordMacro"});              // stop
```

## 10. CLI job file for repeatable builds

```json
{"file":"/work/source.docx",
 "commands":[
   {"command":"edit.replaceAll","params":{"text":"DRAFT","with":"FINAL"}},
   {"command":"references.updateFields","params":{"all":true}}
 ],
 "save":["/work/out.docx","/work/out.pdf","/work/out.md"]}
```

```sh
wordcraft-cli run --script build.json --author "OpenCode"
```

A failure saves nothing, so a partially built bundle cannot slip through.

## 11. Verification loop

```js
const {text} = await wc.get_text();
const insp = await wc.inspect_document();
const page = await wc.render_page({page:1, scale:1});
```

- Text length/words: `insp.words`, `insp.pages`.
- Tables: `insp.blocks.filter(b => b.type === "table")`.
- Comments: `insp.comments`.
- Styles/runs: inspect block styles and runs.
- Visual: render page or screenshot the app.

For a saved file, double-check independently:

```sh
wordcraft-cli info out.docx
wordcraft-cli text out.docx | head
```

## 12. College paper: cover, sectioned numbering, TOC, citation

Verified live on 0.9.0 (A4). Produces a four-page paper: an unnumbered
title page, an abstract, a TOC, and body text with a table, footnote, citation
and bibliography.

### Title page and section break

Do **not** use `insert.coverPage` when the cover must be exactly one page. In
0.9.0 it emitted 27 paragraphs and spilled across two pages, then left a blank
page. Build it manually:

```js
const run = (command, params) => wc.execute(params ? {command, params} : {command});
const type = (text) => wc.type_text({text});

await wc.new_document({template:"blank"});
await run("layout.size", {name:"A4"});
await run("layout.margins", {top:72, bottom:72, left:72, right:72});

// Type the title page as Normal first; style it afterwards.
await type("The Effects of Sleep on Academic Performance"); await run("text.newParagraph");
await type("A College Research Paper");                      await run("text.newParagraph");
await type("Alex Student");                                  await run("text.newParagraph");
await type("ENG 101 · Professor Doe · October 21, 2026");

await wc.select_text({text:"The Effects of Sleep on Academic Performance"});
await run("para.style", {style:"Title"});
await wc.select_text({text:"A College Research Paper"});
await run("para.style", {style:"Subtitle"});
for (const line of ["The Effects of Sleep on Academic Performance",
                    "A College Research Paper", "Alex Student",
                    "ENG 101 · Professor Doe · October 21, 2026"]) {
  await wc.select_text({text:line});
  await run("para.alignCenter");
}
await run("caret.docEnd");
await run("layout.break", {kind:"nextPage"}); // section 2 starts on page 2
```

Verify `sections.length === 2` and `pages === 2` before continuing.

### Number the body from 1

```js
await run("layout.pageNumberFormat", {start:1}); // current (body) section only
await run("insert.pageNumber", {position:"bottom", align:"center", format:"x of y"});
await run("insert.header", {text:"Sleep and Academic Performance"});
await run("para.alignRight");
await run("insert.closeHeader");
```

The cover section has no footer, so page 1 stays unnumbered. `insert.header`
and `insert.pageNumber` act on the section containing the caret.

**Total-page caveat:** `format:"x of y"` uses `NUMPAGES`, which counts the
cover. A three-page body then prints `Page 1 of 4`. If the total must exclude
the cover, use page-only numbering, or replace `NUMPAGES` with a
`SECTIONPAGES` field.

### Body, headings, TOC

Type headings as **Normal**, then apply `Heading 1` after the text exists:

```js
await run("caret.docEnd");
await type("Abstract"); await run("text.newParagraph");
await type("This paper examines …"); await run("text.pageBreak");

await type("TOC_PLACEHOLDER"); await run("text.newParagraph");
await run("text.pageBreak");

for (const h of ["Introduction", "Methods", "Results", "Discussion"]) {
  await type(h); await run("text.newParagraph");
  await type("Body text for " + h + "."); await run("text.newParagraph");
}

// Style after typing: a new paragraph after a styled heading inherits that style.
for (const h of ["Abstract", "Introduction", "Methods", "Results", "Discussion"]) {
  await wc.select_text({text:h});
  await run("para.style", {style:"Heading 1"});
}

// Center alignment inherits too. Reset the body after the centered title page.
const insp = await wc.inspect_document();
const firstBody = insp.blocks.find(b => b.text === "Abstract");
const lastBody = insp.blocks.reduce((a, b) => (b.index > a.index ? b : a), insp.blocks[0]);
await run("select.range", {anchor:{story:"body", path:[firstBody.index], off:0},
  focus:{story:"body", path:[lastBody.index], off:lastBody.len}});
await run("para.alignLeft");
```

`insp` here is a fresh `inspect_document()` taken after the body text exists. This
also keeps TOC entries left-aligned; their right tab still places page numbers.

Insert the TOC last, replacing the placeholder:

```js
await wc.select_text({text:"TOC_PLACEHOLDER"});
await run("references.toc", {levels:2, title:"Contents", pageNumbers:true,
  rightAlign:true, tabLeader:"dot", hyperlinks:true});
await run("references.updateFields", {all:true});
```

`references.toc` replaces the selected placeholder. `updateFields` fills the
entries and page numbers; a PDF export with `--update-fields` does the same.

### Table, citation, bibliography

```js
// Put the caret at the end of the Results paragraph, then:
await run("insert.table", {rows:4, cols:3});
// Fill row-major with type_text + key Tab; leave the last cell without Tab.
await run("references.caption", {label:"Table",
  text:"Average sleep duration and GPA by group", position:"above"});

await run("references.citationStyle", {style:"APA"});
await run("references.citation", {
  tag:"walker2024",
  source:{tag:"walker2024", kind:"article", author:"Walker, Matthew",
    title:"Sleep and academic performance", year:"2024",
    journal:"Journal of Student Success", volume:"12", issue:"3",
    pages:"45-60"},
  pages:"45-47"
});
await run("text.newParagraph");
await run("references.bibliography", {title:"References"});
```

- `Source` fields are `{tag, kind, author, title, year, publisher, city,
  journal, volume, issue, pages, url, editor, edition, month, day, accessed,
  doi}`; `kind` is `book`, `article`, `website`, `report`, etc.
- The citation lands at the caret with no leading space — type a space first.
- `references.bibliography` inserts its own heading and entries.

### Verify

```sh
wordcraft-cli convert college-paper.docx college-paper.pdf --update-fields
pdfinfo college-paper.pdf | grep -E '^Pages|^Page size'
for p in 1 2 3 4; do pdftotext -f $p -l $p -layout college-paper.pdf - |
  grep -Eo 'Page [0-9]+ of [0-9]+' || echo "page $p: no number"; done
```

Check: cover has no footer; body pages count from 1; TOC entries match the
heading pages; table caption is `Table 1`; footnote text is in the note part;
citation and bibliography are present.

## 13. Objects, stories and layout traps (0.9.0)

These were all observed live; verify visually because several commands return
success while the document is wrong.

### Inserted objects stay selected

`insert.chart`, `insert.smartArt` and `insert.wordArt` leave the new object
selected. A following `text.newParagraph` or `type_text` replaces the object:

```js
await run("insert.chart", {type:"column",
  data:{categories:["A","B"], series:[{name:"Value", values:[3,5]}]},
  title:"Chart", legend:"bottom"});
await run("caret.docEnd");        // required: collapse the object selection
await run("text.newParagraph");
await type("After the chart");
```

Without `caret.docEnd`, the chart disappeared and the paragraph was empty.
`caret.docEnd` preserved it. SmartArt behaves the same way. WordArt's default
style works; `style:"style1"` is rejected as an unknown style.

### A text box changes the active story

`insert.textBox` leaves the caret inside the box. Later `insert.shape`,
`insert.equation`, `insert.link` and `insert.bookmark` then land in the box, and
a body cross-reference cannot find the bookmark. Return to the body first:

```js
await run("insert.textBox", {text:"Callout", width:200, height:80});
await run("caret.set", {pos:{story:"body", path:[bodyBlock], off:0}});
```

### Different odd/even headers are not separated

`layout.differentOddEven` followed by `insert.createHeader {page:1}` or
`insert.createFooter {page:1}` appended the text to the **default** header/footer
and left the `even` slot `null`. Every page showed the combined header/footer.
Verify the exported PDF before relying on odd/even headers; a single shared
header is the reliable fallback.

### Table split after a merge can add cells

`table.merge` on a selected row works, but `table.split {columns:4, rows:1}` on
the merged row produced seven cells (the merged text plus six empties) instead
of four. Check `cells` after splitting and repair/delete the extras.

### Body page fields fill on export

`insert.pageField` and `insert.field {instr:"SECTIONPAGES"}` can show an empty
result in the body after `references.updateFields {all:true}`. PDF export with
`--update-fields` filled them. `SECTIONPAGES` is useful for a body-only total
when the cover is a separate unnumbered section:

```js
await type("Page "); await run("insert.pageField");
await type(" of ");  await run("insert.field", {instr:"SECTIONPAGES"});
```

### Verified layouts

Landscape A4, `layout.margins {preset:"narrow"}`, two columns with a separator,
a double page border, a diagonal watermark and a page color all rendered
correctly in one document. Page backgrounds are document-wide; use a separate
document or remove them when a clean print copy is needed.

## 14. Protection, labels, sections and wrapping

### Read-only protection

```js
await run("file.protect", {mode:"readOnly"});
// text.insert now fails: "not available: text.insert: the document is protected (read only)"
await run("file.protect", {mode:"none"});   // unlocks; protection is null again
```

Save a copy before testing protection, and unlock explicitly at the end.

### Labels and envelopes

```js
await run("mailings.start", {kind:"labels"});
await run("mailings.recipients", {path:"/work/recipients.csv"});
await run("mailings.labels", {product:"a4-3x7", fromRecipients:true});
// filled 3 of 21 labels in the test; the generated block used Address/City/
// State/ZIP, not the Name column. Add a Name field manually when needed.

await run("mailings.start", {kind:"envelopes"});
await run("mailings.recipients", {path:"/work/recipients.csv"});
await run("mailings.envelopes", {delivery:"Ada Lovelace\n12 Analytical Way\nLondon",
  return:"Alex Student\nENG 101", size:"Envelope #10"});
// #10 page: 684×297 pt; return and delivery blocks are separate paragraphs.
```

### Continuous sections and columns

```js
await run("layout.break", {kind:"continuous"});
await run("layout.columns", {count:2, space:24, separator:true, apply:"section"});
```

The resulting two sections had `start:"continuous"` and section 2 had two
columns; section 1 stayed single-column.

### Table formula and nested table

```js
await run("table.formula", {formula:"=SUM(ABOVE)"}); // returned result "30"
```

A nested `insert.table` inside a cell returned a cell path but disrupted the
outer table's header layout in the app. `inspect_document` exposes only the
outer table; verify nested tables visually.

### Floating image wrap

```js
await run("insert.picture", {path:"/work/photo.png", width:160, alt:"Photo"});
await run("arrange.wrap", {wrap:"square"});
await run("arrange.wrapText", {side:"right"}); // text sits to the right
```

The image floated and the paragraph wrapped beside it; verify with a screenshot.

### PDF markup with comments

```sh
wordcraft-cli convert review.docx review-markup.pdf --markup
pdftotext -layout review-markup.pdf -
```

Comments, authors and replies appeared in the PDF text layer; the harmless
`Syntax Error: Suspects object is wrong type (boolean)` from PDF export remains.
