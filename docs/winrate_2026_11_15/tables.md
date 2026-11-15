# Tables (tools/study/winrate_1115_report.py)

## All pairings, now v 2026-11-12

| pairing (first side's view) | games | W-D-L | won or led: first / second / even | decided (mean length) | spot A v B (won or led) | 2026-11-12 W-D-L | 11-12 won or led | 11-12 decided |
|---|---|---|---|---|---|---|---|---|
| Crown v Brood | 38 | **0-13-25** | 0 / 37 / 1 | 25 (12:15) | 19 v 18 | 0-11-27 | 0 / 36 / 2 | 27 (12:26) |
| Crown v Clockwork | 38 | **0-22-16** | 0 / 38 / 0 | 16 (12:58) | 19 v 19 | 0-30-8 | 5 / 31 / 2 | 8 (13:01) |
| Brood v Brood (P1) | 38 | **17-18-3** | 26 / 9 / 3 | 20 (13:07) | 26 v 9 | 11-25-2 | 23 / 9 / 6 | 13 (12:26) |
| Brood v Clockwork | 38 | **26-6-6** | 29 / 9 / 0 | 32 (12:18) | 20 v 18 | 12-15-11 | 17 / 20 / 1 | 23 (12:28) |

## Crown v Brood

### Economy and army (first side over second; games still running at that minute)

| | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 1.00 | 0.74 | 0.69 | 0.68 | 1.06 | 0.69 | 0.38 | 0.32 |
| 2026-11-12 | 1.02 | 0.79 | 0.71 | 0.71 | 1.12 | 0.59 | 0.44 | 0.34 |

Income PER MINUTE (median, earned in the minute before) and earned by then over the bench (mean of the games / bench, docs/economy_parity.md):

| side | n at 5 | /min 5:00 | 8:00 | 10:00 | 12:00 | earned 5:00 / bench | 8:00 | 10:00 | 2026-11-12 /min 8:00 | 11-12 earned 8:00 / bench |
|---|---|---|---|---|---|---|---|---|---|---|
| crown | 38 | 1,140 | 760 | 1,520 | 380 | 0.68 | 0.57 | 0.58 | 950 | 0.58 |
| brood | 38 | 918 | 1,749 | 1,964 | 2,175 | 0.66 | 0.80 | 0.79 | 1,694 | 0.76 |

Spot A (P1) v B, won or led, now: classic maps A 9 v B 9; named maps A 10 v B 9.

Spot A (P1) v B, won or led, 2026-11-12: classic maps A 9 v B 7; named maps A 10 v B 10.

Halls lost (built) per game, mean: first 1.71, second 0.00 (2026-11-12: 2.13, 0.00). Halls at 8:00 (median): 2.0 v 3.5.

### OPTIMAL's picks (the first side) and how they did

| opening pick (read -> plan) | games | W-D-L | won or led | later switches |
|---|---|---|---|---|
| opening GREEDY -> rush | 27 | 0-10-17 | 0 | middle GREEDY -> economy x1 |
| opening LEAN -> rush | 11 | 0-3-8 | 0 | late GREEDY -> economy x1 |

The second side's opening picks: opening NORMAL -> brute x7; opening AGGRESSIVE -> balanced x6; opening UNKNOWN -> spitter x6; opening NORMAL -> timing x5; opening UNKNOWN -> timing x4; opening UNKNOWN -> balanced x4; opening UNKNOWN -> brute x3; opening NORMAL -> balanced x2; opening NORMAL -> spitter x1.

First scout read of the first side: GREEDY 38; of the second: NORMAL 26, AGGRESSIVE 12.

Plan at the end, first side: economy 33, balanced 3, rush 2.

### Research: games where done, median time

- **crown**: keen_sabres 35 (6:05); armour 2 (14:40); matchlock 4 (14:40); bayonet 1 (14:50)
- **brood**: nb_pack_hunt 36 (7:57); nb_clutch_raptor 38 (8:02); nb_slither 7 (8:45); nb_fog 1 (9:30); nb_clutch_spitter 17 (9:40); nb_miasma 1 (10:10); nb_quick_roots 6 (10:27); nb_battering_horns 20 (10:37); nb_long_spit 3 (10:50)

### Per map (first side's result: r0 / r1, its slot; W L win/loss, w l = led/trailed a draw, = even draw)

| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 |
|---|---|---|---|---|---|
| amberfall_vale | L P1 11:48 | l P2 | L P1 10:31 | L P2 14:17 | rush / rush |
| ashfall | l P2 | L P1 10:36 | l P2 | l P1 | rush / rush |
| ashford_crossing | l P2 | = P1 | l P2 | l P1 | rush / rush |
| border_march | L P2 11:46 | L P1 13:09 | L P2 14:09 | L P1 12:42 | rush / rush |
| cinder_steps | L P1 14:21 | L P2 12:09 | L P1 14:08 | l P2 | rush / rush |
| dune_sea | L P1 12:11 | l P2 | L P1 11:24 | l P2 | rush / rush |
| frostfang | L P2 12:57 | l P1 | L P2 13:13 | L P1 14:10 | rush / rush |
| frostmere | L P2 11:47 | L P1 10:26 | l P2 | L P1 14:44 | rush / rush |
| glimmerdeep | l P1 | L P2 12:37 | l P1 | L P2 12:01 | rush / rush |
| greenhold | L P1 10:43 | L P2 13:52 | = P1 | L P2 9:59 | rush / rush |
| highmoor | L P2 10:39 | l P1 | l P2 | = P1 | rush / rush |
| hollowfen | l P2 | L P1 13:47 | L P2 13:48 | L P1 10:35 | rush / rush |
| kestrel_rise | L P1 14:08 | L P2 13:09 | L P1 12:16 | L P2 10:32 | rush / rush |
| mirewood | l P1 | L P2 12:49 | L P1 12:47 | L P2 14:46 | rush / rush |
| red_coast | L P1 10:40 | L P2 11:37 | L P1 10:40 | L P2 10:51 | rush / rush |
| redrock_canyon | L P1 10:45 | L P2 11:16 | L P1 11:52 | L P2 11:49 | rush / rush |
| saltmarsh_isles | L P2 12:24 | l P1 | L P2 11:04 | L P1 14:55 | rush / rush |
| thornwood_maze | l P2 | L P1 14:04 | L P2 10:38 | L P1 13:47 | rush / rush |
| twin_fords | l P1 | L P2 12:45 | L P1 11:53 | L P2 12:13 | rush / rush |

## Crown v Clockwork

### Economy and army (first side over second; games still running at that minute)

| | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 0.63 | 0.59 | 0.53 | 0.49 | 0.70 | 0.55 | 0.41 | 0.20 |
| 2026-11-12 | 0.65 | 0.68 | 0.65 | 0.64 | 0.66 | 0.91 | 0.51 | 0.37 |

Income PER MINUTE (median, earned in the minute before) and earned by then over the bench (mean of the games / bench, docs/economy_parity.md):

| side | n at 5 | /min 5:00 | 8:00 | 10:00 | 12:00 | earned 5:00 / bench | 8:00 | 10:00 | 2026-11-12 /min 8:00 | 11-12 earned 8:00 / bench |
|---|---|---|---|---|---|---|---|---|---|---|
| crown | 38 | 760 | 1,140 | 1,140 | 760 | 0.63 | 0.62 | 0.63 | 760 | 0.57 |
| clockwork | 38 | 1,408 | 2,440 | 2,937 | 2,674 | 0.95 | 1.01 | 1.12 | 1,653 | 0.81 |

Spot A (P1) v B, won or led, now: classic maps A 9 v B 9; named maps A 10 v B 10.

Spot A (P1) v B, won or led, 2026-11-12: classic maps A 9 v B 8; named maps A 10 v B 9.

Halls lost (built) per game, mean: first 2.00, second 0.03 (2026-11-12: 1.61, 0.37). Halls at 8:00 (median): 2.0 v 3.0.

### OPTIMAL's picks (the first side) and how they did

| opening pick (read -> plan) | games | W-D-L | won or led | later switches |
|---|---|---|---|---|
| opening NORMAL -> timing | 19 | 0-16-3 | 0 |  |
| opening NORMAL -> balloon | 12 | 0-4-8 | 0 | middle DEFENSIVE -> siege x1 |
| opening NORMAL -> economy | 7 | 0-2-5 | 0 | middle AGGRESSIVE -> balanced x1 |

The second side's opening picks: opening UNKNOWN -> economy x18; opening UNKNOWN -> springer x9; opening UNKNOWN -> heavy x7; opening UNKNOWN -> balanced x4.

First scout read of the first side: NORMAL 38; of the second: UNKNOWN 38.

Plan at the end, first side: timing 19, balloon 11, economy 6, siege 1, balanced 1.

### Research: games where done, median time

- **crown**: keen_sabres 38 (7:20); bayonet 21 (10:25); armour 16 (10:27); matchlock 22 (10:30); charge 16 (11:22); quadrant 1 (12:00); flintlock 13 (12:10); pouch 12 (12:55); caplock 5 (13:10); charges 7 (13:30)
- **clockwork**: shield_wall 38 (7:30); high_leap 27 (8:40); owl_morph 1 (13:55)

### Per map (first side's result: r0 / r1, its slot; W L win/loss, w l = led/trailed a draw, = even draw)

| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 |
|---|---|---|---|---|---|
| amberfall_vale | l P1 | L P2 12:29 | w P1 | w P2 | balloon / balloon |
| ashfall | L P2 13:53 | L P1 12:27 | w P2 | = P1 | timing / balloon |
| ashford_crossing | l P2 | l P1 | l P2 | l P1 | timing / timing |
| border_march | L P2 11:00 | l P1 | l P2 | l P1 | balloon / balloon |
| cinder_steps | L P1 12:40 | L P2 11:27 | l P1 | L P2 13:55 | balloon / balloon |
| dune_sea | L P1 13:09 | L P2 13:07 | w P1 | l P2 | timing / economy |
| frostfang | l P2 | l P1 | L P2 13:39 | L P1 13:58 | timing / balloon |
| frostmere | l P2 | l P1 | L P2 10:53 | l P1 | timing / timing |
| glimmerdeep | l P1 | L P2 14:20 | l P1 | l P2 | timing / balloon |
| greenhold | l P1 | l P2 | l P1 | L P2 12:22 | timing / balloon |
| highmoor | l P2 | l P1 | L P2 14:06 | l P1 | timing / timing |
| hollowfen | l P2 | L P1 13:13 | l P2 | l P1 | timing / economy |
| kestrel_rise | L P1 14:35 | l P2 | l P1 | l P2 | economy / timing |
| mirewood | L P1 13:17 | L P2 12:57 | l P1 | l P2 | balloon / balloon |
| red_coast | l P1 | L P2 12:00 | L P1 11:34 | l P2 | timing / economy |
| redrock_canyon | l P1 | l P2 | l P1 | l P2 | timing / timing |
| saltmarsh_isles | l P2 | l P1 | = P2 | w P1 | economy / timing |
| thornwood_maze | L P2 14:53 | L P1 12:03 | l P2 | L P1 13:45 | timing / economy |
| twin_fords | l P1 | l P2 | l P1 | l P2 | timing / economy |

## Brood v Brood (P1)

### Economy and army (first side over second; games still running at that minute)

| | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 1.07 | 1.08 | 1.08 | 1.10 | 1.18 | 0.98 | 1.14 | 1.27 |
| 2026-11-12 | 1.04 | 1.05 | 1.05 | 1.05 | 0.92 | 1.07 | 1.08 | 1.08 |

Income PER MINUTE (median, earned in the minute before) and earned by then over the bench (mean of the games / bench, docs/economy_parity.md):

| side | n at 5 | /min 5:00 | 8:00 | 10:00 | 12:00 | earned 5:00 / bench | 8:00 | 10:00 | 2026-11-12 /min 8:00 | 11-12 earned 8:00 / bench |
|---|---|---|---|---|---|---|---|---|---|---|
| brood (P1) | 38 | 1,756 | 2,151 | 2,043 | 2,088 | 0.87 | 1.06 | 0.98 | 2,112 | 1.03 |
| brood (P2) | 38 | 1,540 | 1,878 | 1,894 | 1,814 | 0.81 | 0.98 | 0.91 | 2,000 | 0.98 |

Spot A (P1) v B, won or led, now: classic maps A 12 v B 5; named maps A 14 v B 4.

Spot A (P1) v B, won or led, 2026-11-12: classic maps A 8 v B 6; named maps A 15 v B 3.

Halls lost (built) per game, mean: first 0.00, second 0.00 (2026-11-12: 0.00, 0.00). Halls at 8:00 (median): 4.0 v 4.0.

### OPTIMAL's picks (the first side) and how they did

| opening pick (read -> plan) | games | W-D-L | won or led | later switches |
|---|---|---|---|---|
| opening NORMAL -> balanced | 17 | 10-5-2 | 12 |  |
| opening NORMAL -> timing | 9 | 2-6-1 | 4 |  |
| opening NORMAL -> economy | 8 | 3-5-0 | 6 |  |
| opening UNKNOWN -> timing | 4 | 2-2-0 | 4 |  |

The second side's opening picks: opening NORMAL -> balanced x14; opening NORMAL -> timing x14; opening NORMAL -> economy x4; opening UNKNOWN -> balanced x3; opening UNKNOWN -> timing x3.

First scout read of the first side: NORMAL 38; of the second: NORMAL 38.

Plan at the end, first side: balanced 17, timing 13, economy 8.

### Research: games where done, median time

- **brood (P1)**: nb_clutch_raptor 38 (5:35); nb_pack_hunt 38 (5:45); nb_clutch_spitter 21 (8:25); nb_slither 11 (8:50); nb_miasma 2 (10:10); nb_battering_horns 12 (10:32); nb_long_spit 1 (10:40); nb_fog 6 (10:52); nb_quick_roots 11 (11:40); nb_swamp_mending 1 (12:15); nb_updraft 2 (12:37)
- **brood (P2)**: nb_clutch_raptor 38 (5:47); nb_pack_hunt 38 (6:05); nb_clutch_spitter 20 (8:35); nb_slither 9 (9:25); nb_fog 6 (10:10); nb_quick_roots 16 (10:27); nb_miasma 4 (11:37); nb_battering_horns 3 (11:55); nb_long_spit 3 (12:45); nb_swamp_mending 4 (13:22)

### Per map (first side's result: r0 / r1, its slot; W L win/loss, w l = led/trailed a draw, = even draw)

| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 |
|---|---|---|---|---|---|
| amberfall_vale | W P1 10:47 | w P1 | W P1 13:12 | = P1 | balanced / economy |
| ashfall | W P1 14:02 | w P1 | L P1 11:14 | = P1 | balanced / timing |
| ashford_crossing | W P1 11:42 | W P1 12:51 | W P1 11:18 | l P1 | balanced / timing |
| border_march | L P1 13:17 | = P1 | l P1 | W P1 14:45 | balanced / balanced |
| cinder_steps | W P1 9:54 | w P1 | W P1 9:33 | W P1 10:02 | timing / timing |
| dune_sea | L P1 12:29 | l P1 | w P1 | w P1 | timing / timing |
| frostfang | W P1 14:27 | W P1 14:23 | W P1 14:33 | l P1 | balanced / timing |
| frostmere | w P1 | l P1 | w P1 | L P1 13:26 | balanced / timing |
| glimmerdeep | w P1 | W P1 14:11 | w P1 | W P1 10:45 | timing / timing |
| greenhold | w P1 | W P1 13:36 | w P1 | l P1 | balanced / economy |
| highmoor | w P1 | W P1 14:22 | l P1 | = P1 | timing / balanced |
| hollowfen | W P1 14:50 | = P1 | W P1 12:57 | l P1 | balanced / timing |
| kestrel_rise | = P1 | L P1 11:24 | w P1 | = P1 | economy / balanced |
| mirewood | l P1 | l P1 | w P1 | = P1 | balanced / balanced |
| red_coast | W P1 14:22 | W P1 13:02 | w P1 | = P1 | balanced / economy |
| redrock_canyon | w P1 | w P1 | w P1 | W P1 14:44 | economy / economy |
| saltmarsh_isles | l P1 | l P1 | W P1 14:55 | w P1 | economy / timing |
| thornwood_maze | W P1 14:24 | W P1 12:04 | w P1 | w P1 | balanced / economy |
| twin_fords | W P1 12:49 | W P1 13:36 | l P1 | W P1 10:14 | balanced / balanced |

## Brood v Clockwork

### Economy and army (first side over second; games still running at that minute)

| | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 0.68 | 0.90 | 1.05 | 1.08 | 0.80 | 1.01 | 1.81 | 2.26 |
| 2026-11-12 | 0.62 | 0.69 | 0.82 | 0.97 | 0.72 | 0.75 | 0.61 | 0.96 |

Income PER MINUTE (median, earned in the minute before) and earned by then over the bench (mean of the games / bench, docs/economy_parity.md):

| side | n at 5 | /min 5:00 | 8:00 | 10:00 | 12:00 | earned 5:00 / bench | 8:00 | 10:00 | 2026-11-12 /min 8:00 | 11-12 earned 8:00 / bench |
|---|---|---|---|---|---|---|---|---|---|---|
| brood | 38 | 834 | 1,642 | 1,967 | 1,972 | 0.55 | 0.69 | 0.72 | 958 | 0.55 |
| clockwork | 38 | 850 | 1,371 | 1,393 | 1,158 | 0.81 | 0.72 | 0.70 | 1,387 | 0.74 |

Spot A (P1) v B, won or led, now: classic maps A 13 v B 5; named maps A 7 v B 13.

Spot A (P1) v B, won or led, 2026-11-12: classic maps A 15 v B 3; named maps A 10 v B 9.

Halls lost (built) per game, mean: first 0.00, second 1.89 (2026-11-12: 0.00, 1.08). Halls at 8:00 (median): 3.0 v 2.0.

### OPTIMAL's picks (the first side) and how they did

| opening pick (read -> plan) | games | W-D-L | won or led | later switches |
|---|---|---|---|---|
| opening GREEDY -> rush | 35 | 24-5-6 | 27 | middle DEFENSIVE -> brute x11; late DEFENSIVE -> brute x10; middle GREEDY -> timing x4; opening AGGRESSIVE -> balanced x3 |
| opening UNKNOWN -> spitter | 1 | 0-1-0 | 0 |  |
| opening NORMAL -> balanced | 1 | 1-0-0 | 1 | middle DEFENSIVE -> brute x1 |
| opening UNKNOWN -> balanced | 1 | 1-0-0 | 1 | late DEFENSIVE -> brute x1 |

The second side's opening picks: opening GREEDY -> cs_rush x38.

First scout read of the first side: GREEDY 35, NORMAL 3; of the second: GREEDY 38.

Plan at the end, first side: brute 23, balanced 12, spitter 1, economy 1, timing 1.

### Research: games where done, median time

- **brood**: nb_pack_hunt 33 (6:45); nb_clutch_raptor 35 (8:05); nb_clutch_spitter 7 (9:20); nb_slither 3 (10:40); nb_battering_horns 16 (11:05); nb_long_spit 2 (11:10); nb_quick_roots 7 (11:35); nb_updraft 1 (12:00); nb_fog 2 (12:52); nb_swamp_mending 1 (12:55); nb_miasma 1 (14:30)
- **clockwork**: shield_wall 12 (10:35)

### Per map (first side's result: r0 / r1, its slot; W L win/loss, w l = led/trailed a draw, = even draw)

| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 |
|---|---|---|---|---|---|
| amberfall_vale | l P1 | W P2 13:54 | l P1 | = P2 | spitter / rush |
| ashfall | W P2 13:09 | W P1 11:27 | L P2 11:24 | W P1 13:04 | rush / rush |
| ashford_crossing | W P2 14:13 | W P1 9:47 | W P2 14:23 | l P1 | rush / rush |
| border_march | L P2 11:53 | W P1 11:46 | L P2 9:52 | W P1 14:34 | rush / rush |
| cinder_steps | l P1 | l P2 | W P1 13:01 | L P2 12:41 | rush / rush |
| dune_sea | W P1 11:07 | W P2 11:42 | W P1 12:01 | L P2 10:43 | rush / rush |
| frostfang | w P2 | w P1 | L P2 12:56 | l P1 | rush / rush |
| frostmere | W P2 10:32 | W P1 12:05 | w P2 | W P1 13:31 | balanced / rush |
| glimmerdeep | W P1 14:01 | W P2 14:05 | w P1 | w P2 | rush / rush |
| greenhold | W P1 11:17 | L P2 8:48 | w P1 | L P2 14:04 | rush / rush |
| highmoor | W P2 13:55 | W P1 12:44 | L P2 10:18 | W P1 12:34 | rush / rush |
| hollowfen | W P2 12:43 | L P1 13:03 | L P2 12:30 | L P1 12:25 | rush / rush |
| kestrel_rise | W P1 13:08 | W P2 10:51 | w P1 | l P2 | rush / rush |
| mirewood | W P1 11:16 | L P2 13:12 | W P1 13:55 | L P2 13:45 | rush / rush |
| red_coast | W P1 9:23 | W P2 14:44 | l P1 | l P2 | rush / rush |
| redrock_canyon | W P1 13:53 | W P2 12:41 | W P1 10:04 | W P2 13:50 | balanced / rush |
| saltmarsh_isles | W P2 13:33 | L P1 14:06 | l P2 | l P1 | rush / rush |
| thornwood_maze | W P2 13:29 | w P1 | W P2 9:50 | W P1 14:10 | rush / rush |
| twin_fords | W P1 10:25 | L P2 10:44 | L P1 11:30 | l P2 | rush / rush |

