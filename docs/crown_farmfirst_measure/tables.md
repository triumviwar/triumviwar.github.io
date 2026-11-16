# Tables (tools/study/farmfirst_report.py)

## In short (paired games only: the same map and seed in both arms)

| pairing | arm | games | W-D-L | won or led / trailed / even | early losses (<6:00) | income 5:00 (ratio) | 8:00 | 12:00 | army 5:00 (ratio) | 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | Farm first (as is) | 38 | 0-33-5 | 4 / 33 / 1 | 0 | 1.00 | 0.91 | 0.77 | 0.45 | 0.55 |
| Crown v Brood | farmfirst:off (old) | 38 | 0-30-8 | 1 / 33 / 4 | 0 | 0.90 | 0.85 | 0.72 | 0.38 | 0.44 |
| Crown v Clockwork | Farm first (as is) | 38 | 0-38-0 | 1 / 36 / 1 | 0 | 0.75 | 0.72 | 0.58 | 0.65 | 0.67 |
| Crown v Clockwork | farmfirst:off (old) | 38 | 0-37-1 | 0 / 38 / 0 | 0 | 0.65 | 0.64 | 0.51 | 0.76 | 0.52 |

## Crown v Brood

### The Crown's income earned (mean) and over the enemy's (ratio of sums, games still running)

| arm | 2:00 | 3:00 | 5:00 | 8:00 | 12:00 | ratio 2:00 | 3:00 | 5:00 | 8:00 | 12:00 | n at 12:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Farm first (as is) | 760 | 1,400 | 3,210 | 8,210 | 14,215 | 1.32 | 1.26 | 1.00 | 0.91 | 0.77 | 33 |
| farmfirst:off (old) | 760 | 1,140 | 2,910 | 7,650 | 13,376 | 1.32 | 1.03 | 0.90 | 0.85 | 0.72 | 30 |

### Army value (the Crown's mean) and over the enemy's

| arm | 3:00 | 5:00 | 8:00 | 12:00 | ratio 3:00 | 5:00 | 8:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| Farm first (as is) | 0 | 129 | 1,022 | 842 | 0.00 | 0.45 | 0.55 | 0.32 |
| farmfirst:off (old) | 0 | 99 | 831 | 850 | 0.00 | 0.38 | 0.44 | 0.28 |

### Workers, halls, the enemy's first attack (Crown side; means)

| arm | 2 Farms by 2:00 | workers 3:00 | 5:00 | 8:00 | halls 5:00 | 8:00 | enemy's first attack (mean, games with one) | Crown halls lost (built) a game | before 6:00 |
|---|---|---|---|---|---|---|---|---|---|
| Farm first (as is) | 38 of 38 | 15.32 | 26.66 | 44.68 | 2.00 | 1.97 | 7:38 (38) | 0.82 | 0 |
| farmfirst:off (old) | 1 of 38 | 13.58 | 24.68 | 43.71 | 2.00 | 1.92 | 7:37 (38) | 1.13 | 0 |

### Paired sign tests (ff better / off better / tie; two-sided p)

| measure | ff better | off better | tie | p |
|---|---|---|---|---|
| result (W > w > = > l > L) | 8 | 5 | 25 | 0.581 |
| income ratio 3:00 | 26 | 0 | 12 | 0.000 |
| income ratio 5:00 | 31 | 6 | 1 | 0.000 |
| income ratio 8:00 | 30 | 8 | 0 | 0.000 |
| income ratio 12:00 | 19 | 10 | 0 | 0.136 |
| army ratio 5:00 | 18 | 11 | 9 | 0.265 |
| army ratio 8:00 | 24 | 14 | 0 | 0.143 |

### Per game (Crown's result, its income ratio at 5:00 and 8:00, early loss *)

| game | Crown slot | ff | off | ff inc 5 / 8 | off inc 5 / 8 | ff pick | off pick |
|---|---|---|---|---|---|---|---|
| amberfall_vale_crbr_r0 | P1 | L 10:47 | L 10:06 | 0.96 / 0.80 | 0.75 / 0.67 | balanced | balanced |
| amberfall_vale_crbr_r1 | P2 | l | l | 0.93 / 0.83 | 0.66 / 0.73 | balanced | balanced |
| ashfall_crbr_r0 | P2 | = | l | 0.98 / 0.97 | 0.97 / 0.97 | balanced | balanced |
| ashfall_crbr_r1 | P1 | w | = | 1.03 / 0.96 | 0.90 / 0.94 | balanced | balanced |
| ashford_crossing_crbr_r0 | P2 | l | l | 1.01 / 1.02 | 1.00 / 0.96 | balanced | balanced |
| ashford_crossing_crbr_r1 | P1 | l | l | 1.00 / 1.04 | 1.03 / 0.95 | balanced | balanced |
| border_march_crbr_r0 | P2 | L 11:18 | L 11:57 | 0.89 / 0.86 | 0.90 / 0.79 | balanced | balanced |
| border_march_crbr_r1 | P1 | L 9:49 | L 11:02 | 1.02 / 0.76 | 0.91 / 0.84 | balanced | balanced |
| cinder_steps_crbr_r0 | P1 | l | l | 1.01 / 0.84 | 0.88 / 0.75 | balanced | balanced |
| cinder_steps_crbr_r1 | P2 | l | l | 1.41 / 0.91 | 1.11 / 0.85 | balanced | balanced |
| dune_sea_crbr_r0 | P1 | w | L 10:08 | 1.01 / 0.98 | 0.93 / 0.86 | balanced | balanced |
| dune_sea_crbr_r1 | P2 | l | l | 0.97 / 0.91 | 0.96 / 0.94 | balanced | balanced |
| frostfang_crbr_r0 | P2 | l | = | 1.01 / 0.96 | 1.01 / 0.92 | balanced | balanced |
| frostfang_crbr_r1 | P1 | l | l | 1.08 / 1.01 | 0.96 / 0.93 | balanced | balanced |
| frostmere_crbr_r0 | P2 | L 10:40 | l | 0.94 / 0.69 | 0.74 / 0.74 | balanced | balanced |
| frostmere_crbr_r1 | P1 | l | l | 1.01 / 0.95 | 1.01 / 0.76 | balanced | balanced |
| glimmerdeep_crbr_r0 | P1 | l | l | 1.00 / 0.73 | 0.87 / 0.79 | balanced | balanced |
| glimmerdeep_crbr_r1 | P2 | l | l | 1.27 / 0.88 | 1.11 / 0.97 | balanced | balanced |
| greenhold_crbr_r0 | P1 | l | = | 0.92 / 0.94 | 0.92 / 0.91 | balanced | balanced |
| greenhold_crbr_r1 | P2 | l | = | 1.02 / 0.96 | 0.91 / 0.88 | balanced | balanced |
| highmoor_crbr_r0 | P2 | l | l | 0.99 / 0.92 | 1.00 / 0.95 | balanced | balanced |
| highmoor_crbr_r1 | P1 | l | l | 1.17 / 1.02 | 1.04 / 0.95 | balanced | balanced |
| hollowfen_crbr_r0 | P2 | l | l | 1.09 / 1.10 | 0.96 / 0.89 | balanced | balanced |
| hollowfen_crbr_r1 | P1 | l | L 11:07 | 0.80 / 0.82 | 0.70 / 0.74 | balanced | balanced |
| kestrel_rise_crbr_r0 | P1 | l | l | 1.27 / 0.95 | 1.17 / 0.80 | balanced | balanced |
| kestrel_rise_crbr_r1 | P2 | w | l | 1.19 / 1.03 | 0.91 / 0.96 | balanced | balanced |
| mirewood_crbr_r0 | P1 | l | l | 0.96 / 0.90 | 0.85 / 0.88 | balanced | balanced |
| mirewood_crbr_r1 | P2 | l | w | 1.07 / 1.05 | 1.07 / 0.96 | balanced | balanced |
| red_coast_crbr_r0 | P1 | l | l | 0.82 / 0.90 | 0.93 / 0.89 | balanced | balanced |
| red_coast_crbr_r1 | P2 | w | l | 1.23 / 1.15 | 1.09 / 1.00 | balanced | balanced |
| redrock_canyon_crbr_r0 | P1 | l | l | 0.89 / 0.81 | 0.85 / 0.67 | balanced | balanced |
| redrock_canyon_crbr_r1 | P2 | l | l | 0.62 / 0.63 | 0.79 / 0.78 | balanced | balanced |
| saltmarsh_isles_crbr_r0 | P2 | l | L 10:32 | 0.87 / 0.89 | 0.76 / 0.70 | balanced | balanced |
| saltmarsh_isles_crbr_r1 | P1 | L 10:56 | L 11:41 | 0.85 / 0.83 | 0.76 / 0.63 | balanced | balanced |
| thornwood_maze_crbr_r0 | P2 | l | L 11:39 | 0.96 / 0.96 | 0.67 / 0.77 | balanced | balanced |
| thornwood_maze_crbr_r1 | P1 | l | l | 0.84 / 0.84 | 0.73 / 0.82 | balanced | balanced |
| twin_fords_crbr_r0 | P1 | l | l | 1.18 / 0.96 | 1.05 / 0.92 | balanced | balanced |
| twin_fords_crbr_r1 | P2 | l | l | 1.08 / 0.96 | 0.95 / 0.94 | balanced | balanced |

## Crown v Clockwork

### The Crown's income earned (mean) and over the enemy's (ratio of sums, games still running)

| arm | 2:00 | 3:00 | 5:00 | 8:00 | 12:00 | ratio 2:00 | 3:00 | 5:00 | 8:00 | 12:00 | n at 12:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Farm first (as is) | 760 | 1,380 | 3,080 | 7,040 | 11,889 | 0.74 | 0.73 | 0.75 | 0.72 | 0.58 | 38 |
| farmfirst:off (old) | 760 | 1,150 | 2,680 | 6,360 | 10,707 | 0.74 | 0.61 | 0.65 | 0.64 | 0.51 | 37 |

### Army value (the Crown's mean) and over the enemy's

| arm | 3:00 | 5:00 | 8:00 | 12:00 | ratio 3:00 | 5:00 | 8:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| Farm first (as is) | 14 | 251 | 1,211 | 1,110 | 0.77 | 0.65 | 0.67 | 0.26 |
| farmfirst:off (old) | 44 | 305 | 1,009 | 1,065 | 2.40 | 0.76 | 0.52 | 0.21 |

### Workers, halls, the enemy's first attack (Crown side; means)

| arm | 2 Farms by 2:00 | workers 3:00 | 5:00 | 8:00 | halls 5:00 | 8:00 | enemy's first attack (mean, games with one) | Crown halls lost (built) a game | before 6:00 |
|---|---|---|---|---|---|---|---|---|---|
| Farm first (as is) | 38 of 38 | 15.61 | 24.03 | 37.76 | 1.74 | 2.29 | 5:37 (36) | 0.79 | 0 |
| farmfirst:off (old) | 1 of 38 | 13.58 | 21.47 | 34.11 | 1.61 | 2.16 | 5:36 (36) | 1.11 | 0 |

### Paired sign tests (ff better / off better / tie; two-sided p)

| measure | ff better | off better | tie | p |
|---|---|---|---|---|
| result (W > w > = > l > L) | 3 | 0 | 35 | 0.250 |
| income ratio 3:00 | 29 | 7 | 2 | 0.000 |
| income ratio 5:00 | 33 | 5 | 0 | 0.000 |
| income ratio 8:00 | 32 | 6 | 0 | 0.000 |
| income ratio 12:00 | 25 | 12 | 0 | 0.047 |
| army ratio 5:00 | 10 | 22 | 6 | 0.050 |
| army ratio 8:00 | 29 | 9 | 0 | 0.002 |

### Per game (Crown's result, its income ratio at 5:00 and 8:00, early loss *)

| game | Crown slot | ff | off | ff inc 5 / 8 | off inc 5 / 8 | ff pick | off pick |
|---|---|---|---|---|---|---|---|
| amberfall_vale_crcw_r0 | P1 | l | l | 0.79 / 0.71 | 0.68 / 0.63 | balloon | balloon |
| amberfall_vale_crcw_r1 | P2 | l | l | 0.88 / 0.84 | 0.60 / 0.63 | balloon | balloon |
| ashfall_crcw_r0 | P2 | l | l | 0.73 / 0.67 | 0.62 / 0.64 | timing | timing |
| ashfall_crcw_r1 | P1 | l | l | 0.79 / 0.68 | 0.70 / 0.66 | balloon | balloon |
| ashford_crossing_crcw_r0 | P2 | l | l | 0.64 / 0.67 | 0.64 / 0.59 | timing | timing |
| ashford_crossing_crcw_r1 | P1 | l | l | 0.80 / 0.87 | 0.63 / 0.78 | timing | timing |
| border_march_crcw_r0 | P2 | l | l | 0.69 / 0.62 | 0.60 / 0.56 | balloon | balloon |
| border_march_crcw_r1 | P1 | l | l | 0.71 / 0.60 | 0.63 / 0.57 | balloon | balloon |
| cinder_steps_crcw_r0 | P1 | l | l | 0.75 / 0.92 | 0.66 / 0.81 | balloon | balloon |
| cinder_steps_crcw_r1 | P2 | l | L 11:56 | 0.72 / 0.57 | 0.62 / 0.52 | balloon | balloon |
| dune_sea_crcw_r0 | P1 | l | l | 0.71 / 0.74 | 0.70 / 0.73 | timing | timing |
| dune_sea_crcw_r1 | P2 | l | l | 0.80 / 0.83 | 0.62 / 0.70 | economy | economy |
| frostfang_crcw_r0 | P2 | l | l | 0.71 / 0.74 | 0.62 / 0.67 | timing | timing |
| frostfang_crcw_r1 | P1 | l | l | 0.66 / 0.59 | 0.68 / 0.57 | balloon | balloon |
| frostmere_crcw_r0 | P2 | l | l | 0.63 / 0.58 | 0.64 / 0.62 | timing | timing |
| frostmere_crcw_r1 | P1 | l | l | 0.80 / 0.74 | 0.62 / 0.56 | timing | timing |
| glimmerdeep_crcw_r0 | P1 | l | l | 0.78 / 0.61 | 0.58 / 0.43 | timing | timing |
| glimmerdeep_crcw_r1 | P2 | l | l | 0.71 / 0.64 | 0.53 / 0.43 | balloon | balloon |
| greenhold_crcw_r0 | P1 | l | l | 0.71 / 0.72 | 0.63 / 0.73 | timing | timing |
| greenhold_crcw_r1 | P2 | l | l | 0.70 / 0.71 | 0.61 / 0.58 | balloon | balloon |
| highmoor_crcw_r0 | P2 | l | l | 0.70 / 0.70 | 0.62 / 0.74 | timing | timing |
| highmoor_crcw_r1 | P1 | l | l | 0.71 / 0.60 | 0.62 / 0.70 | timing | timing |
| hollowfen_crcw_r0 | P2 | l | l | 0.75 / 0.87 | 0.65 / 0.75 | timing | timing |
| hollowfen_crcw_r1 | P1 | l | l | 0.83 / 0.87 | 0.83 / 0.67 | economy | economy |
| kestrel_rise_crcw_r0 | P1 | l | l | 0.81 / 0.73 | 0.72 / 0.77 | economy | economy |
| kestrel_rise_crcw_r1 | P2 | l | l | 0.66 / 0.74 | 0.66 / 0.75 | timing | timing |
| mirewood_crcw_r0 | P1 | l | l | 0.73 / 0.60 | 0.65 / 0.57 | balloon | balloon |
| mirewood_crcw_r1 | P2 | l | l | 0.70 / 0.67 | 0.62 / 0.55 | balloon | balloon |
| red_coast_crcw_r0 | P1 | l | l | 0.74 / 0.66 | 0.64 / 0.56 | timing | timing |
| red_coast_crcw_r1 | P2 | l | l | 0.79 / 0.85 | 0.61 / 0.68 | economy | economy |
| redrock_canyon_crcw_r0 | P1 | = | l | 0.70 / 0.72 | 0.69 / 0.58 | timing | timing |
| redrock_canyon_crcw_r1 | P2 | l | l | 0.62 / 0.62 | 0.62 / 0.59 | timing | timing |
| saltmarsh_isles_crcw_r0 | P2 | w | l | 0.96 / 0.96 | 0.90 / 0.86 | economy | economy |
| saltmarsh_isles_crcw_r1 | P1 | l | l | 0.86 / 0.91 | 0.68 / 0.67 | timing | timing |
| thornwood_maze_crcw_r0 | P2 | l | l | 0.77 / 0.85 | 0.58 / 0.61 | timing | timing |
| thornwood_maze_crcw_r1 | P1 | l | l | 0.94 / 0.67 | 0.73 / 0.64 | economy | economy |
| twin_fords_crcw_r0 | P1 | l | l | 0.70 / 0.64 | 0.64 / 0.55 | timing | timing |
| twin_fords_crcw_r1 | P2 | l | l | 0.86 / 0.86 | 0.61 / 0.63 | economy | economy |

