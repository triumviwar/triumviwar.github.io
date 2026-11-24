# World War: the tuning pass (job world-war-tune)

The owner said "Yes" to Claude choosing the changes; he checks them after. This page says what changed, why, and what
the computer wars showed before and after. Every number is in `scripts/worldwar/ww_rules.gd` (WWRules).

## In short

- Three-side wars are near even now. Each side wins about a third.
- Two-side wars are close now for every pairing. The Crown used to win almost all of them.
- No side runs away any more when there is no last season.
- Less of the world is left free at the end.
- NOT DONE: wars still end at the last season, by the most land. Capitals fall more often, but the third side
  (most often the Brood, across the sea) is rarely finished off. See "What is left".
- A war saved before this pass keeps its old rules to its end. The old numbers are kept in the code (WWRules.V1).

## How it was measured

- `tools/sim_world_war_tune.gd`: computer wars, every battle decided at once, summed up in one line.
- `tools/study/ww_tune.sh`: one "arm" = 100 wars in each of five setups: three sides, the three two-side pairings,
  and three sides with no last season (stopped at season 120).
- Normal computers, take the capitals, 48 seasons, story heroes on.
- The same seeds for every arm (1000-1099), so two arms differ only by the rules. The final arms were run again on
  a second set of seeds (3000-3099) to check the result was not luck.
- A tuning arm can change any number without touching the code: `tune=GUARD:250,BIOME_INCOME.brood.temperate:0.9`.
  `tune=v1` plays the old rules.
- Raw lines: `docs/world_war_tune/before.txt`, `after.txt`, `levels_and_keys.txt`.

## Before and after

### Three sides, 48 seasons (who won, of 100)

| seeds | rules | the Crown | the Clockwork | the Brood |
| --- | --- | --- | --- | --- |
| 1000-1099 | before | 26 | 30 | 44 |
| 1000-1099 | after | 43 | 28 | 29 |
| 3000-3099 | before | 28 | 38 | 34 |
| 3000-3099 | after | 35 | 29 | 36 |
| both | before | 27 | 34 | 39 |
| both | after | **39** | **28.5** | **32.5** |

The goal was 28-38 each. The Crown is one point over, the others in.

### Two sides, 48 seasons (who won, of 100)

| pairing | seeds | before | after |
| --- | --- | --- | --- |
| Crown v Clockwork | 1000 | Crown 95 - 5 | Crown 48 - 52 |
| Crown v Clockwork | 3000 | Crown 96 - 4 | Crown 50 - 50 |
| Crown v Brood | 1000 | Crown 100 - 0 | Crown 60 - 40 |
| Crown v Brood | 3000 | Crown 97 - 3 | Crown 49 - 51 |
| Clockwork v Brood | 1000 | Clockwork 19 - 81 | Clockwork 55 - 45 |
| Clockwork v Brood | 3000 | Clockwork 14 - 86 | Clockwork 62 - 38 |

The goal was 40-60. Both seed sets together: 49, 54.5 and 58.5. One run of Clockwork v Brood (62) is just over.

### No last season (three sides, stopped at season 120)

| seeds | rules | still at war | the Crown won | the Clockwork won | the Brood won | most land one side held, on average |
| --- | --- | --- | --- | --- | --- | --- |
| 1000 | before | 68 | 25 | 0 | 7 | 75% of all held land |
| 1000 | after | 87 | 7 | 3 | 3 | 61% |
| 3000 | before | 75 | 20 | 0 | 5 | 69% |
| 3000 | after | 92 | 6 | 1 | 1 | 58% |

Before, the Crown ran away when the war had no end. Now no side does.

### How wars end, and the land left free (three sides, 48 seasons, seeds 1000)

| | before | after |
| --- | --- | --- |
| won by taking every capital | 3 | 3 |
| won by the most land at the last season | 97 | 97 |
| capitals taken (in 100 wars) | 37 | 62 |
| free regions at the end (of 60) | 29.8 | 21.3 |
| free land's worth at the end | 51.7 | 34.7 |

In two-side wars a quick conquest used to be common, and it was always the Crown. Now two-side wars are fought to the
last season more often (the Crown v the Clockwork: a capital fell in 76 of 100 before, 20 now, and both sides lost
theirs).

### Other levels and the key regions (three sides, seeds 1000)

| setup | before | after |
| --- | --- | --- |
| Hard computers | Crown 19, Clockwork 33, Brood 48 | Crown 33, Clockwork 26, Brood 41 |
| Easy computers | Crown 36, Clockwork 38, Brood 26 | Crown 27, Clockwork 42, Brood 31 |
| hold 8 key regions | Crown 23, Clockwork 25, Brood 52 (22 ended by keys) | Crown 25, Clockwork 12, Brood 63 (71 ended by keys) |

Key-region wars now end by keys most of the time. But the Brood wins too many: nine of the fifteen keys are on its side
of the sea (the Amazon, Rio, Luanda, the Cape, Goa, Canton, Nagasaki, New Spain, Virginia). That needs a map change,
not a number (choice 14).

## What changed, and why

### What the old wars showed

- THE SEA MADE THE CROWN'S WORLD SMALL. Rome has a sea lane to Lisbon, and Lisbon has lanes everywhere. Rio and
  Luanda were only two steps from Rome, so the Crown paid no far-land upkeep and got no far-land unrest anywhere.
- AN OWN REGION WAS EMPTY. A held region's guard was its worth x 100 (200 for a worth-2 region), less than free
  militia (650). Wars were armies walking into each other's empty provinces, back and forth.
- THE BROOD NEVER BUILT. The computer raised soldiers until it had what it wanted, and only then built. The Brood's
  cheap armies never got there, so it never built a Nest or a Swamp.
- THE AI GANGED UP ON THE WRONG SIDE. In a two-side war "the side with the most land" was always the enemy, even
  when it was smaller, so the Crown sailed to Brazil and fought the Brood there instead of growing.
- THE CROWN COULD LIVE ANYWHERE. It hated no land and earned well everywhere, so in a two-side war it took the absent
  side's homeland too.

### The changes (old number -> new number)

| what | old | new | why |
| --- | --- | --- | --- |
| a sea lane, counted from the capital (SEA_HOP) | 1 step | 2 steps | overseas lands are far: their upkeep and unrest grow |
| SUPPLY LINES: an army's strength far from its capital (SUPPLY_*) | none | -5% a step past 3 steps, at least 70% | a quiet brake on reaching round the world |
| a held region's own guard (GUARD) | worth x 100 | worth x 250 | holding land means something; no more free walks into empty provinces |
| free land's militia (FREE_GUARD) | worth x 250 + 150 | worth x 180 + 150 | less of the world stays free |
| the winner's losses against free militia (FREE_LOSS) | full | half | militia are farmers, not an army |
| unrest counted from (SEATS) | the capital | the nearest seat: the capital or a Fort, Works or Nest | a province held from a fort; building matters |
| the Clockwork's upkeep (UPKEEP_SIDE) | 9% | 8% | it lost every two-side war |
| the Clockwork's income in the cold | 80% | 100% | its homeland is cold; machines don't mind it |
| the Clockwork in temperate land (BIOME_FIGHT) | x1.0 | x1.05 | like the Crown: both are armies of the open field |
| the Crown's income in the jungle / the desert | 80% / 90% | 60% / 75% | it can't live everywhere |
| lands the Crown hates (HATED, unrest +8) | none | jungle, desert | the same |
| the Brood's income in temperate land / the desert | 75% / 60% | 90% / 80% | it had too little land it could live on |
| the Brood in the desert (BIOME_FIGHT) | x0.85 | x0.95 | the same |
| lands the Brood hates | cold, desert | cold | the same |
| the Brood in temperate land (BIOME_FIGHT) | x0.9 | x1.0 | the same |
| a sea crossing (SEA_LOSS) | the Clockwork 5% | the Clockwork 5%, the Brood 10% | the Brood ranged over the whole world in three-side wars |
| ONE SIDE AGAINST ANOTHER (VS) | none | the Brood x1.25 against the Crown's armies, x1.05 against the Clockwork's | the Brood's creatures hunt men; it lost every war to the Crown |
| a three-side war's extra start lands (START_THIRD) | the Crown: Lyon | the Crown: Lyon, Lisbon; the Clockwork: Vienna | the two in Europe share it; the Brood has its side of the sea alone |
| a two-side war's extra start lands (START_TWO) | none | the Brood against the Crown: Mato Grosso, Minas Gerais | the Crown's side of the world is the bigger |
| a side not in the war (ABSENT_GUARD) | its home is plain free land | the Clockwork's home: free land with 3x the militia | the Crown took the empty Empire for nothing in a war against the Brood |
| THE AI: builds once its armies reach (AI_BUILD_AT) | 100% of what it wants | 70% | so every side builds (the Brood never did) |
| THE AI: "the leader is everyone's first enemy" (AI_LEADER_REAL) | always the biggest other side | only if that side is really bigger than me | in a two-side war the Crown chased a smaller Brood round the world |
| THE AI: THE COALITION (AI_TRUCE) | none | while one side holds 1.1x another's land, the others' attacks on each other score 8 less (capitals still fair game) | the two in Europe tore each other apart while the Brood grew |
| THE AI: THE MARCH ON A CAPITAL (AI_MARCH) | none | an army worth 2,500 heads for the nearest enemy capital from season 12 | so a strong army goes for the end |

Nothing else changed: the regiments, the units' worth, the buildings, the climate losses, the risings, the capitals'
guard and its fading, the luck, the bend of income, the heroes, the events.

### The road there (three sides and the two-side pairings, seeds 1000, the Crown's share first)

| arm (each adds to the one before) | three sides Crown / Clockwork / Brood | Crown v Clockwork | Crown v Brood | Clockwork v Brood |
| --- | --- | --- | --- | --- |
| the old rules | 26 / 30 / 44 | 95 - 5 | 100 - 0 | 19 - 81 |
| sea lanes count 2 | 19 / 52 / 29 | 65 - 35 | 88 - 12 | 41 - 59 |
| supply lines | 10 / 55 / 35 | 68 - 32 | 89 - 11 | 44 - 56 |
| the AI's real leader + the coalition (4 at 1.3x) | 17 / 59 / 24 | 50 - 50 | 62 - 38 | 33 - 67 |
| seats | 12 / 57 / 31 | 68 - 32 | 79 - 21 | 32 - 68 |
| half losses against militia | 26 / 33 / 41 | 90 - 10 | 87 - 13 | 49 - 51 |
| the guards (held x250, free x180) | 31 / 37 / 32 | 88 - 12 | 99 - 1 | 41 - 59 |
| the Crown hates the jungle and desert, earns less there | 17 / 45 / 38 | 66 - 34 | 93 - 7 | 41 - 59 |
| the AI builds at 70% | 20 / 49 / 31 | 69 - 31 | 95 - 5 | 50 - 50 |
| the absent home walled, the Clockwork's cold and upkeep, the Brood's temperate income | 14 / 50 / 36 | 57 - 43 | 72 - 28 | 45 - 55 |
| the Brood's desert, the Brood x1.1 and the Clockwork x1.05 in temperate land | 20 / 32 / 48 | 48 - 52 | 55 - 45 | 37 - 63 |
| the Brood back to x1.0 in temperate land, its sea losses, VS (the Brood against men and automata) | 14 / 43 / 43 | 48 - 52 | 60 - 40 | 55 - 45 |
| the three-side starts (Lisbon, Vienna), the coalition at 8 / 1.1x: THE FINAL RULES | 43 / 28 / 29 | 48 - 52 | 60 - 40 | 55 - 45 |

Things tried and NOT kept (measured, then put back):

| tried | what it did |
| --- | --- |
| no story heroes | nothing: the Crown's heroes were not why it won |
| bigger armies allowed (120 units) | nothing: armies never reach 80 |
| the Normal computer attacks at 1.1x (was 1.25x) | a little more fighting, no change in who wins |
| income bent harder (1,400 or 1,000 instead of 1,800) | small, mixed |
| more unrest for a big empire (1.0 or 1.5 a region past 8-10) | the Crown still won two-side wars; fewer regions held by all |
| a Clockwork extra start land in a two-side war (Vienna, Hungary, the Rhineland) | nothing: the free land round the start decides it |
| more start gold for the Crown and the Clockwork in a three-side war | no clear effect either way |
| armies cost more for each region past 10 | nothing |
| capitals fade lower (to 15-20% by season 32), the AI dares more for a capital | more capitals taken, but still almost no war won by conquest |
| THE SPOILS (the taker of a capital takes all the fallen side's land) | kept as a switch, off: see choice 12 |

## For the player

- The HELP page says the new things: the guard is worth x 250, armies far from home fight weaker, a sea crossing
  counts as two steps, unrest counts from your nearest Fort, Works or Nest, the Crown dislikes the jungle and the desert,
  the Clockwork earns well in the cold, the Brood hunts men well but loses a tenth at each sea crossing (pt and es too).
- A war saved before this keeps the old rules (its file has no rules' version; WWWar.num reads WWRules.V1 for it).
- The patch note is under 0.38.999.

## How it is built

- `WWWar.num(name, a, b, default)` / `numf` / `rule_on`: every tuned number is read through these. Order: a tuning
  override saved in the war (`d.tune`), then the old number for a war of rules version 1 (`WWRules.V1`), then the
  constant. A new war is version 2 (`WWRules.RULES_VERSION`, saved as `d.rv`).
- New rules in `ww_war.gd`: `supply()`, `seat_hops()` (unrest from the nearest seat), `hops()` with sea lanes counting
  SEA_HOP (a shortest-path search now), SEA_LOSS, VS in `strengths()`, FREE_LOSS in `resolve()`, START_TWO and
  ABSENT_GUARD in `make()`, THE SPOILS in `_fall()` (switch, off).
- New AI rules in `ww_ai.gd`: AI_BUILD_AT, AI_LEADER_REAL, AI_TRUCE / AI_TRUCE_GAP, AI_MARCH / AI_MARCH_FROM
  (`_capital_dist`), AI_CAPITAL_MARGIN (1.0: no change), AI_FAR (0.4: no change), AI_WANT_BASE / AI_WANT_REGION (no
  change).
- Tests: `tools/test_world_war.gd` has 8 new checks (sea lanes, supply, VS, the two-side starts, the absent home, an old
  war on old numbers, the version saved, a file with no version). 68 checks, 0 failures.
- `tools/sim_world_war_tune.gd` (`ownlist=1`, `freelist=1` show who held what and what stayed free) and
  `tools/study/ww_tune.sh`.

## Claude's choices (for the owner to confirm)

1. SEA LANES COUNT AS TWO STEPS from the capital (upkeep, unrest, supply). The biggest single fix: the Crown's world
   was two steps wide.
2. SUPPLY LINES: an army fights 5% weaker for each step from its capital past three, never under 70%. The region's own
   guard is not touched. A quiet brake, not a wall.
3. A HELD REGION'S GUARD IS WORTH x 250 (was x 100), free militia x 180 (was x 250), and the winner loses half as much
   against militia. Your land is defended; free land is cheaper to take.
4. UNREST COUNTS FROM THE NEAREST SEAT (the capital or a Fort, Works or Nest), not only the capital: building a fort
   in a far province makes it holdable.
5. THE CROWN DISLIKES THE JUNGLE AND THE DESERT (unrest, and 60% / 75% income). Fiction: fevers and thirst.
6. THE CLOCKWORK: 8% upkeep (was 9%), full income in the cold, x1.05 in temperate land. It was the weakest in every
   two-side war.
7. THE BROOD: more income in temperate land (90%) and the desert (80%), no longer hates the desert, x1.0 in temperate
   land (was 0.9), x0.95 in the desert; but it loses a tenth of an army at each sea crossing (creatures die in the
   ships' holds).
8. ONE SIDE AGAINST ANOTHER: the Brood's creatures fight x1.25 against the Crown's armies and x1.05 against the
   Clockwork's. This is the strongest single number of the pass, and the one that made the Crown v the Brood even.
   An alternative would be a different map for two-side wars.
9. THE STARTS: in a three-side war the Crown also holds Lisbon (and Lyon, as before) and the Clockwork Vienna; in a
   two-side war against the Crown the Brood also holds Mato Grosso and Minas Gerais; a side not in the war leaves its
   home as free land, the Clockwork's with three times the militia (the walled free cities of the Empire). These are
   separate rules for separate modes, as the design principles allow.
10. THE COMPUTER: builds once its armies reach 70% of what it wants; gangs up on "the leader" only if that side really
    holds more land than itself; THE COALITION: while one side runs ahead (1.1x another's land), the other two leave
    each other's lands alone (their capitals are still fair game); THE MARCH: a 2,500-strong army heads for the nearest
    enemy capital from season 12.
11. OLD WARS KEEP OLD RULES: a war saved before this plays to its end on the first numbers. (The other way: every saved
    war would change under the player's feet.)
12. THE SPOILS is built but OFF: when on, the taker of a capital takes all the fallen side's lands (restless, unrest
    35). Measured: it did not end more wars (the third side, usually the Brood across the sea, still stands).
13. THE NORMAL COMPUTER'S BOLDNESS (attack at 1.25x), the income bend, the capitals' guard and its fading, the regiments
    and the buildings are UNCHANGED.
14. KEY-REGION WARS FAVOUR THE BROOD (63 of 100): nine of the fifteen keys are on its side of the sea. Not changed here
    (it is the map's data): proposed, swap two of them (for example Canton and Nagasaki for Vienna and London).

## What is left

- WARS STILL END AT THE LAST SEASON. Capitals fall more often (62 in 100 three-side wars, was 37), but to win by
  capitals all the others must fall, and the Brood's Queen in the Amazon almost never does (1 in 100). Ideas, not
  built: a weaker capital guard for the Amazon (measured: 6 wars ended by conquest instead of 3, but with no last
  season the Crown then won most); a win by holding two enemy capitals; a surrender when one side holds twice the
  other's land for a year in a two-side war.
- The three-side Crown is a point over the goal (39 of 100 over both seed sets); the Clockwork v the Brood is a point
  or two over on one seed set (62).
- Key-region wars: the keys' places (choice 14).
- Human players were not measured: a player who builds forts abroad and marches on capitals will end wars sooner than
  the computers.
