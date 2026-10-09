# Deutsch-Begleiter

Three modes. Use the matching skill.

| Mode | Skill | What it's for |
|---|---|---|
| **Ingest** | `/ingest` | Parse a course unit → unit notes, patterns, rules, Anki cards |
| **Teach** | `/teach` | Paradigms you revisit — articles, cases, conjugation. Table + mini-check |
| **Drill** | `/drill` | Rapid question → answer, one at a time. Lenient. Hints on request. |

Shared: [`course/grammatik.md`](course/grammatik.md) (every rule, one page) ·
[`patterns/patterns.md`](patterns/patterns.md) (the library) · [`MISTAKES.md`](MISTAKES.md) ·
[`anki/German.txt`](anki/German.txt) (glossary) · [`anki/German-core.txt`](anki/German-core.txt) (deck)

**Method:** learn **patterns, not isolated words**. Memorise `Woher kommst du? → Ich komme aus X.`,
not just *aus*. For tables (*mein/dein/Ihr*, verb rows), use `/teach`. For “where is that rule?”,
open [`course/grammatik.md`](course/grammatik.md).

Same slash commands in Cursor and in VS Code Copilot Chat. Open the folder, accept the Copilot
Chat recommendation, then start a chat. Rules live in [`AGENTS.md`](AGENTS.md); the three skills
live in `.agents/skills/`.

---

## Quick start

```
/ingest
Parse unit 3
```

```
/teach
Possessives — der Koffer → mein / dein / Ihr
```

```
/drill
Drill me on A1.2 Unit 9
```

```
/drill
Mixed drill, 15 questions, cold.
```

---

## Status

Both booklets are **complete**: A1.1 units 1–10 and A1.2 units 1–10.

| | |
|---|---|
| Units ingested | 20 |
| Patterns in the library | 114 |
| Rules in `grammatik.md` | every one of them, in 15 sections |
| Glossary cards | ~1650 (`German.txt`) |
| Cards in the deck | ~356 (`German-core.txt`) |

---

## Layout

```
courses/                      # source PDFs + MAP.md per level
  a1.1/                       # A1-1 booklet + LÖSUNGEN + MAP.md
  a1.2/                       # A1-2 booklet + LÖSUNGEN + MAP.md
course/                       # processed notes
  grammatik.md                # EVERY rule, one page — start here
  check_grammatik.py          # proves every pattern is reachable from grammatik.md
  README.md                   # course-mode detail + the checks
  a1.1/                       # notes.md + unit-01…unit-10
  a1.2/                       # notes.md + unit-01…unit-10
                              #   + partizip-ii.md, vergangenheit.md (consolidated refs)
patterns/patterns.md          # cross-unit frames + ladders + traps — the real curriculum
anki/German.txt               # glossary — EVERY card (chunk/noun/pattern/verb/teach)
anki/German-core.txt          # deck — pattern/verb/teach only (generated from German.txt)
MISTAKES.md                   # selective error log (+14 day revisits)
.agents/skills/               # /ingest, /teach, /drill (Cursor and VS Code)
AGENTS.md                     # always-on rules for both editors
```

### Where the rules live

Three layers, each with one job:

| Layer | File | Job |
|---|---|---|
| **Index** | `course/grammatik.md` | find the rule — one line + booklet examples + unit |
| **Library** | `patterns/patterns.md` | the full pattern: frame, instances, ladder, traps |
| **Spine** | `course/a1.1/notes.md` · `course/a1.2/notes.md` | raw tables (articles, pronouns, conjugations) |

`/ingest` writes to all three, + cards. `check_grammatik.py` fails if a pattern never reaches
the index — so “it's carded but explained nowhere” can't happen quietly.

---

## Anki

Two files, two decks, on purpose:

| File | `#deck:` | Anki deck | Role |
|---|---|---|---|
| `anki/German-core.txt` | `German-core` | **German-core** | the SRS deck — 356 cards to review |
| `anki/German.txt` | `German` | **German** | the glossary — all ~1650, parked |

- Import **`German-core.txt`** for normal study. It is the only deck you review.
- Import **`German.txt`** only if you want to filter on the parked cards. They sit inert.
- The `#deck:` header **decides the destination** — Anki ignores the deck you highlight.
- Always pick **“Update existing notes when first field matches”**, never *Duplicate*.
- **Import core first, then the glossary.** The first import of a card decides its home deck;
  a later update never moves it.
- **Never delete the `German-core` deck.** It holds your intervals. Re-importing rebuilds the
  cards but resets them all to New.
- To study a subset, don't build another deck — use **Custom Study** on the deck, or a
  **filtered deck** (`tag:verb`, `tag:noun`). Same cards, one schedule.

Tags look like `a1.2 unit_09 noun` — three separate tags. Scope a unit with both:
`tag:a1.2 tag:unit_05`, because `unit_05` alone matches A1.1 U5 as well.

`anki/German.txt` is the source of truth. Never hand-edit `German-core.txt`; regenerate it.

---

## Checks

```
python3 course/check_grammatik.py   # every pattern reachable from grammatik.md
python3 anki/validate_deck.py       # card shape, deck name, duplicate fronts, answer leaks
python3 anki/split_core.py          # regenerate German-core.txt from German.txt
```

Run them after any change to `patterns/`, `course/`, or `anki/`.

---

See [`course/README.md`](course/README.md) for course-mode detail, and
[`courses/a1.1/MAP.md`](courses/a1.1/MAP.md) / [`courses/a1.2/MAP.md`](courses/a1.2/MAP.md)
for what each unit covers.
