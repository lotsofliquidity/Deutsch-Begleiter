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
(the glossary) with unit tags (`a1.1 unit_01`). One chunk = one card. Never card a whole
ladder. Run `python3 anki/split_core.py` after appending so
[`anki/German-core.txt`](anki/German-core.txt) (the deck) picks up any `pattern`/`verb`
cards.

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
| 1 | 2026-09-27 | Verbposition: Zeit / leider zuerst | A1.1 Unit 10 | Left the time or *leider* in the middle, or answered a different sentence. | 2026-10-11 | OPEN |
| 2 | 2026-09-27 | Akkusativ maskulin | A1.1 Unit 9 | Masculine object came out as *dem*, then a bare *Nein* instead of the object form. | 2026-10-11 | OPEN |
| 3 | 2026-09-30 | Imperativ sein/haben (du vs ihr) | A1.2 Unit 3 | *du bist* came out as Hab; *ihr seid* came out as Sei, twice. | 2026-10-14 | OPEN |
| 4 | 2026-09-30 | Imperativ ihr | A1.2 Unit 3 | Several people stayed singular (*Hol*, *Nimm*); the plural ending was left off. | 2026-10-14 | OPEN |
| 5 | 2026-09-30 | mehr + Adjektiv | A1.2 Unit 3 | “More slowly” came out as *mehr langsam*, again. | 2026-10-14 | OPEN |
| 6 | 2026-09-30 | kein vs nicht | A1.2 Unit 3 | No milk, then no beer, both came out with *nicht*. | 2026-10-14 | OPEN |
| 7 | 2026-10-01 | du vs Sie: Rückfrage | A1.1 Unit 3 | The return question stayed nominative, and the taxi *Sie* came out lowercase. | 2026-10-15 | OPEN |
| 8 | 2026-10-01 | mein/Ihr + noun | A1.1 Unit 4 | Formal your came out lowercase, and the key card kept a bare form. | 2026-10-15 | OPEN |
| 9 | 2026-10-01 | hier | A1.1 Unit 3–4 | “Here” kept coming out as the English-looking *Heir*. | 2026-10-15 | OPEN |
| 10 | 2026-10-01 | Was machst du beruflich? | A1.1 Unit 6 | The friend question took *von Beruf*, the formal one took *arbeiten*, and “what do you work as” lost the person. | 2026-10-15 | OPEN |
| 11 | 2026-10-01 | Job ohne Artikel | A1.1 Unit 6 | Job titles took an article, and the engineer one came out as an object form. | 2026-10-15 | OPEN |
| 12 | 2026-10-08 | Demonstrativ: der/die/das · dies- | A1.2 Unit 9 | Twice: *das Kleid* came out as *Der* hier (not *Das/Dieses*), and Dativ Plural came out as *dem* instead of *denen*. | 2026-10-22 | OPEN |
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

## Planned drills

Self-scheduled practice — **not** logged errors. Nothing here has gone wrong yet; these
are topics parked for a specific date because they aren't landing.

Flag any row whose **Due** is today or earlier at session start, same as a due revisit.
Once drilled, delete the row (or move the misses to **Open entries** via the `/drill`
rules).

| Due | Topic | Booklet | Note |
|---|---|---|---|
| 2026-10-10 | Past tense system — Perfekt vs Präteritum | A1.2 U6–U7 | Not landing: two forms, one time level. Drill the three decisions — participle form, auxiliary, placement. Set up 2026-10-06. |

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
