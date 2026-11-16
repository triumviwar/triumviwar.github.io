# Tables (tools/study/crown_coach_measure_report.py)

## Results (paired games only: played with the coach on and off)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | coach on | 3 | 0-2-1 | 0 / 2 / 1 | 1 (10:25) |
| Crown v Brood | coach:off | 3 | 0-2-1 | 0 / 2 / 1 | 1 (11:12) |
| Crown v Clockwork | coach on | 3 | 0-3-0 | 0 / 3 / 0 | 0 (-) |
| Crown v Clockwork | coach:off | 3 | 0-3-0 | 0 / 3 / 0 | 0 (-) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (3 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.90 (0.90) | 0.82 (0.82) | 0.81 (0.81) | 0.83 (0.84) | 0.23 (0.41) | 0.49 (0.63) | 0.46 (1.13) | 0.34 (0.43) |
| coach:off | 1.02 (1.02) | 0.77 (0.79) | 0.74 (0.76) | 0.85 (0.85) | 0.64 (0.64) | 0.75 (0.77) | 0.44 (0.64) | 0.80 (0.80) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 2.0 | 1.0 | 4.0 | 4.0 | 24.0 | 37.0 | 31.7 | 47.3 | 1.33 / 0.00 |
| coach:off | 2.0 | 2.5 | 3.3 | 4.0 | 19.3 | 26.3 | 23.0 | 44.0 | 0.67 / 0.00 |

### Crown v Clockwork (3 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.64 (0.64) | 0.67 (0.67) | 0.62 (0.62) | 0.57 (0.57) | 0.78 (0.91) | 0.55 (0.54) | 0.49 (0.49) | 0.26 (0.24) |
| coach:off | 0.64 (0.64) | 0.59 (0.59) | 0.56 (0.56) | 0.46 (0.46) | 0.98 (2.16) | 0.66 (0.71) | 0.44 (0.44) | 0.20 (0.21) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 2.0 | 2.0 | 3.0 | 4.0 | 22.0 | 36.7 | 27.3 | 47.0 | 2.00 / 0.00 |
| coach:off | 2.0 | 3.0 | 3.0 | 4.3 | 18.7 | 30.3 | 27.3 | 45.0 | 0.67 / 0.00 |

## The paired comparison: the same map and seed, coach on v off

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | outcome: on better / off better / same (sign p) | income 8:00 per game: on higher / lower (p) | income 12:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|
| Crown v Brood | 1 / 1 / 1 (1.000) | 1 / 2 (1.000) | 1 / 1 (1.000) | 1 / 2 (1.000) | 1 / 1 (1.000) |
| Crown v Clockwork | 0 / 0 / 3 (1.000) | 3 / 0 (0.250) | 2 / 1 (1.000) | 1 / 2 (1.000) | 2 / 1 (1.000) |

### Game by game

| game | map | on | off | income 8:00 on / off | army 8:00 on / off | Crown halls 12:00 on / off | the Crown's OPTIMAL picks (on) | (off) |
|---|---|---|---|---|---|---|---|---|
| dune_sea_crbr_r0 | dune_sea | L | L | 0.80 / 0.63 | 0.03 / 0.48 | None / None | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| greenhold_crbr_r0 | greenhold | = | l | 0.88 / 0.89 | 1.35 / 0.72 | 2 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| highmoor_crbr_r0 | highmoor | l | = | 0.79 / 0.85 | 0.50 / 1.12 | 0 / 3 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its |
| dune_sea_crcw_r0 | dune_sea | l | l | 0.72 / 0.64 | 0.48 / 0.64 | 3 / 2 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| greenhold_crcw_r0 | greenhold | l | l | 0.68 / 0.61 | 0.55 / 0.53 | 1 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |
| highmoor_crcw_r0 | highmoor | l | l | 0.62 / 0.52 | 0.60 / 0.95 | 2 / 3 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |

## Which coach rules fired (coach on; result.json crown_ai, means per game, and games where it fired)

| pairing | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (on) | 30.0 (3) | 64.8 | 0 | 1.7 (2) | 2.0 (2) | 0.7 | 0.7 | 0.7 | 1.7 / 0.0 |
| Crown v Brood (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.0 | 0.0 | 0.0 | 0.0 / 0.0 |
| Crown v Clockwork (on) | 43.7 (3) | 60.3 | 3 | 5.0 (3) | 0.0 (0) | 0.0 | 0.0 | 0.0 | 0.0 / 0.0 |
| Crown v Clockwork (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.7 | 0.7 | 0.0 | 1.3 / 0.7 |

## The Crown's OPTIMAL picks

- Crown v Brood, coach on: picks {'balanced': 3}; story mentions a Horseman rush in 0 games
- Crown v Brood, coach:off: picks {'rush': 3}; story mentions a Horseman rush in 3 games
- Crown v Clockwork, coach on: picks {'timing': 3}; story mentions a Horseman rush in 0 games
- Crown v Clockwork, coach:off: picks {'timing': 3}; story mentions a Horseman rush in 1 games

Games with errors.txt: on 0, off 0; failed (no result): on 0, off 0.
