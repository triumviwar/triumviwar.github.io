# The battle matrix: the analysis (made by tools/study/battle_matrix_report.py)

8450 fights. Score = the Crown's share of the value lost in the fight (50 = even). C = the Crown clearly ahead (the 95% interval above 50), B = the Brood clearly ahead, = = not told apart.


## open field, at the supply cap (150 army supply each, late research) (338 fights)

Pairings: the Crown clearly ahead in **72**, the Brood in **11**, even in 86 (of 169). Mean score over all pairings: 64.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (95) | MH (80) | D (24) | M, MD, MB, CH |
| R3S1 (Raptors, a few Spitters (3:1)) | MH (76) | H (73) | D (7) | MC, MCH, MMo, MH, MO |
| R1S1 (Raptors and Spitters (1:1)) | MH (82) | MCH (74) | D (40) | M, MCMo, MD, MO |
| R1S3 (Spitters, a few Raptors (3:1)) | MMo (69) | MMi (69) | D (48) | M, MMo, MCMo, MD, MB |
| S (Spitters) | MH (83) | MCMo (63) | D (4) | MH, MB |
| B (Brutes) | MMi (98) | MH (98) | MCH (80) | M, MC, MCH, MH, H, D, MD, MO, MB, MMi, CH |
| RSB (Raptors, Spitters, Brutes) | MH (83) | MCH (78) | D (57) | M, MMo, MH, MD, MO, MB |
| TC (Tyrant Challengers) | MH (90) | CH (90) | H (31) | M, MC, MCH, MMo, MCMo, MH, MD, MO, MB, MMi |
| TCS (Tyrant Challengers + Spitters) | M (73) | MMi (70) | D (10) | M, MC, MMo, MD |
| VC (Venom Challengers) | MH (90) | MCH (67) | D (0) | MCH, MH |
| StC (Storm Challengers (flyers)) | MCH (82) | M (81) | H (0) | M, MC, MCMo, MD, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | H (89) | MH (88) | D (53) | M, MC, MMo, MCMo, MH, MO, MB, MMi |
| RSy (Raptors and Spitters with the Tyrant Sire) | MH (74) | MCH (73) | H (43) | M, MMo, MD, MO, CH |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (25) | S (62) | B (98) | VC |
| MC (Musketeers + Field Cannons) | VC (53) | S (57) | B (82) | none |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | R (59) | S (63) | StC (82) | none |
| MMo (Musketeers + Mortars) | VC (25) | StC (43) | B (83) | VC, StC |
| MCMo (Musketeers + Cannons + Mortars) | R (57) | R3S1 (59) | B (83) | none |
| MH (Musketeers + Horsemen) | StC (51) | R1S3 (68) | B (98) | none |
| H (Horsemen) | StC (0) | S (13) | B (89) | S, TC, StC |
| D (Dragoons) | VC (0) | S (4) | B (86) | R1S3, TCS, VC |
| MD (Musketeers + Dragoons) | VC (15) | S (26) | B (96) | none |
| MO (Musketeers + Officers) | VC (2) | S (30) | B (92) | VC, StC |
| MB (Musketeers + the band) | VC (13) | S (56) | B (96) | none |
| MMi (Musketeers + a Missionary) | VC (19) | S (57) | B (98) | none |
| CH (Cannons + Horsemen) | StC (35) | TCS (41) | R (95) | none |

Best Crown compositions on average: MH 79, MCH 72, M 71, MMi 69. Safest (best at its worst): MCH 59, MCMo 57, MC 53.
Best Brood compositions on average: VC 66, S 52, StC 44, TCS 43 (the Brood's own share). Safest: R1S3 31, TCS 27, RSy 26.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: MC, MCH, MCMo, MH (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **68**. The Crown's best mix: MH 44%, MCH 38%, MMi 19%. The Brood's: R1S3 94%, StC 3%, VC 3%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **68**. The Crown's best mix: MH 44%, MCH 38%, MMi 19%. The Brood's: R1S3 94%, StC 3%, VC 3%.

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

## the set block (open ground, the Crown in a close block, guns up), early (600) (338 fights)

Pairings: the Crown clearly ahead in **10**, the Brood in **56**, even in 103 (of 169). Mean score over all pairings: 35.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MMo (89) | MCH (78) | D (10) | MMo |
| R3S1 (Raptors, a few Spitters (3:1)) | MCH (95) | MC (94) | D (16) | MCMo, MMi |
| R1S1 (Raptors and Spitters (1:1)) | CH (84) | MC (78) | D (11) | MH, CH |
| R1S3 (Spitters, a few Raptors (3:1)) | MCH (55) | MC (54) | D (15) | none |
| S (Spitters) | CH (75) | MC (49) | D (7) | none |
| B (Brutes) | MH (35) | MB (25) | D (0) | none |
| RSB (Raptors, Spitters, Brutes) | H (47) | CH (40) | MMo (15) | none |
| TC (Tyrant Challengers) | MH (72) | MCH (58) | D (0) | none |
| TCS (Tyrant Challengers + Spitters) | CH (80) | MH (39) | D (0) | none |
| VC (Venom Challengers) | CH (61) | MCMo (11) | D (0) | CH |
| StC (Storm Challengers (flyers)) | M (79) | MO (55) | CH (0) | M |
| RSTd (Raptors, Spitters, Mist Toads) | M (88) | MCH (87) | D (21) | M, MC, MCH |
| RSy (Raptors and Spitters with the Tyrant Sire) | MCH (38) | MB (33) | MD (20) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (0) | B (11) | RSTd (88) | VC, RSy |
| MC (Musketeers + Field Cannons) | B (0) | VC (11) | R3S1 (94) | B, RSB, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | B (0) | StC (0) | R3S1 (95) | B, RSB, StC |
| MMo (Musketeers + Mortars) | B (0) | TCS (0) | R (89) | R1S3, B, RSB, TC, TCS, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | B (0) | StC (0) | R3S1 (80) | B, RSB, TC, TCS, StC, RSy |
| MH (Musketeers + Horsemen) | VC (0) | S (17) | RSTd (80) | VC |
| H (Horsemen) | StC (0) | B (11) | RSTd (80) | R, R1S1, StC, RSy |
| D (Dragoons) | B (0) | StC (0) | RSTd (21) | R1S3, B, RSB, TC, TCS, VC, StC, RSTd |
| MD (Musketeers + Dragoons) | B (0) | VC (0) | StC (54) | R1S1, B, RSB, TC, TCS, VC, RSy |
| MO (Musketeers + Officers) | B (0) | VC (0) | RSTd (62) | R1S3, B, RSB, VC, RSy |
| MB (Musketeers + the band) | VC (0) | RSB (22) | R3S1 (64) | R1S3, B, RSB, TC, VC, RSy |
| MMi (Musketeers + a Missionary) | B (0) | VC (0) | R3S1 (69) | B, VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | B (12) | R1S1 (84) | StC |

Best Crown compositions on average: M 49, CH 49, MH 45, MCH 44. Safest (best at its worst): MO 0, MMo 0, MMi 0.
Best Brood compositions on average: B 93, VC 92, TCS 75, RSy 74 (the Brood's own share). Safest: B 65, RSy 62, RSB 53.
Brood compositions that out-trade EVERY Crown composition: B, RSB, RSy (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **25**. The Crown's best mix: MH 58%, CH 42%. The Brood's: B 72%, VC 28%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **25**. The Crown's best mix: MH 58%, CH 42%. The Brood's: B 72%, VC 28%.

## the set block (open ground, the Crown in a close block, guns up), mid (1,500) (338 fights)

Pairings: the Crown clearly ahead in **16**, the Brood in **49**, even in 104 (of 169). Mean score over all pairings: 42.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (97) | MC (76) | D (12) | CH |
| R3S1 (Raptors, a few Spitters (3:1)) | CH (100) | MC (84) | H (16) | MC, MMo, CH |
| R1S1 (Raptors and Spitters (1:1)) | CH (76) | MCH (75) | H (23) | MCH |
| R1S3 (Spitters, a few Raptors (3:1)) | CH (88) | MMo (60) | D (20) | CH |
| S (Spitters) | MC (59) | MMo (53) | D (5) | MC, CH |
| B (Brutes) | CH (72) | MCH (66) | D (0) | MCH |
| RSB (Raptors, Spitters, Brutes) | CH (94) | MC (71) | D (24) | MC, CH |
| TC (Tyrant Challengers) | MCH (84) | CH (66) | D (10) | MCH |
| TCS (Tyrant Challengers + Spitters) | MCH (71) | MC (70) | D (13) | MCH |
| VC (Venom Challengers) | MCH (39) | MC (36) | D (0) | none |
| StC (Storm Challengers (flyers)) | MMi (88) | M (85) | CH (0) | MMi |
| RSTd (Raptors, Spitters, Mist Toads) | CH (85) | MC (84) | D (29) | MC, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | CH (51) | MCH (44) | D (15) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (10) | B (28) | StC (85) | R1S3, TCS, VC, RSy |
| MC (Musketeers + Field Cannons) | StC (28) | RSy (34) | RSTd (84) | RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (27) | VC (39) | TC (84) | StC |
| MMo (Musketeers + Mortars) | VC (5) | B (10) | R3S1 (71) | B, RSy |
| MCMo (Musketeers + Cannons + Mortars) | VC (5) | B (26) | R (71) | B, RSy |
| MH (Musketeers + Horsemen) | VC (0) | S (19) | StC (76) | R1S1, VC, RSTd |
| H (Horsemen) | StC (0) | VC (9) | R1S3 (53) | R, R3S1, B, StC, RSy |
| D (Dragoons) | B (0) | VC (0) | RSTd (29) | R, R1S3, S, B, RSB, TC, VC, RSy |
| MD (Musketeers + Dragoons) | VC (0) | B (10) | StC (74) | R1S1, S, B, VC, RSy |
| MO (Musketeers + Officers) | VC (5) | S (15) | StC (60) | R3S1, R1S1, R1S3, S, RSy |
| MB (Musketeers + the band) | VC (12) | B (20) | StC (78) | R, R1S1, R1S3, B, RSB, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (6) | B (11) | StC (88) | R, S, B, TC, RSy |
| CH (Cannons + Horsemen) | StC (0) | VC (36) | R3S1 (100) | StC |

Best Crown compositions on average: CH 68, MCH 61, MC 59, MMo 45. Safest (best at its worst): MC 28, MCH 27, MB 12.
Best Brood compositions on average: VC 88, B 72, S 68, RSy 66 (the Brood's own share). Safest: VC 61, RSy 49, S 41.
Brood compositions that out-trade EVERY Crown composition: VC (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **35**. The Crown's best mix: MCH 86%, M 14%. The Brood's: VC 67%, StC 33%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **35**. The Crown's best mix: MCH 86%, M 14%. The Brood's: VC 67%, StC 33%.

## the set block (open ground, the Crown in a close block, guns up), late (4,000) (338 fights)

Pairings: the Crown clearly ahead in **45**, the Brood in **35**, even in 89 (of 169). Mean score over all pairings: 53.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (82) | MMo (81) | H (18) | MMo, MCMo, CH |
| R3S1 (Raptors, a few Spitters (3:1)) | CH (86) | MMo (80) | H (23) | MMo, MCMo, MB |
| R1S1 (Raptors and Spitters (1:1)) | MC (86) | CH (84) | H (19) | MC, MCH, MMo, MCMo |
| R1S3 (Spitters, a few Raptors (3:1)) | MC (79) | CH (78) | D (25) | MC, CH |
| S (Spitters) | MMo (70) | MCH (70) | D (10) | MC |
| B (Brutes) | CH (86) | MCH (82) | D (10) | MC, MH, MO |
| RSB (Raptors, Spitters, Brutes) | CH (82) | MC (81) | D (28) | MCH |
| TC (Tyrant Challengers) | MCH (83) | MMo (82) | D (28) | M, MC, MMo, MCMo, MH, H, MD, MO, MB, CH |
| TCS (Tyrant Challengers + Spitters) | MC (81) | CH (79) | H (17) | MC, MCH, MCMo |
| VC (Venom Challengers) | CH (89) | MCMo (64) | D (2) | MCH, MCMo, CH |
| StC (Storm Challengers (flyers)) | M (87) | MMi (86) | CH (0) | M, MC, MD, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | CH (87) | MC (85) | D (31) | MCH, MMo, MCMo, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | MCH (76) | MC (72) | H (18) | MC, MCMo |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (16) | S (39) | StC (87) | R3S1, R1S1, S, VC, RSTd |
| MC (Musketeers + Field Cannons) | VC (62) | B (64) | R1S1 (86) | none |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (37) | VC (61) | RSTd (83) | none |
| MMo (Musketeers + Mortars) | VC (28) | B (34) | TC (82) | none |
| MCMo (Musketeers + Cannons + Mortars) | StC (30) | VC (64) | R3S1 (80) | StC |
| MH (Musketeers + Horsemen) | VC (8) | RSy (33) | TC (80) | R3S1, S, RSy |
| H (Horsemen) | StC (0) | S (14) | TC (77) | R, S, StC, RSy |
| D (Dragoons) | VC (2) | B (10) | StC (43) | R, R1S3, S, B, RSB, TC, VC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (11) | S (31) | StC (83) | R3S1, S, VC, RSy |
| MO (Musketeers + Officers) | VC (11) | S (26) | StC (76) | R, R1S1, R1S3, S, VC, RSTd, RSy |
| MB (Musketeers + the band) | VC (18) | S (36) | StC (83) | S |
| MMi (Musketeers + a Missionary) | VC (16) | S (37) | StC (86) | none |
| CH (Cannons + Horsemen) | StC (0) | S (58) | VC (89) | StC |

Best Crown compositions on average: MC 76, CH 72, MCH 72, MCMo 69. Safest (best at its worst): MC 62, MCH 37, MCMo 30.
Best Brood compositions on average: VC 69, S 57, RSy 54, R1S3 49 (the Brood's own share). Safest: S 30, RSy 24, R1S3 21.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: MC (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **66**. The Crown's best mix: MC 78%, CH 16%, MCH 7%. The Brood's: S 65%, VC 31%, StC 3%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **66**. The Crown's best mix: MC 78%, CH 16%, MCH 7%. The Brood's: S 65%, VC 31%, StC 3%.

## a choke, early (600) (338 fights)

Pairings: the Crown clearly ahead in **9**, the Brood in **55**, even in 105 (of 169). Mean score over all pairings: 34.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MCH (85) | MC (77) | D (10) | none |
| R3S1 (Raptors, a few Spitters (3:1)) | MH (89) | MCH (88) | D (10) | MCH, MMo, MCMo, MH |
| R1S1 (Raptors and Spitters (1:1)) | MC (81) | MCH (75) | D (13) | MCMo |
| R1S3 (Spitters, a few Raptors (3:1)) | M (62) | MCH (55) | D (18) | none |
| S (Spitters) | CH (74) | MC (61) | D (4) | MC |
| B (Brutes) | H (42) | MH (29) | D (0) | none |
| RSB (Raptors, Spitters, Brutes) | CH (41) | H (38) | MMo (15) | none |
| TC (Tyrant Challengers) | MH (88) | H (48) | D (0) | MH |
| TCS (Tyrant Challengers + Spitters) | CH (53) | M (53) | D (0) | none |
| VC (Venom Challengers) | CH (72) | MCMo (30) | D (0) | none |
| StC (Storm Challengers (flyers)) | M (83) | MD (68) | CH (0) | none |
| RSTd (Raptors, Spitters, Mist Toads) | M (88) | MC (85) | D (21) | M, MH |
| RSy (Raptors and Spitters with the Tyrant Sire) | CH (38) | MB (33) | H (17) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (0) | RSy (20) | RSTd (88) | B, RSB, VC, RSy |
| MC (Musketeers + Field Cannons) | B (0) | VC (0) | RSTd (85) | R1S3, B, VC |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | B (0) | StC (0) | R3S1 (88) | B, TC, StC |
| MMo (Musketeers + Mortars) | B (0) | TCS (0) | RSTd (80) | B, RSB, TC, TCS, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | B (0) | StC (0) | R3S1 (80) | B, TC, TCS, StC, RSTd |
| MH (Musketeers + Horsemen) | VC (0) | S (17) | R3S1 (89) | VC |
| H (Horsemen) | StC (0) | VC (0) | RSTd (76) | R, R1S3, VC, StC |
| D (Dragoons) | B (0) | StC (0) | RSTd (21) | R, R3S1, B, RSB, TC, TCS, VC, StC, RSTd |
| MD (Musketeers + Dragoons) | B (0) | VC (0) | StC (68) | S, B, RSB, TCS, VC, RSy |
| MO (Musketeers + Officers) | B (0) | VC (0) | RSTd (80) | R3S1, S, B, RSB, VC, RSy |
| MB (Musketeers + the band) | B (12) | VC (12) | R1S1 (46) | R1S1, RSB, RSy |
| MMi (Musketeers + a Missionary) | B (0) | VC (0) | RSTd (64) | B, VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | B (12) | RSTd (79) | RSB, StC |

Best Crown compositions on average: M 51, CH 47, MH 42, MCH 41. Safest (best at its worst): MB 12, MO 0, MMo 0.
Best Brood compositions on average: B 91, VC 90, TCS 77, StC 74 (the Brood's own share). Safest: RSy 62, RSB 59, B 58.
Brood compositions that out-trade EVERY Crown composition: B, RSB, RSy (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **25**. The Crown's best mix: CH 35%, H 34%, M 30%. The Brood's: B 61%, VC 25%, StC 14%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **25**. The Crown's best mix: CH 35%, H 34%, M 30%. The Brood's: B 61%, VC 25%, StC 14%.

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

## a choke, late (4,000) (338 fights)

Pairings: the Crown clearly ahead in **43**, the Brood in **52**, even in 74 (of 169). Mean score over all pairings: 53.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (90) | MMo (87) | H (18) | MC, MCH, MMo, MCMo |
| R3S1 (Raptors, a few Spitters (3:1)) | MC (86) | MMo (86) | H (21) | MCH, MMo, MCMo |
| R1S1 (Raptors and Spitters (1:1)) | MC (85) | MCMo (78) | H (19) | MC, MMo, CH |
| R1S3 (Spitters, a few Raptors (3:1)) | MC (81) | MMo (75) | D (26) | MC, MCH, MMo |
| S (Spitters) | MMo (76) | CH (73) | D (11) | MCH, MMo, MCMo, CH |
| B (Brutes) | MCH (87) | CH (87) | D (13) | MH, CH |
| RSB (Raptors, Spitters, Brutes) | MC (89) | MCH (83) | H (19) | MCH, MMo |
| TC (Tyrant Challengers) | MH (84) | MC (84) | D (28) | M, MCMo, MH, H, CH |
| TCS (Tyrant Challengers + Spitters) | MCMo (83) | MC (80) | H (15) | MC, MMo, MCMo |
| VC (Venom Challengers) | CH (89) | MCMo (64) | D (0) | MCMo |
| StC (Storm Challengers (flyers)) | M (90) | MMi (89) | CH (0) | M, MC, MH, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MC (92) | MCH (86) | D (31) | MC, MCH, MMo, MCMo, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | MC (74) | MCH (73) | H (22) | MCH, MMo, CH |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (10) | R (32) | StC (90) | R, R3S1, S, TCS, VC, RSy |
| MC (Musketeers + Field Cannons) | VC (59) | S (72) | RSTd (92) | none |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | VC (52) | StC (61) | B (87) | none |
| MMo (Musketeers + Mortars) | VC (24) | B (35) | R (87) | VC |
| MCMo (Musketeers + Cannons + Mortars) | StC (33) | VC (64) | R3S1 (83) | StC |
| MH (Musketeers + Horsemen) | VC (2) | S (28) | TC (84) | R1S1, R1S3, S, TCS, VC, RSy |
| H (Horsemen) | StC (0) | S (14) | TC (84) | R, RSB, TCS, VC, StC, RSTd, RSy |
| D (Dragoons) | VC (0) | S (11) | StC (40) | R, R3S1, R1S1, R1S3, S, B, RSB, VC |
| MD (Musketeers + Dragoons) | VC (11) | S (27) | StC (84) | R, R1S3, S, RSTd |
| MO (Musketeers + Officers) | VC (8) | S (25) | StC (80) | R1S3, S, RSB, VC, RSTd, RSy |
| MB (Musketeers + the band) | VC (11) | R (27) | StC (87) | R, R1S3, S, RSB, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (10) | R (26) | StC (89) | R, R1S1, S, B, VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | R1S3 (61) | R (90) | StC |

Best Crown compositions on average: MC 80, MCH 75, CH 72, MCMo 72. Safest (best at its worst): MC 59, MCH 52, MCMo 33.
Best Brood compositions on average: VC 72, S 57, RSy 52, R1S3 49 (the Brood's own share). Safest: RSy 26, S 24, R1S3 19.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: MC, MCH (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **65**. The Crown's best mix: MC 80%, CH 20%. The Brood's: VC 73%, StC 27%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **65**. The Crown's best mix: MC 80%, CH 20%. The Brood's: VC 73%, StC 27%.

## a ramp, the Crown on top, early (600) (338 fights)

Pairings: the Crown clearly ahead in **13**, the Brood in **56**, even in 100 (of 169). Mean score over all pairings: 37.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MH (100) | H (100) | D (18) | M, MCH, MH, H |
| R3S1 (Raptors, a few Spitters (3:1)) | MH (68) | CH (65) | H (11) | none |
| R1S1 (Raptors and Spitters (1:1)) | MC (90) | CH (84) | D (15) | CH |
| R1S3 (Spitters, a few Raptors (3:1)) | MCH (78) | MC (67) | D (15) | MH |
| S (Spitters) | CH (100) | MC (61) | D (0) | MC, CH |
| B (Brutes) | MH (47) | CH (24) | D (0) | none |
| RSB (Raptors, Spitters, Brutes) | MCH (69) | H (53) | MMo (15) | none |
| TC (Tyrant Challengers) | MH (71) | H (68) | D (0) | none |
| TCS (Tyrant Challengers + Spitters) | M (60) | MCH (46) | D (0) | none |
| VC (Venom Challengers) | CH (100) | MCMo (37) | D (0) | CH |
| StC (Storm Challengers (flyers)) | M (89) | MD (75) | CH (0) | MO |
| RSTd (Raptors, Spitters, Mist Toads) | MCH (100) | M (94) | D (20) | MC, MCH, MMi |
| RSy (Raptors and Spitters with the Tyrant Sire) | MB (33) | MH (32) | H (14) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | B (11) | RSy (20) | RSTd (94) | R1S3, VC, RSy |
| MC (Musketeers + Field Cannons) | B (11) | TCS (15) | R1S1 (90) | TCS, VC, StC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (0) | VC (0) | RSTd (100) | VC, StC, RSy |
| MMo (Musketeers + Mortars) | B (0) | TCS (8) | R1S1 (64) | R, B, RSB, TC, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | B (0) | StC (0) | RSTd (38) | B, RSB, TC, VC, StC |
| MH (Musketeers + Horsemen) | VC (0) | S (25) | R (100) | VC |
| H (Horsemen) | B (0) | StC (0) | R (100) | S, B, TCS, VC, StC, RSy |
| D (Dragoons) | B (0) | S (0) | RSTd (20) | R1S3, S, B, RSB, TC, TCS, VC, StC |
| MD (Musketeers + Dragoons) | B (0) | VC (0) | StC (75) | R3S1, B, RSB, TCS, VC, RSy |
| MO (Musketeers + Officers) | B (12) | VC (12) | StC (71) | RSB, TCS, RSy |
| MB (Musketeers + the band) | VC (0) | TCS (9) | R (65) | R1S3, S, RSB, VC, RSy |
| MMi (Musketeers + a Missionary) | B (12) | TC (24) | RSTd (90) | RSB, VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | TC (17) | VC (100) | B, TC, StC |

Best Crown compositions on average: MH 54, M 51, CH 48, MC 46. Safest (best at its worst): MMi 12, MO 12, MC 11.
Best Brood compositions on average: B 89, VC 81, RSy 77, TCS 74 (the Brood's own share). Safest: RSy 67, B 53, TCS 40.
Brood compositions that out-trade EVERY Crown composition: B, RSy (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **29**. The Crown's best mix: MH 51%, CH 29%, MB 20%. The Brood's: RSy 87%, VC 11%, TCS 2%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **35**. The Crown's best mix: MH 55%, CH 35%, MCH 10%. The Brood's: TCS 39%, B 30%, RSB 20%, VC 11%.

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

## a ramp, the Crown on top, late (4,000) (338 fights)

Pairings: the Crown clearly ahead in **48**, the Brood in **41**, even in 80 (of 169). Mean score over all pairings: 55.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MMo (88) | MCH (88) | H (23) | MC, MCH, MMo, MCMo, CH |
| R3S1 (Raptors, a few Spitters (3:1)) | MCH (88) | MC (88) | H (21) | MC, MCH, MMo, MCMo |
| R1S1 (Raptors and Spitters (1:1)) | MC (84) | CH (84) | H (20) | MMo, MCMo |
| R1S3 (Spitters, a few Raptors (3:1)) | MCMo (79) | MCH (79) | H (18) | MC, MCH, MMo, MCMo |
| S (Spitters) | CH (86) | MC (81) | D (14) | MC, MCH, CH |
| B (Brutes) | MC (99) | MCMo (95) | D (23) | M, MC, MCH, MCMo, MH, MO, CH |
| RSB (Raptors, Spitters, Brutes) | MC (82) | CH (78) | H (18) | MC |
| TC (Tyrant Challengers) | MC (93) | MCH (91) | D (36) | M, MCH, MMo, MCMo, MH, H, MO, MMi |
| TCS (Tyrant Challengers + Spitters) | MCH (81) | MC (81) | H (21) | MCMo, CH |
| VC (Venom Challengers) | CH (97) | MC (78) | D (4) | MCH, CH |
| StC (Storm Challengers (flyers)) | M (89) | MMi (85) | CH (0) | M, MH, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MC (94) | MCMo (92) | H (28) | MC, MCH, MCMo, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | MC (84) | MCH (77) | H (23) | MCH, MMo |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (14) | R (28) | StC (89) | R, R1S1, R1S3, S, TCS, RSy |
| MC (Musketeers + Field Cannons) | StC (76) | R1S3 (77) | B (99) | none |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | StC (44) | VC (66) | B (94) | none |
| MMo (Musketeers + Mortars) | VC (35) | StC (42) | TC (90) | none |
| MCMo (Musketeers + Cannons + Mortars) | StC (26) | VC (73) | B (95) | none |
| MH (Musketeers + Horsemen) | VC (9) | S (26) | TC (82) | S, RSy |
| H (Horsemen) | StC (0) | VC (6) | B (69) | R3S1, R1S3, RSB, TCS, StC, RSy |
| D (Dragoons) | VC (4) | S (14) | StC (37) | R, R1S1, R1S3, S, B, RSB, TC, VC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (18) | R (30) | StC (85) | R, R1S1, R1S3, VC, RSy |
| MO (Musketeers + Officers) | VC (13) | S (40) | B (85) | R1S1, R1S3, RSB, TCS, VC |
| MB (Musketeers + the band) | VC (22) | R (27) | StC (85) | R, R3S1, R1S3, S |
| MMi (Musketeers + a Missionary) | VC (14) | R (25) | StC (85) | R, RSy |
| CH (Cannons + Horsemen) | StC (0) | RSy (68) | VC (97) | StC |

Best Crown compositions on average: MC 85, MCH 79, MCMo 78, CH 76. Safest (best at its worst): MC 76, MCH 44, MMo 35.
Best Brood compositions on average: VC 65, S 51, RSy 50, R1S3 50 (the Brood's own share). Safest: R1S3 21, TCS 19, RSB 18.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: MC (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **76**. The Crown's best mix: MC 97%, M 3%. The Brood's: StC 72%, R1S3 28%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **76**. The Crown's best mix: MC 97%, M 3%. The Brood's: StC 72%, R1S3 28%.

## a ramp, the Brood on top, early (600) (338 fights)

Pairings: the Crown clearly ahead in **8**, the Brood in **59**, even in 102 (of 169). Mean score over all pairings: 38.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | CH (100) | MMo (85) | D (0) | CH |
| R3S1 (Raptors, a few Spitters (3:1)) | MB (79) | MO (74) | D (0) | none |
| R1S1 (Raptors and Spitters (1:1)) | MO (85) | M (84) | D (0) | none |
| R1S3 (Spitters, a few Raptors (3:1)) | MMi (83) | MO (77) | D (0) | none |
| S (Spitters) | M (84) | MO (66) | D (0) | none |
| B (Brutes) | MO (88) | M (83) | D (0) | MO |
| RSB (Raptors, Spitters, Brutes) | MO (80) | M (74) | D (0) | MO |
| TC (Tyrant Challengers) | MO (88) | MMi (86) | D (0) | M, MO |
| TCS (Tyrant Challengers + Spitters) | MO (57) | M (51) | D (0) | none |
| VC (Venom Challengers) | CH (100) | MO (48) | D (0) | CH |
| StC (Storm Challengers (flyers)) | M (89) | MO (83) | CH (0) | none |
| RSTd (Raptors, Spitters, Mist Toads) | MO (94) | M (88) | D (0) | M, CH |
| RSy (Raptors and Spitters with the Tyrant Sire) | MO (36) | MH (35) | D (0) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (22) | RSy (23) | StC (89) | VC |
| MC (Musketeers + Field Cannons) | RSy (0) | VC (0) | R (85) | S, B, VC, StC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | VC (11) | StC (22) | R (62) | RSB, StC, RSy |
| MMo (Musketeers + Mortars) | RSy (0) | VC (0) | R (85) | S, TCS, VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | B (0) | StC (0) | R (59) | R3S1, S, B, RSB, TC, TCS, VC, StC |
| MH (Musketeers + Horsemen) | VC (0) | S (21) | TC (63) | S, B, VC, RSy |
| H (Horsemen) | B (0) | R (0) | R3S1 (23) | R, R3S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSy |
| D (Dragoons) | B (0) | R (0) | VC (0) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (0) | StC (12) | R1S1 (52) | TC, TCS, VC, RSy |
| MO (Musketeers + Officers) | RSy (36) | VC (48) | RSTd (94) | none |
| MB (Musketeers + the band) | VC (25) | RSy (33) | RSTd (81) | R1S1, VC, RSy |
| MMi (Musketeers + a Missionary) | VC (0) | RSy (20) | TC (86) | VC |
| CH (Cannons + Horsemen) | StC (0) | R1S3 (2) | VC (100) | R1S3, StC |

Best Crown compositions on average: MO 73, M 67, MB 54, MMi 49. Safest (best at its worst): MO 36, MB 25, M 22.
Best Brood compositions on average: VC 84, RSy 84, TCS 76, StC 67 (the Brood's own share). Safest: RSy 64, TCS 43, R3S1 21.
Brood compositions that out-trade EVERY Crown composition: RSy (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **36**. The Crown's best mix: MO 100%. The Brood's: RSy 100%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **53**. The Crown's best mix: MO 92%, CH 8%. The Brood's: TCS 53%, VC 47%.

## a ramp, the Brood on top, mid (1,500) (507 fights)

Pairings: the Crown clearly ahead in **55**, the Brood in **42**, even in 72 (of 169). Mean score over all pairings: 55.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MO (77) | MMi (75) | D (9) | MO, MMi |
| R3S1 (Raptors, a few Spitters (3:1)) | MO (84) | M (84) | D (20) | M, MMo, MCMo, MH, MO, MMi |
| R1S1 (Raptors and Spitters (1:1)) | MO (71) | M (68) | D (29) | MH |
| R1S3 (Spitters, a few Raptors (3:1)) | MO (80) | M (72) | D (21) | M, MH, H, MO, MB |
| S (Spitters) | MO (73) | M (73) | D (23) | M, MC, MO, MB |
| B (Brutes) | M (95) | MMi (92) | CH (3) | M, MC, MCH, MO, MB, MMi |
| RSB (Raptors, Spitters, Brutes) | MO (84) | M (83) | D (31) | M, MC, MCH, MH, MO |
| TC (Tyrant Challengers) | MB (89) | MO (88) | H (0) | M, MC, MCH, MCMo, MH, MO, MB, MMi |
| TCS (Tyrant Challengers + Spitters) | M (90) | MO (88) | D (26) | M, MCH, MO, MB, MMi |
| VC (Venom Challengers) | H (58) | MCH (38) | D (0) | none |
| StC (Storm Challengers (flyers)) | M (98) | MMo (95) | CH (0) | M, MC, MMo, MCMo, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MO (88) | MCH (84) | D (32) | M, MCH, MD, MO, MB, MMi |
| RSy (Raptors and Spitters with the Tyrant Sire) | H (54) | MH (43) | D (19) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (3) | RSy (30) | StC (98) | VC, RSy |
| MC (Musketeers + Field Cannons) | VC (23) | RSy (27) | StC (95) | R1S1, VC, RSy |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | RSy (36) | VC (38) | RSTd (84) | RSy |
| MMo (Musketeers + Mortars) | VC (0) | RSy (26) | StC (95) | VC, RSy |
| MCMo (Musketeers + Cannons + Mortars) | VC (13) | RSy (25) | StC (95) | VC, RSy |
| MH (Musketeers + Horsemen) | VC (16) | StC (32) | TC (82) | S, VC |
| H (Horsemen) | StC (0) | TC (0) | RSB (71) | R, TC, StC |
| D (Dragoons) | VC (0) | StC (7) | RSTd (32) | R, R3S1, R1S1, R1S3, S, B, TC, TCS, VC, StC, RSTd, RSy |
| MD (Musketeers + Dragoons) | VC (7) | RSy (29) | TCS (78) | B, VC, RSy |
| MO (Musketeers + Officers) | VC (7) | RSy (38) | TCS (88) | VC, RSy |
| MB (Musketeers + the band) | VC (11) | RSy (32) | StC (95) | VC, RSy |
| MMi (Musketeers + a Missionary) | VC (4) | RSy (32) | StC (93) | VC, RSy |
| CH (Cannons + Horsemen) | StC (0) | B (3) | S (63) | R1S1, B, VC, StC, RSTd, RSy |

Best Crown compositions on average: MO 73, M 72, MMi 67, MB 66. Safest (best at its worst): MCH 36, MC 23, MH 16.
Best Brood compositions on average: VC 85, RSy 68, R 50, R1S1 47 (the Brood's own share). Safest: RSy 46, VC 42, R1S1 29.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **42**. The Crown's best mix: H 44%, MCH 30%, MC 22%, MO 5%. The Brood's: RSy 50%, VC 25%, StC 22%, R 3%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **43**. The Crown's best mix: MCH 74%, H 26%. The Brood's: VC 75%, StC 25%.

## a ramp, the Brood on top, late (4,000) (338 fights)

Pairings: the Crown clearly ahead in **47**, the Brood in **16**, even in 106 (of 169). Mean score over all pairings: 57.

| Brood composition | best Crown answer (score) | 2nd | worst Crown choice (score) | Crown compositions that beat it clearly |
|---|---|---|---|---|
| R (Raptors) | MO (68) | CH (66) | D (20) | M, MCH, MO |
| R3S1 (Raptors, a few Spitters (3:1)) | MO (74) | MMi (69) | D (15) | MO, MMi |
| R1S1 (Raptors and Spitters (1:1)) | MO (71) | M (67) | D (30) | MMo, MO |
| R1S3 (Spitters, a few Raptors (3:1)) | MH (62) | M (62) | D (20) | none |
| S (Spitters) | CH (71) | MO (60) | D (13) | none |
| B (Brutes) | MB (100) | MD (99) | H (0) | M, MC, MCH, MMo, MCMo, MH, MD, MO, MB, MMi, CH |
| RSB (Raptors, Spitters, Brutes) | MO (76) | MMi (67) | D (18) | M, MO, MMi |
| TC (Tyrant Challengers) | MMi (92) | MB (92) | D (32) | M, MC, MCMo, MD, MO, MB, MMi |
| TCS (Tyrant Challengers + Spitters) | MO (74) | M (73) | D (31) | M, MC, MH, MD, MB, MMi |
| VC (Venom Challengers) | CH (67) | MCMo (61) | D (0) | none |
| StC (Storm Challengers (flyers)) | MMi (99) | MMo (96) | H (0) | M, MC, MCH, MMo, MCMo, MH, MD, MO, MB, MMi |
| RSTd (Raptors, Spitters, Mist Toads) | MO (76) | M (75) | H (33) | M, MCH, MMi |
| RSy (Raptors and Spitters with the Tyrant Sire) | MO (65) | H (63) | D (26) | none |

| Crown composition | best Brood answer (score) | 2nd | worst Brood choice (score) | Brood compositions that beat it clearly |
|---|---|---|---|---|
| M (Musketeers) | VC (28) | S (52) | B (99) | none |
| MC (Musketeers + Field Cannons) | RSy (44) | R1S1 (49) | B (95) | RSB |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | RSB (42) | S (43) | StC (90) | S |
| MMo (Musketeers + Mortars) | RSy (32) | VC (45) | B (98) | RSy |
| MCMo (Musketeers + Cannons + Mortars) | RSy (35) | RSB (41) | B (89) | RSy |
| MH (Musketeers + Horsemen) | VC (30) | S (38) | B (94) | none |
| H (Horsemen) | B (0) | StC (0) | TC (72) | B, VC, StC |
| D (Dragoons) | VC (0) | S (13) | RSTd (34) | S, B, RSB, VC |
| MD (Musketeers + Dragoons) | VC (32) | RSy (37) | B (99) | R1S3, S, RSy |
| MO (Musketeers + Officers) | VC (11) | R1S3 (57) | B (98) | VC |
| MB (Musketeers + the band) | VC (31) | R1S3 (38) | B (100) | none |
| MMi (Musketeers + a Missionary) | VC (30) | RSy (37) | StC (99) | RSy |
| CH (Cannons + Horsemen) | R1S3 (38) | R1S1 (39) | TC (77) | none |

Best Crown compositions on average: MO 70, M 69, MMi 67, MC 64. Safest (best at its worst): MC 44, MCH 42, CH 38.
Best Brood compositions on average: VC 65, RSy 55, S 54, R1S3 51 (the Brood's own share). Safest: R1S3 38, RSy 35, VC 33.
Brood compositions that out-trade EVERY Crown composition: none (clearly, every one: none). Crown compositions that out-trade every Brood composition: none (clearly: none).

**The game's value at equal cost** (both sides pick their army blind, each at its best mix): the Crown's share **51**. The Crown's best mix: CH 37%, M 33%, MC 24%, MCH 6%. The Brood's: RSy 32%, VC 31%, R1S3 22%, RSB 15%.
Without the Tyrant Sire (RSy left out: he is one unit a game, not an army to buy): the Crown's share **52**. The Crown's best mix: MC 73%, MMi 18%, MCH 8%. The Brood's: VC 38%, RSB 31%, R1S1 31%.

## The fighting (micro) counts

| ground, size | Crown armies with guns | guns set at contact | guns set 10 s after | guns that fired by 20 s | guns lost per gun | riders lost per rider | the Crown's pulls a fight | the Brood's pulls a fight |
|---|---|---|---|---|---|---|---|---|
| open field, -150 | 130 | 0% | 63% | 30% | 0.14 | 0.54 | 0.4 | 4.2 |
| open field, 600 | 260 | 0% | 34% | 38% | 0.84 | 0.91 | 10.5 | 0.7 |
| open field, 1500 | 260 | 0% | 57% | 58% | 0.76 | 0.83 | 3.1 | 1.2 |
| open field, 4000 | 260 | 0% | 61% | 51% | 0.45 | 0.83 | 1.4 | 2.3 |
| the set line (open ground, the Crown formed, guns up), 600 | 195 | 100% | 88% | 27% | 0.74 | 0.92 | 0.0 | 0.6 |
| the set line (open ground, the Crown formed, guns up), 1500 | 195 | 100% | 88% | 49% | 0.51 | 0.89 | 0.0 | 1.0 |
| the set line (open ground, the Crown formed, guns up), 4000 | 195 | 100% | 85% | 46% | 0.17 | 0.87 | 0.0 | 2.1 |
| the set block (open ground, the Crown in a close block, guns up), 600 | 130 | 100% | 87% | 25% | 0.73 | 0.92 | 0.0 | 0.7 |
| the set block (open ground, the Crown in a close block, guns up), 1500 | 130 | 100% | 85% | 46% | 0.48 | 0.89 | 0.0 | 1.1 |
| the set block (open ground, the Crown in a close block, guns up), 4000 | 130 | 100% | 86% | 46% | 0.19 | 0.87 | 0.0 | 2.2 |
| a choke, 600 | 130 | 100% | 89% | 29% | 0.75 | 0.90 | 0.0 | 0.6 |
| a choke, 1500 | 195 | 100% | 87% | 47% | 0.52 | 0.89 | 0.0 | 1.0 |
| a choke, 4000 | 130 | 100% | 81% | 42% | 0.16 | 0.87 | 0.0 | 2.2 |
| a ramp, the Crown on top, 600 | 130 | 100% | 82% | 17% | 0.77 | 0.85 | 0.0 | 0.6 |
| a ramp, the Crown on top, 1500 | 195 | 100% | 85% | 31% | 0.43 | 0.88 | 0.0 | 1.3 |
| a ramp, the Crown on top, 4000 | 130 | 98% | 74% | 8% | 0.12 | 0.85 | 0.0 | 2.0 |
| a ramp, the Brood on top, 600 | 130 | 0% | 32% | 46% | 0.76 | 0.87 | 20.8 | 1.5 |
| a ramp, the Brood on top, 1500 | 195 | 0% | 57% | 75% | 0.43 | 0.75 | 8.0 | 6.0 |
| a ramp, the Brood on top, 4000 | 130 | 0% | 65% | 90% | 0.33 | 0.76 | 2.4 | 6.3 |

## What the guns, riders and the rest add (score against the plain Musketeer line, same Brood army)

| ground, size | MC | MCH | MMo | MCMo | MH | H | D | MD | MO | MB | MMi | CH |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| open, -150 | -4 | +0 | -9 | -5 | +8 | -21 | -37 | -8 | -11 | -4 | -2 | -6 |
| open, 600 | -36 | -14 | -42 | -60 | -27 | -44 | -72 | -43 | +1 | -17 | -20 | -36 |
| open, 1500 | -17 | +1 | -28 | -25 | +17 | -19 | -51 | -23 | -2 | -8 | -7 | -23 |
| open, 4000 | -5 | +5 | -14 | -7 | +14 | -25 | -53 | -14 | +5 | -7 | -3 | +6 |
| set, -150 |  |  |  |  |  |  |  |  |  |  |  |  |
| set, 600 | -6 | -5 | -18 | -20 | -5 | -25 | -41 | -20 | -15 | -18 | -10 | -3 |
| set, 1500 | +17 | +18 | +6 | +0 | -1 | -16 | -25 | -9 | -7 | -1 | -1 | +28 |
| set, 4000 | +33 | +28 | +24 | +25 | -1 | -18 | -21 | -3 | +1 | -2 | -2 | +27 |
| block, -150 |  |  |  |  |  |  |  |  |  |  |  |  |
| block, 600 | -8 | -5 | -15 | -22 | -5 | -23 | -41 | -23 | -15 | -14 | -13 | +0 |
| block, 1500 | +17 | +19 | +2 | +1 | -2 | -17 | -27 | -9 | -7 | -2 | -3 | +26 |
| block, 4000 | +25 | +21 | +9 | +17 | -3 | -25 | -28 | -7 | -8 | -2 | -2 | +21 |
| choke, -150 |  |  |  |  |  |  |  |  |  |  |  |  |
| choke, 600 | -11 | -10 | -22 | -21 | -9 | -25 | -43 | -22 | -16 | -20 | -18 | -4 |
| choke, 1500 | +16 | +16 | +1 | +0 | -1 | -14 | -25 | -10 | -6 | -2 | -2 | +26 |
| choke, 4000 | +34 | +29 | +24 | +26 | +0 | -20 | -22 | -3 | +1 | -3 | -4 | +26 |
| up, -150 |  |  |  |  |  |  |  |  |  |  |  |  |
| up, 600 | -5 | -5 | -23 | -31 | +3 | -21 | -42 | -18 | -14 | -16 | -9 | -3 |
| up, 1500 | +9 | +6 | -8 | -5 | -7 | -37 | -40 | -20 | -21 | -4 | -3 | +13 |
| up, 4000 | +38 | +32 | +26 | +31 | -1 | -22 | -21 | -3 | +3 | -2 | -3 | +29 |
| down, -150 |  |  |  |  |  |  |  |  |  |  |  |  |
| down, 600 | -31 | -27 | -35 | -52 | -29 | -62 | -67 | -38 | +6 | -13 | -19 | -20 |
| down, 1500 | -10 | -9 | -20 | -13 | -15 | -29 | -54 | -18 | +1 | -6 | -5 | -40 |
| down, 4000 | -4 | -8 | -6 | -11 | -7 | -34 | -47 | -9 | +1 | -10 | -2 | -13 |

## The fighting or the numbers: open field (the computer marches) against the set line (formed, guns up)

| size | mean score, open | mean score, set | pairings the Brood wins open but the Crown wins set | the Brood wins both | the Crown wins both |
|---|---|---|---|---|---|
| 600 | 40 | 35 | 5 | 61 | 7 |
| 1500 | 45 | 41 | 5 | 54 | 10 |
| 4000 | 54 | 52 | 9 | 38 | 36 |

- 600: the Brood wins open but the Crown wins set: MC-R3S1, MC-R1S1, MMo-R3S1, CH-S, CH-VC. The Brood wins both: M-VC, M-RSy, MC-TC, MC-TCS, MC-VC, MC-StC, MC-RSy, MCH-B, MMo-S, MMo-B, MMo-RSB, MMo-TC, MMo-VC, MMo-StC, MMo-RSy, MCMo-B, MCMo-RSB, MCMo-TC, MCMo-TCS, MCMo-VC, MCMo-StC, MCMo-RSy, MH-VC, MH-RSy, H-R, H-R3S1, H-S, H-B, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-StC, D-RSTd, D-RSy, MD-R, MD-R1S3, MD-S, MD-B, MD-RSB, MD-TCS, MD-VC, MD-RSy, MO-RSy, MB-VC, MB-RSy, MMi-S, MMi-VC, MMi-RSy, CH-B, CH-StC, CH-RSy.
- 1500: the Brood wins open but the Crown wins set: MMo-R, MMo-R3S1, CH-R1S3, CH-RSB, CH-TCS. The Brood wins both: M-R, M-S, M-VC, M-RSy, MC-RSy, MMo-B, MMo-RSB, MMo-VC, MMo-RSy, MCMo-S, MCMo-VC, MCMo-RSy, MH-RSy, H-R, H-R3S1, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-StC, D-RSTd, D-RSy, MD-R, MD-R3S1, MD-R1S1, MD-S, MD-RSB, MD-TC, MD-TCS, MD-VC, MD-RSy, MO-R, MO-S, MO-VC, MO-RSy, MB-R, MB-S, MB-VC, MB-RSy, MMi-R, MMi-R1S3, MMi-S, MMi-VC, MMi-RSy, CH-StC.
- 4000: the Brood wins open but the Crown wins set: MC-RSy, MCH-RSy, MMo-R, MMo-R1S1, MMo-RSB, MMo-RSy, MCMo-RSB, MCMo-VC, MCMo-RSy. The Brood wins both: M-S, M-VC, M-RSy, MMo-VC, H-R, H-R3S1, H-R1S3, H-S, H-TCS, H-VC, H-StC, H-RSy, D-R, D-R3S1, D-R1S3, D-S, D-B, D-RSB, D-TC, D-TCS, D-VC, D-RSTd, D-RSy, MD-R, MD-R1S3, MD-S, MD-RSB, MD-VC, MD-RSy, MO-VC, MB-R, MB-S, MB-VC, MB-RSy, MMi-S, MMi-VC, MMi-RSy, CH-StC.

| Crown composition | open -150 | set -150 | block -150 | open 600 | set 600 | block 600 | open 1500 | set 1500 | block 1500 | open 4000 | set 4000 | block 4000 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M | 71 |  |  | 72 | 49 | 49 | 59 | 41 | 42 | 61 | 45 | 52 |
| MC | 68 |  |  | 36 | 43 | 42 | 42 | 57 | 59 | 56 | 78 | 76 |
| MCH | 72 |  |  | 58 | 44 | 44 | 61 | 58 | 61 | 67 | 73 | 72 |
| MMo | 63 |  |  | 30 | 31 | 34 | 31 | 46 | 45 | 47 | 69 | 60 |
| MCMo | 66 |  |  | 12 | 30 | 27 | 34 | 41 | 43 | 54 | 71 | 69 |
| MH | 79 |  |  | 45 | 44 | 45 | 76 | 40 | 41 | 76 | 45 | 48 |
| H | 50 |  |  | 28 | 24 | 26 | 40 | 25 | 26 | 36 | 27 | 26 |
| D | 35 |  |  | 0 | 8 | 9 | 8 | 15 | 15 | 8 | 24 | 24 |
| MD | 64 |  |  | 29 | 29 | 27 | 36 | 32 | 33 | 47 | 42 | 45 |
| MO | 60 |  |  | 73 | 34 | 35 | 57 | 34 | 36 | 66 | 46 | 44 |
| MB | 68 |  |  | 55 | 31 | 35 | 51 | 39 | 40 | 54 | 43 | 49 |
| MMi | 69 |  |  | 51 | 40 | 36 | 52 | 40 | 40 | 58 | 43 | 50 |
| CH | 66 |  |  | 35 | 46 | 49 | 36 | 69 | 68 | 67 | 72 | 72 |
