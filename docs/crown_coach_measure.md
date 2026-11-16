# Crown coach measured (crown-coach-measure, 2026-11-16)

A measuring job: no game or AI code changed. It measures the Crown coach of branch crown-coach-1116 at 3f513748 (0.38.35,
scripts/ai_crown_coach.gd: labourers first, halls on time, an honest reckoning v the Brood, no blind Horseman rush v the
Brood, the screen before the wave, guns set before contact) against the same build with `coach:off`.

Data: docs/crown_coach_measure/data/{on,off}/<tag>/ (result.json, story.txt), every table in
docs/crown_coach_measure/tables.md (tools/study/crown_coach_measure_report.py), films in docs/crown_coach_measure/films/.

## In short

| pairing (Crown's view) | arm | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|
| Crown v Brood | coach on | 0-26-12 | **0** / 36 / 2 | 12 (10:59) |
| Crown v Brood | coach:off | 0-32-6 | **2** / 30 / 6 | 6 (11:26) |
| Crown v Clockwork | coach on | 0-38-0 | 0 / 38 / 0 | 0 |
| Crown v Clockwork | coach:off | 0-36-2 | 0 / 38 / 0 | 2 (11:18) |

1. **Against the Brood the coach makes the Crown WORSE.** Paired game by game (same map and seed) the coach-off Crown did
   better in 15, the coached one in 3, 20 the same: **sign test p = 0.008**. Twice as many losses by 12:00 (12 v 6), more
   built halls lost (1.39 v 0.79 a game) and the army at 8:00 is half the enemy's share (0.41 v 0.83 of the Brood's,
   smaller in 35 of 38 pairs, p < 0.001). The income is a little better (0.84 v 0.80 of the Brood's at 8:00, inside the
   noise: 23 v 15 pairs, p 0.26).
2. **Why: the Crown is naked when the Brood arrives.** With the coach its army at 5:00 is a median **90** (off: 360); it
   builds 42 labourers by 8:00 (off: 29), but the Brood's first arrival (median 7:40, 550 of army) kills a median **28**
   Crown units and 5 buildings in 90 s (off: 7 and 2). Two rules do it together: LABOURERS FIRST holds the gold for
   labourers before any soldier (the story says "puts its musket line before more buildings (240 ... against the 461 it
   wants)", "(300 ... against 862)": the army never catches up), and NO BLIND RUSH removes the only early pressure. **The
   "failed" Horseman rush was doing a job**: it held the Brood's economy back (Brood workers at 5:00: 23 with the rush, 31
   without), so without it the Brood is richer, earlier and attacks a Crown that has only labourers.
3. **Against the Clockwork the economy rules help a little and change nothing else.** Income at 8:00 0.63 v 0.59 of the
   Clockwork's, higher in 28 of 38 pairs (**p 0.005**); 35 v 31 labourers at 8:00; the halls rule moved the next Town Hall
   up in 24 games. But by 12:00 the gain is gone (0.52 v 0.48, 19 v 17 pairs), the army ratio is the same (0.55 v 0.56 at
   8:00), and every game is still a draw the Clockwork leads (the off arm lost 2, the coached arm 0: p 0.5).
4. **The fight rules barely fire.** Per game the line formed on the march 0.3-0.6 times, the screen sighted the enemy 0.1-0.2
   times. Guns set early fired in 10 of 38 games in each pairing. v the Brood the coach forms before contact more often (13
   formings v 6) but also meets the enemy unformed more often (26 v 5), because it walks out with a thin wave. Screen riders
   are trained first in 28 (Brood) and 34 (Clockwork) games, but against the Clockwork they mostly sit at home: the Timing
   plan holds its attack ("its army (1200) is not clearly bigger than the 1394 it reckons") and a screen only rides with a
   wave.
5. No game failed, no script errors (152 games).

**Recommendation for the owner (Claude's, nothing applied):** keep LABOURERS FIRST and HALLS ON TIME against the
Clockwork; against the Brood do not merge the coach as it is. Either give LABOURERS FIRST an army floor (soldiers first
until the army is a set share of the reckoned Brood army, or of `wants by now`, from ~3:00), or keep the Horseman rush v a
GREEDY Brood (`norush:off`) and keep only the economy rules. The cleanest next measurement is the same design with
`norush:off` and with `labsfirst:off` separately v the Brood (76 games each, ~2.5 h on two cores).

## How it was measured

- **The win-rate design of docs/winrate_2026_11_15.md**: tools/qa_match.gd, Hard OPTIMAL v Hard OPTIMAL, the 19 two-player
  maps x round 0 and round 1 (`qa_matches.base()`: the same tags, seeds and side swaps), **to 12:00** (`end 720`, not 15:00
  as the win-rate study: so the W-D-L here has more draws and is not comparable with that study's table).
- **Each game twice**: as is ("on") and with `coach:off` ("off"), the two arms next to each other in the queue
  (tools/study/crown_coach_measure.py; 152 games, two at a time on a 2-core machine, about 2 minutes of real time a game).
  The match is not deterministic, so a pair shares map, seed and sides, not the game.
- **Won or led**: won, or led a draw by 10% on income earned + 2 x army value (the win-rate studies' rule).
- **Ratios**: the Crown's over its enemy's, pooled (sum over sum, as in the win-rate reports; tables.md also has the
  per-game means). Income = earned by then. A side beaten before a minute counts 0 halls then.
- **Coach counters**: tools/qa_match.gd now writes the Crown computer's counters into result.json `crown_ai` (read only:
  AICrownCoach labs_first_n / labs_first_held_t / screen_trained / guns_early_n / bo_hall_moved, AICrownLine forms /
  deploys / def_lines, AICrownScreen sent / sightings / lost). Story lines counted with grep.
- **Sign test**: two-sided exact, ties dropped.

## Crown v Brood (38 pairs)

| arm | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.88 | 0.84 | 0.78 | 0.73 | 0.33 | **0.41** | 0.39 | 0.19 |
| coach:off | 1.03 | 0.80 | 0.75 | 0.70 | 0.66 | **0.83** | 0.73 | 0.52 |

| arm | Crown halls 8:00 | 12:00 | Brood halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | Brood workers 5:00 | 8:00 | built Crown halls lost a game |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 1.9 | 0.9 | 4.0 | 4.0 | **24.9** | **41.9** | 31.1 | 51.1 | 1.39 |
| coach:off | 2.0 | 1.7 | 3.7 | 3.9 | 19.4 | 28.8 | 23.2 | 47.7 | 0.79 |

(Brood "halls" as tools/qa_match.gd counts them for the Brood.)

The first enemy arrival in the Crown's base (medians):

| arm | games | when | Brood army | Crown army there | Crown units lost in 90 s | Brood units lost | Crown buildings lost | Crown army 5:00 | 8:00 | Crown's first attack (games, when) | games with a built hall lost (first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| coach on | 35 | 7:40 | 550 | 715 | **28** | 32 | 5 | **90** | 860 | 17, 8:50 | 29, 9:55 |
| coach:off | 30 | 8:15 | 512 | 920 | 7 | 42 | 2 | 360 | 820 | 9, 6:35 | 20, 10:40 |

Paired, coach on v off: outcome better 3 / worse 15 / same 20 (**p 0.008**); income at 8:00 higher in 23 / lower in 15 (p
0.26), at 12:00 13 / 11 (p 0.84, only games both arms reached); army at 8:00 3 / 35 (**p < 0.001**), at 12:00 7 / 17 (p
0.064). The coach did better on Frostmere r1 and Redrock r0 (a trailed draw instead of a loss) and Greenhold r0 (even instead
of trailing); the coach-off Crown did better on Ashfall r1, Border March r0 and r1, Frostmere r0, Greenhold r1, Redrock r1,
Saltmarsh r0 and r1 (a trailed draw instead of a loss), Ashford r1, Highmoor r0, Kestrel r0 and r1, Thornwood r1 (even
instead of trailing), Highmoor r1 and Mirewood r0 (led instead of trailing): no map stands out, the coach loses across the
pool.

OPTIMAL's picks: with the coach Balanced in 38 of 38 (the GREEDY read now picks Balanced); without it the Horseman rush in
38 of 38.

## Crown v Clockwork (38 pairs)

| arm | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.64 | **0.63** | 0.57 | 0.52 | 0.73 | 0.55 | 0.46 | 0.22 |
| coach:off | 0.63 | 0.59 | 0.53 | 0.48 | 0.70 | 0.56 | 0.37 | 0.17 |

| arm | Crown halls 8:00 | 12:00 | Clockwork halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | Clockwork workers 5:00 | 8:00 | built Crown halls lost a game |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 2.1 | 2.2 | 3.1 | 4.1 | 21.3 | 34.7 | 27.7 | 47.1 | 0.97 |
| coach:off | 2.0 | 2.2 | 3.1 | 4.1 | 19.5 | 30.5 | 27.6 | 47.0 | 1.11 |

First arrival: 7:00 (coach) v 6:10 (off), the Crown's army there 670 v 480, losses alike (4 units, 2 buildings).
Paired: outcome 2 / 0 / 36 (p 0.5: the two coach-off losses, Amberfall r1 and Cinder Steps r1); income at 8:00 28 / 10
(**p 0.005**), at 12:00 19 / 17; army at 8:00 20 / 18, at 12:00 20 / 16. OPTIMAL picks the same plans in both arms (Timing
19, Balloon 12, Economy 7). Still 4 Clockwork halls to the Crown's 2 at 12:00 and 47 workers to 35 at 8:00.

## Which coach rules fired (coach on, per game)

| pairing | labourers by LABOURERS FIRST (games) | s it held gold | next hall moved up (games) | screen riders trained first (games) | guns set early (games) | lines formed on the march | met the enemy unformed (story) | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| v Brood | 31.8 (38) | 53 | 0 | 2.1 (28) | 5.1 (10) | 0.3 | 26 lines in 11 games (off: 5 in 3) | 0.2 | 1.7 / 0.5 |
| v Clockwork | 31.6 (38) | 50 | 24 | 3.4 (34) | 2.5 (10) | 0.6 | 15 in 9 (off: 11 in 9) | 0.1 | 1.7 / 0.2 |

"Forms its musket line before the enemy" (story): v Brood 13 in 10 games (off 6 in 4), v Clockwork 16 in 11 (off 22 in 17).
"Holds its wave back": v Brood 27 in 19 games (off 24 in 16). The halls rule ("the next Town Hall first (the coach)") never
fired v the Brood: Balanced's opening has no Town Hall step ahead of a full main there.

## Films (coach on, tools/film_coach.gd shots:1 under xvfb-run, 12:00)

docs/crown_coach_measure/films/<film>/: coach.txt (both sides every 15 s), story.txt, result_short.json (with the coach
counters), map_0600/0900/1145.png, the Crown's army every 30 s from 6:00 and the fights (jpg, 60%).

- **crbr_greenhold_1137** (Greenhold, the Crown P2; the study pair: lost with the coach, trailed without). Lost at 11:47.
  The Crown fills its Farms (8/8, 46 labourers at 8:00) but its army is 120-480 all game; the Brood's Timing push (1,330
  at 6:30, 23 Raptors) sits in the Crown's natural from 6:30 and is never fought: the line is "a line of 1 behind the
  wall", the musket line 60 of the 1,172 it wants at 7:24. No screen rider was trained, no line formed, no gun set; the
  natural falls at 8:12, the main at 10:08. The coach's economy without an army.
- **crbr_kestrel_1130** (Kestrel Rise, P1; drawn). The best Crown film: 43 labourers by LABOURERS FIRST, 3 screen riders,
  guns set early 26 times, 2 lines formed. But the first wave (8:40, 31 supply) walks out as a crowd (fight_0903: muskets
  in a column at a gate, the guns on their horses behind, the riders inside the mass, not ahead) and is called home at
  9:54 by a push on its base; the second wave forms properly at 11:07 (15 muskets in a rank, 3 guns: army_0_1100) and
  fights the Raptors in line, but the guns are still limbered at the gate behind it.
- **crcw_greenhold_1101** (Greenhold, P1; trailed). Timing plan, 3 halls by 7:45 (the hall rule moved it up at 3:33),
  46 labourers at 9:45, but the Timing attack never leaves (`att false` all game) and 4 screen Cuirassiers stand at home.
  The Clockwork comes into the natural at 8:45; fight_0905: the Crown's soldiers in a crowd on the ramp, one gun firing,
  the natural's Farms emptied (0/8, 1/8) and its hall going down. Army 1,440 at 9:45, 230 at 11:45.
- **crcw_highmoor_1141** (Highmoor, P1; trailed). Timing again, never attacks: "holds its timing attack: its army (1200) is
  not clearly bigger than the 1394 it reckons" (9:43, 10:13). The line stands on the high ground above the natural's ramp
  (5 defence lines), the Clockwork walks into the natural below (fight_0707: Farms 1/8, Powder makers 0/6) and the line
  does not come down. No screen sent, no line formed on a march, 1 gun at most.

### What the Crown still does wrong (coach's notes)

1. **No army floor.** LABOURERS FIRST takes every harvest while a Farm post is free; the army lags "what it wants by now" by
   half or more for minutes (Greenhold 1137: 300 of 862, 60 of 1,172). The rule's stop (an armed enemy at our buildings)
   comes too late: by then the enemy is in the natural.
2. **Formed or not at contact: mostly not.** Lines formed on the march 0.3-0.6 times a game; most first contacts are at the
   Crown's own natural, where it stands "along the palisade" in 1-5 men or on the ramp in a crowd.
3. **Guns set: rarely.** Few guns are built (0-3 in the films) and they stay limbered at gates; the guns-early rule fires
   in a quarter of the games.
4. **Riders out front: only with a wave**, and the waves rarely go (Timing v the Clockwork holds the whole game). The
   screen riders the coach trains first stand at home.
5. **Halls held or lost: lost.** The natural falls in most Brood games (a built hall lost in 29 of 38 coached games, first
   at a median 9:55) and in 25 of 38 Clockwork games (9:50); a defending line on the main's high ground does not save the
   natural below it.
