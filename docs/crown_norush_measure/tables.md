# Tables (tools/study/crown_norush_measure_report.py)

## Results (paired games only: played in every arm)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | A as is | 38 | 0-37-1 | 4 / 28 / 6 | 1 (11:55) |
| Crown v Brood | N no blind rush | 38 | 0-31-7 | 0 / 33 / 5 | 7 (10:44) |
| Crown v Brood | R rush on true greed only | 38 | 0-35-3 | 0 / 31 / 7 | 3 (10:54) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (38 paired games)

| arm | income 3:00 | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 3:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|---|---|
| A as is | 1.05 (1.05) | 1.04 (1.07) | 0.81 (0.84) | 0.76 (0.79) | 0.69 (0.72) | 0.86 (0.98) | 0.78 (0.88) | 1.01 (1.34) | 0.91 (1.22) | 0.63 (1.08) |
| N no blind rush | 1.03 (1.03) | 0.91 (0.92) | 0.82 (0.82) | 0.75 (0.76) | 0.70 (0.71) | 0.00 (0.00) | 0.75 (0.94) | 0.52 (0.60) | 0.57 (0.83) | 0.42 (0.66) |
| R rush on true greed only | 1.03 (1.03) | 0.99 (1.01) | 0.86 (0.86) | 0.81 (0.82) | 0.74 (0.75) | 0.00 (0.00) | 0.22 (0.31) | 0.58 (0.69) | 0.73 (0.93) | 0.58 (0.81) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| A as is | 2.0 | 2.2 | 3.6 | 3.9 | 19.8 | 30.4 | 23.3 | 47.2 | 0.42 / 0.00 |
| N no blind rush | 1.9 | 1.8 | 4.0 | 4.0 | 24.9 | 42.1 | 31.4 | 52.0 | 1.03 / 0.00 |
| R rush on true greed only | 2.0 | 2.2 | 4.0 | 4.0 | 27.1 | 43.6 | 29.1 | 51.9 | 0.82 / 0.00 |

## The paired comparisons: the same map and seed

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | X v Y | outcome: X better / Y better / same (sign p) | income 8:00: X higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|---|
| Crown v Brood | N v A | 4 / 14 / 20 (0.031) | 21 / 17 (0.627) | 15 / 15 (1.000) | 16 / 20 (0.618) | 5 / 33 (0.000) | 11 / 19 (0.200) |
| Crown v Brood | R v A | 4 / 12 / 22 (0.077) | 23 / 15 (0.256) | 19 / 15 (0.608) | 1 / 36 (0.000) | 7 / 31 (0.000) | 15 / 18 (0.728) |
| Crown v Brood | N v R | 3 / 9 / 26 (0.146) | 14 / 24 (0.143) | 9 / 20 (0.061) | 33 / 3 (0.000) | 19 / 19 (1.000) | 10 / 18 (0.185) |

### Game by game

#### Crown v Brood

| game | map | A | N | R | income 8:00 A / N / R | army 8:00 A / N / R | Crown halls 12:00 A / N / R | the Crown's OPTIMAL picks (A / N / R) |
|---|---|---|---|---|---|---|---|---|
| amberfall_vale_crbr_r0 | amberfall_vale | l | L | l | 0.72 / 0.71 / 0.86 | 1.16 / 0.07 / 0.46 | 2 / None / 4 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| amberfall_vale_crbr_r1 | amberfall_vale | l | l | l | 0.64 / 0.66 / 0.78 | 1.17 / 0.35 / 0.38 | 3 / 0 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| ashfall_crbr_r0 | ashfall | = | = | l | 0.96 / 0.80 / 0.99 | 1.25 / 0.62 / 0.62 | 3 / 4 / 4 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| ashfall_crbr_r1 | ashfall | l | = | L | 0.81 / 0.92 / 0.84 | 1.60 / 0.90 / 0.04 | 2 / 3 / None | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| ashford_crossing_crbr_r0 | ashford_crossing | w | l | = | 0.99 / 0.87 / 0.97 | 1.22 / 0.79 / 0.72 | 3 / 4 / 4 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| ashford_crossing_crbr_r1 | ashford_crossing | l | l | l | 0.93 / 0.87 / 0.93 | 0.92 / 0.83 / 2.18 | 3 / 2 / 4 | opening NORMAL -> balanced (a normal game) | late GREEDY ->  // opening NORMAL -> balanced (a normal game) // opening NORMAL -> balanced (a normal game) |
| border_march_crbr_r0 | border_march | = | L | l | 1.12 / 0.66 / 0.94 | 1.57 / 0.13 / 0.55 | 2 / None / 1 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| border_march_crbr_r1 | border_march | l | L | l | 0.94 / 0.72 / 0.83 | 1.19 / 0.00 / 0.52 | 1 / None / 1 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| cinder_steps_crbr_r0 | cinder_steps | l | l | l | 0.95 / 0.74 / 0.73 | 3.05 / 0.56 / 1.89 | 1 / 0 / 2 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| cinder_steps_crbr_r1 | cinder_steps | l | l | l | 0.98 / 0.93 / 0.80 | 0.76 / 0.54 / 0.77 | 1 / 2 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| dune_sea_crbr_r0 | dune_sea | l | L | l | 0.73 / 0.83 / 0.85 | 0.43 / 0.11 / 0.72 | 0 / None / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| dune_sea_crbr_r1 | dune_sea | = | = | = | 0.74 / 0.82 / 0.97 | 0.92 / 0.69 / 0.58 | 3 / 2 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| frostfang_crbr_r0 | frostfang | l | l | l | 0.89 / 0.86 / 1.03 | 1.11 / 1.16 / 1.28 | 3 / 2 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| frostfang_crbr_r1 | frostfang | l | = | = | 0.78 / 0.99 / 0.98 | 0.66 / 0.62 / 0.93 | 2 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| frostmere_crbr_r0 | frostmere | l | l | l | 0.70 / 0.71 / 0.80 | 0.91 / 0.74 / 0.52 | 1 / 0 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| frostmere_crbr_r1 | frostmere | l | l | l | 0.63 / 0.90 / 0.81 | 0.81 / 0.79 / 0.55 | 1 / 1 / 4 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| glimmerdeep_crbr_r0 | glimmerdeep | l | l | l | 0.73 / 0.78 / 0.79 | 0.82 / 0.41 / 0.83 | 1 / 3 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| glimmerdeep_crbr_r1 | glimmerdeep | = | l | l | 1.04 / 0.86 / 0.89 | 1.48 / 0.54 / 0.85 | 3 / 3 / 2 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| greenhold_crbr_r0 | greenhold | w | l | = | 1.46 / 0.89 / 0.86 | 6.80 / 0.84 / 0.58 | 3 / 3 / 2 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| greenhold_crbr_r1 | greenhold | l | L | = | 0.71 / 0.72 / 1.00 | 0.76 / 0.08 / 0.62 | 3 / None / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| highmoor_crbr_r0 | highmoor | l | = | l | 0.76 / 0.86 / 1.11 | 1.32 / 1.61 / 0.80 | 3 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| highmoor_crbr_r1 | highmoor | w | l | = | 0.89 / 1.01 / 0.92 | 2.24 / 0.76 / 0.57 | 2 / 4 / 4 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| hollowfen_crbr_r0 | hollowfen | l | l | l | 0.89 / 0.86 / 0.89 | 0.85 / 0.49 / 0.47 | 3 / 1 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| hollowfen_crbr_r1 | hollowfen | l | L | L | 0.66 / 0.71 / 0.78 | 1.08 / 0.21 / 0.06 | 0 / None / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| kestrel_rise_crbr_r0 | kestrel_rise | l | l | = | 0.76 / 0.83 / 0.83 | 0.66 / 0.51 / 0.59 | 3 / 2 / 4 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| kestrel_rise_crbr_r1 | kestrel_rise | = | l | l | 1.11 / 0.88 / 0.89 | 1.42 / 0.56 / 0.87 | 3 / 1 / 3 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| mirewood_crbr_r0 | mirewood | w | l | l | 1.03 / 0.84 / 0.89 | 1.27 / 0.62 / 0.68 | 3 / 2 / 3 | opening LEAN -> rush (the matchup) // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| mirewood_crbr_r1 | mirewood | = | l | l | 1.19 / 0.87 / 0.88 | 4.86 / 0.57 / 0.60 | 2 / 2 / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| red_coast_crbr_r0 | red_coast | l | l | l | 0.68 / 0.88 / 0.77 | 0.79 / 0.66 / 1.63 | 3 / 0 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| red_coast_crbr_r1 | red_coast | l | l | l | 0.76 / 1.01 / 0.97 | 0.95 / 1.22 / 0.58 | 3 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| redrock_canyon_crbr_r0 | redrock_canyon | L | l | l | 0.75 / 0.64 / 0.71 | 0.62 / 1.04 / 0.40 | None / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| redrock_canyon_crbr_r1 | redrock_canyon | l | l | l | 0.63 / 0.70 / 0.67 | 0.52 / 0.53 / 0.27 | 2 / 2 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| saltmarsh_isles_crbr_r0 | saltmarsh_isles | l | l | l | 0.66 / 0.80 / 0.77 | 0.90 / 0.88 / 0.73 | 4 / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| saltmarsh_isles_crbr_r1 | saltmarsh_isles | l | L | L | 0.75 / 0.67 / 0.71 | 1.30 / 0.03 / 0.02 | 1 / None / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| thornwood_maze_crbr_r0 | thornwood_maze | l | l | l | 0.66 / 0.78 / 0.80 | 0.87 / 0.78 / 0.72 | 2 / 4 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| thornwood_maze_crbr_r1 | thornwood_maze | l | l | l | 0.79 / 0.83 / 0.78 | 0.58 / 0.56 / 0.44 | 2 / 4 / 4 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| twin_fords_crbr_r0 | twin_fords | l | l | l | 0.83 / 0.93 / 0.92 | 0.75 / 0.42 / 0.48 | 3 / 1 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |
| twin_fords_crbr_r1 | twin_fords | l | l | l | 0.83 / 0.96 / 0.90 | 1.28 / 0.57 / 0.54 | 3 / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> balanced (a normal game) // opening GREEDY -> economy (out-expand it: its early ground i |

## Which coach rules fired (result.json crown_ai, means per game, and games where it fired)

| pairing (arm) | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (A) | 2.4 (19) | 4.0 | 0 | 1.4 (28) | 1.1 (4) | 0.1 | 0.4 | 0.1 | 0.4 / 0.1 |
| Crown v Brood (N) | 1.2 (13) | 1.8 | 0 | 2.5 (29) | 0.4 (2) | 0.1 | 0.3 | 0.1 | 0.5 / 0.1 |
| Crown v Brood (R) | 1.6 (11) | 2.6 | 0 | 2.8 (34) | 0.7 (2) | 0.1 | 0.0 | 0.1 | 0.4 / 0.0 |

## Story lines (games with one, and lines in all)

| pairing (arm) | musket line before more buildings (the v-Brood line rule, every arm) | keeps its army on time (the army clock) | forms its musket line | holds its wave | Horseman rush |
|---|---|---|---|---|---|
| Crown v Brood (A) | 287 in 38 | 0 in 0 | 4 in 4 | 35 in 20 | 125 in 37 |
| Crown v Brood (N) | 291 in 38 | 0 in 0 | 3 in 2 | 41 in 21 | 0 in 0 |
| Crown v Brood (R) | 280 in 38 | 0 in 0 | 2 in 2 | 40 in 25 | 0 in 0 |

## The Crown's OPTIMAL picks

- Crown v Brood, A as is: picks {'rush': 37, 'economy': 2, 'balanced': 1}; story mentions a Horseman rush in 37 games
- Crown v Brood, N no blind rush: picks {'balanced': 38}; story mentions a Horseman rush in 0 games
- Crown v Brood, R rush on true greed only: picks {'economy': 37, 'balanced': 1}; story mentions a Horseman rush in 0 games

## The enemy's first arrival in the Crown's base (result.json first_arrival: 300+ army value within 500 px; medians)

| pairing | arm | games with one | when | its army | the Crown's army there | Crown units lost in 90 s | enemy units lost | Crown buildings lost | Crown army 5:00 (abs.) | 8:00 | the Crown's own first attack (games, when) | built Crown halls lost (games with one, first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | A | 31 | 7:50 | 575 | 1110 | 4 | 35 | 0 | 360 | 1080 | 11, 6:10 | 12, 10:55 |
| Crown v Brood | N | 38 | 8:10 | 900 | 1195 | 10 | 31 | 2 | 240 | 1045 | 6, 10:57 | 22, 10:15 |
| Crown v Brood | R | 38 | 8:25 | 637 | 1635 | 7 | 34 | 1 | 60 | 1200 | 4, 11:00 | 19, 10:45 |

Games with errors.txt: A 0, N 0, R 0; failed (no result): A 0, N 0, R 0.
