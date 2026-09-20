---
name: ingest
description: >-
  Parses Happy German course units from courses/ into unit notes, patterns,
  grammar notes, and Anki cards. Use when the user says /ingest, "parse unit",
  "ingest unit", or asks to process a booklet unit. Not for drilling (/drill)
  or paradigm tutoring (/teach).
---

# Ingest

You turn a course unit into **patterns, notes, and Anki cards**. You are not a
freeform tutor and you do not run drills (`/drill`).

## Paths (this repo only)

| Kind | Path |
|---|---|
| Source PDFs | `courses/<level>/` (e.g. `courses/a1.1/`) |
| Curriculum map | `courses/<level>/MAP.md` |
| Unit records | `course/<booklet>/unit-NN-<slug>.md` |
| Grammar spine | `course/<booklet>/notes.md` |
| Pattern library | `patterns/patterns.md` |
| Anki | `anki/German.txt` |
| Mistakes | `MISTAKES.md` |

Booklet map: `a1.1` PDFs → processed under `course/a1.1/`. Never invent German —
check booklet + `_LOESUNGEN` in `courses/`.

## Primary workflow — parse a unit

1. Confirm level + unit (e.g. A1.1 Unit 3). Create folders if needed.
2. Read the unit from the PDF (and LÖSUNGEN when checking forms).
   **Do not skip dialog footnotes / asterisk glosses** (*denn*, *man*, *eigentlich*,
   *ja*, *doch*, register tips). If the booklet flags it, it belongs in chunks/notes —
   not only the big “Grammatik:” headings.
3. Write **`course/<booklet>/unit-NN-<slug>.md`** (kebab slug, no umlauts).
4. Upsert produceable frames into **`patterns/patterns.md`** (Meta: booklet + unit).
5. Distill lookups into **`course/<booklet>/notes.md`** (tight tables only).
6. Append cards to **`anki/German.txt`**:
   - `#deck:German`, three tab-separated fields, tags **`a1.1 unit_NN`** (+ optional `chunk`/`verb`/`pattern`)
   - Frames, survival chunks, **and** flagged particles — not every ladder rung or noun dump
7. Mark the unit ingested on **`courses/<level>/MAP.md`**.
8. Run `python3 anki/validate_deck.py`.
9. In chat: 3–6 sentence summary + offer `/drill` on this unit. Do not dump the library.

**Unit file shape:** chunks table · patterns introduced · drill ladder · what tripped me up.

**Pattern quality bar:** fixed frame + swappable slot · 5–8 rung ladder · register · no invented German.

## Stuck while ingesting

Contrast pair → one-line rule → if still stuck on a **paradigm** (possessives,
conjugation, articles), say so in one line and point to **`/teach`**. Do not start
a drill round. Add traps to `patterns.md` only if it will recur as a frame issue.

## Mistakes

Due revisits: read `MISTAKES.md` Open entries at session start; list if Revisit due ≤ today.
Ingest itself rarely logs; logging is mainly `/drill`.

## Tone

Concise. German first in frames, English gloss second. Future-you, not a PDF dump.
