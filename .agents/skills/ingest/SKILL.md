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
| **Every rule, one page** | `course/grammatik.md` — the rule index (§1 articles … §14 register, §15 formulas) |
| Consolidated refs | `course/a1.2/partizip-ii.md` · `course/a1.2/vergangenheit.md` |
| Pattern library | `patterns/patterns.md` |
| Anki glossary (ALL cards) | `anki/German.txt` |
| Anki deck (`pattern`/`verb`/`teach` only) | `anki/German-core.txt` — generated, never hand-edit |
| Mistakes | `MISTAKES.md` |

Booklet map: `a1.1` PDFs → processed under `course/a1.1/`. Never invent German —
check booklet + `_LOESUNGEN` in `courses/`.

## Primary workflow — parse a unit

1. Confirm level + unit (e.g. A1.1 Unit 3). Create folders if needed.
2. Read the unit from the PDF **and LÖSUNGEN**.
   **Neue Chunks are mandatory:** each dialog has a **Neue Chunks** exercise
   (almost always **10 lines**). Copy **all of them** from LÖSUNGEN into the unit
   file — do not curate a “best of” subset. Organise by dialog
   (`### Dialog N — <title>`).
   **Phrase boxes are mandatory too:** bilingual teaching panels in the booklet
   (*Nach dem … fragen*, *Sich bedanken*, *Sich verabschieden*, *Bezahlen*,
   *Jemanden vorstellen*, *Wörter im …*, etc.). Pull every **produceable** bullet
   (Q&A pairs, survival replies) into an **Also — …** block under the dialog and
   card them. Skip pure grammar lectures that belong in `notes.md` / `/teach`
   (conjugation tables, article theory) — but keep their example sentences if
   they’re sayable frames.
   **Also** keep dialog footnotes / asterisk glosses (*denn*, *man*, *eigentlich*,
   *ja*, *doch*, register tips). If the booklet flags it, it belongs in chunks/notes —
   not only the big “Grammatik:” headings.
   **Irregular verbs are study items:** record every irregular form taught or used in
   the unit in `notes.md` as `infinitive → Partizip II` (including irregular `-t`
   participles and irregular separable verbs), and add an individual production card
   for each form to `German.txt`. Do not leave them only embedded in dialog chunks.
3. Write **`course/<booklet>/unit-NN-<slug>.md`** (kebab slug, no umlauts).
4. Upsert produceable frames into **`patterns/patterns.md`** (Meta: booklet + unit).
5. Distill lookups into **`course/<booklet>/notes.md`** (tight tables only).
6. Fold the unit's **rules** into **`course/grammatik.md`** — the one-page rule index.
   This file is the answer to “where are the rules?”. Every rule the unit introduces or
   extends gets an entry in the right numbered section (§1 articles … §14 register),
   in the house shape:

   ```
   - **Rule name** *(U7)* — one short statement.
     - *Booklet example.*
     - *Booklet example.*
     - Trap: ~~wrong~~ → *right*.
   ```

   - **One rule per bullet.** Examples are indented sub-bullets, **one example per line** —
     never a wall of prose. Blank line between rules. Nothing over ~160 characters on a line.
     This file is read, not parsed.
   - **Examples must be booklet-attested** — copy from the unit file, the LÖSUNGEN, or the
     pattern’s `Instances`. Never invent German to fill a slot.
   - Add the new sections to that section’s `Deeper:` list: `*Deeper:*` on its own line, then
     one `- [label](../patterns/patterns.md#anchor)` per line.
   - A pattern that is really a **formula** (greetings, restaurant lines, small talk) goes in
     **§15** instead — there is no rule to state.
   - The other consolidated refs move when the unit touches them: `partizip-ii.md` for any new
     participle form, `vergangenheit.md` for the past-tense system.
   - **A rule living only in a card, or only as debris inside someone else’s section, is not
     done.** That is the failure this step exists to prevent.
   - **Check before finishing:** `python3 course/check_grammatik.py` — exit 0 means every
     `## <pattern>` heading in `patterns.md` is reachable from `grammatik.md` (a rule in
     §1–§14, a link in §15, or a `Deeper:` entry). Fix the gaps it lists; do not loosen it.
7. Append **every** card to **`anki/German.txt`** (the glossary) — `chunk` and `noun`
   included; `split_core.py` promotes only `pattern`/`verb`/`teach` to the deck:
   - `#deck:German`, three tab-separated fields, tags **`a1.1 unit_NN`** (+ optional `chunk`/`verb`/`pattern`/`noun`)
   - **Direction = production:** cue/English/situation on the **front**, German on the **back** (for survival chunks, nouns, and frames you must say). Disambiguate register/sense on the front in **English only** (*informal* / *formal* / *pointing* / *farther* / *curious / softened*) — never put the German answer in the cue (`~~(da drüben)~~`, `~~(with denn)~~`, `~~(hätten gern)~~`).
   - **Atomic cards (hard):** one job per card.
     - `chunk` back = German **only** (no particle asides, no “don't drop X”, no conjugation tips).
     - `chunk` front = English cue; parentheses = English sense/register only (validator flags answer leaks).
     - `pattern` = one grammar question → one short rule (particles, traps, frames).
     - `verb` = forms only; `noun` = `article + sg · article + pl`.
     - Irregular participle `verb` cards: English cue with the infinitive on the front; Partizip II only on the back.
     - Two acceptable replies → two cards, not `A / B` on one back.
     - Register / disambiguation on the **front**, never as a mini-lesson on the back.
   - **Card the frame, not the dialog line.** Unit file keeps all 10 Neue Chunks
     verbatim; Anki gets the reusable bit only (`Wo kann ich … kaufen?`, not
     *Und wo kann ich das Ticket kaufen?*). Skip comedy, names, and long glue.
     Prefer a slot frame (`Ich komme aus X.`) over a filled example
     (`… aus Australien`) when the slot is the point. Mid-phrase slots
     (German before **and** after) use `X`: `Ich steige am X ein.` ·
     `Wie viele X hätten Sie gerne?` End slots also use `X`: `Danke für X.`
     One job per card — split stacked clauses (*einsteigen* ≠ *bis zum …*).
   - **Every phrase-box bullet worth saying → one card.** Also card frames, flagged particles, and high-value traps.
   - **Unit noun lists → one card per noun**: English (or bare lemma) on front; back = `der/die/das X · die Y` (sg + pl together). Uncountables: note “no plural”.
   - Still skip full drill ladders and random dialog nouns not on the unit list
8. Mark the unit ingested on **`courses/<level>/MAP.md`**.
9. Run the three checks, in this order:
   `python3 course/check_grammatik.py` (every pattern reachable from `grammatik.md`) →
   `python3 anki/validate_deck.py` → `python3 anki/split_core.py`
   (regenerates `anki/German-core.txt` — the reviewable deck — from the glossary).
10. In chat: 3–6 sentence summary + offer `/drill` on this unit. Do not dump the library.

**Unit file shape:** Neue Chunks by dialog (complete) · Also — phrase boxes · patterns introduced · drill ladder · what tripped me up.

**Pattern quality bar:** fixed frame + swappable slot · 5–8 rung ladder · register · no invented German.

## Stuck while ingesting

Contrast pair → one-line rule → if still stuck on a **paradigm** (possessives,
conjugation, articles), say so in one line and point to **`/teach`**. Do not start
a drill round. Add traps to `patterns.md` only if it will recur as a frame issue.

## Mistakes

Due revisits: read `MISTAKES.md` Open entries and Planned drills at session start; list if
Revisit due / Due ≤ today.
Ingest itself rarely logs; logging is mainly `/drill`.

## Tone

Concise. German first in frames, English gloss second. Future-you, not a PDF dump.
