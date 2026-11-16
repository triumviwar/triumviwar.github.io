# Tables (tools/study/crown_coach_measure_2_report.py)

## Results (paired games only: played in every arm)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | A as is | 38 | 0-29-9 | 0 / 36 / 2 | 9 (11:07) |
| Crown v Brood | B norush:off | 38 | 0-29-9 | 0 / 35 / 3 | 9 (10:58) |
| Crown v Brood | C coach:off | 38 | 0-34-4 | 0 / 31 / 7 | 4 (10:26) |
| Crown v Clockwork | A as is | 38 | 0-38-0 | 0 / 36 / 2 | 0 (-) |
| Crown v Clockwork | C coach:off | 38 | 0-36-2 | 0 / 38 / 0 | 2 (11:34) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (38 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| A as is | 1.00 (1.02) | 0.85 (0.86) | 0.80 (0.80) | 0.75 (0.76) | 0.43 (0.53) | 0.54 (0.60) | 0.50 (0.87) | 0.35 (0.55) |
| B norush:off | 1.07 (1.11) | 0.93 (0.94) | 0.79 (0.80) | 0.72 (0.73) | 0.53 (0.60) | 0.43 (0.61) | 0.31 (0.61) | 0.19 (0.37) |
| C coach:off | 1.06 (1.08) | 0.80 (0.82) | 0.74 (0.76) | 0.68 (0.69) | 0.69 (0.77) | 0.75 (0.99) | 0.66 (0.92) | 0.39 (0.62) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| A as is | 1.9 | 1.5 | 4.0 | 3.9 | 25.5 | 40.7 | 31.5 | 51.9 | 1.00 / 0.00 |
| B norush:off | 2.2 | 1.4 | 3.9 | 4.0 | 22.9 | 38.5 | 25.9 | 49.7 | 1.21 / 0.00 |
| C coach:off | 2.0 | 1.8 | 3.7 | 3.9 | 19.3 | 28.4 | 23.4 | 47.3 | 0.76 / 0.00 |

### Crown v Clockwork (38 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| A as is | 0.73 (0.73) | 0.68 (0.69) | 0.62 (0.62) | 0.58 (0.59) | 0.69 (0.96) | 0.71 (0.76) | 0.58 (0.70) | 0.32 (0.41) |
| C coach:off | 0.64 (0.64) | 0.57 (0.57) | 0.52 (0.52) | 0.48 (0.48) | 0.69 (0.99) | 0.55 (0.57) | 0.42 (0.48) | 0.20 (0.22) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| A as is | 2.1 | 2.7 | 3.0 | 4.0 | 21.5 | 34.2 | 27.0 | 45.7 | 0.74 / 0.03 |
| C coach:off | 1.9 | 2.0 | 3.1 | 4.1 | 19.3 | 29.3 | 27.4 | 47.2 | 0.74 / 0.00 |

## The paired comparisons: the same map and seed

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | X v Y | outcome: X better / Y better / same (sign p) | income 8:00: X higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|---|
| Crown v Brood | A v C | 3 / 12 / 23 (0.035) | 25 / 13 (0.073) | 16 / 11 (0.442) | 8 / 29 (0.001) | 12 / 26 (0.034) | 14 / 13 (1.000) |
| Crown v Brood | B v C | 3 / 11 / 24 (0.057) | 32 / 6 (0.000) | 19 / 8 (0.052) | 11 / 24 (0.041) | 12 / 26 (0.034) | 10 / 16 (0.327) |
| Crown v Brood | A v B | 10 / 11 / 17 (1.000) | 14 / 24 (0.143) | 10 / 11 (1.000) | 15 / 21 (0.405) | 19 / 19 (1.000) | 13 / 7 (0.263) |
| Crown v Clockwork | A v C | 4 / 0 / 34 (0.125) | 31 / 7 (0.000) | 29 / 7 (0.000) | 17 / 18 (1.000) | 29 / 9 (0.002) | 24 / 12 (0.065) |

### Game by game

#### Crown v Brood

| game | map | A | B | C | income 8:00 A / B / C | army 8:00 A / B / C | Crown halls 12:00 A / B / C | the Crown's OPTIMAL picks (A / B / C) |
|---|---|---|---|---|---|---|---|---|
| amberfall_vale_crbr_r0 | amberfall_vale | L | l | l | 0.67 / 1.01 / 0.61 | 0.00 / 0.22 / 0.61 | None / 1 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| amberfall_vale_crbr_r1 | amberfall_vale | l | l | l | 0.78 / 0.78 / 0.66 | 0.59 / 0.81 / 0.60 | 2 / 0 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| ashfall_crbr_r0 | ashfall | l | l | = | 0.91 / 0.99 / 0.78 | 0.97 / 1.05 / 0.74 | 2 / 3 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashfall_crbr_r1 | ashfall | L | l | l | 0.83 / 0.80 / 0.78 | 0.04 / 1.04 / 1.76 | None / 2 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r0 | ashford_crossing | l | = | = | 1.00 / 0.87 / 0.91 | 0.84 / 1.11 / 0.72 | 2 / 2 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r1 | ashford_crossing | l | = | l | 1.02 / 1.01 / 0.80 | 0.61 / 0.91 / 0.56 | 2 / 2 / 2 | opening NORMAL -> balanced (a normal game) // opening NORMAL -> balanced (a normal game) | late GREEDY ->  // opening NORMAL -> balanced (a normal game) |
| border_march_crbr_r0 | border_march | L | l | l | 0.74 / 1.06 / 1.07 | 0.08 / 1.24 / 1.13 | None / 2 / 0 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| border_march_crbr_r1 | border_march | L | l | l | 0.88 / 1.06 / 0.96 | 0.14 / 0.90 / 1.79 | None / 3 / 0 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) | middle GREEDY -> econom // opening LEAN -> rush (the matchup) |
| cinder_steps_crbr_r0 | cinder_steps | L | l | l | 0.57 / 0.84 / 0.77 | 0.63 / 1.82 / 1.12 | None / 1 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| cinder_steps_crbr_r1 | cinder_steps | l | l | l | 0.91 / 0.97 / 1.06 | 0.48 / 0.00 / 0.93 | 2 / 0 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| dune_sea_crbr_r0 | dune_sea | L | L | l | 0.94 / 0.93 / 0.76 | 0.14 / 0.00 / 0.59 | None / None / 0 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| dune_sea_crbr_r1 | dune_sea | L | l | = | 0.82 / 1.01 / 0.83 | 0.67 / 0.83 / 0.92 | None / 3 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostfang_crbr_r0 | frostfang | l | l | l | 0.95 / 1.08 / 0.83 | 1.17 / 1.98 / 1.21 | 2 / 4 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostfang_crbr_r1 | frostfang | l | L | l | 0.86 / 1.04 / 0.88 | 0.90 / 0.00 / 0.51 | 1 / None / 4 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostmere_crbr_r0 | frostmere | l | l | l | 0.82 / 0.92 / 0.72 | 0.38 / 0.65 / 1.32 | 2 / 3 / 1 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| frostmere_crbr_r1 | frostmere | l | L | l | 0.89 / 0.84 / 0.64 | 0.91 / 0.54 / 0.36 | 0 / None / 0 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| glimmerdeep_crbr_r0 | glimmerdeep | l | l | l | 0.69 / 0.93 / 0.92 | 0.55 / 0.29 / 1.10 | 0 / 1 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| glimmerdeep_crbr_r1 | glimmerdeep | l | l | l | 0.83 / 1.08 / 0.84 | 0.41 / 0.38 / 2.80 | 2 / 3 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| greenhold_crbr_r0 | greenhold | = | l | = | 0.90 / 0.94 / 0.94 | 0.89 / 0.71 / 1.16 | 2 / 2 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| greenhold_crbr_r1 | greenhold | = | l | l | 0.90 / 1.03 / 0.75 | 0.61 / 0.69 / 1.86 | 2 / 2 / 1 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| highmoor_crbr_r0 | highmoor | l | l | = | 0.95 / 1.03 / 0.79 | 0.77 / 1.09 / 1.11 | 2 / 3 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| highmoor_crbr_r1 | highmoor | l | L | l | 1.03 / 1.03 / 0.97 | 0.76 / 0.00 / 1.14 | 2 / None / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| hollowfen_crbr_r0 | hollowfen | l | = | = | 1.01 / 1.13 / 0.87 | 0.67 / 0.76 / 0.51 | 1 / 4 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| hollowfen_crbr_r1 | hollowfen | l | L | L | 0.74 / 0.78 / 0.63 | 0.70 / 0.03 / 0.06 | 2 / None / None | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| kestrel_rise_crbr_r0 | kestrel_rise | l | l | l | 0.94 / 0.94 / 0.93 | 0.78 / 0.33 / 0.53 | 3 / 0 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| kestrel_rise_crbr_r1 | kestrel_rise | l | l | l | 0.99 / 0.95 / 1.11 | 0.94 / 0.30 / 1.18 | 3 / 2 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| mirewood_crbr_r0 | mirewood | l | l | l | 0.91 / 0.83 / 0.82 | 0.47 / 0.63 / 0.91 | 2 / 3 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening LEAN -> rush (the matchup) // opening LEAN -> rush (the matchup) |
| mirewood_crbr_r1 | mirewood | l | l | l | 0.82 / 0.91 / 0.96 | 0.85 / 0.45 / 1.11 | 1 / 0 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| red_coast_crbr_r0 | red_coast | l | L | l | 0.90 / 0.85 / 0.81 | 1.12 / 0.00 / 0.70 | 3 / None / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| red_coast_crbr_r1 | red_coast | l | l | l | 1.05 / 1.03 / 0.74 | 0.57 / 2.17 / 0.93 | 3 / 3 / 1 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| redrock_canyon_crbr_r0 | redrock_canyon | L | l | L | 0.60 / 0.92 / 0.67 | 0.04 / 0.00 / 0.37 | None / 0 / None | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| redrock_canyon_crbr_r1 | redrock_canyon | l | l | l | 0.71 / 0.83 / 0.70 | 0.57 / 0.20 / 0.52 | 2 / 1 / 1 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| saltmarsh_isles_crbr_r0 | saltmarsh_isles | l | L | l | 0.85 / 0.81 / 0.66 | 0.82 / 0.05 / 1.62 | 3 / None / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| saltmarsh_isles_crbr_r1 | saltmarsh_isles | L | l | L | 0.74 / 0.90 / 0.71 | 0.04 / 0.84 / 0.05 | None / 1 / None | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| thornwood_maze_crbr_r0 | thornwood_maze | l | L | L | 0.93 / 0.76 / 0.64 | 1.08 / 0.23 / 0.52 | 3 / None / None | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| thornwood_maze_crbr_r1 | thornwood_maze | l | l | l | 0.68 / 0.88 / 0.68 | 0.66 / 0.33 / 0.31 | 1 / 0 / 3 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| twin_fords_crbr_r0 | twin_fords | l | L | = | 0.91 / 0.97 / 0.95 | 0.44 / 0.00 / 2.89 | 1 / None / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |
| twin_fords_crbr_r1 | twin_fords | l | l | l | 0.91 / 0.85 / 0.84 | 0.63 / 0.78 / 1.22 | 3 / 2 / 2 | opening GREEDY -> balanced (its early ground is its usual op // opening GREEDY -> rush (punish the greed: the Horse Breeder  // opening GREEDY -> rush (punish the greed: the Horse Breeder  |

#### Crown v Clockwork

| game | map | A | C | income 8:00 A / C | army 8:00 A / C | Crown halls 12:00 A / C | the Crown's OPTIMAL picks (A / C) |
|---|---|---|---|---|---|---|---|
| amberfall_vale_crcw_r0 | amberfall_vale | l | l | 0.69 / 0.56 | 0.49 / 0.65 | 4 / 3 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) | late DEFE |
| amberfall_vale_crcw_r1 | amberfall_vale | l | l | 0.93 / 0.54 | 0.82 / 0.48 | 4 / 1 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| ashfall_crcw_r0 | ashfall | l | l | 0.65 / 0.57 | 0.71 / 0.58 | 0 / 3 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| ashfall_crcw_r1 | ashfall | l | l | 0.77 / 0.59 | 0.97 / 0.41 | 4 / 2 | opening NORMAL -> balloon (raids on its workers) | middle DE // opening NORMAL -> balloon (raids on its workers) |
| ashford_crossing_crcw_r0 | ashford_crossing | l | l | 0.55 / 0.52 | 0.55 / 0.65 | 4 / 1 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| ashford_crossing_crcw_r1 | ashford_crossing | l | l | 0.61 / 0.55 | 0.59 / 0.54 | 4 / 3 | opening UNKNOWN -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| border_march_crcw_r0 | border_march | l | l | 0.66 / 0.54 | 0.65 / 0.82 | 1 / 2 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| border_march_crcw_r1 | border_march | l | l | 0.57 / 0.58 | 0.79 / 0.51 | 0 / 1 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| cinder_steps_crcw_r0 | cinder_steps | l | l | 0.80 / 0.67 | 0.92 / 0.44 | 1 / 3 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| cinder_steps_crcw_r1 | cinder_steps | l | L | 0.56 / 0.45 | 1.19 / 0.28 | 3 / None | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| dune_sea_crcw_r0 | dune_sea | l | l | 0.68 / 0.63 | 0.86 / 0.94 | 1 / 3 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| dune_sea_crcw_r1 | dune_sea | l | l | 0.81 / 0.59 | 0.37 / 0.20 | 2 / 0 | opening NORMAL -> economy (an economic race) // opening NORMAL -> economy (an economic race) |
| frostfang_crcw_r0 | frostfang | l | l | 0.63 / 0.55 | 0.70 / 0.90 | 3 / 4 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| frostfang_crcw_r1 | frostfang | l | l | 0.55 / 0.59 | 0.85 / 0.52 | 3 / 2 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| frostmere_crcw_r0 | frostmere | l | l | 0.63 / 0.55 | 0.83 / 0.91 | 2 / 4 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| frostmere_crcw_r1 | frostmere | l | l | 0.58 / 0.54 | 0.77 / 0.67 | 2 / 1 | opening NORMAL -> timing (a timing attack) | late GREEDY ->  // opening NORMAL -> timing (a timing attack) |
| glimmerdeep_crcw_r0 | glimmerdeep | l | l | 0.63 / 0.53 | 0.77 / 0.68 | 2 / 2 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| glimmerdeep_crcw_r1 | glimmerdeep | l | l | 0.54 / 0.61 | 1.13 / 0.68 | 0 / 3 | opening NORMAL -> balloon (raids on its workers) | middle DE // opening NORMAL -> balloon (raids on its workers) |
| greenhold_crcw_r0 | greenhold | l | l | 0.63 / 0.54 | 0.59 / 0.40 | 4 / 2 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| greenhold_crcw_r1 | greenhold | l | l | 0.63 / 0.55 | 0.64 / 0.54 | 4 / 4 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| highmoor_crcw_r0 | highmoor | l | l | 0.63 / 0.60 | 1.13 / 0.69 | 3 / 2 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| highmoor_crcw_r1 | highmoor | l | l | 0.66 / 0.47 | 0.70 / 0.64 | 3 / 1 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| hollowfen_crcw_r0 | hollowfen | l | l | 0.76 / 0.60 | 0.62 / 0.47 | 4 / 2 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| hollowfen_crcw_r1 | hollowfen | l | l | 0.80 / 0.59 | 0.74 / 0.34 | 3 / 0 | opening NORMAL -> economy (an economic race) // opening NORMAL -> economy (an economic race) |
| kestrel_rise_crcw_r0 | kestrel_rise | = | l | 0.89 / 0.65 | 2.26 / 0.47 | 4 / 3 | opening NORMAL -> economy (an economic race) // opening NORMAL -> economy (an economic race) |
| kestrel_rise_crcw_r1 | kestrel_rise | l | l | 0.65 / 0.68 | 0.63 / 0.49 | 4 / 3 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| mirewood_crcw_r0 | mirewood | l | l | 0.64 / 0.65 | 0.53 / 0.92 | 2 / 1 | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| mirewood_crcw_r1 | mirewood | l | L | 0.68 / 0.49 | 0.53 / 0.43 | 3 / None | opening NORMAL -> balloon (raids on its workers) // opening NORMAL -> balloon (raids on its workers) |
| red_coast_crcw_r0 | red_coast | l | l | 0.55 / 0.60 | 0.56 / 0.80 | 4 / 3 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| red_coast_crcw_r1 | red_coast | l | l | 0.81 / 0.50 | 1.08 / 0.30 | 3 / 0 | opening NORMAL -> economy (an economic race) // opening NORMAL -> economy (an economic race) |
| redrock_canyon_crcw_r0 | redrock_canyon | l | l | 0.64 / 0.60 | 0.63 / 0.56 | 4 / 2 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| redrock_canyon_crcw_r1 | redrock_canyon | l | l | 0.64 / 0.47 | 0.72 / 0.61 | 2 / 3 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| saltmarsh_isles_crcw_r0 | saltmarsh_isles | l | l | 0.88 / 0.66 | 0.52 / 0.47 | 4 / 4 | opening NORMAL -> economy (an economic race) // opening NORMAL -> economy (an economic race) |
| saltmarsh_isles_crcw_r1 | saltmarsh_isles | = | l | 0.93 / 0.53 | 0.68 / 0.63 | 3 / 4 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| thornwood_maze_crcw_r0 | thornwood_maze | l | l | 0.69 / 0.62 | 0.77 / 0.68 | 2 / 1 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| thornwood_maze_crcw_r1 | thornwood_maze | l | l | 0.80 / 0.66 | 0.55 / 0.85 | 2 / 2 | opening NORMAL -> economy (an economic race) // opening NORMAL -> economy (an economic race) |
| twin_fords_crcw_r0 | twin_fords | l | l | 0.55 / 0.56 | 0.74 / 0.26 | 4 / 2 | opening NORMAL -> timing (a timing attack) // opening NORMAL -> timing (a timing attack) |
| twin_fords_crcw_r1 | twin_fords | l | l | 0.75 / 0.53 | 0.40 / 0.39 | 0 / 0 | opening NORMAL -> economy (an economic race) // opening NORMAL -> economy (an economic race) | middle AGGRES |

## Which coach rules fired (result.json crown_ai, means per game, and games where it fired)

| pairing (arm) | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (A) | 17.9 (38) | 31.1 | 0 | 3.1 (33) | 3.9 (13) | 0.5 | 1.6 | 0.4 | 3.3 / 0.5 |
| Crown v Brood (B) | 15.8 (38) | 24.4 | 35 | 1.1 (17) | 4.3 (10) | 0.4 | 0.8 | 0.1 | 1.8 / 0.4 |
| Crown v Brood (C) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.0 | 0.0 | 0.0 | 0.2 / 0.0 |
| Crown v Clockwork (A) | 24.7 (38) | 40.8 | 9 | 2.7 (37) | 3.6 (16) | 0.8 | 0.8 | 0.4 | 2.3 / 0.2 |
| Crown v Clockwork (C) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.7 | 0.4 | 0.3 | 1.9 / 0.3 |

## Story lines (games with one, and lines in all)

| pairing (arm) | musket line before more buildings (the v-Brood line rule, every arm) | keeps its army on time (the army clock) | forms its musket line | holds its wave | Horseman rush |
|---|---|---|---|---|---|
| Crown v Brood (A) | 285 in 38 | 0 in 0 | 19 in 13 | 27 in 20 | 0 in 0 |
| Crown v Brood (B) | 290 in 38 | 0 in 0 | 17 in 11 | 2 in 2 | 65 in 24 |
| Crown v Brood (C) | 292 in 38 | 0 in 0 | 1 in 1 | 32 in 17 | 131 in 37 |
| Crown v Clockwork (A) | 0 in 0 | 129 in 38 | 31 in 18 | 3 in 3 | 1 in 1 |
| Crown v Clockwork (C) | 0 in 0 | 131 in 38 | 28 in 18 | 6 in 5 | 5 in 1 |

## The Crown's OPTIMAL picks

- Crown v Brood, A as is: picks {'balanced': 38}; story mentions a Horseman rush in 0 games
- Crown v Brood, B norush:off: picks {'rush': 37, 'economy': 2, 'balanced': 1}; story mentions a Horseman rush in 37 games
- Crown v Brood, C coach:off: picks {'rush': 37, 'balanced': 1}; story mentions a Horseman rush in 37 games
- Crown v Clockwork, A as is: picks {'timing': 19, 'balloon': 13, 'economy': 7, 'siege': 2}; story mentions a Horseman rush in 1 games
- Crown v Clockwork, C coach:off: picks {'timing': 19, 'balloon': 12, 'economy': 7, 'siege': 1, 'balanced': 1}; story mentions a Horseman rush in 1 games

## The enemy's first arrival in the Crown's base (result.json first_arrival: 300+ army value within 500 px; medians)

| pairing | arm | games with one | when | its army | the Crown's army there | Crown units lost in 90 s | enemy units lost | Crown buildings lost | Crown army 5:00 (abs.) | 8:00 | the Crown's own first attack (games, when) | built Crown halls lost (games with one, first at) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | A | 38 | 8:00 | 687 | 1045 | 18 | 39 | 2 | 120 | 1100 | 28, 8:30 | 23, 10:30 |
| Crown v Brood | B | 33 | 8:10 | 575 | 840 | 32 | 26 | 8 | 240 | 770 | 19, 8:15 | 25, 10:05 |
| Crown v Brood | C | 32 | 8:10 | 625 | 955 | 11 | 33 | 2 | 360 | 835 | 7, 5:35 | 19, 10:55 |
| Crown v Clockwork | A | 36 | 6:30 | 560 | 687 | 3 | 11 | 1 | 240 | 1255 | 21, 9:00 | 20, 10:37 |
| Crown v Clockwork | C | 36 | 6:30 | 525 | 550 | 2 | 9 | 2 | 300 | 1060 | 21, 9:30 | 20, 9:52 |

Games with errors.txt: A 0, B 0, C 0; failed (no result): A 0, B 0, C 0.
