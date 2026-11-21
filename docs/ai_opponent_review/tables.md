# AI opponent review: tables (tools/study/ai_opponent_review_report.py)

161 games with a result.

## The matrix: Hard OPTIMAL v Hard OPTIMAL to 20:00

Read from the first-named side (mirrors: P1 = spot A). W-D-L = won, drawn at the bell, lost. Won or led = first / second / even. The 12:00 cut beside the 2026-11-17 study's games on the same tags.

| pairing | games | W-D-L 20:00 | won or led 20:00 | median end of decided | W-D-L 12:00 | won or led 12:00 | 11-17 same tags (12:00) | paired better / worse (p) |
|---|---|---|---|---|---|---|---|---|
| Crown v Brood | 12 | 0-8-4 | 3 / 8 / 1 | 17:16 | 0-12-0 | 9 / 2 / 1 | 2 / 9 / 1 | 9 / 1 (0.02) |
| Crown v Clockwork | 11 | 2-8-1 | 7 / 2 / 2 | 14:39 | 0-11-0 | 2 / 5 / 4 | 0 / 10 / 1 | 6 / 1 (0.12) |
| Brood v Clockwork | 12 | 4-4-4 | 6 / 6 / 0 | 15:52 | 0-11-1 | 2 / 8 / 2 | 0 / 11 / 1 | 4 / 1 (0.38) |
| Crown v Crown (P1) | 12 | 4-5-3 | 6 / 6 / 0 | 18:08 | 0-12-0 | 5 / 3 / 4 | 4 / 6 / 2 | 5 / 3 (0.73) |
| Brood v Brood (P1) | 12 | 3-8-1 | 5 / 4 / 3 | 14:14 | 0-12-0 | 5 / 2 / 5 | 6 / 3 / 3 | 2 / 3 (1.00) |
| Clockwork v Clockwork (P1) | 12 | 2-4-6 | 2 / 6 / 4 | 13:31 | 0-11-1 | 4 / 6 / 2 | 7 / 3 / 2 | 2 / 6 (0.29) |

## The benchmark players against the computer (to 15:00)

Each cell is the HUMAN-LIKE PLAYER's record against that computer (all three benchmark factions together): won-drawn-lost (W-D-L at 15:00), then won or led / trailed / even at the bell. The owner's targets: a novice usually beats Easy; an average player has close games with Normal; a good player finds Hard a real fight.

### NOVICE player

| computer | v EASY | v NORMAL | v HARD |
|---|---|---|---|
| Crown computer | 1-2-0 (2 / 0 / 1) | 0-2-1 (0 / 3 / 0) | 0-3-0 (1 / 2 / 0) |
| Brood computer | 0-1-2 (0 / 3 / 0) | 0-0-3 (0 / 3 / 0) | 0-1-2 (0 / 2 / 1) |
| Clockwork computer | 1-1-1 (2 / 1 / 0) | 1-1-1 (2 / 1 / 0) | 0-1-2 (0 / 3 / 0) |
| **all** | 2-4-3 (4 / 4 / 1) | 1-3-5 (2 / 7 / 0) | 0-5-4 (1 / 7 / 1) |

### AVERAGE player

| computer | v EASY | v NORMAL | v HARD |
|---|---|---|---|
| Crown computer | 2-1-0 (3 / 0 / 0) | 0-3-0 (0 / 2 / 1) | 0-2-1 (1 / 2 / 0) |
| Brood computer | 0-1-2 (1 / 2 / 0) | 0-1-2 (0 / 3 / 0) | 0-0-3 (0 / 3 / 0) |
| Clockwork computer | 2-1-0 (2 / 1 / 0) | 0-2-1 (2 / 1 / 0) | 0-0-3 (0 / 3 / 0) |
| **all** | 4-3-2 (6 / 3 / 0) | 0-6-3 (2 / 6 / 1) | 0-2-7 (1 / 8 / 0) |

### GOOD player

| computer | v EASY | v NORMAL | v HARD |
|---|---|---|---|
| Crown computer | 2-1-0 (3 / 0 / 0) | 1-2-0 (1 / 2 / 0) | 0-3-0 (0 / 1 / 2) |
| Brood computer | 0-1-2 (1 / 2 / 0) | 1-2-0 (1 / 1 / 1) | 0-0-3 (0 / 3 / 0) |
| Clockwork computer | 3-0-0 (3 / 0 / 0) | 1-1-1 (1 / 2 / 0) | 0-2-1 (0 / 2 / 1) |
| **all** | 5-2-2 (7 / 2 / 0) | 3-5-1 (3 / 5 / 1) | 0-5-4 (0 / 6 / 3) |

### By the benchmark player's own faction (all computers together)

| player | v EASY | v NORMAL | v HARD |
|---|---|---|---|
| novice Crown | 0-2-1 (0 / 2 / 1) | 0-2-1 (1 / 2 / 0) | 0-2-1 (1 / 2 / 0) |
| novice Brood | 1-1-1 (2 / 1 / 0) | 0-1-2 (0 / 3 / 0) | 0-1-2 (0 / 3 / 0) |
| novice Clockwork | 1-1-1 (2 / 1 / 0) | 1-0-2 (1 / 2 / 0) | 0-2-1 (0 / 2 / 1) |
| average Crown | 1-1-1 (1 / 2 / 0) | 0-3-0 (1 / 2 / 0) | 0-1-2 (1 / 2 / 0) |
| average Brood | 2-0-1 (2 / 1 / 0) | 0-1-2 (0 / 2 / 1) | 0-0-3 (0 / 3 / 0) |
| average Clockwork | 1-2-0 (3 / 0 / 0) | 0-2-1 (1 / 2 / 0) | 0-1-2 (0 / 3 / 0) |
| good Crown | 2-0-1 (2 / 1 / 0) | 1-2-0 (1 / 2 / 0) | 0-2-1 (0 / 1 / 2) |
| good Brood | 2-0-1 (2 / 1 / 0) | 1-2-0 (1 / 1 / 1) | 0-1-2 (0 / 3 / 0) |
| good Clockwork | 1-2-0 (3 / 0 / 0) | 1-1-1 (1 / 2 / 0) | 0-2-1 (0 / 2 / 1) |

### Economy at 8:00 and decided games

| strength | level | games | human income / computer at 8:00 (median) | human workers / computer at 8:00 | computer wins: median end | human wins: median end |
|---|---|---|---|---|---|---|
| novice | easy | 9 | 0.95 | 1.41 | 11:53 | 13:35 |
| novice | normal | 9 | 0.82 | 0.73 | 13:20 | 14:06 |
| novice | hard | 9 | 0.79 | 0.55 | 12:10 | - |
| average | easy | 9 | 1.09 | 1.73 | 13:46 | 14:16 |
| average | normal | 9 | 0.97 | 1.00 | 12:05 | - |
| average | hard | 9 | 0.87 | 0.73 | 12:25 | - |
| good | easy | 9 | 1.29 | 2.18 | 12:01 | 11:46 |
| good | normal | 9 | 1.15 | 1.05 | 14:16 | 11:38 |
| good | hard | 9 | 0.95 | 0.78 | 13:29 | - |

## Sanity: the benchmark players against each other (from the stronger one's side)

| game | stronger | weaker | result | end |
|---|---|---|---|---|
| sanity_braverage_v_brnovice_cinder_steps | average Brood | novice Brood | L | 11:40 |
| sanity_brgood_v_craverage_hollowfen | good Brood | average Crown | W | 12:44 |
| sanity_brgood_v_cwnovice_ashford_crossing | good Brood | novice Clockwork | = | 15:00 |
| sanity_craverage_v_crnovice_frostfang | average Crown | novice Crown | w | 15:00 |
| sanity_crgood_v_brnovice_greenhold | good Crown | novice Brood | w | 15:00 |
| sanity_crgood_v_cwaverage_dune_sea | good Crown | average Clockwork | l | 15:00 |
| sanity_cwaverage_v_cwnovice_frostfang | average Clockwork | novice Clockwork | W | 14:36 |
| sanity_cwgood_v_braverage_dune_sea | good Clockwork | average Brood | W | 11:33 |
| sanity_cwgood_v_crnovice_greenhold | good Clockwork | novice Crown | w | 15:00 |

Stronger player won or led 6 of 9 (lost or trailed 2).

## Blunder scan (computer sides only)

Per computer level, the share of its games with each event (the match tool's own detectors), and how often. army idle = its army stood still (fewer than a quarter fighting) while 300+ of the enemy was in its base for the stall's length; bank = 400+ unspent for a minute; no units = nothing made for 90 s below the supply cap; stuck = a unit stuck on a move order; bad first attack = its first attack lost 2x what it killed; no attack = no wave of its own and none of its armies arrived in the enemy's base by 12:00; one hall = still one hall at 10:00.

| computer | games | army idle | bank | no units | stuck | bad first attack | no attack by 12:00 | one hall at 10:00 |
|---|---|---|---|---|---|---|---|---|
| Brood EASY | 9 | 0% | 0% | 0% | 0% | 0% | 0% | 0% |
| Brood HARD | 57 | 0% | 4% (2) | 0% | 5% (12) | 0% | 2% | 0% |
| Brood NORMAL | 9 | 0% | 11% (1) | 0% | 11% (8) | 0% | 0% | 0% |
| Clockwork EASY | 9 | 0% | 0% | 0% | 11% (1) | 0% | 0% | 56% |
| Clockwork HARD | 56 | 0% | 0% | 4% (2) | 4% (5) | 0% | 9% | 5% |
| Clockwork NORMAL | 9 | 0% | 0% | 0% | 0% | 0% | 0% | 22% |
| Crown EASY | 9 | 0% | 11% (1) | 11% (1) | 11% (2) | 0% | 11% | 56% |
| Crown HARD | 56 | 0% | 0% | 7% (4) | 34% (58) | 0% | 18% | 0% |
| Crown NORMAL | 9 | 0% | 0% | 0% | 22% (5) | 0% | 11% | 0% |

Examples:

- bank: base_dune_sea_brcw_r0 P1 Brood at 18:45; bench_braverage_v_creasy_greenhold_r0 P2 Crown at 3:30; bench_craverage_v_brhard_frostfang_r0 P2 Brood at 13:35; bench_crgood_v_brnormal_hollowfen_r0 P2 Brood at 13:20
- no units: base_ashford_crossing_brcw_r0 P1 Clockwork at 15:25; base_dune_sea_brcw_r0 P2 Clockwork at 16:15; base_dune_sea_crcr_r1 P1 Crown at 16:40; base_dune_sea_crcr_r1 P2 Crown at 17:30; base_frostfang_crcr_r0 P1 Crown at 12:05; base_frostfang_crcr_r1 P2 Crown at 16:20; bench_braverage_v_creasy_greenhold_r0 P2 Crown at 4:20
- stuck: base_ashford_crossing_brcw_r0 P2 Brood at 19:00; base_ashford_crossing_crbr_r1 P1 Crown at 11:40; base_ashford_crossing_crcr_r0 P1 Crown at 13:30; base_ashford_crossing_crcr_r1 P2 Crown at 9:40; base_ashford_crossing_crcw_r1 P1 Crown at 11:20; base_cinder_steps_brcw_r0 P2 Clockwork at 12:30; base_cinder_steps_crbr_r0 P1 Crown at 16:30; base_cinder_steps_crbr_r1 P2 Crown at 8:20
- no attack by 12:00: base_ashford_crossing_crbr_r0 P1 Brood; base_ashford_crossing_crbr_r1 P1 Crown; base_ashford_crossing_crcr_r0 P1 Crown; base_cinder_steps_crcr_r0 P1 Crown; base_cinder_steps_crcw_r1 P2 Crown; base_cinder_steps_cwcw_r1 P1 Clockwork; base_dune_sea_brcw_r0 P2 Clockwork; base_dune_sea_brcw_r1 P1 Clockwork
- one hall at 10:00: base_cinder_steps_cwcw_r0 P1 Clockwork; base_dune_sea_cwcw_r1 P1 Clockwork; base_hollowfen_cwcw_r1 P1 Clockwork; bench_braverage_v_creasy_greenhold_r0 P2 Crown; bench_brgood_v_creasy_ashford_crossing_r0 P1 Crown; bench_brgood_v_cweasy_ashford_crossing_r0 P1 Clockwork; bench_brnovice_v_creasy_ashford_crossing_r0 P1 Crown; bench_brnovice_v_cweasy_ashford_crossing_r0 P1 Clockwork

## fix: levelgrubs (the computer's side)
| game | before | after | army 8:00 before / after | income 8:00 before / after | end before / after |
|---|---|---|---|---|---|
| bench_braverage_v_breasy_ashford_crossing_r0 | W | l | 590 / 2365 | 9281 / 6092 | 826 / 900 |
| bench_braverage_v_brnormal_hollowfen_r0 | W | W | 690 / 2525 | 9151 / 9193 | 846 / 708 |
| bench_brgood_v_breasy_greenhold_r0 | W | L | 2550 / 2735 | 9747 / 6220 | 672 / 738 |
| bench_brgood_v_brnormal_dune_sea_r0 | = | L | 1000 / 1670 | 9544 / 8632 | 900 / 803 |
| bench_brnovice_v_breasy_greenhold_r0 | W | W | 2375 / 2590 | 9759 / 6292 | 621 / 702 |
| bench_brnovice_v_brnormal_dune_sea_r0 | W | W | 2095 / 1625 | 9400 / 8667 | 844 / 675 |
| bench_craverage_v_breasy_greenhold_r0 | W | W | 2800 / 2410 | 9842 / 6001 | 713 / 873 |
| bench_craverage_v_brnormal_dune_sea_r0 | w | w | 1795 / 1600 | 7703 / 7409 | 900 / 900 |
| bench_crgood_v_breasy_ashford_crossing_r0 | W | l | 3135 / 2515 | 9318 / 6438 | 721 / 900 |
| bench_crgood_v_brnormal_hollowfen_r0 | w | W | 1335 / 1640 | 7368 / 7330 | 900 / 882 |
| bench_crnovice_v_breasy_ashford_crossing_r0 | w | W | 1905 / 1765 | 8486 / 6244 | 900 / 802 |
| bench_crnovice_v_brnormal_hollowfen_r0 | W | w | 1425 / 1550 | 8550 / 8494 | 810 / 900 |
| bench_cwaverage_v_breasy_greenhold_r0 | l | L | 3060 / 2340 | 8570 / 5903 | 900 / 741 |
| bench_cwaverage_v_brnormal_dune_sea_r0 | W | W | 945 / 1250 | 5214 / 6344 | 725 / 584 |
| bench_cwgood_v_breasy_ashford_crossing_r0 | l | L | 2120 / 2350 | 7912 / 5885 | 900 / 741 |
| bench_cwgood_v_brnormal_hollowfen_r0 | L | W | 825 / 2225 | 6211 / 6711 | 695 / 518 |
| bench_cwnovice_v_breasy_ashford_crossing_r0 | W | l | 2230 / 1550 | 8857 / 5945 | 893 / 900 |
| bench_cwnovice_v_brnormal_hollowfen_r0 | W | W | 1275 / 1875 | 6155 / 6172 | 601 / 527 |

From that side: better 3, worse 8, the same 7.

## fix: easypace (the computer's side)
| game | before | after | army 8:00 before / after | income 8:00 before / after | end before / after |
|---|---|---|---|---|---|
| bench_braverage_v_breasy_ashford_crossing_r0 | W | W | 590 / 2115 | 9281 / 5906 | 826 / 633 |
| bench_brgood_v_breasy_greenhold_r0 | W | L | 2550 / 2190 | 9747 / 5953 | 672 / 702 |
| bench_brnovice_v_breasy_greenhold_r0 | W | W | 2375 / 1965 | 9759 / 5926 | 621 / 895 |
| bench_craverage_v_breasy_greenhold_r0 | W | l | 2800 / 2470 | 9842 / 5990 | 713 / 900 |
| bench_crgood_v_breasy_ashford_crossing_r0 | W | w | 3135 / 2620 | 9318 / 6257 | 721 / 900 |
| bench_crnovice_v_breasy_ashford_crossing_r0 | w | l | 1905 / 2000 | 8486 / 6313 | 900 / 900 |
| bench_cwaverage_v_breasy_greenhold_r0 | l | l | 3060 / 2235 | 8570 / 5811 | 900 / 900 |
| bench_cwgood_v_breasy_ashford_crossing_r0 | l | L | 2120 / 2240 | 7912 / 5669 | 900 / 690 |
| bench_cwnovice_v_breasy_ashford_crossing_r0 | W | L | 2230 / 1390 | 8857 / 6001 | 893 / 732 |

From that side: better 0, worse 6, the same 3.

## fix: ridersquad (the Brood's side)
| game | before | after | army 8:00 before / after | income 8:00 before / after | end before / after |
|---|---|---|---|---|---|
| base_ashford_crossing_crbr_r0 | l | W | 575 / 750 | 4440 / 4905 | 1200 / 1012 |
| base_ashford_crossing_crbr_r1 | w | l | 340 / 570 | 4801 / 5106 | 1200 / 1200 |
| base_cinder_steps_crbr_r0 | l | w | 475 / 575 | 3700 / 5024 | 1200 / 1200 |
| base_cinder_steps_crbr_r1 | w | l | 575 / 625 | 3177 / 3156 | 1200 / 1200 |
| base_dune_sea_crbr_r0 | W | w | 1125 / 575 | 5663 / 4009 | 949 / 1200 |
| base_dune_sea_crbr_r1 | w | w | 1225 / 375 | 6335 / 5829 | 1200 / 1200 |
| base_frostfang_crbr_r0 | W | w | 675 / 755 | 4952 / 5817 | 1129 / 1200 |
| base_frostfang_crbr_r1 | W | W | 1125 / 875 | 6131 / 5715 | 881 / 1120 |
| base_greenhold_crbr_r0 | = | W | 1050 / 530 | 5937 / 6041 | 1200 / 1009 |
| base_greenhold_crbr_r1 | l | W | 400 / 1225 | 4654 / 5941 | 1200 / 955 |
| base_hollowfen_crbr_r0 | W | w | 1125 / 500 | 4787 / 5139 | 1036 / 1200 |
| base_hollowfen_crbr_r1 | w | w | 775 / 625 | 4148 / 3807 | 1200 / 1200 |

From that side: better 4, worse 5, the same 3.
