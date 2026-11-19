# Scout deny study: tables

Made by tools/study/scout_deny_report.py from docs/scout_deny/data. ON = the rule as built, OFF = `scoutdeny:off`; the same games (tag = map, seed, sides) in every arm. Games: OFF 48, ON_V1 48, ON 48.

## The first scout, by matchup (scouter -> denier)

| scouter -> denier | arm | first scouts | brought a read | killed | median death | its scouts lost a game | GREEDY read by 5:00 |
|---|---|---|---|---|---|---|---|
| crown -> crown | OFF | 16 | 0% (0/16) | 100% (16/16) | 1:51 | 3.06 | 12% (2/16) |
| crown -> crown | ON_V1 | 16 | 0% (0/16) | 100% (16/16) | 1:51 | 3.56 | 6% (1/16) |
| crown -> crown | ON | 16 | 0% (0/16) | 100% (16/16) | 1:51 | 3.75 | 0% (0/16) |
| crown -> clockwork | OFF | 8 | 100% (8/8) | 75% (6/8) | 1:24 | 3.88 | 100% (8/8) |
| crown -> clockwork | ON_V1 | 8 | 100% (8/8) | 50% (4/8) | 1:24 | 3.38 | 100% (8/8) |
| crown -> clockwork | ON | 8 | 100% (8/8) | 38% (3/8) | 1:20 | 3.12 | 100% (8/8) |
| crown -> brood | OFF | 8 | 100% (8/8) | 0% (0/8) | - | 1.25 | 100% (8/8) |
| crown -> brood | ON_V1 | 8 | 100% (8/8) | 25% (2/8) | 1:21 | 3.00 | 100% (8/8) |
| crown -> brood | ON | 8 | 100% (8/8) | 50% (4/8) | 1:21 | 3.12 | 100% (8/8) |
| clockwork -> crown | OFF | 8 | 0% (0/8) | 0% (0/8) | - | 2.12 | 0% (0/8) |
| clockwork -> crown | ON_V1 | 8 | 0% (0/8) | 0% (0/8) | - | 2.88 | 12% (1/8) |
| clockwork -> crown | ON | 8 | 0% (0/8) | 0% (0/8) | - | 2.75 | 0% (0/8) |
| clockwork -> clockwork | OFF | 16 | 94% (15/16) | 0% (0/16) | - | 2.50 | 44% (7/16) |
| clockwork -> clockwork | ON_V1 | 16 | 62% (10/16) | 0% (0/16) | - | 2.75 | 50% (8/16) |
| clockwork -> clockwork | ON | 16 | 81% (13/16) | 0% (0/16) | - | 3.56 | 81% (13/16) |
| clockwork -> brood | OFF | 8 | 100% (8/8) | 0% (0/8) | - | 1.25 | 100% (8/8) |
| clockwork -> brood | ON_V1 | 8 | 75% (6/8) | 0% (0/8) | - | 1.88 | 0% (0/8) |
| clockwork -> brood | ON | 8 | 75% (6/8) | 0% (0/8) | - | 1.88 | 0% (0/8) |
| brood -> crown | OFF | 8 | 100% (8/8) | 25% (2/8) | 3:04 | 1.88 | 12% (1/8) |
| brood -> crown | ON_V1 | 8 | 100% (8/8) | 25% (2/8) | 3:25 | 1.75 | 12% (1/8) |
| brood -> crown | ON | 8 | 100% (8/8) | 38% (3/8) | 3:10 | 2.00 | 0% (0/8) |
| brood -> clockwork | OFF | 8 | 100% (8/8) | 0% (0/8) | - | 0.88 | 100% (8/8) |
| brood -> clockwork | ON_V1 | 8 | 100% (8/8) | 38% (3/8) | 1:55 | 1.00 | 100% (8/8) |
| brood -> clockwork | ON | 8 | 100% (8/8) | 25% (2/8) | 2:07 | 1.00 | 100% (8/8) |
| brood -> brood | OFF | 16 | 100% (16/16) | 6% (1/16) | 6:09 | 1.56 | 0% (0/16) |
| brood -> brood | ON_V1 | 16 | 100% (16/16) | 0% (0/16) | - | 1.38 | 0% (0/16) |
| brood -> brood | ON | 16 | 100% (16/16) | 25% (4/16) | 3:16 | 1.81 | 0% (0/16) |

## What the rule did, by the denying faction (per player a game)

| denier | arm | players | hunts sent | scouts killed | chases given up | none fit (looks) | workers sent | workers lost | hunters lost | first kill (median) |
|---|---|---|---|---|---|---|---|---|---|---|
| crown | ON_V1 | 32 | 4.2 | 2.1 | 2.0 | 20.9 | 1.2 | 0.00 | 0.09 | 4:33 |
| crown | ON | 32 | 4.0 | 2.0 | 2.0 | 20.8 | 0.9 | 0.00 | 0.06 | 4:26 |
| clockwork | ON_V1 | 32 | 3.8 | 1.7 | 2.2 | 3.8 | 2.1 | 0.00 | 0.19 | 5:16 |
| clockwork | ON | 32 | 4.1 | 1.8 | 2.3 | 2.8 | 2.4 | 0.00 | 0.06 | 5:19 |
| brood | ON_V1 | 32 | 3.7 | 1.2 | 2.5 | 4.7 | 2.3 | 0.12 | 0.12 | 5:44 |
| brood | ON | 32 | 4.1 | 1.4 | 2.6 | 6.9 | 2.5 | 0.06 | 0.06 | 5:21 |

Kills by the scout's kind (ON):

- brood killed: Grub 20, Labourer 17, Winder 7, Raptors 1
- clockwork killed: Winder 35, Labourer 14, Grub 4, Raptors 2, Missionary 1
- crown killed: Labourer 30, Winder 26, Horseman 3, Raptors 2, Dragoon 2, Grub 1

## The pairings: income and outcome (the first-named faction's view; P1 in a mirror)

| pairing | arm | games | income 5:00 (it / foe) | income 8:00 (it / foe) | W-D-L | won or led / trailed / even | paired ON v OFF better / worse (p) |
|---|---|---|---|---|---|---|---|
| Crown v Brood | OFF | 8 | 3,040 / 2,784 | 6,365 / 6,737 | 0-8-0 | 0 / 6 / 2 |  |
| Crown v Brood | ON_V1 | 8 | 2,850 / 2,652 | 6,602 / 6,890 | 0-8-0 | 2 / 4 / 2 | 3 / 0 (p 0.25) |
| Crown v Brood | ON | 8 | 2,945 / 2,575 | 6,412 / 6,640 | 0-8-0 | 0 / 6 / 2 | 0 / 0 (p 1.00) |
| Crown v Clockwork | OFF | 8 | 2,992 / 4,180 | 7,077 / 9,801 | 0-8-0 | 0 / 7 / 1 |  |
| Crown v Clockwork | ON_V1 | 8 | 2,945 / 4,120 | 6,840 / 9,546 | 0-8-0 | 0 / 8 / 0 | 0 / 1 (p 1.00) |
| Crown v Clockwork | ON | 8 | 2,992 / 4,096 | 6,982 / 9,518 | 0-8-0 | 0 / 8 / 0 | 0 / 1 (p 1.00) |
| Brood v Clockwork | OFF | 8 | 2,443 / 3,833 | 7,080 / 8,442 | 0-8-0 | 1 / 7 / 0 |  |
| Brood v Clockwork | ON_V1 | 8 | 2,293 / 3,700 | 6,423 / 7,775 | 0-5-3 | 3 / 5 / 0 | 3 / 1 (p 0.62) |
| Brood v Clockwork | ON | 8 | 2,275 / 3,883 | 6,057 / 8,320 | 0-6-2 | 1 / 7 / 0 | 1 / 1 (p 1.00) |
| Crown mirror | OFF | 8 | 3,230 / 3,182 | 7,505 / 7,505 | 0-8-0 | 4 / 3 / 1 |  |
| Crown mirror | ON_V1 | 8 | 3,277 / 3,277 | 7,505 / 7,315 | 0-8-0 | 4 / 2 / 2 | 3 / 3 (p 1.00) |
| Crown mirror | ON | 8 | 3,277 / 3,230 | 7,552 / 7,172 | 0-8-0 | 3 / 4 / 1 | 1 / 2 (p 1.00) |
| Brood mirror | OFF | 8 | 3,457 / 3,330 | 8,886 / 8,765 | 3-3-2 | 4 / 3 / 1 |  |
| Brood mirror | ON_V1 | 8 | 3,575 / 3,493 | 8,965 / 8,934 | 1-6-1 | 3 / 2 / 3 | 4 / 3 (p 1.00) |
| Brood mirror | ON | 8 | 3,460 / 3,321 | 8,828 / 8,756 | 0-8-0 | 2 / 5 / 1 | 1 / 4 (p 0.38) |
| Clockwork mirror | OFF | 8 | 4,318 / 4,289 | 10,070 / 9,875 | 0-8-0 | 4 / 2 / 2 |  |
| Clockwork mirror | ON_V1 | 8 | 4,229 / 4,247 | 9,785 / 9,892 | 0-8-0 | 3 / 4 / 1 | 0 / 2 (p 0.50) |
| Clockwork mirror | ON | 8 | 4,327 / 4,265 | 10,452 / 10,171 | 0-8-0 | 2 / 2 / 4 | 1 / 3 (p 0.62) |

## GREEDY reads and what OPTIMAL picked from them

**OFF**: 41 picks on a GREEDY read.

| game | player | at | pick | at 12:00 |
|---|---|---|---|---|
| base_ashford_crossing_brcw_r0 | P1 clockwork | 1:51 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_ashford_crossing_brcw_r0 | P2 brood | 1:50 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_ashford_crossing_brcw_r0 | P2 brood | 4:50 | middle GREEDY -> timing (a timing attack before its economy pays off) | drew |
| base_ashford_crossing_brcw_r1 | P1 brood | 1:51 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_ashford_crossing_brcw_r1 | P2 clockwork | 1:56 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_ashford_crossing_crbr_r1 | P2 brood | 7:14 | middle GREEDY -> economy (too late to punish: out-expand it) | drew |
| base_ashford_crossing_crcw_r0 | P2 crown | 5:52 | middle GREEDY -> balloon (raids on its workers) | drew |
| base_ashford_crossing_cwcw_r0 | P1 clockwork | 2:22 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_ashford_crossing_cwcw_r0 | P2 clockwork | 2:22 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_dune_sea_brcw_r0 | P1 brood | 1:42 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_dune_sea_brcw_r0 | P1 brood | 4:37 | middle GREEDY -> timing (a timing attack before its economy pays off) | drew |
| base_dune_sea_brcw_r0 | P2 clockwork | 1:59 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_dune_sea_brcw_r1 | P1 clockwork | 1:41 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_dune_sea_brcw_r1 | P2 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_dune_sea_crbr_r0 | P1 crown | 1:29 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_dune_sea_crbr_r1 | P2 crown | 1:43 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_dune_sea_crcr_r1 | P1 crown | 5:32 | middle GREEDY -> economy (too late to punish: out-expand it) | drew |
| base_dune_sea_cwcw_r1 | P1 clockwork | 2:22 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_greenhold_brbr_r0 | P1 brood | 7:27 | middle GREEDY -> economy (too late to punish: out-expand it) | won |
| base_greenhold_brcw_r0 | P1 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_greenhold_brcw_r0 | P1 brood | 4:37 | middle GREEDY -> timing (a timing attack before its economy pays off) | drew |
| base_greenhold_brcw_r0 | P2 clockwork | 2:00 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_greenhold_brcw_r1 | P1 clockwork | 1:42 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_greenhold_brcw_r1 | P2 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_greenhold_brcw_r1 | P2 brood | 4:40 | middle GREEDY -> timing (a timing attack before its economy pays off) | drew |
| base_greenhold_crbr_r1 | P2 crown | 1:45 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_greenhold_crcw_r1 | P1 clockwork | 5:05 | middle GREEDY -> springer (a timing attack before its economy pays off) | drew |
| base_hollowfen_brcw_r0 | P1 clockwork | 1:49 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_hollowfen_brcw_r0 | P2 brood | 1:50 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_hollowfen_brcw_r1 | P1 brood | 1:51 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_hollowfen_brcw_r1 | P2 clockwork | 2:06 | opening GREEDY -> balanced (its first ground is its usual opening: the economy goes on, a Light Works ready for its Raptors) | drew |
| base_hollowfen_crbr_r0 | P2 crown | 1:48 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_hollowfen_crbr_r1 | P1 crown | 1:33 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_hollowfen_crcr_r0 | P1 crown | 6:15 | middle GREEDY -> economy (too late to punish: out-expand it) | drew |
| base_hollowfen_crcr_r0 | P2 crown | 4:58 | middle GREEDY -> timing (Horsemen are no answer to Musketeers: a timing attack) | drew |
| base_hollowfen_crcr_r1 | P1 crown | 4:47 | middle GREEDY -> timing (Horsemen are no answer to Musketeers: a timing attack) | drew |
| base_hollowfen_crcr_r1 | P2 crown | 5:26 | middle GREEDY -> timing (Horsemen are no answer to Musketeers: a timing attack) | drew |
| base_hollowfen_cwcw_r0 | P1 clockwork | 2:23 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_hollowfen_cwcw_r0 | P2 clockwork | 2:30 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_hollowfen_cwcw_r1 | P1 clockwork | 2:31 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_hollowfen_cwcw_r1 | P2 clockwork | 2:30 | opening GREEDY -> balanced (steady waves punish the greed) | drew |

**ON_V1**: 23 picks on a GREEDY read.

| game | player | at | pick | at 12:00 |
|---|---|---|---|---|
| base_ashford_crossing_brcw_r0 | P2 brood | 1:50 | opening GREEDY -> rush (punish the greed before its army is up) | lost |
| base_ashford_crossing_brcw_r0 | P2 brood | 4:47 | middle GREEDY -> timing (a timing attack before its economy pays off) | lost |
| base_ashford_crossing_brcw_r1 | P1 brood | 1:51 | opening GREEDY -> rush (punish the greed before its army is up) | lost |
| base_ashford_crossing_crbr_r1 | P2 brood | 8:16 | middle GREEDY -> economy (too late to punish: out-expand it) | drew |
| base_dune_sea_brcw_r0 | P1 brood | 1:42 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_dune_sea_brcw_r1 | P2 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_dune_sea_crbr_r0 | P1 crown | 1:29 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_dune_sea_crbr_r1 | P2 crown | 1:43 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_dune_sea_cwcw_r1 | P2 clockwork | 2:51 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_greenhold_brcw_r0 | P1 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_greenhold_brcw_r0 | P1 brood | 4:36 | middle GREEDY -> timing (a timing attack before its economy pays off) | drew |
| base_greenhold_brcw_r1 | P2 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | lost |
| base_greenhold_crbr_r1 | P2 crown | 1:45 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_greenhold_cwcw_r0 | P1 clockwork | 2:50 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_greenhold_cwcw_r1 | P2 clockwork | 2:10 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_hollowfen_brcw_r0 | P2 brood | 1:50 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_hollowfen_brcw_r1 | P1 brood | 1:51 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_hollowfen_brcw_r1 | P1 brood | 6:12 | middle GREEDY -> economy (too late to punish: out-expand it) | drew |
| base_hollowfen_crbr_r0 | P2 crown | 1:48 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_hollowfen_crbr_r1 | P1 crown | 4:58 | middle GREEDY -> economy (too late for the riders: out-expand it) | drew |
| base_hollowfen_crcr_r0 | P1 crown | 4:45 | middle GREEDY -> timing (Horsemen are no answer to Musketeers: a timing attack) | drew |
| base_hollowfen_crcw_r1 | P2 clockwork | 4:51 | middle GREEDY -> springer (a timing attack before its economy pays off) | drew |
| base_hollowfen_cwcw_r1 | P1 clockwork | 2:25 | opening GREEDY -> balanced (steady waves punish the greed) | drew |

**ON**: 25 picks on a GREEDY read.

| game | player | at | pick | at 12:00 |
|---|---|---|---|---|
| base_ashford_crossing_brcw_r0 | P2 brood | 1:50 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_ashford_crossing_brcw_r1 | P1 brood | 1:51 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_ashford_crossing_brcw_r1 | P1 brood | 4:47 | middle GREEDY -> timing (a timing attack before its economy pays off) | drew |
| base_ashford_crossing_crbr_r1 | P1 crown | 1:37 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_ashford_crossing_cwcw_r0 | P1 clockwork | 2:58 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_ashford_crossing_cwcw_r0 | P2 clockwork | 2:57 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_dune_sea_brcw_r0 | P1 brood | 1:42 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_dune_sea_brcw_r1 | P2 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_dune_sea_crbr_r0 | P1 crown | 1:29 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_dune_sea_crbr_r1 | P2 crown | 1:24 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_dune_sea_cwcw_r0 | P1 clockwork | 2:51 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_dune_sea_cwcw_r0 | P2 clockwork | 2:51 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_dune_sea_cwcw_r1 | P1 clockwork | 2:51 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_dune_sea_cwcw_r1 | P2 clockwork | 2:51 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_greenhold_brcw_r0 | P1 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | lost |
| base_greenhold_brcw_r1 | P2 brood | 1:41 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_greenhold_brcw_r1 | P2 brood | 4:32 | middle GREEDY -> timing (a timing attack before its economy pays off) | drew |
| base_greenhold_crbr_r1 | P2 crown | 1:45 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_greenhold_cwcw_r0 | P1 clockwork | 2:50 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_greenhold_cwcw_r1 | P1 clockwork | 2:50 | opening GREEDY -> balanced (steady waves punish the greed) | drew |
| base_hollowfen_brcw_r0 | P2 brood | 1:50 | opening GREEDY -> rush (punish the greed before its army is up) | lost |
| base_hollowfen_brcw_r1 | P1 brood | 1:51 | opening GREEDY -> rush (punish the greed before its army is up) | drew |
| base_hollowfen_crbr_r0 | P2 crown | 1:19 | opening GREEDY -> rush (punish the greed: the Horse Breeder at once, the riders before its army) | drew |
| base_hollowfen_crbr_r1 | P1 crown | 4:59 | middle GREEDY -> economy (too late for the riders: out-expand it) | drew |
| base_hollowfen_cwcw_r0 | P1 clockwork | 2:25 | opening GREEDY -> balanced (steady waves punish the greed) | drew |


## Workers at 5:00 and 8:00 (mean per player, by faction)

| faction | arm | workers 5:00 | workers 8:00 |
|---|---|---|---|
| crown | OFF | 23.1 | 38.6 |
| crown | ON_V1 | 22.8 | 38.3 |
| crown | ON | 22.8 | 37.7 |
| clockwork | OFF | 26.9 | 40.5 |
| clockwork | ON_V1 | 26.3 | 38.6 |
| clockwork | ON | 26.8 | 40.8 |
| brood | OFF | 28.8 | 47.1 |
| brood | ON_V1 | 28.0 | 46.3 |
| brood | ON | 27.4 | 46.2 |
