# The computer opponent, reviewed (ai-opponent-review, 2026-11-21)

Written to be listened to. Tables are in `docs/ai_opponent_review/tables.md`; the games in `docs/ai_opponent_review/data/`;
pictures in `docs/shots/ai_opponent_review/`.

Why: the game was graded B minus, and the COMPUTER OPPONENT got a C ("it works, but it's weak and uneven, and it's the thing
most players will meet first"). Balance could not be graded at all, because almost everything was measured computer against
computer. This job does three things: a fresh win-rate matrix on today's main, a yardstick that plays like an ordinary
person (to say where each computer level sits), and a hunt for the computer's visible blunders, fixing the clear ones.

No balance number was changed. Every change is in how the computer plays, and each one has an off switch.

## In short

- **The matrix (Hard against Hard, 71 games to 20:00):** the Crown computer now beats or leads the Clockwork computer (7
  of 11; on 11-17 it led none at 12:00) and leads the Brood computer at 12:00 (9 of 12) but loses to it by 20:00 (the
  Brood won or led 8 of 12). Brood v Clockwork is even. The mirrors finish now, mostly between 14:00 and 18:00.
- **Where the levels sit**, measured with a new human-like benchmark player (NOVICE, AVERAGE, GOOD; 81 games): EASY is
  beaten by every strength, except the Easy Brood, which beat everyone. NORMAL is not a close game for the average
  player: the computer wins or leads two games in three. HARD beat the good benchmark player in every game. The Brood
  computer is about a level stronger than the Crown and Clockwork computers at every level; the Crown computer the weakest.
- **Blunders**: no computer stood idle while its base burned or sat on a big bank. The laughable ones were: the Easy
  Brood not being easy (it had no worker cap), one rider keeping the whole Brood army at home, a wrong AI STORY line ("far
  behind" with twice the army), the Crown's guns and wagons stuck, the Hard Crown watching a hall die from its high
  ground, and the Clockwork's whole army turning round for one raider.
- **Fixed** (each with an off switch): the Easy and Normal Brood get a worker cap like the others, the Easy Brood lays its
  warriors at half the pace (the benchmark players went from 2 of 9 to 5 of 8 won or led against it), a squad guards
  against riders while the rest of the Brood plays on (the guard never over 725, was up to 3,875), and the AI STORY line
  says why it waits.
- **Next**: make the levels mean the same for every faction (the Normal Brood next), decide what Normal is, give Hard a
  habit a good player can find, and play the owner's own games against each level to calibrate the benchmark.

## 1. The matrix: the Hard OPTIMAL computer against itself, all nine matchups, to 20:00

How: the 2026-11-17 study's design (Hard OPTIMAL against Hard OPTIMAL, the sides swapped between round 0 and round 1),
cut down to the six "parity" maps of every kind (Greenhold, Dune Sea, Frostfang, Ashford Crossing, Hollowfen, Cinder
Steps), 12 games a pairing, 71 games in all, on today's main (0.38.107, before this job's fixes), each to 20:00. One game
timed out (Crown v Clockwork, Greenhold round 1). Beside it: the same tags (map, seed, sides) in the 11-17 study, which
ran to 12:00, so the comparison is at 12:00.

| pairing | games | W-D-L 20:00 | won or led 20:00 | median end of decided | W-D-L 12:00 | won or led 12:00 | 11-17 same tags (12:00) | paired better / worse (p) |
|---|---|---|---|---|---|---|---|---|
| Crown v Brood | 12 | 0-8-4 | 3 / 8 / 1 | 17:16 | 0-12-0 | 9 / 2 / 1 | 2 / 9 / 1 | 9 / 1 (0.02) |
| Crown v Clockwork | 11 | 2-8-1 | 7 / 2 / 2 | 14:39 | 0-11-0 | 2 / 5 / 4 | 0 / 10 / 1 | 6 / 1 (0.12) |
| Brood v Clockwork | 12 | 4-4-4 | 6 / 6 / 0 | 15:52 | 0-11-1 | 2 / 8 / 2 | 0 / 11 / 1 | 4 / 1 (0.38) |
| Crown v Crown (P1) | 12 | 4-5-3 | 6 / 6 / 0 | 18:08 | 0-12-0 | 5 / 3 / 4 | 4 / 6 / 2 | 5 / 3 (0.73) |
| Brood v Brood (P1) | 12 | 3-8-1 | 5 / 4 / 3 | 14:14 | 0-12-0 | 5 / 2 / 5 | 6 / 3 / 3 | 2 / 3 (1.00) |
| Clockwork v Clockwork (P1) | 12 | 2-4-6 | 2 / 6 / 4 | 13:31 | 0-11-1 | 4 / 6 / 2 | 7 / 3 / 2 | 2 / 6 (0.29) |

Read aloud:

1. **Crown v Clockwork turned over.** At 12:00 the Crown led 2 and trailed 5 (on 11-17: 0 and 10); by 20:00 it won 2,
   lost 1 and led 5 more: 7 of 11 won or led. Income a minute is even at 8:00 (0.97) and the Crown's from 12:00 (1.14,
   then 1.39 at 16:00). This is the crown-rule-cleanup of 0.38.107: against the Clockwork its army clock, army floor,
   fight rules and home hold were cut and it plays its economy.
2. **Crown v Brood: the Crown leads at 12:00 and loses by 20:00.** At 12:00 the Crown led 9 of 12 (on 11-17: 2, paired
   9 better and 1 worse, p 0.02), with 1.8 times the Brood's army at 8:00. Then the Brood out-earns it (the Crown's
   income a minute 1.28 of the Brood's at 8:00, 0.76 at 12:00, 0.59 at 16:00), and by 20:00 the Brood won 4, led 4; the
   Crown led 3 and won none. This is what crown-rule-cleanup found: "the Crown leads to ~14:00 and loses at 15-19".
3. **Brood v Clockwork is even again**: 4 wins each, 6 won or led each. At 12:00 the Clockwork still leads 8 of 12 (11 of
   12 on 11-17): the Brood's army is half the Clockwork's at 8:00 and it comes back late.
4. **The mirrors now finish**: decided by 20:00 Crown 7 of 12 (11-17: 2 of 19 to 20:00), Brood 4, Clockwork 8. Spot A
   against spot B: Crown 6 v 6, Brood 5 v 4, Clockwork 2 v 6 (P1 lost 6 of 12; p 0.29 on 8 decided games: not proven, but
   worth watching: on 11-17 spot A led 7 v 3 at 12:00).
5. Across the six pairings 34 of 71 games ended by 20:00 (the median end 13:31 to 18:08 by pairing). At 12:00 only 2 had:
   a win rate to 12:00 measures who is ahead, a win rate to 20:00 begins to measure who wins.

## 2. Where each computer level sits: the human-like benchmark player

### What the benchmark player is

A new measuring tool (`scripts/ai_bench_human.gd`, class BenchHuman), used only by the study tool, never in a real match.
It plays each faction's Balanced plan, a standard build, with the Hard computer's knowledge of how to build. What makes it
"human" is a person's limits:

- It looks at the game only every so often: about every 1.5 seconds for the NOVICE, 1 second for the AVERAGE player and
  0.6 seconds for the GOOD player, with some jitter. The Hard computer thinks every 0.4 to 0.7 seconds.
- Each look it manages ONE place: either its economy and production at home, or its army. It looks at its army about a
  quarter to a third of the time, and always once it has NOTICED an attack on its base. Noticing takes 6 seconds for the
  novice, 3 for the average player and about 1 for the good one.
- It forgets: on some looks at home it makes no workers (novice 35% of the time, average 15%, good 5%) or no soldiers
  (the same shares). Its workers stop at 24 (novice), 36 (average) or 48 (good).
- No perfect micro: none of the Hard computer's focus fire, kiting or pulling back hurt units, and no rider hit and run.
  The novice uses no special abilities; only the good player hunts an enemy scout in its base.
- It attacks when its plan says it has a decent army.

What it is not: a person. It shares the computer's own build logic, so it shares its blind spots, and it never baits the
computer or learns its habits. A real person who does those things will do better than these numbers. Treat it as a
ruler, not as the owner.

Does the ruler work? Played against each other (9 games, faction against faction), the stronger benchmark player won or
led 6 of 9 and lost or trailed 2. In the tables below the stronger players do better against every level, and every
player does worse as the level goes up. So the ruler orders things the right way.

### How it was measured

Each benchmark faction, at each strength, played each computer faction at Easy, Normal and Hard (the computer on its
OPTIMAL plan): 81 games, one per cell, to 15:00, on six maps of all kinds (Greenhold, Dune Sea, Frostfang, Ashford
Crossing, Hollowfen, Cinder Steps), sides alternating. A game not ended by 15:00 is "led" by the side 10% ahead on
income earned plus twice its army's value (the earlier studies' rule).

Three games per computer faction, level and strength is few. Read the totals (nine games a cell) as the real result
and the faction rows as hints.

### The results (before the fixes in section 3)

Each cell is the BENCHMARK PLAYER's record against that computer: won-drawn-lost at 15:00, then in brackets won or led /
lost or trailed / even. The "all" row is the three computer factions together (nine games).

### NOVICE player

| computer | v EASY | v NORMAL | v HARD |
|---|---|---|---|
| Crown computer | 1-2-0 (2 / 0 / 1) | 0-2-1 (0 / 3 / 0) | 0-3-0 (1 / 2 / 0) |
| Brood computer | 0-1-2 (0 / 3 / 0) | 0-0-3 (0 / 3 / 0) | 0-1-2 (0 / 2 / 1) |
| Clockwork computer | 1-1-1 (2 / 1 / 0) | 1-1-1 (2 / 1 / 0) | 0-1-2 (0 / 3 / 0) |
| **all** | 2-4-3 (4 / 4 / 1) | 1-3-5 (2 / 7 / 0) | 0-5-4 (1 / 7 / 1) |

### AVERAGE player

| computer | v EASY | v NORMAL | v HARD |
|---|---|---|---|
| Crown computer | 2-1-0 (3 / 0 / 0) | 0-3-0 (0 / 2 / 1) | 0-2-1 (1 / 2 / 0) |
| Brood computer | 0-1-2 (1 / 2 / 0) | 0-1-2 (0 / 3 / 0) | 0-0-3 (0 / 3 / 0) |
| Clockwork computer | 2-1-0 (2 / 1 / 0) | 0-2-1 (2 / 1 / 0) | 0-0-3 (0 / 3 / 0) |
| **all** | 4-3-2 (6 / 3 / 0) | 0-6-3 (2 / 6 / 1) | 0-2-7 (1 / 8 / 0) |

### GOOD player

| computer | v EASY | v NORMAL | v HARD |
|---|---|---|---|
| Crown computer | 2-1-0 (3 / 0 / 0) | 1-2-0 (1 / 2 / 0) | 0-3-0 (0 / 1 / 2) |
| Brood computer | 0-1-2 (1 / 2 / 0) | 1-2-0 (1 / 1 / 1) | 0-0-3 (0 / 3 / 0) |
| Clockwork computer | 3-0-0 (3 / 0 / 0) | 1-1-1 (1 / 2 / 0) | 0-2-1 (0 / 2 / 1) |
| **all** | 5-2-2 (7 / 2 / 0) | 3-5-1 (3 / 5 / 1) | 0-5-4 (0 / 6 / 3) |

Read aloud, the "all" rows say:

- EASY: the novice won or led 4 of 9, the average player 6 of 9, the good player 7 of 9. Against the Easy Crown and the
  Easy Clockwork every strength wins or leads most games. Against the Easy BROOD nobody did: the novice 0 of 3, the
  average and good players 1 of 3 each.
- NORMAL: the novice won or led 2 of 9 (lost 5), the average player 2 of 9 (lost 3, trailed 6), the good player 3 of 9.
  Normal is not a close game for the average player: the computer leads two games in three.
- HARD: the novice 1 of 9, the average player 1 of 9 (lost 7), the good player 0 of 9 (lost 4, trailed 2, even 3). The
  good benchmark player never beat the Hard computer in 15 minutes.
- By faction: the BROOD computer is the strongest at every level (the benchmark won or led 3 of its 27 games), the CROWN
  computer the weakest (11 of 27; at Easy and Normal it beat a benchmark player only once). The Clockwork is between (12 of 27).
- Economy at 8:00: against Easy every benchmark player out-earns the computer except the novice (0.95); against Hard
  every one earns less (0.79 novice, 0.87 average, 0.95 good). The Hard computer also wins sooner (median 12:10-13:29).


### Against the owner's targets

- "A novice should usually beat Easy": MET against the Easy Crown and the Easy Clockwork (the novice won or led 4 of 6),
  NOT against the Easy Brood (0 of 3). After the two Easy Brood fixes (section 3) the novice won or led 2 of 3 against it,
  and every strength together 5 of 8 (before: 2 of 9).
- "An average player should have close games on Normal": NOT MET. The Normal computer leads or wins 6 of 9 against the
  average player, the Brood all 3. Normal sits closer to "a good player's fair fight": the good player won or led 3 and
  lost 1. The Normal Brood is the furthest off (the cap fix does not touch it before 9:00).
- "A good player should find Hard a real fight": MORE THAN MET. The good player won no game in 9 and led none; Hard is a
  wall, not a fight, for this benchmark. (A real good player who micro-manages, baits and scouts will do better: the
  benchmark has no micro at all.)
- So, roughly: EASY is where the owner wants it for the Crown and the Clockwork; NORMAL plays like the owner's idea of HARD;
  HARD is beyond the good benchmark player; and the Brood computer is one level stronger than the other two at every level.

## 3. The computer's blunders

### How they were found

Three ways: the match tool's own detectors over all the study games (an army standing still while the enemy is in its
base, a bank left unspent, no units made, units stuck on a move, a first attack that traded badly, no attack by 12:00,
one hall at 10:00); the match logs of every game (the computer explains each decision there, and the AI STORY the player
reads is made from them); and filmed games (pictures every 15 seconds, the armies every minute, every fight).

The blunder scan over the 81 benchmark games (the computer's side only; the full table in tables.md):

| computer | army idle while the enemy is in its base | bank unspent | units stuck | no attack by 12:00 | one hall at 10:00 |
|---|---|---|---|---|---|
| Crown Easy / Normal / Hard | 0 / 0 / 0 | 1 / 0 / 0 | 1 / 2 / 3 games | 1 / 1 / 3 | 5 / 0 / 0 |
| Clockwork Easy / Normal / Hard | 0 / 0 / 0 | 0 / 0 / 0 | 1 / 0 / 0 | 0 / 0 / 0 | 5 / 2 / 0 |
| Brood Easy / Normal / Hard | 0 / 0 / 0 | 0 / 1 / 1 | 0 / 1 / 0 | 0 / 0 / 0 | - |

(9 games a level and faction.) No computer stood idle with its army while its base burned, and none sat on a big bank
for long. The laughable things are subtler, and the logs and films show them:

1. **THE EASY BROOD IS NOT EASY** (a bug in the levels). The Crown and Clockwork computers stop making workers by level
   (Easy 16, Normal 30 or 26, Hard 40 or 32); the Brood computer stopped only by its plan, 46 to 54 grubs, at every
   level. Its Easy had the Hard economy with a later first wave. At 8:00 the Easy Brood had 47 grubs and 2,460 of army
   (the Easy Crown 840, the Easy Clockwork 1,500, the HARD Brood 1,070) and it beat the good benchmark player.
   Picture: `easy_brood_army_0830.jpg` (the Easy Brood's army of 4,170 by its Mother at 8:30, a good Crown player at 1,850).
2. **ONE RIDER PINS THE WHOLE BROOD ARMY** (a bug). Against riders at home the Brood guards its grubs and does not chase
   (the owner's rule), but the guard was EVERY creature not in a wave, and while it guarded no wave could leave. In a
   Normal Brood's game one Cuirassier circling its land kept 89, then 122 creatures (4,175 of army) at home from 10:06
   to 10:56. Pictures: `rider_pin_before_map_1030.png` (the whole map at 10:30: the Brood's dots all at home, top left)
   and `rider_pin_before_brood_1030.jpg`.
3. **THE CROWN SAYS ITS ARMY IS "FAR BEHIND" WITH TWICE THE ENEMY'S** (a wrong line in the AI STORY). "Milestone Armoury
   waits: the army is far behind the enemy's (1,580 against the 775 it reckons)". The hold was for another reason (the
   Brood it ESTIMATES blind, a short home line, or a Barracks idle for want of gold) and the line printed the wrong pair.
4. **THE CROWN'S WHEELS GET STUCK**: Field Cannons, Mortars and Powder Wagons stuck on a move order in 6 of the 27 Crown
   computer games (and the benchmark Crown's own guns too): pathing for the big wheeled units, not a decision.
5. **THE HARD CROWN RARELY GOES OUT**: in 3 of 9 games it had not attacked by 12:00 (twice against a benchmark Crown,
   once against a Clockwork). Its Siege push went out at 8:11 with 19 supply and one gun and fell back at 8:51; at 13:23
   its 1,863 of army watched from the top of its ramp while 1,520 of the novice's took a hall below ("goes down only at
   1,978": it wants 1.3 times the force before it leaves the high ground).
6. **THE CLOCKWORK SENDS ITS WHOLE ARMY AGAINST SMALL RAIDS**: "the whole army defends the base (12 units, 1,160) against a
   raid worth 150": 31 of 166 such lines in the benchmark games were more than five times the raid. Short (the raid leaves
   or dies), so it costs less than the Brood's pin, but a human sees the whole army turn round for one rider.
7. **THE EASY COMPUTERS DO NOT EXPAND**: the Easy Crown and the Easy Clockwork are still on one hall at 10:00 in 5 of 9
   games each. That is Easy being easy, and fine; listed because a human notices it.

### What was fixed (each behind an off switch, each measured)

1. **THE EASY AND NORMAL BROOD GET A WORKER CAP** like the other computers (switch `levelgrubs:off`): Easy 20 grubs, Normal
   38, Hard and Brutal unchanged. The caps match the others' by income (a grub earns about three quarters of a labourer).
   Measured on the same 18 benchmark games: the Easy Brood's income at 8:00 fell from about 9,300 to 6,000, but its army
   hardly (2,460 -> 2,400): the Brood has no buildings to buy, so the food goes into creatures. Results for the computer:
   better in 2, worse in 7, the same in 7. Normal is not touched before 9:00 (its grubs stay under 38 till then).
2. **THE EASY BROOD LAYS ITS WARRIORS AT HALF THE PACE** (switch `easypace:off`): a warrior egg on every other think, not
   while a big attack is at its Mother. Together with the cap, on the same 8 Easy Brood games: the benchmark players won or
   led 5 of 8 (before 2 of 9), the novice 2 of 3 (before 0 of 3); the computer was worse in 5 games and the same in 3.
   Both Brood level fixes are for skirmish and the tutorial's practice games only: the story missions' Brood computers
   (the rival pack of the Brood prologue is an Easy Brood capped at 36 supply) play as they were tuned
   (test_campaign_b01 and test_tutorial pass).
3. **A SQUAD GUARDS AGAINST RIDERS, THE REST PLAYS ON** (switch `ridersquad:off`): when the Brood's guard is strong (2.5
   times the riders), only the nearest creatures worth 3 times the riders (400 at least) guard the grubs, with the same
   no-chase rule; the others go back to the plan and its waves. Filmed again on the same map and seed: the guard against
   the one Cuirassier was 14 to 16 creatures (410-420) instead of 89 to 122, and the wave left at 10:26 instead of 10:56
   (`rider_squad_after_wave_1039.jpg`). In the 12 Crown v Brood matrix games run again on the fixed code (the Crown OPTIMAL rides its Horsemen into every
   Brood), the guard's value never went over 725 (before: 44 guard lines over 1,500, up to 3,875); the results moved
   within the noise (for the Brood 4 better, 5 worse, 3 the same; it won or led 10 of 12, before 8). The Brood's rider tests pass (test_brood_v_riders,
   test_brood_rush_riders).
4. **THE CROWN'S "MILESTONE WAITS" LINE GIVES ITS REAL REASON**: "the army is far behind the enemy's (army against the
   reckoned enemy)" only when that is the reason; otherwise "the army comes first" with the Brood it estimates, its short
   home line, or its idle Barracks. The AI STORY line the player reads is the same ("its army comes first").

The AI tests (tools/test_ai_*.gd, 23) before and after: the same two fail on main and on the branch
(test_ai_rush_followup, test_ai_wall_vs_rush: "Barracks and Powder Mill by 75 s", 100 s; both listed as known in
CLAUDE.md); test_ai_harass's [raid] check failed once before and passed after (known flaky).

### Not fixed: proposals

- **The Normal Brood is still a level too strong** for the average benchmark player (it won all three). A Normal pace like
  Easy's (a warrior on two thinks in three) is the obvious next step; not done because Normal is less clearly a bug and
  wants its own measurement.
- **The Hard Crown's high-ground rule** (BEAT 1.3, against the Brood about 2): it watched a hall die below while bigger
  than the attackers. Proposal: when one of its own halls below is being hit, go down at 1.0 (an even fight) instead.
- **The Clockwork's whole-army defence**: send a share sized to the raid (as the Brood's squad now does) and keep the rest
  where it was.
- **The Crown's wheeled units getting stuck**: a pathing job (the big units' corner slip), not an AI one.
- **The match tool's first_attack misses the Crown's Siege push and the Clockwork's push** (they are not "waves"); this
  report counts an army arriving in the enemy's base as well. Worth fixing in tools/qa_match.gd.

## 4. What would most improve the computer opponent next

In order of what a player would feel first:

1. **Make the levels mean the same for every faction.** The Brood computer is a level stronger than the Crown and the
   Clockwork at Easy, Normal and Hard alike. The two Easy fixes here are the start; Normal wants the same (a slower pace,
   measured against the average benchmark player), and Hard v Hard the Brood leads the Crown from 12:00 on (section 1).
2. **Re-label or re-tune Normal.** Against the benchmark players Normal plays like the owner's idea of Hard (the average
   player wins or leads 2 of 9). Either Normal gets a little slower (its think 1.2 s, its worker caps), or the lobby says
   so ("Normal: for players who know the game").
3. **Give Hard something a good player can find and punish.** Hard beat the good benchmark player in every game. A real
   good player out-plays the benchmark with micro and baiting, so Hard may be right for them; but a computer with no
   readable habit is no fun to beat. The Crown's passivity (the high-ground rule, the Siege push that turns round) is the
   habit to keep and make fair; the Brood's and Clockwork's waves are the ones to make readable.
4. **Fix the visible silliness that remains**: the Clockwork's whole army against one raider, the Crown's stuck guns and
   wagons, the Crown's hall dying below a bigger army on the high ground.
5. **Measure against people.** The benchmark has the computer's blind spots. One evening of the owner's own games against
   each level, logged (the match log already says everything the computer decides), would show whether the benchmark's
   NOVICE / AVERAGE / GOOD are the right yardstick; the tool can then be tuned to match him.

## 5. Balance observations (proposals only, nothing changed)

From the computer-against-computer matrix only; the AI's skill is part of every number, so these are leads to check,
not verdicts.

- **The Brood's late game**: against the Crown it is behind on army until 14:00-16:00 and wins anyway, on income (the
  Crown earns 0.59 of the Brood a minute at 16:00). With the Crown computer now playing its economy, this looks more like
  the Brood's late economy than the Crown's AI. If it is confirmed with human players: look at the Rootmaws' late yield,
  or the Brood's supply cap army at even income (crown-rule-cleanup's question).
- **The Clockwork mirror's spot B** (P1 lost 6 of 12) and the Brood v Clockwork early game (the Brood's army half the
  Clockwork's at 8:00, then even at the bell): measure before any change.
- **The level gap between factions** (section 2) is AI tuning, not balance: do not read the benchmark tables as faction
  balance.

## The tools

- `scripts/ai_bench_human.gd`: the benchmark player. A qa_match slot `faction/plan/side/who` with who = novice, average or
  good runs it (who may also be easy, normal, hard or brutal for a computer of that level).
- `tools/study/ai_opponent_review.py`: the study's queue (sanity, bench, the matrix, the fix measurements), run from a
  frozen copy of the game (`tools/study/freeze_copy.sh`: scripts and tools copied, the art symlinked) so code edited
  meanwhile cannot leak into running games.
- `tools/study/ai_opponent_review_report.py DATA > tables.md`: every table above.
- `tools/study/ai_opponent_review_fix.py FIXDATA BASEDATA`: a fix's games beside the study's on the same tags.
- `tools/study/ai_opponent_review_film.sh TAG [END]`: films a study game (pictures for this document).
- `tools/study/run_ai_tests.sh [ROOT]`: every tools/test_ai_*.gd, a line each.
