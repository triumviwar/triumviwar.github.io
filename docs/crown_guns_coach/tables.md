# Tables (tools/study/crown_guns_coach_report.py)

## Results (paired games only: played in both arms)

| pairing | arm | games | W-D-L | won or led: Crown / enemy / even | decided (mean length) |
|---|---|---|---|---|---|
| Crown v Clockwork | A as is | 38 | 0-37-1 | 0 / 38 / 0 | 1 (11:35) |
| Crown v Clockwork | C gunscoach:off | 38 | 0-36-2 | 0 / 38 / 0 | 2 (11:03) |
| Crown v Brood | A as is | 38 | 0-34-4 | 2 / 30 / 6 | 4 (10:23) |
| Crown v Brood | C gunscoach:off | 38 | 0-33-5 | 5 / 31 / 2 | 5 (11:05) |

## Economy and army (Crown / enemy): pooled, and in brackets the per-game mean

### Crown v Clockwork (38 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 | built halls lost a game (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| A as is | 0.73 (0.73) | 0.70 (0.70) | 0.63 (0.63) | 0.59 (0.59) | 0.70 (1.07) | 0.62 (0.64) | 0.55 (0.68) | 0.32 (0.38) | 0.53 / 0.00 |
| C gunscoach:off | 0.73 (0.73) | 0.69 (0.69) | 0.61 (0.61) | 0.58 (0.58) | 0.72 (1.19) | 0.67 (0.69) | 0.44 (0.54) | 0.26 (0.30) | 0.74 / 0.03 |

### Crown v Brood (38 paired games)

| arm | income 5:00 | income 8:00 | income 10:00 | income 12:00 | army 5:00 | army 8:00 | army 10:00 | army 12:00 | built halls lost a game (Crown / enemy) |
|---|---|---|---|---|---|---|---|---|---|
| A as is | 1.04 (1.08) | 0.78 (0.81) | 0.74 (0.76) | 0.70 (0.71) | 0.75 (0.96) | 0.73 (1.06) | 0.72 (0.94) | 0.46 (0.66) | 0.68 / 0.00 |
| C gunscoach:off | 1.03 (1.06) | 0.79 (0.82) | 0.76 (0.78) | 0.73 (0.76) | 0.72 (0.78) | 0.72 (0.90) | 0.61 (0.98) | 0.41 (0.80) | 0.79 / 0.00 |

## Paired: the same map and seed (A v C)

| pairing | outcome: A better / C better / same (sign p) | income 8:00: A higher / lower (p) | income 12:00 (p) | army 5:00 (p) | army 8:00 (p) | army 10:00 (p) | army 12:00 (p) |
|---|---|---|---|---|---|---|---|
| Crown v Clockwork | 2 / 1 / 35 (1.000) | 22 / 16 (0.418) | 22 / 13 (0.175) | 13 / 16 (0.711) | 17 / 21 (0.627) | 22 / 16 (0.418) | 16 / 19 (0.736) |
| Crown v Brood | 10 / 8 / 20 (0.815) | 16 / 22 (0.418) | 12 / 19 (0.281) | 18 / 12 (0.362) | 19 / 19 (1.000) | 21 / 14 (0.311) | 14 / 16 (0.856) |

## The Crown's fights (scripts/ai_crown_guns.gd's count)

### Every fight (worth 60 or more)

| pairing | arm | games | fights | begun formed | with a gun near | guns near (sum) | set at contact | fired in the first 10 s | fights where a gun fired in 10 s (of those with a gun near) | killed / lost in them | kills per loss |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Clockwork | A as is | 38 | 113 | 29 (26%) | 71 | 120 | 46 (38%) | 78 (65%) | 49 (69%) | 172010 / 87030 | 1.98 |
| Crown v Clockwork | C gunscoach:off | 38 | 122 | 31 (25%) | 67 | 113 | 17 (15%) | 57 (50%) | 40 (60%) | 138860 / 109975 | 1.26 |
| Crown v Brood | A as is | 38 | 88 | 39 (44%) | 69 | 164 | 54 (33%) | 92 (56%) | 48 (70%) | 123525 / 115295 | 1.07 |
| Crown v Brood | C gunscoach:off | 38 | 89 | 19 (21%) | 63 | 135 | 27 (20%) | 50 (37%) | 33 (52%) | 104335 / 118065 | 0.88 |

### Real fights (worth 300 or more of kills + losses)

| pairing | arm | games | fights | begun formed | with a gun near | guns near (sum) | set at contact | fired in the first 10 s | fights where a gun fired in 10 s (of those with a gun near) | killed / lost in them | kills per loss |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Clockwork | A as is | 38 | 104 | 29 (28%) | 68 | 117 | 45 (38%) | 78 (67%) | 49 (72%) | 171285 / 86320 | 1.98 |
| Crown v Clockwork | C gunscoach:off | 38 | 99 | 26 (26%) | 54 | 97 | 17 (18%) | 53 (55%) | 36 (67%) | 137085 / 108275 | 1.27 |
| Crown v Brood | A as is | 38 | 81 | 38 (47%) | 66 | 152 | 48 (32%) | 90 (59%) | 47 (71%) | 123075 / 114955 | 1.07 |
| Crown v Brood | C gunscoach:off | 38 | 82 | 18 (22%) | 57 | 124 | 25 (20%) | 45 (36%) | 30 (53%) | 103455 / 117650 | 0.88 |

### Real fights out (the wave) and at home

Out:

| pairing | arm | games | fights | begun formed | with a gun near | guns near (sum) | set at contact | fired in the first 10 s | fights where a gun fired in 10 s (of those with a gun near) | killed / lost in them | kills per loss |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Clockwork | A as is | 38 | 32 | 10 (31%) | 20 | 41 | 15 (37%) | 33 (80%) | 15 (75%) | 52935 / 31660 | 1.67 |
| Crown v Clockwork | C gunscoach:off | 38 | 35 | 11 (31%) | 19 | 35 | 9 (26%) | 21 (60%) | 13 (68%) | 45825 / 39450 | 1.16 |
| Crown v Brood | A as is | 38 | 27 | 19 (70%) | 24 | 66 | 21 (32%) | 43 (65%) | 18 (75%) | 43655 / 24785 | 1.76 |
| Crown v Brood | C gunscoach:off | 38 | 29 | 10 (34%) | 22 | 52 | 21 (40%) | 23 (44%) | 13 (59%) | 44575 / 33705 | 1.32 |

At home:

| pairing | arm | games | fights | begun formed | with a gun near | guns near (sum) | set at contact | fired in the first 10 s | fights where a gun fired in 10 s (of those with a gun near) | killed / lost in them | kills per loss |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Clockwork | A as is | 38 | 72 | 19 (26%) | 48 | 76 | 30 (39%) | 45 (59%) | 34 (71%) | 118350 / 54660 | 2.17 |
| Crown v Clockwork | C gunscoach:off | 38 | 64 | 15 (23%) | 35 | 62 | 8 (13%) | 32 (52%) | 23 (66%) | 91260 / 68825 | 1.33 |
| Crown v Brood | A as is | 38 | 54 | 19 (35%) | 42 | 86 | 27 (31%) | 47 (55%) | 29 (69%) | 79420 / 90170 | 0.88 |
| Crown v Brood | C gunscoach:off | 38 | 53 | 8 (15%) | 35 | 72 | 4 (6%) | 22 (31%) | 17 (49%) | 58880 / 83945 | 0.70 |

## The new rules fired (sums over the games; scripts/ai_crown_guns.gd counters)

| pairing | arm | kept | sets | ups | follows | paces | spots | feet | climbs | leaves | def_sets | post_sets | screen sightings | lines formed on the march | met unformed |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Clockwork | A as is | 2358 | 67 | 31 | 14 | 43 | 2 | 1 | 1 | 0 | 2 | 301 | 13 | 31 | 25 |
| Crown v Clockwork | C gunscoach:off | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 20 | 39 | 20 |
| Crown v Brood | A as is | 2949 | 111 | 42 | 58 | 49 | 1 | 1 | 0 | 0 | 4 | 329 | 27 | 33 | 8 |
| Crown v Brood | C gunscoach:off | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 17 | 28 | 29 |

### Game by game

#### Crown v Clockwork

| game | map | A / C | income 8:00 A / C | army 8:00 A / C | army 12:00 A / C | real fights (A / C) | guns fired in 10 s (A / C) |
|---|---|---|---|---|---|---|---|
| amberfall_vale_crcw_r0 | amberfall_vale | l / l | 0.70 / 0.71 | 0.74 / 0.62 | 0.18 / 0.02 | 4 / 2 | 0/0 / 0/0 |
| amberfall_vale_crcw_r1 | amberfall_vale | l / l | 0.84 / 0.84 | 0.70 / 0.76 | 0.24 / 0.19 | 3 / 4 | 0/0 / 0/0 |
| ashfall_crcw_r0 | ashfall | l / l | 0.68 / 0.69 | 0.75 / 0.60 | 0.34 / 0.51 | 3 / 2 | 1/3 / 1/3 |
| ashfall_crcw_r1 | ashfall | l / l | 0.73 / 0.83 | 0.72 / 0.91 | 0.92 / 0.37 | 4 / 5 | 0/4 / 3/4 |
| ashford_crossing_crcw_r0 | ashford_crossing | l / l | 0.53 / 0.55 | 0.58 / 0.86 | 0.39 / 0.04 | 3 / 3 | 8/9 / 2/5 |
| ashford_crossing_crcw_r1 | ashford_crossing | l / l | 0.62 / 0.61 | 0.62 / 0.54 | 0.08 / 0.29 | 2 / 0 | 2/2 / 0/0 |
| border_march_crcw_r0 | border_march | l / l | 0.62 / 0.58 | 0.82 / 0.68 | 0.05 / 0.37 | 2 / 2 | 0/0 / 1/1 |
| border_march_crcw_r1 | border_march | l / l | 0.54 / 0.65 | 0.79 / 0.89 | 0.63 / 0.56 | 4 / 2 | 2/3 / 1/1 |
| cinder_steps_crcw_r0 | cinder_steps | l / l | 0.80 / 0.68 | 0.57 / 0.60 | 0.64 / 0.36 | 3 / 4 | 1/2 / 0/0 |
| cinder_steps_crcw_r1 | cinder_steps | l / L | 0.57 / 0.57 | 0.49 / 0.39 | 0.34 /  | 3 / 1 | 0/1 / 0/0 |
| dune_sea_crcw_r0 | dune_sea | l / l | 0.68 / 0.73 | 0.79 / 0.97 | 0.67 / 0.99 | 5 / 3 | 2/4 / 3/4 |
| dune_sea_crcw_r1 | dune_sea | l / l | 0.80 / 0.80 | 0.44 / 0.72 | 1.01 / 0.01 | 2 / 2 | 4/4 / 1/2 |
| frostfang_crcw_r0 | frostfang | l / l | 0.58 / 0.55 | 0.51 / 0.50 | 0.33 / 0.33 | 2 / 2 | 6/6 / 4/6 |
| frostfang_crcw_r1 | frostfang | l / l | 0.67 / 0.59 | 0.49 / 0.65 | 0.55 / 0.07 | 3 / 3 | 4/4 / 0/1 |
| frostmere_crcw_r0 | frostmere | l / l | 0.64 / 0.60 | 0.44 / 0.71 | 0.08 / 0.13 | 1 / 3 | 0/0 / 0/0 |
| frostmere_crcw_r1 | frostmere | l / l | 0.78 / 0.73 | 0.65 / 0.85 | 0.37 / 0.57 | 4 / 3 | 3/6 / 2/9 |
| glimmerdeep_crcw_r0 | glimmerdeep | l / l | 0.71 / 0.60 | 0.74 / 0.64 | 0.65 / 0.17 | 2 / 2 | 2/4 / 4/5 |
| glimmerdeep_crcw_r1 | glimmerdeep | L / l | 0.62 / 0.58 | 0.23 / 0.62 |  / 0.32 | 1 / 5 | 0/0 / 1/1 |
| greenhold_crcw_r0 | greenhold | l / l | 0.73 / 0.67 | 0.50 / 0.58 | 0.26 / 0.44 | 3 / 2 | 1/3 / 4/4 |
| greenhold_crcw_r1 | greenhold | l / l | 0.66 / 0.62 | 0.48 / 0.60 | 0.15 / 0.30 | 2 / 4 | 1/1 / 1/2 |
| highmoor_crcw_r0 | highmoor | l / l | 0.52 / 0.60 | 0.61 / 0.58 | 0.08 / 0.10 | 3 / 1 | 4/4 / 2/2 |
| highmoor_crcw_r1 | highmoor | l / l | 0.60 / 0.59 | 0.53 / 0.63 | 0.30 / 0.31 | 3 / 4 | 5/6 / 4/6 |
| hollowfen_crcw_r0 | hollowfen | l / l | 0.69 / 0.74 | 0.52 / 0.52 | 0.37 / 0.01 | 1 / 1 | 2/2 / 1/1 |
| hollowfen_crcw_r1 | hollowfen | l / l | 0.81 / 0.86 | 0.18 / 1.29 | 0.08 / 0.23 | 3 / 4 | 0/1 / 2/3 |
| kestrel_rise_crcw_r0 | kestrel_rise | l / l | 0.81 / 0.85 | 0.94 / 1.04 | 0.30 / 0.19 | 4 / 2 | 1/5 / 2/3 |
| kestrel_rise_crcw_r1 | kestrel_rise | l / l | 0.68 / 0.69 | 0.67 / 0.62 | 0.78 / 0.53 | 2 / 2 | 6/6 / 2/2 |
| mirewood_crcw_r0 | mirewood | l / L | 0.65 / 0.59 | 0.61 / 0.46 | 0.54 /  | 3 / 2 | 4/5 / 0/0 |
| mirewood_crcw_r1 | mirewood | l / l | 0.71 / 0.62 | 0.57 / 0.77 | 0.21 / 0.19 | 3 / 4 | 2/2 / 1/2 |
| red_coast_crcw_r0 | red_coast | l / l | 0.75 / 0.74 | 0.74 / 0.82 | 0.31 / 0.47 | 3 / 3 | 1/4 / 5/6 |
| red_coast_crcw_r1 | red_coast | l / l | 0.87 / 0.73 | 1.09 / 0.16 | 0.83 / 0.01 | 5 / 1 | 2/2 / 0/0 |
| redrock_canyon_crcw_r0 | redrock_canyon | l / l | 0.68 / 0.65 | 0.78 / 0.73 | 0.40 / 0.61 | 3 / 3 | 2/4 / 2/5 |
| redrock_canyon_crcw_r1 | redrock_canyon | l / l | 0.64 / 0.64 | 1.11 / 0.32 | 0.11 / 0.20 | 4 / 4 | 4/5 / 1/3 |
| saltmarsh_isles_crcw_r0 | saltmarsh_isles | l / l | 0.94 / 0.89 | 0.87 / 0.77 | 0.38 / 0.48 | 2 / 2 | 1/2 / 2/4 |
| saltmarsh_isles_crcw_r1 | saltmarsh_isles | l / l | 0.78 / 0.80 | 0.70 / 0.78 | 0.39 / 0.40 | 0 / 2 | 0/0 / 0/2 |
| thornwood_maze_crcw_r0 | thornwood_maze | l / l | 0.79 / 0.80 | 0.91 / 0.81 | 0.43 / 0.39 | 2 / 2 | 0/1 / 0/2 |
| thornwood_maze_crcw_r1 | thornwood_maze | l / l | 0.67 / 0.77 | 0.16 / 1.07 | 0.00 / 0.11 | 1 / 3 | 0/0 / 0/0 |
| twin_fords_crcw_r0 | twin_fords | l / l | 0.65 / 0.64 | 0.78 / 0.94 | 0.16 / 0.37 | 2 / 3 | 2/4 / 1/8 |
| twin_fords_crcw_r1 | twin_fords | l / l | 0.81 / 0.82 | 0.51 / 0.35 | 0.54 / 0.07 | 4 / 2 | 5/8 / 0/0 |

#### Crown v Brood

| game | map | A / C | income 8:00 A / C | army 8:00 A / C | army 12:00 A / C | real fights (A / C) | guns fired in 10 s (A / C) |
|---|---|---|---|---|---|---|---|
| amberfall_vale_crbr_r0 | amberfall_vale | l / l | 0.65 / 0.68 | 0.44 / 0.37 | 0.00 / 0.00 | 3 / 2 | 1/3 / 0/2 |
| amberfall_vale_crbr_r1 | amberfall_vale | l / l | 0.63 / 0.59 | 0.57 / 0.47 | 0.65 / 0.55 | 1 / 1 | 3/4 / 1/4 |
| ashfall_crbr_r0 | ashfall | l / = | 0.89 / 0.92 | 3.69 / 1.48 | 0.65 / 0.87 | 1 / 1 | 0/2 / 0/3 |
| ashfall_crbr_r1 | ashfall | = / l | 0.83 / 0.93 | 0.86 / 0.73 | 1.31 / 0.46 | 3 / 3 | 9/9 / 5/7 |
| ashford_crossing_crbr_r0 | ashford_crossing | l / w | 0.94 / 0.92 | 1.09 / 0.87 | 1.06 / 3.13 | 2 / 2 | 5/6 / 4/6 |
| ashford_crossing_crbr_r1 | ashford_crossing | l / l | 0.86 / 0.82 | 4.65 / 1.77 | 0.73 / 0.17 | 4 / 3 | 7/9 / 2/7 |
| border_march_crbr_r0 | border_march | l / l | 1.10 / 1.53 | 1.37 / 0.97 | 0.54 / 0.57 | 2 / 1 | 2/3 / 0/4 |
| border_march_crbr_r1 | border_march | l / w | 0.93 / 0.97 | 0.36 / 2.35 | 0.48 / 6.95 | 2 / 2 | 2/4 / 0/0 |
| cinder_steps_crbr_r0 | cinder_steps | w / w | 1.24 / 0.84 | 2.05 / 1.85 | 1.50 / 2.10 | 1 / 1 | 0/3 / 0/1 |
| cinder_steps_crbr_r1 | cinder_steps | l / l | 0.73 / 0.85 | 0.68 / 0.76 | 0.06 / 0.10 | 2 / 2 | 2/4 / 0/2 |
| dune_sea_crbr_r0 | dune_sea | l / L | 0.77 / 0.66 | 0.90 / 0.74 | 0.00 /  | 4 / 2 | 4/5 / 2/4 |
| dune_sea_crbr_r1 | dune_sea | l / l | 0.84 / 0.87 | 0.83 / 0.98 | 0.25 / 0.88 | 2 / 2 | 4/4 / 3/4 |
| frostfang_crbr_r0 | frostfang | l / l | 0.73 / 0.85 | 0.85 / 1.73 | 0.00 / 0.74 | 2 / 1 | 0/2 / 2/2 |
| frostfang_crbr_r1 | frostfang | l / l | 0.82 / 0.86 | 0.81 / 0.83 | 0.06 / 0.08 | 2 / 4 | 4/5 / 3/6 |
| frostmere_crbr_r0 | frostmere | l / L | 0.64 / 0.74 | 0.14 / 0.22 | 0.00 /  | 3 / 3 | 0/1 / 0/1 |
| frostmere_crbr_r1 | frostmere | l / L | 0.61 / 0.58 | 0.42 / 0.54 | 0.00 /  | 1 / 2 | 0/1 / 1/2 |
| glimmerdeep_crbr_r0 | glimmerdeep | l / l | 0.69 / 0.69 | 0.44 / 0.98 | 0.06 / 0.03 | 1 / 2 | 1/1 / 0/3 |
| glimmerdeep_crbr_r1 | glimmerdeep | = / l | 1.01 / 0.76 | 1.24 / 0.70 | 1.22 / 0.00 | 2 / 3 | 4/8 / 0/0 |
| greenhold_crbr_r0 | greenhold | = / l | 0.87 / 0.92 | 0.62 / 0.79 | 1.36 / 0.35 | 2 / 3 | 2/4 / 2/8 |
| greenhold_crbr_r1 | greenhold | l / l | 0.79 / 0.66 | 0.56 / 0.39 | 0.81 / 0.00 | 2 / 5 | 2/2 / 1/1 |
| highmoor_crbr_r0 | highmoor | = / l | 0.76 / 0.83 | 0.76 / 1.59 | 1.45 / 0.21 | 1 / 2 | 0/3 / 2/5 |
| highmoor_crbr_r1 | highmoor | l / w | 0.98 / 1.20 | 0.62 / 1.17 | 0.28 / 0.78 | 2 / 2 | 1/4 / 0/2 |
| hollowfen_crbr_r0 | hollowfen | l / l | 0.73 / 0.82 | 0.44 / 0.57 | 0.26 / 0.00 | 3 / 1 | 6/6 / 0/3 |
| hollowfen_crbr_r1 | hollowfen | l / l | 0.69 / 0.92 | 1.25 / 0.67 | 0.03 / 0.77 | 2 / 2 | 0/0 / 0/2 |
| kestrel_rise_crbr_r0 | kestrel_rise | = / l | 0.95 / 0.97 | 0.84 / 0.83 | 1.02 / 0.11 | 2 / 1 | 6/6 / 1/3 |
| kestrel_rise_crbr_r1 | kestrel_rise | l / = | 1.07 / 1.12 | 1.56 / 2.19 | 0.82 / 1.29 | 2 / 2 | 0/5 / 1/6 |
| mirewood_crbr_r0 | mirewood | l / l | 0.70 / 0.78 | 1.17 / 1.18 | 0.04 / 0.67 | 1 / 1 | 0/5 / 0/4 |
| mirewood_crbr_r1 | mirewood | w / l | 1.11 / 0.82 | 3.62 / 0.54 | 4.59 / 0.06 | 3 / 2 | 4/7 / 0/4 |
| red_coast_crbr_r0 | red_coast | l / l | 0.73 / 0.69 | 0.99 / 1.51 | 0.02 / 0.58 | 3 / 3 | 5/6 / 3/5 |
| red_coast_crbr_r1 | red_coast | = / l | 0.83 / 0.69 | 1.25 / 1.30 | 0.94 / 0.44 | 4 / 2 | 3/7 / 4/5 |
| redrock_canyon_crbr_r0 | redrock_canyon | L / l | 0.62 / 0.60 | 0.36 / 0.25 |  / 0.00 | 1 / 2 | 1/1 / 2/2 |
| redrock_canyon_crbr_r1 | redrock_canyon | L / L | 0.57 / 0.53 | 0.17 / 0.16 |  /  | 1 / 1 | 1/1 / 0/1 |
| saltmarsh_isles_crbr_r0 | saltmarsh_isles | l / l | 0.62 / 0.80 | 1.77 / 0.41 | 0.04 / 0.00 | 5 / 1 | 3/7 / 0/1 |
| saltmarsh_isles_crbr_r1 | saltmarsh_isles | L / L | 0.66 / 0.73 | 0.12 / 0.15 |  /  | 2 / 4 | 1/1 / 0/1 |
| thornwood_maze_crbr_r0 | thornwood_maze | L / l | 0.61 / 0.68 | 0.16 / 0.20 |  / 0.00 | 1 / 2 | 0/0 / 2/2 |
| thornwood_maze_crbr_r1 | thornwood_maze | l / w | 0.84 / 0.77 | 0.95 / 0.91 | 1.60 / 3.75 | 2 / 3 | 1/2 / 3/4 |
| twin_fords_crbr_r0 | twin_fords | l / l | 0.87 / 0.75 | 0.46 / 0.50 | 0.11 / 0.68 | 2 / 4 | 5/5 / 1/4 |
| twin_fords_crbr_r1 | twin_fords | l / l | 0.88 / 0.75 | 1.05 / 0.59 | 0.50 / 0.00 | 2 / 2 | 1/6 / 0/3 |

