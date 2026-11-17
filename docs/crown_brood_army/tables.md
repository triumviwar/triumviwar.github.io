# Tables (tools/study/crown_brood_army_report.py)

## Results (paired games only: played in every arm)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | F as is | 38 | 0-36-2 | 6 / 29 / 3 | 2 (11:21) |
| Crown v Brood | H cbaecon:off | 38 | 0-37-1 | 1 / 33 / 4 | 1 (11:41) |
| Crown v Brood | O cba:off | 38 | 0-35-3 | 3 / 32 / 3 | 3 (11:16) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (38 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| F as is | 1.03 (1.06) | 0.83 (0.85) | 0.79 (0.81) | 0.74 (0.78) | 0.74 (0.88) | 1.07 (1.47) | 0.83 (1.29) | 0.44 (1.43) |
| H cbaecon:off | 1.03 (1.06) | 0.83 (0.85) | 0.77 (0.80) | 0.73 (0.75) | 0.76 (0.83) | 1.14 (1.54) | 0.81 (1.13) | 0.44 (0.67) |
| O cba:off | 1.02 (1.05) | 0.80 (0.82) | 0.76 (0.77) | 0.70 (0.72) | 0.74 (0.82) | 0.81 (1.07) | 0.70 (0.96) | 0.43 (0.80) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| F as is | 2.0 | 1.9 | 3.5 | 3.9 | 19.7 | 31.3 | 23.0 | 46.6 | 0.61 / 0.00 |
| H cbaecon:off | 2.0 | 2.2 | 3.8 | 3.9 | 19.9 | 30.7 | 23.3 | 47.7 | 0.34 / 0.00 |
| O cba:off | 2.0 | 1.6 | 3.7 | 3.9 | 19.6 | 29.0 | 23.1 | 47.5 | 0.66 / 0.00 |

## The paired comparisons: the same map and seed

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | X v Y | outcome: X better / Y better / same (sign p) | income 8:00: X higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|---|
| Crown v Brood | F v O | 7 / 4 / 27 (0.549) | 22 / 16 (0.418) | 19 / 15 (0.608) | 15 / 17 (0.860) | 25 / 13 (0.073) | 15 / 15 (1.000) |
| Crown v Brood | H v O | 5 / 5 / 28 (1.000) | 21 / 17 (0.627) | 19 / 15 (0.608) | 17 / 15 (0.860) | 26 / 12 (0.034) | 18 / 14 (0.597) |
| Crown v Brood | F v H | 9 / 5 / 24 (0.424) | 18 / 20 (0.871) | 21 / 14 (0.311) | 17 / 14 (0.720) | 18 / 20 (0.871) | 18 / 15 (0.728) |

### Game by game

#### Crown v Brood

| game | map | F | H | O | income 8:00 F / H / O | army 8:00 F / H / O | Crown halls 12:00 F / H / O | the Crown's OPTIMAL picks (F / H / O) |
|---|---|---|---|---|---|---|---|---|
| amberfall_vale_crbr_r0 | amberfall_vale | l | l | L | 0.80 / 0.79 / 0.62 | 0.55 / 0.76 / 0.54 | 1 / 2 / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| amberfall_vale_crbr_r1 | amberfall_vale | l | l | l | 0.61 / 0.66 / 0.59 | 0.64 / 0.53 / 0.27 | 3 / 3 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| ashfall_crbr_r0 | ashfall | l | l | l | 0.78 / 0.90 / 0.89 | 1.73 / 1.60 / 2.86 | 2 / 4 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashfall_crbr_r1 | ashfall | l | L | = | 0.85 / 0.71 / 0.97 | 0.89 / 0.90 / 1.09 | 2 / None / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r0 | ashford_crossing | = | = | = | 0.94 / 0.86 / 0.87 | 1.28 / 1.17 / 0.95 | 2 / 3 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r1 | ashford_crossing | l | l | l | 0.92 / 0.92 / 0.89 | 0.53 / 0.50 / 0.64 | 2 / 0 / 2 | opening NORMAL -> balanced (a normal game) // opening NORMAL -> balanced (a normal game) // opening NORMAL -> balanced (a normal game) |
| border_march_crbr_r0 | border_march | l | l | l | 1.24 / 1.11 / 0.98 | 2.13 / 1.54 / 0.63 | 3 / 3 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| border_march_crbr_r1 | border_march | l | l | l | 0.76 / 0.88 / 0.79 | 1.42 / 1.50 / 4.20 | 1 / 3 / 1 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| cinder_steps_crbr_r0 | cinder_steps | w | l | l | 1.10 / 1.00 / 0.90 | 2.23 / 2.58 / 1.24 | 2 / 2 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| cinder_steps_crbr_r1 | cinder_steps | w | l | l | 0.98 / 0.78 / 0.84 | 1.39 / 0.85 / 0.59 | 2 / 2 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| dune_sea_crbr_r0 | dune_sea | L | l | l | 0.61 / 0.68 / 0.73 | 0.48 / 0.97 / 1.18 | None / 2 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| dune_sea_crbr_r1 | dune_sea | l | l | l | 0.87 / 0.88 / 0.91 | 1.98 / 1.58 / 1.51 | 4 / 2 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostfang_crbr_r0 | frostfang | l | l | l | 0.99 / 0.93 / 0.86 | 1.60 / 1.64 / 1.10 | 3 / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostfang_crbr_r1 | frostfang | l | l | l | 0.87 / 0.88 / 0.73 | 1.72 / 1.40 / 0.45 | 3 / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostmere_crbr_r0 | frostmere | l | l | l | 0.87 / 0.72 / 0.88 | 1.49 / 4.15 / 1.33 | 1 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostmere_crbr_r1 | frostmere | l | l | l | 0.63 / 0.65 / 0.56 | 0.90 / 1.62 / 0.82 | 0 / 0 / 0 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| glimmerdeep_crbr_r0 | glimmerdeep | l | l | l | 0.80 / 0.81 / 0.69 | 0.90 / 0.94 / 0.55 | 2 / 3 / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| glimmerdeep_crbr_r1 | glimmerdeep | l | l | l | 0.94 / 0.89 / 0.95 | 1.02 / 4.08 / 0.85 | 2 / 2 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| greenhold_crbr_r0 | greenhold | w | = | w | 1.12 / 1.13 / 0.90 | 1.20 / 1.90 / 0.95 | 2 / 3 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| greenhold_crbr_r1 | greenhold | l | l | l | 0.81 / 0.78 / 0.89 | 1.27 / 1.14 / 1.15 | 3 / 2 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| highmoor_crbr_r0 | highmoor | l | l | = | 1.02 / 0.84 / 0.87 | 2.02 / 1.26 / 2.37 | 3 / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| highmoor_crbr_r1 | highmoor | l | l | l | 0.92 / 0.94 / 1.02 | 1.21 / 0.90 / 0.68 | 3 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| hollowfen_crbr_r0 | hollowfen | = | l | l | 0.89 / 0.84 / 0.77 | 0.81 / 0.56 / 0.34 | 2 / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| hollowfen_crbr_r1 | hollowfen | l | = | L | 0.79 / 0.91 / 0.62 | 3.13 / 3.89 / 0.25 | 3 / 2 / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| kestrel_rise_crbr_r0 | kestrel_rise | l | = | l | 0.91 / 0.93 / 0.88 | 0.79 / 0.64 / 0.49 | 2 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| kestrel_rise_crbr_r1 | kestrel_rise | = | l | w | 1.03 / 1.03 / 1.36 | 1.77 / 1.16 / 2.35 | 2 / 2 / 3 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| mirewood_crbr_r0 | mirewood | w | l | w | 1.03 / 0.90 / 1.10 | 8.00 / 1.80 / 1.08 | 2 / 2 / 2 | opening LEAN -> rush (the matchup) | middle GREEDY -> econom // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| mirewood_crbr_r1 | mirewood | l | w | l | 0.81 / 1.26 / 0.86 | 0.75 / 3.97 / 0.75 | 1 / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| red_coast_crbr_r0 | red_coast | l | l | l | 0.86 / 0.74 / 0.76 | 1.01 / 1.44 / 1.75 | 3 / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| red_coast_crbr_r1 | red_coast | l | l | l | 0.81 / 0.73 / 0.79 | 1.00 / 1.77 / 1.52 | 2 / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| redrock_canyon_crbr_r0 | redrock_canyon | L | l | L | 0.59 / 0.70 / 0.68 | 0.56 / 1.02 / 0.16 | None / 2 / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| redrock_canyon_crbr_r1 | redrock_canyon | l | l | l | 0.61 / 0.67 / 0.68 | 0.82 / 0.68 / 0.94 | 0 / 1 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| saltmarsh_isles_crbr_r0 | saltmarsh_isles | l | l | l | 0.63 / 0.70 / 0.74 | 1.41 / 1.57 / 1.11 | 1 / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| saltmarsh_isles_crbr_r1 | saltmarsh_isles | l | l | l | 0.79 / 0.74 / 0.73 | 0.35 / 0.89 / 0.71 | 0 / 0 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| thornwood_maze_crbr_r0 | thornwood_maze | l | l | l | 0.64 / 0.72 / 0.75 | 0.64 / 0.65 / 1.20 | 3 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| thornwood_maze_crbr_r1 | thornwood_maze | w | l | l | 0.84 / 0.75 / 0.68 | 1.41 / 0.84 / 0.48 | 2 / 0 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| twin_fords_crbr_r0 | twin_fords | w | l | l | 0.94 / 0.99 / 0.89 | 3.63 / 1.00 / 1.05 | 2 / 3 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| twin_fords_crbr_r1 | twin_fords | l | l | l | 0.84 / 0.90 / 0.74 | 1.13 / 2.98 / 0.62 | 0 / 3 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |

## Which coach rules fired (result.json crown_ai, means per game, and games where it fired)

| pairing (arm) | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (F) | 1.1 (10) | 1.4 | 0 | 1.6 (27) | 8.7 (18) | 0.8 | 0.9 | 0.6 | 3.0 / 0.4 |
| Crown v Brood (H) | 0.0 (0) | 0.0 | 0 | 1.7 (32) | 5.7 (15) | 0.6 | 0.8 | 0.4 | 2.6 / 0.3 |
| Crown v Brood (O) | 0.0 (0) | 0.0 | 0 | 1.4 (26) | 8.4 (16) | 0.6 | 0.7 | 0.6 | 2.9 / 0.7 |

## This job's rules (result.json crown_ai vb_*, means per game, and games where it fired)

| arm | Musketeers and guns the floor trained | s it held gold | Barracks it put up | looks asked | s the line was short | counters | thinks the wave waited for the first push | push held (games, median when) |
|---|---|---|---|---|---|---|---|---|
| F as is | 21.9 (38) | 90.7 | 0.9 (24) | 1.1 | 439.5 | 0.0 (0) | 29.3 (21) | 8, 8:36 |
| H cbaecon:off | 20.2 (38) | 83.9 | 0.7 (22) | 1.2 | 440.5 | 0.0 (0) | 48.3 (26) | 13, 9:01 |
| O cba:off | 0.0 (0) | 0.0 | 0.0 (0) | 0.0 | 449.8 | 0.0 (0) | 0.0 (0) | 0, - |

## Story lines (games with one, and lines in all)

| pairing (arm) | musket line before more buildings (the v-Brood line rule, every arm) | the army floor (this job) | the counter (this job) | keeps its army on time (the army clock) | forms its musket line | holds its wave | Horseman rush |
|---|---|---|---|---|---|---|---|
| Crown v Brood (F) | 296 in 38 | 0 in 0 | 0 in 0 | 0 in 0 | 29 in 19 | 10 in 8 | 124 in 37 |
| Crown v Brood (H) | 299 in 38 | 0 in 0 | 0 in 0 | 0 in 0 | 22 in 16 | 13 in 12 | 129 in 37 |
| Crown v Brood (O) | 300 in 38 | 0 in 0 | 0 in 0 | 0 in 0 | 24 in 17 | 6 in 6 | 136 in 37 |

## The Crown's OPTIMAL picks

- Crown v Brood, F as is: picks {'rush': 37, 'balanced': 2, 'economy': 2}; story mentions a Horseman rush in 37 games
- Crown v Brood, H cbaecon:off: picks {'rush': 37, 'balanced': 1}; story mentions a Horseman rush in 37 games
- Crown v Brood, O cba:off: picks {'rush': 37, 'balanced': 1}; story mentions a Horseman rush in 37 games

## The enemy's first arrival in the Crown's base (result.json first_arrival: 300+ army value within 500 px; medians)

| pairing | arm | games with one | when | its army | the Crown's army there | Crown units lost in 90 s | enemy units lost | Crown buildings lost | Crown army 5:00 (abs.) | 8:00 | the Crown's own first attack (games, when) | built Crown halls lost (games with one, first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | F | 28 | 8:15 | 575 | 1110 | 3 | 43 | 0 | 360 | 1080 | 28, 9:17 | 15, 11:10 |
| Crown v Brood | H | 31 | 8:20 | 625 | 1140 | 5 | 40 | 1 | 360 | 1145 | 26, 10:05 | 8, 11:25 |
| Crown v Brood | O | 32 | 8:15 | 595 | 975 | 7 | 39 | 1 | 360 | 825 | 27, 9:05 | 14, 10:57 |

Games with errors.txt: F 0, H 0, O 0; failed (no result): F 0, H 0, O 0.
