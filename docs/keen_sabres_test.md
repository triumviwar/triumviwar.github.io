# keen-sabres-test: do we need Keen Sabres? (2026-11-15)

The owner (10:03): "Why do we need Keen Sabres as a concept? With charge and hit and run tactics we should be able to
deal enough damage." The 0.38.10 tests (docs/balance_raptor_horseman.md) used riders that stand and trade or a simple
scripted kite; 0.38.9 (docs/crown-coach-cavalry.md) gave the Crown computer real hit and run (AICavMicro). This job
measures Raptors against Horsemen with that hit and run, with and without the Charge and Keen Sabres.

**Nothing in the game changed.** Branch `keen-sabres-test`, version 0.38.12 (a version bump for the measuring
switches only). Study switches added, all off by default:

- `keensabres:off`: nobody can research Keen Sabres (Game.research_problem; the computer's research loop asks it too).
- `chargelight:2.2` (unit.gd `STUDY_CHARGE_LIGHT`): a charged blow on a light unit hits x2.2 instead of x2.
- `AICavMicro.charge_play` (a variable, set by the study tool): false = the micro rides as if the Charge weren't drilled
  (no galloping round to wait for the next charge), though charged blows still land when they happen.

## The answer in plain words

**No: hit and run plus the Charge, as they are today, do not hold Raptors at equal cost.** And the Charge, the way
the computer's riders play it, makes things *worse* against Raptors, not better.

1. **Riders that stand lose everything** (trade 0.15-0.18: they kill a sixth of their own value), as 0.38.10 found.
2. **Hit and run without research** (arm b) keeps riders alive (without Pack Hunt they are faster than Raptors) but
   kills little: the fights end in draws, trade about 0.4. The riders hold the field, they don't hold the Raptors.
3. **Adding the Charge** (arm c) is the worst micro arm: almost every rider dies (95-100%), trade 0.15-0.40. The
   charge needs 5 s without a blow and 2 s at the gallop; while the micro gallops round the fight to set up the next
   charge, the Raptors (92, 114 with Pack Hunt) close in. And a charged blow does 36, which leaves a 38-hp Raptor
   standing, so the charge never removes a Raptor by itself.
4. **Keen Sabres with hit and run** (arm d) is the only research that clearly helps: trade 0.5-1.2, riders win or
   draw most small fights. **Both researches** (arm e) is the best set against Raptors *without* Pack Hunt (trade
   1.0-1.15, 19 of 32 fights won), because a charged keen blow (48) does kill a Raptor; with Pack Hunt it falls apart
   again (the same charge-waiting problem: 0.40-0.55).
5. **At equal cost no rider set holds big fights.** At 8 v 45 and 12 v 67 even the best arms trade 0.5-0.9 and lose
   most riders. The swarm surrounds; the riders' speed edge buys draws, not kills. (The Brood's equal cost here is
   food against gold: see "How it was measured".)
6. **Raids on workers** don't need Keen Sabres: 4 riders kill all 10 grubs and 6 Spitters with or without it (no
   rider lost). With 12 Raptors guarding, both arms fail (c 0 of 4, e 0 of 4 won, 4 and 3.8 riders lost of 4).
7. **Computer games** (Crown OPTIMAL v Brood OPTIMAL, 8 games each): the Crown wins none either way. With Keen Sabres
   removed it lasted to 15:00 more often (draws 5 v 2) but still led only 1 game in 8; that's within the noise of 8 games
   (+-3). **The computer never drilled the Cavalry Charge before 15:00 in any of the 16 games**; it bought Keen Sabres
   at 5:55-7:40 in all 8 "on" games. So in today's computer games the Charge plays no part at all.

**So the honest answer to "with charge and hit and run we should deal enough damage": not with the Charge as it works
today.** Two numbers are against it: 36 doesn't kill 38, and the charge comes back too slowly (about every 7 s) to
trade against a swarm.

## What I'd recommend (the owner decides)

Keep Keen Sabres for now, **or** replace it with a Charge that does the job. The study's alternative arm points to
the second:

- **Charge x2.2 on light units** (one charge kills a 38-hp Raptor; 18 x 2.2 = 39.6), *with* riders that don't wait
  round for it (arm f2): trade 1.07-1.16 without Pack Hunt (as good as Keen Sabres, better in big fights: 1.15 at
  12 v 67 against Keen's 0.64), 0.67-0.69 with it, riders lose a third. **Played the way the micro plays the charge
  today (arm f), the same x2.2 is poor** (0.23-0.57): the number alone is not enough, the riders' play must change
  too.
- So, if the owner wants Keen Sabres gone, the alternative that measured best is a package:
  1. the Charge's double blow raised against light units (x2.2, or +2 on a charged blow) so one charge kills a Raptor;
  2. the computer's riders not galloping round to set up the next charge when the enemy is a fast melee swarm (in
     AICavMicro: `charge_play` off against Raptors), taking each blow as it comes;
  3. moving the Cavalry Charge to the Horse Breeder (the computer never drilled it at the Armoury before 15:00 in
     these games; at the Breeder it would come with the riders, as Keen Sabres does now).
  Even that package does not win big equal-cost fights; nothing tested does.
- If Keen Sabres goes: its button at the Horse Breeder, `Defs.RESEARCH["keen_sabres"]`, the `_:` blow in
  `Unit._strike`, its texts in en/pt/es (tools/i18n/71_balance_raptor_horseman.txt, the Horseman's and the Horse
  Breeder's "about" and tooltip, the Help page in tools/i18n/05_help.txt, lang_pt / lang_es), its stand-in icon
  (assets/icons/research_keen_sabres.png, docs/art_style_inconsistency.md), tools/test_keen_sabres.gd, and the
  computer's research (it has no rule of its own: the generic loop `AI._research` buys it at 6-7 min once the gold is
  there) all go; old saves with the flag just ignore it.
- If it stays: the proposal from 0.38.10 still stands: the computer should buy it only with riders out (today it buys
  it at 6-7 min whether or not).

## How it was measured

`tools/study_keen_sabres.gd` (Hollowfen's open ground, 30 x 20 tiles; the computers off; the riders' side runs a real
AICavMicro like the Crown computer's). Equal cost: a Horseman with his horse is 140 gold, a Raptor 25 food (an egg of
2 is 50), so 5.6 Raptors a rider: 2 v 11, 4 v 22, 8 v 45, 12 v 67. (The task's "4v2, 8v4" sizes are not equal cost:
4 Raptors cost 100 against 2 riders' 280; equal-cost sizes were used instead.) Food and gold are different
resources and Raptors use more supply (1 each against a rider's 3), so "equal cost" is equal spending only.

- The Raptors attack-move at the riders (open) or into the riders' base (a Town Hall, a Barracks and three Cottages
  round the riders); an idle Raptor goes at the nearest rider every second (a Brood player chasing). Hurt riders the
  micro sends "home" ride to the arena's edge. 60 s a fight, 4 seeds a cell, Pack Hunt off and on.
- A rider WIN = every Brood fighter dead; LOSS = every rider dead; else a draw. Trade = Brood value killed / rider
  value lost (140 a rider).
- Computer games: `tools/study/keen_sabres_games.py` (tools/qa_match.gd, Hard OPTIMAL v Hard OPTIMAL, 15:00,
  greenhold, mirewood, hollowfen, dune_sea, 2 seeds with the sides swapped), Keen Sabres researchable ("on") v
  `keensabres:off`. qa_match.gd now also writes when each research was done (`tech_at`).
- Data: docs/keen_sabres_test/*.json and *.log (every fight), docs/keen_sabres_test/games/*/result.json. Tables:
  `python3 tools/study/keen_sabres_report.py docs/keen_sabres_test/*.json`,
  `python3 tools/study/keen_sabres_games.py report docs/keen_sabres_test/games`.

Arms: stand = riders stand still; a = attack-move, no micro; b = hit and run, no research; c = b + Charge;
d = b + Keen Sabres; e = b + both. Alternatives: c2 = c but the micro doesn't wait round for the charge;
f / f2 = c / c2 with a charged blow on light x2.2.

### All sizes summed (16 fights a cell)

| arm | ground | Pack Hunt | riders W-D-L | trade | riders lost | Raptors killed |
|---|---|---|---|---|---|---|
| stand | open | no | 0-0-16 | 0.18 | 100% | 18% |
| stand | base | no | 0-0-16 | 0.18 | 100% | 18% |
| stand | open | yes | 0-0-16 | 0.15 | 100% | 15% |
| stand | base | yes | 0-0-16 | 0.16 | 100% | 17% |
| a | open | no | 0-0-16 | 0.26 | 100% | 26% |
| a | base | no | 0-0-16 | 0.27 | 100% | 27% |
| a | open | yes | 0-0-16 | 0.21 | 100% | 22% |
| a | base | yes | 1-0-15 | 0.22 | 98% | 22% |
| b | open | no | 0-14-2 | 0.40 | 47% | 19% |
| b | base | no | 0-16-0 | 0.44 | 31% | 13% |
| b | open | yes | 0-9-7 | 0.39 | 90% | 35% |
| b | base | yes | 0-13-3 | 0.65 | 64% | 42% |
| **c** | open | no | 0-0-16 | 0.36 | 100% | 36% |
| **c** | base | no | 0-4-12 | 0.40 | 95% | 38% |
| **c** | open | yes | 0-0-16 | 0.23 | 100% | 23% |
| **c** | base | yes | 0-0-16 | 0.15 | 100% | 15% |
| d | open | no | 0-16-0 | 0.74 | 38% | 29% |
| d | base | no | 0-16-0 | 0.52 | 38% | 20% |
| d | open | yes | 3-8-5 | 0.81 | 74% | 61% |
| d | base | yes | 4-11-1 | 1.18 | 56% | 66% |
| e | open | no | 10-1-5 | 1.02 | 74% | 76% |
| e | base | no | 9-3-4 | 1.15 | 73% | 84% |
| e | open | yes | 5-0-11 | 0.55 | 93% | 51% |
| e | base | yes | 4-0-12 | 0.40 | 92% | 37% |
| c2 | open | no | 0-16-0 | 0.48 | 49% | 24% |
| c2 | base | no | 0-15-1 | 0.51 | 30% | 15% |
| c2 | open | yes | 0-12-4 | 0.50 | 85% | 43% |
| c2 | base | yes | 1-9-6 | 0.50 | 77% | 39% |
| f | open | no | 5-1-10 | 0.57 | 90% | 52% |
| f | base | no | 0-3-13 | 0.43 | 96% | 42% |
| f | open | yes | 1-0-15 | 0.28 | 99% | 28% |
| f | base | yes | 0-0-16 | 0.23 | 100% | 23% |
| f2 | open | no | 0-16-0 | 1.07 | 36% | 38% |
| f2 | base | no | 0-16-0 | 1.16 | 30% | 35% |
| f2 | open | yes | 0-13-3 | 0.69 | 81% | 56% |
| f2 | base | yes | 1-12-3 | 0.67 | 74% | 50% |

### By size (open and base summed, 8 fights a cell): trade (riders lost)

| arm | Pack Hunt | 2 v 11 | 4 v 22 | 8 v 45 | 12 v 67 |
|---|---|---|---|---|---|
| stand | no | 0.21 (100%) | 0.18 (100%) | 0.17 (100%) | 0.18 (100%) |
| stand | yes | 0.18 (100%) | 0.17 (100%) | 0.16 (100%) | 0.15 (100%) |
| a | no | 0.36 (100%) | 0.29 (100%) | 0.30 (100%) | 0.22 (100%) |
| a | yes | 0.47 (100%) | 0.43 (94%) | 0.15 (100%) | 0.16 (100%) |
| b | no | 0.71 (6%) | 0.20 (44%) | 0.40 (36%) | 0.49 (45%) |
| b | yes | 0.61 (75%) | 0.74 (69%) | 0.35 (86%) | 0.52 (75%) |
| c | no | 0.41 (100%) | 0.60 (91%) | 0.35 (97%) | 0.32 (100%) |
| c | yes | 0.27 (100%) | 0.27 (100%) | 0.23 (100%) | 0.13 (100%) |
| d | no | 3.04 (6%) | 0.85 (25%) | 0.50 (48%) | 0.64 (41%) |
| d | yes | 2.82 (31%) | 1.56 (50%) | 0.78 (66%) | 0.83 (75%) |
| e | no | 2.62 (38%) | 2.32 (41%) | 0.87 (83%) | 0.91 (84%) |
| e | yes | 0.91 (75%) | 1.22 (66%) | 0.42 (100%) | 0.30 (100%) |
| c2 | no | no loss (0%) | 0.50 (31%) | 0.27 (52%) | 0.63 (41%) |
| c2 | yes | 0.68 (69%) | 0.54 (81%) | 0.56 (75%) | 0.43 (86%) |
| f | no | 0.86 (75%) | 0.96 (78%) | 0.45 (95%) | 0.36 (100%) |
| f | yes | 0.39 (94%) | 0.43 (100%) | 0.27 (100%) | 0.16 (100%) |
| f2 | no | no loss (0%) | 0.95 (38%) | 0.88 (28%) | 1.15 (40%) |
| f2 | yes | 1.15 (56%) | 0.91 (69%) | 0.72 (73%) | 0.55 (86%) |

### Raids (4 riders, 4 seeds)

| raid | arm | W-D-L | value killed (mean) | grubs killed (of 10) | riders lost (of 4, mean) | rider health left |
|---|---|---|---|---|---|---|
| 10 grubs + 6 Spitters | c (Charge) | 4-0-0 | 770 | 10.0 | 0.0 | 77% |
| 10 grubs + 6 Spitters | e (Charge + Keen) | 4-0-0 | 770 | 10.0 | 0.0 | 75% |
| + 12 Raptors on guard | c | 0-0-4 | 228 | 0.0 | 4.0 | 0% |
| + 12 Raptors on guard | e | 0-1-3 | 302 | 0.2 | 3.8 | 2% |

### Computer games (Crown OPTIMAL v Brood OPTIMAL, Hard, 15:00)

| arm | games | Crown W-D-L | won or led Crown/Brood/even | riders made | riders lost | kills by riders | of them Raptors | grubs |
|---|---|---|---|---|---|---|---|---|
| Keen Sabres on | 8 | 0-2-6 | 0/7/1 | 45 | 35 | 116 | 44 | 58 |
| keensabres:off | 8 | 0-5-3 | 1/7/0 | 74 | 45 | 110 | 33 | 62 |

Keen Sabres was researched at 5:55-7:40 in all 8 "on" games; the Cavalry Charge in none of the 16 (by 15:00). A
won-or-led count of 8 moves +-3 between runs of the same games, so these games don't separate the two; per game
tables: `python3 tools/study/keen_sabres_games.py report docs/keen_sabres_test/games`.

## Caveats

- The riders' play is the computer's AICavMicro, not a top player's. Its charge loop (gallop round until the next
  blow is a charge) is what hurts arm c; a human would likely play the charge better against Raptors, but no human
  can make 36 kill 38.
- The Raptors' play is simple: attack-move and chase the nearest rider. A Brood player who stops chasing riders he
  can't catch makes the hit-and-run draws even emptier for the riders.
- A few "rider health left" cells read over 100% (102-106%) where no rider was hurt; not looked into (the share is
  health left over the riders' starting maximum). It doesn't touch the win or trade numbers.
- 4 seeds a cell: single cells are noisy (one fight more or less moves a 2 v 11 cell a lot); read the summed rows.
