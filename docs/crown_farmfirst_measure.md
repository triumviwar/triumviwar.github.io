# The Crown's second Farm before the Barracks, measured (crown-farmfirst-measure)

A measuring job: no game or AI code changed. The owner DECIDED on 2026-11-16 08:01 that the Crown computer's OPTIMAL
opening builds its second Farm right after the Gate and the Barracks after it (`AICrownCoach.farm_first`,
scripts/ai_crown_coach.gd; the old order with the switch `farmfirst:off`). That was measured on 5 pairs of games. This
runs it on the win-rate design.

Branch crown-farmfirst-measure, from crown-coach-1116 at 53b63e94. Data: docs/crown_farmfirst_measure/data/{ff,off}/<game>/
(result.json, story.txt), every table in docs/crown_farmfirst_measure/tables.md.

## In short

| pairing | arm | W-D-L | won or led / trailed / even | early losses (<6:00) | Crown income / enemy's 3:00 | 5:00 | 8:00 | 12:00 | army / enemy's 5:00 | 8:00 |
|---|---|---|---|---|---|---|---|---|---|---|
| Crown v Brood | **Farm first** | 0-33-5 | **4** / 33 / 1 | 0 | **1.26** | **1.00** | **0.91** | **0.77** | 0.45 | 0.55 |
| Crown v Brood | old order | 0-30-8 | 1 / 33 / 4 | 0 | 1.03 | 0.90 | 0.85 | 0.72 | 0.38 | 0.44 |
| Crown v Clockwork | **Farm first** | 0-38-0 | **1** / 36 / 1 | 0 | **0.73** | **0.75** | **0.72** | **0.58** | 0.65 | 0.67 |
| Crown v Clockwork | old order | 0-37-1 | 0 / 38 / 0 | 0 | 0.61 | 0.65 | 0.64 | 0.51 | 0.76 | 0.52 |

1. **Farm first earns more, in almost every game, all game long.** Paired by map and seed, the Crown's income ratio is
   higher with Farm first at 5:00 in 31 of 38 games v the Brood and 33 of 38 v the Clockwork, at 8:00 in 30 and 32 (sign
   test p < 0.001 each), at 12:00 in 19 of 29 and 25 of 37 (p 0.14, 0.047). The Crown earns about 300-400 gold more by
   5:00, 560-680 more by 8:00 and 840-1,180 more by 12:00. The switch did what it says: 38 of 38 Farm-first games had 2 Farms
   at 2:00, 1 of 38 old-order games.
2. **No rush window opened.** Not one early loss in either arm (no game lost and no built Crown hall lost before 6:00, all
   152 games). The Clockwork's first attack came at the same time (5:37 v 5:36); the Brood's at 7:38 v 7:37.
   Over the whole game the Crown LOST FEWER halls with Farm first: 0.82 v 1.13 a game (Brood), 0.79 v 1.11 (Clockwork).
3. **The one cost: v the Clockwork the army is a little smaller at 5:00** (0.65 v 0.76 of the Clockwork's; 22 of 32 games
   lower, p 0.05), the Barracks coming a minute later. By 8:00 it is bigger (0.67 v 0.52, 29 of 38 games, p 0.002), the
   extra income turned into soldiers. V the Brood the army is bigger at 5:00 and 8:00 too (not significant).
4. **Results moved a little, all one way, but not enough to call.** Won or led 4 v 1 (Brood), 1 v 0 (Clockwork); Brood
   wins over the Crown 5 v 8; paired results better in 8, worse in 5 v the Brood (p 0.58), better in 3, worse in 0 v the
   Clockwork (p 0.25). The Crown still wins no game in either arm: the opening helps the economy, it does not fix the
   gap (still 0.72 of the Clockwork's income at 8:00 and 0.91 of the Brood's).
5. Nothing else changed: OPTIMAL picked the same plan in both arms of every pair (v the Brood Balanced in all 76 games;
   v the Clockwork Timing / Balloon / Economy, the same per seed). No game failed; one harmless headless-renderer line
   (`texture_2d_initialize ... "t" is null`) in one game's log.

**Recommendation: keep Farm first, in both matchups.** It is a clear, steady economic gain with no early cost that showed
up in 152 games (no early losses, fewer halls lost), and the results lean its way. No matchup needs it off. Worth watching:
a human Clockwork or Brood who rushes earlier than the computers do (the computers' first attacks come at 5:37 / 7:38, so
these games could not test a sub-4:00 rush; the opening's own rule, a seen rush puts the Barracks first, is the guard).

## How it was measured

- **The design of docs/winrate_2026_11_15.md**: `tools/qa_match.gd` via `qa_matches.run_one`, Hard OPTIMAL v Hard OPTIMAL,
  the 19 two-player maps, round 0 and round 1 (`qa_matches.base()`: the same tags, seeds and sides, sides swapped between
  rounds), Crown v Brood and Crown v Clockwork, **to 12:00** (`end:720`). 38 games a pairing.
- **Each game twice**: arm "ff" as is, arm "off" with `farmfirst:off`; the same map, seed and sides, so each pair differs
  only by the opening. Queue and runner: `tools/study/farmfirst_measure.py` (new; the two arms of a game back to back).
  Two games at a time on a 2-core machine, ~4.6 h for the 152 games.
- **Report**: `tools/study/farmfirst_report.py DATA` (new). Won or led = a win, or a draw at 12:00 led by income earned +
  2 x army value 10% ahead (the win-rate studies' rule). Income = gold earned by then (cumulative); a ratio is the sum of
  the Crown's over the sum of the enemy's in the games still running at that minute. Early loss = the game lost, or a built
  Crown hall lost, before 6:00. Sign tests are two-sided binomial over the pairs that differ.
- Note: v the Brood, OPTIMAL now opens Balanced in every game (not the Horseman rush of the 11-15 study), on this branch.

## Income and army by minute

The Crown's income earned (mean of the games):

| pairing | arm | 2:00 | 3:00 | 5:00 | 8:00 | 12:00 |
|---|---|---|---|---|---|---|
| v Brood | Farm first | 760 | 1,400 | 3,210 | 8,210 | 14,215 |
| v Brood | old order | 760 | 1,140 | 2,910 | 7,650 | 13,376 |
| v Clockwork | Farm first | 760 | 1,380 | 3,080 | 7,040 | 11,889 |
| v Clockwork | old order | 760 | 1,150 | 2,680 | 6,360 | 10,707 |

Over the enemy's: v Brood 1.32 / 1.26 / 1.00 / 0.91 / 0.77 (Farm first) v 1.32 / 1.03 / 0.90 / 0.85 / 0.72 (old) at
2 / 3 / 5 / 8 / 12; v Clockwork 0.74 / 0.73 / 0.75 / 0.72 / 0.58 v 0.74 / 0.61 / 0.65 / 0.64 / 0.51.

Army value over the enemy's at 3 / 5 / 8 / 12: v Brood 0.00 / 0.45 / 0.55 / 0.32 (Farm first) v 0.00 / 0.38 / 0.44 / 0.28;
v Clockwork 0.77 / 0.65 / 0.67 / 0.26 v 2.40 / 0.76 / 0.52 / 0.21 (at 3:00 both sides have only a soldier or two: the
ratio is noise). Workers at 5:00: 26.7 v 24.7 (Brood), 24.0 v 21.5 (Clockwork); at 8:00 44.7 v 43.7, 37.8 v 34.1.

## Paired sign tests (Farm first better / old better / tie)

| measure | v Brood | p | v Clockwork | p |
|---|---|---|---|---|
| result (W > w > = > l > L) | 8 / 5 / 25 | 0.58 | 3 / 0 / 35 | 0.25 |
| income ratio 3:00 | 26 / 0 / 12 | <0.001 | 29 / 7 / 2 | <0.001 |
| income ratio 5:00 | 31 / 6 / 1 | <0.001 | 33 / 5 / 0 | <0.001 |
| income ratio 8:00 | 30 / 8 / 0 | <0.001 | 32 / 6 / 0 | <0.001 |
| income ratio 12:00 | 19 / 10 / 0 | 0.14 | 25 / 12 / 0 | 0.047 |
| army ratio 5:00 | 18 / 11 / 9 | 0.27 | 10 / 22 / 6 | 0.05 |
| army ratio 8:00 | 24 / 14 / 0 | 0.14 | 29 / 9 / 0 | 0.002 |

Per-game rows (both arms side by side, with OPTIMAL's pick) are in tables.md.
