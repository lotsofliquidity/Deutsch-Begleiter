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
- `unit-NN-<slug>.md` — chunks, patterns, ladder
- `practice/` — optional dated logs

---

## Flow

```
courses PDF  →  /ingest  →  unit file + patterns + notes + anki/German.txt
                                ↓
                    /teach (paradigms)  →  more Anki
                                ↓
                           /drill
                                ↓
                    misses (selective) → ../MISTAKES.md
```

---

## Mistakes

Bad drills may get a row in [`../MISTAKES.md`](../MISTAKES.md). Near-misses and
one-off slips usually do not. Cold-retry open entries after 14 days.
