# Tables (tools/study/crown_coach_measure_report.py)

## Results (paired games only: played with the coach on and off)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | coach on | 33 | 0-22-11 | 0 / 31 / 2 | 11 (10:57) |
| Crown v Brood | coach:off | 33 | 0-29-4 | 2 / 25 / 6 | 4 (11:31) |
| Crown v Clockwork | coach on | 32 | 0-32-0 | 0 / 32 / 0 | 0 (-) |
| Crown v Clockwork | coach:off | 32 | 0-32-0 | 0 / 32 / 0 | 0 (-) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (33 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.89 (0.90) | 0.85 (0.85) | 0.78 (0.78) | 0.73 (0.74) | 0.33 (0.38) | 0.42 (0.52) | 0.39 (0.59) | 0.19 (0.29) |
| coach:off | 1.04 (1.06) | 0.82 (0.84) | 0.79 (0.81) | 0.73 (0.76) | 0.67 (0.76) | 0.86 (1.10) | 0.80 (1.44) | 0.58 (1.27) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 1.9 | 1.4 | 4.0 | 4.0 | 24.9 | 42.0 | 31.4 | 50.8 | 1.42 / 0.00 |
| coach:off | 2.0 | 2.2 | 3.7 | 3.9 | 19.5 | 29.4 | 23.2 | 47.1 | 0.64 / 0.00 |

### Crown v Clockwork (32 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.64 (0.64) | 0.63 (0.64) | 0.57 (0.57) | 0.51 (0.51) | 0.71 (0.97) | 0.54 (0.56) | 0.47 (0.53) | 0.22 (0.24) |
| coach:off | 0.62 (0.62) | 0.59 (0.59) | 0.53 (0.54) | 0.48 (0.48) | 0.68 (0.94) | 0.58 (0.63) | 0.40 (0.45) | 0.16 (0.19) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 2.1 | 2.2 | 3.0 | 4.1 | 21.5 | 34.8 | 27.8 | 47.2 | 0.97 / 0.00 |
| coach:off | 2.0 | 2.2 | 3.1 | 4.2 | 19.6 | 30.7 | 27.8 | 46.9 | 1.06 / 0.00 |

## The paired comparison: the same map and seed, coach on v off

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | outcome: on better / off better / same (sign p) | income 8:00 per game: on higher / lower (p) | income 12:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|
| Crown v Brood | 2 / 15 / 16 (0.002) | 18 / 15 (0.728) | 10 / 11 (1.000) | 3 / 30 (0.000) | 4 / 17 (0.007) |
| Crown v Clockwork | 0 / 0 / 32 (1.000) | 23 / 9 (0.020) | 16 / 16 (1.000) | 15 / 17 (0.860) | 17 / 15 (0.860) |

### Game by game

| game | map | on | off | income 8:00 on / off | army 8:00 on / off | Crown halls 12:00 on / off | the Crown's OPTIMAL picks (on) | (off) |
|---|---|---|---|---|---|---|---|---|
| amberfall_vale_crbr_r0 | amberfall_vale | L | L | 0.69 / 0.77 | 0.06 / 0.73 | None / None | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| ashfall_crbr_r0 | ashfall | l | l | 0.95 / 1.07 | 0.68 / 1.50 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| ashfall_crbr_r1 | ashfall | L | l | 0.90 / 0.79 | 0.00 / 0.93 | None / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r0 | ashford_crossing | l | l | 0.95 / 0.79 | 0.82 / 1.03 | 3 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| ashford_crossing_crbr_r1 | ashford_crossing | l | = | 1.01 / 0.90 | 0.61 / 0.76 | 2 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| border_march_crbr_r0 | border_march | L | l | 0.84 / 0.80 | 0.14 / 0.44 | None / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| border_march_crbr_r1 | border_march | L | l | 0.72 / 0.86 | 0.13 / 1.02 | None / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| cinder_steps_crbr_r0 | cinder_steps | l | l | 0.76 / 0.98 | 0.22 / 4.40 | 0 / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| dune_sea_crbr_r0 | dune_sea | L | L | 0.80 / 0.63 | 0.03 / 0.48 | None / None | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| dune_sea_crbr_r1 | dune_sea | l | l | 0.89 / 0.81 | 0.50 / 1.21 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| frostfang_crbr_r0 | frostfang | l | l | 0.91 / 0.95 | 1.09 / 1.39 | 2 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| frostfang_crbr_r1 | frostfang | l | l | 0.97 / 0.88 | 0.71 / 1.65 | 3 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| frostmere_crbr_r0 | frostmere | L | l | 0.60 / 0.78 | 0.00 / 1.96 | None / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| glimmerdeep_crbr_r0 | glimmerdeep | l | l | 0.71 / 0.67 | 0.37 / 0.41 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| greenhold_crbr_r0 | greenhold | = | l | 0.88 / 0.89 | 1.35 / 0.72 | 2 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| greenhold_crbr_r1 | greenhold | L | l | 0.70 / 0.86 | 0.09 / 1.00 | None / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| highmoor_crbr_r0 | highmoor | l | = | 0.79 / 0.85 | 0.50 / 1.12 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| highmoor_crbr_r1 | highmoor | l | w | 0.96 / 1.11 | 0.49 / 2.04 | 1 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| hollowfen_crbr_r0 | hollowfen | l | l | 0.82 / 0.67 | 0.50 / 0.57 | 1 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| kestrel_rise_crbr_r0 | kestrel_rise | l | = | 0.97 / 1.28 | 0.66 / 0.79 | 3 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| kestrel_rise_crbr_r1 | kestrel_rise | l | = | 0.84 / 1.04 | 0.50 / 2.24 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| mirewood_crbr_r0 | mirewood | l | w | 0.98 / 1.09 | 0.57 / 1.66 | 1 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| mirewood_crbr_r1 | mirewood | = | = | 0.93 / 0.81 | 2.58 / 0.63 | 3 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| red_coast_crbr_r0 | red_coast | L | L | 0.92 / 0.73 | 0.19 / 0.83 | None / None | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| red_coast_crbr_r1 | red_coast | l | l | 0.96 / 0.88 | 0.83 / 0.92 | 2 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| redrock_canyon_crbr_r0 | redrock_canyon | l | L | 0.70 / 0.65 | 0.31 / 0.43 | 1 / None | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| redrock_canyon_crbr_r1 | redrock_canyon | L | l | 0.70 / 0.55 | 0.05 / 1.08 | None / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| saltmarsh_isles_crbr_r0 | saltmarsh_isles | L | l | 0.78 / 0.82 | 0.54 / 0.59 | None / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| saltmarsh_isles_crbr_r1 | saltmarsh_isles | L | l | 0.82 / 0.70 | 0.18 / 0.34 | None / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| thornwood_maze_crbr_r0 | thornwood_maze | l | l | 0.80 / 0.63 | 0.38 / 0.99 | 0 / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| thornwood_maze_crbr_r1 | thornwood_maze | l | = | 0.91 / 0.96 | 0.48 / 1.06 | 3 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| twin_fords_crbr_r0 | twin_fords | l | l | 0.90 / 0.86 | 0.97 / 0.53 | 2 / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| twin_fords_crbr_r1 | twin_fords | l | l | 0.99 / 0.74 | 0.54 / 0.81 | 2 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| amberfall_vale_crcw_r0 | amberfall_vale | l | l | 0.68 / 0.67 | 0.56 / 0.51 | 1 / 1 | opening NORMAL -> balloon (raids on its workers) | opening NORMAL -> balloon (raids on its workers) |
| ashfall_crcw_r0 | ashfall | l | l | 0.63 / 0.58 | 0.50 / 0.55 | 2 / 3 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| ashfall_crcw_r1 | ashfall | l | l | 0.68 / 0.65 | 0.51 / 1.03 | 2 / 4 | opening NORMAL -> balloon (raids on its workers) | middle DEFENSIVE -> siege (a siege to b | opening NORMAL -> balloon (raids on its workers) |
| ashford_crossing_crcw_r0 | ashford_crossing | l | l | 0.58 / 0.57 | 0.76 / 0.79 | 3 / 0 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| ashford_crossing_crcw_r1 | ashford_crossing | l | l | 0.66 / 0.59 | 0.42 / 0.48 | 2 / 3 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| border_march_crcw_r0 | border_march | l | l | 0.55 / 0.57 | 0.43 / 0.39 | 0 / 2 | opening NORMAL -> balloon (raids on its workers) | opening NORMAL -> balloon (raids on its workers) |
| border_march_crcw_r1 | border_march | l | l | 0.53 / 0.60 | 0.86 / 0.99 | 0 / 2 | opening NORMAL -> balloon (raids on its workers) | opening NORMAL -> balloon (raids on its workers) |
| cinder_steps_crcw_r0 | cinder_steps | l | l | 0.78 / 0.72 | 0.53 / 0.37 | 2 / 1 | opening NORMAL -> balloon (raids on its workers) | late DEFENSIVE -> siege (a siege to bre | opening NORMAL -> balloon (raids on its workers) |
| dune_sea_crcw_r0 | dune_sea | l | l | 0.72 / 0.64 | 0.48 / 0.64 | 3 / 2 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| dune_sea_crcw_r1 | dune_sea | l | l | 0.66 / 0.51 | 0.44 / 0.27 | 2 / 1 | opening NORMAL -> economy (an economic race) | middle AGGRESSIVE -> balanced (defend again | opening NORMAL -> economy (an economic race) |
| frostfang_crcw_r0 | frostfang | l | l | 0.71 / 0.61 | 0.47 / 0.58 | 3 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| frostfang_crcw_r1 | frostfang | l | l | 0.55 / 0.55 | 0.35 / 0.66 | 1 / 3 | opening NORMAL -> balloon (raids on its workers) | opening NORMAL -> balloon (raids on its workers) |
| frostmere_crcw_r0 | frostmere | l | l | 0.62 / 0.52 | 0.88 / 0.60 | 4 / 1 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| glimmerdeep_crcw_r0 | glimmerdeep | l | l | 0.38 / 0.49 | 0.83 / 0.82 | 2 / 0 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| greenhold_crcw_r0 | greenhold | l | l | 0.68 / 0.61 | 0.55 / 0.53 | 1 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| greenhold_crcw_r1 | greenhold | l | l | 0.68 / 0.69 | 0.48 / 1.48 | 2 / 4 | opening NORMAL -> balloon (raids on its workers) | opening NORMAL -> balloon (raids on its workers) |
| highmoor_crcw_r0 | highmoor | l | l | 0.62 / 0.52 | 0.60 / 0.95 | 2 / 3 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| highmoor_crcw_r1 | highmoor | l | l | 0.68 / 0.52 | 0.55 / 0.78 | 4 / 3 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| hollowfen_crcw_r0 | hollowfen | l | l | 0.68 / 0.59 | 0.41 / 0.37 | 3 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| kestrel_rise_crcw_r0 | kestrel_rise | l | l | 0.64 / 0.64 | 0.46 / 0.49 | 2 / 1 | opening NORMAL -> economy (an economic race) | middle AGGRESSIVE -> balanced (defend again | opening NORMAL -> economy (an economic race) | middle AGGRESSIVE -> balanced (defend again |
| kestrel_rise_crcw_r1 | kestrel_rise | l | l | 0.73 / 0.74 | 0.57 / 0.74 | 3 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| mirewood_crcw_r0 | mirewood | l | l | 0.68 / 0.54 | 0.31 / 0.69 | 0 / 2 | opening NORMAL -> balloon (raids on its workers) | middle DEFENSIVE -> siege (a siege to b | opening NORMAL -> balloon (raids on its workers) |
| mirewood_crcw_r1 | mirewood | l | l | 0.54 / 0.53 | 0.82 / 0.52 | 2 / 2 | opening NORMAL -> balloon (raids on its workers) | opening NORMAL -> balloon (raids on its workers) |
| red_coast_crcw_r0 | red_coast | l | l | 0.63 / 0.63 | 0.56 / 0.61 | 4 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| red_coast_crcw_r1 | red_coast | l | l | 0.61 / 0.51 | 0.30 / 0.25 | 2 / 0 | opening NORMAL -> economy (an economic race) | opening NORMAL -> economy (an economic race) |
| redrock_canyon_crcw_r0 | redrock_canyon | l | l | 0.58 / 0.60 | 0.57 / 0.48 | 4 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| redrock_canyon_crcw_r1 | redrock_canyon | l | l | 0.55 / 0.60 | 0.69 / 0.94 | 4 / 1 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| saltmarsh_isles_crcw_r0 | saltmarsh_isles | l | l | 0.93 / 0.81 | 0.64 / 0.32 | 3 / 0 | opening NORMAL -> economy (an economic race) | opening NORMAL -> economy (an economic race) |
| thornwood_maze_crcw_r0 | thornwood_maze | l | l | 0.52 / 0.58 | 0.73 / 0.72 | 1 / 2 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| thornwood_maze_crcw_r1 | thornwood_maze | l | l | 0.64 / 0.55 | 0.16 / 0.15 | 1 / 2 | opening NORMAL -> economy (an economic race) | opening NORMAL -> economy (an economic race) |
| twin_fords_crcw_r0 | twin_fords | l | l | 0.58 / 0.55 | 0.80 / 1.05 | 3 / 1 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| twin_fords_crcw_r1 | twin_fords | l | l | 0.60 / 0.48 | 0.57 / 0.43 | 3 / 2 | opening NORMAL -> economy (an economic race) | opening NORMAL -> economy (an economic race) |

## Which coach rules fired (coach on; result.json crown_ai, means per game, and games where it fired)

| pairing | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (on) | 31.3 (33) | 52.4 | 0 | 2.0 (24) | 4.9 (9) | 0.3 | 0.6 | 0.2 | 1.8 / 0.5 |
| Crown v Brood (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.2 | 0.2 | 0.1 | 0.9 / 0.2 |
| Crown v Clockwork (on) | 31.0 (32) | 50.3 | 23 | 3.4 (29) | 2.3 (8) | 0.5 | 0.4 | 0.1 | 1.7 / 0.1 |
| Crown v Clockwork (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.8 | 0.3 | 0.2 | 1.6 / 0.1 |

## The Crown's OPTIMAL picks

- Crown v Brood, coach on: picks {'balanced': 33}; story mentions a Horseman rush in 0 games
- Crown v Brood, coach:off: picks {'rush': 33}; story mentions a Horseman rush in 33 games
- Crown v Clockwork, coach on: picks {'timing': 17, 'balloon': 9, 'economy': 6, 'siege': 3, 'balanced': 2}; story mentions a Horseman rush in 2 games
- Crown v Clockwork, coach:off: picks {'timing': 17, 'balloon': 9, 'economy': 6, 'balanced': 1}; story mentions a Horseman rush in 2 games

Games with errors.txt: on 0, off 0; failed (no result): on 0, off 0.
