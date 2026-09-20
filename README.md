# d3utsch

Three modes. Use the matching skill.

| Mode | Skill | What it's for |
|---|---|---|
| **Ingest** | `/ingest` | Parse a course unit → notes, patterns, Anki cards |
| **Teach** | `/teach` | Paradigms you revisit — possessives, conjugations, articles. Table + mini-check + Anki |
| **Drill** | `/drill` | Rapid question → answer. Lenient. Hints on request. |

Shared: [`patterns/patterns.md`](patterns/patterns.md) · [`MISTAKES.md`](MISTAKES.md) · [`anki/German.txt`](anki/German.txt)

**Method:** learn **patterns, not isolated words**. Memorise `Woher kommst du? → Ich komme aus X.`, not just *aus*. For tables (*mein/dein/Ihr*, verb rows), use `/teach`.

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
Drill me on A1.A Unit 3
```

```
/drill
Mixed drill, 15 questions, cold.
```

---

## Layout

```
courses/                 # source PDFs + MAP.md per level
  a1.1/                  # A1-1 booklet + LÖSUNGEN + MAP.md
course/                  # processed notes (one folder per booklet)
  a1-a/                  # units 1–4 ingested
patterns/patterns.md     # cross-unit frames — the real curriculum
anki/German.txt          # Anki deck "German" (unit- / teach-tagged)
MISTAKES.md              # selective error log (+14 day revisits)
.cursor/skills/
  ingest/                # parse units
  teach/                 # paradigms
  drill/                 # test
```

Anki: import `anki/German.txt`. Tags look like `a1.1 unit_01` or `a1.1 teach possessives`.
Validate with `python3 anki/validate_deck.py`.

See [`courses/a1.1/MAP.md`](courses/a1.1/MAP.md) for the full A1.1 map.
