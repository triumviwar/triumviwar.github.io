# Tables (tools/study/winrate_1117_report.py)

All six pairings now (0.38.46, to 12:00; the Crown mirror to 15:00) against the earlier study cut at 12:00.

| pairing (first side's view) | games | W-D-L | won or led first / second / even | decided (mean length) | spot A v B (p) | earlier study | its W-D-L at 12:00 | won or led | paired better / worse (p) |
|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | 38 | **0-37-1** | 3 / 32 / 3 | 1 (10:13) | 19 v 16 (0.736) | 2026-11-15 | 0-27-11 | 1 / 33 / 4 | 6 / 3 (0.508) |
| Crown v Clockwork | 38 | **0-38-0** | 0 / 36 / 2 | 0 (-) | 17 v 19 (0.868) | 2026-11-15 | 0-35-3 | 0 / 38 / 0 | 2 / 0 (0.500) |
| Brood v Clockwork | 38 | **0-34-4** | 2 / 34 / 2 | 4 (11:23) | 17 v 19 (0.868) | 2026-11-15 | 11-24-3 | 29 / 9 / 0 | 1 / 27 (<0.001) |
| Crown v Crown (P1) | 38 | **0-38-0** | 10 / 16 / 12 | 0 (-) | 10 v 16 (0.327) | 2026-11-12 | 0-38-0 | 15 / 13 / 10 | 8 / 13 (0.383) |
| Crown v Crown (P1) to 15:00 | 38 | **0-38-0** | 13 / 18 / 7 | 0 (-) | 13 v 18 (0.473) | 2026-11-12 | 3-35-0 | 16 / 18 / 4 | 9 / 10 (1.000) |
| Brood v Brood (P1) | 38 | **5-33-0** | 14 / 8 / 16 | 5 (11:22) | 14 v 8 (0.286) | 2026-11-15 | 3-34-1 | 23 / 7 / 8 | 5 / 14 (0.064) |
| Clockwork v Clockwork (P1) | 38 | **2-35-1** | 19 / 15 / 4 | 3 (11:31) | 19 v 15 (0.608) | 2026-11-12 | 1-36-1 | 19 / 13 / 6 | 12 / 13 (1.000) |

## Crown v Brood

W-D-L **0-37-1**, won or led first / second / even **3 / 32 / 3**, decided 1 (10:13); 2026-11-15 cut at the same time: 0-27-11, 1 / 33 / 4, 11 (11:05).

Paired on the same 38 tags: the first side's result better in 6, worse in 3 (sign test p 0.508); its income ratio at 8:00 x1.16 of the old (geometric mean; up in 32 of 38, p <0.001; paired t 5.1).

Spot A (P1) v spot B, won or led (even draws dropped): now 19 v 16 (p 0.736); 2026-11-15 18 v 16 (p 0.864).

- now: classic maps A 11 v B 6; named maps A 8 v B 10
- 2026-11-15: classic maps A 9 v B 6; named maps A 9 v B 10

| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 1.02 | 0.85 | 0.79 | 0.74 | 0.70 | 1.17 | 0.94 | 0.73 |
| 2026-11-15 | 1.00 | 0.74 | 0.69 | 0.68 | 1.06 | 0.69 | 0.38 | 0.32 |

(sums over the games still running at that minute)

| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | 2026-11-15 earned/bench 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| crown | 760 | 1,140 | 1,520 | 1,520 | 0.67 | 0.61 | 0.66 | 31 | 2 | 3 | 0.57 |
| brood | 858 | 1,570 | 2,114 | 2,291 | 0.63 | 0.74 | 0.78 | 48 | 4 | 4 | 0.80 |

Built halls lost per game: first 0.24, second 0.00 (2026-11-15: 1.21, 0.00). First hall lost (median, games): first 11:12 (8), second - (0). First attack (median): first 6:15 (10), second 8:25 (36). Decided games' length: mean 10:13, median 10:13.

### OPTIMAL's picks

| crown opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| rush | 37 | 0-36-1 | 3 | economy x1 |
| balanced | 1 | 0-1-0 | 0 |  |

| brood opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| brute | 11 | 0-11-0 | 9 |  |
| balanced | 11 | 1-10-0 | 10 |  |
| timing | 9 | 0-9-0 | 8 | economy x1 |
| spitter | 7 | 0-7-0 | 5 | economy x3 |

- crown: first read GREEDY 37, NORMAL 1; plan at the end economy 32, rush 4, balanced 2; 2026-11-15 opening picks rush 38.
- brood: first read NORMAL 20, AGGRESSIVE 17, GREEDY 1; plan at the end brute 11, balanced 11, timing 8, economy 4, spitter 4; 2026-11-15 opening picks balanced 12, brute 10, timing 9, spitter 7.

### Research (games, median time)

- **crown**: charge 33 (8:05)
- **brood**: nb_clutch_raptor 37 (7:55); nb_slither 3 (8:15); nb_pack_hunt 32 (8:17); nb_clutch_spitter 9 (8:25); nb_long_spit 2 (8:55); nb_quick_roots 9 (9:20); nb_fog 1 (10:15); nb_battering_horns 23 (10:20); nb_miasma 1 (10:40)

### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)

| map | now r0 | now r1 | 2026-11-15 r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |
|---|---|---|---|---|---|---|
| amberfall_vale | l P1 | l P2 | L P1 11:48 | l P2 | rush / rush | timing / brute |
| ashfall | l P2 | l P1 | l P2 | L P1 10:36 | rush / rush | brute / timing |
| ashford_crossing | l P2 | l P1 | w P2 | = P1 | rush / balanced | balanced / spitter |
| border_march | l P2 | l P1 | L P2 11:46 | l P1 | rush / rush | timing / timing |
| cinder_steps | l P1 | l P2 | l P1 | l P2 | rush / rush | brute / spitter |
| dune_sea | l P1 | l P2 | l P1 | l P2 | rush / rush | timing / brute |
| frostfang | l P2 | w P1 | l P2 | = P1 | rush / rush | brute / brute |
| frostmere | l P2 | l P1 | L P2 11:47 | L P1 10:26 | rush / rush | timing / balanced |
| glimmerdeep | l P1 | = P2 | l P1 | l P2 | rush / rush | brute / balanced |
| greenhold | w P1 | l P2 | L P1 10:43 | l P2 | rush / rush | timing / timing |
| highmoor | l P2 | w P1 | L P2 10:39 | = P1 | rush / rush | brute / spitter |
| hollowfen | = P2 | l P1 | l P2 | l P1 | rush / rush | spitter / balanced |
| kestrel_rise | l P1 | l P2 | l P1 | l P2 | rush / rush | spitter / balanced |
| mirewood | l P1 | l P2 | l P1 | l P2 | rush / rush | brute / spitter |
| red_coast | l P1 | l P2 | L P1 10:40 | L P2 11:37 | rush / rush | balanced / balanced |
| redrock_canyon | l P1 | L P2 10:13 | L P1 10:45 | L P2 11:16 | rush / rush | balanced / balanced |
| saltmarsh_isles | l P2 | l P1 | l P2 | l P1 | rush / rush | balanced / timing |
| thornwood_maze | l P2 | l P1 | l P2 | l P1 | rush / rush | balanced / brute |
| twin_fords | l P1 | = P2 | = P1 | l P2 | rush / rush | spitter / brute |

## Crown v Clockwork

W-D-L **0-38-0**, won or led first / second / even **0 / 36 / 2**, decided 0 (-); 2026-11-15 cut at the same time: 0-35-3, 0 / 38 / 0, 3 (11:29).

Paired on the same 38 tags: the first side's result better in 2, worse in 0 (sign test p 0.500); its income ratio at 8:00 x1.16 of the old (geometric mean; up in 30 of 38, p <0.001; paired t 5.6).

Spot A (P1) v spot B, won or led (even draws dropped): now 17 v 19 (p 0.868); 2026-11-15 19 v 19 (p 1.000).

- now: classic maps A 8 v B 9; named maps A 9 v B 10
- 2026-11-15: classic maps A 9 v B 9; named maps A 10 v B 10

| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 0.72 | 0.68 | 0.62 | 0.58 | 0.72 | 0.69 | 0.58 | 0.30 |
| 2026-11-15 | 0.63 | 0.59 | 0.53 | 0.49 | 0.70 | 0.55 | 0.41 | 0.20 |

(sums over the games still running at that minute)

| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | 2026-11-15 earned/bench 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| crown | 760 | 1,520 | 1,520 | 1,140 | 0.71 | 0.70 | 0.71 | 34 | 2 | 3 | 0.62 |
| clockwork | 1,353 | 2,302 | 2,806 | 2,668 | 0.94 | 0.99 | 1.09 | 47 | 3 | 4 | 1.01 |

Built halls lost per game: first 0.71, second 0.00 (2026-11-15: 0.92, 0.03). First hall lost (median, games): first 9:50 (19), second - (0). First attack (median): first 8:10 (26), second 5:32 (36). Decided games' length: mean -, median -.

### OPTIMAL's picks

| crown opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| timing | 19 | 0-19-0 | 0 | siege x1 |
| balloon | 12 | 0-12-0 | 0 | siege x4 |
| economy | 7 | 0-7-0 | 0 |  |

| clockwork opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| economy | 17 | 0-17-0 | 16 | springer x2; balanced x2 |
| springer | 10 | 0-10-0 | 10 |  |
| heavy | 7 | 0-7-0 | 6 |  |
| balanced | 4 | 0-4-0 | 4 | springer x2 |

- crown: first read NORMAL 37, UNKNOWN 1; plan at the end timing 18, balloon 8, economy 7, siege 5; 2026-11-15 opening picks timing 19, balloon 12, economy 7.
- clockwork: first read UNKNOWN 37, GREEDY 1; plan at the end springer 14, economy 13, heavy 7, balanced 4; 2026-11-15 opening picks economy 18, springer 9, heavy 7, balanced 4.

### Research (games, median time)

- **crown**: charge 36 (8:10); armour 14 (9:22); matchlock 24 (9:37); bayonet 23 (10:20); flintlock 13 (10:25); pouch 10 (10:32); charges 2 (11:07); caplock 3 (11:20)
- **clockwork**: high_leap 22 (5:47); shield_wall 38 (7:27); long_chain 21 (8:30)

### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)

| map | now r0 | now r1 | 2026-11-15 r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |
|---|---|---|---|---|---|---|
| amberfall_vale | l P1 | l P2 | l P1 | l P2 | balloon / balloon | springer / springer |
| ashfall | l P2 | l P1 | l P2 | l P1 | timing / balloon | springer / springer |
| ashford_crossing | l P2 | l P1 | l P2 | l P1 | timing / timing | economy / heavy |
| border_march | l P2 | l P1 | L P2 11:00 | l P1 | balloon / balloon | balanced / economy |
| cinder_steps | l P1 | l P2 | l P1 | L P2 11:27 | balloon / balloon | heavy / balanced |
| dune_sea | l P1 | = P2 | l P1 | l P2 | timing / economy | springer / economy |
| frostfang | l P2 | l P1 | l P2 | l P1 | timing / balloon | economy / balanced |
| frostmere | l P2 | l P1 | l P2 | l P1 | timing / timing | economy / springer |
| glimmerdeep | l P1 | l P2 | l P1 | l P2 | timing / balloon | balanced / economy |
| greenhold | l P1 | l P2 | l P1 | l P2 | timing / balloon | heavy / economy |
| highmoor | l P2 | l P1 | l P2 | l P1 | timing / timing | economy / economy |
| hollowfen | l P2 | l P1 | l P2 | l P1 | timing / economy | heavy / economy |
| kestrel_rise | l P1 | l P2 | l P1 | l P2 | economy / timing | economy / heavy |
| mirewood | l P1 | l P2 | l P1 | l P2 | balloon / balloon | economy / economy |
| red_coast | l P1 | l P2 | l P1 | L P2 12:00 | timing / economy | economy / economy |
| redrock_canyon | l P1 | l P2 | l P1 | l P2 | timing / timing | springer / economy |
| saltmarsh_isles | = P2 | l P1 | l P2 | l P1 | economy / timing | heavy / heavy |
| thornwood_maze | l P2 | l P1 | l P2 | l P1 | timing / economy | springer / economy |
| twin_fords | l P1 | l P2 | l P1 | l P2 | timing / economy | springer / springer |

## Brood v Clockwork

W-D-L **0-34-4**, won or led first / second / even **2 / 34 / 2**, decided 4 (11:23); 2026-11-15 cut at the same time: 11-24-3, 29 / 9 / 0, 14 (10:47).

Paired on the same 38 tags: the first side's result better in 1, worse in 27 (sign test p <0.001); its income ratio at 8:00 x0.88 of the old (geometric mean; up in 14 of 38, p 0.143; paired t -2.7).

Spot A (P1) v spot B, won or led (even draws dropped): now 17 v 19 (p 0.868); 2026-11-15 20 v 18 (p 0.871).

- now: classic maps A 8 v B 9; named maps A 9 v B 10
- 2026-11-15: classic maps A 13 v B 5; named maps A 7 v B 13

| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 0.62 | 0.79 | 0.82 | 0.79 | 1.24 | 0.52 | 0.46 | 0.46 |
| 2026-11-15 | 0.68 | 0.90 | 1.05 | 1.08 | 0.80 | 1.01 | 1.81 | 2.26 |

(sums over the games still running at that minute)

| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | 2026-11-15 earned/bench 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| brood | 842 | 1,611 | 1,824 | 1,643 | 0.55 | 0.72 | 0.73 | 42 | 3 | 4 | 0.69 |
| clockwork | 1,167 | 1,689 | 2,194 | 2,324 | 0.89 | 0.86 | 0.90 | 31 | 3 | 4 | 0.72 |

Built halls lost per game: first 0.00, second 0.03 (2026-11-15: 0.00, 1.03). First hall lost (median, games): first - (0), second 8:30 (1). First attack (median): first 2:55 (38), second 8:55 (38). Decided games' length: mean 11:23, median 11:25.

### OPTIMAL's picks

| brood opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| rush | 35 | 0-31-4 | 1 | timing x19; economy x5; brute x1 |
| spitter | 1 | 0-1-0 | 0 |  |
| balanced | 1 | 0-1-0 | 1 | brute x1 |
| timing | 1 | 0-1-0 | 0 |  |

| clockwork opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| balanced | 38 | 4-34-0 | 34 |  |

- brood: first read GREEDY 35, NORMAL 3; plan at the end timing 19, balanced 11, economy 5, brute 2, spitter 1; 2026-11-15 opening picks rush 35, balanced 2, spitter 1.
- clockwork: first read GREEDY 38; plan at the end balanced 38; 2026-11-15 opening picks cs_rush 38.

### Research (games, median time)

- **brood**: nb_pack_hunt 35 (7:20); nb_clutch_raptor 35 (7:25); nb_clutch_spitter 10 (9:45); nb_slither 3 (9:55); nb_battering_horns 1 (11:00); nb_quick_roots 6 (11:17)
- **clockwork**: long_chain 5 (9:10); shield_wall 27 (10:15)

### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)

| map | now r0 | now r1 | 2026-11-15 r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |
|---|---|---|---|---|---|---|
| amberfall_vale | l P1 | l P2 | l P1 | w P2 | rush / spitter | balanced / balanced |
| ashfall | l P2 | l P1 | w P2 | W P1 11:27 | rush / rush | balanced / balanced |
| ashford_crossing | l P2 | l P1 | w P2 | W P1 9:47 | rush / rush | balanced / balanced |
| border_march | l P2 | l P1 | L P2 11:53 | W P1 11:46 | rush / rush | balanced / balanced |
| cinder_steps | l P1 | l P2 | l P1 | l P2 | rush / rush | balanced / balanced |
| dune_sea | l P1 | L P2 10:52 | W P1 11:07 | W P2 11:42 | rush / rush | balanced / balanced |
| frostfang | l P2 | l P1 | w P2 | w P1 | rush / rush | balanced / balanced |
| frostmere | l P2 | l P1 | W P2 10:32 | w P1 | rush / rush | balanced / balanced |
| glimmerdeep | l P1 | l P2 | w P1 | w P2 | rush / rush | balanced / balanced |
| greenhold | L P1 11:50 | = P2 | W P1 11:17 | L P2 8:48 | rush / rush | balanced / balanced |
| highmoor | l P2 | L P1 11:27 | w P2 | w P1 | rush / rush | balanced / balanced |
| hollowfen | l P2 | l P1 | w P2 | l P1 | rush / rush | balanced / balanced |
| kestrel_rise | l P1 | l P2 | w P1 | W P2 10:51 | rush / rush | balanced / balanced |
| mirewood | l P1 | l P2 | W P1 11:16 | l P2 | rush / rush | balanced / balanced |
| red_coast | l P1 | l P2 | W P1 9:23 | w P2 | rush / rush | balanced / balanced |
| redrock_canyon | w P1 | l P2 | w P1 | w P2 | balanced / timing | balanced / balanced |
| saltmarsh_isles | = P2 | l P1 | w P2 | l P1 | rush / rush | balanced / balanced |
| thornwood_maze | w P2 | l P1 | w P2 | w P1 | rush / rush | balanced / balanced |
| twin_fords | l P1 | L P2 11:24 | W P1 10:25 | L P2 10:44 | rush / rush | balanced / balanced |

## Crown v Crown (P1)

W-D-L **0-38-0**, won or led first / second / even **10 / 16 / 12**, decided 0 (-); 2026-11-12 cut at the same time: 0-38-0, 15 / 13 / 10, 0 (-).

Paired on the same 38 tags: the first side's result better in 8, worse in 13 (sign test p 0.383); its income ratio at 8:00 x1.07 of the old (geometric mean; up in 24 of 38, p 0.099; paired t 2.1).

Spot A (P1) v spot B, won or led (even draws dropped): now 10 v 16 (p 0.327); 2026-11-12 15 v 13 (p 0.851).

- now: classic maps A 6 v B 5; named maps A 4 v B 11
- 2026-11-12: classic maps A 7 v B 5; named maps A 8 v B 8

| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 0.99 | 1.02 | 1.00 | 0.95 | 0.76 | 0.85 | 1.08 | 0.99 |
| 2026-11-12 | 0.99 | 0.96 | 0.98 | 0.99 | 0.69 | 0.78 | 0.99 | 1.03 |

(sums over the games still running at that minute)

| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | 2026-11-12 earned/bench 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| crown (P1) | 760 | 1,900 | 1,520 | 1,140 | 0.77 | 0.80 | 0.81 | 42 | 2 | 4 | 0.57 |
| crown (P2) | 1,140 | 1,900 | 1,520 | 1,710 | 0.77 | 0.78 | 0.81 | 43 | 2 | 4 | 0.59 |

Built halls lost per game: first 0.34, second 0.13 (2026-11-12: 0.34, 0.24). First hall lost (median, games): first 9:45 (10), second 11:07 (4). First attack (median): first 8:20 (29), second 7:50 (29). Decided games' length: mean -, median -.

### OPTIMAL's picks

| crown (P1) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| economy | 12 | 0-12-0 | 5 |  |
| dragoon | 12 | 0-12-0 | 2 |  |
| balanced | 10 | 0-10-0 | 2 | economy x2; siege x1 |
| siege | 2 | 0-2-0 | 0 | economy x1; balanced x1 |
| timing | 2 | 0-2-0 | 1 |  |

| crown (P2) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| economy | 11 | 0-11-0 | 5 | timing x1; balanced x1; siege x1 |
| dragoon | 8 | 0-8-0 | 4 | economy x2; balanced x1 |
| timing | 8 | 0-8-0 | 2 |  |
| balanced | 7 | 0-7-0 | 3 |  |
| siege | 4 | 0-4-0 | 2 | timing x1 |

- crown (P1): first read UNKNOWN 38; plan at the end economy 14, dragoon 12, balanced 8, siege 2, timing 2; 2026-11-12 opening picks economy 12, dragoon 12, balanced 10, siege 2, timing 2.
- crown (P2): first read UNKNOWN 38; plan at the end timing 10, economy 9, balanced 8, dragoon 6, siege 5; 2026-11-12 opening picks economy 11, dragoon 8, timing 8, balanced 7, siege 4.

### Research (games, median time)

- **crown (P1)**: charge 37 (7:45); bayonet 30 (9:15); matchlock 29 (9:15); armour 29 (9:40); pouch 17 (10:15); flintlock 19 (10:25); charges 4 (10:50); caplock 12 (11:40)
- **crown (P2)**: charge 37 (7:20); bayonet 24 (9:35); matchlock 30 (9:45); armour 29 (9:50); flintlock 22 (10:32); pouch 16 (11:15); caplock 7 (11:15); charges 5 (11:40); quadrant 1 (11:55)

### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)

| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |
|---|---|---|---|---|---|---|
| amberfall_vale | = P1 | l P1 | w P1 | w P1 | balanced / economy | siege / economy |
| ashfall | l P1 | w P1 | w P1 | w P1 | balanced / economy | dragoon / timing |
| ashford_crossing | l P1 | w P1 | w P1 | l P1 | siege / economy | economy / timing |
| border_march | l P1 | w P1 | l P1 | = P1 | balanced / economy | economy / economy |
| cinder_steps | l P1 | l P1 | l P1 | l P1 | economy / siege | siege / dragoon |
| dune_sea | = P1 | = P1 | w P1 | = P1 | dragoon / balanced | timing / balanced |
| frostfang | w P1 | l P1 | w P1 | l P1 | dragoon / dragoon | balanced / dragoon |
| frostmere | l P1 | l P1 | l P1 | = P1 | dragoon / dragoon | balanced / economy |
| glimmerdeep | l P1 | l P1 | w P1 | w P1 | dragoon / economy | siege / balanced |
| greenhold | l P1 | w P1 | = P1 | = P1 | timing / balanced | dragoon / dragoon |
| highmoor | = P1 | w P1 | = P1 | w P1 | economy / economy | economy / timing |
| hollowfen | w P1 | l P1 | l P1 | l P1 | dragoon / dragoon | dragoon / balanced |
| kestrel_rise | w P1 | l P1 | w P1 | l P1 | balanced / balanced | dragoon / economy |
| mirewood | = P1 | = P1 | w P1 | w P1 | economy / economy | siege / balanced |
| red_coast | = P1 | = P1 | l P1 | l P1 | dragoon / balanced | balanced / economy |
| redrock_canyon | = P1 | w P1 | = P1 | w P1 | dragoon / timing | timing / economy |
| saltmarsh_isles | = P1 | l P1 | w P1 | = P1 | balanced / dragoon | dragoon / timing |
| thornwood_maze | = P1 | = P1 | = P1 | l P1 | balanced / dragoon | economy / timing |
| twin_fords | w P1 | l P1 | = P1 | l P1 | economy / economy | economy / timing |

## Crown v Crown (P1) to 15:00

W-D-L **0-38-0**, won or led first / second / even **13 / 18 / 7**, decided 0 (-); 2026-11-12 cut at the same time: 3-35-0, 16 / 18 / 4, 3 (13:32).

Paired on the same 38 tags: the first side's result better in 9, worse in 10 (sign test p 1.000); its income ratio at 8:00 x1.07 of the old (geometric mean; up in 24 of 38, p 0.099; paired t 2.1).

Spot A (P1) v spot B, won or led (even draws dropped): now 13 v 18 (p 0.473); 2026-11-12 16 v 18 (p 0.864).

- now: classic maps A 6 v B 7; named maps A 7 v B 11
- 2026-11-12: classic maps A 8 v B 7; named maps A 8 v B 11

| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 0.99 | 1.02 | 1.00 | 0.95 | 0.76 | 0.85 | 1.08 | 0.99 |
| 2026-11-12 | 0.99 | 0.96 | 0.98 | 0.99 | 0.69 | 0.78 | 0.99 | 1.03 |

(sums over the games still running at that minute)

| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | 2026-11-12 earned/bench 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| crown (P1) | 760 | 1,900 | 1,520 | 1,140 | 0.77 | 0.80 | 0.81 | 42 | 2 | 4 | 0.57 |
| crown (P2) | 1,140 | 1,900 | 1,520 | 1,710 | 0.77 | 0.78 | 0.81 | 43 | 2 | 4 | 0.59 |

Built halls lost per game: first 0.71, second 0.34 (2026-11-12: 0.63, 0.63). First hall lost (median, games): first 10:30 (16), second 12:40 (9). First attack (median): first 8:25 (31), second 7:50 (30). Decided games' length: mean -, median -.

### OPTIMAL's picks

| crown (P1) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| economy | 12 | 0-12-0 | 5 |  |
| dragoon | 12 | 0-12-0 | 3 |  |
| balanced | 10 | 0-10-0 | 4 | economy x2; siege x1 |
| siege | 2 | 0-2-0 | 0 | economy x1; balanced x1 |
| timing | 2 | 0-2-0 | 1 |  |

| crown (P2) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| economy | 11 | 0-11-0 | 6 | timing x1; balanced x1; siege x1 |
| dragoon | 8 | 0-8-0 | 2 | economy x2; balanced x1 |
| timing | 8 | 0-8-0 | 3 |  |
| balanced | 7 | 0-7-0 | 5 | siege x1 |
| siege | 4 | 0-4-0 | 2 | timing x1 |

- crown (P1): first read UNKNOWN 38; plan at the end economy 14, dragoon 12, balanced 8, siege 2, timing 2; 2026-11-12 opening picks economy 12, dragoon 12, balanced 10, siege 2, timing 2.
- crown (P2): first read UNKNOWN 38; plan at the end timing 10, economy 9, balanced 8, dragoon 6, siege 5; 2026-11-12 opening picks economy 11, dragoon 8, timing 8, balanced 7, siege 4.

### Research (games, median time)

- **crown (P1)**: charge 38 (7:45); armour 33 (9:40); bayonet 36 (9:40); matchlock 36 (9:47); flintlock 29 (10:55); pouch 31 (11:35); caplock 21 (11:55); charges 16 (12:57); quadrant 6 (13:52)
- **crown (P2)**: charge 37 (7:20); matchlock 37 (9:50); armour 34 (10:07); bayonet 34 (10:40); flintlock 29 (10:45); pouch 27 (11:45); caplock 21 (12:30); charges 21 (12:35); quadrant 7 (13:30)

### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)

| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |
|---|---|---|---|---|---|---|
| amberfall_vale | w P1 | l P1 | w P1 | W P1 14:53 | balanced / economy | siege / economy |
| ashfall | = P1 | w P1 | w P1 | w P1 | balanced / economy | dragoon / timing |
| ashford_crossing | l P1 | w P1 | w P1 | l P1 | siege / economy | economy / timing |
| border_march | l P1 | w P1 | l P1 | w P1 | balanced / economy | economy / economy |
| cinder_steps | l P1 | l P1 | l P1 | l P1 | economy / siege | siege / dragoon |
| dune_sea | l P1 | = P1 | w P1 | l P1 | dragoon / balanced | timing / balanced |
| frostfang | w P1 | l P1 | = P1 | l P1 | dragoon / dragoon | balanced / dragoon |
| frostmere | l P1 | l P1 | l P1 | l P1 | dragoon / dragoon | balanced / economy |
| glimmerdeep | l P1 | l P1 | w P1 | w P1 | dragoon / economy | siege / balanced |
| greenhold | = P1 | w P1 | w P1 | l P1 | timing / balanced | dragoon / dragoon |
| highmoor | l P1 | w P1 | = P1 | w P1 | economy / economy | economy / timing |
| hollowfen | w P1 | l P1 | l P1 | l P1 | dragoon / dragoon | dragoon / balanced |
| kestrel_rise | w P1 | l P1 | W P1 13:37 | l P1 | balanced / balanced | dragoon / economy |
| mirewood | = P1 | l P1 | l P1 | w P1 | economy / economy | siege / balanced |
| red_coast | l P1 | = P1 | l P1 | = P1 | dragoon / balanced | balanced / economy |
| redrock_canyon | = P1 | w P1 | l P1 | W P1 12:07 | dragoon / timing | timing / economy |
| saltmarsh_isles | w P1 | l P1 | w P1 | = P1 | balanced / dragoon | dragoon / timing |
| thornwood_maze | = P1 | w P1 | l P1 | l P1 | balanced / dragoon | economy / timing |
| twin_fords | w P1 | l P1 | w P1 | l P1 | economy / economy | economy / timing |

## Brood v Brood (P1)

W-D-L **5-33-0**, won or led first / second / even **14 / 8 / 16**, decided 5 (11:22); 2026-11-15 cut at the same time: 3-34-1, 23 / 7 / 8, 4 (10:56).

Paired on the same 38 tags: the first side's result better in 5, worse in 14 (sign test p 0.064); its income ratio at 8:00 x0.94 of the old (geometric mean; up in 12 of 38, p 0.034; paired t -3.9).

Spot A (P1) v spot B, won or led (even draws dropped): now 14 v 8 (p 0.286); 2026-11-15 23 v 7 (p 0.005).

- now: classic maps A 7 v B 5; named maps A 7 v B 3
- 2026-11-15: classic maps A 9 v B 5; named maps A 14 v B 2

| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 1.01 | 1.01 | 1.03 | 1.03 | 0.98 | 1.08 | 1.12 | 0.99 |
| 2026-11-15 | 1.07 | 1.08 | 1.08 | 1.10 | 1.18 | 0.98 | 1.14 | 1.27 |

(sums over the games still running at that minute)

| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | 2026-11-15 earned/bench 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| brood (P1) | 1,430 | 1,976 | 2,198 | 2,142 | 0.79 | 1.00 | 0.96 | 53 | 4 | 4 | 1.06 |
| brood (P2) | 1,408 | 1,951 | 2,184 | 1,930 | 0.78 | 0.99 | 0.93 | 53 | 4 | 4 | 0.98 |

Built halls lost per game: first 0.00, second 0.00 (2026-11-15: 0.00, 0.00). First hall lost (median, games): first - (0), second - (0). First attack (median): first 7:22 (38), second 6:50 (36). Decided games' length: mean 11:22, median 11:27.

### OPTIMAL's picks

| brood (P1) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| balanced | 17 | 3-14-0 | 9 | economy x1 |
| timing | 13 | 1-12-0 | 3 |  |
| economy | 8 | 1-7-0 | 2 |  |

| brood (P2) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| balanced | 17 | 0-16-1 | 4 |  |
| timing | 17 | 0-13-4 | 3 | economy x1 |
| economy | 4 | 0-4-0 | 1 |  |

- brood (P1): first read NORMAL 38; plan at the end balanced 16, timing 13, economy 9; 2026-11-15 opening picks balanced 17, timing 13, economy 8.
- brood (P2): first read NORMAL 38; plan at the end balanced 17, timing 16, economy 5; 2026-11-15 opening picks balanced 17, timing 17, economy 4.

### Research (games, median time)

- **brood (P1)**: nb_clutch_raptor 38 (5:55); nb_pack_hunt 37 (6:30); nb_slither 11 (7:35); nb_clutch_spitter 17 (8:25); nb_quick_roots 9 (9:00); nb_long_spit 3 (9:40); nb_fog 5 (9:45); nb_battering_horns 4 (9:45); nb_miasma 2 (10:20); nb_updraft 1 (10:20); nb_swamp_mending 2 (11:22)
- **brood (P2)**: nb_clutch_raptor 38 (5:55); nb_pack_hunt 37 (6:20); nb_clutch_spitter 3 (7:55); nb_slither 3 (8:30); nb_fog 7 (9:35); nb_quick_roots 16 (9:37); nb_battering_horns 2 (10:10); nb_miasma 5 (10:15); nb_updraft 1 (10:50); nb_swamp_mending 1 (11:30)

### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)

| map | now r0 | now r1 | 2026-11-15 r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |
|---|---|---|---|---|---|---|
| amberfall_vale | = P1 | = P1 | W P1 10:47 | w P1 | balanced / economy | balanced / timing |
| ashfall | w P1 | l P1 | w P1 | = P1 | balanced / timing | balanced / timing |
| ashford_crossing | W P1 10:55 | w P1 | W P1 11:42 | w P1 | balanced / timing | timing / balanced |
| border_march | w P1 | w P1 | l P1 | = P1 | balanced / balanced | timing / timing |
| cinder_steps | W P1 11:27 | = P1 | W P1 9:54 | = P1 | timing / timing | timing / balanced |
| dune_sea | w P1 | l P1 | l P1 | l P1 | timing / timing | timing / balanced |
| frostfang | = P1 | = P1 | w P1 | = P1 | balanced / timing | timing / balanced |
| frostmere | = P1 | = P1 | w P1 | l P1 | balanced / timing | economy / balanced |
| glimmerdeep | = P1 | l P1 | w P1 | w P1 | timing / timing | timing / balanced |
| greenhold | w P1 | l P1 | w P1 | w P1 | balanced / economy | economy / timing |
| highmoor | = P1 | = P1 | w P1 | w P1 | timing / balanced | economy / balanced |
| hollowfen | w P1 | l P1 | w P1 | w P1 | balanced / timing | timing / balanced |
| kestrel_rise | = P1 | w P1 | = P1 | L P1 11:24 | economy / balanced | balanced / timing |
| mirewood | l P1 | l P1 | l P1 | l P1 | balanced / balanced | timing / balanced |
| red_coast | = P1 | w P1 | = P1 | w P1 | balanced / economy | balanced / balanced |
| redrock_canyon | = P1 | l P1 | w P1 | w P1 | economy / economy | timing / economy |
| saltmarsh_isles | = P1 | = P1 | = P1 | = P1 | economy / timing | balanced / timing |
| thornwood_maze | W P1 11:48 | W P1 11:32 | w P1 | w P1 | balanced / economy | timing / timing |
| twin_fords | = P1 | W P1 11:10 | w P1 | w P1 | balanced / balanced | balanced / balanced |

## Clockwork v Clockwork (P1)

W-D-L **2-35-1**, won or led first / second / even **19 / 15 / 4**, decided 3 (11:31); 2026-11-12 cut at the same time: 1-36-1, 19 / 13 / 6, 2 (11:43).

Paired on the same 38 tags: the first side's result better in 12, worse in 13 (sign test p 1.000); its income ratio at 8:00 x0.96 of the old (geometric mean; up in 15 of 38, p 0.256; paired t -1.7).

Spot A (P1) v spot B, won or led (even draws dropped): now 19 v 15 (p 0.608); 2026-11-12 19 v 13 (p 0.377).

- now: classic maps A 11 v B 6; named maps A 8 v B 9
- 2026-11-12: classic maps A 9 v B 6; named maps A 10 v B 7

| first / second | income 5:00 | 8:00 | 10:00 | 12:00 | army 5:00 | 8:00 | 10:00 | 12:00 |
|---|---|---|---|---|---|---|---|---|
| now | 1.00 | 0.99 | 1.02 | 1.03 | 1.02 | 1.07 | 1.23 | 1.31 |
| 2026-11-12 | 1.04 | 1.04 | 1.04 | 1.06 | 1.04 | 1.25 | 1.32 | 1.43 |

(sums over the games still running at that minute)

| side | /min 5:00 | 8:00 | 10:00 | 12:00 | earned/bench 5:00 | 8:00 | 10:00 | workers 8:00 | halls 8:00 | 12:00 | 2026-11-12 earned/bench 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| clockwork (P1) | 1,502 | 2,492 | 2,750 | 2,537 | 1.00 | 1.04 | 1.08 | 47 | 3 | 4 | 0.95 |
| clockwork (P2) | 1,501 | 2,576 | 2,666 | 1,914 | 1.00 | 1.05 | 1.06 | 47 | 3 | 4 | 0.92 |

Built halls lost per game: first 0.82, second 1.24 (2026-11-12: 0.68, 1.32). First hall lost (median, games): first 10:12 (12), second 10:10 (18). First attack (median): first 5:50 (36), second 5:50 (34). Decided games' length: mean 11:31, median 11:35.

### OPTIMAL's picks

| clockwork (P1) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| balanced | 30 | 2-27-1 | 16 |  |
| economy | 6 | 0-6-0 | 3 | balanced x1 |
| springer | 2 | 0-2-0 | 0 |  |

| clockwork (P2) opening pick (read -> plan) | games | its W-D-L | its won or led | later switches |
|---|---|---|---|---|
| balanced | 29 | 1-27-1 | 13 |  |
| economy | 6 | 0-6-0 | 1 |  |
| springer | 3 | 0-2-1 | 1 |  |

- clockwork (P1): first read GREEDY 22, NORMAL 13, UNKNOWN 3; plan at the end balanced 31, economy 5, springer 2; 2026-11-12 opening picks balanced 37, springer 1.
- clockwork (P2): first read GREEDY 20, NORMAL 16, UNKNOWN 2; plan at the end balanced 29, economy 6, springer 3; 2026-11-12 opening picks balanced 36, economy 1, springer 1.

### Research (games, median time)

- **clockwork (P1)**: shield_wall 37 (7:25); long_chain 27 (8:00); high_leap 14 (9:40)
- **clockwork (P2)**: shield_wall 34 (7:35); long_chain 20 (7:55); high_leap 16 (9:07)

### Per map (first side: r0 / r1 with its slot; W L win/loss, w l led/trailed a draw, = even)

| map | now r0 | now r1 | 2026-11-12 r0 | r1 | first side's pick r0 / r1 | second's r0 / r1 |
|---|---|---|---|---|---|---|
| amberfall_vale | l P1 | l P1 | W P1 11:44 | l P1 | balanced / balanced | balanced / balanced |
| ashfall | l P1 | w P1 | w P1 | w P1 | springer / economy | springer / balanced |
| ashford_crossing | w P1 | w P1 | = P1 | w P1 | balanced / balanced | economy / springer |
| border_march | l P1 | w P1 | = P1 | w P1 | balanced / economy | balanced / balanced |
| cinder_steps | L P1 11:52 | w P1 | w P1 | w P1 | balanced / balanced | balanced / balanced |
| dune_sea | w P1 | l P1 | = P1 | w P1 | balanced / springer | economy / economy |
| frostfang | w P1 | w P1 | w P1 | l P1 | economy / balanced | economy / balanced |
| frostmere | l P1 | l P1 | l P1 | w P1 | balanced / balanced | balanced / balanced |
| glimmerdeep | w P1 | l P1 | w P1 | w P1 | balanced / economy | balanced / balanced |
| greenhold | w P1 | = P1 | l P1 | w P1 | balanced / balanced | balanced / balanced |
| highmoor | w P1 | l P1 | = P1 | w P1 | balanced / economy | balanced / balanced |
| hollowfen | l P1 | = P1 | w P1 | = P1 | balanced / balanced | balanced / balanced |
| kestrel_rise | w P1 | W P1 11:35 | L P1 11:43 | w P1 | balanced / balanced | balanced / balanced |
| mirewood | w P1 | l P1 | l P1 | l P1 | balanced / balanced | economy / balanced |
| red_coast | w P1 | W P1 11:08 | l P1 | l P1 | balanced / balanced | economy / springer |
| redrock_canyon | = P1 | l P1 | w P1 | = P1 | balanced / balanced | balanced / balanced |
| saltmarsh_isles | w P1 | w P1 | l P1 | l P1 | balanced / balanced | balanced / balanced |
| thornwood_maze | l P1 | = P1 | l P1 | l P1 | balanced / balanced | balanced / balanced |
| twin_fords | l P1 | w P1 | w P1 | w P1 | economy / balanced | balanced / balanced |

