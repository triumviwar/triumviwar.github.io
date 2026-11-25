# The battle matrix: what counters what, Crown against Brood

The owner, 2026-11-25: "For us to make a decision to reduce the Rootmaw bonus we have to be 100% sure that is the problem.
Forget economy for a while and only do a gigantic round of battles... all possible compositions of Crown and Brood armies
fighting... We don't even know the best possible compositions and what counters what."

This is that round of battles. No game number was changed. The tools: `tools/battle_lab.gd` (one fight) and
`tools/study/battle_lab.py` (the jobs, the run on every core, the tables), `tools/study/battle_matrix_report.py` (the
analysis). The data: `docs/battle_matrix/data/rows.jsonl` (one line a fight). The full tables: `docs/battle_matrix/tables.md`.
The machine-made analysis: `docs/battle_matrix/analysis.md`. Pictures: `docs/shots/battle_matrix/`.

In all, **8,450 fights**: 13 Crown armies against 13 Brood armies (169 pairings), at three sizes and at the supply cap,
on six grounds, two to four times each.

## The short answer

- **At equal value, the Crown wins most of its fights with the armies the computers really use.** The Crown computer's
  own wave (Musketeers, Field Cannons and a few Horsemen) beats the Brood computer's usual armies (Raptors with Spitters,
  Tyrant Challengers) in the open at every size: scores of 58 to 73 against Raptors and Spitters, 60 to 68 against
  Tyrant Challengers. It loses to Spitters alone at mid and late (36 and 46), to Raptors, Spitters and Brutes at mid
  (44), and to the Tyrant Sire leading a wave (30 to 39).
- **The Crown is weak early and strong late.** Across all 169 pairings in the open field, the Crown is clearly ahead in
  27 and the Brood in 84 at 600 value; at 1,500 it is 40 to 78; at 4,000 it is 72 to 50. The Crown's army gets better
  per coin as it grows; the Brood's does not.
- **If both sides picked their army blind** (the best mix each could choose without seeing the other), the Crown's share
  of the losses would be about **57 to 61 in the open at every size**, as long as the Tyrant Sire stays at home. That is a
  Crown edge at equal cost, not a Brood one.
- **Two Brood things are far stronger per coin than anything else:** the **Tyrant Sire** in a fight (one 150-food
  creature with 1,000 health turns any Raptor and Spitter army into the strongest army in the lab early and mid), and
  **Venom Challengers** (they beat every Crown composition but the two with Musketeers and Horsemen). The Brood
  computer does not bring the Sire into its waves against the Crown.
- **Two Crown things are much weaker than their price:** **Dragoons** (as an army they lose nearly everything: score 0 to
  28 in the open) and **Mortars in a field fight** (they cannot fire inside 5 tiles, and the 30% of the army they cost
  is missing from the line).
- **The Crown's biggest FIGHTING problem is its guns.** In the open field the computer never had a single gun set up
  when the fight began (0 of 3,627 guns in 832 fights; 0 of 468 going up the ramp). Set up beforehand, the same army is
  far stronger: Musketeers with Cannons go from 42 to 57 at mid and from 56 to 78 late. Guns not set are dead weight;
  guns set are the Crown's best late weapon.
- **The Crown computer's foot and riders fight well.** Its own march-and-fight beats a line set by hand and left on
  HOLD (Musketeers 59 against 41 at mid), and its rider hit and run makes **Musketeers with Horsemen the best Crown army
  in the open** at mid and late (76 on average; late it out-trades every Brood army, though not all clearly).
- **For the Rootmaw question:** these fights do not show the Brood winning fights it should not win. At equal value the
  Crown's real army trades better than the Brood's real army, and the gap grows with size. If the Crown loses late games
  to the Brood, it is not because a coin's worth of Brood beats a coin's worth of Crown. It must come from what the lab
  leaves out: how and where the fights happen (guns not set, reinforcements one by one, labourers caught walking), how
  fast each side refills, and the economy behind it. This lab cannot weigh the economy, so it cannot clear or convict the
  Rootmaw bonus. See "What this matrix can and cannot say about the Rootmaw bonus".

## How a fight is made

- A real match on version 0.38.208, Crown against Brood, both computers on Hard and running. Neither side has any money:
  the lab empties both banks all the time, so nobody trains, researches or grows anything.
- Two armies are placed facing each other, away from both bases. **They are worth the same.** Every resource counts one
  for one at the game's own prices: gold, food, powder and spoils alike. A Crown rider or gun counts its horse (40). A
  Crown soldier counts his powder load and any refit fees he comes out with (armour, a better lock). A Brood young counts
  its egg's price over the young in the egg (a Raptor is 25, a Spitter 47.5). The Brood army is built to the Crown army's
  value, usually within one Raptor.
- Each army is handed to its own computer as an attack wave. So the fighting is the computers' own: the Crown's line,
  guns, rider screen and cavalry hit and run; the Brood's wave, its no-chase of riders, the Mist Toads' fog and tongue.
- One thing is taken away: retreat. When a computer pulls its wave back, the lab sends it in again. Every fight is fought
  to the end, so the result measures the fight, not the decision to leave it. (The Crown's computer wanted to pull back
  up to 20 times a fight, the Brood's up to 6; mostly once or twice.)
- The fight ends when one side has nothing left that fights, or three minutes after first contact. Most were over in 15
  to 25 seconds.
- Research by size: early, the Crown has the bayonet and the Brood nothing. Mid, the Crown adds the Matchlock, the
  Cavalry Charge, Prepared Charges and the Shot Pouch; the Brood has Pack Hunt and Long Spit. Late, the Crown adds Armour
  (Guardsmen and Cuirassiers), the Flintlock and the Gunner's Quadrant; the Brood adds Slither, Battering Horns, Fog,
  Miasma and Updraft.

### The score

Each fight gives one number: **the Crown's share of the value lost**. It is what the Brood lost, over what both sides
lost. 50 means an even trade. 70 means the Brood lost 70 of every 100 that died. Above 50 the Crown traded better.
A **win** is a fight where the other side has nothing left that fights (or is clearly behind at the bell).

Every pairing was fought 2 to 4 times with different seeds. A pairing is called for a side only when its 95% interval is
clear of 50. With so few fights a pairing, that is a strict test: many "even" pairings lean one way.

### The sizes

- **Early**: 600 value each (about 8 Musketeers, or 24 Raptors).
- **Mid**: 1,500 each.
- **Late**: 4,000 each (about 47 Guardsmen, or 160 Raptors).
- **At the cap**: each army as big as 150 supply allows, late research. Here the values are NOT equal: this is the late
  game, where supply, not money, is the limit.

### The grounds

- **Open field**: both armies march at each other on flat open ground (the middle of Dune Sea). Both computers fight.
- **Set line**: open ground, but the Crown stands ready, as a careful player sets it: a line two deep across the Brood's
  way, its guns unlimbered behind it, every man on HOLD, riders going at whatever comes near them. The Crown's computer
  has no say. The Brood comes at it.
- **Set block**: as the set line, but the Crown's foot stands in the close block it marches in on the open field, not in
  a line.
- **Choke**: a wall of rock right across the map with one gap six tiles wide. The Crown is set as on the set line, behind
  the gap. The Brood comes through it.
- **Ramp, the Crown on top**: a ramp out in the open on Jade Wilds, away from the bases. The Crown is set on the top as on
  the set line. The Brood comes up.
- **Ramp, the Brood on top**: the Brood's computer holds the top. The Crown's computer goes up at it.

### The compositions (shares of the army's value)

| Crown | | Brood | |
|---|---|---|---|
| M | Musketeers | R | Raptors |
| MC | Musketeers 75, Field Cannons 25 | R3S1 | Raptors 75, Spitters 25 |
| MCH | Musketeers 55, Cannons 30, Horsemen 15 (the computer's own wave) | R1S1 | Raptors 50, Spitters 50 |
| MMo | Musketeers 70, Mortars 30 | R1S3 | Raptors 25, Spitters 75 |
| MCMo | Musketeers 60, Cannons 20, Mortars 20 | S | Spitters |
| MH | Musketeers 70, Horsemen 30 | B | Brutes |
| H | Horsemen | RSB | Raptors 35, Spitters 45, Brutes 20 |
| D | Dragoons | TC | Tyrant Challengers |
| MD | Musketeers 70, Dragoons 30 | TCS | Tyrant Challengers 40, Spitters 60 |
| MO | Musketeers 70, Officers 30 | VC | Venom Challengers |
| MB | Musketeers 85, the band (Drummer, Fifer, Piper) | StC | Storm Challengers (flyers) |
| MMi | Musketeers 90, a Missionary | RSTd | Raptors 40, Spitters 45, Mist Toads 15 |
| CH | Cannons 60, Horsemen 40 | RSy | Raptors and Spitters with the Tyrant Sire (counted at his price, 150) |

Prices used (late, with Armour): Guardsman 85, Field Cannon 222, Mortar 214, Cuirassier 135, Dragoon 125, Officer 65,
Raptor 25, Spitter 47.5, Brute 170, Tyrant Challenger 110, Venom Challenger 170, Storm Challenger 180, Mist Toad 125,
Tyrant Sire 150. Early the Musketeer is 73 and the Horseman 105. Not in the lab: Pikemen (campaign only), the Balloon (it
does not fight), Hatchlings (they bite only flyers), Skywings (retired), the Storm and Venom Sires.

## The open field: the whole matrix at mid size (1,500 each)

Each cell is the Crown's score (its share of the value lost; 50 is even), then the Crown's wins out of four fights.
**Bold**: the Crown clearly ahead. *Italic*: the Brood clearly ahead. The last column is the row's average; the last row
is the column's average (low = good for that Brood composition). The other sizes and grounds are in
`docs/battle_matrix/tables.md`.

| Crown \ Brood | R | R3S1 | R1S1 | R1S3 | S | B | RSB | TC | TCS | VC | StC | RSTd | RSy | row |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **M** | *28 (0/4)* | **63 (4/4)** | 59 (3/4) | 62 (3/4) | *33 (0/4)* | **84 (4/4)** | **70 (4/4)** | **88 (4/4)** | **76 (4/4)** | *10 (0/4)* | **91 (4/4)** | 68 (3/4) | *35 (0/4)* | 59 |
| **MC** | 44 (1/4) | 36 (1/4) | 43 (1/4) | 44 (1/4) | *32 (0/4)* | *33 (0/4)* | 43 (1/4) | 55 (2/4) | 46 (1/4) | *16 (0/4)* | 69 (3/4) | 56 (3/4) | *34 (0/4)* | 42 |
| **MCH** | **72 (4/4)** | **70 (4/4)** | 59 (3/4) | 45 (1/4) | *36 (0/4)* | 69 (3/4) | 44 (1/4) | 64 (3/4) | **68 (4/4)** | **79 (4/4)** | **82 (4/4)** | **66 (4/4)** | *33 (0/4)* | 61 |
| **MMo** | *15 (0/4)* | *28 (0/4)* | *37 (0/4)* | *31 (0/4)* | *15 (0/4)* | *34 (0/4)* | *27 (0/4)* | 38 (0/4) | *38 (0/4)* | *5 (0/4)* | 68 (3/4) | *41 (0/4)* | *31 (0/4)* | 31 |
| **MCMo** | *12 (0/4)* | 27 (1/4) | *35 (0/4)* | *38 (0/4)* | *29 (0/4)* | 33 (1/4) | *34 (0/4)* | 44 (1/4) | 44 (1/4) | *8 (0/4)* | 64 (3/4) | 44 (1/4) | *31 (0/4)* | 34 |
| **MH** | **78 (4/4)** | **88 (4/4)** | **84 (4/4)** | 57 (2/4) | **79 (4/4)** | **84 (4/4)** | 56 (2/4) | **89 (4/4)** | **75 (4/4)** | **88 (4/4)** | **95 (4/4)** | **81 (4/4)** | *37 (0/4)* | 76 |
| **H** | *22 (0/4)* | *27 (0/4)* | 49 (2/4) | 43 (0/4) | 64 (3/4) | *28 (0/4)* | 56 (2.5/4) | **75 (4/4)** | **75 (4/4)** | *5 (0/4)* | *0 (0/4)* | 47 (1/4) | *34 (0/4)* | 40 |
| **D** | *0 (0/4)* | *2 (0/4)* | *3 (0/4)* | *5 (0/4)* | *6 (0/4)* | *16 (0/4)* | *10 (0/4)* | *4 (0/4)* | *27 (0/4)* | *0 (0/4)* | *11 (0/4)* | *10 (0/4)* | *4 (0/4)* | 8 |
| **MD** | *18 (0/4)* | *33 (0/4)* | *40 (0/4)* | 41 (0/4) | *10 (0/4)* | 38 (1/4) | *36 (0/4)* | *40 (0/4)* | *26 (0/4)* | *10 (0/4)* | **74 (4/4)** | **67 (4/4)** | *31 (0/4)* | 36 |
| **MO** | *29 (0/4)* | **66 (4/4)** | **70 (4/4)** | 36 (1/4) | *25 (0/4)* | **85 (4/4)** | 61 (3/4) | **80 (4/4)** | 64 (3/4) | *8 (0/4)* | **93 (4/4)** | **84 (4/4)** | *36 (0/4)* | 57 |
| **MB** | *25 (0/4)* | 47 (1/4) | 48 (1/4) | *35 (0/4)* | *28 (0/4)* | **75 (4/4)** | 48 (1/4) | **82 (4/4)** | **72 (4/4)** | *6 (0/4)* | **89 (4/4)** | 63 (3/4) | *40 (0/4)* | 51 |
| **MMi** | *25 (0/4)* | 56 (2/4) | 52 (1/4) | *41 (0/4)* | *36 (0/4)* | **73 (4/4)** | 53 (2/4) | **77 (4/4)** | 56 (2/4) | *8 (0/4)* | **86 (4/4)** | **73 (4/4)** | *35 (0/4)* | 52 |
| **CH** | 75 (3/4) | 56 (1/4) | 41 (1/4) | *38 (0/4)* | 44 (1/4) | *0 (0/4)* | *33 (0/4)* | 48 (2/4) | *31 (0/4)* | *18 (0/4)* | *5 (0/4)* | 52 (1.5/4) | *34 (0/4)* | 36 |
| **column** | 34 | 46 | 48 | 40 | 34 | 50 | 44 | 60 | 54 | 20 | 64 | 58 | 32 |  |

How to read a row: the Crown's computer wave (MCH) beats Raptors (72), Raptors with a few Spitters (70), Venom
Challengers (79) and flyers (82), leans its way against the half-and-half mix (59), and loses to Spitters alone (36) and to
the Sire (33). Musketeers with Horsemen (MH) beat everything but the Sire.

## What counters what

### Against each Brood army, the Crown's best answer (open field)

| Brood army | early (600) | mid (1,500) | late (4,000) | Crown armies that beat it clearly, mid and late | Crown armies it beats clearly, mid and late |
|---|---|---|---|---|---|
| R Raptors | MO 79, M 74 | MH 78, CH 75 | CH 98, MCH 61 | MCH | MMo, H, D, MD, MB |
| R3S1 Raptors, some Spitters | MO 95, M 86 | MH 88, MCH 70 | CH 79, MH 69 | M, MCH, MH, MO | H, D |
| R1S1 Raptors and Spitters | M 87, MO 79 | MH 84, MO 70 | CH 70, MO 69 | MH, MO | MMo |
| R1S3 Spitters, some Raptors | CH 74, M 72 | M 62, MH 57 | MCH 68, MH 62 | none | D |
| S Spitters | MCH 74, M 63 | MH 79, H 64 | MH 85, MCMo 62 | MH | M, D, MD, MB, MMi |
| B Brutes | MO 82, M 80 | MO 85, MH 84 | MH 97, MO 96 | M, MH, MO, MB, MMi | D |
| RSB Raptors, Spitters, Brutes | M 78, MMi 64 | M 70, MO 61 | MO 76, MB 69 | M | MMo, MCMo, D, MD |
| TC Tyrant Challengers | MO 88, MB 84 | MH 89, M 88 | CH 97, MH 88 | M, MH, MO, MB, MMi | D |
| TCS Tyrant Challengers, Spitters | M 76, MO 74 | M 76, MH 75 | MH 80, MO 76 | M, MCH, MH, MB | D, MD |
| VC Venom Challengers | MCH 81, MO 54 | MH 88, MCH 79 | MH 92, CH 89 | MCH, MH | M, MC, MMo, MCMo, H, D, MD, MO, MB, MMi |
| StC Storm Challengers (flyers) | M 87, MO 79 | MH 95, MO 93 | MH 94, M 88 | M, MCH, MH, MD, MO, MB, MMi | H, D, CH |
| RSTd with Mist Toads | MO 100, M 94 | MO 84, MH 81 | MCH 82, MO 79 | MCH, MH, MD, MO | D |
| RSy with the Tyrant Sire | MB 41, MO 38 | MB 40, MH 37 | MO 62, MH 56 | none | M, MC, MCH, MMo, MCMo, H, D, MD, MB, MMi |

### Against each Crown army, the Brood's best answer (open field; the Brood's own share)

| Crown army | early (600) | mid (1,500) | late (4,000) |
|---|---|---|---|
| M Musketeers | VC 83, RSy 66 | VC 90, R 72 | VC 86, S 61 |
| MC Musketeers, Cannons | VC 94, RSy 77 | VC 84, S 68 | VC 70, RSy 64 |
| MCH the computer's wave | Brutes 75, RSy 70 | RSy 67, S 64 | RSy 61, S 54 |
| MMo Musketeers, Mortars | VC 100, StC 82 | VC 95, R 85 | VC 94, R 72 |
| MCMo Musketeers, Cannons, Mortars | Brutes 100, StC 100 | VC 92, R 88 | RSB 70, VC 66 |
| MH Musketeers, Horsemen | VC 94, Brutes 79 | RSy 63, RSB 44 | R 45, RSy 44 |
| H Horsemen | Brutes 100, StC 100 | StC 100, VC 95 | StC 100, VC 92 |
| D Dragoons | anything (100) | anything (100) | anything (99) |
| MD Musketeers, Dragoons | VC 100, S 93 | S 90, VC 90 | VC 94, S 73 |
| MO Musketeers, Officers | RSy 62, VC 46 | VC 92, S 75 | VC 91, R 52 |
| MB Musketeers, the band | VC 94, R 61 | VC 94, R 75 | VC 86, S 72 |
| MMi Musketeers, a Missionary | VC 100, S 73 | VC 92, R 75 | VC 88, S 67 |
| CH Cannons, Horsemen | Brutes 94, StC 94 | Brutes 100, StC 95 | StC 69, S 60 |

### The counters in plain words

- **Riders counter Venom Challengers and Spitters.** Venom Challengers beat every Crown army but the two with Musketeers
  and Horsemen, often by 9 to 1. Against those two (MCH, MH) they lose badly at mid and late (79 to 92 for the Crown).
  Spitters alone beat the plain musket line (33 at mid) but lose to Musketeers with Horsemen (79). The riders' hit and
  run gets in among shooters.
- **The musket line counters Brutes, Tyrant Challengers and flyers.** Brutes and Tyrant Challengers lose to Musketeers
  alone and to Musketeers with Officers, Horsemen or the band (75 to 97); Musketeers with guns in the open do less well.
  Storm Challengers (the flyers) lose to every army with Musketeers (64 to 95) and beat only the armies without them
  (Horsemen, Dragoons, Cannons with Horsemen: the Horsemen cannot hit flyers).
- **Raptors counter the slow and the stuck.** Raptors beat Mortars, Dragoons, Horsemen alone and the band's army; they
  lose to the computer's wave (Musketeers, Cannons, Horsemen) and to Cannons with Horsemen.
- **Brutes counter guns with nobody in front of them.** Cannons with Horsemen lose every early and mid fight to Brutes
  (6 and 0); late, with Armour and the Quadrant, the same army wins (93).
- **The Tyrant Sire counters everything** at early and mid sizes: no Crown army clearly beats a Raptor and Spitter wave
  with him at its head. Only late do Musketeers with Officers (62) or with Horsemen (56) get the better of it.

## The best composition for each side

| ground, size | best Crown army on average (score) | the safest Crown army (its worst matchup) | best Brood army on average (its share) | the safest Brood army (its worst matchup) |
|---|---|---|---|---|
| open, early | MO 73, M 72, MCH 58 | MO (38) | VC 85, RSy 73, S 69 | RSy (59) |
| open, mid | MH 76, MCH 61, M 59 | MH (37) | VC 80, RSy 68, S 66 | RSy (60) |
| open, late | MH 76, CH 67, MCH 67 | MH (55) | VC 69, RSy 61, S 59 | RSy (38) |
| at the cap (equal supply) | MH 79, MCH 72, M 71 | MCH (59) | VC 66, S 52, StC 44 | R1S3 (31) |

**If both sides pick blind.** Treat the matrix as a game where each side picks its army without seeing the other, and
each mixes its choices as well as it can. The value of that game is the Crown's fair share of a fight at equal value:

| ground, size | the Crown's share, the Sire allowed | the Crown's best mix | the Brood's best mix | the Crown's share, the Sire left at home | the Crown's best mix | the Brood's best mix |
|---|---|---|---|---|---|---|
| open, early | 39 | MO 68, MB 32 | Sire 94, VC 6 | 57 | MO 60, MCH 27, M 12 | RSB 49, VC 33, R1S3 18 |
| open, mid | 39 | MB 60, MH 40 | Sire 97, VC 3 | 59 | MH 62, M 38 | R1S3 93, VC 7 |
| open, late | 57 | MH 46, MO 41, CH 12 | Sire 82, R 14, VC 4 | 61 | MH 37, MCH 28, MO 22, CH 13 | R1S3 49, RSB 34, R 13, S 4 |
| at the cap (equal supply) | 68 | MH 44, MCH 38, MMi 19 | R1S3 94, StC 3, VC 3 | 68 | the same | the same |

So with the Sire at home, a careful Crown player at equal value should get about 57 to 61 of every 100 lost in a field
fight. The Brood's best blind picks are Spitter-heavy mixes and Venom Challengers; the Crown's are Musketeers with
Officers early and Musketeers with Horsemen later.

### Can the Crown win fights at equal value at all?

Yes, and more often than not with the right army. In the open at 4,000 the Crown is clearly ahead in 72 pairings and the
Brood in 50; at the cap it is 72 to 11. Where it cannot: early (600), against the Sire, against Venom Challengers
without riders, and with Dragoons or Mortars as a big part of the army.

### Does any army beat everything?

- **The Brood with the Tyrant Sire** out-trades every Crown army in the open at 600 and 1,500, clearly against every
  one. He is one unit a game and the Brood computer keeps him at home against the Crown, but a human Brood player could
  walk him with the wave. At 150 food he is the cheapest fighting value in the game. A balance question for the owner.
- **No other Brood army** beats every Crown army. Venom Challengers come closest: they beat 10 of the 13 Crown armies at
  mid and late, but riders beat them.
- **Musketeers with Horsemen** out-trade every Brood army in the open late (the Sire too, 56), though not all of them
  clearly. No Crown army beats everything early or mid.

## At the cap: equal supply, not equal value

Late in a real game, supply is the limit, not money. So the lab also fought each pairing with both armies as big as 150
supply allows (late research; two seeds a pairing). Here the values are not equal, and that is the point: a Raptor is 25
for one supply and a Guardsman 85, so at equal supply the Crown's army is worth about twice the Brood's (about 10,000 to
12,750 against 3,750 to 5,900 for the Raptor and Spitter mixes).

The Crown won **286 of the 338 fights**: clearly ahead in 72 pairings, the Brood in 11, and the mean score was 64. Only
Venom Challengers (85 a supply, as dear as a Guardsman) and Spitters held their own. Musketeers with Horsemen scored 79 on
average; the computer's wave 72.

This is NOT how the real games look. In the Crown-against-Brood games of the crown-brood-late job
(docs/crown_brood_late.md), at 16:00 the Crown's army was worth 2,305 and the Brood's 2,485. Neither side had a capped
army of soldiers: the Crown stood at about 116 supply, 46 to 57 of it labourers, held back by gold and powder (that job's
finding); and the Brood's Rootmaws and Mound Turtles cost it no army supply. So the real late fights are close to the
lab's EQUAL VALUE fights at 1,500 to 4,000, not to its equal supply fights.

## The fighting or the numbers

To tell a fighting (micro) problem from a numbers problem, the same armies were fought three ways on the same open
ground: **open** (the Crown's computer marches and fights), **set line** and **set block** (the Crown stands ready, set by
hand: guns unlimbered, every man on HOLD, the computer has no say). The block keeps the open field's close formation, so
set line against set block tells the formation from the rest.

| Crown army | open, 600 | set line | set block | open, 1,500 | set line | set block | open, 4,000 | set line | set block |
|---|---|---|---|---|---|---|---|---|---|
| M | 72 | 49 | 49 | 59 | 41 | 42 | 61 | 45 | 52 |
| MC | 36 | 43 | 42 | 42 | 57 | 59 | 56 | 78 | 76 |
| MCH | 58 | 44 | 44 | 61 | 58 | 61 | 67 | 73 | 72 |
| MMo | 30 | 31 | 34 | 31 | 46 | 45 | 47 | 69 | 60 |
| MCMo | 12 | 30 | 27 | 34 | 41 | 43 | 54 | 71 | 69 |
| MH | 45 | 44 | 45 | 76 | 40 | 41 | 76 | 45 | 48 |
| H | 28 | 24 | 26 | 40 | 25 | 26 | 36 | 27 | 26 |
| D | 0 | 8 | 9 | 8 | 15 | 15 | 8 | 24 | 24 |
| MD | 29 | 29 | 27 | 36 | 32 | 33 | 47 | 42 | 45 |
| MO | 73 | 34 | 35 | 57 | 34 | 36 | 66 | 46 | 44 |
| MB | 55 | 31 | 35 | 51 | 39 | 40 | 54 | 43 | 49 |
| MMi | 51 | 40 | 36 | 52 | 40 | 40 | 58 | 43 | 50 |
| CH | 35 | 46 | 49 | 36 | 69 | 68 | 67 | 72 | 72 |

What it says:

1. **The guns are the Crown's fighting problem.** Every army with guns does much better with them set up: Musketeers with
   Cannons 42 against 57 to 59 at mid, 56 against 76 to 78 late; Cannons with Horsemen 36 against 68 to 69 at mid; the
   Mortar armies 31 to 34 against 41 to 46 at mid and 47 to 54 against 60 to 71 late. In the open, the computer had
   **none** of its 3,627 guns set when the fight began (in 832 fights), and only 34% to 61% ten seconds in. It marches
   its guns limbered at the back of the wave; by the time they are up, the Raptors are on the line. Guns not set are
   often worse than no guns: Musketeers alone beat Musketeers with Cannons in the open at every size.
2. **The formation is not the problem.** The set line and the set block score within a few points of each other almost
   everywhere. Two deep or in a block, a static Crown army does the same.
3. **The computer's own foot and rider fighting is good.** Armies with no guns do clearly WORSE when set by hand and left
   on HOLD than when the computer fights them: Musketeers 59 against 41, Musketeers with Officers 57 against 34, Musketeers
   with Horsemen 76 against 40 at mid. HOLD keeps men from closing up and helping each other, and riders on HOLD lose their
   hit and run. The Crown computer's rider micro (AICavMicro) is worth the most: with it, Musketeers with Horsemen are
   the best Crown army in the open; without it, they are ordinary.
4. **Dragoons are a fighting problem too, but mostly a design one.** As an army they score 0 to 28 in the open (35 at
   the cap). They ride into the swarm, take 0.8 seconds to get off, and fire a third slower; at 121 to 125 each
   they cost a Musketeer and a half. Mixed in (MD) they still pull the score down.
5. **Officers are cheap and good per coin.** Musketeers with Officers are the best Crown army early (73) and good later.
   The Officer costs 65 here (60 gold and his pistol's powder), less than a Musketeer, with 80 health, armour, a pistol
   and a sabre. But he takes 3 supply, so at the cap he is dear: there Musketeers with Officers fall to 60, below plain
   Musketeers (71).

### The films (docs/shots/battle_matrix/)

- **The guns, open and set.** `MC_R1S1_4000_open_s0_00/01.jpg`: the same late army (Musketeers with five Cannons) against
  Raptors and Spitters. The computer marches in a long bent column, the guns limbered at its tail; the Raptors hit the
  head of the column before a gun is up. The Crown lost everything (4,000) for 2,000 of Raptors; score 33.
  `MC_R1S1_4000_set_s0_00/01.jpg`: the same armies, the Crown set: a line two deep, five guns up behind it. The Raptors
  die in a stream in front of the line and the Spitters never close. The Crown lost 8 Musketeers (680) for the whole
  Brood army (3,995); score 86.
- **Riders against Venom Challengers.** `MH_VC_1500_open_s0_01.jpg`: Horsemen ride into the Venom Challengers from both
  flanks while the line shoots; 9 of 9 killed for 2 men lost (score 89). `M_VC_1500_open_s0_01.jpg`: the same Brood army
  against Musketeers alone; the line shuffles to re-form under fire and loses 19 men for one Challenger (score 10).
- **The Tyrant Sire.** `MCH_RSy_1500_open_s0_01.jpg`: the Sire walks into the line ahead of his Raptors and takes the
  volleys; the computer's wave is gone in 22 seconds for half the Brood army (score 35).
- **Dragoons.** `D_R1S1_1500_open_s0_00/01.jpg`: twelve Dragoons ride into the Raptors, get off among them and die; 3
  Raptors killed (score 5).

## The grounds compared

Every ground at every size (the score's mean over all 169 pairings; the blind-pick value with the Sire at home; the
best three armies of each side on average):

| ground | size | fights | mean score | pairings the Crown wins clearly / the Brood / even | blind pick, the Crown's share (Sire at home) | best Crown armies | best Brood armies |
|---|---|---|---|---|---|---|---|
| open field | 600 | 676 | 40 | 27 / 84 / 58 | 57 | MO 73, M 72, MCH 58 | VC 85, RSy 74, S 69 |
| open field | 1500 | 676 | 45 | 40 / 78 / 51 | 59 | MH 76, MCH 60, M 59 | VC 80, RSy 68, S 66 |
| open field | 4000 | 676 | 54 | 72 / 50 / 47 | 61 | MH 76, CH 67, MCH 67 | VC 69, RSy 61, S 59 |
| the set line (open ground, the Crown formed, guns up) | 600 | 507 | 35 | 17 / 85 / 67 | 21 | M 49, CH 46, MH 44 | B 92, VC 86, TCS 78 |
| the set line (open ground, the Crown formed, guns up) | 1500 | 507 | 41 | 28 / 91 / 50 | 34 | CH 69, MCH 58, MC 57 | VC 88, B 73, S 71 |
| the set line (open ground, the Crown formed, guns up) | 4000 | 507 | 52 | 69 / 74 / 26 | 62 | MC 78, MCH 73, CH 72 | VC 72, S 58, RSy 53 |
| the set block (open ground, the Crown in a close block, guns up) | 600 | 338 | 35 | 10 / 56 / 103 | 25 | M 49, CH 49, MH 45 | B 93, VC 92, TCS 75 |
| the set block (open ground, the Crown in a close block, guns up) | 1500 | 338 | 42 | 16 / 49 / 104 | 35 | CH 68, MCH 61, MC 59 | VC 88, B 72, S 68 |
| the set block (open ground, the Crown in a close block, guns up) | 4000 | 338 | 53 | 45 / 35 / 89 | 66 | MC 76, CH 72, MCH 72 | VC 69, S 57, RSy 54 |
| a choke | 600 | 338 | 34 | 9 / 55 / 105 | 25 | M 51, CH 47, MH 42 | B 91, VC 90, TCS 77 |
| a choke | 1500 | 507 | 41 | 27 / 93 / 49 | 38 | CH 67, MC 57, MCH 57 | VC 86, B 74, S 70 |
| a choke | 4000 | 338 | 53 | 43 / 52 / 74 | 65 | MC 80, MCH 75, CH 72 | VC 72, S 57, RSy 52 |
| a ramp, the Crown on top | 600 | 338 | 37 | 13 / 56 / 100 | 35 | MH 54, M 51, CH 48 | B 89, VC 82, RSy 77 |
| a ramp, the Crown on top | 1500 | 507 | 46 | 31 / 73 / 65 | 36 | CH 68, MC 64, MCH 62 | VC 86, B 68, RSy 67 |
| a ramp, the Crown on top | 4000 | 338 | 55 | 48 / 41 / 80 | 76 | MC 85, MCH 79, MCMo 78 | VC 65, S 51, RSy 50 |
| a ramp, the Brood on top | 600 | 338 | 38 | 8 / 59 / 102 | 53 | MO 73, M 67, MB 54 | VC 84, RSy 84, TCS 76 |
| a ramp, the Brood on top | 1500 | 507 | 55 | 55 / 42 / 72 | 43 | MO 73, M 72, MMi 67 | VC 85, RSy 68, R 50 |
| a ramp, the Brood on top | 4000 | 338 | 57 | 47 / 16 / 106 | 52 | MO 70, M 69, MMi 66 | VC 65, RSy 55, S 54 |

What the grounds add, compared like for like:

- **The choke changes nothing at equal value.** The Crown set behind a 6-tile gap scores the same as the Crown set on
  open ground (34 against 35 early, 41 against 41 at mid, 53 against 52 late). The Brood's swarm comes through the gap
  in a stream, but the Crown's line on HOLD cannot make use of it.
- **The high ground helps the Crown a little.** Set on a ramp's top, the Crown scores 2 to 5 points more than set on flat
  ground (37 against 35, 46 against 41, 55 against 52). The guns gain most: Musketeers with Cannons go from 78 to 85 late.
- **The Brood holding a ramp's top is weak, but that is its computer, not the hill.** Going up at the Brood, the Crown's
  computer scores 55 at mid against 45 on flat open ground. The Brood's creatures, told to hold a spot, seem to come
  down in ones and twos instead of as one wave (not filmed). Many of these fights ran to the bell (74 of 507 at
  mid) with the Brood's computer pulling back again and again. Read it as "the Brood should not sit on a hill and wait", not as a fact about
  hills.
- **The same armies come out on top everywhere:** Venom Challengers for the Brood (and Brutes early against a Crown set
  by hand), and
  for the Crown the gun armies (MC, MCH, CH) wherever the Crown stands ready, Musketeers with Horsemen or Officers wherever
  its computer fights.

## What this matrix can and cannot say about the Rootmaw bonus

The Rootmaw bonus (Defs.FOOD_BONUS, the far Rootmaws' pay) is an ECONOMY number. This lab has no economy. So it cannot
say whether the bonus is too big. It can only say whether the Brood's fights are too good, which is the other place a
lopsided matchup could come from.

What it does say:

- **A coin of Brood does not beat a coin of Crown.** At equal value, with the armies the computers actually build, the
  Crown's wave beats the Brood's Raptor and Spitter waves and its Tyrant Challengers at every size (58 to 73). With the
  best armies on both sides picked blind, the Crown's fair share is 57 to 61 (the Sire at home). The Crown's army gets
  better per coin as it grows.
- **In the real games the armies are about equal in value.** At 12:00 in the crown-brood-late games the Crown's army
  was worth 2,221 and the Brood's 1,821; at 16:00, 2,305 and 2,485; the incomes earned were about equal at 16:00
  (20,500 and 20,350). Equal armies, equal income, and an army that trades better at equal value: by the numbers of this
  lab, the Crown should win those fights more often than it loses them. In the games it loses the matchup (the
  championship: the Brood beat the Crown in 97% of games).
- **So the gap lies in what the lab takes away, not in the units' numbers:**
  1. *How the fights are fought*: the Crown's guns are never set when a fight starts, and an army with guns not set
     trades 15 to 20 points worse than the same army ready. The computer's waves also pull back (often, up to 20 times
     a fight here) where the lab sent them in again.
  2. *Which armies are brought*: the Crown computer's armies are gun-heavy (its usual wave of 12 Musketeers, 3 Cannons
     and 2 Horsemen is about a third guns by value) and rider-light; the lab's best Crown army is Musketeers with
     Horsemen.
  3. *Where and when the fights happen*: reinforcements arriving one by one, fights at the Crown's outlying halls,
     labourers caught walking (docs/crown_brood_fix.md: 83% of labourers lost after 12:00 die to Raptors). None of these
     are in the lab.
  4. *Remaking the army and the supply it takes*: how fast each side refills after a fight, and the supply: in the
     crown-brood-late games much of the Crown's supply was labourers late, while the Brood's Rootmaws and Mound Turtles
     cost it no army supply. Not measured here.
- **The honest verdict for the owner's question:** this matrix gives **no evidence** that the Brood's fighting is the
  problem, and it shows a clear Crown fighting problem (the guns). It does **not** prove that the Rootmaw bonus is fine:
  it cannot see the economy. To be "100% sure" about the Rootmaw bonus, the next step is to fix the guns at contact (and
  measure games again), then compare the bonus at 1.2 and 1.0 with the fighting held the same. If the Crown still loses
  with its guns set and its armies at equal value, the economy is the next suspect.

## What the lab leaves out (limits)

- No economy, no production, no reinforcements, no scouting before the fight: two whole armies meet at once.
- No retreat: every fight is fought to the end. A real computer pulls back from a losing fight and keeps what is left.
- The holding side on the choke and the ramp's top (when it is the Crown) is set by hand and left on HOLD, without its
  computer; that makes it weaker than the computer's own fighting with foot and riders (see the set line), so the grounds
  where the Crown holds understate it. When the Brood holds the ramp's top, its computer keeps it on the spot, and its
  creatures come down in ones and twos rather than as a wave, which understates the Brood there.
- One map for the open, the set and the choke grounds (Dune Sea's middle), one ramp (Jade Wilds).
- Two to four fights a pairing. The big differences are clear; many small ones are not (see the bold and italic cells).
- Values are counted one for one across resources. A side whose resource is scarcer (the Crown's powder, the Brood's
  spoils) would value its units differently; and the Tyrant Sire is counted at his food price (150), not at what he is
  worth to the Brood as its father.
- The research by size is one plausible set, not what every game has.

## Claude's choices (for the owner to check)

1. **Equal value counts every resource one for one** (gold = food = powder = spoils), with the horse in a rider's or a
   gun's price and the powder load in a soldier's. The game has no exchange rate; this is the simplest fair count.
2. **No retreat**: the lab sends a pulled-back wave in again, so a fight measures the fight, not the decision to leave.
3. **The Brood army is matched to the Crown army's actual value** (the Crown's whole units make its value a little off
   the round number).
4. **The score is the Crown's share of the value lost**, not the win: a fight won at a terrible price is not a good fight.
   Wins are shown beside it.
5. **The holding Crown (set, block, choke, the ramp's top) is set by hand, not by its computer.** The computer's line code
   wants a march's end, not a spot to hold, and with it on, it limbered the guns again and walked the men off the spot.
6. **The Tyrant Sire is counted at his price (150)** and fought with a Raptor and Spitter wave (RSy), as a human Brood
   player could; the Brood computer does not do it against the Crown. The blind-pick value is given with and without him.
7. **The research by size** (see the method): early bayonet only; mid the first locks, the Cavalry Charge, Prepared
   Charges, the Shot Pouch, Pack Hunt and Long Spit; late everything that bears on a field fight.
8. **Equal supply at 150 army supply each**, not 200: both sides keep some supply for workers in a real game.
9. **Compositions not tried**: Pikemen (campaign only), the Balloon (no weapon), Hatchlings (bite only flyers), the
   Storm and Venom Sires as fighters, more than one Sire.

## Proposals (nothing changed; for the owner to decide)

1. **The Crown computer's guns at contact** (an AI change, not a number): unlimber the guns as soon as the screen or
   the line sees the enemy coming, and march the guns nearer the head of the wave. Worth 15 to 20 points of score in
   these fights. (The crown-brood-late job's `cblguns` part already tries a version of this: guns set at contact away from
   home went from 6% to 68% there, and fights traded 1.25 against 1.01.)
2. **More riders in the Crown computer's armies against the Brood**: Musketeers with Horsemen (70/30) is the best Crown
   army in the open at mid and late, and riders are the only answer to Venom Challengers and Spitters.
3. **Fewer Mortars and no Dragoon armies against the Brood in the field**: both trade badly here.
4. **Balance questions** (numbers, owner's call): the Tyrant Sire as a fighter at 150 food; Venom Challengers against
   riderless Crown armies; the Dragoon as a fighting unit; the Officer's price per supply against his price per coin.
5. **Before touching the Rootmaw bonus**: fix (1), then measure Crown v Brood games again with the bonus at 1.2 and at
   1.0, as the owner asked, with the fighting held the same.

## Reproduce

    python3 tools/study/battle_lab.py jobs --sizes 1500,600,4000 --grounds open --seeds 4 > jobs.txt
    python3 tools/study/battle_lab.py run jobs.txt --workers 2 --chunk 30      # (resumes; rows to docs/battle_matrix/data/rows.jsonl)
    python3 tools/study/battle_lab.py report                                   # (docs/battle_matrix/tables.md)
    python3 tools/study/battle_matrix_report.py                                # (docs/battle_matrix/analysis.md)
    godot --headless --fixed-fps 30 --path . --script res://tools/battle_lab.gd -- crown:MCH brood:R1S1 size:1500 ground:open seed:0 [debug]
    xvfb-run -a godot --rendering-driver opengl3 --resolution 1024x576 --fixed-fps 30 --path . --script res://tools/battle_lab.gd -- \
        jobs:/abs/films.txt shots:/abs/dir nshots:4 shotgap:4                   # (pictures of the fights)

Ground jobs: `--grounds open,set,block,choke,up,down`; sizes 600, 1,500, 4,000 and -150 (equal supply, 150 each).
All fights ran on version 0.38.208 on a 2-core cloud machine (about 4 to 8 seconds a fight).
