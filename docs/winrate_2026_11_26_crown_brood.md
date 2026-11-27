# Win rates 2026-11-26: Crown v Brood

Job winrate-crown-brood, branch `winrate-crown-brood`, from main at 0.38.221 (the battle tests' lessons are in: ai-lessons,
crown-micro, crown-micro-2, crown-finish, brood-micro). A measuring job: no game rule and no computer changed, no version
bump.

The owner (2026-11-26): "run win rate tests, and then ... win rate tests with the Rootmaw nerf, not only against Crown but
all matchups, so we have a good way to compare." This is the Crown v Brood part; three other jobs do the other matchups
with the same method.

## How

- Hard OPTIMAL against Hard OPTIMAL, every game to 20:00 (a defeat ends it sooner).
- 30 games a cell on the six parity maps. Game i (0 to 29): seed 1126001 + i, map number i mod 6, start spot (i / 6) mod 2.
  Spot A = the Crown in the first slot. This gives every map 3 games with the Crown on spot A and 2 on spot B, 18 and 12
  in all (the shared formula of the four jobs; not quite half and half).
- Two arms, the same 30 games each: DEFAULT (main as it is) and NERF (the match switch `farmaw:2.0`: a far Rootmaw pays
  x2.0 instead of x2.2, the same as `Defs.FOOD_BONUS` 1.2 -> 1.0).
- Score = income earned + 2 x army, at the bell or the defeat; a beaten side's score counts a quarter. g = ln(Crown score
  / Brood score), so plus is good for the Crown. "Led" = 10% ahead on score at the bell, else "even".
- Tool: `tools/study/winrate_1126_crown_brood.py` (`run default`, `run nerf`, `report --games`). Data:
  `docs/winrate_2026_11_26/data/crown_brood/<arm>/<game>/` (result.json, story.txt).

## The table

| arm | games | Crown won | Crown led | even | Brood led | Brood won | Crown won or led | Brood won or led | median minute decided | mean g (t) |
|---|---|---|---|---|---|---|---|---|---|---|
| default | 30 | 5 | 8 | 1 | 4 | 12 | 13 | 16 | 18.4 | -0.40 (-1.3) |
| nerf | 30 | 6 | 6 | 2 | 9 | 7 | 12 | 16 | 17.1 | +0.00 (0.0) |

Nerf against default, game by game on the same 30 games: g up by 0.40 (t 0.9); the Crown did better in 16, worse in 14.

Income earned and army (Crown / Brood), the mean of the 30 games:

| arm | income 8:00 | 12:00 | 16:00 | army 8:00 | 12:00 | 16:00 | halls 12:00 | halls 20:00 |
|---|---|---|---|---|---|---|---|---|
| default | 6,409 / 4,794 | 13,281 / 12,217 | 20,723 / 19,507 | 1,346 / 662 | 2,070 / 1,641 | 2,054 / 2,494 | 3.7 / 3.4 | 3.0 / 3.1 |
| nerf | 6,409 / 4,557 | 13,610 / 11,299 | 21,862 / 18,123 | 1,318 / 663 | 2,148 / 1,582 | 2,565 / 2,375 | 3.9 / 3.2 | 3.2 / 3.0 |

(Halls at 20:00 count a beaten side as 0.)

By start spot:

| arm | spot | games | Crown won or led | even | Brood won or led | mean g |
|---|---|---|---|---|---|---|
| default | Crown on A | 18 | 9 | 0 | 9 | -0.22 |
| default | Crown on B | 12 | 4 | 1 | 7 | -0.68 |
| nerf | Crown on A | 18 | 8 | 2 | 8 | +0.16 |
| nerf | Crown on B | 12 | 4 | 0 | 8 | -0.23 |

By map (5 games each: Crown won or led / even / Brood won or led, mean g):

| map | default | nerf |
|---|---|---|
| greenhold | 4 / 0 / 1, +1.06 | 3 / 0 / 2, -0.15 |
| dune_sea | 1 / 1 / 3, -0.57 | 1 / 0 / 4, -0.54 |
| frostfang | 0 / 0 / 5, -1.63 | 2 / 0 / 3, -0.52 |
| ashford_crossing | 1 / 0 / 4, -1.55 | 4 / 0 / 1, +1.61 |
| hollowfen | 2 / 0 / 3, -0.69 | 1 / 1 / 3, -0.13 |
| cinder_steps | 5 / 0 / 0, +0.96 | 1 / 1 / 3, -0.26 |

## What we found

1. **Crown v Brood is close now.** With the lessons in, the Crown won or led 13 of 30, the Brood 16. Before, on
   0.38.177 (crown-brood-fix's "today"), it was 3 against 27, mean g -1.32; in ai-opponent-review (0.38.107) 3 against 8 of
   12; in the ai-lessons block of 10 games, 4 against 6. Those used other seeds, so this is a rough comparison, but the
   gap has closed a lot. The Brood still wins outright more often: 12 times against the Crown's 5.
2. **The old shape is still there: the Crown is ahead early and behind late.** At 8:00 the Crown has twice the Brood's
   army and a third more income. By 16:00 the Brood's army is the bigger one, and most Crown defeats come between 17 and
   19 minutes.
3. **The nerf cuts the Brood's income by about 7%** from 12:00 on (12,217 to 11,299 at 12:00, 19,507 to 18,123 at 16:00).
   At 16:00 the Crown's army is now the bigger one (2,565 against 2,375).
4. **The nerf moves the score, but not the win count.** Mean g goes from -0.40 to 0.00. Won or led stays the same (12 and
   16). The Brood wins outright less (12 to 7) and leads at the bell more (4 to 9); the Crown wins outright 6 (was 5).
   Game by game the change is +0.40 with t 0.9, 16 better and 14 worse: within the noise of 30 games.
5. **These games are very noisy.** The same game can flip on a small change: Greenhold game 0 was a Crown defeat at 16:40
   in the default arm and a Crown lead at the bell with the nerf. Single games swing about 2 points of g either way, so 30
   games only show a change of roughly 0.7 in mean g or more. The map rows (5 games each) swap around between arms and
   say little.
6. **Spot B is worse for the Crown in both arms** (mean g about half a point lower than on spot A), but on 12 games
   against 18 that is not clear either.

One game (default, Hollowfen game 10) logged 43 script errors, "Trying to assign invalid previously freed instance" at
`scripts/ai_expand_wall.gd:458`; the game still ran to its end.
