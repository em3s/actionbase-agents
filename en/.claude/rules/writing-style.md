# Writing Style (MANDATORY)

Applies to all prose artifacts — PR/issue bodies, comments, reviews. Goal: **text that reads like a developer wrote it.** Verbosity, mechanical completeness, or artificial structure means failure.

## Openings — Why First

- Open with the problem, incident, or observation that motivated the change (1–3 sentences). What the change does comes second.
- Never open by restating the title ("This PR introduces...")

```
Not all filesystems support `If-Match`. I introduced a dependency on this feature when I added GC boundary files. This PR adds a config to disable it.
```

## Length — Proportional to the Change

- A trivial fix gets one or two plain sentences with no headers: "`main` is failing after #1921"
- Delete sections you have nothing to say in, or write a blunt "None."
- When the content ends, the text ends. No closing summary paragraph

## Sentences

- First person, active voice. Own your actions and judgments (use contractions: it's, don't, I'll)
- Short declarative sentences. Fragments are fine
- State verified facts plainly. Flag only what you actually didn't verify: "I haven't verified this, but ..."
- No decorative hedging — never put "probably" on something you checked
- Trade-offs in prose — one downside sentence plus a revisit condition: "The downside is X. If that becomes a problem, we can revisit."
- Name what you're deliberately not doing and defer it: "I'll leave that for a future PR."

## Formatting

- **No artificial line breaks — one paragraph = one line.** Line breaks only between paragraphs
- Paragraphs run 1–4 sentences
- Bullets are 3–6 terse imperatives ("Add test", "Update bindings"). Never re-enumerate the diff file-by-file. No "**bold-prefixed:**" bullets
- Numbered lists only for sequences/scenarios; tables only when they genuinely compress a comparison
- Paste evidence instead of describing it: logs in fenced blocks, CI runs as bare URLs on their own line, reports as blockquotes with attribution
- Backtick identifiers, config keys, and filenames. Reference issues as `#N`; `Closes #N` / `Fixes #N` on its own line

## Banned

- Marketing adjectives: robust, comprehensive, seamless, powerful, significantly
- Emoji as list decoration
- Empty boilerplate sections kept for form
- AI attribution footers (disclose AI use matter-of-factly in the PR template's AI Assistance section)

## Comment Register

- Short, warm, decisive: "LGTM! Merged", "Nah, this is too much. Closing for now."
- Own mistakes casually and immediately
- Credit AI work plainly: "Sol did this. I reviewed things and it seems quite reasonable."
