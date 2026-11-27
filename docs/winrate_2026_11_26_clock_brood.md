# Win rates 2026-11-26: the Clockwork v the Brood (winrate-clock-brood)

The owner, 2026-11-26: win rate tests after the new fighting rules and the battle-test lessons went into the main
computers (0.38.221: ai-lessons, crown-micro, crown-micro-2, crown-finish, brood-micro), and the same with the Rootmaw
nerf, in every matchup. This job is the Clockwork against the Brood. A measuring job: no rule and no computer changed.

**Method** (the same in all four jobs): Hard OPTIMAL against Hard OPTIMAL, on 0.38.221, every game to 20:00 (a defeat
ends it sooner), the six parity maps, 30 games an arm. Game i has seed 1126001 + i, map number i mod 6, and start spot
(i div 6) mod 2. Both arms play the same 30 games. Arms: **default** (main as it is) and **nerf** (the match switch
`farmaw:2.0`: a far Rootmaw pays two times a near one, not 2.2). Score = income earned + 2 x army at the bell or the
defeat; a beaten side's score counts a quarter. "Led" = 10% ahead on score at 20:00. g = the log of the score ratio,
from the Clockwork's side (above zero: the Clockwork ahead).

Note on the spots: the shared seed rule gives 18 games with the Clockwork on spot A and 12 on spot B, not 15 and 15.
The spot matters a lot here (below), so the plain totals lean a little to the Clockwork. A spot-even line is given too.

Tool: tools/study/winrate_1126_clock_brood.py (`run default`, `run nerf`, `table`, `games <arm>`).
Data: docs/winrate_2026_11_26/data/clock_brood/<arm>/<game>/ (result.json, story.txt). No game failed and no game
logged a script error.

## The table

| arm | games | Clockwork won | Clockwork led | even | Brood led | Brood won | Clockwork won or led | Brood won or led | median minute decided | mean g (t) |
|---|---|---|---|---|---|---|---|---|---|---|
| default | 30 | 12 | 4 | 0 | 4 | 10 | 16 | 14 | 15.3 | +0.21 (0.6) |
| nerf | 30 | 11 | 3 | 0 | 9 | 7 | 14 | 16 | 15.7 | +0.33 (1.0) |

Means, Clockwork / Brood (a side beaten counts 0 after its defeat):

| arm | income 8:00 | income 12:00 | income 16:00 | army 8:00 | army 12:00 | army 16:00 | halls 12:00 | halls 20:00 |
|---|---|---|---|---|---|---|---|---|
| default | 8,258 / 6,383 | 16,650 / 13,736 | 18,762 / 15,689 | 1,732 / 1,090 | 2,974 / 2,683 | 3,166 / 2,770 | 3.6 / 3.8 | 2.7 / 2.4 |
| nerf | 8,317 / 5,898 | 17,010 / 12,469 | 19,688 / 15,915 | 1,789 / 932 | 3,778 / 3,154 | 3,039 / 3,069 | 4.0 / 3.7 | 2.9 / 2.5 |

By start spot (the Clockwork on spot A = slot 0, on spot B = slot 1):

| arm | Clockwork's spot | games | Clockwork won or led | even | Brood won or led | mean g |
|---|---|---|---|---|---|---|
| default | A | 18 | 12 | 0 | 6 | +0.61 |
| default | B | 12 | 4 | 0 | 8 | -0.40 |
| nerf | A | 18 | 12 | 0 | 6 | +1.07 |
| nerf | B | 12 | 2 | 0 | 10 | -0.76 |

- default, spots weighted evenly: the Clockwork won or led 50% of games.
- nerf, spots weighted evenly: the Clockwork won or led 42% of games.

Nerf v default, the same games (30 pairs): mean change in g (Clockwork side) +0.13, t 0.4; the Clockwork better in 15, worse in 12 (by more than 0.05).

By map (Clockwork won or led / Brood won or led):

| map | default | nerf |
|---|---|---|
| greenhold | 2 / 3 of 5 | 4 / 1 of 5 |
| dune_sea | 3 / 2 of 5 | 2 / 3 of 5 |
| frostfang | 3 / 2 of 5 | 3 / 2 of 5 |
| ashford_crossing | 2 / 3 of 5 | 1 / 4 of 5 |
| hollowfen | 3 / 2 of 5 | 2 / 3 of 5 |
| cinder_steps | 3 / 2 of 5 | 2 / 3 of 5 |

Medians, the Clockwork's of the Brood's: income at 8:00 1.29 (nerf 1.43), at 12:00 1.20 (nerf 1.34); army at 8:00 1.62
(nerf 1.79).

The nerf, game by game (same 30 games): the Brood's income at 8:00 is 485 less (t -2.8, lower in 21 of 30), at 12:00
1,267 less (t -1.5, lower in 22 of 30), at 16:00 the same. Its army at 8:00 is 158 smaller (t -2.4). The Clockwork's own
numbers do not move. The same side won or led in 22 of 30 games in both arms.

Decided by 20:00: default 22 of 30 (the Clockwork won 12, at 11.6 to 19.4 minutes; the Brood 10, at 13.3 to 17.6);
nerf 18 of 30 (the Clockwork 11, the Brood 7, all after 15:00).

## What it shows

1. **The matchup is even again.** By default the Clockwork won 12 and the Brood 10; won or led 16 to 14; mean g +0.21
   (t 0.6, noise). With the spots weighted evenly, the Clockwork won or led half the games. It is a game of big fights:
   most games end between 13 and 18 minutes.

2. **The Brood caught up after the lessons.** Before: the wr1000 baseline (0.38.124) was even (7 to 6 wins, g +0.18);
   then the kept `owls` change gave the Clockwork a clear edge (g about +0.7 over 30 games); then the Brood's fighting was
   coached (brood-micro: the Brood beaten 7 of 10 before, 3 of 10 after). Now, with everything in, it is back to even,
   g +0.21. The older 11-17 study (to 12:00 only) had the Clockwork ahead in 34 of 38; those games stopped before the
   big fights, so they are not the same measure.

3. **The Clockwork still earns more early, the Brood wins by fighting.** The Clockwork earns about 1.3 times the
   Brood's income at 8:00 and has 1.6 times the army, and still loses ten games outright. At equal value the Brood wins
   the fights (the battle matrix said so too); the Clockwork's lead in income has to be big to hold.

4. **The start spot matters more than anything else here.** On spot A the Clockwork won or led 12 of 18 in both arms;
   on spot B only 4 of 12 (default) and 2 of 12 (nerf). Mean g +0.61 on A, -0.40 on B. Spot B is also where the nerf
   looked worst for the Clockwork. With 12 games on B this could still be partly chance, but it is the largest split in
   the table and worth a spot check on these six maps.

5. **What the nerf does in this matchup: it slows the Brood, it does not change who wins.** The Brood earns about 8%
   less at 8:00 and 9% less at 12:00, with a smaller army at 8:00, and by 16:00 it has caught up. Fewer games are
   decided (18 v 22), fewer Brood wins (7 v 10) but more Brood leads at the bell (9 v 4). The mean g moved +0.13 for the
   Clockwork (t 0.4): within the noise. Won or led went 16/14 to 14/16, also within the noise. So against the
   Clockwork the nerf takes some early pressure off, and the games last longer, but the result stays even.
