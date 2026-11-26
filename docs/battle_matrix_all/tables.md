# The battle matrix, all matchups: the tables

6572 fights (tools/study/battle_matrix_all_report.py). Side A is the first faction named. The score is side A's share of the value lost in a fight (50 = an even trade).


## Brood v Brood


### Brood v Brood: open field, early (600) (676 results)

Each cell: the **row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| row \ column | R | R3S1 | R1S1 | R1S3 | S | B | RSB | TC | TCS | VC | StC | RSTd | RSy | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **R** | 50 (4) | **75 (4)** | **76 (4)** | **71 (4)** | 62 (4) | 49 (4) | **76 (4)** | **79 (4)** | **74 (4)** | *0 (4)* | *0 (4)* | **79 (4)** | *20 (4)* | 55 |
| **R3S1** | *25 (4)* | 50 (4) | **62 (4)** | **66 (4)** | 54 (4) | **65 (4)** | 60 (4) | **73 (4)** | 50 (4) | *10 (4)* | *0 (4)* | **70 (4)** | *20 (4)* | 47 |
| **R1S1** | *24 (4)* | *38 (4)* | 50 (4) | **59 (4)** | 39 (4) | 42 (4) | 49 (4) | **61 (4)** | 46 (4) | *0 (4)* | *0 (4)* | **67 (4)** | *20 (4)* | 38 |
| **R1S3** | *29 (4)* | *34 (4)* | *41 (4)* | 50 (4) | *33 (4)* | 32 (4) | 52 (4) | 41 (4) | *41 (4)* | *5 (4)* | *0 (4)* | **73 (4)** | *26 (4)* | 35 |
| **S** | 38 (4) | 46 (4) | 61 (4) | **67 (4)** | 50 (4) | 39 (4) | **75 (4)** | **69 (4)** | **66 (4)** | *14 (4)* | *0 (4)* | **80 (4)** | *26 (4)* | 49 |
| **B** | 51 (4) | *35 (4)* | 58 (4) | 68 (4) | 61 (4) | 50 (4) | **75 (4)** | 63 (4) | **70 (4)** | **73 (4)** | *0 (4)* | **84 (4)** | *25 (4)* | 55 |
| **RSB** | *24 (4)* | 40 (4) | 51 (4) | 48 (4) | *25 (4)* | *25 (4)* | 50 (4) | **62 (4)** | 41 (4) | *10 (4)* | *0 (4)* | **73 (4)** | *20 (4)* | 36 |
| **TC** | *21 (4)* | *27 (4)* | *39 (4)* | 59 (4) | *31 (4)* | 37 (4) | *38 (4)* | 50 (4) | 48 (4) | 33 (4) | *0 (4)* | **78 (4)** | *24 (4)* | 37 |
| **TCS** | *26 (4)* | 50 (4) | 54 (4) | **59 (4)** | *34 (4)* | *30 (4)* | 59 (4) | 52 (4) | 50 (4) | *15 (4)* | *0 (4)* | **71 (4)** | *20 (4)* | 40 |
| **VC** | **100 (4)** | **90 (4)** | **100 (4)** | **95 (4)** | **86 (4)** | *27 (4)* | **90 (4)** | 67 (4) | **85 (4)** | 50 (4) | **84 (4)** | **100 (4)** | *25 (4)* | 77 |
| **StC** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | *16 (4)* | 50 (4) | **100 (4)** | **100 (4)** | 90 |
| **RSTd** | *21 (4)* | *30 (4)* | *33 (4)* | *27 (4)* | *20 (4)* | *16 (4)* | *27 (4)* | *22 (4)* | *29 (4)* | *0 (4)* | *0 (4)* | 50 (4) | *20 (4)* | 23 |
| **RSy** | **80 (4)** | **80 (4)** | **80 (4)** | **75 (4)** | **74 (4)** | **75 (4)** | **80 (4)** | **76 (4)** | **80 (4)** | **75 (4)** | *0 (4)* | **80 (4)** | 50 (4) | 70 |

| comp | its best counter (its share) | it beats clearly |
|---|---|---|
| R (Raptors) | VC (100) | R3S1, R1S1, R1S3, RSB, TC, TCS, RSTd |
| R3S1 (Raptors, a few Spitters (3:1)) | StC (100) | R1S1, R1S3, B, TC, RSTd |
| R1S1 (Raptors and Spitters (1:1)) | VC (100) | R1S3, TC, RSTd |
| R1S3 (Spitters, a few Raptors (3:1)) | StC (100) | RSTd |
| S (Spitters) | StC (100) | R1S3, RSB, TC, TCS, RSTd |
| B (Brutes) | StC (100) | RSB, TCS, VC, RSTd |
| RSB (Raptors, Spitters, Brutes) | StC (100) | TC, RSTd |
| TC (Tyrant Challengers) | StC (100) | RSTd |
| TCS (Tyrant Challengers + Spitters) | StC (100) | R1S3, RSTd |
| VC (Venom Challengers) | RSy (75) | R, R3S1, R1S1, R1S3, S, RSB, TCS, StC, RSTd |
| StC (Storm Challengers (flyers)) | VC (84) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, RSTd, RSy |
| RSTd (Raptors, Spitters, Mist Toads) | VC (100) | none |
| RSy (Raptors and Spitters with the Tyrant Sire) | StC (100) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, RSTd |

Best on average: Brood StC 90, VC 77, RSy 70, B 55

Safest (best at its worst): VC 25, StC 16, R 0.

**The best blind mix** (each side picks blind, each at its best mix): VC 46%, RSy 31%, StC 23%.
Without the Tyrant Sire (RSy left out): Brood's share **53**.

### Brood v Brood: open field, mid (1,500) (676 results)

Each cell: the **row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| row \ column | R | R3S1 | R1S1 | R1S3 | S | B | RSB | TC | TCS | VC | StC | RSTd | RSy | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **R** | 50 (4) | **77 (4)** | **81 (4)** | **74 (4)** | **72 (4)** | **64 (4)** | **73 (4)** | **81 (4)** | **76 (4)** | *5 (4)* | *0 (4)* | **82 (4)** | *34 (4)* | 59 |
| **R3S1** | *23 (4)* | 50 (4) | **71 (4)** | **66 (4)** | 47 (4) | 45 (4) | **66 (4)** | **71 (4)** | **65 (4)** | *5 (4)* | *0 (4)* | **78 (4)** | *31 (4)* | 48 |
| **R1S1** | *19 (4)* | *29 (4)* | 50 (4) | *41 (4)* | *28 (4)* | *36 (4)* | 54 (4) | 51 (4) | 44 (4) | *3 (4)* | *0 (4)* | **62 (4)** | *32 (4)* | 34 |
| **R1S3** | *26 (4)* | *34 (4)* | **59 (4)** | 50 (4) | *24 (4)* | *40 (4)* | **60 (4)** | *38 (4)* | 57 (4) | *5 (4)* | *0 (4)* | **70 (4)** | *31 (4)* | 38 |
| **S** | *28 (4)* | 53 (4) | **72 (4)** | **76 (4)** | 50 (4) | **61 (4)** | **75 (4)** | **72 (4)** | **74 (4)** | *12 (4)* | *0 (4)* | **87 (4)** | *40 (4)* | 54 |
| **B** | *36 (4)* | 55 (4) | **64 (4)** | **60 (4)** | *39 (4)* | 50 (4) | **72 (4)** | 63 (4) | 56 (4) | 53 (4) | *0 (4)* | **72 (4)** | *32 (4)* | 50 |
| **RSB** | *27 (4)* | *34 (4)* | 46 (4) | *40 (4)* | *25 (4)* | *28 (4)* | 50 (4) | 44 (4) | *40 (4)* | *8 (4)* | *0 (4)* | **68 (4)** | *32 (4)* | 34 |
| **TC** | *19 (4)* | *29 (4)* | 49 (4) | **62 (4)** | *28 (4)* | 37 (4) | 56 (4) | 50 (4) | 44 (4) | *20 (4)* | *0 (4)* | **80 (4)** | *30 (4)* | 39 |
| **TCS** | *24 (4)* | *35 (4)* | 56 (4) | 43 (4) | *26 (4)* | 44 (4) | **60 (4)** | 56 (4) | 50 (4) | *8 (4)* | *0 (4)* | **73 (4)** | *32 (4)* | 39 |
| **VC** | **95 (4)** | **95 (4)** | **97 (4)** | **95 (4)** | **88 (4)** | 47 (4) | **92 (4)** | **80 (4)** | **92 (4)** | 50 (4) | **90 (4)** | **100 (4)** | *35 (4)* | 81 |
| **StC** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | *10 (4)* | 50 (4) | **100 (4)** | **100 (4)** | 89 |
| **RSTd** | *18 (4)* | *22 (4)* | *38 (4)* | *30 (4)* | *13 (4)* | *28 (4)* | *32 (4)* | *20 (4)* | *27 (4)* | *0 (4)* | *0 (4)* | 50 (4) | *29 (4)* | 24 |
| **RSy** | **66 (4)** | **69 (4)** | **68 (4)** | **69 (4)** | **60 (4)** | **68 (4)** | **68 (4)** | **70 (4)** | **68 (4)** | **65 (4)** | *0 (4)* | **71 (4)** | 50 (4) | 61 |

| comp | its best counter (its share) | it beats clearly |
|---|---|---|
| R (Raptors) | StC (100) | R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, RSTd |
| R3S1 (Raptors, a few Spitters (3:1)) | StC (100) | R1S1, R1S3, RSB, TC, TCS, RSTd |
| R1S1 (Raptors and Spitters (1:1)) | StC (100) | RSTd |
| R1S3 (Spitters, a few Raptors (3:1)) | StC (100) | R1S1, RSB, RSTd |
| S (Spitters) | StC (100) | R1S1, R1S3, B, RSB, TC, TCS, RSTd |
| B (Brutes) | StC (100) | R1S1, R1S3, RSB, RSTd |
| RSB (Raptors, Spitters, Brutes) | StC (100) | RSTd |
| TC (Tyrant Challengers) | StC (100) | R1S3, RSTd |
| TCS (Tyrant Challengers + Spitters) | StC (100) | RSB, RSTd |
| VC (Venom Challengers) | RSy (65) | R, R3S1, R1S1, R1S3, S, RSB, TC, TCS, StC, RSTd |
| StC (Storm Challengers (flyers)) | VC (90) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, RSTd, RSy |
| RSTd (Raptors, Spitters, Mist Toads) | VC (100) | none |
| RSy (Raptors and Spitters with the Tyrant Sire) | StC (100) | R, R3S1, R1S1, R1S3, S, B, RSB, TC, TCS, VC, RSTd |

Best on average: Brood StC 89, VC 81, RSy 61, R 59

Safest (best at its worst): VC 35, StC 10, R 0.

**The best blind mix** (each side picks blind, each at its best mix): VC 48%, RSy 38%, StC 14%.
Without the Tyrant Sire (RSy left out): Brood's share **55**.

## Clockwork v Brood


### Clockwork v Brood: open field, early (600) (728 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Brood | R | R3S1 | R1S1 | R1S3 | S | B | RSB | TC | TCS | VC | StC | RSTd | RSy | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **K** | *15 (4)* | *22 (4)* | *30 (4)* | *32 (4)* | *18 (4)* | *21 (4)* | *30 (4)* | *28 (4)* | *31 (4)* | *0 (4)* | *0 (4)* | **66 (4)** | *24 (4)* | 24 |
| **KW** | *13 (4)* | *22 (4)* | *22 (4)* | *26 (4)* | *14 (4)* | *0 (4)* | *23 (4)* | *9 (4)* | *17 (4)* | *0 (4)* | *0 (4)* | *39 (4)* | *23 (4)* | 16 |
| **KN** | *4 (4)* | *9 (4)* | *9 (4)* | *14 (4)* | *6 (4)* | *0 (4)* | *16 (4)* | *17 (4)* | *0 (4)* | *0 (4)* | *0 (4)* | *25 (4)* | *15 (4)* | 9 |
| **KP** | **68 (4)** | **68 (4)** | **69 (4)** | *30 (4)* | *15 (4)* | *0 (4)* | *20 (4)* | 34 (4) | *22 (4)* | *0 (4)* | 48 (4) | 48 (4) | *26 (4)* | 35 |
| **P** | **100 (4)** | **100 (4)** | **100 (4)** | 72 (4) | *35 (4)* | *0 (4)* | *21 (4)* | **100 (4)** | 48 (4) | *6 (4)* | **100 (4)** | **100 (4)** | *21 (4)* | 62 |
| **Sp** | *11 (4)* | *13 (4)* | *15 (4)* | *24 (4)* | *11 (4)* | *0 (4)* | *22 (4)* | *13 (4)* | *0 (4)* | *0 (4)* | *30 (4)* | *26 (4)* | *14 (4)* | 14 |
| **KSp** | *9 (4)* | *18 (4)* | *19 (4)* | *26 (4)* | *15 (4)* | *0 (4)* | *22 (4)* | *23 (4)* | *23 (4)* | *6 (4)* | *25 (4)* | *37 (4)* | *22 (4)* | 19 |
| **KB** | *21 (4)* | *25 (4)* | *22 (4)* | *30 (4)* | *18 (4)* | *0 (4)* | 35 (4) | *19 (4)* | *9 (4)* | *0 (4)* | *0 (4)* | 64 (4) | *22 (4)* | 20 |
| **Se** | *2 (4)* | *6 (4)* | *8 (4)* | *16 (4)* | *8 (4)* | *0 (4)* | *19 (4)* | *0 (4)* | *4 (4)* | *0 (4)* | *0 (4)* | *18 (4)* | *12 (4)* | 7 |
| **KSe** | *4 (4)* | *4 (4)* | *9 (4)* | *14 (4)* | *0 (4)* | *0 (4)* | *14 (4)* | *0 (4)* | *0 (4)* | *0 (4)* | *0 (4)* | *10 (4)* | *12 (4)* | 5 |
| **O** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | *0 (4)* | *0 (4)* | **100 (4)** | **100 (4)** | 85 |
| **CW** | 51 (4) | 48 (4) | *35 (4)* | *17 (4)* | *3 (4)* | *0 (4)* | *32 (4)* | *14 (4)* | *8 (4)* | *0 (4)* | 46 (4) | *37 (4)* | *29 (4)* | 25 |
| **KGW** | *7 (4)* | *14 (4)* | *16 (4)* | *22 (4)* | *9 (4)* | *0 (4)* | *21 (4)* | *12 (4)* | *0 (4)* | *0 (4)* | *0 (4)* | *29 (4)* | *22 (4)* | 12 |
| **KPN** | **77 (4)** | 39 (4) | *35 (4)* | *22 (4)* | *0 (4)* | *0 (4)* | *18 (4)* | *14 (4)* | *14 (4)* | *0 (4)* | 39 (4) | 36 (4) | *31 (4)* | 25 |

| Clockwork comp | Brood's best answer (Clockwork share) | Brood comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| K (Clock Soldiers, no Winders) | VC (0) | R (Raptors) | P (100) |
| KW (Clock Soldiers + Winders) | B (0) | R3S1 (Raptors, a few Spitters (3:1)) | P (100) |
| KN (Clock Soldiers + Netters) | B (0) | R1S1 (Raptors and Spitters (1:1)) | P (100) |
| KP (Clock Soldiers + Pendulums) | B (0) | R1S3 (Spitters, a few Raptors (3:1)) | O (100) |
| P (Pendulums) | B (0) | S (Spitters) | O (100) |
| Sp (Springers) | B (0) | B (Brutes) | O (100) |
| KSp (Clock Soldiers + Springers) | B (0) | RSB (Raptors, Spitters, Brutes) | O (100) |
| KB (Clock Soldiers + Spring Ballistas) | B (0) | TC (Tyrant Challengers) | P (100) |
| Se (Brass Serpents) | B (0) | TCS (Tyrant Challengers + Spitters) | O (100) |
| KSe (Clock Soldiers + Brass Serpents) | S (0) | VC (Venom Challengers) | P (6) |
| O (the air: Ticking Owls + Swifts) | VC (0) | StC (Storm Challengers (flyers)) | P (100) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | B (0) | RSTd (Raptors, Spitters, Mist Toads) | P (100) |
| KGW (Clock Soldiers + the Great Winder (no Winders)) | B (0) | RSy (Raptors and Spitters with the Tyrant Sire) | O (100) |
| KPN (Clock Soldiers + Pendulums + Netters) | S (0) |  |  |

Best on average: Clockwork O 85, P 62, KP 35, KPN 25
; Brood VC 99, B 91, S 82, TCS 80 (its own share).

Safest (best at its worst): Clockwork K 0, KW 0, KN 0; Brood VC 94, R 0, R3S1 0.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **6**. Clockwork's mix: P 94%, O 6%. Brood's: VC 94%, B 6%.
Without the Tyrant Sire (RSy left out): Clockwork's share **6**.

### Clockwork v Brood: open field, mid (1,500) (728 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Brood | R | R3S1 | R1S1 | R1S3 | S | B | RSB | TC | TCS | VC | StC | RSTd | RSy | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **K** | *16 (4)* | *25 (4)* | *44 (4)* | **59 (4)** | *41 (4)* | *24 (4)* | 53 (4) | *37 (4)* | *40 (4)* | *12 (4)* | *0 (4)* | **68 (4)** | *31 (4)* | 35 |
| **KW** | *12 (4)* | *16 (4)* | *33 (4)* | *41 (4)* | *24 (4)* | *23 (4)* | *37 (4)* | *20 (4)* | *32 (4)* | *11 (4)* | *0 (4)* | 51 (4) | *32 (4)* | 26 |
| **KN** | *4 (4)* | *9 (4)* | *15 (4)* | *24 (4)* | *14 (4)* | *12 (4)* | *25 (4)* | *13 (4)* | *14 (4)* | *3 (4)* | 27 (4) | *22 (4)* | *17 (4)* | 15 |
| **KP** | **67 (4)** | 57 (4) | *43 (4)* | 50 (4) | 40 (4) | *11 (4)* | *32 (4)* | 46 (4) | *34 (4)* | *15 (4)* | *28 (4)* | 50 (4) | *34 (4)* | 39 |
| **P** | **100 (4)** | **88 (4)** | **83 (4)** | **75 (4)** | *37 (4)* | *10 (4)* | *40 (4)* | **79 (4)** | 45 (4) | *19 (4)* | **78 (4)** | **88 (4)** | *34 (4)* | 60 |
| **Sp** | *4 (4)* | *8 (4)* | *12 (4)* | *23 (4)* | *7 (4)* | *9 (4)* | *28 (4)* | *8 (4)* | *13 (4)* | *0 (4)* | *24 (4)* | *20 (4)* | *11 (4)* | 13 |
| **KSp** | *8 (4)* | *14 (4)* | *23 (4)* | *35 (4)* | *20 (4)* | *13 (4)* | *34 (4)* | *16 (4)* | *32 (4)* | *9 (4)* | *17 (4)* | *36 (4)* | *31 (4)* | 22 |
| **KB** | *10 (4)* | *25 (4)* | 46 (4) | 65 (4) | 57 (4) | *22 (4)* | 67 (4) | *30 (4)* | 53 (4) | 48 (4) | *0 (4)* | **71 (4)** | 47 (4) | 42 |
| **Se** | *1 (4)* | *3 (4)* | *8 (4)* | *21 (4)* | *5 (4)* | *0 (4)* | *15 (4)* | *0 (4)* | *17 (4)* | *0 (4)* | *0 (4)* | *15 (4)* | *7 (4)* | 7 |
| **KSe** | *2 (4)* | *3 (4)* | *4 (4)* | *21 (4)* | *7 (4)* | *6 (4)* | *15 (4)* | *8 (4)* | *10 (4)* | *0 (4)* | *0 (4)* | *11 (4)* | *9 (4)* | 7 |
| **O** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | *0 (4)* | *0 (4)* | **100 (4)** | **100 (4)** | 85 |
| **CW** | *30 (4)* | *47 (4)* | *37 (4)* | 49 (4) | *18 (4)* | *11 (4)* | *36 (4)* | *30 (4)* | *29 (4)* | *6 (4)* | *39 (4)* | 63 (4) | *34 (4)* | 33 |
| **KGW** | *8 (4)* | *11 (4)* | *24 (4)* | *34 (4)* | *16 (4)* | *15 (4)* | *33 (4)* | *14 (4)* | *27 (4)* | *0 (4)* | *0 (4)* | *36 (4)* | *25 (4)* | 19 |
| **KPN** | **60 (4)** | *46 (4)* | *34 (4)* | *27 (4)* | *17 (4)* | *12 (4)* | *25 (4)* | *31 (4)* | *23 (4)* | *0 (4)* | 60 (4) | *37 (4)* | *33 (4)* | 31 |

| Clockwork comp | Brood's best answer (Clockwork share) | Brood comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| K (Clock Soldiers, no Winders) | StC (0) | R (Raptors) | P (100) |
| KW (Clock Soldiers + Winders) | StC (0) | R3S1 (Raptors, a few Spitters (3:1)) | O (100) |
| KN (Clock Soldiers + Netters) | VC (3) | R1S1 (Raptors and Spitters (1:1)) | O (100) |
| KP (Clock Soldiers + Pendulums) | B (11) | R1S3 (Spitters, a few Raptors (3:1)) | O (100) |
| P (Pendulums) | B (10) | S (Spitters) | O (100) |
| Sp (Springers) | VC (0) | B (Brutes) | O (100) |
| KSp (Clock Soldiers + Springers) | R (8) | RSB (Raptors, Spitters, Brutes) | O (100) |
| KB (Clock Soldiers + Spring Ballistas) | StC (0) | TC (Tyrant Challengers) | O (100) |
| Se (Brass Serpents) | B (0) | TCS (Tyrant Challengers + Spitters) | O (100) |
| KSe (Clock Soldiers + Brass Serpents) | VC (0) | VC (Venom Challengers) | KB (48) |
| O (the air: Ticking Owls + Swifts) | VC (0) | StC (Storm Challengers (flyers)) | P (78) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | VC (6) | RSTd (Raptors, Spitters, Mist Toads) | O (100) |
| KGW (Clock Soldiers + the Great Winder (no Winders)) | VC (0) | RSy (Raptors and Spitters with the Tyrant Sire) | O (100) |
| KPN (Clock Soldiers + Pendulums + Netters) | VC (0) |  |  |

Best on average: Clockwork O 85, P 60, KB 42, KP 39
; Brood VC 91, B 81, StC 80, S 71 (its own share).

Safest (best at its worst): Clockwork KP 11, P 10, KSp 8; Brood VC 52, StC 22, R 0.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **30**. Clockwork's mix: KB 46%, P 38%, O 16%. Brood's: VC 48%, B 30%, StC 22%.
Without the Tyrant Sire (RSy left out): Clockwork's share **30**.

### Clockwork v Brood: open field, late (4,000) (84 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Brood | R1S1 | S | B | RSB | TC | VC | StC | mean |
|---|---|---|---|---|---|---|---|---|
| **KP** | 49 (2) | 39 (2) | *11 (2)* | 42 (2) | 53 (2) | *4 (2)* | 36 (2) | 33 |
| **P** | 77 (2) | 33 (2) | *13 (2)* | *37 (2)* | **81 (2)** | 9 (2) | **78 (2)** | 47 |
| **KB** | 41 (2) | 69 (2) | 52 (2) | 51 (2) | 32 (2) | *39 (2)* | *0 (2)* | 41 |
| **O** | **100 (2)** | **100 (2)** | **100 (2)** | **100 (2)** | **100 (2)** | *6 (2)* | *0 (2)* | 72 |
| **CW** | **70 (2)** | *29 (2)* | 17 (2) | *42 (2)* | 26 (2) | *2 (2)* | 13 (2) | 29 |
| **KPN** | 44 (2) | *23 (2)* | *6 (2)* | *32 (2)* | 36 (2) | *4 (2)* | 63 (2) | 30 |

| Clockwork comp | Brood's best answer (Clockwork share) | Brood comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| KP (Clock Soldiers + Pendulums) | VC (4) | R1S1 (Raptors and Spitters (1:1)) | O (100) |
| P (Pendulums) | VC (9) | S (Spitters) | O (100) |
| KB (Clock Soldiers + Spring Ballistas) | StC (0) | B (Brutes) | O (100) |
| O (the air: Ticking Owls + Swifts) | StC (0) | RSB (Raptors, Spitters, Brutes) | O (100) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | VC (2) | TC (Tyrant Challengers) | O (100) |
| KPN (Clock Soldiers + Pendulums + Netters) | VC (4) | VC (Venom Challengers) | KB (39) |
|  |  | StC (Storm Challengers (flyers)) | P (78) |

Best on average: Clockwork O 72, P 47, KB 41, KP 33
; Brood VC 89, StC 68, B 67, S 51 (its own share).

Safest (best at its worst): Clockwork P 9, KPN 4, KP 4; Brood VC 61, StC 22, R1S1 0.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **28**. Clockwork's mix: KB 64%, P 36%. Brood's: VC 72%, StC 28%.

### Clockwork v Brood: the set line (side A formed by hand, ready), mid (1,500) (168 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Brood | R1S1 | S | B | RSB | TC | VC | StC | mean |
|---|---|---|---|---|---|---|---|---|
| **KP** | **68 (4)** | *20 (4)* | *14 (4)* | *36 (4)* | 51 (4) | *10 (4)* | *11 (4)* | 30 |
| **P** | **79 (4)** | *37 (4)* | *12 (4)* | *38 (4)* | **79 (4)** | *25 (4)* | **88 (4)** | 51 |
| **KB** | **61 (4)** | 56 (4) | *10 (4)* | **63 (4)** | *22 (4)* | 55 (4) | *0 (4)* | 38 |
| **O** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | *5 (4)* | *0 (4)* | 72 |
| **CW** | *39 (4)* | *9 (4)* | *11 (4)* | *29 (4)* | *15 (4)* | *5 (4)* | *19 (4)* | 18 |
| **KPN** | *34 (4)* | *4 (4)* | *11 (4)* | *27 (4)* | *12 (4)* | *10 (4)* | 28 (4) | 18 |

| Clockwork comp | Brood's best answer (Clockwork share) | Brood comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| KP (Clock Soldiers + Pendulums) | VC (10) | R1S1 (Raptors and Spitters (1:1)) | O (100) |
| P (Pendulums) | B (12) | S (Spitters) | O (100) |
| KB (Clock Soldiers + Spring Ballistas) | StC (0) | B (Brutes) | O (100) |
| O (the air: Ticking Owls + Swifts) | StC (0) | RSB (Raptors, Spitters, Brutes) | O (100) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | VC (5) | TC (Tyrant Challengers) | O (100) |
| KPN (Clock Soldiers + Pendulums + Netters) | S (4) | VC (Venom Challengers) | KB (55) |
|  |  | StC (Storm Challengers (flyers)) | P (88) |

Best on average: Clockwork O 72, P 51, KB 38, KP 30
; Brood VC 82, StC 76, B 74, S 62 (its own share).

Safest (best at its worst): Clockwork P 12, KP 10, CW 5; Brood VC 45, StC 12, R1S1 0.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **32**. Clockwork's mix: KB 40%, P 37%, O 24%. Brood's: VC 53%, B 30%, StC 18%.

### Clockwork v Brood: a choke (side A holds the gap), mid (1,500) (168 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Brood | R1S1 | S | B | RSB | TC | VC | StC | mean |
|---|---|---|---|---|---|---|---|---|
| **KP** | **71 (4)** | *22 (4)* | *13 (4)* | *35 (4)* | *45 (4)* | *12 (4)* | *14 (4)* | 30 |
| **P** | **92 (4)** | *33 (4)* | *10 (4)* | *36 (4)* | **85 (4)** | *22 (4)* | **81 (4)** | 51 |
| **KB** | **63 (4)** | 39 (4) | *15 (4)* | **63 (4)** | *25 (4)* | **63 (4)** | *0 (4)* | 38 |
| **O** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | *5 (4)* | *0 (4)* | 72 |
| **CW** | *41 (4)* | *6 (4)* | *10 (4)* | *28 (4)* | *15 (4)* | *5 (4)* | *11 (4)* | 16 |
| **KPN** | *37 (4)* | *5 (4)* | *11 (4)* | *27 (4)* | *14 (4)* | *8 (4)* | 26 (4) | 18 |

| Clockwork comp | Brood's best answer (Clockwork share) | Brood comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| KP (Clock Soldiers + Pendulums) | VC (12) | R1S1 (Raptors and Spitters (1:1)) | O (100) |
| P (Pendulums) | B (10) | S (Spitters) | O (100) |
| KB (Clock Soldiers + Spring Ballistas) | StC (0) | B (Brutes) | O (100) |
| O (the air: Ticking Owls + Swifts) | StC (0) | RSB (Raptors, Spitters, Brutes) | O (100) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | VC (5) | TC (Tyrant Challengers) | O (100) |
| KPN (Clock Soldiers + Pendulums + Netters) | S (5) | VC (Venom Challengers) | KB (63) |
|  |  | StC (Storm Challengers (flyers)) | P (81) |

Best on average: Clockwork O 72, P 51, KB 38, KP 30
; Brood VC 81, StC 78, B 74, S 66 (its own share).

Safest (best at its worst): Clockwork KP 12, P 10, KPN 5; Brood VC 37, StC 19, R1S1 0.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **33**. Clockwork's mix: P 41%, KB 36%, O 23%. Brood's: VC 45%, B 31%, StC 24%.

### Clockwork v Brood: a ramp, side A on top, mid (1,500) (168 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Brood | R1S1 | S | B | RSB | TC | VC | StC | mean |
|---|---|---|---|---|---|---|---|---|
| **KP** | 58 (4) | *22 (4)* | *18 (4)* | *42 (4)* | 53 (4) | *21 (4)* | *11 (4)* | 32 |
| **P** | **88 (4)** | 55 (4) | *12 (4)* | *39 (4)* | **72 (4)** | *26 (4)* | **92 (4)** | 55 |
| **KB** | **76 (4)** | **69 (4)** | *14 (4)* | **80 (4)** | 40 (4) | 52 (4) | *0 (4)* | 47 |
| **O** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | *10 (4)* | *13 (4)* | 75 |
| **CW** | *37 (4)* | *19 (4)* | *10 (4)* | *34 (4)* | *18 (4)* | *18 (4)* | *24 (4)* | 23 |
| **KPN** | *27 (4)* | *11 (4)* | *11 (4)* | *25 (4)* | *12 (4)* | *8 (4)* | *26 (4)* | 17 |

| Clockwork comp | Brood's best answer (Clockwork share) | Brood comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| KP (Clock Soldiers + Pendulums) | StC (11) | R1S1 (Raptors and Spitters (1:1)) | O (100) |
| P (Pendulums) | B (12) | S (Spitters) | O (100) |
| KB (Clock Soldiers + Spring Ballistas) | StC (0) | B (Brutes) | O (100) |
| O (the air: Ticking Owls + Swifts) | VC (10) | RSB (Raptors, Spitters, Brutes) | O (100) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | B (10) | TC (Tyrant Challengers) | O (100) |
| KPN (Clock Soldiers + Pendulums + Netters) | VC (8) | VC (Venom Challengers) | KB (52) |
|  |  | StC (Storm Challengers (flyers)) | P (92) |

Best on average: Clockwork O 75, P 55, KB 47, KP 32
; Brood VC 78, B 72, StC 72, S 54 (its own share).

Safest (best at its worst): Clockwork P 12, KP 11, O 10; Brood VC 48, StC 8, R1S1 0.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **34**. Clockwork's mix: KB 43%, P 33%, O 23%. Brood's: VC 57%, B 25%, StC 17%.

## Clockwork v Clockwork


### Clockwork v Clockwork: open field, early (600) (784 results)

Each cell: the **row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| row \ column | K | KW | KN | KP | P | Sp | KSp | KB | Se | KSe | O | CW | KGW | KPN | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **K** | 50 (4) | **74 (4)** | **77 (4)** | *33 (4)* | *0 (4)* | **80 (4)** | **72 (4)** | **86 (4)** | **87 (4)** | **87 (4)** | *0 (4)* | *25 (4)* | **83 (4)** | *30 (4)* | 56 |
| **KW** | *26 (4)* | 50 (4) | **74 (4)** | *31 (4)* | *0 (4)* | **72 (4)** | 62 (4) | **82 (4)** | **76 (4)** | **87 (4)** | *0 (4)* | *26 (4)* | **74 (4)** | *24 (4)* | 49 |
| **KN** | *23 (4)* | *26 (4)* | 50 (4) | *27 (4)* | *0 (4)* | 51 (4) | *24 (4)* | 61 (4) | 34 (4) | **81 (4)** | 59 (4) | *20 (4)* | **80 (4)** | *21 (4)* | 40 |
| **KP** | **67 (4)** | **68 (4)** | **73 (4)** | 50 (4) | *0 (4)* | **69 (4)** | **68 (4)** | **83 (4)** | **71 (4)** | **84 (4)** | *10 (4)* | *30 (4)* | **77 (4)** | 45 (4) | 57 |
| **P** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | 50 (4) | **92 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | 76 (4) | 69 (4) | **100 (4)** | **100 (4)** | 92 |
| **Sp** | *20 (4)* | *28 (4)* | 49 (4) | *31 (4)* | *8 (4)* | 50 (4) | *17 (4)* | *15 (4)* | **90 (4)** | **80 (4)** | 61 (4) | 43 (4) | **58 (4)** | 54 (4) | 43 |
| **KSp** | *28 (4)* | 38 (4) | **76 (4)** | *32 (4)* | *0 (4)* | **83 (4)** | 50 (4) | **80 (4)** | **74 (4)** | **84 (4)** | *25 (4)* | 43 (4) | **74 (4)** | *24 (4)* | 51 |
| **KB** | *14 (4)* | *18 (4)* | 39 (4) | *17 (4)* | *0 (4)* | **85 (4)** | *20 (4)* | 50 (4) | **71 (4)** | **91 (4)** | *0 (4)* | *30 (4)* | 52 (4) | *28 (4)* | 37 |
| **Se** | *13 (4)* | *24 (4)* | 66 (4) | *29 (4)* | *0 (4)* | *10 (4)* | *26 (4)* | *29 (4)* | 50 (4) | **90 (4)** | *0 (4)* | *16 (4)* | **65 (4)** | *28 (4)* | 32 |
| **KSe** | *13 (4)* | *13 (4)* | *19 (4)* | *16 (4)* | *0 (4)* | *20 (4)* | *16 (4)* | *9 (4)* | *10 (4)* | 50 (4) | *0 (4)* | *12 (4)* | *17 (4)* | *15 (4)* | 15 |
| **O** | **100 (4)** | **100 (4)** | 41 (4) | **90 (4)** | 24 (4) | 39 (4) | **75 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | 50 (4) | 65 (4) | **100 (4)** | 35 (4) | 73 |
| **CW** | **75 (4)** | **74 (4)** | **80 (4)** | **70 (4)** | 31 (4) | 57 (4) | 57 (4) | **70 (4)** | **84 (4)** | **88 (4)** | 35 (4) | 50 (4) | **74 (4)** | **71 (4)** | 65 |
| **KGW** | *17 (4)* | *26 (4)* | *20 (4)* | *23 (4)* | *0 (4)* | *42 (4)* | *26 (4)* | 48 (4) | *35 (4)* | **83 (4)** | *0 (4)* | *26 (4)* | 50 (4) | 32 (4) | 30 |
| **KPN** | **70 (4)** | **76 (4)** | **79 (4)** | 55 (4) | *0 (4)* | 46 (4) | **76 (4)** | **72 (4)** | **72 (4)** | **85 (4)** | 65 (4) | *29 (4)* | 68 (4) | 50 (4) | 60 |

| comp | its best counter (its share) | it beats clearly |
|---|---|---|
| K (Clock Soldiers, no Winders) | P (100) | KW, KN, Sp, KSp, KB, Se, KSe, KGW |
| KW (Clock Soldiers + Winders) | P (100) | KN, Sp, KB, Se, KSe, KGW |
| KN (Clock Soldiers + Netters) | P (100) | KSe, KGW |
| KP (Clock Soldiers + Pendulums) | P (100) | K, KW, KN, Sp, KSp, KB, Se, KSe, KGW |
| P (Pendulums) | nothing beats it | K, KW, KN, KP, Sp, KSp, KB, Se, KSe, KGW, KPN |
| Sp (Springers) | P (92) | Se, KSe, KGW |
| KSp (Clock Soldiers + Springers) | P (100) | KN, Sp, KB, Se, KSe, KGW |
| KB (Clock Soldiers + Spring Ballistas) | P (100) | Sp, Se, KSe |
| Se (Brass Serpents) | P (100) | KSe, KGW |
| KSe (Clock Soldiers + Brass Serpents) | P (100) | none |
| O (the air: Ticking Owls + Swifts) | P (76) | K, KW, KP, KSp, KB, Se, KSe, KGW |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | P (69) | K, KW, KN, KP, KB, Se, KSe, KGW, KPN |
| KGW (Clock Soldiers + the Great Winder (no Winders)) | P (100) | KSe |
| KPN (Clock Soldiers + Pendulums + Netters) | P (100) | K, KW, KN, KSp, KB, Se, KSe |

Best on average: Clockwork P 92, O 73, CW 65, KPN 60

Safest (best at its worst): P 50, CW 31, O 24.

**The best blind mix** (each side picks blind, each at its best mix): P 100%.

### Clockwork v Clockwork: open field, mid (1,500) (784 results)

Each cell: the **row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| row \ column | K | KW | KN | KP | P | Sp | KSp | KB | Se | KSe | O | CW | KGW | KPN | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **K** | 50 (4) | **66 (4)** | **83 (4)** | *17 (4)* | *16 (4)* | **86 (4)** | **81 (4)** | 37 (4) | **87 (4)** | **92 (4)** | *0 (4)* | *22 (4)* | **76 (4)** | *24 (4)* | 53 |
| **KW** | *34 (4)* | 50 (4) | **77 (4)** | *19 (4)* | *4 (4)* | **81 (4)** | **77 (4)** | *31 (4)* | **81 (4)** | **88 (4)** | *0 (4)* | *24 (4)* | **71 (4)** | *15 (4)* | 47 |
| **KN** | *17 (4)* | *23 (4)* | 50 (4) | *12 (4)* | *4 (4)* | **87 (4)** | 33 (4) | *10 (4)* | 56 (4) | **82 (4)** | 68 (4) | *11 (4)* | 34 (4) | *6 (4)* | 35 |
| **KP** | **83 (4)** | **81 (4)** | **88 (4)** | 50 (4) | *15 (4)* | **83 (4)** | **83 (4)** | **80 (4)** | **70 (4)** | **82 (4)** | *11 (4)* | 56 (4) | **78 (4)** | **56 (4)** | 65 |
| **P** | **84 (4)** | **96 (4)** | **96 (4)** | **85 (4)** | 50 (4) | **81 (4)** | **88 (4)** | **84 (4)** | **96 (4)** | **100 (4)** | 59 (4) | **84 (4)** | **100 (4)** | **100 (4)** | 86 |
| **Sp** | *14 (4)* | *19 (4)* | *13 (4)* | *17 (4)* | *19 (4)* | 50 (4) | *28 (4)* | *7 (4)* | **82 (4)** | 65 (4) | 55 (4) | *30 (4)* | *15 (4)* | *9 (4)* | 30 |
| **KSp** | *19 (4)* | *23 (4)* | 67 (4) | *17 (4)* | *12 (4)* | **72 (4)** | 50 (4) | *8 (4)* | **81 (4)** | **78 (4)** | *35 (4)* | *20 (4)* | 35 (4) | *9 (4)* | 38 |
| **KB** | 63 (4) | **69 (4)** | **90 (4)** | *20 (4)* | *16 (4)* | **93 (4)** | **92 (4)** | 50 (4) | **84 (4)** | **89 (4)** | *0 (4)* | 50 (4) | **80 (4)** | *28 (4)* | 59 |
| **Se** | *13 (4)* | *19 (4)* | 44 (4) | *30 (4)* | *4 (4)* | *18 (4)* | *19 (4)* | *16 (4)* | 50 (4) | **75 (4)** | *0 (4)* | *20 (4)* | *31 (4)* | 51 (4) | 28 |
| **KSe** | *8 (4)* | *12 (4)* | *18 (4)* | *18 (4)* | *0 (4)* | 35 (4) | *22 (4)* | *11 (4)* | *25 (4)* | 50 (4) | *0 (4)* | *24 (4)* | *15 (4)* | *21 (4)* | 18 |
| **O** | **100 (4)** | **100 (4)** | 32 (4) | **89 (4)** | 41 (4) | 45 (4) | **65 (4)** | **100 (4)** | **100 (4)** | **100 (4)** | 50 (4) | 59 (4) | **100 (4)** | 40 (4) | 73 |
| **CW** | **78 (4)** | **76 (4)** | **89 (4)** | 44 (4) | *16 (4)* | **70 (4)** | **80 (4)** | 50 (4) | **80 (4)** | **76 (4)** | 41 (4) | 50 (4) | **68 (4)** | **74 (4)** | 64 |
| **KGW** | *24 (4)* | *29 (4)* | 66 (4) | *22 (4)* | *0 (4)* | **85 (4)** | 65 (4) | *20 (4)* | **69 (4)** | **85 (4)** | *0 (4)* | *32 (4)* | 50 (4) | *20 (4)* | 40 |
| **KPN** | **76 (4)** | **85 (4)** | **94 (4)** | *44 (4)* | *0 (4)* | **91 (4)** | **91 (4)** | **72 (4)** | 49 (4) | **79 (4)** | 60 (4) | *26 (4)* | **80 (4)** | 50 (4) | 64 |

| comp | its best counter (its share) | it beats clearly |
|---|---|---|
| K (Clock Soldiers, no Winders) | O (100) | KW, KN, Sp, KSp, Se, KSe, KGW |
| KW (Clock Soldiers + Winders) | O (100) | KN, Sp, KSp, Se, KSe, KGW |
| KN (Clock Soldiers + Netters) | P (96) | Sp, KSe |
| KP (Clock Soldiers + Pendulums) | O (89) | K, KW, KN, Sp, KSp, KB, Se, KSe, KGW, KPN |
| P (Pendulums) | nothing beats it | K, KW, KN, KP, Sp, KSp, KB, Se, KSe, CW, KGW, KPN |
| Sp (Springers) | KB (93) | Se |
| KSp (Clock Soldiers + Springers) | KB (92) | Sp, Se, KSe |
| KB (Clock Soldiers + Spring Ballistas) | O (100) | KW, KN, Sp, KSp, Se, KSe, KGW |
| Se (Brass Serpents) | O (100) | KSe |
| KSe (Clock Soldiers + Brass Serpents) | P (100) | none |
| O (the air: Ticking Owls + Swifts) | KN (68) | K, KW, KP, KSp, KB, Se, KSe, KGW |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | P (84) | K, KW, KN, Sp, KSp, Se, KSe, KGW, KPN |
| KGW (Clock Soldiers + the Great Winder (no Winders)) | P (100) | Sp, Se, KSe |
| KPN (Clock Soldiers + Pendulums + Netters) | P (100) | K, KW, KN, Sp, KSp, KB, KSe, KGW |

Best on average: Clockwork P 86, O 73, KP 65, KPN 64

Safest (best at its worst): P 50, O 32, CW 16.

**The best blind mix** (each side picks blind, each at its best mix): P 100%.

## Crown v Clockwork


### Crown v Clockwork: open field, early (600) (728 results)

Each cell: the **Crown row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Crown \ Clockwork | K | KW | KN | KP | P | Sp | KSp | KB | Se | KSe | O | CW | KGW | KPN | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **M** | **97 (4)** | **95 (4)** | **100 (4)** | **100 (4)** | **60 (4)** | **92 (4)** | **90 (4)** | **100 (4)** | **92 (4)** | **100 (4)** | **97 (4)** | **86 (4)** | **100 (4)** | **87 (4)** | 93 |
| **MC** | **89 (4)** | **85 (4)** | **87 (4)** | 82 (4) | *9 (4)* | 64 (4) | 74 (4) | **97 (4)** | **88 (4)** | **100 (4)** | *36 (4)* | *46 (4)* | **91 (4)** | 61 (4) | 72 |
| **MCH** | 64 (4) | **76 (4)** | **82 (4)** | 48 (4) | **72 (4)** | 56 (4) | **75 (4)** | **84 (4)** | **76 (4)** | **88 (4)** | *27 (4)* | 35 (4) | **88 (4)** | 47 (4) | 66 |
| **MMo** | **89 (4)** | **90 (4)** | **89 (4)** | 84 (4) | *9 (4)* | 64 (4) | 63 (4) | **97 (4)** | **88 (4)** | **94 (4)** | 55 (4) | 44 (4) | **96 (4)** | *38 (4)* | 71 |
| **MCMo** | *20 (4)* | *30 (4)* | **80 (4)** | 51 (4) | *5 (4)* | *30 (4)* | *22 (4)* | *30 (4)* | *36 (4)* | **78 (4)** | *13 (4)* | *26 (4)* | 42 (4) | 56 (4) | 37 |
| **MH** | **86 (4)** | **91 (4)** | **94 (4)** | **87 (4)** | *23 (4)* | **88 (4)** | **92 (4)** | **100 (4)** | **88 (4)** | **100 (4)** | 55 (4) | 46 (4) | **100 (4)** | **77 (4)** | 81 |
| **H** | **90 (4)** | **77 (4)** | **87 (4)** | 69 (4) | 36 (4) | **82 (4)** | **79 (4)** | **85 (4)** | *0 (4)* | **95 (4)** | *0 (4)* | 62 (4) | **88 (4)** | 69 (4) | 66 |
| **D** | *29 (4)* | 54 (4) | **77 (4)** | 43 (4) | *16 (4)* | *22 (4)* | *31 (4)* | **75 (4)** | **64 (4)** | **89 (4)** | 55 (4) | *24 (4)* | **71 (4)** | *44 (4)* | 50 |
| **MD** | **62 (4)** | **60 (4)** | **67 (4)** | **64 (4)** | 54 (4) | 38 (4) | **62 (4)** | **62 (4)** | **72 (4)** | **69 (4)** | **66 (4)** | 34 (4) | **61 (4)** | *34 (4)* | 57 |
| **MO** | **97 (4)** | **100 (4)** | **97 (4)** | **89 (4)** | 50 (4) | **92 (4)** | **97 (4)** | **100 (4)** | **97 (4)** | **100 (4)** | **100 (4)** | 81 (4) | **100 (4)** | **83 (4)** | 92 |
| **MB** | **89 (4)** | **95 (4)** | **98 (4)** | **82 (4)** | 38 (4) | **88 (4)** | **93 (4)** | **89 (4)** | **97 (4)** | **98 (4)** | **89 (4)** | 73 (4) | **100 (4)** | **77 (4)** | 86 |
| **MMi** | **95 (4)** | **95 (4)** | **97 (4)** | **94 (4)** | 47 (4) | **95 (4)** | **95 (4)** | **100 (4)** | **89 (4)** | **100 (4)** | **87 (4)** | 71 (4) | **96 (4)** | 71 (4) | 88 |
| **CH** | *41 (4)* | 47 (4) | 50 (4) | 38 (4) | 20 (4) | *9 (4)* | 52 (4) | 59 (4) | 70 (4) | 54 (4) | *14 (4)* | 40 (4) | **73 (4)** | 34 (4) | 43 |

| Crown comp | Clockwork's best answer (Crown share) | Clockwork comp | Crown's best answer (Crown share) |
|---|---|---|---|
| M (Musketeers) | P (60) | K (Clock Soldiers, no Winders) | M (97) |
| MC (Musketeers + Field Cannons) | P (9) | KW (Clock Soldiers + Winders) | MO (100) |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | O (27) | KN (Clock Soldiers + Netters) | M (100) |
| MMo (Musketeers + Mortars) | P (9) | KP (Clock Soldiers + Pendulums) | M (100) |
| MCMo (Musketeers + Cannons + Mortars) | P (5) | P (Pendulums) | MCH (72) |
| MH (Musketeers + Horsemen) | P (23) | Sp (Springers) | MMi (95) |
| H (Horsemen) | Se (0) | KSp (Clock Soldiers + Springers) | MO (97) |
| D (Dragoons) | P (16) | KB (Clock Soldiers + Spring Ballistas) | M (100) |
| MD (Musketeers + Dragoons) | CW (34) | Se (Brass Serpents) | MO (97) |
| MO (Musketeers + Officers) | P (50) | KSe (Clock Soldiers + Brass Serpents) | M (100) |
| MB (Musketeers + the band) | P (38) | O (the air: Ticking Owls + Swifts) | MO (100) |
| MMi (Musketeers + a Missionary) | P (47) | CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | M (86) |
| CH (Cannons + Horsemen) | Sp (9) | KGW (Clock Soldiers + the Great Winder (no Winders)) | M (100) |
|  |  | KPN (Clock Soldiers + Pendulums + Netters) | M (87) |

Best on average: Crown M 93, MO 92, MMi 88, MB 86
; Clockwork P 66, CW 49, O 47, KPN 40 (its own share).

Safest (best at its worst): Crown M 60, MO 50, MMi 47; Clockwork P 28, CW 14, KPN 13.

**The game's value at equal cost** (both pick blind, each its best mix): Crown's share **65**. Crown's mix: M 59%, MCH 41%. Clockwork's: P 81%, CW 19%.

### Crown v Clockwork: open field, mid (1,500) (728 results)

Each cell: the **Crown row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Crown \ Clockwork | K | KW | KN | KP | P | Sp | KSp | KB | Se | KSe | O | CW | KGW | KPN | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **M** | **79 (4)** | **82 (4)** | **90 (4)** | 70 (4) | 57 (4) | **93 (4)** | **86 (4)** | **79 (4)** | **99 (4)** | **96 (4)** | **96 (4)** | **83 (4)** | **84 (4)** | **72 (4)** | 83 |
| **MC** | **61 (4)** | **83 (4)** | **88 (4)** | **78 (4)** | 44 (4) | **79 (4)** | **75 (4)** | **77 (4)** | **90 (4)** | **92 (4)** | *41 (4)* | **73 (4)** | **72 (4)** | **72 (4)** | 73 |
| **MCH** | **68 (4)** | **76 (4)** | **83 (4)** | 56 (4) | 42 (4) | **74 (4)** | **69 (4)** | *32 (4)* | **80 (4)** | **84 (4)** | *43 (4)* | **84 (4)** | **82 (4)** | **73 (4)** | 68 |
| **MMo** | 63 (4) | **81 (4)** | **89 (4)** | 65 (4) | *32 (4)* | **76 (4)** | **71 (4)** | **75 (4)** | **95 (4)** | **92 (4)** | **81 (4)** | 58 (4) | **76 (4)** | **76 (4)** | 74 |
| **MCMo** | 60 (4) | **83 (4)** | **90 (4)** | **77 (4)** | *30 (4)* | **75 (4)** | **75 (4)** | **77 (4)** | **92 (4)** | **94 (4)** | 61 (4) | **73 (4)** | **75 (4)** | **73 (4)** | 74 |
| **MH** | **75 (4)** | **80 (4)** | **78 (4)** | **81 (4)** | 47 (4) | **84 (4)** | **83 (4)** | 47 (4) | **86 (4)** | **100 (4)** | **72 (4)** | **78 (4)** | **93 (4)** | **83 (4)** | 78 |
| **H** | **87 (4)** | **87 (4)** | **92 (4)** | **84 (4)** | *20 (4)* | **90 (4)** | **83 (4)** | **90 (4)** | 75 (4) | **91 (4)** | 16 (4) | **92 (4)** | **82 (4)** | **80 (4)** | 76 |
| **D** | *32 (4)* | 47 (4) | 46 (4) | *30 (4)* | *32 (4)* | 51 (4) | **73 (4)** | 37 (4) | **75 (4)** | **75 (4)** | **74 (4)** | 37 (4) | **62 (4)** | 55 (4) | 52 |
| **MD** | **64 (4)** | **66 (4)** | **72 (4)** | 66 (4) | 48 (4) | **67 (4)** | 52 (4) | **63 (4)** | **76 (4)** | **75 (4)** | **88 (4)** | 47 (4) | **66 (4)** | 64 (4) | 65 |
| **MO** | **83 (4)** | **90 (4)** | **92 (4)** | **66 (4)** | 71 (4) | **89 (4)** | **90 (4)** | **91 (4)** | **97 (4)** | **100 (4)** | **92 (4)** | **91 (4)** | **91 (4)** | **78 (4)** | 87 |
| **MB** | **86 (4)** | **88 (4)** | **91 (4)** | 68 (4) | 48 (4) | **89 (4)** | **84 (4)** | *29 (4)* | **100 (4)** | **97 (4)** | **95 (4)** | **88 (4)** | **91 (4)** | 69 (4) | 80 |
| **MMi** | **77 (4)** | **83 (4)** | **85 (4)** | 70 (4) | 48 (4) | **87 (4)** | **81 (4)** | **76 (4)** | **95 (4)** | **87 (4)** | **95 (4)** | **74 (4)** | **83 (4)** | **77 (4)** | 80 |
| **CH** | 61 (4) | 56 (4) | **76 (4)** | **69 (4)** | 57 (4) | **62 (4)** | **63 (4)** | **62 (4)** | **81 (4)** | **84 (4)** | *3 (4)* | **74 (4)** | **70 (4)** | 72 (4) | 63 |

| Crown comp | Clockwork's best answer (Crown share) | Clockwork comp | Crown's best answer (Crown share) |
|---|---|---|---|
| M (Musketeers) | P (57) | K (Clock Soldiers, no Winders) | H (87) |
| MC (Musketeers + Field Cannons) | O (41) | KW (Clock Soldiers + Winders) | MO (90) |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | KB (32) | KN (Clock Soldiers + Netters) | H (92) |
| MMo (Musketeers + Mortars) | P (32) | KP (Clock Soldiers + Pendulums) | H (84) |
| MCMo (Musketeers + Cannons + Mortars) | P (30) | P (Pendulums) | MO (71) |
| MH (Musketeers + Horsemen) | KB (47) | Sp (Springers) | M (93) |
| H (Horsemen) | O (16) | KSp (Clock Soldiers + Springers) | MO (90) |
| D (Dragoons) | KP (30) | KB (Clock Soldiers + Spring Ballistas) | MO (91) |
| MD (Musketeers + Dragoons) | CW (47) | Se (Brass Serpents) | MB (100) |
| MO (Musketeers + Officers) | KP (66) | KSe (Clock Soldiers + Brass Serpents) | MH (100) |
| MB (Musketeers + the band) | KB (29) | O (the air: Ticking Owls + Swifts) | M (96) |
| MMi (Musketeers + a Missionary) | P (48) | CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | H (92) |
| CH (Cannons + Horsemen) | O (3) | KGW (Clock Soldiers + the Great Winder (no Winders)) | MH (93) |
|  |  | KPN (Clock Soldiers + Pendulums + Netters) | MH (83) |

Best on average: Crown MO 87, M 83, MB 80, MMi 80
; Clockwork P 56, KB 36, O 34, KP 32 (its own share).

Safest (best at its worst): Crown MO 66, M 57, MMi 48; Clockwork P 29, KPN 17, KP 16.

**The game's value at equal cost** (both pick blind, each its best mix): Crown's share **68**. Crown's mix: MO 87%, MH 13%. Clockwork's: KP 60%, P 40%.

### Crown v Clockwork: open field, late (4,000) (72 results)

Each cell: the **Crown row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Crown \ Clockwork | KP | P | KB | O | CW | KPN | mean |
|---|---|---|---|---|---|---|---|
| **M** | **93 (2)** | **97 (2)** | *25 (2)* | **98 (2)** | **90 (2)** | **96 (2)** | 83 |
| **MC** | **77 (2)** | 96 (2) | *34 (2)* | 94 (2) | **79 (2)** | 76 (2) | 76 |
| **MCH** | 81 (2) | 81 (2) | *34 (2)* | 76 (2) | **74 (2)** | 81 (2) | 71 |
| **MH** | **91 (2)** | **93 (2)** | 30 (2) | 79 (2) | 57 (2) | **87 (2)** | 73 |
| **H** | **94 (2)** | 76 (2) | 44 (2) | *0 (2)* | **91 (2)** | 92 (2) | 66 |
| **MO** | **96 (2)** | **97 (2)** | 53 (2) | **98 (2)** | 84 (2) | **98 (2)** | 87 |

| Crown comp | Clockwork's best answer (Crown share) | Clockwork comp | Crown's best answer (Crown share) |
|---|---|---|---|
| M (Musketeers) | KB (25) | KP (Clock Soldiers + Pendulums) | MO (96) |
| MC (Musketeers + Field Cannons) | KB (34) | P (Pendulums) | MO (97) |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | KB (34) | KB (Clock Soldiers + Spring Ballistas) | MO (53) |
| MH (Musketeers + Horsemen) | KB (30) | O (the air: Ticking Owls + Swifts) | M (98) |
| H (Horsemen) | O (0) | CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | H (91) |
| MO (Musketeers + Officers) | KB (53) | KPN (Clock Soldiers + Pendulums + Netters) | MO (98) |

Best on average: Crown MO 87, M 83, MC 76, MH 73
; Clockwork KB 63, O 26, CW 21, KP 12 (its own share).

Safest (best at its worst): Crown MO 53, MC 34, MCH 34; Clockwork KB 47, CW 9, KP 4.

**The game's value at equal cost** (both pick blind, each its best mix): Crown's share **53**. Crown's mix: MO 100%. Clockwork's: KB 100%.

### Crown v Clockwork: the set line (side A formed by hand, ready), mid (1,500) (144 results)

Each cell: the **Crown row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Crown \ Clockwork | KP | P | KB | O | CW | KPN | mean |
|---|---|---|---|---|---|---|---|
| **M** | 40 (4) | *21 (4)* | *33 (4)* | **95 (4)** | *42 (4)* | **72 (4)** | 51 |
| **MC** | 66 (4) | 56 (4) | *34 (4)* | 69 (4) | *42 (4)* | **81 (4)** | 58 |
| **MCH** | **81 (4)** | **74 (4)** | 65 (4) | 36 (4) | 55 (4) | **92 (4)** | 67 |
| **MH** | 71 (4) | 43 (4) | 80 (4) | **81 (4)** | **88 (4)** | **91 (4)** | 76 |
| **H** | **62 (4)** | 51 (4) | 72 (4) | *0 (4)* | 71 (4) | **75 (4)** | 55 |
| **MO** | 51 (4) | *20 (4)* | *34 (4)* | 67 (4) | *43 (4)* | **71 (4)** | 48 |

| Crown comp | Clockwork's best answer (Crown share) | Clockwork comp | Crown's best answer (Crown share) |
|---|---|---|---|
| M (Musketeers) | P (21) | KP (Clock Soldiers + Pendulums) | MCH (81) |
| MC (Musketeers + Field Cannons) | KB (34) | P (Pendulums) | MCH (74) |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | O (36) | KB (Clock Soldiers + Spring Ballistas) | MH (80) |
| MH (Musketeers + Horsemen) | P (43) | O (the air: Ticking Owls + Swifts) | M (95) |
| H (Horsemen) | O (0) | CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | MH (88) |
| MO (Musketeers + Officers) | P (20) | KPN (Clock Soldiers + Pendulums + Netters) | MCH (92) |

Best on average: Crown MH 76, MCH 67, MC 58, H 55
; Clockwork P 56, KB 47, CW 43, O 42 (its own share).

Safest (best at its worst): Crown MH 43, MCH 36, MC 34; Clockwork P 26, KB 20, KP 19.

**The game's value at equal cost** (both pick blind, each its best mix): Crown's share **60**. Crown's mix: MCH 39%, MC 32%, MH 29%. Clockwork's: P 57%, O 38%, KB 6%.

### Crown v Clockwork: a choke (side A holds the gap), mid (1,500) (144 results)

Each cell: the **Crown row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Crown \ Clockwork | KP | P | KB | O | CW | KPN | mean |
|---|---|---|---|---|---|---|---|
| **M** | 47 (4) | *23 (4)* | *33 (4)* | **95 (4)** | *42 (4)* | **73 (4)** | 52 |
| **MC** | 56 (4) | 50 (4) | *38 (4)* | **75 (4)** | *42 (4)* | **79 (4)** | 57 |
| **MCH** | **78 (4)** | **65 (4)** | 50 (4) | *37 (4)* | 51 (4) | **90 (4)** | 62 |
| **MH** | **74 (4)** | *27 (4)* | **96 (4)** | **75 (4)** | 50 (4) | **88 (4)** | 69 |
| **H** | **61 (4)** | 50 (4) | 55 (4) | *0 (4)* | 54 (4) | **87 (4)** | 51 |
| **MO** | *39 (4)* | *29 (4)* | *33 (4)* | 52 (4) | *43 (4)* | 72 (4) | 45 |

| Crown comp | Clockwork's best answer (Crown share) | Clockwork comp | Crown's best answer (Crown share) |
|---|---|---|---|
| M (Musketeers) | P (23) | KP (Clock Soldiers + Pendulums) | MCH (78) |
| MC (Musketeers + Field Cannons) | KB (38) | P (Pendulums) | MCH (65) |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | O (37) | KB (Clock Soldiers + Spring Ballistas) | MH (96) |
| MH (Musketeers + Horsemen) | P (27) | O (the air: Ticking Owls + Swifts) | M (95) |
| H (Horsemen) | O (0) | CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | H (54) |
| MO (Musketeers + Officers) | P (29) | KPN (Clock Soldiers + Pendulums + Netters) | MCH (90) |

Best on average: Crown MH 69, MCH 62, MC 57, M 52
; Clockwork P 60, CW 53, KB 49, O 44 (its own share).

Safest (best at its worst): Crown MC 38, MCH 37, MO 29; Clockwork CW 46, P 35, KP 22.

**The game's value at equal cost** (both pick blind, each its best mix): Crown's share **51**. Crown's mix: MCH 64%, MH 36%. Clockwork's: CW 56%, O 23%, P 21%.

### Crown v Clockwork: a ramp, side A on top, mid (1,500) (144 results)

Each cell: the **Crown row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Crown \ Clockwork | KP | P | KB | O | CW | KPN | mean |
|---|---|---|---|---|---|---|---|
| **M** | 51 (4) | *24 (4)* | *38 (4)* | **96 (4)** | **81 (4)** | **78 (4)** | 61 |
| **MC** | **85 (4)** | 71 (4) | 81 (4) | 58 (4) | **97 (4)** | **92 (4)** | 81 |
| **MCH** | **85 (4)** | 62 (4) | **88 (4)** | *30 (4)* | **98 (4)** | **100 (4)** | 77 |
| **MH** | 63 (4) | *29 (4)* | 70 (4) | **77 (4)** | **79 (4)** | **92 (4)** | 68 |
| **H** | 70 (4) | 47 (4) | *20 (4)* | *0 (4)* | **77 (4)** | **84 (4)** | 50 |
| **MO** | 50 (4) | *24 (4)* | 45 (4) | **67 (4)** | 57 (4) | **72 (4)** | 52 |

| Crown comp | Clockwork's best answer (Crown share) | Clockwork comp | Crown's best answer (Crown share) |
|---|---|---|---|
| M (Musketeers) | P (24) | KP (Clock Soldiers + Pendulums) | MC (85) |
| MC (Musketeers + Field Cannons) | O (58) | P (Pendulums) | MC (71) |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | O (30) | KB (Clock Soldiers + Spring Ballistas) | MCH (88) |
| MH (Musketeers + Horsemen) | P (29) | O (the air: Ticking Owls + Swifts) | M (96) |
| H (Horsemen) | O (0) | CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | MCH (98) |
| MO (Musketeers + Officers) | P (24) | KPN (Clock Soldiers + Pendulums + Netters) | MCH (100) |

Best on average: Crown MC 81, MCH 77, MH 68, M 61
; Clockwork P 57, O 45, KB 43, KP 33 (its own share).

Safest (best at its worst): Crown MC 58, MCH 30, MH 29; Clockwork P 29, KP 15, KB 12.

**The game's value at equal cost** (both pick blind, each its best mix): Crown's share **64**. Crown's mix: MC 85%, M 15%. Clockwork's: O 55%, P 45%.

## Clockwork v Crown


### Clockwork v Crown: the set line (side A formed by hand, ready), mid (1,500) (144 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Crown | M | MC | MCH | MH | H | MO | mean |
|---|---|---|---|---|---|---|---|
| **KP** | *14 (4)* | *28 (4)* | *37 (4)* | *26 (4)* | *0 (4)* | *14 (4)* | 20 |
| **P** | 60 (4) | *43 (4)* | *41 (4)* | 44 (4) | *0 (4)* | *35 (4)* | 37 |
| **Sp** | *9 (4)* | *12 (4)* | *18 (4)* | *23 (4)* | *0 (4)* | *3 (4)* | 11 |
| **KB** | 57 (4) | **62 (4)** | **62 (4)** | 51 (4) | *0 (4)* | 34 (4) | 44 |
| **CW** | *10 (4)* | *26 (4)* | *28 (4)* | *27 (4)* | *0 (4)* | *7 (4)* | 16 |
| **KPN** | *11 (4)* | *15 (4)* | *21 (4)* | *22 (4)* | *0 (4)* | *5 (4)* | 12 |

| Clockwork comp | Crown's best answer (Clockwork share) | Crown comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| KP (Clock Soldiers + Pendulums) | H (0) | M (Musketeers) | P (60) |
| P (Pendulums) | H (0) | MC (Musketeers + Field Cannons) | KB (62) |
| Sp (Springers) | H (0) | MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | KB (62) |
| KB (Clock Soldiers + Spring Ballistas) | H (0) | MH (Musketeers + Horsemen) | KB (51) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | H (0) | H (Horsemen) | KP (0) |
| KPN (Clock Soldiers + Pendulums + Netters) | H (0) | MO (Musketeers + Officers) | P (35) |

Best on average: Clockwork KB 44, P 37, KP 20, CW 16
; Crown H 100, MO 84, M 73, MC 69 (its own share).

Safest (best at its worst): Clockwork KP 0, P 0, Sp 0; Crown H 100, MO 65, MH 49.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **0**. Clockwork's mix: KP 100%. Crown's: H 100%.

### Clockwork v Crown: a choke (side A holds the gap), mid (1,500) (144 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Crown | M | MC | MCH | MH | H | MO | mean |
|---|---|---|---|---|---|---|---|
| **KP** | *18 (4)* | *27 (4)* | *33 (4)* | *28 (4)* | *8 (4)* | *16 (4)* | 22 |
| **P** | 60 (4) | 43 (4) | *41 (4)* | 43 (4) | 43 (4) | *40 (4)* | 45 |
| **Sp** | *8 (4)* | *11 (4)* | *16 (4)* | *23 (4)* | *3 (4)* | *3 (4)* | 11 |
| **KB** | 56 (4) | **62 (4)** | **62 (4)** | 40 (4) | *15 (4)* | 41 (4) | 46 |
| **CW** | *8 (4)* | *29 (4)* | *30 (4)* | *26 (4)* | *5 (4)* | *6 (4)* | 17 |
| **KPN** | *11 (4)* | *18 (4)* | *22 (4)* | *23 (4)* | *5 (4)* | *5 (4)* | 14 |

| Clockwork comp | Crown's best answer (Clockwork share) | Crown comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| KP (Clock Soldiers + Pendulums) | H (8) | M (Musketeers) | P (60) |
| P (Pendulums) | MO (40) | MC (Musketeers + Field Cannons) | KB (62) |
| Sp (Springers) | MO (3) | MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | KB (62) |
| KB (Clock Soldiers + Spring Ballistas) | H (15) | MH (Musketeers + Horsemen) | P (43) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | H (5) | H (Horsemen) | P (43) |
| KPN (Clock Soldiers + Pendulums + Netters) | H (5) | MO (Musketeers + Officers) | KB (41) |

Best on average: Clockwork KB 46, P 45, KP 22, CW 17
; Crown H 87, MO 81, M 73, MH 70 (its own share).

Safest (best at its worst): Clockwork P 40, KB 15, KP 8; Crown MO 59, H 57, MH 57.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **40**. Clockwork's mix: P 90%, KB 10%. Crown's: MO 97%, H 3%.

### Clockwork v Crown: a ramp, side A on top, mid (1,500) (144 results)

Each cell: the **Clockwork row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| Clockwork \ Crown | M | MC | MCH | MH | H | MO | mean |
|---|---|---|---|---|---|---|---|
| **KP** | *23 (4)* | 52 (4) | 63 (4) | 36 (4) | *0 (4)* | *19 (4)* | 32 |
| **P** | **79 (4)** | **82 (4)** | **74 (4)** | **63 (4)** | *0 (4)* | **72 (4)** | 62 |
| **Sp** | *12 (4)* | *21 (4)* | *17 (4)* | *12 (4)* | *0 (4)* | *10 (4)* | 12 |
| **KB** | **82 (4)** | **71 (4)** | **62 (4)** | **63 (4)** | *0 (4)* | 44 (4) | 54 |
| **CW** | *24 (4)* | 38 (4) | *32 (4)* | *22 (4)* | *0 (4)* | *14 (4)* | 21 |
| **KPN** | *17 (4)* | *21 (4)* | *20 (4)* | *11 (4)* | *0 (4)* | *7 (4)* | 13 |

| Clockwork comp | Crown's best answer (Clockwork share) | Crown comp | Clockwork's best answer (Clockwork share) |
|---|---|---|---|
| KP (Clock Soldiers + Pendulums) | H (0) | M (Musketeers) | KB (82) |
| P (Pendulums) | H (0) | MC (Musketeers + Field Cannons) | P (82) |
| Sp (Springers) | H (0) | MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | P (74) |
| KB (Clock Soldiers + Spring Ballistas) | H (0) | MH (Musketeers + Horsemen) | KB (63) |
| CW (the computer's push (Soldiers, Pendulums, Ballistas, Netters, a Springer)) | H (0) | H (Horsemen) | KP (0) |
| KPN (Clock Soldiers + Pendulums + Netters) | H (0) | MO (Musketeers + Officers) | P (72) |

Best on average: Clockwork P 62, KB 54, KP 32, CW 21
; Crown H 100, MO 72, MH 65, M 61 (its own share).

Safest (best at its worst): Clockwork KP 0, P 0, Sp 0; Crown H 100, MH 37, MO 28.

**The game's value at equal cost** (both pick blind, each its best mix): Clockwork's share **0**. Clockwork's mix: KP 100%. Crown's: H 100%.

## Crown v Crown


### Crown v Crown: open field, early (600) (676 results)

Each cell: the **row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| row \ column | M | MC | MCH | MMo | MCMo | MH | H | D | MD | MO | MB | MMi | CH | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **M** | 50 (4) | **76 (4)** | **81 (4)** | **80 (4)** | **87 (4)** | **72 (4)** | **95 (4)** | **90 (4)** | **87 (4)** | 36 (4) | 33 (4) | **76 (4)** | **94 (4)** | 74 |
| **MC** | *24 (4)* | 50 (4) | 64 (4) | **85 (4)** | 47 (4) | 48 (4) | **93 (4)** | 55 (4) | 54 (4) | 34 (4) | *14 (4)* | 51 (4) | 68 (4) | 53 |
| **MCH** | *19 (4)* | 36 (4) | 50 (4) | *27 (4)* | 64 (4) | 31 (4) | **85 (4)** | 44 (4) | **80 (4)** | *8 (4)* | *11 (4)* | *17 (4)* | **91 (4)** | 43 |
| **MMo** | *20 (4)* | *15 (4)* | **73 (4)** | 50 (4) | *20 (4)* | 25 (4) | **89 (4)** | 42 (4) | 73 (4) | *13 (4)* | *14 (4)* | 41 (4) | **73 (4)** | 42 |
| **MCMo** | *13 (4)* | 53 (4) | 36 (4) | **80 (4)** | 50 (4) | 30 (4) | 64 (4) | 35 (4) | **80 (4)** | *5 (4)* | 28 (4) | 25 (4) | 47 (4) | 42 |
| **MH** | *28 (4)* | 52 (4) | 69 (4) | 75 (4) | 70 (4) | 50 (4) | 74 (4) | **78 (4)** | 77 (4) | *23 (4)* | *32 (4)* | 32 (4) | 64 (4) | 56 |
| **H** | *5 (4)* | *7 (4)* | *15 (4)* | *11 (4)* | 36 (4) | 26 (4) | 50 (4) | *32 (4)* | *15 (4)* | *8 (4)* | *7 (4)* | *16 (4)* | 67 (4) | 23 |
| **D** | *10 (4)* | 45 (4) | 56 (4) | 58 (4) | 65 (4) | *22 (4)* | **68 (4)** | 50 (4) | 47 (4) | *13 (4)* | *2 (4)* | *0 (4)* | 39 (4) | 37 |
| **MD** | *13 (4)* | 46 (4) | *20 (4)* | 27 (4) | *20 (4)* | 23 (4) | **85 (4)** | 53 (4) | 50 (4) | *17 (4)* | 42 (4) | 46 (4) | 53 (4) | 38 |
| **MO** | 64 (4) | 66 (4) | **92 (4)** | **87 (4)** | **95 (4)** | **77 (4)** | **92 (4)** | **87 (4)** | **83 (4)** | 50 (4) | 34 (4) | **84 (4)** | **88 (4)** | 77 |
| **MB** | 67 (4) | **86 (4)** | **89 (4)** | **86 (4)** | 72 (4) | **68 (4)** | **93 (4)** | **98 (4)** | 58 (4) | 66 (4) | 50 (4) | 62 (4) | **79 (4)** | 75 |
| **MMi** | *24 (4)* | 49 (4) | **83 (4)** | 59 (4) | 75 (4) | 68 (4) | **84 (4)** | **100 (4)** | 54 (4) | *16 (4)* | 38 (4) | 50 (4) | 73 (4) | 59 |
| **CH** | *6 (4)* | 32 (4) | *9 (4)* | *27 (4)* | 53 (4) | 36 (4) | 33 (4) | 61 (4) | 47 (4) | *12 (4)* | *21 (4)* | 27 (4) | 50 (4) | 32 |

| comp | its best counter (its share) | it beats clearly |
|---|---|---|
| M (Musketeers) | MB (67) | MC, MCH, MMo, MCMo, MH, H, D, MD, MMi, CH |
| MC (Musketeers + Field Cannons) | MB (86) | MMo, H |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | MO (92) | H, MD, CH |
| MMo (Musketeers + Mortars) | MO (87) | MCH, H, CH |
| MCMo (Musketeers + Cannons + Mortars) | MO (95) | MMo, MD |
| MH (Musketeers + Horsemen) | MO (77) | D |
| H (Horsemen) | M (95) | none |
| D (Dragoons) | MMi (100) | H |
| MD (Musketeers + Dragoons) | M (87) | H |
| MO (Musketeers + Officers) | MB (66) | MCH, MMo, MCMo, MH, H, D, MD, MMi, CH |
| MB (Musketeers + the band) | nothing beats it | MC, MCH, MMo, MH, H, D, CH |
| MMi (Musketeers + a Missionary) | MO (84) | MCH, H, D |
| CH (Cannons + Horsemen) | M (94) | none |

Best on average: Crown MO 77, MB 75, M 74, MMi 59

Safest (best at its worst): MB 50, MO 34, M 33.

**The best blind mix** (each side picks blind, each at its best mix): MB 100%.

### Crown v Crown: open field, mid (1,500) (676 results)

Each cell: the **row's share** of the value lost (50 = even; bold: the row clearly ahead, italic: the column clearly ahead), then how many fights.

| row \ column | M | MC | MCH | MMo | MCMo | MH | H | D | MD | MO | MB | MMi | CH | mean |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **M** | 50 (4) | 55 (4) | **67 (4)** | 65 (4) | 62 (4) | 57 (4) | **95 (4)** | **91 (4)** | **81 (4)** | 29 (4) | 50 (4) | *25 (4)* | 61 (4) | 61 |
| **MC** | 45 (4) | 50 (4) | 62 (4) | 68 (4) | 50 (4) | 40 (4) | **95 (4)** | 65 (4) | 46 (4) | *32 (4)* | 55 (4) | 48 (4) | 70 (4) | 56 |
| **MCH** | *33 (4)* | 38 (4) | 50 (4) | 45 (4) | *35 (4)* | 42 (4) | **78 (4)** | **70 (4)** | 53 (4) | *34 (4)* | *30 (4)* | 37 (4) | 65 (4) | 47 |
| **MMo** | 35 (4) | 32 (4) | 55 (4) | 50 (4) | 36 (4) | 42 (4) | **90 (4)** | **73 (4)** | 43 (4) | *25 (4)* | *16 (4)* | *25 (4)* | **71 (4)** | 46 |
| **MCMo** | 38 (4) | 50 (4) | **65 (4)** | 64 (4) | 50 (4) | 25 (4) | **98 (4)** | **70 (4)** | 38 (4) | *27 (4)* | 51 (4) | 34 (4) | 71 (4) | 52 |
| **MH** | 43 (4) | 60 (4) | 58 (4) | 58 (4) | 75 (4) | 50 (4) | **79 (4)** | 56 (4) | 33 (4) | 46 (4) | 33 (4) | 62 (4) | **84 (4)** | 57 |
| **H** | *5 (4)* | *5 (4)* | *22 (4)* | *10 (4)* | *2 (4)* | *21 (4)* | 50 (4) | *23 (4)* | *33 (4)* | *15 (4)* | *6 (4)* | *7 (4)* | 52 (4) | 19 |
| **D** | *9 (4)* | 35 (4) | *30 (4)* | *27 (4)* | *30 (4)* | 44 (4) | **77 (4)** | 50 (4) | 37 (4) | *13 (4)* | *17 (4)* | *14 (4)* | 50 (4) | 33 |
| **MD** | *19 (4)* | 54 (4) | 47 (4) | 57 (4) | 62 (4) | 67 (4) | **67 (4)** | 63 (4) | 50 (4) | *9 (4)* | *26 (4)* | 27 (4) | 64 (4) | 47 |
| **MO** | 71 (4) | **68 (4)** | **66 (4)** | **75 (4)** | **73 (4)** | 54 (4) | **85 (4)** | **87 (4)** | **91 (4)** | 50 (4) | 59 (4) | 65 (4) | 68 (4) | 70 |
| **MB** | 50 (4) | 45 (4) | **70 (4)** | **84 (4)** | 49 (4) | 67 (4) | **94 (4)** | **83 (4)** | **74 (4)** | 41 (4) | 50 (4) | 51 (4) | 69 (4) | 64 |
| **MMi** | **75 (4)** | 52 (4) | 63 (4) | **75 (4)** | 66 (4) | 38 (4) | **93 (4)** | **86 (4)** | 73 (4) | 35 (4) | 49 (4) | 50 (4) | **64 (4)** | 63 |
| **CH** | 39 (4) | 30 (4) | 35 (4) | *29 (4)* | 29 (4) | *16 (4)* | 48 (4) | 50 (4) | 36 (4) | 32 (4) | 31 (4) | *36 (4)* | 50 (4) | 35 |

| comp | its best counter (its share) | it beats clearly |
|---|---|---|
| M (Musketeers) | MMi (75) | MCH, H, D, MD |
| MC (Musketeers + Field Cannons) | MO (68) | H |
| MCH (the computer's wave (Musketeers, Cannons, Horsemen)) | MB (70) | H, D |
| MMo (Musketeers + Mortars) | MB (84) | H, D, CH |
| MCMo (Musketeers + Cannons + Mortars) | MH (75) | MCH, H, D |
| MH (Musketeers + Horsemen) | MB (67) | H, CH |
| H (Horsemen) | MCMo (98) | none |
| D (Dragoons) | M (91) | H |
| MD (Musketeers + Dragoons) | MO (91) | H |
| MO (Musketeers + Officers) | nothing beats it | MC, MCH, MMo, MCMo, H, D, MD |
| MB (Musketeers + the band) | MO (59) | MCH, MMo, H, D, MD |
| MMi (Musketeers + a Missionary) | MO (65) | M, MMo, H, D, CH |
| CH (Cannons + Horsemen) | MH (84) | none |

Best on average: Crown MO 70, MB 64, MMi 63, M 61

Safest (best at its worst): MO 50, MB 41, MMi 35.

**The best blind mix** (each side picks blind, each at its best mix): MO 100%.

## The fighting counts (all grounds and sizes)

| matchup | fights | fight length s (mean) | pulls a minute, side A / B | Clockwork constructs run down (a fight) | under a quarter wind | Crown guns set at contact | guns fired in the first 20 s | own men killed by own splash |
|---|---|---|---|---|---|---|---|---|
| Brood v Brood | 676 | 23 | 3.2 / 2.7 | - | - | - | - | 0.00 |
| Clockwork v Brood | 2044 | 23 | 4.0 / 1.0 | 0.00 | 0.00 | - | - | 0.00 |
| Clockwork v Clockwork | 784 | 37 | 5.1 / 4.6 | 0.05 | 0.09 | - | - | 0.00 |
| Clockwork v Crown | 432 | 35 | 0.0 / 3.1 | 1.13 | 1.28 | 0% | 90% | 0.22 |
| Crown v Clockwork | 1960 | 31 | 6.2 / 4.4 | 0.04 | 0.06 | 20% | 75% | 0.31 |
| Crown v Crown | 676 | 40 | 11.1 / 10.2 | - | - | 0% | 74% | 0.00 |
