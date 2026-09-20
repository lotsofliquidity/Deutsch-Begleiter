# MISTAKES.md

The German error log for the 9-week plan (14 Sep – 15 Nov 2026).
Started in **W01**, with the first A1.1 unit.

---

## How to use this file

**Add an entry only when something went wrong.** A clean round writes nothing — a round
with ten right answers and one wrong noun is a good round.

Log a row when it is worth a cold revisit (drills are **lenient** — near-misses usually
do not get a row):

- same pattern wrong **twice** in one round
- total blank on a frame you should know
- English escape **and** you still couldn't produce it after one nudge
- clear wrong case / verb form that would stick

**Do not log:** one-off vocab slips, typos counted as close enough, English you recovered
in German on the next beat.

**Do not log the correct form.** Log what *went wrong*. You re-drill the pattern — you
don't read the answer back to yourself.

**One row per pattern or chunk, not per question.** Five wrong `dir` answers is
**one** row. 15–25 rows across the nine weeks is a study tool; 200 is a diary.

**The date is the mechanism.** An entry is not closed until you produce it clean
**14 days later**, cold, in `/drill`, no notes. Soft pass if close enough.

**Cursor will remind you.** At the start of any session, due revisits (Revisit due ≤
today) are listed so you can cold-retry them first. You can also just ask: "What's due?"

**The cold queue feeds Anki.** Real gaps go to [`anki/German.txt`](anki/German.txt)
with unit tags (`a1.1 unit_01`). One chunk = one card. Never card a whole ladder.

---

## What a good entry looks like

```
Date logged  : 2026-09-16
Pattern/Chunk: Hast du X dabei?
Booklet      : A1.1 Unit 1
Went wrong   : Escaped into English — could ask the question, couldn't answer it with a pronoun.
Revisit due  : 2026-09-30
Status       : OPEN
```

```
Date logged  : 2026-09-18
Pattern/Chunk: Wohin + Verb der Bewegung
Booklet      : A1.1 Unit 2
Went wrong   : Reached for `zu` with a city (~~zu Bern~~) — and didn't catch it on the
               second pass either.
Revisit due  : 2026-10-02
Status       : OPEN
```

Note what is **not** in there: the correct form.

---

## Open entries

| # | Date logged | Pattern / Chunk | Booklet | Went wrong | Revisit due | Status |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |

**Status values:** `OPEN` · `PASSED` (produced clean at the revisit) · `RECURRED`
(failed the revisit — set a new `Revisit due` 14 days out, keep the old row)

---

## Closed entries

Move a row here once it's `PASSED`. Keep them — the tally is your progress measure.

| # | Pattern / Chunk | Booklet | First logged | Closed | Notes |
|---|---|---|---|---|---|
| | | | | | |

---

## Before each booklet test

Cold-retry the open rows for that booklet **before** the test. A row that passes gets
closed; a row that fails goes back out 14 days.

| Test | Week | Booklet | Open rows retried | Passed | Failed |
|---|---|---|---|---|---|
| A1.1 | W02 | a1.1 | | | |
| A1.B | W03 | a1-b | | | |
| A2.A | W05 | a2-a | | | |
| A2.B | W06 | a2-b | | | |
| B1.A | W08 | b1-a | | | |
| B1.B | W09 | b1-b | | | |

---

## Cold retries at the start of the course (W01 / W04 / W07)

The plan puts a cold redo at the head of each sprint. Pick your **worst** entries —
anything still `OPEN` or `RECURRED`, favouring the patterns that carry the most weight
(accusative vs dative, `Wohin`/`Wo`, word order with a modal, perfect tense) — and
re-drill them with no notes.

| Sprint | Week | Retried | Outcome |
|---|---|---|---|
| Q3 | W01 | | |
| Q4 | W04 | | |
| Q4 | W07 | | |
