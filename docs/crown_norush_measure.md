# The Crown without its blind Horseman rush v the Brood (crown-norush-measure, 2026-11-17)

A measuring job: no game or AI code changed (study tools and this doc only). The question: on main (0.38.46, so with the
army floor and the hold of 0.38.40 and the guns of 0.38.41), is the Crown better against the Brood WITHOUT the blind
Horseman rush that OPTIMAL opens with in 37 of 38 games?

Three arms, Crown OPTIMAL v Brood OPTIMAL, Hard, to 12:00:

- **A** as is;
- **N** the blind rush off alone: `optlean:off greedybrood:balanced`. No switch had to be written: `optlean:off` stops the
  lean to the rush before the scout (AIOptimal.lean_now), and `greedybrood:balanced` (the study switch of
  docs/crown_optimal_opening.md) makes a GREEDY read of the Brood pick Balanced instead of the riders. Those are exactly the
  two places `AICrownCoach.no_rush_v_brood()` acts (AIOptimal._lean_chance and AIOptimal._punish), so N is NO BLIND RUSH
  without `broodecon:on`'s labourers first and halls on time. Checked in the data: N picked Balanced in 38 of 38, no story
  mentions a Horseman rush.
- **R** the rush only on a truly greedy Brood: `optlean:off truegreed:on` (existing switches): no lean; a GREEDY read
  checks what the scout saw (3+ grounds or 5+ Rootmaws, AIOptimal._true_greed_brood) and rides only then, else the
  Economy race (that switch's own fallback, not Balanced). In practice the scout at ~1:30 never saw a truly greedy Brood:
  R picked the Economy race in 37 games and Balanced in 1, and never rushed. **R is therefore "Economy instead of the
  rush"**, not a rush on a real read.

Data: docs/crown_norush_measure/data/{A,N,R}/<tag>/ (result.json, story.txt); every table in
docs/crown_norush_measure/tables.md (tools/study/crown_norush_measure_report.py); the film in docs/crown_norush_measure/films/.

## In short

| arm | W-D-L | won or led: Crown / Brood / even | decided (mean length) | built Crown halls lost a game |
|---|---|---|---|---|
| A as is (the rush) | 0-37-1 | **4** / 28 / 6 | 1 (11:55) | **0.42** |
| N no blind rush (Balanced) | 0-31-**7** | 0 / 33 / 5 | 7 (10:44) | 1.03 |
| R rush on true greed only (= Economy) | 0-35-3 | 0 / 31 / 7 | 3 (10:54) | 0.82 |

1. **The Crown is WORSE without the rush.** Paired (same map, seed and sides), outcome: N better in 4, A better in **14**,
   same in 20 (**p 0.031**); R better in 4, A better in 12 (p 0.077). N lost 7 games outright (A 1), won or led none (A 4),
   lost 2.5x as many built halls. Army at 8:00 lower in **33 of 38** (N v A, p < 0.001) and 31 of 38 (R v A, p < 0.001).
2. **Why: the rush's worth is in the Brood's economy, not the Crown's** (as docs/crown_optimal_opening.md and the
   truegreed study found in November). Without it the Crown is richer (income earned by 8:00 7,370 v 5,750; labourers at
   8:00 42 v 30) but the unharassed Brood is richer still: 31 workers at 5:00 v 23, income earned by 8:00 9,014 v 7,067,
   **army at 8:00 1,794 v 1,051**. The income ratio at 8:00 is a wash (0.82 v 0.81, paired 21 / 17, p 0.63); the army
   ratio at 8:00 drops from 1.01 to 0.52. In A the Brood reads AGGRESSIVE (the Horse Breeder) in 37 of 38 and spends its
   opening on Raptors; in N and R it never does, and goes to its Spitter timing or Brute siege on a full economy.
3. **The Brood's first push is bigger and does more.** First arrival in the Crown's base (medians): A 7:50 with 575 of
   army (in 31 games), N 8:10 with **900** (in all 38), R 8:25 with 637; the Crown lost 4 / 10 / 7 units and 0 / 2 / 1
   buildings in the first 90 s; a built hall lost in 12 / 22 / 19 games.
4. **The Crown's 5:00 is thin in every arm, thinnest in R**: army at 5:00 360 (A, the riders), 210 (N), 52 (R: the
   Economy race builds no army before 5:00). The army floor of 0.38.40 lifts all three to ~1,000-1,200 by 8:00, but against
   1,800-1,900 of Brood in N and R.
5. N v R: R's income is a little higher (8:00 24 / 14, p 0.14; 12:00 20 / 9, p 0.061) and its outcome a little better
   (9 / 3, p 0.15), both below the rush.
6. 114 games, none failed, no errors.

**Recommendation: do NOT switch the rush off v the Brood by default.** On 0.38.46 the blind Horseman rush is still the
Crown computer's best opening against the Brood's OPTIMAL in this measure: removing it (with Balanced or with the Economy
race behind it) makes the Crown lose more (p 0.03) because it lets the Brood's economy and army run free. The owner's
reading of the rush ("like a 6pool: if it doesn't deal a lot of damage it is almost certainly a loss") is right about its
shape but not about this computer's numbers: the rush rarely kills much, yet it makes the Brood answer it (Raptors, a
slower economy) and that is worth more to the Crown than the farms it gives up. What the Crown lacks against the Brood is
not the opening but the plan after it (point 4 and the film): a standard opening that wins needs an answer to the Brood's
Spitter / Brute timing at 8:00-8:30 that this computer does not have yet.

Proposals (nothing applied):

- **P1** keep `no_rush_v_brood()` behind `broodecon:on` as it is; drop the idea of NO BLIND RUSH v the Brood until the
  Crown's standard game can hold the Brood's 8:00 push (re-measure arm N after any such work: the tools are here).
- **P2** if the rush is to go one day, what it does must be replaced: a cheaper, later harass that still makes the Brood
  read AGGRESSIVE (one or two Horsemen at its grubs at ~3:00 from a Farm-first opening?) is the arm to measure next.
- **P3** the truly-greedy check (truegreed) never fires at the 1:30 read v this Brood (its usual opening is 2 grounds and
  under 5 Rootmaws), so a "rush only on real greed" rule is the same as no rush; a later second look would be needed.

## How it was measured

- **The win-rate design** (docs/winrate_2026_11_15.md, as docs/crown_brood_measure.md): tools/qa_match.gd, Hard OPTIMAL
  Crown v Hard OPTIMAL Brood, the 19 two-player maps x round 0 and round 1 (`qa_matches.base()`: the same tags, seeds and
  side swaps as the earlier measures), **to 12:00** (`end 720`).
- **Each game in every arm**, the arms next to each other in the queue (tools/study/crown_norush_measure.py; 114 games;
  one at a time on a 2-core machine (jobs = cores - 1), Godot 4.7.1 headless, every game under `timeout 2400`, ~4.5
  minutes a game, ~8.5 hours). The match is not deterministic, so a pair shares map, seed and sides, not the game.
- **Won or led**: won, or led a draw by 10% on income earned + 2 x army value. **Ratios**: the Crown's over the Brood's,
  pooled (sum over sum); tables.md also has per-game means. **Sign test**: two-sided exact, ties dropped. Absolute numbers
  below are means over the 38 games (income = income earned so far).

## Economy and army (Crown / Brood, pooled)

| arm | income 3:00 | 5:00 | 8:00 | 10:00 | 12:00 | army 3:00 | 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|---|---|
| A as is | 1.05 | 1.04 | 0.81 | 0.76 | 0.69 | 0.86 | 0.78 | **1.01** | **0.91** | **0.63** |
| N no blind rush | 1.03 | 0.91 | 0.82 | 0.75 | 0.70 | 0.00 | 0.75 | 0.52 | 0.57 | 0.42 |
| R true greed only | 1.03 | 0.99 | **0.86** | **0.81** | **0.74** | 0.00 | 0.22 | 0.58 | 0.73 | 0.58 |

| arm | Crown income earned 5:00 / 8:00 / 12:00 | Brood income earned 5:00 / 8:00 / 12:00 | Crown army 5:00 / 8:00 / 12:00 | Brood army 5:00 / 8:00 / 12:00 |
|---|---|---|---|---|
| A | 2,840 / 5,750 / 10,698 | 2,728 / **7,067** / 15,404 | 354 / 1,059 / 1,477 | 455 / **1,051** / 2,361 |
| N | 2,940 / 7,370 / 10,815 | 3,234 / 9,014 / 15,397 | 210 / 934 / 994 | 280 / 1,794 / 2,357 |
| R | 3,000 / 7,560 / 12,663 | 3,028 / 8,803 / 17,035 | 52 / 1,099 / 1,494 | 234 / 1,909 / 2,596 |

| arm | Crown halls 8:00 | 12:00 | Brood halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | Brood workers 5:00 | 8:00 |
|---|---|---|---|---|---|---|---|---|
| A | 2.0 | 2.2 | 3.6 | 3.9 | 19.8 | 30.4 | **23.3** | 47.2 |
| N | 1.9 | 1.8 | 4.0 | 4.0 | 24.9 | 42.1 | 31.4 | 52.0 |
| R | 2.0 | 2.2 | 4.0 | 4.0 | 27.1 | 43.6 | 29.1 | 51.9 |

## Paired

| X v Y | outcome X better / Y better / same (p) | income 8:00 X higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|
| N v A | 4 / **14** / 20 (**0.031**) | 21 / 17 (0.63) | 15 / 15 (1.0) | 16 / 20 (0.62) | 5 / **33** (**<0.001**) | 11 / 19 (0.20) |
| R v A | 4 / 12 / 22 (0.077) | 23 / 15 (0.26) | 19 / 15 (0.61) | 1 / 36 (<0.001) | 7 / **31** (**<0.001**) | 15 / 18 (0.73) |
| N v R | 3 / 9 / 26 (0.15) | 14 / 24 (0.14) | 9 / 20 (0.061) | 33 / 3 (<0.001) | 19 / 19 (1.0) | 10 / 18 (0.19) |

## The Brood's first arrival in the Crown's base (medians; 300+ army value within 500 px)

| arm | games | when | Brood army | Crown army there | Crown units lost in 90 s | Brood units lost | Crown buildings lost | Crown army 5:00 | 8:00 | the Crown's own first attack (games, when) | games with a built hall lost (first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| A | 31 | 7:50 | 575 | 1,110 | 4 | 35 | 0 | 360 | 1,080 | 11, 6:10 | 12, 10:55 |
| N | 38 | 8:10 | **900** | 1,195 | 10 | 31 | 2 | 240 | 1,045 | 6, 10:57 | 22, 10:15 |
| R | 38 | 8:25 | 637 | 1,635 | 7 | 34 | 1 | 60 | 1,200 | 4, 11:00 | 19, 10:45 |

## OPTIMAL's picks, both sides

| arm | the Crown's picks | the Brood's first read -> pick | Brood reads AGGRESSIVE (games) | the Brood's picks (all) |
|---|---|---|---|---|
| A | Rush 37 (lean or GREEDY punish), Economy 2, Balanced 1 | NORMAL/UNKNOWN -> Timing 9, Brute 10, Spitter 7 | 37 | Brute 10, Timing 9, Spitter 7, Economy 2 |
| N | Balanced 38 | UNKNOWN/GREEDY -> Brute 12, Spitter 12, Timing 9 | 0 | Brute 12, Spitter 12, Timing 9, Economy 4 |
| R | Economy 37, Balanced 1 | GREEDY -> Spitter 18, UNKNOWN -> Spitter 7, Brute 5, Timing 4 | 0 | Spitter 25, Economy 6, Brute 5, Timing 4 |

The coach's rules fire as before in every arm (tables.md): screen riders trained first in 28-34 games, the musket-line
rule speaks in every game, "holds its wave back" in 20-25 games.

## Film (arm N, tools/film_coach.gd shots:1 under xvfb-run, 12:00)

docs/crown_norush_measure/films/crbr_border_march_1158_N/: coach.txt (both sides every 15 s), story.txt, log.txt,
result_short.json, map_0600/0900/1145, both armies every 30 s from 6:00 and the fights (jpg, 60%). The same map, seed and
sides as the films of docs/crown_brood_measure.md and docs/crown_coach_measure_2.md (Border March 1158, the Crown P1), so
they can be set side by side; a film is a new game, not a replay of the study's (in the study A trailed here, N lost).

- **crbr_border_march_1158_N**: a draw on the clock, but the Crown is wiped out (0 halls, 0 army, 1 labourer at 12:00
  against 4,190 of Brood army on 4 grounds). No lean; at 1:32 the Crown reads GREEDY and picks Balanced. Its economy is
  good: the natural's hall at 3:08, a walled natural, 45 labourers at 8:00 (the Brood 44 workers). The Brood, never shown
  a Horse Breeder, reads UNKNOWN at 3:00 and goes Timing with its whole economy behind it. Its first push at 6:02 (22
  supply) is held at the palisade (the Crown loses 3, the Brood 18: "moves its army along the palisade", fight_0622).
  But the armies part: 480 v 915 at 6:00, 1,190 v 1,905 at 8:00, while the musket-line rule asks every minute for more
  than the Barracks give. At 8:09 the Brood comes with 66 supply (45 soldiers worth 1,125 at the gate at 8:26); the line
  of 18 behind the palisade melts to 4 in twenty seconds (fight_0831: Raptors and Spitters among the Farms, the hall's
  guard still forming), the Crown "holds the gate ... its army (240) goes out only at 3,244", the natural's hall falls at
  9:00, the fresh hall at 10:20 is lost unbuilt, the main's hall at 11:35. The Crown's own army never left home.

What it shows: the rush's absence did not buy the Crown a better game, it bought the Brood a free one. The Crown's
standard opening is sound to 6:00 (it holds the first Timing push); it loses the 8:00 push because the Brood's army has
grown faster than its own, not because it was out-built at home.

## Claude's choices

1. N uses two existing study switches instead of a new `norushonly:on`: they act at exactly the two places
   `no_rush_v_brood()` does, so no game code was touched.
2. R uses `truegreed:on`, whose fallback on a usual opening is the Economy race (the owner's earlier "out-expand it"),
   not Balanced; with it R turned out to be a second no-rush arm (the true greed was never seen), which is still worth
   having: two different no-rush openings both lose to the rush.
3. Measured on 0.38.46 (main at the start of the job; the task named 0.38.45; 0.38.46 changed only a test).
