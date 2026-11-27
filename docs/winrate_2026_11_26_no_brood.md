# Win rates, 2026-11-26: the matchups without the Brood (winrate-no-brood)

A measuring job. No game rule and no AI changed. Main 0.38.221, after the AI lessons (ai-lessons), the Crown's micro
(crown-micro, crown-micro-2), the Crown finisher (crown-finish) and the Brood micro were merged. One of four jobs that
share the six matchups with the same method; this one has the three without the Brood.

Hard OPTIMAL against Hard OPTIMAL. Every game to 20:00, or sooner if one side is beaten. The six parity maps, 30 games a
matchup, 90 games in all. Only main as it is: the Rootmaw nerf touches only the Brood.

## The table

"Us" is the Crown in Crown v Clockwork, and the side on spot A in a mirror. Won = the other side beaten. Led = 10% ahead
at the bell on income earned plus twice the army value.

| matchup | games | us won | us led | even | them led | them won | won or led, us / them | decided | median minute decided | mean g (t) |
|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Clockwork (us = Crown) | 30 | 14 | 10 | 4 | 2 | 0 | **24 / 2** | 14 | 16.6 | +1.09 (5.8) |
| Crown mirror (us = spot A) | 30 | 4 | 7 | 2 | 9 | 8 | 11 / 17 | 12 | 18.1 | -0.36 (-1.3) |
| Clockwork mirror (us = spot A) | 30 | 10 | 3 | 3 | 2 | 12 | 13 / 14 | 22 | 14.6 | -0.15 (-0.4) |

Income earned so far and army value, the mean of the games, us / them. Halls the mean, a beaten side counted 0 at 20:00.

| matchup | income 8:00 | income 12:00 | income 16:00 | army 8:00 | army 12:00 | army 16:00 | halls 12:00 | halls 20:00 |
|---|---|---|---|---|---|---|---|---|
| Crown v Clockwork | 9.1k / 9.7k | 18.8k / 19.4k | 33.0k / 28.5k | 1.3k / 1.4k | 2.3k / 2.3k | 3.5k / 2.4k | 4.8 / 3.8 | 6.7 / 2.6 |
| Crown mirror | 7.9k / 8.1k | 15.4k / 15.8k | 20.7k / 23.3k | 1.0k / 1.0k | 1.8k / 1.9k | 1.8k / 2.1k | 3.6 / 3.6 | 3.2 / 4.2 |
| Clockwork mirror | 10.1k / 10.0k | 18.7k / 18.8k | 27.2k / 29.0k | 1.6k / 1.5k | 3.0k / 3.4k | 3.0k / 5.2k | 3.3 / 3.4 | 2.9 / 3.4 |

(At 16:00 the means leave out the sides already beaten, so they lean to the side that is still standing.)

By the Crown's start spot in Crown v Clockwork: on spot A 9 won, 5 led, 2 even, 2 behind, 0 lost (18 games); on spot B 5
won, 5 led, 2 even, 0 behind, 0 lost (12 games). In a mirror "us" is always spot A, so the main row is the spot A v spot B
split.

## What it shows

1. **The Crown now beats the Clockwork, and finishes it.** It won or led 24 of 30, and won outright 14. The Clockwork won
   none and led only 2. Before: on 11-17 (to 12:00) the Crown won or led none of 38; on 11-21 (ai-opponent-review) 7 of
   11; in the wr1000 baseline (0.38.124) 18 of 30, with only 2 outright wins, and the Clockwork won 3. With the finisher
   (crown-finish) it won 9 of 20 outright; here 14 of 30, about the same share. So the outright wins came with the
   finisher and held after the lessons.
2. **That game is still even until about 14:00.** The Clockwork earns a little more at 8:00 and 12:00 (9.7k v 9.1k, 19.4k
   v 18.8k), the armies match at 12:00, and the score at 14:00 is only 1.13 to the Crown (g +0.12, t 1.7). Then the Crown
   pulls away: by 16:00 it has earned 33k to 28.5k and has half again the army, and at 20:00 it holds 6.7 halls to 2.6.
   The Clockwork's new army mix (Ballistas for Clock Soldiers, from the lessons) did not save a single game.
3. **The Crown mirror ends more often than it used to.** 12 of 30 decided (40%), at a median of 18:06. The wr1000 baseline
   decided 9 of 30 (30%) at 18:05, and crown-finish's 20 games 7 without the finisher and 10 with it. Most games still go
   to the bell: 16 of the 18 undecided ones had a side 10% ahead.
4. **The Crown mirror leans to spot B again, but not past chance.** Spot B won or led 17, spot A 11 (sign test p 0.34).
   The wr1000 mirror found the same lean (16 v 10, and 92 v 77 over 180 games). Two maps carry most of it: Dune Sea and
   Cinder Steps, where spot B won 3 games each. It is a lean to keep watching, not an edge shown.
5. **The Clockwork mirror decides most games and has no spot edge.** 22 of 30 ended by 20:00, at a median of 14:36 (the
   wr1000 baseline: 14 of 20, at 13:26). Spot A won or led 13, spot B 14. The incomes are level to 12:00; the side that
   wins pulls ahead in army after that.
6. **The games ran clean.** No game logged a script error. One Clockwork mirror game (game 27, Ashford Crossing) hit the
   50-minute run limit while another game ran beside it; played again alone with the same seed it finished at 16:30, spot
   B winning. That second run is the one in the table.

## How it was measured

- Runner and report: `tools/study/winrate_1126_no_brood.py` (`run`, `report`, `games`), on `tools/qa_match.gd` through
  `qa_matches.run_one`. Two games at a time on a 2-core machine, about 5 to 10 minutes a game.
- Game i (0 to 29) of every matchup: seed 1126001 + i, map PARITY_MAPS[i % 6] (Greenhold, Dune Sea, Frostfang, Ashford
  Crossing, Hollowfen, Cinder Steps), spot (i // 6) % 2. The same in the other three jobs, so the tables join. This rule
  gives 18 games on spot A and 12 on spot B, not 15 and 15; in Crown v Clockwork the Crown is on spot A in 18.
- Score = income earned + 2 x army value at the bell or the defeat; a beaten side's score counts a quarter. g = ln(our
  score / their score); its t is the plain one-sample t over the 30 games.
- Data: `docs/winrate_2026_11_26/data/<cell>/default/<tag>/` (result.json, story.txt), cells `crown_clock`,
  `crown_mirror`, `clock_mirror`. All the report's tables, by spot and by map too: `docs/winrate_2026_11_26/no_brood_tables.md`;
  one line a game: `docs/winrate_2026_11_26/no_brood_games.txt`.
