# Win rates: the Rootmaw at 1.1 (job winrate-rootmaw-1-1)

The owner asked on 27 November 2026: "What if we nerfed the Rootmaw from 1.2 to 1.1?" This job measures it. Nothing in
the game was changed: Defs.FOOD_BONUS is still 1.2 and every balance number is as it was. The owner decides.

## What was measured

- The far Rootmaw today pays 2.2 times the near one (FOOD_BONUS 1.2). Three arms, each a match switch:
  - **today, 1.2**: no switch, the far Rootmaw pays x2.2.
  - **1.1**: the switch `farmaw:2.1`, the far Rootmaw pays x2.1.
  - **1.0**: the switch `farmaw:2.0`, the far Rootmaw pays x2.0 (the nerf measured on 26 November).
- Three matchups: Crown v Brood, Clockwork v Brood, and the Brood mirror. The switch works on every Brood in the game,
  so in the mirror both Broods get it.
- Hard OPTIMAL computer against Hard OPTIMAL computer, every game to 20:00 unless one side is beaten first, on the six
  parity maps (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder Steps). Version 0.38.222.
- 30 games a matchup and arm, 270 in all. The 30 games are the same in every matchup and arm: game i has seed 1127001 + i
  and map number i mod 6, five games a map.
- **The spot split is fixed.** The 26 November study put 18 of its 30 games on spot A and only 12 on spot B. Here
  exactly 15 games put the first side on spot A and 15 on spot B (by map 3 and 2). In the mirror, 15 games have player 1
  on spot A and 15 have player 2 there.
- The score is the same as before: income earned plus twice the army, at the bell or at the defeat; a beaten side's
  score counts a quarter. g is the natural log of one side's score over the other's (plus = the first side ahead).
  "Led" means 10% ahead on score at the bell; "even" means closer than that. "Won" means the other side was beaten.
- t is the mean divided by its standard error. Roughly: below 2 is within the noise of 30 games.
- No game stalled and none failed. One game (Crown v Brood, 1.0, game 24) logged the known script error in
  ai_expand_wall.gd line 339 and still ran to its end.
- Tools: tools/study/winrate_rootmaw_11.py (list, run, queue, status, report). Data: docs/winrate_rootmaw_1_1/data/.
  All tables: docs/winrate_rootmaw_1_1/tables.md; every game in one line: docs/winrate_rootmaw_1_1/games.txt.

## The short answer

**Keep 1.2.** On these 270 games neither nerf changed any of the three matchups by more than the noise, and today's
1.2 is already close to even in all three. How sure: fairly sure that 1.1 makes no large difference (a shift of about
0.7 in mean g, roughly 5 or 6 games in 30 changing hands, would have shown); not sure about a small one, which 30 games
cannot see.

## Crown v Brood

| Rootmaw | Crown won | Crown led | even | Brood led | Brood won | Crown won or led | Brood won or led | mean g (t) |
|---|---|---|---|---|---|---|---|---|
| today, 1.2 | 9 | 7 | 1 | 8 | 5 | 16 | 13 | +0.44 (1.4) |
| 1.1 | 12 | 6 | 1 | 6 | 5 | 18 | 11 | +0.66 (2.1) |
| 1.0 | 10 | 7 | 0 | 3 | 10 | 17 | 13 | +0.27 (0.7) |

Paired on the same games (plus = better for the Crown):

| compared | mean change of g (t) | Crown better | Crown worse |
|---|---|---|---|
| 1.1 against today | +0.23 (0.6) | 18 | 11 |
| 1.0 against today | -0.16 (-0.4) | 14 | 16 |
| 1.0 against 1.1 | -0.39 (-1.1) | 9 | 17 |

By spot (Crown won or led / even / Brood won or led, mean g): today, Crown on A 6 / 1 / 8 (+0.47), on B 10 / 0 / 5
(+0.41); 1.1, on A 9 / 1 / 5 (+0.73), on B 9 / 0 / 6 (+0.59); 1.0, on A 10 / 0 / 5 (+0.68), on B 7 / 0 / 8 (-0.13).

Income earned, army and halls, Crown / Brood:

| Rootmaw | income 8:00 | 12:00 | 16:00 | army 8:00 | 12:00 | 16:00 | halls 8:00 | 12:00 | 16:00 |
|---|---|---|---|---|---|---|---|---|---|
| today, 1.2 | 6,473 / 4,494 | 13,413 / 11,121 | 20,221 / 16,928 | 1,302 / 592 | 2,160 / 1,377 | 2,687 / 2,150 | 2.0 / 3.4 | 3.8 / 3.2 | 4.8 / 2.9 |
| 1.1 | 6,384 / 4,357 | 13,317 / 10,988 | 21,223 / 16,413 | 1,331 / 614 | 2,276 / 1,234 | 2,722 / 1,864 | 2.1 / 3.3 | 3.8 / 3.3 | 4.6 / 2.9 |
| 1.0 | 6,485 / 4,398 | 13,441 / 10,902 | 21,347 / 16,757 | 1,362 / 608 | 2,210 / 1,478 | 2,402 / 1,952 | 2.1 / 3.5 | 3.8 / 3.1 | 4.5 / 3.1 |

In plain words: on these seeds the Crown is already slightly ahead of the Brood today (won or led 16 against 13). With
1.1 it is a little further ahead (18 against 11), but the game-by-game change is only +0.23 with t 0.6: noise. With 1.0
the Brood actually won outright more often (10 against 5), again within the noise. Half the games are decided outright
(14 to 20 of 30), most of them after 17 minutes.

## Clockwork v Brood

| Rootmaw | Clockwork won | Clockwork led | even | Brood led | Brood won | Clockwork won or led | Brood won or led | mean g (t) |
|---|---|---|---|---|---|---|---|---|
| today, 1.2 | 10 | 3 | 3 | 6 | 8 | 13 | 14 | +0.18 (0.5) |
| 1.1 | 6 | 3 | 1 | 10 | 10 | 9 | 20 | -0.34 (-1.1) |
| 1.0 | 10 | 4 | 0 | 4 | 12 | 14 | 16 | +0.06 (0.2) |

Paired on the same games (plus = better for the Clockwork):

| compared | mean change of g (t) | Clockwork better | Clockwork worse |
|---|---|---|---|
| 1.1 against today | -0.52 (-1.3) | 11 | 15 |
| 1.0 against today | -0.12 (-0.2) | 16 | 14 |
| 1.0 against 1.1 | +0.40 (0.9) | 16 | 12 |

By spot (Clockwork won or led / even / Brood won or led, mean g): today, Clockwork on A 5 / 2 / 8 (+0.03), on B 8 / 1 / 6
(+0.34); 1.1, on A 5 / 1 / 9 (-0.08), on B 4 / 0 / 11 (-0.60); 1.0, on A 7 / 0 / 8 (+0.05), on B 7 / 0 / 8 (+0.07).

Income earned, army and halls, Clockwork / Brood:

| Rootmaw | income 8:00 | 12:00 | 16:00 | army 8:00 | 12:00 | 16:00 | halls 8:00 | 12:00 | 16:00 |
|---|---|---|---|---|---|---|---|---|---|
| today, 1.2 | 8,071 / 6,271 | 16,475 / 13,346 | 20,329 / 18,306 | 1,606 / 1,116 | 2,849 / 2,649 | 3,012 / 3,113 | 2.6 / 3.3 | 3.7 / 3.7 | 2.7 / 2.9 |
| 1.1 | 8,375 / 6,241 | 17,010 / 13,517 | 21,495 / 20,103 | 1,863 / 1,042 | 3,164 / 3,270 | 2,465 / 4,052 | 2.7 / 3.4 | 3.7 / 3.8 | 2.5 / 3.3 |
| 1.0 | 8,444 / 5,772 | 16,882 / 12,284 | 21,504 / 17,294 | 1,818 / 1,048 | 3,459 / 2,808 | 2,806 / 3,277 | 2.7 / 3.1 | 3.7 / 3.7 | 2.9 / 2.9 |

In plain words: today this matchup is even (13 against 14). The strange row is 1.1: the Brood did better with the
nerf (20 against 9). That cannot be the nerf itself; a weaker Rootmaw cannot help the Brood. It shows how far these
games swing on a small change: one Rootmaw paying a little less sends the whole game down another road. The same games
at 1.0 are even again (14 against 16). Take the 1.1 row as noise, the size of noise to expect from 30 games.

## The Brood mirror (the Brood on spot A against the Brood on spot B)

| Rootmaw | spot A won | spot A led | even | spot B led | spot B won | spot A won or led | spot B won or led | mean g (t) |
|---|---|---|---|---|---|---|---|---|
| today, 1.2 | 11 | 4 | 4 | 1 | 10 | 15 | 11 | +0.17 (0.7) |
| 1.1 | 12 | 2 | 3 | 0 | 13 | 14 | 13 | +0.03 (0.1) |
| 1.0 | 11 | 6 | 2 | 2 | 9 | 17 | 11 | +0.21 (0.8) |

The spot A edge per arm is the mean g above: today +0.17 (t 0.7), 1.1 +0.03 (t 0.1), 1.0 +0.21 (t 0.8). None is beyond
the noise. Paired changes (plus = better for spot A): 1.1 against today -0.13 (t -0.5), 1.0 against today +0.04
(t 0.1), 1.0 against 1.1 +0.17 (t 0.5).

By which player stood on spot A (spot A won or led / even / spot B won or led, mean g): today, player 1 on A 8 / 3 / 4
(+0.15), player 2 on A 7 / 1 / 7 (+0.18); 1.1, player 1 8 / 1 / 6 (+0.18), player 2 6 / 2 / 7 (-0.12); 1.0, player 1
10 / 0 / 5 (+0.53), player 2 7 / 2 / 6 (-0.11).

Income earned, army and halls, spot A / spot B:

| Rootmaw | income 8:00 | 12:00 | 16:00 | army 8:00 | 12:00 | 16:00 | halls 8:00 | 12:00 | 16:00 |
|---|---|---|---|---|---|---|---|---|---|
| today, 1.2 | 9,406 / 9,132 | 18,502 / 17,079 | 25,181 / 22,440 | 1,388 / 1,289 | 2,157 / 1,765 | 2,412 / 2,256 | 4.0 / 3.9 | 3.7 / 3.8 | 3.2 / 2.8 |
| 1.1 | 9,072 / 8,958 | 17,121 / 16,264 | 21,687 / 19,692 | 1,320 / 1,032 | 1,915 / 1,762 | 1,972 / 2,283 | 4.0 / 4.0 | 3.5 / 3.2 | 2.4 / 2.9 |
| 1.0 | 8,810 / 8,699 | 17,201 / 15,705 | 22,143 / 20,504 | 1,278 / 962 | 1,980 / 2,186 | 2,369 / 2,135 | 4.0 / 4.0 | 3.7 / 3.3 | 3.3 / 2.7 |

In plain words: the mirror ends more often than the others (20 to 25 of 30 decided, half before 14 or 15 minutes), and
the nerf takes a few hundred food off both sides alike by 8:00 and some 800 to 1,400 by 12:00. Spot A keeps a small
lead in income (about 5% at 12:00 in every arm), but on the score it is within the noise in every arm.

## What we found

1. **Neither nerf moved any matchup beyond the noise.** The six paired changes against today lie between -0.52 and
   +0.23 in mean g, with t between -1.3 and +0.6. With 30 games only a change of about 0.7 or more would stand out.
2. **Today's 1.2 is already close to even on these seeds.** Crown v Brood won or led 16 against 13 (mean g +0.44,
   t 1.4), Clockwork v Brood 13 against 14 (+0.18, t 0.5), and the Brood mirror's spot A 15 against 11 (+0.17, t 0.7).
   On 26 November, on other seeds, Crown v Brood was 13 against 16: put together, 60 games, the Crown and the Brood won
   or led 29 each.
3. **The Brood mirror's spot A edge looks smaller than it did.** On 26 November spot A won or led 18 against 7 (t 2.3),
   but that study had 18 of its 30 games on spot A's side of the seed rule. With an even 15 and 15 split it is 15
   against 11 (t 0.7). Part of the "edge is back" finding was likely the uneven split. Spot A still earns about 5% more
   by 12:00 in every arm, so a small lean may be real; it is not big enough to decide games here.
4. **The nerf costs the Brood less income than expected in these games.** Against the Crown the Brood's income at 12:00
   is 11,121 today, 10,988 at 1.1 and 10,902 at 1.0 (1% and 2% less). Against the Clockwork 1.0 takes 8% off by 12:00,
   but 1.1 takes nothing. The far Rootmaws are only part of the Brood's income, and a game that goes another way changes
   the income more than the switch does.
5. **Single games swing hard.** The same seed and map can be a Brood win in one arm and a clear Crown lead in the next,
   so the map rows (5 games each, in tables.md) say little.
6. **Spot B cells.** With the even split the cross matchups show no steady spot advantage: the Crown and the Clockwork
   do about as well on spot B as on spot A in today's arm.

## Recommendation

**Keep the Rootmaw at 1.2 (no change).** Fairly sure: 270 games found no effect of 1.1 or 1.0 big enough to matter, and
today's value already gives close games in all three Brood matchups. A small effect cannot be ruled out with 30 games a
cell; if the owner wants to know about a small effect, the next step would be 60 or more games a cell for 1.2 against
1.1 only, in Crown v Brood (the matchup the nerf was meant for). If the owner still wants a nerf, 1.1 is the gentler
step and did not hurt the Brood in these games; 1.0 showed nothing more.

## Claude's choices

1. New seeds (1127001 to 1127030) for all three arms, so 1.0 was measured again here rather than reusing 26 November's
   games, which had the uneven spot split.
2. The spot rule: spot = (game // 6 + game mod 6) mod 2, which gives 15 and 15 overall and 3 and 2 on each map.
3. Halls at a minute after a side was beaten count as 0 for that side.
