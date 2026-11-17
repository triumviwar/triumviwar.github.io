# Tables (tools/study/crown_brood_measure_report.py)

## Results (paired games only: played in every arm)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | M as is | 38 | 0-32-6 | 1 / 35 / 2 | 6 (11:02) |
| Crown v Brood | C coach:off | 38 | 0-31-7 | 2 / 33 / 3 | 7 (10:46) |
| Crown v Brood | H honest:off | 38 | 0-33-5 | 5 / 30 / 3 | 5 (11:08) |
| Crown v Brood | F screen/guns off | 38 | 0-31-7 | 1 / 34 / 3 | 7 (10:29) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (38 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| M as is | 1.02 (1.05) | 0.78 (0.80) | 0.70 (0.72) | 0.68 (0.69) | 0.72 (0.81) | 0.68 (0.85) | 0.57 (0.77) | 0.34 (0.50) |
| C coach:off | 1.04 (1.06) | 0.81 (0.84) | 0.76 (0.79) | 0.70 (0.72) | 0.74 (0.79) | 0.73 (0.94) | 0.59 (0.87) | 0.33 (0.58) |
| H honest:off | 1.03 (1.06) | 0.84 (0.87) | 0.80 (0.82) | 0.76 (0.79) | 0.70 (0.80) | 0.84 (1.03) | 0.69 (1.02) | 0.53 (1.74) |
| F screen/guns off | 1.03 (1.06) | 0.78 (0.81) | 0.74 (0.76) | 0.70 (0.71) | 0.73 (0.80) | 0.65 (0.84) | 0.55 (0.68) | 0.26 (0.39) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| M as is | 2.1 | 1.5 | 3.8 | 3.9 | 19.3 | 26.9 | 23.4 | 47.2 | 0.79 / 0.00 |
| C coach:off | 2.0 | 1.6 | 3.7 | 4.0 | 19.3 | 28.1 | 22.8 | 46.2 | 0.89 / 0.00 |
| H honest:off | 2.0 | 1.6 | 3.6 | 3.8 | 19.6 | 30.4 | 22.8 | 46.5 | 0.82 / 0.00 |
| F screen/guns off | 2.0 | 1.4 | 3.6 | 3.9 | 19.5 | 26.7 | 23.3 | 46.4 | 0.92 / 0.00 |

## The paired comparisons: the same map and seed

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | X v Y | outcome: X better / Y better / same (sign p) | income 8:00: X higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|---|
| Crown v Brood | M v C | 6 / 7 / 25 (1.000) | 16 / 22 (0.418) | 16 / 13 (0.711) | 15 / 18 (0.728) | 16 / 22 (0.418) | 11 / 16 (0.442) |
| Crown v Brood | M v H | 6 / 11 / 21 (0.332) | 12 / 26 (0.034) | 8 / 21 (0.024) | 16 / 16 (1.000) | 13 / 25 (0.073) | 8 / 18 (0.076) |
| Crown v Brood | M v F | 5 / 5 / 28 (1.000) | 20 / 18 (0.871) | 11 / 18 (0.265) | 15 / 16 (1.000) | 17 / 21 (0.627) | 15 / 12 (0.701) |

### Game by game

#### Crown v Brood

| game | map | M | C | H | F | income 8:00 M / C / H / F | army 8:00 M / C / H / F | Crown halls 12:00 M / C / H / F | the Crown's OPTIMAL picks (M / C / H / F) |
|---|---|---|---|---|---|---|---|---|---|
| amberfall_vale_crbr_r0 | amberfall_vale | l | L | l | L | 0.64 / 0.66 / 0.82 / 0.58 | 0.56 / 0.09 / 0.64 / 0.00 | 1 / None / 2 / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| amberfall_vale_crbr_r1 | amberfall_vale | l | l | l | l | 0.52 / 0.60 / 0.54 / 0.60 | 0.26 / 0.37 / 0.32 / 0.59 | 0 / 2 / 0 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| ashfall_crbr_r0 | ashfall | = | l | l | l | 0.75 / 0.70 / 0.96 / 0.69 | 1.06 / 0.51 / 1.21 / 1.51 | 2 / 3 / 2 / 1 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashfall_crbr_r1 | ashfall | l | w | L | l | 0.75 / 1.32 / 0.78 / 0.96 | 0.57 / 1.11 / 0.14 / 0.21 | 2 / 3 / None / 0 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r0 | ashford_crossing | l | = | w | l | 0.87 / 0.97 / 0.91 / 0.90 | 0.95 / 0.92 / 0.77 / 0.86 | 3 / 3 / 3 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r1 | ashford_crossing | l | l | l | l | 0.89 / 0.83 / 0.99 / 0.88 | 0.64 / 0.65 / 1.14 / 0.59 | 2 / 1 / 3 / 1 | opening NORMAL -> balanced (a normal game) // opening NORMAL -> balanced (a normal game) // opening NORMAL -> balanced (a normal game) // opening NORMAL -> balanced (a normal game) |
| border_march_crbr_r0 | border_march | l | l | w | l | 1.03 / 0.95 / 1.16 / 0.88 | 2.20 / 0.76 / 1.88 / 0.46 | 2 / 2 / 2 / 1 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| border_march_crbr_r1 | border_march | l | l | w | l | 0.86 / 0.80 / 1.09 / 0.96 | 0.54 / 1.82 / 1.04 / 1.13 | 2 / 0 / 2 / 0 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| cinder_steps_crbr_r0 | cinder_steps | l | l | l | l | 0.92 / 1.18 / 0.91 / 0.97 | 3.71 / 2.35 / 1.40 / 2.56 | 2 / 3 / 1 / 1 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| cinder_steps_crbr_r1 | cinder_steps | l | L | l | l | 0.89 / 0.82 / 0.78 / 1.05 | 0.88 / 0.52 / 0.89 / 1.43 | 1 / None / 0 / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| dune_sea_crbr_r0 | dune_sea | L | L | L | L | 0.49 / 0.60 / 0.61 / 0.58 | 0.04 / 0.43 / 0.21 / 0.04 | None / None / None / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| dune_sea_crbr_r1 | dune_sea | l | l | l | l | 0.85 / 0.93 / 0.96 / 0.87 | 2.05 / 1.45 / 1.35 / 1.19 | 2 / 3 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostfang_crbr_r0 | frostfang | l | l | l | l | 0.94 / 0.89 / 0.77 / 0.87 | 0.91 / 1.88 / 0.94 / 1.11 | 4 / 2 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostfang_crbr_r1 | frostfang | l | l | l | l | 0.88 / 0.84 / 0.86 / 0.87 | 0.73 / 0.74 / 1.75 / 1.00 | 4 / 2 / 3 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostmere_crbr_r0 | frostmere | L | L | l | L | 0.68 / 0.72 / 0.77 / 0.61 | 0.04 / 0.37 / 1.38 / 0.13 | None / None / 1 / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostmere_crbr_r1 | frostmere | l | l | L | L | 0.64 / 0.72 / 0.64 / 0.62 | 0.53 / 0.91 / 0.39 / 0.16 | 0 / 0 / None / None | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| glimmerdeep_crbr_r0 | glimmerdeep | l | l | l | l | 0.65 / 0.69 / 0.86 / 0.89 | 0.52 / 0.49 / 0.83 / 0.66 | 2 / 2 / 1 / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| glimmerdeep_crbr_r1 | glimmerdeep | l | l | w | l | 0.87 / 0.73 / 1.39 / 0.59 | 1.17 / 0.74 / 1.48 / 0.64 | 1 / 1 / 2 / 0 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| greenhold_crbr_r0 | greenhold | l | L | l | = | 0.97 / 0.91 / 0.86 / 0.82 | 0.28 / 0.36 / 0.96 / 0.76 | 2 / None / 0 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| greenhold_crbr_r1 | greenhold | l | = | l | l | 0.69 / 0.92 / 0.85 / 0.71 | 0.50 / 0.68 / 0.77 / 0.46 | 0 / 2 / 0 / 0 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| highmoor_crbr_r0 | highmoor | l | l | = | l | 0.89 / 0.83 / 0.86 / 0.87 | 1.18 / 0.79 / 1.20 / 1.49 | 3 / 2 / 2 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| highmoor_crbr_r1 | highmoor | l | = | l | l | 0.93 / 1.11 / 0.86 / 1.19 | 0.89 / 0.80 / 0.80 / 3.55 | 3 / 3 / 1 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| hollowfen_crbr_r0 | hollowfen | l | l | l | l | 0.90 / 0.84 / 0.87 / 0.78 | 0.52 / 0.60 / 0.84 / 0.61 | 1 / 1 / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| hollowfen_crbr_r1 | hollowfen | L | l | L | L | 0.72 / 0.58 / 0.69 / 0.60 | 0.32 / 0.82 / 0.17 / 0.30 | None / 0 / None / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| kestrel_rise_crbr_r0 | kestrel_rise | = | l | l | = | 1.12 / 1.01 / 0.86 / 0.96 | 0.72 / 0.64 / 0.52 / 0.54 | 3 / 2 / 1 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| kestrel_rise_crbr_r1 | kestrel_rise | l | w | = | w | 1.04 / 1.41 / 1.26 / 1.34 | 1.69 / 1.23 / 2.25 / 0.90 | 2 / 4 / 3 / 3 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| mirewood_crbr_r0 | mirewood | l | l | w | l | 0.96 / 0.70 / 1.01 / 0.79 | 1.10 / 1.65 / 1.38 / 1.26 | 2 / 0 / 3 / 2 | opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| mirewood_crbr_r1 | mirewood | l | l | l | l | 0.84 / 0.97 / 0.97 / 0.83 | 1.03 / 1.56 / 1.30 / 0.80 | 1 / 3 / 1 / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| red_coast_crbr_r0 | red_coast | l | l | l | L | 0.78 / 0.67 / 0.78 / 0.63 | 0.86 / 0.83 / 0.46 / 0.00 | 2 / 2 / 3 / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| red_coast_crbr_r1 | red_coast | w | l | = | l | 0.83 / 0.78 / 0.88 / 0.81 | 0.91 / 1.87 / 0.65 / 0.93 | 2 / 3 / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| redrock_canyon_crbr_r0 | redrock_canyon | l | l | l | l | 0.57 / 0.96 / 0.73 / 0.58 | 0.61 / 0.73 / 0.19 / 0.56 | 0 / 3 / 0 / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| redrock_canyon_crbr_r1 | redrock_canyon | L | L | l | l | 0.58 / 0.61 / 0.64 / 0.62 | 0.43 / 0.07 / 1.57 / 0.36 | None / None / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| saltmarsh_isles_crbr_r0 | saltmarsh_isles | l | l | L | l | 0.72 / 0.72 / 0.59 / 0.68 | 0.74 / 0.97 / 0.15 / 0.75 | 3 / 3 / None / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| saltmarsh_isles_crbr_r1 | saltmarsh_isles | L | l | l | L | 0.58 / 0.70 / 0.97 / 0.68 | 0.07 / 0.53 / 1.02 / 0.20 | None / 0 / 3 / None | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| thornwood_maze_crbr_r0 | thornwood_maze | L | L | l | l | 0.69 / 0.71 / 0.82 / 0.66 | 0.50 / 0.07 / 3.30 / 0.78 | None / None / 3 / 4 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| thornwood_maze_crbr_r1 | thornwood_maze | l | l | l | = | 0.79 / 0.87 / 0.86 / 0.93 | 0.87 / 1.71 / 0.89 / 1.08 | 1 / 3 / 2 / 2 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| twin_fords_crbr_r0 | twin_fords | l | l | l | l | 0.90 / 0.94 / 0.88 / 0.90 | 1.15 / 1.49 / 1.62 / 1.54 | 1 / 2 / 1 / 1 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| twin_fords_crbr_r1 | twin_fords | l | l | l | l | 0.76 / 0.87 / 0.88 / 0.89 | 0.72 / 2.04 / 1.28 / 0.92 | 1 / 1 / 4 / 3 | opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |

## Which coach rules fired (result.json crown_ai, means per game, and games where it fired)

| pairing (arm) | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (M) | 0.0 (0) | 0.0 | 0 | 1.2 (21) | 9.9 (16) | 0.6 | 0.6 | 0.4 | 2.3 / 0.3 |
| Crown v Brood (C) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.2 | 0.3 | 0.1 | 0.4 / 0.1 |
| Crown v Brood (H) | 0.0 (0) | 0.0 | 0 | 1.3 (24) | 4.3 (10) | 0.4 | 0.4 | 0.2 | 1.6 / 0.3 |
| Crown v Brood (F) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.5 | 0.4 | 0.4 | 1.8 / 0.3 |

## Story lines (games with one, and lines in all)

| pairing (arm) | musket line before more buildings (the v-Brood line rule, every arm) | keeps its army on time (the army clock) | forms its musket line | holds its wave | Horseman rush |
|---|---|---|---|---|---|
| Crown v Brood (M) | 296 in 38 | 0 in 0 | 24 in 16 | 9 in 7 | 131 in 37 |
| Crown v Brood (C) | 295 in 38 | 0 in 0 | 6 in 5 | 32 in 18 | 131 in 37 |
| Crown v Brood (H) | 294 in 38 | 0 in 0 | 17 in 10 | 27 in 13 | 129 in 37 |
| Crown v Brood (F) | 293 in 38 | 0 in 0 | 20 in 15 | 15 in 12 | 133 in 37 |

## The Crown's OPTIMAL picks

- Crown v Brood, M as is: picks {'rush': 37, 'balanced': 1}; story mentions a Horseman rush in 37 games
- Crown v Brood, C coach:off: picks {'rush': 37, 'balanced': 1, 'economy': 1}; story mentions a Horseman rush in 37 games
- Crown v Brood, H honest:off: picks {'rush': 37, 'balanced': 1}; story mentions a Horseman rush in 37 games
- Crown v Brood, F screen/guns off: picks {'rush': 37, 'balanced': 1}; story mentions a Horseman rush in 37 games

## The enemy's first arrival in the Crown's base (result.json first_arrival: 300+ army value within 500 px; medians)

| pairing | arm | games with one | when | its army | the Crown's army there | Crown units lost in 90 s | enemy units lost | Crown buildings lost | Crown army 5:00 (abs.) | 8:00 | the Crown's own first attack (games, when) | built Crown halls lost (games with one, first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | M | 30 | 7:55 | 550 | 710 | 9 | 33 | 1 | 360 | 770 | 23, 9:00 | 20, 10:37 |
| Crown v Brood | C | 32 | 8:05 | 587 | 800 | 9 | 27 | 1 | 360 | 835 | 15, 5:35 | 21, 10:30 |
| Crown v Brood | H | 29 | 8:00 | 600 | 830 | 11 | 32 | 1 | 360 | 940 | 17, 6:45 | 19, 10:55 |
| Crown v Brood | F | 30 | 8:00 | 515 | 855 | 14 | 31 | 3 | 360 | 820 | 22, 8:07 | 23, 10:00 |

Games with errors.txt: M 0, C 0, H 0, F 0; failed (no result): M 0, C 0, H 0, F 0.
