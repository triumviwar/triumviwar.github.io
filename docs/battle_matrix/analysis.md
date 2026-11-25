# The battle matrix: the analysis (made by tools/study/battle_matrix_report.py)

4809 fights. Score = the Crown's share of the value lost in the fight (50 = even). C = the Crown clearly ahead (the 95% interval above 50), B = the Brood clearly ahead, = = not told apart.


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
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **57**. The Crown's best mix: MO 60%, MCH 27%, M 13%. The Brood's: RSB 49%, VC 33%, R1S3 18%.

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
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **59**. The Crown's best mix: MH 62%, M 38%. The Brood's: R1S3 93%, VC 7%.

## open field, late (4,000) (676 fights)

Pairings: the Crown clearly ahead in **72**, the Brood in **50**, even in 47 (of 169). Mean score over all pairings: 54.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (98) | MCH (61) | D (1) | MCH, CH |
| R3S1 (Raptors, a few Spitters (3:1)) | CH (79) | MH (69) | D (0) | M, MCH, MH, MO, CH |
| R1S1 (Raptors and Spitters (1:1)) | CH (70) | MO (69) | D (28) | M, MCH, MH, MO, MMi, CH |
| R1S3 (Spitters, a few Raptors (3:1)) | MCH (68) | MH (62) | D (20) | M, MCH, MH |
| S (Spitters) | MH (85) | MCMo (62) | D (5) | MCMo, MH |
| B (Brutes) | MH (97) | MO (96) | D (5) | M, MC, MCH, MMo, MCMo, MH, H, MD, MO, MB, MMi, CH |
| RSB (Raptors, Spitters, Brutes) | MO (76) | MB (69) | D (6) | M, MO, MB, MMi |
| TC (Tyrant Challengers) | CH (97) | MH (88) | D (4) | M, MC, MCH, MMo, MCMo, MH, MD, MO, MB, MMi, CH |
| TCS (Tyrant Challengers + Spitters) | MH (80) | MO (76) | D (3) | M, MCH, MH, MO, MB, MMi |
| VC (Venom Challengers) | MH (92) | CH (89) | D (3) | MCH, MH, CH |
| StC (Storm Challengers (flyers)) | MH (94) | M (88) | H (0) | M, MC, MCH, MCMo, MH, MD, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MCH (82) | MO (79) | D (23) | M, MC, MCH, MCMo, MH, MD, MO, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | MO (62) | MH (56) | D (4) | MO |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (14) | S (39) | B (94) | S, VC, RSy |
| MC (Musketeers + Field Cannons) | VC (30) | RSy (36) | B (83) | VC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | RSy (39) | S (46) | B (91) | RSy |
| MMo (Musketeers + Mortars) | VC (6) | R (28) | B (77) | R, R1S1, RSB, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | RSB (30) | VC (34) | B (75) | RSB, VC, RSy |
| MH (Musketeers + Horsemen) | R (55) | RSy (56) | B (97) | none |
| H (Horsemen) | StC (0) | VC (8) | B (83) | R, R3S1, R1S3, S, TCS, VC, StC, RSy |
| D (Dragoons) | R3S1 (0) | R (1) | R1S1 (28) | R, R3S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (6) | S (27) | StC (79) | R, R1S3, S, RSB, TCS, VC, RSy |
| MO (Musketeers + Officers) | VC (9) | R (48) | B (96) | VC |
| MB (Musketeers + the band) | VC (14) | S (28) | B (93) | R, S, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (12) | S (33) | B (93) | S, VC, RSy |
| CH (Cannons + Horsemen) | StC (31) | S (40) | R (98) | StC |

Best Crown compositions on average: MH 76, CH 67, MCH 67, MO 66. Safest (best at its worst): MH 55, MCH 39, CH 31.
Best Brood compositions on average: VC 69, RSy 61, S 59, R 56 (the Brood's own share). Safest: RSy 38, R1S3 32, R1S1 30.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: MH (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **57**. The Crown's best mix: MH 47%, MO 41%, CH 12%. The Brood's: RSy 82%, R 14%, VC 4%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **61**. The Crown's best mix: MH 37%, MCH 28%, MO 22%, CH 13%. The Brood's: R1S3 49%, RSB 34%, R 13%, S 4%.

## the set line (open ground, the Crown formed, guns up), early (600) (507 fights)

Pairings: the Crown clearly ahead in **17**, the Brood in **85**, even in 67 (of 169). Mean score over all pairings: 35.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MCH (87) | MC (74) | D (9) | M, MCH |
| R3S1 (Raptors, a few Spitters (3:1)) | MH (88) | MCH (84) | D (8) | MC, MCH, MMo, MH |
| R1S1 (Raptors and Spitters (1:1)) | M (74) | MCH (70) | D (13) | MC, MCH |
| R1S3 (Spitters, a few Raptors (3:1)) | MMi (56) | M (55) | D (15) | none |
| S (Spitters) | CH (90) | MCMo (60) | D (5) | CH |
| B (Brutes) | MH (28) | MMi (25) | D (0) | none |
| RSB (Raptors, Spitters, Brutes) | H (44) | M (41) | MMo (15) | none |
| TC (Tyrant Challengers) | MH (75) | M (49) | D (0) | MH |
| TCS (Tyrant Challengers + Spitters) | MCH (38) | CH (31) | MCMo (0) | none |
| VC (Venom Challengers) | CH (61) | MCH (31) | D (0) | CH |
| StC (Storm Challengers (flyers)) | M (86) | MD (67) | CH (0) | M, MD |
| RSTd (Raptors, Spitters, Mist Toads) | CH (80) | M (80) | D (24) | M, MC, MCH, MMi |
| RSy (Raptors and Spitters with the Tyrant Sire) | CH (33) | MB (33) | D (11) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | B (8) | VC (8) | StC (86) | B, RSB, VC, RSy |
| MC (Musketeers + Field Cannons) | B (0) | VC (15) | R3S1 (84) | B, TC, TCS, VC, StC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | B (7) | StC (8) | R (87) | B, RSB, StC |
| MMo (Musketeers + Mortars) | B (0) | TCS (0) | R3S1 (73) | S, B, RSB, TC, TCS, VC, StC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | B (0) | StC (0) | RSTd (67) | R, B, RSB, TC, TCS, VC, StC, RSy |
| MH (Musketeers + Horsemen) | VC (0) | S (18) | R3S1 (88) | S, VC, RSy |
| H (Horsemen) | StC (0) | B (7) | RSTd (60) | R, R3S1, R1S1, S, B, TCS, VC, StC, RSy |
| D (Dragoons) | B (0) | StC (0) | RSTd (24) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (0) | B (7) | StC (67) | R, R1S3, S, B, RSB, TC, TCS, VC, RSy |
| MO (Musketeers + Officers) | B (8) | VC (8) | RSTd (64) | R3S1, R1S1, S, B, RSB, TCS, VC, RSy |
| MB (Musketeers + the band) | B (8) | VC (8) | R1S1 (50) | R1S3, S, B, TC, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (8) | B (25) | RSTd (77) | S, B, VC, StC, RSy |
| CH (Cannons + Horsemen) | StC (0) | B (8) | S (90) | B, StC, RSy |

Best Crown compositions on average: M 49, CH 46, MH 44, MCH 44. Safest (best at its worst): MMi 8, MB 8, MO 8.
Best Brood compositions on average: B 92, VC 86, TCS 78, RSy 75 (the Brood's own share). Safest: B 72, RSy 67, TCS 62.
Brood compositions that out-trade EVERY Crown composition: B, RSB, TCS, RSy (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **21**. The Crown's best mix: MH 65%, CH 35%. The Brood's: B 75%, VC 25%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **21**. The Crown's best mix: MH 65%, CH 35%. The Brood's: B 75%, VC 25%.

## the set line (open ground, the Crown formed, guns up), mid (1,500) (507 fights)

Pairings: the Crown clearly ahead in **28**, the Brood in **91**, even in 50 (of 169). Mean score over all pairings: 41.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (96) | MCH (81) | D (14) | MC, MCH, MMo, CH |
| R3S1 (Raptors, a few Spitters (3:1)) | CH (87) | MCH (79) | H (17) | MC, MCH, MMo, MCMo, CH |
| R1S1 (Raptors and Spitters (1:1)) | CH (82) | MC (76) | H (22) | MC, MCH, CH |
| R1S3 (Spitters, a few Raptors (3:1)) | CH (86) | MMo (63) | D (20) | CH |
| S (Spitters) | MC (51) | MMo (48) | D (4) | none |
| B (Brutes) | CH (70) | MCH (62) | D (0) | none |
| RSB (Raptors, Spitters, Brutes) | CH (86) | MC (71) | D (22) | MC, CH |
| TC (Tyrant Challengers) | CH (72) | MH (72) | D (11) | MCH, MH |
| TCS (Tyrant Challengers + Spitters) | CH (86) | MCH (73) | D (13) | MC, MCH, CH |
| VC (Venom Challengers) | CH (51) | MCH (31) | D (0) | none |
| StC (Storm Challengers (flyers)) | M (87) | MB (81) | CH (0) | M, MH, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | CH (83) | MC (79) | D (29) | MC, MCH, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | CH (50) | MMo (43) | D (17) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (7) | B (28) | StC (87) | R, R3S1, R1S1, R1S3, S, B, TC, TCS, VC, RSy |
| MC (Musketeers + Field Cannons) | VC (30) | B (32) | RSTd (79) | RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (27) | VC (31) | R (81) | VC, StC |
| MMo (Musketeers + Mortars) | VC (3) | B (13) | R (73) | B, RSB, TC, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | VC (3) | B (18) | RSTd (66) | S, B, VC, RSy |
| MH (Musketeers + Horsemen) | VC (0) | S (20) | TC (72) | R, R1S1, R1S3, S, B, RSB, VC, RSy |
| H (Horsemen) | StC (0) | VC (6) | R1S3 (55) | R, R3S1, R1S1, S, VC, StC, RSy |
| D (Dragoons) | B (0) | VC (0) | RSTd (29) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (0) | B (10) | StC (72) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, RSTd, RSy |
| MO (Musketeers + Officers) | VC (3) | S (15) | StC (74) | R, R1S1, R1S3, S, B, RSB, TC, TCS, VC, RSTd, RSy |
| MB (Musketeers + the band) | VC (8) | B (18) | StC (81) | R, R1S1, S, B, RSB, TCS, VC, RSTd, RSy |
| MMi (Musketeers + a Missionary) | VC (7) | B (24) | StC (80) | R, R1S1, R1S3, S, B, TCS, VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | S (45) | R (96) | StC |

Best Crown compositions on average: CH 69, MCH 58, MC 57, MMo 46. Safest (best at its worst): MC 30, MCH 27, MB 8.
Best Brood compositions on average: VC 88, B 73, S 71, RSy 66 (the Brood's own share). Safest: RSy 50, VC 49, S 49.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **34**. The Crown's best mix: MC 81%, CH 19%. The Brood's: VC 67%, StC 33%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **34**. The Crown's best mix: MC 81%, CH 19%. The Brood's: VC 67%, StC 33%.

## the set line (open ground, the Crown formed, guns up), late (4,000) (507 fights)

Pairings: the Crown clearly ahead in **69**, the Brood in **74**, even in 26 (of 169). Mean score over all pairings: 52.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MMo (89) | MC (79) | H (17) | MC, MCH, MMo, MCMo, MO, CH |
| R3S1 (Raptors, a few Spitters (3:1)) | CH (87) | MMo (86) | H (23) | MC, MCH, MMo, MCMo, CH |
| R1S1 (Raptors and Spitters (1:1)) | CH (89) | MC (86) | H (21) | MC, MCH, MMo, MCMo, CH |
| R1S3 (Spitters, a few Raptors (3:1)) | CH (81) | MC (80) | D (25) | MC, MCH, MMo, MCMo, CH |
| S (Spitters) | MMo (77) | MC (72) | D (9) | MC, MCH, MMo, MCMo |
| B (Brutes) | CH (88) | MCH (79) | D (16) | MC, MCH, MCMo, MO, CH |
| RSB (Raptors, Spitters, Brutes) | MC (85) | CH (79) | D (29) | MC, MCH, MMo, MCMo, CH |
| TC (Tyrant Challengers) | MMo (85) | MCH (84) | D (27) | M, MC, MCH, MMo, MCMo, MH, H, MD, MO, MB, MMi, CH |
| TCS (Tyrant Challengers + Spitters) | MC (80) | CH (78) | H (16) | MC, MCH, MMo, MCMo, CH |
| VC (Venom Challengers) | CH (87) | MCMo (60) | D (1) | MCMo, CH |
| StC (Storm Challengers (flyers)) | M (90) | MMi (89) | CH (0) | M, MH, MD, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MC (88) | CH (85) | D (31) | MC, MCH, MMo, MCMo, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | MCH (74) | MMo (72) | H (20) | MC, MCH, MMo, MCMo |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (9) | R (30) | StC (90) | R, R3S1, R1S1, R1S3, S, TCS, VC, RSTd, RSy |
| MC (Musketeers + Field Cannons) | VC (57) | RSy (71) | RSTd (88) | none |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (46) | VC (54) | RSTd (84) | none |
| MMo (Musketeers + Mortars) | B (26) | VC (26) | R (89) | B, VC |
| MCMo (Musketeers + Cannons + Mortars) | StC (26) | VC (60) | RSTd (83) | none |
| MH (Musketeers + Horsemen) | VC (4) | S (27) | TC (83) | R, R1S1, R1S3, S, RSB, VC, RSTd, RSy |
| H (Horsemen) | StC (0) | S (13) | TC (72) | R, R3S1, R1S1, R1S3, S, TCS, VC, StC, RSy |
| D (Dragoons) | VC (1) | S (9) | StC (40) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (14) | S (29) | StC (86) | R, R3S1, R1S1, R1S3, S, B, RSB, VC, RSTd, RSy |
| MO (Musketeers + Officers) | VC (5) | S (26) | TC (76) | R3S1, R1S1, R1S3, S, RSB, VC, RSTd, RSy |
| MB (Musketeers + the band) | VC (10) | R (27) | StC (87) | R, R3S1, R1S1, S, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (10) | R (27) | StC (89) | R, R3S1, R1S1, S, B, TCS, VC, RSTd, RSy |
| CH (Cannons + Horsemen) | StC (0) | RSy (57) | R1S1 (89) | StC |

Best Crown compositions on average: MC 78, MCH 73, CH 72, MCMo 71. Safest (best at its worst): MC 57, MCH 46, MCMo 26.
Best Brood compositions on average: VC 72, S 58, RSy 53, R 50 (the Brood's own share). Safest: RSy 26, S 23, TCS 20.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: MC (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **62**. The Crown's best mix: MC 84%, CH 16%. The Brood's: VC 71%, StC 29%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **62**. The Crown's best mix: MC 84%, CH 16%. The Brood's: VC 71%, StC 29%.

## a choke, mid (1,500) (507 fights)

Pairings: the Crown clearly ahead in **27**, the Brood in **93**, even in 49 (of 169). Mean score over all pairings: 41.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (88) | MCH (84) | H (16) | MCH |
| R3S1 (Raptors, a few Spitters (3:1)) | CH (90) | MC (80) | H (15) | MC, MCH, MMo, MCMo, CH |
| R1S1 (Raptors and Spitters (1:1)) | CH (88) | MC (72) | D (24) | MC, MCH, MCMo, CH |
| R1S3 (Spitters, a few Raptors (3:1)) | CH (81) | MC (66) | D (20) | MC, CH |
| S (Spitters) | MMo (54) | MC (50) | D (7) | none |
| B (Brutes) | CH (67) | MCH (52) | D (0) | none |
| RSB (Raptors, Spitters, Brutes) | CH (88) | MC (63) | D (24) | CH |
| TC (Tyrant Challengers) | MH (73) | MCH (69) | D (17) | MCH, MH |
| TCS (Tyrant Challengers + Spitters) | CH (83) | MCH (72) | D (19) | MC, MCH, CH |
| VC (Venom Challengers) | CH (58) | MC (36) | D (0) | none |
| StC (Storm Challengers (flyers)) | MB (86) | M (84) | CH (0) | M, MH, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | CH (83) | MC (81) | D (30) | MC, MCH, MCMo, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | CH (47) | MMo (43) | D (15) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (7) | R (29) | StC (84) | R, R3S1, R1S1, R1S3, S, TCS, VC, RSTd, RSy |
| MC (Musketeers + Field Cannons) | RSy (35) | VC (36) | RSTd (81) | VC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (22) | VC (23) | R (84) | S, VC, StC, RSy |
| MMo (Musketeers + Mortars) | VC (3) | B (10) | R3S1 (71) | B, RSB, TC, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | VC (7) | B (16) | RSTd (65) | S, B, TC, VC, RSy |
| MH (Musketeers + Horsemen) | VC (3) | S (20) | StC (78) | R, R1S1, R1S3, S, B, VC, RSTd, RSy |
| H (Horsemen) | StC (0) | S (10) | RSB (62) | R, R3S1, R1S1, S, VC, StC, RSTd, RSy |
| D (Dragoons) | B (0) | VC (0) | RSTd (30) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (7) | B (10) | StC (65) | R, R1S1, R1S3, S, B, RSB, TC, TCS, VC, RSTd, RSy |
| MO (Musketeers + Officers) | VC (3) | S (17) | StC (79) | R, R3S1, R1S1, R1S3, S, B, RSB, TCS, VC, RSy |
| MB (Musketeers + the band) | VC (8) | B (17) | StC (86) | R, R1S1, R1S3, S, B, RSB, TCS, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (10) | B (15) | StC (76) | R, R1S1, B, RSB, TC, VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | S (37) | R3S1 (90) | StC, RSy |

Best Crown compositions on average: CH 67, MC 58, MCH 57, MMo 42. Safest (best at its worst): MC 35, MCH 22, MMi 10.
Best Brood compositions on average: VC 86, B 74, S 70, RSy 67 (the Brood's own share). Safest: RSy 53, S 46, VC 42.
Brood compositions that out-trade EVERY Crown composition: RSy (clearly, every one: RSy). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **38**. The Crown's best mix: MC 64%, CH 24%, MB 12%. The Brood's: VC 45%, StC 30%, RSy 25%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **38**. The Crown's best mix: MC 89%, CH 11%. The Brood's: VC 66%, StC 34%.

## a ramp, the Crown on top, mid (1,500) (507 fights)

Pairings: the Crown clearly ahead in **31**, the Brood in **73**, even in 65 (of 169). Mean score over all pairings: 46.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MMi (97) | MB (90) | H (12) | MCH, MB, MMi, CH |
| R3S1 (Raptors, a few Spitters (3:1)) | CH (88) | MC (85) | H (13) | M, MC, MCH |
| R1S1 (Raptors and Spitters (1:1)) | MC (89) | CH (81) | H (17) | M, MC, MCMo |
| R1S3 (Spitters, a few Raptors (3:1)) | CH (83) | MC (74) | D (20) | MC, CH |
| S (Spitters) | CH (81) | MC (69) | D (5) | MCMo, CH |
| B (Brutes) | CH (78) | MCH (54) | D (3) | none |
| RSB (Raptors, Spitters, Brutes) | CH (74) | MC (70) | D (22) | MCH |
| TC (Tyrant Challengers) | MCH (85) | MH (82) | D (9) | MCH, MH |
| TCS (Tyrant Challengers + Spitters) | MC (69) | MCH (68) | D (13) | MC, MCH |
| VC (Venom Challengers) | CH (51) | MC (29) | D (0) | none |
| StC (Storm Challengers (flyers)) | M (86) | MB (82) | CH (0) | M, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MC (92) | CH (90) | D (24) | M, MC, MCH, MMo, MCMo, MH, MB, MMi, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | CH (47) | MCH (46) | H (18) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (14) | RSy (30) | StC (86) | VC, RSy |
| MC (Musketeers + Field Cannons) | VC (29) | RSy (36) | RSTd (92) | RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | VC (20) | StC (25) | TC (85) | VC, StC, RSy |
| MMo (Musketeers + Mortars) | VC (10) | B (19) | RSTd (75) | B, TC, TCS, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | VC (15) | B (20) | RSTd (73) | B, VC, RSy |
| MH (Musketeers + Horsemen) | VC (7) | S (23) | TC (82) | R1S3, S, TCS, VC, RSy |
| H (Horsemen) | StC (0) | VC (0) | TC (54) | R, R3S1, R1S1, R1S3, S, B, RSB, TCS, VC, StC, RSy |
| D (Dragoons) | VC (0) | B (3) | RSTd (24) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | B (13) | VC (13) | StC (60) | R1S1, R1S3, S, B, RSB, TC, TCS, VC, RSy |
| MO (Musketeers + Officers) | VC (0) | S (24) | StC (56) | R, R1S1, R1S3, S, B, RSB, TCS, VC, RSTd, RSy |
| MB (Musketeers + the band) | VC (15) | B (26) | R (90) | R3S1, S, B, RSB, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (13) | B (21) | R (97) | B, RSB, VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | RSy (47) | RSTd (90) | StC |

Best Crown compositions on average: CH 68, MC 64, MCH 61, M 55. Safest (best at its worst): MC 29, MCH 20, MCMo 15.
Best Brood compositions on average: VC 86, B 68, RSy 67, S 60 (the Brood's own share). Safest: RSy 53, VC 49, TCS 31.
Brood compositions that out-trade EVERY Crown composition: RSy (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **36**. The Crown's best mix: CH 59%, M 41%. The Brood's: VC 70%, StC 30%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **36**. The Crown's best mix: CH 59%, M 41%. The Brood's: VC 70%, StC 30%.

## a ramp, the Brood on top, mid (1,500) (246 fights)

Pairings: the Crown clearly ahead in **17**, the Brood in **8**, even in 144 (of 169). Mean score over all pairings: 54.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MMi (79) | MO (76) | D (3) | none |
| R3S1 (Raptors, a few Spitters (3:1)) | M (83) | MO (80) | D (32) | MMo |
| R1S1 (Raptors and Spitters (1:1)) | MH (70) | MO (69) | D (24) | MH |
| R1S3 (Spitters, a few Raptors (3:1)) | MO (84) | MD (79) | D (21) | M |
| S (Spitters) | MO (74) | M (73) | D (23) | MCH |
| B (Brutes) | M (95) | MMi (90) | D (0) | M |
| RSB (Raptors, Spitters, Brutes) | MO (88) | M (81) | D (20) | M, MH |
| TC (Tyrant Challengers) | M (91) | MB (90) | D (0) | MH |
| TCS (Tyrant Challengers + Spitters) | MO (90) | M (88) | D (34) | M, MCH |
| VC (Venom Challengers) | H (73) | MCH (36) | D (0) | none |
| StC (Storm Challengers (flyers)) | M (98) | MO (95) | CH (0) | M, MC, MMo, MCMo |
| RSTd (Raptors, Spitters, Mist Toads) | MO (92) | MH (88) | CH (30) | MC, MCH, MH |
| RSy (Raptors and Spitters with the Tyrant Sire) | H (62) | MH (46) | D (19) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (5) | RSy (32) | StC (98) | RSy |
| MC (Musketeers + Field Cannons) | VC (22) | RSy (28) | StC (92) | RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | RSy (36) | VC (36) | RSTd (85) | RSy |
| MMo (Musketeers + Mortars) | VC (0) | RSy (26) | StC (92) | VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | VC (10) | RSy (25) | StC (92) | VC, RSy |
| MH (Musketeers + Horsemen) | VC (20) | S (33) | RSTd (88) | StC |
| H (Horsemen) | StC (0) | TC (0) | VC (73) | none |
| D (Dragoons) | B (0) | StC (0) | TCS (34) | none |
| MD (Musketeers + Dragoons) | VC (10) | RSy (26) | R1S3 (79) | none |
| MO (Musketeers + Officers) | VC (0) | RSy (38) | StC (95) | none |
| MB (Musketeers + the band) | VC (12) | RSy (32) | StC (95) | none |
| MMi (Musketeers + a Missionary) | VC (0) | RSy (30) | B (90) | none |
| CH (Cannons + Horsemen) | StC (0) | B (10) | TC (87) | none |

Best Crown compositions on average: MO 73, M 71, MCH 64, MMi 63. Safest (best at its worst): MCH 36, MC 22, MH 20.
Best Brood compositions on average: VC 85, RSy 67, R 52, R1S1 48 (the Brood's own share). Safest: RSy 38, R1S1 30, VC 27.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **45**. The Crown's best mix: MCH 59%, H 32%, MO 8%, MH 2%. The Brood's: R 38%, VC 37%, RSy 14%, StC 12%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **45**. The Crown's best mix: MCH 69%, H 26%, MH 5%. The Brood's: R 48%, VC 46%, StC 6%.

## The fighting (micro) counts

| ground, size | Crown armies with guns | guns set at contact | guns set 10 s after | guns that fired by 20 s | guns lost per gun | riders lost per rider | the Crown's pulls a fight | the Brood's pulls a fight |
|---|---|---|---|---|---|---|---|---|
| open field, 600 | 260 | 0% | 34% | 38% | 0.84 | 0.91 | 10.5 | 0.7 |
| open field, 1500 | 260 | 0% | 57% | 58% | 0.76 | 0.83 | 3.1 | 1.2 |
| open field, 4000 | 260 | 0% | 61% | 51% | 0.45 | 0.83 | 1.4 | 2.3 |
| the set line (open ground, the Crown formed, guns up), 600 | 195 | 100% | 88% | 27% | 0.74 | 0.92 | 0.0 | 0.6 |
| the set line (open ground, the Crown formed, guns up), 1500 | 195 | 100% | 88% | 49% | 0.51 | 0.89 | 0.0 | 1.0 |
| the set line (open ground, the Crown formed, guns up), 4000 | 195 | 100% | 85% | 46% | 0.17 | 0.87 | 0.0 | 2.1 |
| a choke, 1500 | 195 | 100% | 87% | 47% | 0.52 | 0.89 | 0.0 | 1.0 |
| a ramp, the Crown on top, 1500 | 195 | 100% | 85% | 31% | 0.43 | 0.88 | 0.0 | 1.3 |
| a ramp, the Brood on top, 1500 | 117 | 0% | 64% | 71% | 0.38 | 0.72 | 6.7 | 7.6 |

## What the guns, riders and the rest add (score against the plain Musketeer line, same Brood army)

| ground, size | MC | MCH | MMo | MCMo | MH | H | D | MD | MO | MB | MMi | CH |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| open, 600 | -36 | -14 | -42 | -60 | -27 | -44 | -72 | -43 | +1 | -17 | -20 | -36 |
| open, 1500 | -17 | +1 | -28 | -25 | +17 | -19 | -51 | -23 | -2 | -8 | -7 | -23 |
| open, 4000 | -5 | +5 | -14 | -7 | +14 | -25 | -53 | -14 | +5 | -7 | -3 | +6 |
| set, 600 | -6 | -5 | -18 | -20 | -5 | -25 | -41 | -20 | -15 | -18 | -10 | -3 |
| set, 1500 | +17 | +18 | +6 | +0 | -1 | -16 | -25 | -9 | -7 | -1 | -1 | +28 |
| set, 4000 | +33 | +28 | +24 | +25 | -1 | -18 | -21 | -3 | +1 | -2 | -2 | +27 |
| choke, 600 |  |  |  |  |  |  |  |  |  |  |  |  |
| choke, 1500 | +16 | +16 | +1 | +0 | -1 | -14 | -25 | -10 | -6 | -2 | -2 | +26 |
| choke, 4000 |  |  |  |  |  |  |  |  |  |  |  |  |
| up, 600 |  |  |  |  |  |  |  |  |  |  |  |  |
| up, 1500 | +9 | +6 | -8 | -5 | -7 | -37 | -40 | -20 | -21 | -4 | -3 | +13 |
| up, 4000 |  |  |  |  |  |  |  |  |  |  |  |  |
| down, 600 |  |  |  |  |  |  |  |  |  |  |  |  |
| down, 1500 | -10 | -8 | -21 | -13 | -11 | -30 | -55 | -18 | +2 | -9 | -9 | -37 |
| down, 4000 |  |  |  |  |  |  |  |  |  |  |  |  |

## The fighting or the numbers: open field (the computer marches) against the set line (formed, guns up)

| size | mean score, open | mean score, set | pairings the Brood wins open but the Crown wins set | the Brood wins both | the Crown wins both |
|---|---|---|---|---|---|
| 600 | 40 | 35 | 5 | 61 | 7 |
| 1500 | 45 | 41 | 5 | 54 | 10 |
| 4000 | 54 | 52 | 9 | 38 | 36 |

- 600: the Brood wins open but the Crown wins set: MC-R3S1, MC-R1S1, MMo-R3S1, CH-S, CH-VC. The Brood wins both: M-VC, M-RSy, MC-TC, MC-TCS, MC-VC, MC-StC, MC-RSy, MCH-B, MMo-S, MMo-B, MMo-RSB, MMo-TC, MMo-VC, MMo-StC, MMo-RSy, MCMo-B, MCMo-RSB, MCMo-TC, MCMo-TCS, MCMo-VC, MCMo-StC, MCMo-RSy, MH-VC, MH-RSy, H-R, H-R3S1, H-S, H-B, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-StC, D-RSTd, D-RSy, MD-R, MD-R1S3, MD-S, MD-B, MD-RSB, MD-TCS, MD-VC, MD-RSy, MO-RSy, MB-VC, MB-RSy, MMi-S, MMi-VC, MMi-RSy, CH-B, CH-StC, CH-RSy.
- 1500: the Brood wins open but the Crown wins set: MMo-R, MMo-R3S1, CH-R1S3, CH-RSB, CH-TCS. The Brood wins both: M-R, M-S, M-VC, M-RSy, MC-RSy, MMo-B, MMo-RSB, MMo-VC, MMo-RSy, MCMo-S, MCMo-VC, MCMo-RSy, MH-RSy, H-R, H-R3S1, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-StC, D-RSTd, D-RSy, MD-R, MD-R3S1, MD-R1S1, MD-S, MD-RSB, MD-TC, MD-TCS, MD-VC, MD-RSy, MO-R, MO-S, MO-VC, MO-RSy, MB-R, MB-S, MB-VC, MB-RSy, MMi-R, MMi-R1S3, MMi-S, MMi-VC, MMi-RSy, CH-StC.
- 4000: the Brood wins open but the Crown wins set: MC-RSy, MCH-RSy, MMo-R, MMo-R1S1, MMo-RSB, MMo-RSy, MCMo-RSB, MCMo-VC, MCMo-RSy. The Brood wins both: M-S, M-VC, M-RSy, MMo-VC, H-R, H-R3S1, H-R1S3, H-S, H-TCS, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-RSTd, D-RSy, MD-R, MD-R1S3, MD-S, MD-RSB, MD-VC, MD-RSy, MO-VC, MB-R, MB-S, MB-VC, MB-RSy, MMi-S, MMi-VC, MMi-RSy, CH-StC.

| Crown composition | open 600 | set 600 | open 1500 | set 1500 | open 4000 | set 4000 |
|---|---|---|---|---|---|---|
| M | 72 | 49 | 59 | 41 | 61 | 45 |
| MC | 36 | 43 | 42 | 57 | 56 | 78 |
| MCH | 58 | 44 | 61 | 58 | 67 | 73 |
| MMo | 30 | 31 | 31 | 46 | 47 | 69 |
| MCMo | 12 | 30 | 34 | 41 | 54 | 71 |
| MH | 45 | 44 | 76 | 40 | 76 | 45 |
| H | 28 | 24 | 40 | 25 | 36 | 27 |
| D | 0 | 8 | 8 | 15 | 8 | 24 |
| MD | 29 | 29 | 36 | 32 | 47 | 42 |
| MO | 73 | 34 | 57 | 34 | 66 | 46 |
| MB | 55 | 31 | 51 | 39 | 54 | 43 |
| MMi | 51 | 40 | 52 | 40 | 58 | 43 |
| CH | 35 | 46 | 36 | 69 | 67 | 72 |
