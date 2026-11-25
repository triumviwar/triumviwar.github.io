# The battle matrix: the analysis (made by tools/study/battle_matrix_report.py)

1380 fights. Score = the Crown's share of the value lost in the fight (50 = even). C = the Crown clearly ahead (the 95% interval above 50), B = the Brood clearly ahead, = = not told apart.


## open field, early (600) (676 fights)

Pairings: the Crown clearly ahead in **27**, the Brood in **84**, even in 58 (of 169). Mean score over all pairings: 40.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MO (79) | M (74) | D (0) | M, MO |
| R3S1 (Raptors, a few Spitters (3:1)) | MO (95) | M (86) | D (0) | M, MO |
| R1S1 (Raptors and Spitters (1:1)) | M (87) | MO (79) | D (0) | M, MO |
| R1S3 (Spitters, a few Raptors (3:1)) | CH (74) | M (72) | D (0) | none |
| S (Spitters) | MCH (74) | M (63) | D (0) | none |
| B (Brutes) | MO (82) | M (80) | D (0) | M, MO |
| RSB (Raptors, Spitters, Brutes) | M (78) | MMi (64) | D (0) | M, MH |
| TC (Tyrant Challengers) | MO (88) | MB (84) | D (0) | M, MH, MO, MB, MMi |
| TCS (Tyrant Challengers + Spitters) | M (76) | MO (74) | D (0) | MO |
| VC (Venom Challengers) | MCH (81) | MO (54) | D (0) | MCH |
| StC (Storm Challengers (flyers)) | M (87) | MO (79) | D (0) | M, MCH, MO, MB |
| RSTd (Raptors, Spitters, Mist Toads) | MO (100) | M (94) | D (0) | M, MC, MCH, MMo, MO, MMi |
| RSy (Raptors and Spitters with the Tyrant Sire) | MB (41) | MO (38) | D (0) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (17) | RSy (34) | RSTd (94) | VC, RSy |
| MC (Musketeers + Field Cannons) | VC (6) | RSy (23) | RSTd (79) | R, R3S1, R1S1, S, TC, TCS, VC, StC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | B (25) | RSy (30) | VC (81) | B, RSy |
| MMo (Musketeers + Mortars) | VC (0) | StC (18) | RSTd (91) | R, R3S1, R1S1, S, B, RSB, TC, VC, StC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | B (0) | StC (0) | R (30) | R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MH (Musketeers + Horsemen) | VC (6) | B (21) | RSTd (76) | R1S3, B, TCS, VC, RSy |
| H (Horsemen) | B (0) | StC (0) | R1S3 (58) | R, R3S1, S, B, RSB, VC, StC, RSy |
| D (Dragoons) | B (0) | R (0) | VC (0) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (0) | S (7) | StC (48) | R, R3S1, R1S3, S, B, RSB, TCS, VC, RSTd, RSy |
| MO (Musketeers + Officers) | RSy (38) | VC (54) | RSTd (100) | RSy |
| MB (Musketeers + the band) | VC (6) | R (39) | TC (84) | TCS, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (0) | S (27) | RSTd (82) | S, VC, RSy |
| CH (Cannons + Horsemen) | B (6) | StC (6) | R1S3 (74) | S, B, RSB, VC, StC, RSy |

Best Crown compositions on average: MO 73, M 72, MCH 58, MB 55. Safest (best at its worst): MO 38, MCH 25, M 17.
Best Brood compositions on average: VC 85, RSy 73, S 69, B 68 (the Brood's own share). Safest: RSy 59, S 26, R1S3 26.
Brood compositions that out-trade EVERY Crown composition: RSy (clearly, every one: RSy). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **39**. The Crown's best mix: MO 68%, MB 32%. The Brood's: RSy 93%, VC 7%.

## open field, mid (1,500) (676 fights)

Pairings: the Crown clearly ahead in **40**, the Brood in **78**, even in 51 (of 169). Mean score over all pairings: 45.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MH (78) | CH (75) | D (0) | MCH, MH |
| R3S1 (Raptors, a few Spitters (3:1)) | MH (88) | MCH (70) | D (2) | M, MCH, MH, MO |
| R1S1 (Raptors and Spitters (1:1)) | MH (84) | MO (70) | D (3) | MH, MO |
| R1S3 (Spitters, a few Raptors (3:1)) | M (62) | MH (57) | D (5) | none |
| S (Spitters) | MH (79) | H (64) | D (6) | MH |
| B (Brutes) | MO (85) | MH (84) | CH (0) | M, MH, MO, MB, MMi |
| RSB (Raptors, Spitters, Brutes) | M (70) | MO (61) | D (10) | M |
| TC (Tyrant Challengers) | MH (89) | M (88) | D (4) | M, MH, H, MO, MB, MMi |
| TCS (Tyrant Challengers + Spitters) | M (76) | MH (75) | MD (26) | M, MCH, MH, H, MB |
| VC (Venom Challengers) | MH (88) | MCH (79) | D (0) | MCH, MH |
| StC (Storm Challengers (flyers)) | MH (95) | MO (93) | H (0) | M, MCH, MH, MD, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MO (84) | MH (81) | D (10) | MCH, MH, MD, MO, MMi |
| RSy (Raptors and Spitters with the Tyrant Sire) | MB (40) | MH (37) | D (4) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (10) | R (28) | StC (91) | R, S, VC, RSy |
| MC (Musketeers + Field Cannons) | VC (16) | S (32) | StC (69) | S, B, VC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | RSy (33) | S (36) | StC (82) | S, RSy |
| MMo (Musketeers + Mortars) | VC (5) | R (15) | StC (68) | R, R3S1, R1S1, R1S3, S, B, RSB, TCS, VC, RSTd, RSy |
| MCMo (Musketeers + Cannons + Mortars) | VC (8) | R (12) | StC (64) | R, R1S1, R1S3, S, RSB, VC, RSy |
| MH (Musketeers + Horsemen) | RSy (37) | RSB (56) | StC (95) | RSy |
| H (Horsemen) | StC (0) | VC (5) | TC (75) | R, R3S1, B, VC, StC, RSy |
| D (Dragoons) | VC (0) | R (0) | TCS (27) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | S (10) | VC (10) | StC (74) | R, R3S1, R1S1, S, RSB, TC, TCS, VC, RSy |
| MO (Musketeers + Officers) | VC (8) | S (25) | StC (93) | R, S, VC, RSy |
| MB (Musketeers + the band) | VC (6) | R (25) | StC (89) | R, R1S3, S, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (8) | R (25) | StC (86) | R, R1S3, S, VC, RSy |
| CH (Cannons + Horsemen) | B (0) | StC (5) | R (75) | R1S3, B, RSB, TCS, VC, StC, RSy |

Best Crown compositions on average: MH 76, MCH 61, M 59, MO 57. Safest (best at its worst): MH 37, MCH 33, MC 16.
Best Brood compositions on average: VC 80, RSy 68, S 66, R 66 (the Brood's own share). Safest: RSy 60, R1S3 38, RSB 30.
Brood compositions that out-trade EVERY Crown composition: RSy (clearly, every one: RSy). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **39**. The Crown's best mix: MB 60%, MH 40%. The Brood's: RSy 97%, VC 3%.

## open field, late (4,000) (28 fights)

Pairings: the Crown clearly ahead in **0**, the Brood in **0**, even in 28 (of 28). Mean score over all pairings: 58.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MC (62) | MCH (59) | M (35) | none |
| R3S1 (Raptors, a few Spitters (3:1)) | M (61) | MCH (59) | MC (43) | none |
| R1S1 (Raptors and Spitters (1:1)) | M (59) | MC (44) | MC (44) | none |
| R1S3 (Spitters, a few Raptors (3:1)) | M (60) | MC (44) | MC (44) | none |
| S (Spitters) | MC (58) | M (36) | M (36) | none |
| B (Brutes) | M (90) | MC (76) | MC (76) | none |
| RSB (Raptors, Spitters, Brutes) | M (69) | MC (36) | MC (36) | none |
| TC (Tyrant Challengers) | M (90) | MC (77) | MC (77) | none |
| TCS (Tyrant Challengers + Spitters) | M (70) | MC (66) | MC (66) | none |
| VC (Venom Challengers) | MC (36) | M (18) | M (18) | none |
| StC (Storm Challengers (flyers)) | M (89) | MC (87) | MC (87) | none |
| RSTd (Raptors, Spitters, Mist Toads) | M (74) | MC (60) | MC (60) | none |
| RSy (Raptors and Spitters with the Tyrant Sire) | M (44) | MC (35) | MC (35) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (18) | R (35) | TC (90) | none |
| MC (Musketeers + Field Cannons) | RSy (35) | VC (36) | StC (87) | none |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | R3S1 (59) | R (59) | R (59) | none |

Best Crown compositions on average: M 61, MCH 59, MC 56. Safest (best at its worst): MCH 59, MC 35, M 18.
Best Brood compositions on average: VC 73, RSy 60, S 53, R1S1 49 (the Brood's own share). Safest: VC 64, RSy 56, S 42.
Brood compositions that out-trade EVERY Crown composition: VC, RSy (clearly, every one: none). Crown compositions that out-trade every Brood composition: MCH (clearly: none).

## The fighting (micro) counts

| ground, size | Crown armies with guns | guns set at contact | guns set 10 s after | guns that fired by 20 s | guns lost per gun | riders lost per rider | the Crown's pulls a fight | the Brood's pulls a fight |
|---|---|---|---|---|---|---|---|---|
| open field, 600 | 260 | 0% | 34% | 38% | 0.84 | 0.91 | 10.5 | 0.7 |
| open field, 1500 | 260 | 0% | 57% | 58% | 0.76 | 0.83 | 3.1 | 1.2 |
| open field, 4000 | 15 | 0% | 55% | 27% | 0.40 | 0.88 | 0.7 | 2.8 |

## What the guns, riders and the rest add (score against the plain Musketeer line, same Brood army)

| ground, size | MC | MCH | MMo | MCMo | MH | H | D | MD | MO | MB | MMi | CH |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| open, 600 | -36 | -14 | -42 | -60 | -27 | -44 | -72 | -43 | +1 | -17 | -20 | -36 |
| open, 1500 | -17 | +1 | -28 | -25 | +17 | -19 | -51 | -23 | -2 | -8 | -7 | -23 |
| open, 4000 | -6 | +11 |  |  |  |  |  |  |  |  |  |  |
