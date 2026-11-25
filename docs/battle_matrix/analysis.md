# The battle matrix: the analysis (made by tools/study/battle_matrix_report.py)

3228 fights. Score = the Crown's share of the value lost in the fight (50 = even). C = the Crown clearly ahead (the 95% interval above 50), B = the Brood clearly ahead, = = not told apart.


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

## the set line (open ground, the Crown formed, guns up), late (4,000) (186 fights)

Pairings: the Crown clearly ahead in **5**, the Brood in **6**, even in 158 (of 169). Mean score over all pairings: 52.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MMo (90) | CH (84) | H (17) | none |
| R3S1 (Raptors, a few Spitters (3:1)) | MMo (86) | MC (83) | H (18) | MC |
| R1S1 (Raptors and Spitters (1:1)) | CH (91) | MC (89) | H (24) | MC |
| R1S3 (Spitters, a few Raptors (3:1)) | MCMo (78) | MC (78) | H (22) | MC |
| S (Spitters) | MMo (77) | MC (76) | D (10) | none |
| B (Brutes) | CH (91) | MC (84) | D (18) | none |
| RSB (Raptors, Spitters, Brutes) | MCH (85) | CH (83) | D (26) | none |
| TC (Tyrant Challengers) | MMo (87) | MCMo (84) | D (26) | M |
| TCS (Tyrant Challengers + Spitters) | MC (84) | MCMo (77) | H (13) | none |
| VC (Venom Challengers) | CH (88) | MCH (61) | D (0) | none |
| StC (Storm Challengers (flyers)) | M (91) | MMi (90) | CH (0) | M |
| RSTd (Raptors, Spitters, Mist Toads) | MCH (88) | MMo (85) | H (23) | none |
| RSy (Raptors and Spitters with the Tyrant Sire) | MCMo (76) | MC (73) | H (19) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (10) | R (29) | StC (91) | R, R1S1, TCS, VC, RSTd, RSy |
| MC (Musketeers + Field Cannons) | VC (52) | RSy (73) | R1S1 (89) | none |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (53) | VC (61) | RSTd (88) | none |
| MMo (Musketeers + Mortars) | VC (23) | B (28) | R (90) | none |
| MCMo (Musketeers + Cannons + Mortars) | StC (15) | VC (58) | R1S1 (86) | none |
| MH (Musketeers + Horsemen) | VC (4) | S (29) | StC (83) | none |
| H (Horsemen) | StC (0) | TCS (13) | TC (75) | none |
| D (Dragoons) | VC (0) | S (10) | StC (35) | none |
| MD (Musketeers + Dragoons) | VC (15) | S (27) | StC (85) | none |
| MO (Musketeers + Officers) | VC (4) | S (24) | StC (82) | none |
| MB (Musketeers + the band) | VC (9) | R (26) | StC (89) | none |
| MMi (Musketeers + a Missionary) | VC (8) | R (29) | StC (90) | none |
| CH (Cannons + Horsemen) | StC (0) | RSy (66) | B (91) | none |

Best Crown compositions on average: MC 79, CH 74, MCH 73, MCMo 71. Safest (best at its worst): MCH 53, MC 52, MMo 23.
Best Brood compositions on average: VC 73, S 56, RSy 53, R 50 (the Brood's own share). Safest: RSy 24, S 23, R1S3 21.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: MC, MCH (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **61**. The Crown's best mix: MC 73%, CH 27%. The Brood's: VC 70%, StC 30%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **61**. The Crown's best mix: MC 73%, CH 27%. The Brood's: VC 70%, StC 30%.

## The fighting (micro) counts

| ground, size | Crown armies with guns | guns set at contact | guns set 10 s after | guns that fired by 20 s | guns lost per gun | riders lost per rider | the Crown's pulls a fight | the Brood's pulls a fight |
|---|---|---|---|---|---|---|---|---|
| open field, 600 | 260 | 0% | 34% | 38% | 0.84 | 0.91 | 10.5 | 0.7 |
| open field, 1500 | 260 | 0% | 57% | 58% | 0.76 | 0.83 | 3.1 | 1.2 |
| open field, 4000 | 260 | 0% | 61% | 51% | 0.45 | 0.83 | 1.4 | 2.3 |
| the set line (open ground, the Crown formed, guns up), 600 | 195 | 100% | 88% | 27% | 0.74 | 0.92 | 0.0 | 0.6 |
| the set line (open ground, the Crown formed, guns up), 1500 | 195 | 100% | 88% | 49% | 0.51 | 0.89 | 0.0 | 1.0 |
| the set line (open ground, the Crown formed, guns up), 4000 | 69 | 100% | 84% | 40% | 0.15 | 0.87 | 0.0 | 2.1 |

## What the guns, riders and the rest add (score against the plain Musketeer line, same Brood army)

| ground, size | MC | MCH | MMo | MCMo | MH | H | D | MD | MO | MB | MMi | CH |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| open, 600 | -36 | -14 | -42 | -60 | -27 | -44 | -72 | -43 | +1 | -17 | -20 | -36 |
| open, 1500 | -17 | +1 | -28 | -25 | +17 | -19 | -51 | -23 | -2 | -8 | -7 | -23 |
| open, 4000 | -5 | +5 | -14 | -7 | +14 | -25 | -53 | -14 | +5 | -7 | -3 | +6 |
| set, 600 | -6 | -5 | -18 | -20 | -5 | -25 | -41 | -20 | -15 | -18 | -10 | -3 |
| set, 1500 | +17 | +18 | +6 | +0 | -1 | -16 | -25 | -9 | -7 | -1 | -1 | +28 |
| set, 4000 | +34 | +27 | +22 | +25 | -2 | -21 | -22 | -4 | +1 | -4 | -2 | +28 |

## The fighting or the numbers: open field (the computer marches) against the set line (formed, guns up)

| size | mean score, open | mean score, set | pairings the Brood wins open but the Crown wins set | the Brood wins both | the Crown wins both |
|---|---|---|---|---|---|
| 600 | 40 | 35 | 5 | 61 | 7 |
| 1500 | 45 | 41 | 5 | 54 | 10 |
| 4000 | 54 | 52 | 0 | 2 | 2 |

- 600: the Brood wins open but the Crown wins set: MC-R3S1, MC-R1S1, MMo-R3S1, CH-S, CH-VC. The Brood wins both: M-VC, M-RSy, MC-TC, MC-TCS, MC-VC, MC-StC, MC-RSy, MCH-B, MMo-S, MMo-B, MMo-RSB, MMo-TC, MMo-VC, MMo-StC, MMo-RSy, MCMo-B, MCMo-RSB, MCMo-TC, MCMo-TCS, MCMo-VC, MCMo-StC, MCMo-RSy, MH-VC, MH-RSy, H-R, H-R3S1, H-S, H-B, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-StC, D-RSTd, D-RSy, MD-R, MD-R1S3, MD-S, MD-B, MD-RSB, MD-TCS, MD-VC, MD-RSy, MO-RSy, MB-VC, MB-RSy, MMi-S, MMi-VC, MMi-RSy, CH-B, CH-StC, CH-RSy.
- 1500: the Brood wins open but the Crown wins set: MMo-R, MMo-R3S1, CH-R1S3, CH-RSB, CH-TCS. The Brood wins both: M-R, M-S, M-VC, M-RSy, MC-RSy, MMo-B, MMo-RSB, MMo-VC, MMo-RSy, MCMo-S, MCMo-VC, MCMo-RSy, MH-RSy, H-R, H-R3S1, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-StC, D-RSTd, D-RSy, MD-R, MD-R3S1, MD-R1S1, MD-S, MD-RSB, MD-TC, MD-TCS, MD-VC, MD-RSy, MO-R, MO-S, MO-VC, MO-RSy, MB-R, MB-S, MB-VC, MB-RSy, MMi-R, MMi-R1S3, MMi-S, MMi-VC, MMi-RSy, CH-StC.
- 4000: the Brood wins open but the Crown wins set: none. The Brood wins both: M-VC, M-RSy.

| Crown composition | open 600 | set 600 | open 1500 | set 1500 | open 4000 | set 4000 |
|---|---|---|---|---|---|---|
| M | 72 | 49 | 59 | 41 | 61 | 46 |
| MC | 36 | 43 | 42 | 57 | 56 | 80 |
| MCH | 58 | 44 | 61 | 58 | 67 | 73 |
| MMo | 30 | 31 | 31 | 46 | 47 | 67 |
| MCMo | 12 | 30 | 34 | 41 | 54 | 71 |
| MH | 45 | 44 | 76 | 40 | 76 | 43 |
| H | 28 | 24 | 40 | 25 | 36 | 25 |
| D | 0 | 8 | 8 | 15 | 8 | 23 |
| MD | 29 | 29 | 36 | 32 | 47 | 41 |
| MO | 73 | 34 | 57 | 34 | 66 | 47 |
| MB | 55 | 31 | 51 | 39 | 54 | 42 |
| MMi | 51 | 40 | 52 | 40 | 58 | 44 |
| CH | 35 | 46 | 36 | 69 | 67 | 74 |
