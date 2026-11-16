# Crown coach measured again (crown-coach-measure-2, 2026-11-16)

A measuring job: no game or AI code changed. It measures the Crown coach of branch crown-coach-1116 at 2842d130 (0.38.36:
the first measurement's coach plus THE ARMY FLOOR (`armyfloor:off`), FARM FIRST in every plan but the Rush
(`farmfirst:off`), and main 0.38.36: Horseman 60 + horse 40, Pack Hunt 124, Horseman 90 hp, the Brood spot fix, the Brood
Rootmaw coach) in three arms:

- **A** as is;
- **B** `norush:off` (the coach, but the Horseman rush v a GREEDY Brood kept; Crown v Brood only);
- **C** `coach:off` (also turns off farm first: the Crown as on main).

Data: docs/crown_coach_measure_2/data/{A,B,C}/<tag>/ (result.json, story.txt), every table in
docs/crown_coach_measure_2/tables.md (tools/study/crown_coach_measure_2_report.py), films in docs/crown_coach_measure_2/films/.

## In short

| pairing (Crown's view) | arm | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|
| Crown v Brood | A as is | 0-29-9 | 0 / 36 / 2 | 9 (11:07) |
| Crown v Brood | B norush:off | 0-29-9 | 0 / 35 / 3 | 9 (10:58) |
| Crown v Brood | C coach:off | 0-34-4 | 0 / 31 / **7** | 4 (10:26) |
| Crown v Clockwork | A as is | 0-38-0 | 0 / 36 / **2** | 0 |
| Crown v Clockwork | C coach:off | 0-36-2 | 0 / 38 / 0 | 2 (11:34) |

1. **Against the Clockwork the coach now clearly helps.** Paired (same map and seed) the coached Crown earns more by 8:00
   in 31 of 38 games (**p < 0.001**; 0.68 v 0.57 of the Clockwork's income) and still by 12:00 (29 v 7, **p < 0.001**; 0.58 v
   0.48), and its army is bigger at 8:00 (29 v 9, **p 0.002**; 0.71 v 0.55). It holds 2.7 halls at 12:00 (C: 2.0). The
   outcome moved a little its way (better in 4, worse in 0: the 2 coach-off losses and 2 coached even draws, p 0.125).
   The first measurement saw only +0.04 of income at 8:00 and nothing by 12:00: the army floor (the army clock, "keeps its
   army on time") and farm first together turned a small economic gain into a lasting one without costing the army.
2. **Against the Brood the coach is still worse than none, though less so.** A v C: outcome better 3 / worse 12 / same 23
   (**p 0.035**; the first measurement 3 / 15, p 0.008). The army floor halved the damage at the first Brood arrival (a
   median 18 Crown units and 2 buildings lost in 90 s, was 28 and 5; C 11 and 2) and lifted the army at 8:00 to 0.54 of the
   Brood's (was 0.41; C 0.75), but the Crown is still thin at 5:00 (a median 120 of army, C 360; smaller in 29 of 37 pairs,
   p 0.001) and the Brood, left alone by no rush, is richer (31.5 workers at 5:00 against 23.4 when the Crown rushes). Losses
   by 12:00: 9 (C 4); built halls lost 1.00 a game (C 0.76).
3. **Keeping the rush (B) does not save it.** B earns the most (income 0.93 of the Brood's at 8:00; B v C higher in 32 of 38,
   p < 0.001) and holds the Brood to 25.9 workers at 5:00, but its army is the thinnest when the Brood comes (8:00 ratio
   0.43; the first arrival kills a median **32** Crown units and **8** buildings), so B v C is 3 / 11 (p 0.057) and A v B is
   10 / 11 (p 1.0): the rush plus the coach's economy rules is no better than the coach alone. The rush's riders go out,
   the economy rules then hold the gold for labourers and halls (the halls rule moved the next Town Hall up in 35 of 38 B
   games, 0 of 38 A games), and nothing stands at the gate.
4. **The fight rules fire a little more than before but decide little.** Lines formed before contact (story): v Brood A 19
   in 13 games (C 1), v Clockwork 31 in 18 (C 28 in 18); guns set early in 13 (Brood) and 16 (Clockwork) of 38 games; screen
   sightings 0.4 a game. Screen riders are trained first in 33 / 37 of 38 games.
5. No game failed, no script errors (190 games).

**Recommendation (Claude's, nothing applied):**

- **v the Clockwork: merge arm A** (the coach as is: army floor, farm first, labourers first, halls on time).
- **v the Brood: merge neither A nor B; keep the Crown as it is on main (arm C)** by gating the coach's economy rules
  (labourers first, halls on time, no blind rush) off in the Brood matchup. Farm first goes with them in arm C, so if the
  owner wants farm first everywhere (his decision of 08:01), the cleanest next measurement is v the Brood only: `coach:off`
  against "coach:off but farm first" and against "A with `labsfirst:off`" (76 games each, ~3 h on two cores), to find which
  of the economy rules costs the army. The army floor is right in kind but too late against the Brood's 6:30-8:00 Timing
  push: the line it wants at 5:00 (389 in the film) is far below what the Brood brings at 7:00 (1,345).

## How it was measured

- **The win-rate design of docs/winrate_2026_11_15.md**, as the first measurement (docs/crown_coach_measure.md on branch
  crown-coach-measure): tools/qa_match.gd, Hard OPTIMAL v Hard OPTIMAL, the 19 two-player maps x round 0 and round 1
  (`qa_matches.base()`: the same tags, seeds and side swaps), **to 12:00** (`end 720`).
- **Each game in every arm**, the arms next to each other in the queue (tools/study/crown_coach_measure_2.py; 190 games:
  114 Crown v Brood, 76 Crown v Clockwork; two at a time on a 2-core machine, Godot 4.7.1 headless, about 2.3 minutes of
  real time a game, 7.3 hours). The match is not deterministic, so a pair shares map, seed and sides, not the game.
- **Won or led**: won, or led a draw by 10% on income earned + 2 x army value. **Ratios**: the Crown's over its enemy's,
  pooled (sum over sum); tables.md also has per-game means. **Sign test**: two-sided exact, ties dropped.
- **Coach counters**: tools/qa_match.gd writes the Crown computer's counters into result.json `crown_ai` (the first
  measurement's read-only addition, cherry-picked). The army floor and farm first have no counter of their own; their effect
  shows in LABOURERS FIRST's own counters (v Brood labourers it trained a game 31.8 -> 17.9, seconds it held gold 53 -> 31;
  v Clockwork 31.6 -> 24.7 and 50 -> 41, first measurement -> now).

## Crown v Brood (38 paired games)

| arm | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| A as is | 1.00 | 0.85 | 0.80 | 0.75 | 0.43 | **0.54** | 0.50 | 0.35 |
| B norush:off | 1.07 | **0.93** | 0.79 | 0.72 | 0.53 | 0.43 | 0.31 | 0.19 |
| C coach:off | 1.06 | 0.80 | 0.74 | 0.68 | 0.69 | **0.75** | 0.66 | 0.39 |

| arm | Crown halls 8:00 | 12:00 | Brood halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | Brood workers 5:00 | 8:00 | built Crown halls lost a game |
|---|---|---|---|---|---|---|---|---|---|
| A as is | 1.9 | 1.5 | 4.0 | 3.9 | 25.5 | 40.7 | **31.5** | 51.9 | 1.00 |
| B norush:off | 2.2 | 1.4 | 3.9 | 4.0 | 22.9 | 38.5 | 25.9 | 49.7 | 1.21 |
| C coach:off | 2.0 | 1.8 | 3.7 | 3.9 | 19.3 | 28.4 | **23.4** | 47.3 | 0.76 |

The first enemy arrival in the Crown's base (medians):

| arm | games | when | Brood army | Crown army there | Crown units lost in 90 s | Brood units lost | Crown buildings lost | Crown army 5:00 | 8:00 | Crown's first attack (games, when) | games with a built hall lost (first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A as is | 38 | 8:00 | 687 | 1045 | **18** | 39 | 2 | **120** | 1100 | 28, 8:30 | 23, 10:30 |
| B norush:off | 33 | 8:10 | 575 | 840 | **32** | 26 | **8** | 240 | 770 | 19, 8:15 | 25, 10:05 |
| C coach:off | 32 | 8:10 | 625 | 955 | 11 | 33 | 2 | 360 | 835 | 7, 5:35 | 19, 10:55 |

(The first measurement, coach on: 7:40, 550, 715, 28 lost, 5 buildings, army 90 at 5:00.)

Paired:

| X v Y | outcome X better / Y better / same (p) | income 8:00 X higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|
| A v C | 3 / 12 / 23 (**0.035**) | 25 / 13 (0.073) | 16 / 11 (0.44) | 8 / 29 (**0.001**) | 12 / 26 (**0.034**) | 14 / 13 (1.0) |
| B v C | 3 / 11 / 24 (0.057) | 32 / 6 (**< 0.001**) | 19 / 8 (0.052) | 11 / 24 (**0.041**) | 12 / 26 (**0.034**) | 10 / 16 (0.33) |
| A v B | 10 / 11 / 17 (1.0) | 14 / 24 (0.14) | 10 / 11 (1.0) | 15 / 21 (0.41) | 19 / 19 (1.0) | 13 / 7 (0.26) |

OPTIMAL's picks: A Balanced 38 of 38; B the Rush 37, Economy 2 (one game switched), Balanced 1; C the Rush 37, Balanced 1.
No map stands out (game by game in tables.md): A lost on Amberfall r0, Ashfall r1, Border March r0 and r1, Cinder Steps
r0, Dune Sea r0 and r1, Redrock r0, Saltmarsh r1; C trailed on those (Dune Sea r1 even) but lost Redrock r0 and Saltmarsh r1
too, and Hollowfen r1 and Thornwood r0 (A trailed there).

## Crown v Clockwork (38 paired games)

| arm | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| A as is | 0.73 | **0.68** | 0.62 | **0.58** | 0.69 | **0.71** | 0.58 | 0.32 |
| C coach:off | 0.64 | 0.57 | 0.52 | 0.48 | 0.69 | 0.55 | 0.42 | 0.20 |

| arm | Crown halls 8:00 | 12:00 | Clockwork halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | Clockwork workers 5:00 | 8:00 | built Crown halls lost a game |
|---|---|---|---|---|---|---|---|---|---|
| A as is | 2.1 | **2.7** | 3.0 | 4.0 | 21.5 | 34.2 | 27.0 | 45.7 | 0.74 |
| C coach:off | 1.9 | 2.0 | 3.1 | 4.1 | 19.3 | 29.3 | 27.4 | 47.2 | 0.74 |

First arrival: both 6:30, the Crown's army there 687 v 550, losses alike (3 v 2 units, 1 v 2 buildings); the Crown's own
first attack 21 games in each arm (9:00 v 9:30). Paired A v C: outcome 4 / 0 / 34 (p 0.125: Kestrel Rise r0 and Saltmarsh r1
even instead of trailing, Cinder Steps r1 and Mirewood r1 trailed instead of lost); income 8:00 31 / 7 (**p < 0.001**), 12:00
29 / 7 (**p < 0.001**); army 5:00 17 / 18 (1.0), 8:00 29 / 9 (**p 0.002**), 12:00 24 / 12 (0.065). OPTIMAL picks the same in
both arms (Timing 19, Balloon 12-13, Economy 7, Siege 1-2). Still 4 Clockwork halls to the Crown's 2.7 at 12:00.

## Which coach rules fired (per game; games where it fired)

| pairing (arm) | labourers by LABOURERS FIRST | s it held gold | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|
| v Brood (A) | 17.9 (38) | 31 | 0 | 3.1 (33) | 3.9 (13) | 0.5 | 0.4 | 3.3 / 0.5 |
| v Brood (B) | 15.8 (38) | 24 | 35 | 1.1 (17) | 4.3 (10) | 0.4 | 0.1 | 1.8 / 0.4 |
| v Brood (C) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0.2 / 0 |
| v Clockwork (A) | 24.7 (38) | 41 | 9 | 2.7 (37) | 3.6 (16) | 0.8 | 0.4 | 2.3 / 0.2 |
| v Clockwork (C) | 0 | 0 | 0 | 0 | 0 | 0.7 | 0.3 | 1.9 / 0.3 |

Story: "forms its musket line before the enemy" v Brood A 19 in 13 games, B 17 in 11, C 1 in 1; v Clockwork A 31 in 18, C 28
in 18. "Holds its wave back" v Brood A 27 in 20, B 2 in 2, C 32 in 17. "Keeps its army on time" (the army clock, every arm)
v Clockwork 129-131 lines in all 38 games; v Brood it never shows: there the musket line rule ("puts its musket line before
more buildings", 285-292 lines in every game of every arm) speaks instead.

## Films (arm A, tools/film_coach.gd shots:1 under xvfb-run, 12:00)

docs/crown_coach_measure_2/films/<film>/: coach.txt (both sides every 15 s), story.txt, log.txt, result_short.json (with the
coach counters), map_0600/0900 and the last map, the Crown's army every 30 s from 6:00 and the fights (jpg, 60%). A film is
a new game on the study game's map, seed and sides, not a replay of it.

- **crbr_border_march_1121** (Border March, the Crown P2; in the study A lost, B and C trailed). Lost at 11:24, as in the
  study. Balanced after a GREEDY read. The Crown takes its natural at 3:01 and walls it, and the bank sits at 0-40 from
  3:00 to 6:30: the gold goes to the hall, the palisade and labourers (21 at 4:00, 37 at 6:45; LABOURERS FIRST trained 17).
  The musket line rule speaks every minute ("180 against the 389 it wants" at 5:13, "300 against 790" at 6:13) but the army
  is 60 at 4:00, 120 at 5:00, 300 at 6:00, while the unrushed Brood Timing has 500 at 5:00 and 1,345 at 7:00 (3 Tyrant
  Challengers, 16 Spitters). The push reaches the natural's palisade at 7:05 (fight_0733: Raptors and Spitters at the
  wall, 8-9 Musketeers and one gun behind it, the Farms still full of farmers); 33 Crown units and 10 buildings go in 90 s,
  the natural's hall falls at 8:45, the other at 10:05. The army floor never had the gold to act on: what it wants is too
  little too late for this push.
- **crcw_highmoor_1104** (Highmoor, the Crown P2; in the study trailed in both arms). Trailed (income 0.61, army 0.25 at
  12:00), but the Crown's best side is on show. Timing; the army clock keeps it on time ("410 against the 411 it wants" at
  5:35), it holds a Clockwork push at 6:08 (530 v 490), and its first wave leaves at 7:03 and forms a rank of 7 Musketeers
  with 3 guns behind (fight_0721) before the enemy; the line wins the field three times (7:41, 8:27, 10:00). What still goes
  wrong: the guns stay limbered behind the line (fight_0721, fight_1043), twice the wave meets the enemy before forming
  (8:01, 9:08), and at 10:40 the wave climbs the Clockwork's ramp as a column into its gears (fight_1043) and is spent:
  army 1,625 at 10:00, 900 at 11:00. 4 halls by 10:00, 50 labourers at 11:00; the Clockwork still out-earns it 21.6k to
  13.3k by 12:00.

### What the Crown still does wrong (coach's notes)

1. **v the Brood the army comes too late, whatever the rules say.** The Brood's Timing reaches the Crown at 7:00-8:00 with
   600-1,400 of army; the Crown's own wants by 5:00 are under 400 and its army at 5:00 is a median 120. A floor tied to the
   enemy (the scouted Brood army, or a fixed 500 by 6:00 after a Timing read) would do what a floor tied to its own wants
   cannot.
2. **The walled natural costs the most at the worst time** v the Brood (hall + palisade + labourers between 3:00 and 6:30
   with the bank at 0).
3. **Guns still march limbered** and are rarely set before contact (13-16 of 38 games).
4. **The wave attacks up ramps as a column** v the Clockwork (the line forms in the open, not at a choke).

## Recommendation

v the Clockwork: **arm A**. v the Brood: **arm C** (the coach's economy rules off in that matchup), until the Brood-only
measurement above shows which rule costs the army; B is not better than A (10 / 11) and loses the most at the first arrival.
