# Tables (tools/study/crown_coach_measure_report.py)

## Results (paired games only: played with the coach on and off)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | coach on | 9 | 0-6-3 | 0 / 8 / 1 | 3 (10:31) |
| Crown v Brood | coach:off | 9 | 0-7-2 | 1 / 7 / 1 | 2 (11:30) |
| Crown v Clockwork | coach on | 9 | 0-9-0 | 0 / 9 / 0 | 0 (-) |
| Crown v Clockwork | coach:off | 9 | 0-9-0 | 0 / 9 / 0 | 0 (-) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (9 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.90 (0.91) | 0.89 (0.89) | 0.80 (0.81) | 0.76 (0.77) | 0.32 (0.41) | 0.50 (0.61) | 0.48 (0.75) | 0.19 (0.21) |
| coach:off | 1.06 (1.08) | 0.85 (0.88) | 0.81 (0.84) | 0.81 (0.85) | 0.71 (0.72) | 0.84 (0.96) | 0.65 (0.97) | 0.74 (1.30) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 1.9 | 1.2 | 4.0 | 4.0 | 25.1 | 41.3 | 31.6 | 50.8 | 1.44 / 0.00 |
| coach:off | 2.0 | 2.1 | 3.6 | 3.9 | 19.2 | 29.3 | 22.6 | 44.3 | 0.67 / 0.00 |

### Crown v Clockwork (9 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.64 (0.64) | 0.64 (0.64) | 0.58 (0.58) | 0.52 (0.52) | 0.69 (0.89) | 0.52 (0.52) | 0.46 (0.57) | 0.19 (0.19) |
| coach:off | 0.63 (0.63) | 0.58 (0.58) | 0.54 (0.54) | 0.49 (0.49) | 0.79 (1.37) | 0.63 (0.67) | 0.48 (0.49) | 0.17 (0.19) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 2.1 | 2.0 | 3.0 | 4.1 | 21.8 | 35.2 | 28.2 | 49.1 | 1.44 / 0.00 |
| coach:off | 1.9 | 2.8 | 3.0 | 4.3 | 18.7 | 29.6 | 27.7 | 47.7 | 0.89 / 0.00 |

## The paired comparison: the same map and seed, coach on v off

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | outcome: on better / off better / same (sign p) | income 8:00 per game: on higher / lower (p) | income 12:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|
| Crown v Brood | 1 / 3 / 5 (0.625) | 4 / 5 (1.000) | 2 / 4 (0.688) | 2 / 7 (0.180) | 2 / 4 (0.688) |
| Crown v Clockwork | 0 / 0 / 9 (1.000) | 7 / 2 (0.180) | 4 / 5 (1.000) | 2 / 7 (0.180) | 5 / 4 (1.000) |

### Game by game

| game | map | on | off | income 8:00 on / off | army 8:00 on / off | Crown halls 12:00 on / off | the Crown's OPTIMAL picks (on) | (off) |
|---|---|---|---|---|---|---|---|---|
| ashfall_crbr_r0 | ashfall | l | l | 0.95 / 1.07 | 0.68 / 1.50 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| border_march_crbr_r0 | border_march | L | l | 0.84 / 0.80 | 0.14 / 0.44 | None / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| dune_sea_crbr_r0 | dune_sea | L | L | 0.80 / 0.63 | 0.03 / 0.48 | None / None | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| frostfang_crbr_r0 | frostfang | l | l | 0.91 / 0.95 | 1.09 / 1.39 | 2 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| greenhold_crbr_r0 | greenhold | = | l | 0.88 / 0.89 | 1.35 / 0.72 | 2 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| highmoor_crbr_r0 | highmoor | l | = | 0.79 / 0.85 | 0.50 / 1.12 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| mirewood_crbr_r0 | mirewood | l | w | 0.98 / 1.09 | 0.57 / 1.66 | 1 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| red_coast_crbr_r0 | red_coast | L | L | 0.92 / 0.73 | 0.19 / 0.83 | None / None | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| twin_fords_crbr_r0 | twin_fords | l | l | 0.90 / 0.86 | 0.97 / 0.53 | 2 / 1 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| ashfall_crcw_r0 | ashfall | l | l | 0.63 / 0.58 | 0.50 / 0.55 | 2 / 3 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| border_march_crcw_r0 | border_march | l | l | 0.55 / 0.57 | 0.43 / 0.39 | 0 / 2 | opening NORMAL -> balloon (raids on its workers) | opening NORMAL -> balloon (raids on its workers) |
| dune_sea_crcw_r0 | dune_sea | l | l | 0.72 / 0.64 | 0.48 / 0.64 | 3 / 2 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| frostfang_crcw_r0 | frostfang | l | l | 0.71 / 0.61 | 0.47 / 0.58 | 3 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| greenhold_crcw_r0 | greenhold | l | l | 0.68 / 0.61 | 0.55 / 0.53 | 1 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| highmoor_crcw_r0 | highmoor | l | l | 0.62 / 0.52 | 0.60 / 0.95 | 2 / 3 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| mirewood_crcw_r0 | mirewood | l | l | 0.68 / 0.54 | 0.31 / 0.69 | 0 / 2 | opening NORMAL -> balloon (raids on its workers) | middle DEFENSIVE -> siege (a siege to b | opening NORMAL -> balloon (raids on its workers) |
| red_coast_crcw_r0 | red_coast | l | l | 0.63 / 0.63 | 0.56 / 0.61 | 4 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| twin_fords_crcw_r0 | twin_fords | l | l | 0.58 / 0.55 | 0.80 / 1.05 | 3 / 1 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |

## Which coach rules fired (coach on; result.json crown_ai, means per game, and games where it fired)

| pairing | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (on) | 30.3 (9) | 48.1 | 0 | 1.7 (6) | 8.0 (4) | 0.6 | 0.6 | 0.4 | 2.0 / 0.4 |
| Crown v Brood (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.1 | 0.1 | 0.0 | 0.7 / 0.1 |
| Crown v Clockwork (on) | 34.4 (9) | 56.8 | 9 | 3.8 (8) | 2.2 (3) | 0.4 | 0.3 | 0.1 | 1.4 / 0.0 |
| Crown v Clockwork (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 1.3 | 0.7 | 0.2 | 2.7 / 0.4 |

## The Crown's OPTIMAL picks

- Crown v Brood, coach on: picks {'balanced': 9}; story mentions a Horseman rush in 0 games
- Crown v Brood, coach:off: picks {'rush': 9}; story mentions a Horseman rush in 9 games
- Crown v Clockwork, coach on: picks {'timing': 7, 'balloon': 2, 'siege': 1}; story mentions a Horseman rush in 0 games
- Crown v Clockwork, coach:off: picks {'timing': 7, 'balloon': 2}; story mentions a Horseman rush in 1 games

Games with errors.txt: on 0, off 0; failed (no result): on 0, off 0.
