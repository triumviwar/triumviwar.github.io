# Plan matrix: clockwork (240 games)

Read from the clockwork's side. W-D-L at the bell; won or led = W + a draw led by 10% (income earned + 2 x army).
v OPTIMAL = paired with OPTIMAL's game on the same map, seed and spots (better / worse, sign test p).

## Won or led

| plan | v Crown: won or led (W-D-L) | v OPTIMAL better/worse (p) | v Brood: won or led (W-D-L) | v OPTIMAL better/worse (p) | v Clockwork: won or led (W-D-L) | v OPTIMAL better/worse (p) | all |
|---|---|---|---|---|---|---|---|
| OPTIMAL | **8 of 8** (6-2-0) |  | **7 of 8** (6-1-1) |  | **6 of 8** (6-0-2) |  | 21 of 24 |
| Balanced | **8 of 8** (5-3-0) | 0 / 0 (1.000) | **6 of 8** (6-1-1) | 1 / 2 (1.000) | **5 of 8** (3-2-3) | 2 / 3 (1.000) | 19 of 24 |
| Rush | **3 of 8** (1-6-1) | 0 / 5 (0.062) | **2 of 8** (1-1-6) | 0 / 5 (0.062) | **4 of 8** (4-1-3) | 1 / 3 (0.625) | 9 of 24 |
| Economy | **8 of 8** (6-2-0) | 0 / 0 (1.000) | **8 of 8** (7-1-0) | 1 / 0 (1.000) | **3 of 8** (3-2-3) | 1 / 4 (0.375) | 19 of 24 |
| Timing attack | **8 of 8** (7-1-0) | 0 / 0 (1.000) | **5 of 8** (2-4-2) | 0 / 2 (0.500) | **4 of 8** (3-1-4) | 0 / 2 (0.500) | 17 of 24 |
| Pendulums | **7 of 8** (3-5-0) | 0 / 1 (1.000) | **8 of 8** (6-2-0) | 1 / 0 (1.000) | **4 of 8** (3-3-2) | 1 / 3 (0.625) | 19 of 24 |
| Heavy Works push | **5 of 8** (3-4-1) | 0 / 3 (0.250) | **6 of 8** (5-1-2) | 1 / 2 (1.000) | **0 of 8** (0-0-8) | 0 / 6 (0.031) | 11 of 24 |
| Springer timing | **4 of 8** (2-3-3) | 0 / 4 (0.125) | **1 of 8** (1-2-5) | 1 / 7 (0.070) | **0 of 8** (0-0-8) | 0 / 6 (0.031) | 5 of 24 |
| Clock Soldier rush | **6 of 8** (3-4-1) | 0 / 2 (0.500) | **4 of 8** (4-1-3) | 1 / 3 (0.625) | **5 of 8** (5-0-3) | 1 / 2 (1.000) | 15 of 24 |
| Owl raids | **1 of 8** (0-3-5) | 0 / 7 (0.016) | **1 of 8** (0-1-7) | 0 / 6 (0.031) | **0 of 8** (0-0-8) | 0 / 6 (0.031) | 2 of 24 |

## Median score ratio at the bell (subject / opponent: income earned + 2 x army)

| plan | v Crown | v Brood | v Clockwork |
|---|---|---|---|
| OPTIMAL | 3.00 | 3.00 | 3.00 |
| Balanced | 3.00 | 3.00 | 1.49 |
| Rush | 0.82 | 0.00 | 1.92 |
| Economy | 3.00 | 3.00 | 0.68 |
| Timing attack | 3.00 | 1.33 | 0.95 |
| Pendulums | 2.96 | 3.00 | 1.02 |
| Heavy Works push | 2.04 | 3.00 | 0.00 |
| Springer timing | 1.66 | 0.00 | 0.00 |
| Clock Soldier rush | 2.42 | 2.04 | 3.00 |
| Owl raids | 0.00 | 0.00 | 0.00 |

(a decided game counts as 3.0 won, 0.0 lost)

## v Crown

| plan | earned 5 | 8 | 12 | 16 | 20 | ratio 8 | 12 | 20 | workers 8 | 12 | 20 | army 8 | 12 | 16 | 20 | army ratio 12 | 20 | halls 12 | 20 | halls lost (own / foe) | first attack | foe first attack |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OPTIMAL | 4,022 | 9,764 | 21,100 | 30,493 | 42,350 | 1.64 | 1.82 | 1.91 | 44 | 52 | 50 | 1,745 | 3,960 | 7,228 | 6,900 | 5.10 | 23.09 | 4.00 | 6.50 | 0.00 / 3.00 | 5:37 | 8:35 |
| Balanced | 4,128 | 10,080 | 20,990 | 31,582 | 41,494 | 1.68 | 1.84 | 2.34 | 45 | 54 | 53 | 1,738 | 4,735 | 8,258 | 7,670 | 2.74 | 22.91 | 4.00 | 6.00 | 0.00 / 4.00 | 4:50 | 10:02 |
| Rush | 3,938 | 7,572 | 14,755 | 23,232 | 31,033 | 1.10 | 0.98 | 0.83 | 31 | 36 | 36 | 2,128 | 1,642 | 3,110 | 2,828 | 0.95 | 1.23 | 4.00 | 5.00 | 1.25 / 1.38 | 6:55 | 8:45 |
| Economy | 4,488 | 10,903 | 22,784 | 33,795 | 45,858 | 1.73 | 2.35 | 1.99 | 52 | 54 | 55 | 2,150 | 4,918 | 6,368 | 7,718 | 6.32 | 16.84 | 4.00 | 7.00 | 0.00 / 3.38 | 5:30 | 8:45 |
| Timing attack | 3,977 | 9,412 | 20,628 | 31,459 | 42,180 | 1.54 | 2.14 | 1.69 | 49 | 54 | 53 | 1,652 | 4,565 | 7,852 | 7,090 | 6.55 | 30.17 | 4.00 | 7.00 | 0.00 / 3.00 | 4:35 | 9:55 |
| Pendulums | 3,454 | 7,512 | 17,244 | 26,882 | 35,311 | 1.15 | 1.48 | 1.36 | 35 | 52 | 50 | 1,082 | 2,915 | 6,278 | 8,495 | 2.43 | 4.95 | 4.00 | 6.00 | 0.38 / 2.88 | 6:02 | 8:35 |
| Heavy Works push | 3,476 | 7,124 | 16,140 | 25,722 | 33,625 | 1.06 | 1.19 | 0.91 | 32 | 51 | 46 | 1,395 | 2,198 | 4,425 | 5,852 | 1.34 | 5.60 | 4.00 | 5.50 | 0.62 / 2.25 | 5:47 | 8:35 |
| Springer timing | 3,238 | 6,180 | 13,632 | 22,726 | 34,218 | 0.96 | 1.15 | 1.76 | 32 | 52 | 54 | 612 | 1,310 | 4,135 | 7,830 | 0.79 | 19.54 | 4.00 | 6.00 | 1.62 / 1.38 | 10:17 | 8:02 |
| Clock Soldier rush | 3,386 | 6,828 | 15,452 | 23,595 | 31,091 | 1.19 | 1.28 | 1.32 | 30 | 49 | 51 | 1,075 | 1,648 | 4,030 | 4,092 | 1.00 | 4.61 | 4.00 | 5.00 | 0.88 / 1.75 | 5:47 | 9:42 |
| Owl raids | 3,294 | 5,330 | 9,060 | 13,379 | 25,355 | 0.81 | 0.58 | 0.96 | 26 | 36 | 45 | 1,035 | 1,040 | 1,195 | 2,190 | 0.42 | 1.27 | 3.00 | 5.00 | 2.88 / 0.25 | 11:40 | 10:15 |

Crown OPTIMAL's opening pick against each plan:

| plan | the crown's opening pick | its plan at the end |
|---|---|---|
| OPTIMAL | timing 6, balloon 2 | timing 6, balloon 1, siege 1 |
| Balanced | timing 4, balloon 3, economy 1 | timing 4, balloon 3, balanced 1 |
| Rush | timing 4, balloon 3, economy 1 | timing 3, balloon 2, siege 2, economy 1 |
| Economy | timing 4, balloon 3, economy 1 | timing 4, balloon 3, balanced 1 |
| Timing attack | timing 4, balloon 3, economy 1 | timing 4, balloon 3, economy 1 |
| Pendulums | timing 4, balloon 3, economy 1 | timing 3, siege 3, balloon 1, economy 1 |
| Heavy Works push | timing 4, balloon 3, economy 1 | timing 5, siege 2, economy 1 |
| Springer timing | timing 4, balloon 3, economy 1 | timing 3, balloon 2, siege 2, economy 1 |
| Clock Soldier rush | balloon 3, timing 3, balanced 1, economy 1 | timing 3, balanced 2, balloon 2, siege 1 |
| Owl raids | timing 4, balloon 3, economy 1 | timing 3, siege 2, balloon 2, balanced 1 |

Crown by map (won or led of 2 / the score of each round: W w = l L):

| plan | greenhold | ashford_crossing | mirewood | cinder_steps |
|---|---|---|---|---|
| OPTIMAL | wW | WW | Ww | WW |
| Balanced | WW | Ww | WW | ww |
| Rush | lL | lw | lw | Wl |
| Economy | wW | wW | WW | WW |
| Timing attack | WW | WW | Ww | WW |
| Pendulums | lw | ww | WW | Ww |
| Heavy Works push | =l | wL | WW | Ww |
| Springer timing | Lw | lL | wW | WL |
| Clock Soldier rush | wL | ww | Wl | WW |
| Owl raids | LL | lL | w= | LL |

## v Brood

| plan | earned 5 | 8 | 12 | 16 | 20 | ratio 8 | 12 | 20 | workers 8 | 12 | 20 | army 8 | 12 | 16 | 20 | army ratio 12 | 20 | halls 12 | 20 | halls lost (own / foe) | first attack | foe first attack |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OPTIMAL | 3,679 | 8,338 | 17,044 | 26,634 | 34,746 | 1.31 | 1.21 | 1.03 | 31 | 48 | 44 | 2,225 | 3,590 | 4,785 | 3,055 | 1.17 | 1.96 | 4.00 | 6.00 | 0.38 / 0.00 | 9:05 | 2:55 |
| Balanced | 3,570 | 8,108 | 16,869 | 22,963 | 31,298 | 1.29 | 1.28 | 0.78 | 30 | 48 | 41 | 2,035 | 1,415 | 2,070 | 620 | 2.12 | 0.14 | 4.00 | 5.00 | 0.75 / 0.00 | 9:07 | 2:55 |
| Rush | 3,495 | 6,444 | 12,877 | 19,916 | 28,349 | 0.90 | 0.84 | 0.94 | 27 | 20 | 40 | 1,718 | 235 | 2,610 | 3,300 | 0.10 | 4.71 | 3.00 | 5.00 | 2.62 / 0.00 | 8:20 | 5:42 |
| Economy | 4,053 | 9,086 | 17,592 | 27,866 | 39,374 | 1.51 | 1.26 | 1.33 | 33 | 49 | 54 | 2,562 | 3,885 | 5,765 | 7,750 | 5.86 | 5.96 | 4.00 | 6.00 | 0.00 / 0.00 | 8:55 | 2:55 |
| Timing attack | 3,558 | 7,446 | 17,037 | 26,784 | 37,762 | 0.98 | 1.04 | 1.20 | 35 | 54 | 52 | 1,550 | 2,920 | 3,900 | 4,005 | 1.18 | 2.70 | 4.00 | 6.50 | 1.50 / 0.00 | 8:30 | 5:05 |
| Pendulums | 3,521 | 7,552 | 17,828 | 27,967 | 38,652 | 1.01 | 1.26 | 1.49 | 35 | 53 | 55 | 1,550 | 3,215 | 6,392 | 6,982 | 3.18 | 17.41 | 4.00 | 6.50 | 0.00 / 0.00 | 8:35 | 6:07 |
| Heavy Works push | 3,542 | 7,390 | 16,838 | 25,431 | 38,568 | 0.95 | 1.03 | 1.15 | 35 | 53 | 54 | 1,410 | 2,120 | 3,875 | 6,275 | 1.07 | 2.11 | 4.00 | 7.00 | 1.00 / 0.00 | 9:05 | 5:05 |
| Springer timing | 2,919 | 5,470 | 9,049 | 19,944 | 27,036 | 0.79 | 0.52 | 0.72 | 29 | 30 | 32 | 395 | 375 | 2,565 | 4,348 | 0.64 | 9.02 | 2.50 | 3.50 | 2.00 / 0.00 | 16:35 | 5:05 |
| Clock Soldier rush | 3,338 | 6,704 | 12,178 | 20,348 | 30,973 | 1.30 | 0.85 | 0.83 | 20 | 42 | 56 | 220 | 1,730 | 4,500 | 4,960 | 1.87 | 11.67 | 3.50 | 5.00 | 1.25 / 0.00 | 11:55 | 6:40 |
| Owl raids | 3,171 | 5,256 | 7,696 | 11,648 | 22,871 | 0.69 | 0.55 | 1.06 | 21 | 0 | 54 | 710 | 1,200 | 1,102 | 4,625 | 1.10 | 2.81 | 0.50 | 5.00 | 2.38 / 0.00 | 18:25 | 5:05 |

Brood OPTIMAL's opening pick against each plan:

| plan | the brood's opening pick | its plan at the end |
|---|---|---|
| OPTIMAL | rush 8 | timing 5, balanced 3 |
| Balanced | rush 8 | balanced 3, timing 3, brute 2 |
| Rush | balanced 3, timing 3, spitter 2 | brute 7, balanced 1 |
| Economy | rush 8 | balanced 7, brute 1 |
| Timing attack | balanced 3, timing 3, spitter 2 | brute 4, balanced 2, spitter 1, timing 1 |
| Pendulums | balanced 3, timing 3, spitter 2 | balanced 3, timing 3, spitter 2 |
| Heavy Works push | balanced 3, timing 3, spitter 2 | brute 3, balanced 2, spitter 2, timing 1 |
| Springer timing | balanced 3, timing 3, spitter 2 | brute 6, balanced 1, timing 1 |
| Clock Soldier rush | balanced 3, timing 3, spitter 2 | brute 4, spitter 2, timing 1, balanced 1 |
| Owl raids | balanced 3, timing 3, spitter 2 | brute 5, timing 2, balanced 1 |

Brood by map (won or led of 2 / the score of each round: W w = l L):

| plan | greenhold | ashford_crossing | mirewood | cinder_steps |
|---|---|---|---|---|
| OPTIMAL | Lw | WW | WW | WW |
| Balanced | WW | WW | lL | WW |
| Rush | LL | LL | wL | LW |
| Economy | WW | WW | wW | WW |
| Timing attack | Lw | wl | wL | WW |
| Pendulums | Ww | WW | wW | WW |
| Heavy Works push | WL | WL | Ww | WW |
| Springer timing | WL | LL | =l | LL |
| Clock Soldier rush | =L | LW | WW | WL |
| Owl raids | LL | LL | LL | wL |

## v Clockwork

| plan | earned 5 | 8 | 12 | 16 | 20 | ratio 8 | 12 | 20 | workers 8 | 12 | 20 | army 8 | 12 | 16 | 20 | army ratio 12 | 20 | halls 12 | 20 | halls lost (own / foe) | first attack | foe first attack |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| OPTIMAL | 4,474 | 10,656 | 21,870 | 31,970 | - | 1.03 | 1.33 | - | 48 | 54 | - | 2,040 | 7,290 | 8,300 | - | 1.07 | - | 4.00 | - | 1.12 / 3.88 | 5:30 | 5:50 |
| Balanced | 4,409 | 10,407 | 20,946 | 32,659 | 42,836 | 0.95 | 0.97 | 1.21 | 48 | 52 | 54 | 1,768 | 4,028 | 4,685 | 7,842 | 0.93 | 31.01 | 4.00 | 6.00 | 1.75 / 2.75 | 5:55 | 5:45 |
| Rush | 4,013 | 7,918 | 15,632 | 20,479 | 35,391 | 0.81 | 1.04 | 0.83 | 33 | 36 | 44 | 2,202 | 3,550 | 2,172 | 6,740 | 0.19 | 0.83 | 4.00 | 6.00 | 1.88 / 2.25 | 6:35 | 6:00 |
| Economy | 4,686 | 10,586 | 21,029 | 30,595 | 36,200 | 1.00 | 0.95 | 0.82 | 51 | 53 | 43 | 1,062 | 1,790 | 4,415 | 2,135 | 0.13 | 0.30 | 4.00 | 3.00 | 2.62 / 1.75 | 5:55 | 5:20 |
| Timing attack | 4,018 | 9,168 | 19,264 | 30,120 | 40,867 | 0.95 | 0.93 | 1.36 | 48 | 51 | 54 | 1,350 | 1,595 | 6,298 | 8,315 | 0.05 | 39.60 | 3.50 | 7.00 | 2.50 / 2.38 | 4:55 | 5:05 |
| Pendulums | 3,594 | 8,127 | 18,762 | 30,069 | 41,188 | 0.80 | 0.89 | 0.94 | 40 | 54 | 52 | 1,248 | 3,710 | 4,005 | 4,395 | 0.79 | 0.67 | 4.00 | 6.00 | 0.88 / 1.38 | 5:47 | 6:30 |
| Heavy Works push | 3,602 | 7,452 | 13,649 | 17,515 | - | 0.69 | 0.61 | - | 36 | 43 | - | 1,000 | 330 | 0 | - | 0.06 | - | 3.00 | - | 4.12 / 0.00 | 5:35 | 6:07 |
| Springer timing | 3,358 | 5,850 | 9,992 | - | - | 0.58 | 0.46 | - | 27 | 27 | - | 545 | 125 | - | - | 0.02 | - | 0.50 | - | 3.12 / 0.00 | - | 5:22 |
| Clock Soldier rush | 3,370 | 7,032 | 16,652 | 21,681 | - | 1.42 | 1.10 | - | 36 | 52 | - | 955 | 3,148 | 0 | - | 0.58 | - | 4.00 | - | 1.75 / 1.50 | 5:07 | 6:02 |
| Owl raids | 3,390 | 6,140 | 9,525 | - | - | 0.62 | 0.45 | - | 30 | 21 | - | 1,010 | 75 | - | - | 0.01 | - | 0.00 | - | 3.00 / 0.00 | - | 5:00 |

Clockwork OPTIMAL's opening pick against each plan:

| plan | the clockwork's opening pick | its plan at the end |
|---|---|---|
| OPTIMAL | balanced 5, economy 3 | balanced 5, economy 3 |
| Balanced | balanced 6, economy 2 | balanced 6, economy 2 |
| Rush | economy 5, balanced 2, springer 1 | economy 4, balanced 3, springer 1 |
| Economy | balanced 5, economy 3 | balanced 5, economy 3 |
| Timing attack | economy 5, balanced 2, springer 1 | economy 5, balanced 2, springer 1 |
| Pendulums | economy 5, balanced 2, springer 1 | balanced 4, economy 4 |
| Heavy Works push | economy 5, balanced 2, springer 1 | balanced 4, economy 4 |
| Springer timing | economy 5, balanced 2, springer 1 | balanced 5, economy 2, springer 1 |
| Clock Soldier rush | economy 5, balanced 2, springer 1 | balanced 7, springer 1 |
| Owl raids | economy 5, balanced 2, springer 1 | economy 4, balanced 3, springer 1 |

Clockwork by map (won or led of 2 / the score of each round: W w = l L):

| plan | greenhold | ashford_crossing | mirewood | cinder_steps |
|---|---|---|---|---|
| OPTIMAL | WW | LW | LW | WW |
| Balanced | LL | wW | WW | Lw |
| Rush | WW | LL | Wl | WL |
| Economy | lW | lW | WL | LL |
| Timing attack | LL | LW | Lw | WW |
| Pendulums | Ww | lL | Wl | WL |
| Heavy Works push | LL | LL | LL | LL |
| Springer timing | LL | LL | LL | LL |
| Clock Soldier rush | WW | LL | WW | WL |
| Owl raids | LL | LL | LL | LL |

## The clockwork OPTIMAL's own picks (the subject's OPTIMAL games)

| opponent | opening pick | later picks | plan at the end | its won or led by opening pick |
|---|---|---|---|---|
| crown | springer 5, heavy 1, economy 1, balanced 1 | economy 4, springer 1 | economy 4, springer 3, heavy 1 | springer 5 of 5, heavy 1 of 1, economy 1 of 1, balanced 1 of 1 |
| brood | balanced 8 | - | balanced 8 | balanced 7 of 8 |
| clockwork | balanced 8 | - | balanced 8 | balanced 6 of 8 |
