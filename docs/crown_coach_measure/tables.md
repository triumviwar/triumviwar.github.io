# Tables (tools/study/crown_coach_measure_report.py)

## Results (paired games only: played with the coach on and off)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Brood | coach on | 1 | 0-1-0 | 0 / 0 / 1 | 0 (-) |
| Crown v Brood | coach:off | 1 | 0-1-0 | 0 / 1 / 0 | 0 (-) |
| Crown v Clockwork | coach on | 1 | 0-1-0 | 0 / 1 / 0 | 0 (-) |
| Crown v Clockwork | coach:off | 1 | 0-1-0 | 0 / 1 / 0 | 0 (-) |

## Economy and army (Crown / enemy): pooled (sum / sum), and in brackets the per-game mean

### Crown v Brood (1 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.87 (0.87) | 0.88 (0.88) | 0.96 (0.96) | 1.01 (1.01) | 0.15 (0.15) | 1.35 (1.35) | 3.03 (3.03) | 0.83 (0.83) |
| coach:off | 1.05 (1.05) | 0.89 (0.89) | 0.82 (0.82) | 0.68 (0.68) | 0.51 (0.51) | 0.72 (0.72) | 1.28 (1.28) | 0.82 (0.82) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 2.0 | 2.0 | 4.0 | 4.0 | 25.0 | 45.0 | 32.0 | 46.0 | 0.00 / 0.00 |
| coach:off | 2.0 | 2.0 | 3.0 | 4.0 | 18.0 | 24.0 | 16.0 | 44.0 | 0.00 / 0.00 |

### Crown v Clockwork (1 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 |
|---|---|---|---|---|---|---|---|---|
| coach on | 0.65 (0.65) | 0.68 (0.68) | 0.59 (0.59) | 0.44 (0.44) | 0.71 (0.71) | 0.55 (0.55) | 0.35 (0.35) | 0.03 (0.03) |
| coach:off | 0.61 (0.61) | 0.61 (0.61) | 0.53 (0.53) | 0.51 (0.51) | 0.71 (0.71) | 0.53 (0.53) | 0.46 (0.46) | 0.34 (0.34) |

| arm | Crown halls 8:00 | 12:00 | enemy halls 8:00 | 12:00 | Crown labourers 5:00 | 8:00 | enemy workers 5:00 | 8:00 | built halls lost (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| coach on | 2.0 | 1.0 | 3.0 | 4.0 | 22.0 | 37.0 | 25.0 | 41.0 | 3.00 / 0.00 |
| coach:off | 2.0 | 4.0 | 3.0 | 5.0 | 19.0 | 31.0 | 29.0 | 44.0 | 0.00 / 0.00 |

## The paired comparison: the same map and seed, coach on v off

Outcome rank: won > led a draw > even draw > trailed a draw > lost. A sign test counts the games where one arm did better.

| pairing | outcome: on better / off better / same (sign p) | income 8:00 per game: on higher / lower (p) | income 12:00 (p) | army 8:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|
| Crown v Brood | 1 / 0 / 0 (1.000) | 0 / 1 (1.000) | 1 / 0 (1.000) | 1 / 0 (1.000) | 1 / 0 (1.000) |
| Crown v Clockwork | 0 / 0 / 1 (1.000) | 1 / 0 (1.000) | 0 / 1 (1.000) | 1 / 0 (1.000) | 0 / 1 (1.000) |

### Game by game

| game | map | on | off | income 8:00 on / off | army 8:00 on / off | Crown halls 12:00 on / off | the Crown's OPTIMAL picks (on) | (off) |
|---|---|---|---|---|---|---|---|---|
| greenhold_crbr_r0 | greenhold | = | l | 0.88 / 0.89 | 1.35 / 0.72 | 2 / 2 | opening GREEDY -> balanced (its early ground is its usual opening: a line and guns, the ec | opening LEAN -> rush (the matchup) |
| greenhold_crcw_r0 | greenhold | l | l | 0.68 / 0.61 | 0.55 / 0.53 | 1 / 4 | opening NORMAL -> timing (a timing attack) | opening NORMAL -> timing (a timing attack) |

## Which coach rules fired (coach on; result.json crown_ai, means per game, and games where it fired)

| pairing | labourers trained by LABOURERS FIRST | s gold held for them | next hall moved up (games) | screen riders trained first | guns set early | lines formed on the march | lines deployed at contact unformed | screen sightings | screen riders sent / lost |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood (on) | 29.0 (1) | 60.7 | 0 | 2.0 (1) | 1.0 (1) | 1.0 | 2.0 | 1.0 | 4.0 / 0.0 |
| Crown v Brood (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.0 | 0.0 | 0.0 | 0.0 / 0.0 |
| Crown v Clockwork (on) | 38.0 (1) | 64.4 | 1 | 2.0 (1) | 0.0 (0) | 0.0 | 0.0 | 0.0 | 0.0 / 0.0 |
| Crown v Clockwork (off) | 0.0 (0) | 0.0 | 0 | 0.0 (0) | 0.0 (0) | 0.0 | 0.0 | 0.0 | 0.0 / 0.0 |

## The Crown's OPTIMAL picks

- Crown v Brood, coach on: picks {'balanced': 1}; story mentions a Horseman rush in 0 games
- Crown v Brood, coach:off: picks {'rush': 1}; story mentions a Horseman rush in 1 games
- Crown v Clockwork, coach on: picks {'timing': 1}; story mentions a Horseman rush in 0 games
- Crown v Clockwork, coach:off: picks {'timing': 1}; story mentions a Horseman rush in 0 games

Games with errors.txt: on 0, off 0; failed (no result): on 0, off 0.
