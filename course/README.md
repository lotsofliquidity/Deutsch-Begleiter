# Course mode

Processed follow-along for Happy German booklets. Source PDFs live in
[`../courses/`](../courses/).

| Skill | Job |
|---|---|
| `/ingest` | Parse a unit → notes, patterns, Anki |
| `/teach` | Grammar paradigms (possessives, conjugations, …) |
| `/drill` | Test under pressure |

---

## Start

```
/ingest
Parse unit 4
```

```
/teach
Possessives with der Koffer / das Zimmer / die Reservierung
```

```
/drill
Drill me on A1.1 Unit 2
```

---

## Layout

```
courses/a1.1/     # PDFs + MAP.md
course/a1.1/      # unit-NN-*.md + notes.md
```

Per booklet folder:

- `notes.md` — grammar spine (tables `/teach` starts from)
- `partizip-ii.md` — consolidated partizip reference (a1.2)
- `vergangenheit.md` — consolidated past-tense overview (a1.2)
- `unit-NN-<slug>.md` — chunks, patterns, ladder
- `practice/` — optional dated logs

Cross-booklet:

- [`grammatik.md`](grammatik.md) — **every rule, one page.** The index of rules learned so far
  (A1.1 U1–U10 · A1.2 U1–U10), grouped by topic, each pointing back into `patterns/`.
  `/ingest` folds every new rule in here; `check_grammatik.py` proves nothing is orphaned.

---

## Checks

```
python3 course/check_grammatik.py   # every pattern in patterns/ reachable from grammatik.md
python3 anki/validate_deck.py       # card shape, deck name, duplicate fronts, answer leaks
python3 anki/split_core.py          # regenerate anki/German-core.txt from the glossary
```

---

## Flow

```
courses PDF  →  /ingest  →  unit file + patterns + notes + anki/German.txt (glossary)
                                ↓                                        ↓
                    /teach (paradigms)  →  more Anki        split_core.py → German-core.txt (deck)
                                ↓
                           /drill
                                ↓
                    misses (selective) → ../MISTAKES.md
```

---

## Mistakes

Bad drills may get a row in [`../MISTAKES.md`](../MISTAKES.md). Near-misses and
one-off slips usually do not. Cold-retry open entries after 14 days.
