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
| 3 | 2026-09-30 | Imperativ sein/haben (du vs ihr) | A1.2 Unit 3 | *du bist* came out as Hab; *ihr seid* came out as Sei, twice. **Revisit 2026-10-24: NOT clean.** *Be on time* → *Zieg mal*; *Don't be afraid* → *Sei Angst* (*sein* for *haben*). *Seid pünktlich* held. | 2026-11-07 | RECURRED |
| 4 | 2026-09-30 | Imperativ ihr | A1.2 Unit 3 | Several people stayed singular (*Hol*, *Nimm*); the plural ending was left off. **Revisit 2026-10-24: NOT clean.** *Go get the carrots* (several) → *Hol die Karotten* — still singular. | 2026-11-07 | RECURRED |
| 7 | 2026-10-01 | du vs Sie: Rückfrage | A1.1 Unit 3 | The return question stayed nominative, and the taxi *Sie* came out lowercase. **Revisit 2026-10-24: NOT clean.** *Wie heißen Sie?* → *und Ihnen?* (dative where nominative *Sie* is needed). | 2026-11-07 | RECURRED |
| 8 | 2026-10-01 | mein/Ihr + noun | A1.1 Unit 4 | Formal your came out lowercase, and the key card kept a bare form. **Revisit 2026-10-24: NOT clean.** Formal key-card cue → informal *deine* instead of *Ihre*. | 2026-11-07 | RECURRED |
| 12 | 2026-10-08 | Demonstrativ: der/die/das · dies- | A1.2 Unit 9 | Twice: *das Kleid* came out as *Der* hier (not *Das/Dieses*), and Dativ Plural came out as *dem* instead of *denen*. **Revisit 2026-10-24: NOT clean.** *Das hier* held; *mit denen* failed cold (*Mit die weiß Schuhen* / later *mit dem*). Recovered after §1 detour. | 2026-11-07 | RECURRED |
| 14 | 2026-10-10 | Dativ Plural: mit + den | A1.2 Unit 9 | Twice: *mit* + plural came out as *der*, then *dem* — never reached the plural dative form. **Revisit 2026-10-24: NOT clean.** Twice *die* after *mit* (*Mit die…* · *mit die Kindern*). §1 detour mid-round; mini-check then clean. | 2026-11-07 | RECURRED |
| 15 | 2026-10-10 | für / es gibt + Akkusativ | A1.2 U1/U8 | Both accusative triggers came out dative — *für* was called dative, and *es gibt* produced a dative-form article. **Revisit 2026-10-24: NOT clean.** *für meinem Bruder*; *Ist da einen Tisch?* (mixed frame + case). | 2026-11-07 | RECURRED |
| 16 | 2026-10-10 | wer / wen / wem — Fragewort nach Fall | A1.2 Unit 2 | Three times the wrong question word: the object form for a subject, the thing word for a person, and *wen* where the verb takes the dative. **Revisit 2026-10-24: NOT clean.** *Wer ist das?* held; object → *Wer kenne ich?*; dative → *Wer wort Katie an?* | 2026-11-07 | RECURRED |
| 17 | 2026-10-11 | Perfekt: same-stem partners | A1.2 Unit 7 | Gave *bin* for *schlafen* and *stehen* — assumed a shared stem means the same auxiliary as *einschlafen* / *aufstehen*. **Revisit 2026-10-24 (early): NOT clean.** *schlafen*/*aufstehen* held (*habe geschlafen* · *ist aufgestanden*); *einschlafen* → *hat … geschlafen*; *stehen* → *ist … standen*. | 2026-11-07 | RECURRED |
| 21 | 2026-10-24 | vor + Zeit → Perfekt | A2.1 U6/U9 | Twice: *vor*-builds stayed in the present (*Katie auschaltet…* · *Pietro macht… vor drei Monaten*) instead of Perfekt. Time-phrase dative often held (*vor einer Stunde* · *vor drei Monaten*). **Same-day mini 2026-10-24:** tense clean on 5/5 (*hat … ausgeschaltet/angerufen/gekauft/gemacht*). Soft slips only (*Jahr/Jahre*, spelling). Keep for cold revisit 11-07. | 2026-11-07 | OPEN |
| 22 | 2026-10-24 | Perfekt mit sein — Bewegung / Zustandsänderung | A1.2 U6–U7 | Twice in the past-tense cold: *aufstehen* → *hat … aufgestehen*; *gehen* → *habe den Keller gegangen* (wanted *ist … aufgestanden* · *bin in den Keller gegangen*). *schlafen* with *haben* held. | 2026-11-07 | OPEN |
| 23 | 2026-10-24 | gehen + Infinitiv — order of the pair | A2.1 U4 | Twice+: activity after *gehen* (*Sollen wir gehen essen?* · *Willst du gehen einkaufen* · *Wir war gestern gehen essen*). Wanted *essen gehen* / *einkaufen gehen* / *sind … essen gegangen*. Simple *Wir gehen einkaufen* and the *arbeiten gehen* stacks held. **Mastery pass 2026-10-24:** present/*gern* improved; Perfekt stack still fails (*gehe … gearbeitet* · *war … essen* · *sind eingekauft* · *gehen … geschlafen*). **Mix redrill same day:** Perfekt stacks clean (*schlafen/einkaufen/wandern gegangen* · *dass … bin*); slips = wrong tense for the cue (*sind* when present wanted · *bin…gegangen* when *will* wanted) and *Sie sind gehen spazieren*. | 2026-11-07 | OPEN |
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
| 2026-10-25 | Verb ↔ Nomen — both directions | A2.1 U9 | Landing hard (2026-10-22): noun from verb and verb from noun. Cold pairs both ways — *telefonieren ↔ das Telefonat* · *reparieren ↔ die Reparatur* · *anrufen ↔ der Anruf* · *stören ↔ die Störung* · *funktionieren ↔ die Funktion* · *sprechen ↔ das Gespräch* · *helfen ↔ die Hilfe* · *lösen ↔ die Lösung* · *verbinden ↔ die Verbindung* · *bedienen ↔ die Bedienung*. Then a few *-ung* from U6 (*anmelden → die Anmeldung* · *einladen → die Einladung*). Trap: ~~der Telefon~~ · inventing twins for *Router / Steckdose*. Set up 2026-10-22. |
| 2026-10-26 | Connectors + question words — family drill | A2.1 U4–U8 | Wishlist taste 2026-10-24: *Welch-* · *beim* held; *Gibt es* order soft; *deshalb/dann/weil/wenn* word order not automatic; *Wann?* came out *Wenn?*. Deepen: *deshalb/dann* = verb 2nd · *weil/wenn* = verb last · *Wann?* ≠ *wenn*. Also *es gibt* · *Welch-* · *denn*. Set up 2026-10-24. |
| 2026-10-17 | Consolidation weekend — backcards + the whole due drill queue | A1.1 · A1.2 · A2.1 | **Mostly done (2026-10-24).** Rows 1–2 + 18–20 closed early; row 17 recurred (*einschlafen*/*stehen* aux). Still optional: dative pronouns · Verb↔Nomen (10-25). Set up 2026-10-15. |
| 2026-10-23 | Personalpronomen im Dativ — fill-in | A2.1 U5 · U8 | Parked for later (2026-10-21): do the booklet fill-in cold — *Ergänze das Personalpronomen im Dativ*. Grid first (*ich → mir · du → dir · er → ihm · sie → ihr · es → ihm · wir → uns · ihr → euch · sie → ihnen · Sie → Ihnen*), then the U5 prompts. **Also U8** (*zu* + Adj): *Der Film ist mir zu traurig.* · *Der Kaffee ist uns zu schwach.* · *Das Auto ist mir zu langsam.* · *Die Pizza ist mir zu groß.* · *Das Buch ist ihnen zu kompliziert.* · *Dramen sind ihm zu langweilig.* Nom/Dat when ready: *Wer ist heiß? → Ich bin heiß.* vs *Wem ist heiß? → Mir ist heiß.* Mixed: *Schmeckt dir der Kaffee?* · *Das Auto gehört ihm.* · *Ich helfe ihm.* · *Ich gratuliere Ihnen.* Originally set up 2026-10-16; was due 2026-10-19. |
| 2026-10-26 | Wechselpräpositionen — *Wohin?* vs *Wo?* · *in / zu / bei / aus / von* | A2.1 U1 · U6 | Confusing as a system: the case call isn't landing, and the place-vs-person grid needs a full pass (2026-10-19). Drill the decision first — *Wohin?* → Akkusativ, *Wo?* → Dativ — then the park pair: *Wir können aber in den Park gehen.* vs *Was willst du denn im Park?* Then the grid: building *in* (into / inside) and *aus* (out of); person or activity *zu* (towards), *bei* (at), *von* (from). *vom* = *von + dem*. Then the dative-plural *-n*. Set up 2026-10-12. |
| 2026-10-28 | Possessivartikel im Dativ — *meinem · meiner · meinem · meinen* | A2.1 U3 | The booklet exercise (*Welcher Satz ist richtig?* + *Ergänze die Possessivartikel*) was hard — the ending is being guessed, not checked against the noun behind it. Drill the four slots cold, then *euer → eurem* (~~euerem~~) and the plural *-n* (*mit unseren Kindern*). Set up 2026-10-14. |
| 2026-10-30 | Indefinitpronomen — *ein- / kein- / welch-* in der richtigen Form | A2.1 U7 | Booklet exercises (*Ergänze “ein- / welch-”* + *kein-* + the mixed set) — park for a cold fill-in quiz (2026-10-20). Drill the grids first: *ein-* Nom *einer · eins · eine · welche* · Akk *einen · eins · eine · welche*; *kein-* Nom *keiner · keins · keine · keine* · Akk *keinen · keins · keine · keine*. Then booklet prompts mixed: *Brauchst du noch ein Rezept? → eins* · *Willst du noch eine Wurst? → eine* · *Haben wir noch Zwiebeln? → welche* · *Hast du eine Kreditkarte? → keine* · *Ist hier ein Geldautomat? → keiner* · *Hast du ein Portemonnaie? → keins* · *Hast du einen 20-Euro-Schein? → keinen* · *Hat Gogo eine Kreditkarte? → keine / Katie hat eine* · *Möchtest du ein Brötchen? → keins / schon eins gegessen*. Set up 2026-10-20. |
| 2026-11-01 | Verben mit zwei Objekten — order + pronoun swap | A2.1 U7 | **Confusing as hell on the booklet exercises (2026-10-20)** — no idea what was happening on *Ersetze die unterstrichenen Nomen* and *Antworte mit den Personalpronomen im Dativ und Akkusativ*. Cold drill in this order: (1) Grid *ihm · ihr · ihm · uns · euch · ihnen · Ihnen*. (2) Two nouns → Dat before Akk. (3) **Replace underlined Akk noun only** → pronoun moves left: *Er gibt dem Mann das Geld. → Er gibt es dem Mann.* · *Ich habe meinem Bruder einen Ball geschenkt. → Ich habe ihn meinem Bruder geschenkt.* · *Kannst du mir den Saft kaufen? → Kannst du ihn mir kaufen?* (4) **Answer with both pronouns** → Akk before Dat: *Empfiehlst du Max das Restaurant? → Ja, ich empfehle es ihm.* · *Bringst du Eva die Tasche mit? → Ich bringe sie ihr mit.* · *Gibst du der Verkäuferin das Geld? → Ich gebe es ihr.* · *Erzählst du den Leuten einen Witz? → Ich erzähle ihn ihnen.* · *Erklären Sie den Schülern die Hausaufgabe? → Ich erkläre sie ihnen.* · *Bestellst du deiner Freundin einen Salat? → Ich bestelle ihn ihr.* Trap: ~~Er gibt dem Mann es.~~ · ~~Ich gebe ihm es.~~ · mixing up *ihr* (to her) with *ihr* (you all). Set up 2026-10-20. |

---

## Closed entries

Move a row here once it's `PASSED`. Keep them — the tally is your progress measure.

| # | Pattern / Chunk | Booklet | First logged | Closed | Notes |
|---|---|---|---|---|---|
| 5 | mehr + Adjektiv | A1.2 Unit 3 | 2026-09-30 | 2026-10-24 | Cold: *langsamer* held (*Sprich* form soft). |
| 6 | kein vs nicht | A1.2 Unit 3 | 2026-09-30 | 2026-10-24 | Cold: *Wir brauchen keine Milch.* |
| 9 | hier | A1.1 Unit 3–4 | 2026-10-01 | 2026-10-24 | Cold: *hier* (not *Heir*). |
| 10 | Was machst du beruflich? | A1.1 Unit 6 | 2026-10-01 | 2026-10-24 | Cold: *Was machst du denn beruflich?* |
| 11 | Job ohne Artikel | A1.1 Unit 6 | 2026-10-01 | 2026-10-24 | Cold: *Ich bin Programmierer* / *Sie ist Ingenieurin* (no article). |
| 13 | Akkusativ einen und keinen | A1.1 Unit 9 | 2026-10-09 | 2026-10-24 | Cold: *einen Apfel* · *keinen Kaffee*. |
| 1 | Verbposition: Zeit / leider zuerst | A1.1 Unit 10 | 2026-09-27 | 2026-10-24 | Early cold: *Um 7 Uhr gehe ich…* · *Leider habe ich…* |
| 2 | Akkusativ maskulin | A1.1 Unit 9 | 2026-09-27 | 2026-10-24 | Early cold: *einen Weißwein* · *keinen Kaffee*. |
| 18 | Akkusativ: die Endung bewegt nur maskulin | A1.1 U8/U9 · A1.2 U1 | 2026-10-11 | 2026-10-24 | Early cold: *den ganzen Tag* · *dein Zimmer* (no false *-en*). |
| 19 | Imperativ *du* vs Präsens *du* | A1.2 Unit 3 | 2026-10-11 | 2026-10-24 | Early cold: *Nimm den Wein!* |
| 20 | Partizip II: trennbare starke Verben | A1.2 U6–U7 | 2026-10-11 | 2026-10-24 | Early cold: *aufgestanden* · *mitgenommen*. |

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
