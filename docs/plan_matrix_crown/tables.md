# Plan matrix tables: Crown (288 games, cut at 20:00)

Versions: 0.38.59. Maps: greenhold, ashford_crossing, mirewood, frostfang, cinder_steps, dune_sea.

## Won or led of n (W-D-L), and v OPTIMAL

Each cell: won or led / games (W-D-L; trailed). Below: paired v the OPTIMAL row (same map, round, seed, sides): better / worse games (sign-test p) and the score ratio at the bell relative to OPTIMAL's (x, paired t).

| plan | v Brood | v Clockwork | v Crown (mirror) | all |
|---|---|---|---|---|
| **balanced** | 0/12 (0-0-12; 12)<br>0/1 p 1.000, x0.81 t -0.9 | 0/12 (0-6-6; 12)<br>0/0 p 1.000, x1.03 t 0.1 | 8/12 (1-11-0; 3)<br>7/0 p 0.016, x2.32 t 2.3 | 8/36 |
| **rush** | 1/12 (1-3-8; 11)<br>1/1 p 1.000, x1.97 t 1.4 | 1/12 (1-0-11; 11)<br>1/0 p 1.000, x0.53 t -1.2 | 4/12 (3-8-1; 7)<br>5/2 p 0.453, x2.00 t 1.1 | 6/36 |
| **economy** | 0/12 (0-1-11; 12)<br>0/1 p 1.000, x1.06 t 0.2 | 0/12 (0-5-7; 12)<br>0/0 p 1.000, x0.91 t -0.2 | 4/12 (1-8-3; 6)<br>4/1 p 0.375, x0.93 t -0.3 | 4/36 |
| **timing** | 0/12 (0-0-12; 12)<br>0/1 p 1.000, x0.62 t -2.2 | 2/12 (2-2-8; 10)<br>2/0 p 0.500, x1.47 t 0.7 | 3/12 (1-5-6; 9)<br>3/2 p 1.000, x0.41 t -1.3 | 5/36 |
| **dragoon** | 0/12 (0-3-9; 11)<br>1/1 p 1.000, x1.30 t 0.7 | 0/12 (0-2-10; 12)<br>0/0 p 1.000, x0.53 t -1.9 | 1/12 (0-4-8; 11)<br>1/2 p 1.000, x0.28 t -2.7 | 1/36 |
| **siege** | 0/12 (0-3-9; 12)<br>0/1 p 1.000, x1.29 t 0.8 | 0/12 (0-7-5; 12)<br>0/0 p 1.000, x1.38 t 0.8 | 3/12 (0-9-3; 7)<br>5/2 p 0.453, x0.91 t -0.2 | 3/36 |
| **balloon** | 0/12 (0-2-10; 12)<br>0/1 p 1.000, x0.89 t -0.4 | 1/12 (0-5-7; 11)<br>1/0 p 1.000, x0.92 t -0.2 | 5/12 (4-8-0; 3)<br>8/1 p 0.039, x2.81 t 1.7 | 6/36 |
| **optimal** | 1/12 (0-1-11; 11) | 0/12 (0-6-6; 12) | 2/12 (1-10-1; 10) | 3/36 |

## v Brood

Ratios subject / opponent (sums over the cell's games; a beaten side's last row carried).

| plan | n | income 5 | 8 | 12 | 16 | 20 | workers 8 | 12 | 20 (own) | army 8 | 12 | 16 | halls 12 | 20 (own/opp) | halls lost own / opp | won (median) | lost (median) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| balanced | 12 | 0.98 | 0.78 | 0.64 | 0.52 | 0.51 | 0.76 | 0.31 | 0 | 0.60 | 0.08 | 0.00 | 1.7/4.0 | 0.1/4.0 | 3.00 / 0.00 | 0 (-) | 12 (14:22) |
| rush | 12 | 1.22 | 1.04 | 0.92 | 0.71 | 0.61 | 0.81 | 0.79 | 9 | 1.56 | 1.20 | 0.23 | 2.8/3.8 | 0.5/3.8 | 3.33 / 0.00 | 1 (19:46) | 8 (17:40) |
| economy | 12 | 1.14 | 0.97 | 0.78 | 0.61 | 0.55 | 0.86 | 0.71 | 0 | 0.70 | 0.86 | 0.08 | 2.8/4.0 | 0.1/4.0 | 3.83 / 0.00 | 0 (-) | 11 (17:17) |
| timing | 12 | 0.91 | 0.69 | 0.51 | 0.39 | 0.39 | 0.43 | 0.37 | 1 | 1.08 | 0.37 | 0.00 | 1.7/4.0 | 0.3/4.0 | 3.08 / 0.00 | 0 (-) | 12 (15:29) |
| dragoon | 12 | 0.90 | 0.85 | 0.68 | 0.56 | 0.55 | 0.72 | 0.46 | 6 | 1.06 | 0.45 | 0.22 | 2.2/4.0 | 0.9/3.8 | 2.83 / 0.00 | 0 (-) | 9 (14:22) |
| siege | 12 | 0.92 | 0.90 | 0.74 | 0.59 | 0.53 | 0.78 | 0.65 | 2 | 0.99 | 0.67 | 0.18 | 2.9/4.0 | 0.8/4.0 | 4.25 / 0.00 | 0 (-) | 9 (16:28) |
| balloon | 12 | 0.87 | 0.75 | 0.55 | 0.44 | 0.41 | 0.75 | 0.29 | 1 | 0.72 | 0.32 | 0.12 | 2.0/4.0 | 0.2/4.0 | 3.42 / 0.00 | 0 (-) | 10 (14:33) |
| optimal | 12 | 1.01 | 0.82 | 0.69 | 0.54 | 0.54 | 0.67 | 0.65 | 5 | 0.91 | 0.61 | 0.07 | 2.3/4.0 | 0.4/3.8 | 2.50 / 0.00 | 0 (-) | 11 (15:34) |

| plan | own first attack lands (median, n) | kills in its 90 s (workers / army, mean) | halls taken in it | opp first attack lands | opp OPTIMAL picks |
|---|---|---|---|---|---|
| balanced | 8:15 (12) | 0.50 / 52.00 (12 arrivals) | 0 | - (0) | spitter 5, brute 3, economy 2, balanced 1, timing 1 |
| rush | 9:40 (11) | 0.45 / 42.09 (11 arrivals) | 0 | 7:25 (4) | balanced 4, brute 4, spitter 3, timing 1 |
| economy | 8:15 (12) | 0.25 / 39.08 (12 arrivals) | 0 | 13:25 (2) | spitter 7, economy 4, balanced 1 |
| timing | 8:10 (12) | 0.58 / 58.33 (12 arrivals) | 0 | - (0) | balanced 4, spitter 3, brute 3, economy 1, timing 1 |
| dragoon | 8:45 (12) | 0.08 / 58.75 (12 arrivals) | 0 | 13:50 (1) | economy 6, balanced 2, spitter 2, brute 2 |
| siege | 8:30 (12) | 0.00 / 52.50 (12 arrivals) | 0 | 12:25 (4) | balanced 4, spitter 4, brute 3, economy 1 |
| balloon | 8:20 (12) | 5.00 / 52.50 (12 arrivals) | 0 | - (0) | spitter 5, balanced 3, economy 3, brute 1 |
| optimal | 9:15 (12) | 0.42 / 62.50 (12 arrivals) | 0 | 14:30 (1) | economy 4, balanced 3, brute 3, spitter 1, timing 1 |

## v Clockwork

Ratios subject / opponent (sums over the cell's games; a beaten side's last row carried).

| plan | n | income 5 | 8 | 12 | 16 | 20 | workers 8 | 12 | 20 (own) | army 8 | 12 | 16 | halls 12 | 20 (own/opp) | halls lost own / opp | won (median) | lost (median) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| balanced | 12 | 0.80 | 0.78 | 0.65 | 0.54 | 0.47 | 0.88 | 0.67 | 14 | 0.60 | 0.23 | 0.07 | 2.4/4.2 | 0.6/5.9 | 2.75 / 0.00 | 0 (-) | 6 (15:21) |
| rush | 12 | 0.70 | 0.71 | 0.47 | 0.43 | 0.44 | 0.92 | 0.45 | 16 | 0.18 | 0.07 | 0.05 | 0.7/4.0 | 0.2/3.8 | 2.00 / 0.42 | 1 (19:43) | 11 (13:34) |
| economy | 12 | 0.79 | 0.79 | 0.61 | 0.52 | 0.47 | 0.90 | 0.74 | 22 | 0.50 | 0.20 | 0.09 | 2.0/4.1 | 0.7/5.3 | 2.50 / 0.17 | 0 (-) | 7 (14:59) |
| timing | 12 | 0.67 | 0.65 | 0.58 | 0.55 | 0.55 | 0.70 | 0.83 | 30 | 0.69 | 0.41 | 0.20 | 3.1/4.1 | 2.0/5.0 | 2.75 / 0.67 | 2 (15:13) | 8 (17:33) |
| dragoon | 12 | 0.72 | 0.68 | 0.50 | 0.43 | 0.41 | 0.72 | 0.50 | 7 | 0.50 | 0.14 | 0.02 | 1.8/4.1 | 0.5/4.9 | 2.92 / 0.00 | 0 (-) | 10 (13:33) |
| siege | 12 | 0.68 | 0.72 | 0.59 | 0.54 | 0.54 | 0.78 | 0.76 | 33 | 0.61 | 0.37 | 0.17 | 3.0/4.2 | 2.8/6.0 | 2.75 / 0.00 | 0 (-) | 5 (16:29) |
| balloon | 12 | 0.68 | 0.64 | 0.51 | 0.43 | 0.43 | 0.76 | 0.59 | 19 | 0.58 | 0.29 | 0.12 | 2.0/4.2 | 1.5/5.4 | 2.50 / 0.08 | 0 (-) | 7 (15:30) |
| optimal | 12 | 0.70 | 0.63 | 0.54 | 0.49 | 0.46 | 0.72 | 0.70 | 21 | 0.54 | 0.28 | 0.13 | 2.9/4.0 | 1.4/5.8 | 3.17 / 0.00 | 0 (-) | 6 (16:42) |

| plan | own first attack lands (median, n) | kills in its 90 s (workers / army, mean) | halls taken in it | opp first attack lands | opp OPTIMAL picks |
|---|---|---|---|---|---|
| balanced | 6:45 (12) | 3.83 / 12.08 (12 arrivals) | 0 | 10:00 (7) | springer 5, economy 3, heavy 3, balanced 1 |
| rush | 5:35 (12) | 2.42 / 3.42 (12 arrivals) | 0 | 9:30 (1) | balanced 12 |
| economy | 6:45 (12) | 3.75 / 10.08 (12 arrivals) | 0 | 10:20 (5) | springer 5, heavy 4, balanced 3 |
| timing | 7:30 (11) | 4.09 / 11.91 (11 arrivals) | 0 | 10:30 (7) | springer 4, balanced 3, economy 3, heavy 2 |
| dragoon | 6:45 (12) | 2.17 / 2.25 (12 arrivals) | 0 | 11:40 (3) | economy 3, heavy 3, springer 3, balanced 3 |
| siege | 7:40 (12) | 5.08 / 12.50 (12 arrivals) | 0 | 12:15 (4) | springer 4, economy 4, heavy 3, balanced 1 |
| balloon | 7:20 (12) | 5.17 / 8.92 (12 arrivals) | 0 | 14:15 (4) | economy 4, springer 4, heavy 2, balanced 2 |
| optimal | 7:45 (12) | 5.42 / 9.00 (12 arrivals) | 0 | 10:45 (6) | balanced 4, economy 4, heavy 2, springer 2 |

## v Crown (mirror: the forced plan v OPTIMAL)

Ratios subject / opponent (sums over the cell's games; a beaten side's last row carried).

| plan | n | income 5 | 8 | 12 | 16 | 20 | workers 8 | 12 | 20 (own) | army 8 | 12 | 16 | halls 12 | 20 (own/opp) | halls lost own / opp | won (median) | lost (median) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| balanced | 12 | 1.04 | 1.01 | 1.01 | 1.07 | 1.25 | 1.03 | 1.03 | 75 | 0.91 | 1.15 | 1.12 | 3.2/3.8 | 5.1/2.8 | 0.17 / 2.25 | 1 (18:38) | 0 (-) |
| rush | 12 | 0.91 | 1.05 | 1.11 | 1.04 | 0.92 | 1.23 | 1.15 | 36 | 0.74 | 1.11 | 0.79 | 3.2/2.8 | 2.8/3.8 | 1.33 / 1.00 | 3 (13:38) | 1 (19:14) |
| economy | 12 | 0.94 | 1.02 | 1.06 | 0.91 | 0.84 | 1.08 | 1.18 | 48 | 1.04 | 0.78 | 0.73 | 3.8/3.4 | 3.4/4.3 | 1.33 / 1.00 | 1 (15:12) | 3 (17:55) |
| timing | 12 | 0.86 | 0.83 | 0.70 | 0.59 | 0.56 | 0.66 | 0.58 | 20 | 1.57 | 0.46 | 0.37 | 3.2/3.5 | 2.2/4.5 | 2.33 / 1.17 | 1 (17:23) | 6 (16:36) |
| dragoon | 12 | 0.86 | 0.92 | 0.83 | 0.65 | 0.65 | 0.93 | 0.67 | 16 | 0.96 | 0.73 | 0.40 | 3.4/3.9 | 1.8/5.8 | 3.00 / 0.17 | 0 (-) | 8 (18:09) |
| siege | 12 | 0.95 | 0.94 | 1.01 | 0.96 | 0.92 | 0.97 | 1.16 | 30 | 1.02 | 1.11 | 1.22 | 4.0/3.9 | 4.1/5.1 | 1.67 / 0.75 | 0 (-) | 3 (18:04) |
| balloon | 12 | 0.86 | 0.82 | 0.89 | 1.01 | 1.03 | 0.89 | 1.00 | 45 | 0.90 | 1.41 | 1.39 | 3.3/3.6 | 4.5/3.8 | 1.42 / 1.00 | 4 (17:56) | 0 (-) |
| optimal | 12 | 1.00 | 0.95 | 1.01 | 0.87 | 0.75 | 0.93 | 1.06 | 30 | 1.01 | 0.79 | 0.80 | 3.3/3.4 | 2.8/5.1 | 2.08 / 1.08 | 1 (16:27) | 1 (16:45) |

| plan | own first attack lands (median, n) | kills in its 90 s (workers / army, mean) | halls taken in it | opp first attack lands | opp OPTIMAL picks |
|---|---|---|---|---|---|
| balanced | 9:00 (8) | 5.38 / 15.00 (8 arrivals) | 0 | 10:25 (12) | siege 6, timing 3, economy 2, dragoon 1 |
| rush | 9:55 (10) | 1.40 / 13.80 (10 arrivals) | 0 | 10:00 (12) | balanced 11, siege 1 |
| economy | 11:00 (10) | 2.90 / 14.40 (10 arrivals) | 0 | 9:35 (10) | economy 6, dragoon 3, siege 2, balanced 1 |
| timing | 10:55 (10) | 0.80 / 8.60 (10 arrivals) | 0 | 8:00 (10) | dragoon 5, economy 4, timing 1, siege 1, balanced 1 |
| dragoon | 9:30 (11) | 1.73 / 8.09 (11 arrivals) | 0 | 11:40 (5) | dragoon 5, balanced 3, economy 2, timing 1, siege 1 |
| siege | 10:40 (10) | 3.20 / 13.40 (10 arrivals) | 0 | 9:35 (10) | dragoon 5, economy 4, timing 1, siege 1, balanced 1 |
| balloon | 9:40 (11) | 11.82 / 12.55 (11 arrivals) | 0 | 12:30 (10) | economy 5, dragoon 4, timing 1, siege 1, balanced 1 |
| optimal | 10:25 (10) | 0.10 / 9.90 (10 arrivals) | 0 | 9:00 (9) | balanced 4, dragoon 3, timing 2, siege 2, economy 1 |

## What the subject's OPTIMAL picked

| opponent | map | round | read -> pick (time) | result |
|---|---|---|---|---|
| Brood | greenhold | 0 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:32) | L |
| Brood | greenhold | 1 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:46) | L |
| Brood | ashford_crossing | 0 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:43) | L |
| Brood | ashford_crossing | 1 | NORMAL -> economy (an economic race) (1:36) | L |
| Brood | mirewood | 0 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:29) | L |
| Brood | mirewood | 1 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:43) | L |
| Brood | frostfang | 0 | LEAN -> rush (the matchup) (0:00) | L |
| Brood | frostfang | 1 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:30) | L |
| Brood | cinder_steps | 0 | LEAN -> rush (the matchup) (0:00) | L |
| Brood | cinder_steps | 1 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:29) | L |
| Brood | dune_sea | 0 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:30) | w |
| Brood | dune_sea | 1 | GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) (1:43) | L |
| Clockwork | greenhold | 0 | NORMAL -> balloon (raids on its workers) (1:31) | l |
| Clockwork | greenhold | 1 | NORMAL -> timing (a timing attack) (1:17) | l |
| Clockwork | ashford_crossing | 0 | NORMAL -> timing (a timing attack) (1:42) | l |
| Clockwork | ashford_crossing | 1 | NORMAL -> timing (a timing attack) (1:27) | L |
| Clockwork | mirewood | 0 | NORMAL -> timing (a timing attack) (1:31) | l |
| Clockwork | mirewood | 1 | NORMAL -> balloon (raids on its workers) (1:16) | l |
| Clockwork | frostfang | 0 | NORMAL -> timing (a timing attack) (1:19) | L |
| Clockwork | frostfang | 1 | NORMAL -> timing (a timing attack) (1:32) | l |
| Clockwork | cinder_steps | 0 | NORMAL -> economy (an economic race) (1:24) | L |
| Clockwork | cinder_steps | 1 | NORMAL -> timing (a timing attack) (1:09) | L |
| Clockwork | dune_sea | 0 | NORMAL -> balloon (raids on its workers) (1:29) | L |
| Clockwork | dune_sea | 1 | NORMAL -> timing (a timing attack) (1:18) | L |
| Crown | greenhold | 0 | UNKNOWN -> timing (a timing attack) (2:38) | l |
| Crown | greenhold | 1 | UNKNOWN -> siege (a siege to break its defences) (2:35) | l |
| Crown | ashford_crossing | 0 | UNKNOWN -> economy (an economic race) (2:37) | W |
| Crown | ashford_crossing | 1 | UNKNOWN -> economy (an economic race) (2:40) | l |
| Crown | mirewood | 0 | UNKNOWN -> timing (a timing attack) (2:37) | l |
| Crown | mirewood | 1 | UNKNOWN -> economy (an economic race) (2:35) | l |
| Crown | frostfang | 0 | UNKNOWN -> siege (a siege to break its defences) (2:35) | l |
| Crown | frostfang | 1 | UNKNOWN -> economy (an economic race) (2:38) | w |
| Crown | cinder_steps | 0 | UNKNOWN -> economy (an economic race) (1:59); middle AGGRESSIVE -> balanced (defend against the rush before it counter-attacks) (5:41) | L |
| Crown | cinder_steps | 1 | UNKNOWN -> economy (an economic race) (1:57) | l |
| Crown | dune_sea | 0 | UNKNOWN -> siege (a siege to break its defences) (2:38) | l |
| Crown | dune_sea | 1 | UNKNOWN -> balanced (a normal game) (2:38) | l |

## By map: the subject's result per plan (W w = l L)

v Brood

| plan | greenhold r0 | greenhold r1 | ashford_crossing r0 | ashford_crossing r1 | mirewood r0 | mirewood r1 | frostfang r0 | frostfang r1 | cinder_steps r0 | cinder_steps r1 | dune_sea r0 | dune_sea r1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| balanced | L | L | L | L | L | L | L | L | L | L | L | L |
| rush | L | L | L | L | l | L | L | l | l | L | L | W |
| economy | L | L | L | l | L | L | L | L | L | L | L | L |
| timing | L | L | L | L | L | L | L | L | L | L | L | L |
| dragoon | L | L | L | L | l | L | l | = | L | L | L | L |
| siege | L | l | L | l | L | L | L | l | L | L | L | L |
| balloon | L | L | l | L | L | L | L | l | L | L | L | L |
| optimal | L | L | L | L | L | L | L | L | L | L | w | L |

v Clockwork

| plan | greenhold r0 | greenhold r1 | ashford_crossing r0 | ashford_crossing r1 | mirewood r0 | mirewood r1 | frostfang r0 | frostfang r1 | cinder_steps r0 | cinder_steps r1 | dune_sea r0 | dune_sea r1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| balanced | l | l | l | l | l | L | L | L | L | L | l | L |
| rush | L | L | L | L | L | L | L | L | L | L | L | W |
| economy | L | L | L | l | L | l | L | l | L | L | l | l |
| timing | L | l | L | L | W | l | L | L | L | W | L | L |
| dragoon | L | L | l | L | L | L | L | L | L | L | L | l |
| siege | L | l | L | l | l | l | L | l | L | L | l | l |
| balloon | l | l | L | l | L | L | L | l | w | L | L | L |
| optimal | l | l | l | L | l | l | L | l | L | L | L | L |

v Crown

| plan | greenhold r0 | greenhold r1 | ashford_crossing r0 | ashford_crossing r1 | mirewood r0 | mirewood r1 | frostfang r0 | frostfang r1 | cinder_steps r0 | cinder_steps r1 | dune_sea r0 | dune_sea r1 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| balanced | l | w | w | l | l | w | w | w | w | = | W | w |
| rush | l | w | l | l | = | W | L | l | l | W | l | W |
| economy | w | l | W | l | L | w | = | = | L | w | l | L |
| timing | L | l | L | w | l | W | L | L | L | l | L | w |
| dragoon | L | l | l | w | L | L | L | L | L | l | L | L |
| siege | L | l | l | l | L | w | = | l | L | w | w | = |
| balloon | = | W | l | l | l | = | W | w | W | = | = | W |
| optimal | l | l | W | l | l | l | l | w | L | l | l | l |

