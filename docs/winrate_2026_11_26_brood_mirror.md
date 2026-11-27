# Win rates 2026-11-26: the Brood mirror

Job winrate-brood-mirror. A measuring job: no game rule and no AI changed. Main 0.38.221 (the AI lessons merged).
Tool: tools/study/winrate_1126_brood_mirror.py. Data: docs/winrate_2026_11_26/data/brood_mirror/default/ and nerf/.

How it was played: Hard OPTIMAL Brood against Hard OPTIMAL Brood, every game to 20:00 unless one side was beaten first,
30 games an arm on the six parity maps (5 a map), seeds 1126001 to 1126030, the same 30 games in both arms and in the
other three jobs. Half the games put player 1 on spot A, half on spot B (the `spotswap` switch), so the spot and the
player order can be told apart. "Our" side is the Brood on spot A.

Two arms: DEFAULT (main as it is) and NERF (`farmaw:2.0`: a far Rootmaw pays two times a near one, not 2.2 times; in
the mirror both sides have it).

Score = income earned + 2 x army at the bell or at the defeat; a beaten side's score counts a quarter. Led = 10% ahead
at the bell. g = ln(score of spot A / score of spot B).

## The table (spot-A Brood v spot-B Brood)

| arm | games | A won | A led | even | B led | B won | A won or led | B won or led | decided | median minute (decided) | mean g (t) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| default | 30 | 15 | 3 | 5 | 1 | 6 | 18 | 7 | 21 | 15.1 | +0.55 (2.3) |
| nerf | 30 | 13 | 5 | 2 | 0 | 10 | 18 | 10 | 23 | 13.6 | +0.25 (0.9) |

Nerf v default, the same 30 games: g difference -0.29 (t -0.7), spot A better in 13, worse in 17 (more than 0.05).
How far apart the two sides end (|g|): +0.15 (t 0.7). Game length: -88 s (t -1.6).

## Income and army (each side, mean; a side beaten sooner counts its last minute)

| arm | income 8:00 A / B | 12:00 A / B | 16:00 A / B | army 8:00 A / B | 12:00 A / B | 16:00 A / B | halls 12:00 A / B | 20:00 A / B |
|---|---|---|---|---|---|---|---|---|
| default | 9266 / 9211 | 18113 / 17525 | 25221 / 23803 | 1284 / 1188 | 2370 / 1667 | 2699 / 2596 | 3.9 / 3.9 | 3.9 / 3.8 |
| nerf | 8844 / 8653 | 17682 / 15882 | 22181 / 19602 | 1262 / 1029 | 2231 / 1881 | 2092 / 2047 | 3.9 / 3.8 | 3.9 / 3.8 |

## Spot A v spot B, and player 1 v player 2

| arm | spot A won or led | spot B won or led | mean g (t) | P1 won or led | P2 won or led | P1 on spot A: A won or led | P2 on spot A: A won or led |
|---|---|---|---|---|---|---|---|
| default | 18 | 7 | +0.55 (2.3) | 13 | 12 | 11 of 18 | 7 of 12 |
| nerf | 18 | 10 | +0.25 (0.9) | 11 | 17 | 9 of 18 | 9 of 12 |

## Every game

| # | map | P1 on | default | min | g | nerf | min | g |
|---|---|---|---|---|---|---|---|---|
| 0 | greenhold | A | w | 20.0 | +0.24 | L | 16.2 | -1.74 |
| 1 | dune_sea | A | = | 20.0 | -0.01 | W | 16.5 | +1.65 |
| 2 | frostfang | A | L | 14.8 | -1.66 | W | 15.8 | +1.65 |
| 3 | ashford_crossing | A | W | 12.6 | +2.11 | W | 12.8 | +1.70 |
| 4 | hollowfen | A | L | 17.9 | -1.38 | W | 11.2 | +1.81 |
| 5 | cinder_steps | A | W | 18.0 | +1.77 | L | 19.6 | -1.40 |
| 6 | greenhold | B | = | 20.0 | -0.04 | w | 20.0 | +0.18 |
| 7 | dune_sea | B | W | 16.7 | +1.52 | W | 16.0 | +1.72 |
| 8 | frostfang | B | L | 19.0 | -1.41 | W | 12.7 | +1.75 |
| 9 | ashford_crossing | B | W | 13.2 | +1.67 | W | 12.9 | +1.60 |
| 10 | hollowfen | B | W | 11.2 | +1.62 | W | 14.1 | +1.55 |
| 11 | cinder_steps | B | W | 19.7 | +1.58 | L | 13.1 | -1.82 |
| 12 | greenhold | A | = | 20.0 | -0.01 | L | 11.5 | -1.55 |
| 13 | dune_sea | A | W | 17.4 | +1.51 | L | 14.8 | -1.59 |
| 14 | frostfang | A | W | 11.8 | +1.62 | L | 14.9 | -1.62 |
| 15 | ashford_crossing | A | W | 15.2 | +1.61 | = | 20.0 | +0.09 |
| 16 | hollowfen | A | W | 18.0 | +1.51 | W | 11.1 | +1.74 |
| 17 | cinder_steps | A | L | 17.9 | -1.53 | W | 12.0 | +1.76 |
| 18 | greenhold | B | = | 20.0 | +0.09 | W | 12.2 | +1.88 |
| 19 | dune_sea | B | w | 20.0 | +0.42 | L | 13.6 | -1.79 |
| 20 | frostfang | B | W | 12.6 | +2.27 | w | 20.0 | +0.14 |
| 21 | ashford_crossing | B | L | 14.1 | -1.55 | = | 20.0 | +0.08 |
| 22 | hollowfen | B | W | 15.1 | +1.43 | w | 20.0 | +0.26 |
| 23 | cinder_steps | B | = | 20.0 | -0.08 | W | 12.3 | +1.85 |
| 24 | greenhold | A | W | 19.4 | +1.64 | w | 20.0 | +0.14 |
| 25 | dune_sea | A | L | 14.5 | -1.64 | w | 20.0 | +0.28 |
| 26 | frostfang | A | W | 10.3 | +1.55 | L | 17.1 | -1.53 |
| 27 | ashford_crossing | A | W | 15.0 | +1.62 | W | 13.9 | +1.90 |
| 28 | hollowfen | A | w | 20.0 | +0.14 | L | 13.7 | -1.64 |
| 29 | cinder_steps | A | l | 20.0 | -0.19 | L | 12.5 | -1.42 |

(W = spot A beat B, w = A 10% ahead at the bell, = even, l = B ahead, L = B beat A)

Spot A against spot B, a sign test on won-or-led: default 18 v 7 (p 0.04), nerf 18 v 10 (p 0.18).

## Findings

1. **The mirror finishes now.** Default: 21 of 30 games decided before 20:00, the median at about 15:00. The wr1000
   brood-mirror baseline (main 0.38.124) had 13 of 30 decided, and 24 of 40 once the Sire wave was kept. The
   ai-opponent-review matrix (0.38.107) had 4 of 12. So the lessons and the micro jobs left the mirror decisive.
2. **The nerf makes games a little shorter and a little more decided.** 23 of 30 decided, the median at 13.6 minutes
   (default 15.1); paired, a game is 88 s shorter on average (t -1.6, not sure). Both sides earn less: about 5% less at
   8:00, 2 to 10% less at 12:00, 12 to 18% less at 16:00, and the armies at 16:00 are about a fifth smaller.
3. **The spot A edge is still there by default, and the nerf softens it.** Default: spot A won or led 18, spot B 7
   (p 0.04), mean g +0.55 (t 2.3). Nerf: 18 against 10 (p 0.18), mean g +0.25 (t 0.9). It follows the spot, not the
   player order: player 1 won or led 13 and player 2 12 by default, and 11 against 17 with the nerf. That matches what
   the brood spot study and wr1000 found: a small lean on spot A that shows in long games.
4. **Same game, different result.** The matches are not deterministic: the same map, seed and spot gives the other side the
   win or the lead in 13 of 30 games between the arms (20 of 30 change result at all), so one game tells little. The paired difference, nerf minus default, is -0.29 for spot A
   (t -0.7; 13 games better for A, 17 worse). That is within the noise. In a mirror the nerf hits both sides alike, and
   these games do not show it favouring either spot.
5. **Halls do not change.** Both sides hold about 3.9 halls at 12:00 and at 20:00 in both arms; the nerf lowers what
   each hall pays, not how many are taken.

No failed games and no script errors in the 60 runs.
