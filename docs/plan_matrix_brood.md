# Plan matrix, the Brood (job plan-matrix-brood, finished as plan-matrix-brood-2)

The owner, 2026-11-18 10:59: "we can open up the testing to all strategies against all factions because we are in new
territory now." Sister jobs plan-matrix-crown (docs/plan_matrix_crown.md) and plan-matrix-clockwork
(docs/plan_matrix_clockwork.md) ran the same design for their factions. Studies only: no game, AI or balance code changed.

## What was played

- Every Brood plan of the computer (Balanced, Rush, Economy, Timing, Air rush, Extreme rush, Spitter timing, Brute siege)
  and OPTIMAL itself as the baseline, FORCED on the Brood's Hard computer, against each side's Hard OPTIMAL: the Crown,
  the Clockwork and the Brood (the mirror).
- **4 maps, not 6** (Greenhold, Ashford Crossing, Mirewood, Frostfang), each twice with the start spots swapped:
  **8 games a cell, 216 games, all to 20:00.** The machine has 2 cores and a game takes 6-12 minutes; 6 maps would have
  been 324 games and another ~6 hours, so the run stopped at 4 maps (the runner orders the games map by map, so every cell
  has the same maps and both spots). No game hung or failed (a 30-minute kill timer was added to the runner for that:
  `--timeout`; the first run's stall was its session ending, not a hung game).
- Versions: the games against the Clockwork and the mirror on Greenhold are the first run's (0.38.59; nothing of the
  Brood's, the Clockwork's or the shared AI changed between 0.38.59 and 0.38.69); everything else is 0.38.69. The first
  run's 8 games against the Crown were played again because the Crown computer changed in 0.38.60 (kept for reference in
  `docs/plan_matrix_brood/data_0.38.59/`).
- **Caveat, newer main:** main reached 0.38.79 while the games ran. Three of its changes touch these games: every computer
  now hunts enemy scouts in its base (scout-deny, 0.38.62: the reads that pick OPTIMAL's plans may come later or differ),
  the Crown OPTIMAL's Rush now really gets its Horsemen (crown-build-stack, 0.38.79: the Crown's opening against the Brood
  is stronger than in these games), and the Brood computer's late game thinks faster (same game, its trace identical).
  The column against the Crown is the one most likely to move; rerun it if the owner wants it current.
- Scoring (as the sister studies): W / L = a side beaten before the bell; at the bell a draw is LED (w) or TRAILED (l) when
  one side's income earned + 2 x army value is 10% ahead, else even (=). "Won or led" = W + w. "p" = a two-sided sign test
  of the plan against OPTIMAL's game on the same map, round and spots.

Tools: `tools/study/plan_matrix_brood.py` (the runner; main's `plan_matrix.py` is the Crown study's, with another command
line), `tools/study/plan_matrix_brood_report.py` (the tables), `tools/study/plan_matrix_brood_cw.py` (the finer ranking
below), `tools/study/plan_matrix_brood_waves.py` (the Brood's waves). Data: `docs/plan_matrix_brood/data/` (result.json
and story.txt per game), `games.csv`, `tables.md` (every number by plan and opponent: income and army ratios at 5, 8, 12,
16 and 20 minutes, workers, halls, first attacks, OPTIMAL's picks), `waves.md`, `v_*_fine.md`, `films/`.

## The table

Won or led of 8 (W-D-L), and against OPTIMAL's games: better / worse, p.

| Brood plan | v Crown OPTIMAL | v Clockwork OPTIMAL | v Brood OPTIMAL |
|---|---|---|---|
| Balanced | **7** (4-4-0) · 2/4 p 0.69 | **0** (0-2-6) · 2/2 p 1.0 | **6** (4-4-0) · 5/1 p 0.22 |
| Rush | **8** (7-1-0) · 2/1 p 1.0 | **0** (0-0-8) · 0/2 p 0.50 | **0** (0-2-6) · 1/7 p 0.070 |
| Economy | **7** (6-1-1) · 1/1 p 1.0 | **0** (0-1-7) · 1/2 p 1.0 | **2** (2-4-2) · 2/3 p 1.0 |
| Timing | **8** (3-5-0) · 1/4 p 0.38 | **0** (0-0-8) · 0/2 p 0.50 | **4** (4-1-3) · 3/2 p 1.0 |
| Air rush | **2** (2-5-1) · 0/6 p **0.031** | **0** (0-1-7) · 1/2 p 1.0 | **0** (0-1-7) · 1/6 p 0.13 |
| Extreme rush | **8** (5-3-0) · 0/1 p 1.0 | **0** (0-0-8) · 0/2 p 0.50 | **1** (1-2-5) · 0/6 p **0.031** |
| Spitter timing | **6** (6-1-1) · 1/2 p 1.0 | **0** (0-1-7) · 1/2 p 1.0 | **2** (1-5-2) · 1/4 p 0.38 |
| Brute siege | **6** (6-2-0) · 2/2 p 1.0 | **1** (1-0-7) · 1/2 p 1.0 | **2** (1-3-4) · 2/4 p 0.69 |
| OPTIMAL | **8** (6-2-0) | **0** (0-2-6) | **3** (3-4-1) |
| all plans | 60 of 72 | **1 of 72** | 20 of 72 |

In plain words:

1. **Against the Crown computer almost anything wins.** 60 of 72 won or led, 45 of them outright. Only the Air rush is
   clearly worse (2 of 8; worse than OPTIMAL in 6 of 6 differing games, p 0.031). This agrees with plan-matrix-crown, which
   saw the Crown beaten by the Brood in 82 of 96 games whatever the Crown's plan.
2. **Against the Clockwork computer nothing wins.** 1 of 72 won or led (one Brute siege win on Frostfang). No plan, OPTIMAL
   included, holds the Clockwork after 8:00. This agrees with plan-matrix-clockwork (the Clockwork won 8 of 8 with
   Economy or Pendulums against the Brood) and with the 2026-11-17 win rates (Clockwork wins or leads 34 of 38).
3. **In the mirror the Balanced plan is best** (6 of 8, better than OPTIMAL 5 times and worse once), and the rushes and
   the Air rush are worst (0-1 of 8).
4. **The Air rush plan is not an air plan** (see below): it is the worst plan in all three columns.

The start spots: the forced Brood won or led 44 of 108 on spot A and 37 of 108 on spot B (no edge to speak of).

## Against the Crown: the best and the worst

| plan v Crown | won or led | income ratio 8:00 / 12:00 / 16:00 | workers 8:00 (Brood v Crown) | Crown halls lost | first Brood attack |
|---|---|---|---|---|---|
| Rush (best) | 8 (7 wins) | 0.89 / 1.23 / 1.62 | 35 v **24** | 3.1 | 3:05 |
| OPTIMAL | 8 (6 wins) | 1.10 / 1.30 / 1.58 | 51 v 37 | 3.3 | 7:47 |
| Balanced | 7 | 1.17 / 1.46 / 1.58 | 53 v 37 | 2.4 | 7:10 |
| Air rush (worst) | 2 | 0.85 / 0.92 / 1.02 | 38 v 37 | 0.8 | 7:10 |

On the finer score (`v_crown_fine.md`) the Rush ranks first (2.79; better than Balanced in 4 games, worse in none).

- **Why the Rush is best:** the Crown OPTIMAL reads the Brood as GREEDY at ~1:40 and opens its own Horseman rush in 56 of
  the column's 72 games; the Brood's Raptors at 3:00 meet a Crown that has spent on the Horse Breeder and not on labourers.
  The Crown has 24 workers at 8:00 against the Rush (37 against Balanced) and never catches up: from 12:00 the Brood out-earns
  it 1.2-1.6x and takes its halls (3.1 halls lost a game). Note this is the Crown Rush as it was before 0.38.79, which did
  not get its Horsemen out on time; with that fixed the Brood's Rush may meet riders sooner.
- **Why the Air rush is worst** (film 2, `films/air_v_crown/`, Greenhold, a draw the Crown led at the bell): the plan wants
  its Storm Sire at 2:30 (`"storm": 150` in its row of `ai_brood_new.gd`), keeps only 44 grubs, and turns off Pack Hunt
  (`"pack": false`). In the 24 Air rush games the Storm Lure came **never in 10** and at a median ~8:15 in the other 14
  (5:24 to 16:28); only 10 Pterodactyls died in all 24 games. So the army is plain Raptors without Pack Hunt, on fewer grubs.
  In the film: grubs stop at 44 from 7:00; Raptors (32 at 8:00) reach the Crown's line at 7:43 and are pulled back; the Crown,
  unharassed, builds Musketeers and guns behind its wall (army 2,140 v 715 at 10:00, 4,200 v 2,045 at 16:00); the Storm Lure
  is only sent at 19:05. `map_0800.png` to `map_1900.png` show the Brood never past the middle after 8:00.
  Coach's note: something in the Air rush's build order (the Venom Sire and the second ground come first, the Storm Lure's
  grub is never sent while warriors are wanted) keeps it from ever being an air plan. Worth a look by a Brood coaching job;
  until then the plan is a weak Raptor build under a wrong name.

## Against the Clockwork: no plan works, the least bad

Every game is lost or trailed, so the won/led count can't rank the plans. `plan_matrix_brood_cw.py` ranks them finer
(a win 3; a draw 0..2 by the Brood's share at the bell; a loss -2 at once .. -1 at the bell) and pairs each plan with the
forced Rush on the same map and round:

| plan v Clockwork | finer score | better / worse than the Rush (p) | income ratio 8:00 / 12:00 | army ratio 8:00 / 12:00 | workers 8:00 (Brood v Clockwork) | beaten at (mean) |
|---|---|---|---|---|---|---|
| OPTIMAL (opens Rush, then Timing) | **-0.76** | 7 / 1 (0.070) | 0.80 / 0.76 | 0.53 / 0.35 | 42 v **30** | 14:10 (6 of 8) |
| Balanced | **-0.76** | 7 / 1 (0.070) | 0.80 / 0.72 | 0.69 / 0.39 | 43 v 42 | 14:20 (6 of 8) |
| Brute siege | -0.78 | 5 / 3 | 0.82 / 0.80 | 0.60 / 0.48 | 50 v 44 | 13:41 (7 + 1 win) |
| Spitter timing | -1.01 | 7 / 1 (0.070) | 0.72 / 0.70 | 0.50 / 0.31 | 48 v 42 | 14:45 (7) |
| Economy | -1.07 | 6 / 2 | 0.69 / 0.62 | 0.42 / 0.19 | 41 v 41 | 13:27 (7) |
| Air rush | -1.11 | 5 / 3 | 0.74 / 0.61 | 0.46 / 0.21 | 43 v 42 | 12:44 (7) |
| Timing | -1.30 | 6 / 2 | 0.78 / 0.72 | 0.58 / 0.31 | 44 v 42 | 13:59 (8) |
| Extreme rush | -1.40 | 5 / 3 | 0.50 / 0.55 | 0.41 / 0.07 | 23 v 30 | 11:58 (8) |
| Rush (worst) | -1.41 | - | 0.48 / 0.58 | 0.29 / 0.17 | **23** v 30 | 11:47 (8) |

- **How every plan loses** (`waves.md`): every wave the Brood sends at the Clockwork is pulled back (waves sent = waves
  pulled back in every row), losing 57-70% of it, and the Clockwork's army is 2-3x the Brood's by 12:00 and 2-5x by 16:00.
  The Clockwork OPTIMAL plays Balanced in all 72 games, meets each wave with its whole army on its own gears ("the rest of its
  army stays on its gears", "whole army defends its base"), adds Pendulums, a turret and a Brass Serpent, then pushes from
  ~8:30 and ends it at 12:00-15:00.
- **Why the forced Rush is worst** (film 1, `films/rush_v_clockwork/`, Greenhold, beaten at 10:15): 10 Raptors at 3:14 meet
  5 Clock Soldiers on the ramp (the Clockwork read the early pit as AGGRESSIVE at 1:06 and built a Light Works first); the
  wave comes back with half. The Rush kept the Brood on 7-9 grubs until 4:00 while the Clockwork had 22 Winders; at 6:00 the
  armies are 325 v 1,050, at 7:15 the Brood's second wave (725) walks into 1,875 and is pulled back with 175 left; the
  Clockwork's push (2,500 at 8:00: 20 Clock Soldiers, 6 Springers, 3 Pendulums) breaks the Mother's guard at 8:25 and the
  game is over at 10:15 (`map_0730.png`: the Brood's wave on the Clockwork's doorstep, `map_0830.png`, `map_0930.png`).
- **The owner's question: OPTIMAL opens the Rush on a GREEDY read and loses; is Economy or another plan better?**
  Not on these games. OPTIMAL read the Clockwork as GREEDY at ~1:41 in 8 of 8 and opened its Rush, as in the win-rate
  study; but OPTIMAL's Rush is short: it moves to Timing at ~4:35 (6 of 8) or Economy (1), and its raid sets the
  Clockwork's Winders back (30 at 8:00, against 42 when the Brood plays Balanced). It ends level with the best forced plan
  (Balanced, -0.76) and better than the forced Rush in 7 of 8 games. The forced **Economy** plan did worse (0 of 8, income
  0.62 of the Clockwork's at 12:00, army 0.19): an unharassed Clockwork simply out-grows it. So the opening is not what
  loses this matchup; the fights from 5:00 on are. A pick table cannot fix it: the work is the Brood computer's waves
  against a Clockwork base (never into a defended base at 1:2 or worse; the 2026-11-17 study said the same about its
  half-size waves), or the matchup's balance, which is the owner's call.

## The mirror: the best and the worst

| plan v Brood | won or led | finer score | v OPTIMAL | grubs 8:00 (own v opp) | income 8:00 / 12:00 |
|---|---|---|---|---|---|
| Balanced (best) | **6** | 2.05 | 5 / 1 (p 0.22) | 55 v 54 | 1.08 / 1.27 |
| Timing | 4 | 1.17 | 3 / 2 | 46 v 51 | 1.00 / 1.00 |
| OPTIMAL | 3 | 1.40 | - | 50 v 52 | 1.02 / 1.17 |
| Rush (worst) | 0 | -0.86 | 1 / 7 (p 0.070) | 34 v **56** | 0.52 / 0.53 |
| Air rush (worst) | 0 | -1.05 | 1 / 6 | 44 v 55 | 0.82 / 0.77 |
| Extreme rush | 1 | -0.26 | 0 / 6 (p **0.031**) | 47 v 54 | 0.72 / 0.75 |

- The Brood OPTIMAL reads the other Brood NORMAL in 8 of 8 and then picks Timing 5 times (won or led 1) and Balanced 3
  times (won or led 2). The forced Balanced won or led 6 of 8: its waves come at ~7:00 with an equal economy and an army
  1.3-1.4x the other's, and four of the eight ended before the bell (mean 13:40).
- The rushes fail in the mirror for the same reason as against the Clockwork: a Brood holds Raptors with Raptors at home,
  and the rusher is left with 34 grubs to the other's 56 at 8:00.

## Does OPTIMAL pick the best plans?

| v | OPTIMAL picked (these games) | how it did | the best plan here | verdict |
|---|---|---|---|---|
| Crown | Balanced 5, Spitter 1, Timing 1, Brute 1 (reads AGGRESSIVE / NORMAL) | 8 of 8 | Rush (7 wins of 8), OPTIMAL, Timing, Extreme rush (8 of 8) | fine as it is |
| Clockwork | Rush 8 of 8 (GREEDY read), then Timing | 0 of 8, but the least bad with Balanced | none wins; Balanced = OPTIMAL | the pick is not the problem |
| Brood | Timing 5, Balanced 3 (NORMAL read) | 3 of 8 | Balanced (6 of 8) | pick Balanced, not Timing |

## Proposed pick table (for the owner; nothing changed)

| Brood OPTIMAL v | proposal | evidence |
|---|---|---|
| the Crown | keep the picks; the Rush is an equal option on a GREEDY read | 8 of 8 as is; the Rush 7 wins of 8. Re-measure on 0.38.79 (the Crown's Rush now gets its Horsemen) |
| the Clockwork | keep the GREEDY-read Rush (or Balanced: they score the same); **never the forced Rush or Economy** | no plan wins (1 of 72); the work is the waves against a Clockwork base, not the pick |
| the Brood | **Balanced on a NORMAL read** instead of Timing | Balanced 6 of 8, better than OPTIMAL 5 / 1 (p 0.22: a lean) |
| all | **Air rush: fix or hide.** It never builds its Storm Sire on time; never pick it | worst in every column (2, 0, 0 of 8; p 0.031 v OPTIMAL v the Crown) |

All of these are leans on 8 games a cell (only the Air rush v the Crown and the Extreme rush in the mirror reach p < 0.05
against OPTIMAL). The two clear findings are the two ends: the Brood beats the Crown computer with nearly anything, and
loses to the Clockwork computer with everything.

## Films

1. `films/rush_v_clockwork/` (the worst plan v the Clockwork; Greenhold seed 1102, the Brood on spot A; tools/film_coach.gd,
   headless: the map every 15 s and coach.txt, a line every 15 s per side; story.txt is the AI STORY). Five maps kept:
   03:15 (the Raptors out), 06:00, 07:30 (the second wave at the Clockwork's ramp), 08:30 (the push on the Mother), 09:30.
2. `films/air_v_crown/` (the worst plan v the Crown; Greenhold seed 1100, the Brood on spot A). Six maps kept: 05:00,
   08:00 (the only Raptor wave), 10:00, 13:00, 16:00, 19:00.

Both films were played on 0.38.69 with `film_coach.gd`; their games follow the matrix games closely (the matrix Rush game
was beaten at 9:20, the film's at 10:15; the Air rush game is a Crown-led draw in both).
