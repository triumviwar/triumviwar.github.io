# The Crown's army against the Brood (crown-brood-army, 2026-11-17)

A coaching job (the owner 2026-11-16 23:25: "start all coaching jobs needed"; earlier: "crown can beat brood, it's crown AI
that is bad"). The Crown COMPUTER only, against the Brood only: no unit, price or rule number changed. Its ECONOMY and
ARMY SIZE: how much army it has when the Brood's push comes, what the gold goes to before it, when the army goes out, and
when the economy grows. The fighting code (the line, the guns, the screen) is the job crown-guns-coach's.

Code: scripts/ai_crown_v_brood.gd parts 5-7 (AICrownVBrood), a call in AICrown._think_stage and AICrown._wave_worth, a
line in AICrownCoach.econ_rules. Switches: `cba:off` (the whole job: the Crown v the Brood as on main 0.38.38),
`cbafloor:off` (part 5), `cbahold:off` (part 6), `cbaecon:off` (part 7), `cbacounter:on` (the counter, not kept),
`cbafloor:k=<x>` (the floor's table times x). Tools: tools/crown_brood_trace.gd (the Crown's army every 5 s and what its
gold bought, into army.json), tools/study/crown_brood_army.py (the measure) and crown_brood_army_report.py (its tables),
tools/qa_match.gd reads the new counters (result.json crown_ai vb_*). Data: docs/crown_brood_army/data/{F,H,O}/, tables
in docs/crown_brood_army/tables.md, films in docs/crown_brood_army/films/.

MEASURE_SUMMARY

## What was wrong (traced and filmed on 0.38.38)

A quick loop of 8 games (Border March r0 and r1, Greenhold r0 and r1, Dune Sea r1, Saltmarsh r1, Redrock r0, Hollowfen r1)
on main with tools/crown_brood_trace.gd: 2 lost, 6 drawn (1 led by the Crown, 5 by the Brood), 8 built halls lost.
On 0.38.38 the Crown OPTIMAL opens with the Horseman rush against nearly every Brood (it reads the Brood GREEDY at ~1:40
in every game: the Brood's first Mound Turtle on new ground is its usual opening), the rush "fails" at ~5:10 and hands
over to the Economy plan with a walled natural.

1. **The line is short every minute from 4:30 to 8:00 and the Barracks stand idle.** The v-Brood line rule (part 1 of
   AICrownVBrood) says so every minute ("180 of Musketeers and guns against the 386 it wants by now"), but its keep holds
   two Musketeers' gold only from some of the ways the gold goes. Dune Sea r1, 5:30-7:00: two Barracks, neither busy, 25
   gold in the bank, while the gold went to a Cottage, a Foundry, a Barracks, 27 pieces of the natural's palisade, two
   Farms, a second Powder Mill, the Cavalry Charge and another Cottage; the line stood at 240 from 6:00 to 7:13 while the
   Brood's army went from 500 to 825.
2. **One Musketeer per harvest.** The Crown's gold comes in harvests of 300-600 every ~20 s. With a Musketeer bought only
   when the Barracks is empty, each harvest bought one (15 s to train) and the rest went to labourers and buildings before
   the Barracks was empty again: Greenhold 1100, 6:08-7:20, the Barracks idle about half the time with 0-5 gold between
   harvests (tools/crown_brood_trace.gd, and a debug run of this job's first version).
3. **The table, not the Brood.** What the line wants comes from a table of the Crown's own (300 at 5:00, 700 at 6:00) capped
   at 45 a labourer (under 900 till 8:00 on 20 labourers), while the Brood's Timing reached the Crown at 6:20-8:00 with
   600-1,400 (Saltmarsh r1 6:20: 1,400 against 480, both halls lost by 10:00; Redrock r0 6:50: 985 against 590).
4. **With an army, it walks out of its wall.** With this job's floor alone (the first loop) the Crown had 900-1,300 at
   7:00-8:00 and its wave went at the first edge over the Brood army it reckoned (1.25 of the coach's honest reckoning,
   which counts 0.4 of a Hard Brood's table while the Brood was seen lately): Redrock r0 7:55, 1,200 out against 990 known,
   16 Musketeers formed for a guard of 100 and lost the field (480 for 100) with the Brood's army behind it; the Brood came
   back at 10:10 with 2,360 against 720 and took both halls. Hollowfen r1 7:14: wave 2 out with 24 supply, the Brood's
   push at the natural's gate at 7:31 met 120 at home.
5. **The economy rules from the start still leave it thin.** `broodecon:on` on top of the floor (4 games): army at 5:00
   60-180, at 8:00 0.10-0.38 of the Brood's, 2 of the 4 lost (the floor yields only the idle Barracks' gold; labourers
   first takes the rest).
6. **Two halls to the end.** In every traced game the Crown stood on 2 halls from ~4:30 to 12:00 against the Brood's 4,
   with 25-30 labourers at 8:00 against the Brood's 45-55 workers: even a held push leaves it a trailing draw.

FILMS_BEFORE

## What changed

**5. THE ARMY FLOOR TIED TO THE BROOD** (`cbafloor:off`), from 4:00 to 9:30:

- The floor follows the Brood: FLOOR_SEEN (1.0) of the Brood army its scouts saw in the last two minutes, and the push to
  come 30 s ahead from FLOOR_TABLE (250 at 5:00, 500 at 6:00, 1,000 at 7:30, 1,300 at 9:00) whatever the read (0.6 of it
  before any read), bounded by the economy (55 a labourer, at least 500). It raises the line's own want
  (AICrownVBrood.line_want), so every rule that asks "is the line short" (the labourers wait for idle Barracks, the
  milestones are held, no Church) now asks against the Brood.
- Before any think stage spends, every Barracks takes Musketeers TWO DEEP (FLOOR_DEPTH, as the coach's labourers) and an
  idle Foundry a Field Cannon (one for 4 Musketeers) while the line with its queues is under the floor; the price of the
  slots it could not fill is held from everything else until the next harvest. Only the idle production's gold is held,
  so a busy Barracks lets the economy go on. No dry Musketeer: without his 10 powder he waits (the Mill's crew grows).
- Every Barracks and Foundry busy for 10 s and still 200 short: one more Barracks (up to 3).
- No Brood soldier seen for 75 s between 4:00 and 6:30: a scout goes to look (AICrown.want_look).
- Once a push has been held (part 6) the table counts half: what is seen leads.

**6. HOLD THE FIRST PUSH** (`cbahold:off`): until 10:00 no wave goes out against the Brood unless the army is twice the
Brood army it reckons, never less than a Hard Brood's table (AICrown.BROOD_TABLE: 2,200 at 8:00) for the army it has not
seen. A push is HELD when 450 of Brood die within 75 s: the floor relaxes and the economy grows (part 7). The fight at the
wall is the existing code (the gate post, the defence's alert and muster, the guns).

**7. THE ECONOMY AFTER THE HOLD** (`cbaecon:off`): the coach's LABOURERS FIRST and HALLS ON TIME (off against the Brood
since 0.38.38) come on once a push has been held, or from 9:00 if none has come.

**Not kept: the counter after a held push** (`cbacounter:on`, part 3 of AICrownVBrood with only its "the Brood's wave just
died at our line" reason). FILMS_COUNTER

MEASURE

## Claude's choices (for the owner)

CHOICES
